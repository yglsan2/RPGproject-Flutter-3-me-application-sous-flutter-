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
  List<String> _selectedPowers = [];
  String? _limitation;
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
                      // Randomiser parmi tous les types et sous-types
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
            ],
          ),
        ),
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

  Widget _buildCharacteristicsSelector() {
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
                        _characteristics.forEach((key, value) {
                          _characteristics[key] = _random.nextInt(6) + 1;
                        });
                      });
                    },
                  ),
                ],
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
                  ..._characteristics.entries.map((entry) {
                    return TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ...List.generate(6, (i) {
                          final value = i + 1;
                          return TableCell(
                            child: Radio<int>(
                              value: value,
                              groupValue: entry.value == 0 ? null : entry.value,
                              onChanged: (newValue) {
                                setState(() {
                                  _characteristics[entry.key] = newValue ?? 0;
                                });
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
    String? selectedPower;
    String selectedTable = isSuperior ? 'SUPÉRIEUR' : 'GÉNÉRALE';

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
                  isSelected: selectedTable == 'GÉNÉRALE',
                  onTap: () => setState(() => selectedTable = 'GÉNÉRALE'),
                ),
                const SizedBox(width: 8),
                _buildSelectableButton(
                  label: 'TABLE SUPÉRIEUR',
                  isSelected: selectedTable == 'SUPÉRIEUR',
                  onTap: () => setState(() => selectedTable = 'SUPÉRIEUR'),
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
                  if (isSuperior || selectedTable == 'SUPÉRIEUR') {
                    selectedPower = _superiorPowers[_random.nextInt(_superiorPowers.length)];
                  } else {
                    // Tirage avec dés pour table générale
                    final roll = _random.nextInt(6) + 1;
                    final hundreds = _random.nextInt(6) + 1;
                    final key = hundreds * 100 + roll * 10 + powerNumber;
                    selectedPower = _generalPowers[key];
                  }
                  setState(() {});
                },
              ),
              if (isGeneral) ...[
                const SizedBox(width: 8),
                _buildSelectableButton(
                  label: 'SEMI ALÉATOIRE',
                  isSelected: false,
                  onTap: () {
                    // Logique semi-aléatoire
                    final roll = _random.nextInt(6) + 1;
                    final hundreds = _random.nextInt(6) + 1;
                    final key = hundreds * 100 + roll * 10 + powerNumber;
                    selectedPower = _generalPowers[key];
                    setState(() {});
                  },
                ),
              ],
              const Spacer(),
              _buildSelectableButton(
                label: 'CHOISIR',
                isSelected: false,
                onTap: () {
                  _showPowerSelectionDialog(powerNumber, isSuperior || selectedTable == 'SUPÉRIEUR');
                },
              ),
            ],
          ),
          if (selectedPower != null) ...[
            const SizedBox(height: 8),
            Text(
              selectedPower!,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Radio<String>(
                    value: 'NON',
                    groupValue: _limitation,
                    onChanged: (value) => setState(() => _limitation = value),
                    activeColor: AppTheme.medievalGold,
                  ),
                  const Text('NON'),
                  const SizedBox(width: 24),
                  Radio<String>(
                    value: 'OUI',
                    groupValue: _limitation,
                    onChanged: (value) => setState(() => _limitation = value),
                    activeColor: AppTheme.medievalGold,
                  ),
                  const Text('OUI'),
                ],
              ),
              if (_limitation == 'OUI') ...[
                const SizedBox(height: 12),
                ..._limitations.map((limitation) {
                  return RadioListTile<String>(
                    title: Text(limitation),
                    value: limitation,
                    groupValue: _limitation,
                    onChanged: (value) => setState(() => _limitation = value),
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
                  setState(() {
                    if (_selectedPowers.length < powerNumber) {
                      _selectedPowers.addAll(List.filled(powerNumber - _selectedPowers.length, ''));
                    }
                    _selectedPowers[powerNumber - 1] = power;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
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

    // Convertir les caractéristiques
    final characteristics = <String, int>{};
    _characteristics.forEach((key, value) {
      if (value > 0) {
        // Mapper les abréviations aux noms complets
        final statName = {
          'FO': 'Force',
          'VO': 'Volonté',
          'AG': 'Agilité',
          'PE': 'Perception',
          'PR': 'Présence',
          'AP': 'Apparence',
        }[key] ?? key;
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
    if (_selectedPowers.isNotEmpty) {
      character.powers = _selectedPowers.map((name) => Power(name: name, costPP: 1)).toList();
    }

    characterProvider.setCurrentCharacter(character);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CharacterDetailScreen()),
    );
  }
}
