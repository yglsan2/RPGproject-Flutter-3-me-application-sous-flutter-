import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/character_provider.dart';
import '../providers/game_provider.dart';
import '../models/character.dart';
import '../widgets/stat_card.dart';
import '../widgets/parchment_widget.dart';
import '../widgets/dice_roller.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/character_generator_service.dart';

class CharacterDetailScreen extends StatefulWidget {
  const CharacterDetailScreen({super.key});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final character = context.read<CharacterProvider>().currentCharacter;
    if (character != null) {
      _nameController.text = character.name;
      _motivationController.text = character.motivation;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, characterProvider, _) {
        final character = characterProvider.currentCharacter;
        if (character == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Détails du Personnage'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: AppTheme.medievalGold.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun personnage sélectionné',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.medievalBronze,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  character.isNPC ? Icons.people : Icons.person,
                  color: AppTheme.medievalGold,
                ),
                const SizedBox(width: 8),
                const Text('Fiche du Héros'),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    _saveCharacter(characterProvider, character);
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                tooltip: _isEditing ? 'Sauvegarder' : 'Modifier',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(value, characterProvider, character),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(Icons.save, color: AppTheme.medievalGold),
                        SizedBox(width: 8),
                        Text('Sauvegarder'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: AppTheme.medievalGold),
                        SizedBox(width: 8),
                        Text('Exporter'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ],
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
                _buildHeaderCard(character),
                const SizedBox(height: 16),
                _buildBasicInfoCard(character),
                const SizedBox(height: 16),
                _buildStatsCard(character, characterProvider),
                const SizedBox(height: 16),
                _buildTalentsCard(character),
                const SizedBox(height: 16),
                _buildPowersCard(character),
                const SizedBox(height: 16),
                _buildCompetencesCard(character),
                const SizedBox(height: 16),
                _buildEquipmentCard(character),
                const SizedBox(height: 16),
                _buildDiceRollerCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(Character character) {
    return ParchmentWidget(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.medievalGold,
            child: Text(
              character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.medievalDarkBrown,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            TextField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.medievalDarkBrown,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.medievalGold, width: 2),
                ),
              ),
            )
          else
            Text(
              character.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.medievalDarkBrown,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(
                  character.isNPC ? Icons.people : Icons.person,
                  size: 18,
                  color: AppTheme.medievalGold,
                ),
                label: Text(character.isNPC ? 'PNJ' : 'Joueur'),
                backgroundColor: AppTheme.medievalGold.withValues(alpha: 0.2),
              ),
              Chip(
                avatar: const Icon(Icons.category, size: 18, color: AppTheme.medievalGold),
                label: Text(character.type),
                backgroundColor: AppTheme.medievalBronze.withValues(alpha: 0.2),
              ),
              Chip(
                avatar: const Icon(Icons.star, size: 18, color: AppTheme.medievalGold),
                label: Text(character.superior),
                backgroundColor: AppTheme.medievalBronze.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(Character character) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Informations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Points de Fatigue', '${character.fatiguePoints}'),
              _buildInfoRow('Points de Pouvoir', '${character.powerPoints}'),
              const SizedBox(height: 12),
              Text(
                'Motivation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.medievalDarkBrown,
                    ),
              ),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _motivationController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.medievalGold, width: 2),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.medievalGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.medievalGold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    character.motivation.isEmpty ? 'Aucune motivation définie' : character.motivation,
                    style: TextStyle(
                      fontStyle: character.motivation.isEmpty ? FontStyle.italic : FontStyle.normal,
                      color: AppTheme.medievalDarkBrown,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.medievalDarkBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.medievalGold.withValues(alpha: 0.3),
                  AppTheme.medievalBronze.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.medievalGold.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.medievalDarkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Character character, CharacterProvider characterProvider) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final game = gameProvider.currentGame;
        final edition = game?.getEdition(character.editionId);
        if (edition == null) return const SizedBox();

        return Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.medievalBronze.withValues(alpha: 0.2),
                  AppTheme.medievalGold.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.medievalGold, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Caractéristiques',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...character.characteristics.entries.map((entry) {
                    return StatCard(
                      statName: entry.key,
                      value: entry.value,
                      minValue: game?.minStatValue ?? 2,
                      maxValue: game?.maxStatValue ?? 5,
                      onChanged: (newValue) {
                        final updated = character.copyWith(
                          characteristics: {
                            ...character.characteristics,
                            entry.key: newValue,
                          },
                        );
                        characterProvider.updateCharacter(updated);
                      },
                      onRandomize: () {
                        if (game != null) {
                          final totalPoints = character.isNPC ? game.npcPoints : game.playerPoints;
                          final newValue = CharacterGeneratorService.randomizeSingleStat(
                            character.characteristics,
                            entry.key,
                            totalPoints,
                            game.minStatValue,
                            game.maxStatValue,
                          );
                          final updated = character.copyWith(
                            characteristics: {
                              ...character.characteristics,
                              entry.key: newValue,
                            },
                          );
                          characterProvider.updateCharacter(updated);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTalentsCard(Character character) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Talents',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (character.talents.isEmpty)
                Text(
                  'Aucun talent',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.medievalBronze,
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: character.talents.map((talent) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.medievalGold.withValues(alpha: 0.3),
                            AppTheme.medievalBronze.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.medievalGold.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: AppTheme.medievalGold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            talent,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowersCard(Character character) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.medievalBronze.withValues(alpha: 0.2),
              AppTheme.medievalGold.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Pouvoirs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (character.powers.isEmpty)
                Text(
                  'Aucun pouvoir',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.medievalBronze,
                  ),
                )
              else
                ...character.powers.map((power) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.medievalGold.withValues(alpha: 0.2),
                          AppTheme.medievalBronze.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.medievalGold.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt, color: AppTheme.medievalGold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                power.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.medievalDarkBrown,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.medievalGold.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${power.costPP} PP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppTheme.medievalDarkBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (power.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            power.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.medievalDarkBrown.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompetencesCard(Character character) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Compétences',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (character.competences.isEmpty)
                Text(
                  'Aucune compétence',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.medievalBronze,
                  ),
                )
              else
                ...character.competences.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.medievalGold.withValues(alpha: 0.3),
                                AppTheme.medievalBronze.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.medievalGold.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Niveau ${entry.value}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(Character character) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.medievalBronze.withValues(alpha: 0.2),
              AppTheme.medievalGold.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.backpack, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Équipement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (character.equipment.isEmpty)
                Text(
                  'Aucun équipement',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.medievalBronze,
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: character.equipment.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.medievalGold.withValues(alpha: 0.3),
                            AppTheme.medievalBronze.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.medievalGold.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2, color: AppTheme.medievalGold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            item,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiceRollerCard() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.medievalCream,
              AppTheme.medievalCream.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.casino, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Lanceur de dés',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const DiceRoller(),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCharacter(CharacterProvider characterProvider, Character character) {
    final updated = character.copyWith(
      name: _nameController.text,
      motivation: _motivationController.text,
    );
    characterProvider.updateCharacter(updated);
    characterProvider.saveCharacter(updated);
    StorageService.saveCharacter(updated);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personnage sauvegardé'),
        backgroundColor: AppTheme.medievalGold,
      ),
    );
  }

  void _handleMenuAction(String action, CharacterProvider characterProvider, Character character) {
    switch (action) {
      case 'save':
        _saveCharacter(characterProvider, character);
        break;
      case 'export':
        _exportCharacter(character);
        break;
      case 'delete':
        _deleteCharacter(characterProvider, character);
        break;
    }
  }

  Future<void> _exportCharacter(Character character) async {
    try {
      final filePath = await StorageService.exportCharacterToFile(character);
      await Share.shareXFiles([XFile(filePath)], text: 'Personnage ${character.name}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personnage exporté'),
          backgroundColor: AppTheme.medievalGold,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'export: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCharacter(CharacterProvider characterProvider, Character character) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le personnage'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${character.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              characterProvider.deleteCharacter(character.id);
              StorageService.deleteCharacter(character.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Personnage supprimé'),
                  backgroundColor: AppTheme.medievalGold,
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
