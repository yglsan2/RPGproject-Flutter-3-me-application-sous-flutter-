// ignore_for_file: deprecated_member_use, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_provider.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';
import '../services/character_generator_service.dart';
import '../services/name_generator_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/stat_descriptions.dart';
import '../utils/roll_d6.dart';
import 'character_detail_screen.dart';

class NPCCreationScreen extends StatefulWidget {
  const NPCCreationScreen({super.key});

  @override
  State<NPCCreationScreen> createState() => _NPCCreationScreenState();
}

class _NPCCreationScreenState extends State<NPCCreationScreen> {
  // État du formulaire
  String? _selectedType; // ANGE, DEMON, HUMAIN, AUTRE
  String? _selectedSubType; // Sous-type pour AUTRE
  String? _selectedGrade; // 0, 1, 2, 3, AVATAR, ARCHANGE
  String? _selectedSuperior;
  Map<String, int> _characteristics = {
    'FO': 0, // Force
    'VO': 0, // Volonté
    'AG': 0, // Agilité
    'PE': 0, // Perception
    'PR': 0, // Présence
    'AP': 0, // Apparence (?)
  };
  /// Pouvoirs par slot (1-5). Clé = numéro de pouvoir, valeur = nom du pouvoir.
  final Map<int, String?> _powerSelections = {1: null, 2: null, 3: null, 4: null, 5: null};
  /// Pour le pouvoir 2 : true = table Supérieur, false = table Générale.
  bool _power2UseSuperior = false;
  /// Limitation : false = non, true = oui avec _limitationName.
  bool _hasLimitation = false;
  String? _limitationName;
  bool _npcDiminished = true;
  final Random _random = Random();

  // Tables de pouvoirs selon le PDF
  final List<String> _superiorPowers = [
    'SOMMEIL',
    'LIRE LES SENTIMENTS',
    'NON-DÉTECTION',
    'LIRE LES PENSÉES',
    'RÊVE',
    '(SPE) RÊVE DIVIN',
  ];

  final Map<int, String> _generalPowers = {
    126: 'ATTAQUE SONIQUE',
    226: 'IMMUNITÉ FEU',
    326: 'CHAMP ÉLECTRIQUE',
    426: 'LIRE PENSÉES',
    526: 'RELIQUE SACRÉE',
    626: 'PAPARAZZI',
    132: 'JET D\'EAU BÉNITE',
    232: 'IMMUNITÉ FROID',
    332: 'CHAMP MAGNÉTIQUE',
    432: 'LIRE SENTIMENTS',
    532: 'BRACELET',
    632: 'ENQUÊTEUR',
    156: 'CALME',
    256: 'CONV. MENTALE',
    356: 'POLYMORPHIE',
    456: 'DÉPL. TEMPOREL',
    556: 'SALLE DE CONCERT',
    656: 'ROYALISTES',
  };

  final List<String> _otherSubTypes = [
    'Serviteur de Dieu',
    'Soldat de Dieu',
    'Humain béni',
    'Fils de Dieu',
    'Fille de Dieu',
    'Mort-vivant',
    'Familier',
    'Humain maudit',
    'Incube',
    'Succube',
  ];

  final List<String> _limitations = [
    'ACCÈS DE COLÈRE',
    // Ajouter d'autres limitations selon les règles
  ];

