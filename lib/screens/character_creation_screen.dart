import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/character_provider.dart';
import '../models/game_system.dart';
import '../services/character_generator_service.dart';
import '../services/name_generator_service.dart';
import '../widgets/archetype_selector.dart';
import 'character_detail_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/parchment_widget.dart';
import 'dart:developer' as developer;

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  String? _selectedCharacterType;
  String? _selectedArchetype;
  bool _isNPC = false;
  bool _useArchetype = true;
  String _nameOrigin = 'Fantasy';
  String _nameStyle = 'Classique';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.create, color: AppTheme.medievalGold),
            const SizedBox(width: 8),
            const Text('Forge du Héros'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.medievalGold.withValues(alpha: 0.2),
            ),
            child: IconButton(
              icon: const Icon(Icons.save, color: AppTheme.medievalGold),
              onPressed: _generateCharacter,
              tooltip: 'Forger le personnage',
            ),
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
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, _) {
            final game = gameProvider.currentGame;
            if (game == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 64, color: AppTheme.medievalGold.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Sélectionnez un système de jeu',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.medievalBronze,
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCharacterTypeSelector(game),
                const SizedBox(height: 16),
                _buildNPCSelector(),
                const SizedBox(height: 16),
                if (_selectedCharacterType != null) ...[
                  ArchetypeSelector(
                    characterType: _selectedCharacterType!,
                    selectedArchetype: _selectedArchetype,
                    onArchetypeChanged: (archetype) {
                      setState(() {
                        _selectedArchetype = archetype;
                        gameProvider.saveArchetype(_selectedCharacterType!, archetype ?? '');
                      });
                    },
                    onUseArchetypeChanged: (value) {
                      setState(() {
                        _useArchetype = value;
                      });
                    },
                    useArchetype: _useArchetype,
                  ),
                  const SizedBox(height: 16),
                  _buildNameGenerator(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCharacterTypeSelector(GameSystem game) {
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
                  Icon(Icons.person, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Type de personnage',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: game.characterTypes.map((type) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _selectedCharacterType == type
                            ? [AppTheme.medievalGold, AppTheme.medievalBronze]
                            : [AppTheme.medievalBronze.withValues(alpha: 0.2), AppTheme.medievalGold.withValues(alpha: 0.1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedCharacterType == type
                            ? AppTheme.medievalGold
                            : AppTheme.medievalBronze.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ChoiceChip(
                      label: Text(
                        type,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedCharacterType == type
                              ? AppTheme.medievalDarkBrown
                              : AppTheme.medievalDarkBrown,
                        ),
                      ),
                      selected: _selectedCharacterType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCharacterType = selected ? type : null;
                          _selectedArchetype = null;
                        });
                      },
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

  Widget _buildNPCSelector() {
    return ParchmentWidget(
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
        child: Column(
          children: [
            SwitchListTile(
              title: Row(
                children: [
                  Icon(Icons.people, color: AppTheme.medievalGold, size: 20),
                  const SizedBox(width: 8),
                  const Text('Personnage Non-Joueur (PNJ)'),
                ],
              ),
              subtitle: const Text('Génère un PNJ avec des capacités réduites'),
              value: _isNPC,
              onChanged: (value) {
                setState(() {
                  _isNPC = value;
                });
              },
              activeThumbColor: AppTheme.medievalGold,
            ),
            if (_isNPC)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.medievalBronze.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.medievalBronze.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.medievalGold, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Caractéristiques des PNJ :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.medievalDarkBrown,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildNPCInfoRow('Points de caractéristiques', 'Réduits'),
                    _buildNPCInfoRow('Talents', '2-3 (vs 3-5 pour joueurs)'),
                    _buildNPCInfoRow('Pouvoirs', '1-2 (vs 2-3 pour joueurs)'),
                    _buildNPCInfoRow('Compétences', 'Moins nombreuses et niveau réduit'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNPCInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.medievalDarkBrown,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.medievalGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameGenerator() {
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
                    'Générateur de nom',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _nameOrigin,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Origine',
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
                      items: NameGeneratorService.origins.map((origin) {
                        return DropdownMenuItem(
                          value: origin,
                          child: Row(
                            children: [
                              Icon(Icons.language, color: AppTheme.medievalGold, size: 18),
                              const SizedBox(width: 8),
                              Text(origin),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _nameOrigin = value ?? 'Fantasy';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _nameStyle,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Style',
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
                      items: NameGeneratorService.styles.map((style) {
                        return DropdownMenuItem(
                          value: style,
                          child: Row(
                            children: [
                              Icon(Icons.style, color: AppTheme.medievalGold, size: 18),
                              const SizedBox(width: 8),
                              Text(style),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _nameStyle = value ?? 'Classique';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateCharacter() {
    developer.log(('🎲 [CHAR_CREATION] Début de génération de personnage').toString());
    final gameProvider = context.read<GameProvider>();
    final characterProvider = context.read<CharacterProvider>();
    final game = gameProvider.currentGame;

    if (game == null || _selectedCharacterType == null) {
      developer.log(('❌ [CHAR_CREATION] Erreur: Type de personnage non sélectionné').toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un type de personnage')));
      return;
    }

    final editionId = gameProvider.currentEditionId ?? game.editions.first.id;
    final archetypeName = _useArchetype ? _selectedArchetype : null;

    developer.log(('📋 [CHAR_CREATION] Paramètres:').toString());
    developer.log(('  - Jeu: ${game.name}').toString());
    developer.log(('  - Édition: $editionId').toString());
    developer.log(('  - Type: $_selectedCharacterType').toString());
    developer.log(('  - Archétype: ${archetypeName ?? "Aucun"}').toString());
    developer.log(('  - PNJ: $_isNPC').toString());

    try {
      final character = CharacterGeneratorService.generateCharacter(
        gameSystem: game,
        editionId: editionId,
        characterType: _selectedCharacterType!,
        archetypeName: archetypeName,
        isNPC: _isNPC,
        useArchetype: _useArchetype,
      );

      character.name = NameGeneratorService.generate(origin: _nameOrigin, style: _nameStyle);
      developer.log(('✨ [CHAR_CREATION] Nom généré: ${character.name}').toString());

      characterProvider.setCurrentCharacter(character);
      developer.log(('✅ [CHAR_CREATION] Personnage créé avec succès').toString());

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CharacterDetailScreen()));
    } catch (e) {
      developer.log(('❌ [CHAR_CREATION] Erreur lors de la génération: $e').toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }
}
