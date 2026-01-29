// ignore_for_file: deprecated_member_use, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_provider.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';
import '../services/character_generator_service.dart';
import '../services/name_generator_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, color: AppTheme.medievalGold),
            SizedBox(width: 8),
            Text('Créer PNJ'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _generateFullRandomNPC,
            icon: const Icon(Icons.casino, color: AppTheme.medievalGold, size: 20),
            label: const Text('Tout Aléatoire'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.medievalGold),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.save, color: AppTheme.medievalGold),
            onPressed: _generateNPC,
            tooltip: 'Générer le PNJ',
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
              const Text(
                'TYPE DE PERSONNAGE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              _buildSectionDescription(
                'Ange = serviteur du Ciel (Magna Veritas). Démon = serviteur de l\'Enfer (In Nomine Satanis). '
                'Humain = sans allégeance surnaturelle. Autre = sous-types spéciaux (incube, mort-vivant, familier…).',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...['ANGE', 'DEMON', 'HUMAIN', 'AUTRE'].map((type) {
                    return _buildSelectableButton(
                      label: type,
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
                    label: 'INDIFFÉRENT',
                    isSelected: false,
                    onTap: () {
                      final allTypes = ['ANGE', 'DEMON', 'HUMAIN'] + _otherSubTypes;
                      final randomType = allTypes[_random.nextInt(allTypes.length)];
                      if (_otherSubTypes.contains(randomType)) {
                        setState(() {
                          _selectedType = 'AUTRE';
                          _selectedSubType = randomType;
                        });
                      } else {
                        setState(() {
                          _selectedType = randomType;
                          _selectedSubType = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_selectedType != null)
                Consumer<GameProvider>(
                  builder: (context, gameProvider, _) {
                    final game = gameProvider.currentGame;
                    if (game == null) return const SizedBox();
                    final typeKey = _selectedType == 'ANGE' ? 'Ange' : _selectedType == 'DEMON' ? 'Démon' : 'Humain';
                    final desc = game.characterTypeDescriptions[typeKey];
                    if (desc == null) return const SizedBox();
                    return _buildSectionDescription(desc);
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
          title: const Text('PNJ amoindri'),
          subtitle: const Text('Désactiver = PNJ avec caractéristiques de joueur'),
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
              const Text(
                'SOUS-TYPE (AUTRE)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._otherSubTypes.map((subType) {
                    return _buildSelectableButton(
                      label: subType.toUpperCase(),
                      isSelected: _selectedSubType == subType,
                      onTap: () => setState(() => _selectedSubType = subType),
                    );
                  }),
                  _buildSelectableButton(
                    label: 'RANDOM',
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
              const Text(
                'GRADE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              _buildSectionDescription(
                'Niveau hiérarchique : 0 (base) à 3, ou Avatar (très puissant) / Archange pour les anges. '
                'Plus le grade est élevé, plus le personnage a d\'influence et de pouvoirs.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...['0', '1', '2', '3', 'AVATAR', 'ARCHANGE'].map((grade) {
                    return _buildSelectableButton(
                      label: grade,
                      isSelected: _selectedGrade == grade,
                      onTap: () => setState(() => _selectedGrade = grade),
                    );
                  }),
                  _buildSelectableButton(
                    label: 'RANDOM',
                    isSelected: false,
                    onTap: () {
                      final grades = ['0', '1', '2', '3', 'AVATAR', 'ARCHANGE'];
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
                  const Text(
                    'SÉLECTIONNER UN SUPÉRIEUR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.medievalDarkBrown,
                    ),
                  ),
                  const Spacer(),
                  _buildSelectableButton(
                    label: 'RANDOM',
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
                'Votre Archange (anges) ou Prince démoniaque (démons). Détermine vos pouvoirs et votre rôle en jeu. '
                'Chaque supérieur a des domaines et des capacités spécifiques.',
              ),
              const SizedBox(height: 12),
              ...superiors.take(10).map((superior) {
                return RadioListTile<String>(
                  title: Text(superior),
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
                  child: Text('Voir tous (${superiors.length})'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final gameProvider = Provider.of<GameProvider>(context);
    final game = gameProvider.currentGame;
    final edition = game?.getEdition(gameProvider.currentEditionId ?? (game?.editions.isEmpty ?? true ? '' : game!.editions.first.id));
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
                    const Text(
                      'Aperçu de la fiche',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.medievalDarkBrown,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tout modifier',
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
                    _previewChip('Type', _selectedType ?? '—'),
                    _previewChip('Grade', _selectedGrade ?? '—'),
                    _previewChip('Supérieur', _selectedSuperior ?? '—'),
                    _previewChip('Caracs', caracs > 0 ? '$caracs/6' : '—'),
                    _previewChip('Pouvoirs', powersCount > 0 ? '$powersCount' : '—'),
                    _previewChip('Limitation', _hasLimitation && _limitationName != null ? _limitationName! : 'Non'),
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
    final edition = game?.getEdition(gameProvider.currentEditionId ?? (game?.editions.isEmpty ?? true ? '' : game!.editions.first.id));
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
                  const Text('Mode aperçu – Fiche PNJ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  _previewRow('Type', _selectedType ?? 'Non choisi'),
                  _previewRow('Grade', _selectedGrade ?? 'Non choisi'),
                  _previewRow('Supérieur', _selectedSuperior ?? 'Non choisi'),
                  _previewRow('PNJ amoindri', _npcDiminished ? 'Oui' : 'Non'),
                  const SizedBox(height: 8),
                  const Text('Caractéristiques', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...statNames.map((n) => _previewRow(n, '${_characteristics[n] ?? 0}')),
                  const SizedBox(height: 8),
                  const Text('Pouvoirs', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._powerSelections.entries.map((e) => _previewRow('Pouvoir ${e.key}', e.value ?? '—')),
                  _previewRow('Limitation', _hasLimitation && _limitationName != null ? _limitationName! : 'Non'),
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
                      const Text(
                        'SÉLECTIONNER UNE CARAC OU +',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.medievalDarkBrown,
                        ),
                      ),
                      const Spacer(),
                      _buildSelectableButton(
                        label: 'RANDOM',
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
                    'Les 6 caractéristiques du personnage (Force, Volonté, Agilité, etc.). Choisir une valeur de 1 à 6 par ligne. '
                    'Les noms dépendent de l\'édition choisie à l\'accueil (v1–v3 : Intelligence ; v4 : Rêve ; v5 : Empathie ; v6 : Intuition).',
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
                                  message: StatDescriptions.getOrDefault(statName),
                                  preferBelow: false,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.help,
                                    child: Text(
                                      statName,
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
              const Text(
                'SÉLECTIONNER POUVOIR',
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
            'POUVOIR $powerNumber ${isSuperior ? '(TABLE SUPÉRIEUR)' : isGeneral ? '(TABLE GÉNÉRALE)' : ''}',
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
                  label: 'TABLE GÉNÉRALE',
                  isSelected: !_power2UseSuperior,
                  onTap: () => setState(() => _power2UseSuperior = false),
                ),
                const SizedBox(width: 8),
                _buildSelectableButton(
                  label: 'TABLE SUPÉRIEUR',
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
                label: 'RANDOM',
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
                  label: 'SEMI ALÉATOIRE',
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
                label: 'CHOISIR',
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
              const Text(
                'LIMITATION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.medievalDarkBrown,
                ),
              ),
              _buildSectionDescription(
                'Handicap optionnel (ex. Accès de colère) qui peut donner des avantages en jeu ou compliquer la partie. '
                'Non = aucun ; Oui = choisir dans la liste.',
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
                  const Text('NON'),
                  const SizedBox(width: 24),
                  Radio<bool>(
                    value: true,
                    groupValue: _hasLimitation,
                    onChanged: (value) => setState(() => _hasLimitation = true),
                    activeColor: AppTheme.medievalGold,
                  ),
                  const Text('OUI'),
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
        title: const Text('Tous les Supérieurs'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: superiors.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(superiors[index]),
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
        title: Text('Choisir Pouvoir $powerNumber'),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun système de jeu sélectionné')));
      return;
    }
    final editionId = gameProvider.currentEditionId ?? (game.editions.isEmpty ? '' : game.editions.first.id);
    final edition = game.getEdition(editionId);
    if (edition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Édition non trouvée')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.casino, color: AppTheme.medievalGold),
            SizedBox(width: 8),
            Text('PNJ Tout Aléatoire'),
          ],
        ),
        content: const Text(
          'Créer un PNJ entièrement aléatoire ? Type, grade, supérieur, caractéristiques (jets de dés automatiques), pouvoirs et nom seront tirés au sort. '
          'Vous pourrez tout modifier sur la fiche ensuite.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.casino, size: 20),
            label: const Text('Générer le PNJ'),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PNJ aléatoire créé — modifiez la fiche si besoin.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _generateNPC() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un type de personnage')),
      );
      return;
    }

    final gameProvider = Provider.of<GameProvider>(context);
    final characterProvider = Provider.of<CharacterProvider>(context);
    final game = gameProvider.currentGame;

    if (game == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun système de jeu sélectionné')),
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
      character.motivation = (character.motivation.isEmpty ? '' : '${character.motivation}\n') + 'Limitation: $_limitationName';
    }

    characterProvider.setCurrentCharacter(character);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CharacterDetailScreen()),
    );
  }
}