  /// Clé de traduction pour la bulle d'aide du grade.
  static String _gradeDescKey(String value) {
    if (value == 'AVATAR') return 'grade_desc_avatar';
    if (value == 'ARCHANGE') return 'grade_desc_archange';
    return 'grade_desc_$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people, color: AppTheme.medievalGold),
            const SizedBox(width: 8),
            Text(AppLocalizations.trSafe(context, 'create_npc_short')),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _generateFullRandomNPC,
            icon: const Icon(Icons.casino, color: AppTheme.medievalGold, size: 20),
            label: Text(AppLocalizations.trSafe(context, 'full_random')),
            style: TextButton.styleFrom(foregroundColor: AppTheme.medievalGold),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.save, color: AppTheme.medievalGold),
            onPressed: _generateNPC,
            tooltip: AppLocalizations.trSafe(context, 'generate_npc'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPreviewCard(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildNPCOptionsCard(),
            const SizedBox(height: 16),
            if (_selectedType == 'AUTRE') ...[_buildSubTypeSelector(), const SizedBox(height: 16)],
            const SizedBox(height: 16),
            _buildGradeSelector(),
            const SizedBox(height: 16),
            if (_selectedType != null) _buildSuperiorSelector(),
            const SizedBox(height: 16),
            _buildCharacteristicsSelector(),
            const SizedBox(height: 16),
            _buildPowersSelector(),
            const SizedBox(height: 16),
            _buildLimitationSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.medievalBronze.withValues(alpha: 0.2),
              AppTheme.medievalGold.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.trSafe(context, 'type_person_label'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              _buildSectionDescription(
                AppLocalizations.trSafe(context, 'type_section_help'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...['ANGE', 'DEMON', 'HUMAIN', 'AUTRE'].map((type) {
                    return _buildSelectableButton(
                      label: type == 'ANGE' ? AppLocalizations.trSafe(context, 'type_angels') : type == 'DEMON' ? AppLocalizations.trSafe(context, 'type_demons') : type == 'HUMAIN' ? AppLocalizations.trSafe(context, 'type_humans') : AppLocalizations.trSafe(context, 'type_other'),
                      isSelected: _selectedType == type,
                      onTap: () => setState(() {
                        _selectedType = type;
                        if (type != 'AUTRE') {
                          _selectedSubType = null;
                        }
                      }),
                    );
                  }),
                  _buildSelectableButton(
                    label: AppLocalizations.trSafe(context, 'draw_random'),
                    isSelected: false,
                    onTap: () {
                      final mainTypes = ['ANGE', 'DEMON', 'HUMAIN', 'AUTRE'];
                      final type = mainTypes[_random.nextInt(mainTypes.length)];
                      setState(() {
                        _selectedType = type;
                        _selectedSubType = type == 'AUTRE'
                            ? _otherSubTypes[_random.nextInt(_otherSubTypes.length)]
                            : null;
                      });
                    },
                  ),
                ],
              ),
              if (_selectedType != null)
                Builder(
                  builder: (context) {
                    final descKey = _selectedType == 'ANGE'
                        ? 'type_desc_angel'
                        : _selectedType == 'DEMON'
                            ? 'type_desc_demon'
                            : _selectedType == 'HUMAIN'
                                ? 'type_desc_human'
                                : null;
                    if (descKey == null) return const SizedBox();
                    return _buildSectionDescription(AppLocalizations.trSafe(context, descKey));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDescription(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppTheme.medievalGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.medievalDarkBrown.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNPCOptionsCard() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SwitchListTile(
          title: Text(AppLocalizations.trSafe(context, 'npc_diminished')),
          subtitle: Text(AppLocalizations.trSafe(context, 'npc_subtitle_diminished')),
          value: _npcDiminished,
          onChanged: (value) => setState(() => _npcDiminished = value),
          activeThumbColor: AppTheme.medievalGold,
        ),
      ),
    );
  }

  Widget _buildSubTypeSelector() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.medievalBronze.withValues(alpha: 0.2),
              AppTheme.medievalGold.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.trSafe(context, 'sub_type_other'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              _buildSectionDescription(
                AppLocalizations.trSafe(context, 'other_section_help'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._otherSubTypes.map((subType) {
                    return _buildSelectableButton(
                      label: subType,
                      isSelected: _selectedSubType == subType,
                      onTap: () => setState(() => _selectedSubType = subType),
                    );
                  }),
                  _buildSelectableButton(
                      label: AppLocalizations.trSafe(context, 'draw_random'),
                      isSelected: false,
                      onTap: () {
                        setState(() {
                          _selectedSubType = _otherSubTypes[_random.nextInt(_otherSubTypes.length)];
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _gradeOptionKeys = [
    ('0', 'grade_0'),
    ('1', 'grade_1'),
    ('2', 'grade_2'),
    ('3', 'grade_3'),
    ('AVATAR', 'grade_avatar'),
  ];

  Widget _buildGradeSelector() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.trSafe(context, 'grade_label'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              _buildSectionDescription(
                AppLocalizations.trSafe(context, 'grade_section_help'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._gradeOptionKeys.map((option) {
                    final value = option.$1;
                    final labelKey = option.$2;
                    final tooltip = AppLocalizations.trSafe(context, _gradeDescKey(value));
                    return Tooltip(
                      message: tooltip,
                      preferBelow: false,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: _buildSelectableButton(
                          label: AppLocalizations.trSafe(context, labelKey),
                          isSelected: _selectedGrade == value,
                          onTap: () => setState(() => _selectedGrade = value),
                        ),
                      ),
                    );
                  }),
                  _buildSelectableButton(
                    label: AppLocalizations.trSafe(context, 'draw_random'),
                    isSelected: false,
                    onTap: () {
                      const grades = ['0', '1', '2', '3', 'AVATAR'];
                      setState(() => _selectedGrade = grades[_random.nextInt(grades.length)]);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Titre / exemple de supérieurs adapté au type (traduit).
  String _superiorTitleForType(String? type) {
    switch (type) {
      case 'ANGE':
        return AppLocalizations.trSafe(context, 'superior_title_angel');
      case 'DEMON':
        return AppLocalizations.trSafe(context, 'superior_title_demon');
      case 'HUMAIN':
        return AppLocalizations.trSafe(context, 'superior_title_human');
      default:
        return AppLocalizations.trSafe(context, 'superior_title_generic');
    }
  }

  /// Bulle d’information sur le supérieur, adaptée au type.
  String _superiorDescriptionForType(String? type) {
    switch (type) {
      case 'ANGE':
        return AppLocalizations.trSafe(context, 'superior_desc_angel');
      case 'DEMON':
        return AppLocalizations.trSafe(context, 'superior_desc_demon');
      case 'HUMAIN':
        return AppLocalizations.trSafe(context, 'superior_desc_human');
      default:
        return AppLocalizations.trSafe(context, 'superior_desc_generic');
    }
  }

  Widget _buildSuperiorSelector() {
    final gameProvider = Provider.of<GameProvider>(context);
    final game = gameProvider.currentGame;
    if (game == null) return const SizedBox();

    final typeKey = _selectedType == 'ANGE' ? 'Ange' : _selectedType == 'DEMON' ? 'Démon' : 'Humain';
    final superiors = game.superiors[typeKey] ?? [];

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.medievalBronze.withValues(alpha: 0.2),
              AppTheme.medievalGold.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _superiorTitleForType(_selectedType),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.medievalDarkBrown,
                    ),
                  ),
                  const Spacer(),
                  _buildSelectableButton(
                    label: AppLocalizations.trSafe(context, 'draw_random'),
                    isSelected: false,
                    onTap: () {
                      if (superiors.isNotEmpty) {
                        setState(() => _selectedSuperior = superiors[_random.nextInt(superiors.length)]);
                      }
                    },
                  ),
                ],
              ),
              _buildSectionDescription(
                _superiorDescriptionForType(_selectedType),
              ),
              const SizedBox(height: 12),
              ...superiors.take(10).map((superior) {
                return RadioListTile<String>(
                  title: Text(AppLocalizations.trSuperiorName(context, superior)),
                  value: superior,
                  groupValue: _selectedSuperior,
                  onChanged: (value) => setState(() => _selectedSuperior = value),
                  activeColor: AppTheme.medievalGold,
                );
              }),
              if (superiors.length > 10)
                TextButton(
                  onPressed: () {
                    // Afficher tous les supérieurs dans un dialogue
                    _showAllSuperiors(superiors);
                  },
                  child: Text(AppLocalizations.trSafe(context, 'see_all_count', {'count': '${superiors.length}'})),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _gradeDisplayLabel(String? value) {
    if (value == null) return '—';
    switch (value) {
      case '0': return AppLocalizations.trSafe(context, 'grade_0');
      case '1': return AppLocalizations.trSafe(context, 'grade_1');
      case '2': return AppLocalizations.trSafe(context, 'grade_2');
      case '3': return AppLocalizations.trSafe(context, 'grade_3');
      case 'AVATAR': return AppLocalizations.trSafe(context, 'grade_avatar');
      case 'ARCHANGE': return AppLocalizations.trSafe(context, 'grade_avatar');
      default: return value;
    }
  }

  String _typeDisplayLabel(String? type) {
    if (type == null) return '—';
    switch (type) {
      case 'ANGE': return AppLocalizations.trSafe(context, 'type_angels');
      case 'DEMON': return AppLocalizations.trSafe(context, 'type_demons');
      case 'HUMAIN': return AppLocalizations.trSafe(context, 'type_humans');
      case 'AUTRE': return _selectedSubType != null ? AppLocalizations.trSafe(context, 'other_with_subtype', {'subtype': _selectedSubType!}) : AppLocalizations.trSafe(context, 'type_other');
      default: return type;
    }
  }

  Widget _buildPreviewCard() {
    final gameProvider = Provider.of<GameProvider>(context);
    final game = gameProvider.currentGame;
    final edition = game?.getEdition(gameProvider.currentEditionId ?? (game.editions.isNotEmpty ? game.editions.first.id : ''));
    final statNames = edition?.statNames ?? ['Force', 'Volonté', 'Agilité', 'Perception', 'Présence', 'Apparence'];
    final caracs = statNames.map((n) => _characteristics[n] ?? 0).where((v) => v > 0).length;
    final powersCount = _powerSelections.values.whereType<String>().where((s) => s.isNotEmpty).length;
    return Card(
      child: InkWell(
        onTap: () => _showPreviewSheet(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.medievalGold.withValues(alpha: 0.15),
                AppTheme.medievalBronze.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.preview, color: AppTheme.medievalGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.trSafe(context, 'preview_sheet_title'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.medievalDarkBrown,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.trSafe(context, 'edit_all'),
                      style: TextStyle(fontSize: 12, color: AppTheme.medievalGold, fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.arrow_forward, size: 16, color: AppTheme.medievalGold),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _previewChip(AppLocalizations.trSafe(context, 'preview_type'), _selectedType ?? '—'),
                    _previewChip(AppLocalizations.trSafe(context, 'preview_grade'), _selectedGrade ?? '—'),
                    _previewChip(AppLocalizations.trSafe(context, 'preview_superior'), _selectedSuperior ?? '—'),
                    _previewChip(AppLocalizations.trSafe(context, 'preview_caracs'), caracs > 0 ? '$caracs/6' : '—'),
                    _previewChip(AppLocalizations.trSafe(context, 'preview_powers'), powersCount > 0 ? '$powersCount' : '—'),
                    _previewChip(AppLocalizations.trSafe(context, 'preview_limitation'), _hasLimitation && _limitationName != null ? _limitationName! : AppLocalizations.trSafe(context, 'no')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewChip(String label, String value) {
    return Chip(
      avatar: Icon(Icons.edit, size: 16, color: AppTheme.medievalGold),
      label: Text('$label: $value', style: const TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.medievalBronze.withValues(alpha: 0.2),
    );
  }

  void _showPreviewSheet() {
    final gameProvider = Provider.of<GameProvider>(context);
    final game = gameProvider.currentGame;
    final edition = game?.getEdition(gameProvider.currentEditionId ?? (game.editions.isNotEmpty ? game.editions.first.id : ''));
    final statNames = edition?.statNames ?? ['Force', 'Volonté', 'Agilité', 'Perception', 'Présence', 'Apparence'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: AppTheme.medievalGold.withValues(alpha: 0.2), blurRadius: 12)],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.preview, color: AppTheme.medievalGold),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.trSafe(context, 'npc_preview'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _previewRow(AppLocalizations.trSafe(context, 'preview_type'), _typeDisplayLabel(_selectedType)),
                  _previewRow(AppLocalizations.trSafe(context, 'preview_grade'), _gradeDisplayLabel(_selectedGrade)),
                  _previewRow(AppLocalizations.trSafe(context, 'preview_superior'), _selectedSuperior != null ? AppLocalizations.trSuperiorName(context, _selectedSuperior!) : AppLocalizations.trSafe(context, 'not_chosen')),
                  _previewRow(AppLocalizations.trSafe(context, 'npc_diminished'), _npcDiminished ? AppLocalizations.trSafe(context, 'yes') : AppLocalizations.trSafe(context, 'no')),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.trSafe(context, 'characteristics'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...statNames.map((n) => _previewRow(StatDescriptions.getTranslatedName(context, n), '${_characteristics[n] ?? 0}')),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.trSafe(context, 'powers'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ..._powerSelections.entries.map((e) => _previewRow(AppLocalizations.trSafe(context, 'preview_power_n', {'n': e.key.toString()}), e.value ?? '—')),
                  _previewRow(AppLocalizations.trSafe(context, 'preview_limitation'), _hasLimitation && _limitationName != null ? _limitationName! : AppLocalizations.trSafe(context, 'no')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.medievalDarkBrown)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsSelector() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final game = gameProvider.currentGame;
        final editionId = gameProvider.currentEditionId ?? (game?.editions.isEmpty ?? true ? '' : game!.editions.first.id);
        final edition = game?.getEdition(editionId);
        final statNames = edition?.statNames ?? ['Force', 'Volonté', 'Agilité', 'Perception', 'Présence', 'Apparence'];
        return Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppTheme.medievalCream,
                  AppTheme.medievalCream.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.trSafe(context, 'select_carac_or_more'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.medievalDarkBrown,
                        ),
                      ),
                      const Spacer(),
                      _buildSelectableButton(
                        label: AppLocalizations.trSafe(context, 'random_label'),
                        isSelected: false,
                        onTap: () {
                          setState(() {
                            for (final name in statNames) {
                              _characteristics[name] = RollD6.roll();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  _buildSectionDescription(
                    AppLocalizations.trSafe(context, 'carac_section_help'),
                  ),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: AppTheme.medievalBronze.withValues(alpha: 0.3)),
                    children: [
                      TableRow(
                        children: [
                          const TableCell(child: SizedBox()),
                          ...List.generate(6, (i) => TableCell(
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                        ],
                      ),
                      ...statNames.map((statName) {
                        final value = _characteristics[statName] ?? 0;
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tooltip(
                                  message: StatDescriptions.getTranslatedDescription(context, statName),
                                  preferBelow: false,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.help,
                                    child: Text(
                                      StatDescriptions.getTranslatedName(context, statName),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...List.generate(6, (i) {
                              final v = i + 1;
                              return TableCell(
                                child: Radio<int>(
                                  value: v,
                                  groupValue: value == 0 ? null : value,
                                  onChanged: (newValue) {
                                    setState(() => _characteristics[statName] = newValue ?? 0);
                                  },
                                  activeColor: AppTheme.medievalGold,
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPowersSelector() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.medievalBronze.withValues(alpha: 0.2),
              AppTheme.medievalGold.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.trSafe(context, 'select_power_label'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              const SizedBox(height: 16),
              _buildPowerSelector(1, isSuperior: true),
              const SizedBox(height: 16),
              _buildPowerSelector(2, canChooseTable: true),
              const SizedBox(height: 16),
              _buildPowerSelector(3, isGeneral: true),
              const SizedBox(height: 16),
              _buildPowerSelector(4, isGeneral: true),
              const SizedBox(height: 16),
              _buildPowerSelector(5, isGeneral: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerSelector(int powerNumber, {bool isSuperior = false, bool canChooseTable = false, bool isGeneral = false}) {
    final useSuperiorTable = isSuperior || (canChooseTable && _power2UseSuperior);
    final selectedPower = _powerSelections[powerNumber];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.medievalCream.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.medievalGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSuperior
                ? AppLocalizations.trSafe(context, 'power_n_superior', {'n': '$powerNumber'})
                : isGeneral
                    ? AppLocalizations.trSafe(context, 'power_n_general', {'n': '$powerNumber'})
                    : AppLocalizations.trSafe(context, 'select_power_label'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (canChooseTable) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSelectableButton(
                  label: AppLocalizations.trSafe(context, 'general_table'),
                  isSelected: !_power2UseSuperior,
                  onTap: () => setState(() => _power2UseSuperior = false),
                ),
                const SizedBox(width: 8),
                _buildSelectableButton(
                  label: AppLocalizations.trSafe(context, 'superior_table'),
                  isSelected: _power2UseSuperior,
                  onTap: () => setState(() => _power2UseSuperior = true),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSelectableButton(
                label: AppLocalizations.trSafe(context, 'random_label'),
                isSelected: false,
                onTap: () {
                  String? result;
                  if (useSuperiorTable) {
                    result = _superiorPowers[_random.nextInt(_superiorPowers.length)];
                  } else {
                    final roll = RollD6.roll();
                    final hundreds = RollD6.roll();
                    final key = hundreds * 100 + roll * 10 + powerNumber;
                    result = _generalPowers[key];
                  }
                  setState(() => _powerSelections[powerNumber] = result);
                },
              ),
              if (isGeneral) ...[
                const SizedBox(width: 8),
                _buildSelectableButton(
                  label: AppLocalizations.trSafe(context, 'semi_random'),
                  isSelected: false,
                  onTap: () {
                    final roll = RollD6.roll();
                    final hundreds = RollD6.roll();
                    final key = hundreds * 100 + roll * 10 + powerNumber;
                    final result = _generalPowers[key];
                    setState(() => _powerSelections[powerNumber] = result);
                  },
                ),
              ],
              const Spacer(),
              _buildSelectableButton(
                label: AppLocalizations.trSafe(context, 'choose_label'),
                isSelected: false,
                onTap: () => _showPowerSelectionDialog(powerNumber, useSuperiorTable),
              ),
            ],
          ),
          if (selectedPower != null && selectedPower.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              selectedPower,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.medievalGold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLimitationSelector() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.trSafe(context, 'limitation_label'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              _buildSectionDescription(
                AppLocalizations.trSafe(context, 'limitation_section_help'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: _hasLimitation,
                    onChanged: (value) => setState(() => _hasLimitation = false),
                    activeColor: AppTheme.medievalGold,
                  ),
                  Text(AppLocalizations.trSafe(context, 'no')),
                  const SizedBox(width: 24),
                  Radio<bool>(
                    value: true,
                    groupValue: _hasLimitation,
                    onChanged: (value) => setState(() => _hasLimitation = true),
                    activeColor: AppTheme.medievalGold,
                  ),
                  Text(AppLocalizations.trSafe(context, 'yes')),
                ],
              ),
              if (_hasLimitation) ...[
                const SizedBox(height: 12),
                ..._limitations.map((limitation) {
                  return RadioListTile<String>(
                    title: Text(limitation),
                    value: limitation,
                    groupValue: _limitationName,
                    onChanged: (value) => setState(() => _limitationName = value),
                    activeColor: AppTheme.medievalGold,
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.medievalGold : AppTheme.medievalBronze.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.medievalGold : AppTheme.medievalBronze.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppTheme.medievalDarkBrown : AppTheme.medievalDarkBrown,
          ),
        ),
      ),
    );
  }

  void _showAllSuperiors(List<String> superiors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.trSafe(context, 'all_superiors')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: superiors.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(AppLocalizations.trSuperiorName(context, superiors[index])),
                value: superiors[index],
                groupValue: _selectedSuperior,
                onChanged: (value) {
                  setState(() => _selectedSuperior = value);
                  Navigator.pop(context);
                },
                activeColor: AppTheme.medievalGold,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPowerSelectionDialog(int powerNumber, bool isSuperior) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.trSafe(context, 'choose_power', {'n': '$powerNumber'})),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: isSuperior ? _superiorPowers.length : _generalPowers.length,
            itemBuilder: (context, index) {
              final power = isSuperior
                  ? _superiorPowers[index]
                  : _generalPowers.values.elementAt(index);
              return ListTile(
                title: Text(power),
                onTap: () {
                  setState(() => _powerSelections[powerNumber] = power);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Crée un PNJ entièrement aléatoire (type, grade, supérieur, caractéristiques avec jets auto, pouvoirs…) puis ouvre la fiche.
  Future<void> _generateFullRandomNPC() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final characterProvider = Provider.of<CharacterProvider>(context, listen: false);
    final game = gameProvider.currentGame;
    if (game == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.trSafe(context, 'no_game_system'))));
      return;
    }
    final editionId = gameProvider.currentEditionId ?? (game.editions.isEmpty ? '' : game.editions.first.id);
    final edition = game.getEdition(editionId);
    if (edition == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.trSafe(context, 'edition_not_found'))));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.casino, color: AppTheme.medievalGold),
            const SizedBox(width: 8),
            Text(AppLocalizations.trSafe(context, 'random_npc_full_title')),
          ],
        ),
        content: Text(AppLocalizations.trSafe(context, 'random_npc_dialog_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.trSafe(ctx, 'cancel'))),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.casino, size: 20),
            label: Text(AppLocalizations.trSafe(context, 'generate_npc')),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.medievalGold, foregroundColor: AppTheme.medievalDarkBrown),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    const types = ['ANGE', 'DEMON', 'HUMAIN'];
    final characterTypeKey = types[_random.nextInt(types.length)];
    final characterType = characterTypeKey == 'ANGE' ? 'Ange' : characterTypeKey == 'DEMON' ? 'Démon' : 'Humain';
    final superiorList = game.superiors[characterType];
    String? superiorOverride;
    if (superiorList != null && superiorList.isNotEmpty) {
      superiorOverride = superiorList[_random.nextInt(superiorList.length)];
    }
    final archMap = edition.archetypes[characterType];
    String? archetypeName;
    bool useArchetype = false;
    if (archMap != null && archMap.isNotEmpty) {
      final names = archMap.keys.toList();
      archetypeName = names[_random.nextInt(names.length)];
      useArchetype = true;
    }
    try {
      final character = CharacterGeneratorService.generateCharacter(
        gameSystem: game,
        editionId: editionId,
        characterType: characterType,
        archetypeName: archetypeName,
        isNPC: true,
        useArchetype: useArchetype,
        npcDiminished: _npcDiminished,
        superiorOverride: superiorOverride,
      );
      character.name = NameGeneratorService.generate();
      if (superiorOverride != null) character.superior = superiorOverride;
      characterProvider.setCurrentCharacter(character);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CharacterDetailScreen()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.trSafe(context, 'random_npc_created'))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.trSafe(context, 'error_generic')}: $e')));
    }
  }

  void _generateNPC() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.trSafe(context, 'select_type_please'))),
      );
      return;
    }

    final gameProvider = Provider.of<GameProvider>(context);
    final characterProvider = Provider.of<CharacterProvider>(context);
    final game = gameProvider.currentGame;

    if (game == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.trSafe(context, 'no_game_system'))),
      );
      return;
    }

    // Caractéristiques : clés = noms complets (édition) ou abréviations (legacy)
    final abbrToName = {
      'FO': 'Force', 'VO': 'Volonté', 'AG': 'Agilité',
      'PE': 'Perception', 'PR': 'Présence', 'AP': 'Apparence',
    };
    final characteristics = <String, int>{};
    _characteristics.forEach((key, value) {
      if (value > 0) {
        final statName = abbrToName[key] ?? key;
        characteristics[statName] = value;
      }
    });

    // Créer le personnage
    final editionId = gameProvider.currentEditionId ?? game.editions.first.id;
    final characterType = _selectedType == 'ANGE' ? 'Ange' : _selectedType == 'DEMON' ? 'Démon' : 'Humain';
    
    final character = CharacterGeneratorService.generateCharacter(
      gameSystem: game,
      editionId: editionId,
      characterType: characterType,
      isNPC: true,
      useArchetype: false,
      npcDiminished: _npcDiminished,
      superiorOverride: _selectedSuperior,
    );

    // Mettre à jour avec les valeurs du formulaire
    character.name = NameGeneratorService.generate();
    if (_selectedSuperior != null) {
      character.superior = _selectedSuperior!;
    }
    if (characteristics.isNotEmpty) {
      character.characteristics = characteristics;
    }
    final powersList = _powerSelections.values.whereType<String>().where((s) => s.isNotEmpty).toList();
    if (powersList.isNotEmpty) {
      character.powers = powersList.map((name) => Power(name: name, costPP: 1)).toList();
    }
    if (_limitationName != null && _limitationName!.isNotEmpty) {
      character.motivation = '${character.motivation.isEmpty ? '' : '${character.motivation}\n'}Limitation: $_limitationName';
    }

    characterProvider.setCurrentCharacter(character);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CharacterDetailScreen()),
    );
  }
}
