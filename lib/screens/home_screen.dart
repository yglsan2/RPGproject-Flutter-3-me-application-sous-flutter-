import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/character_provider.dart';
import 'character_detail_screen.dart';
import '../models/game_system.dart';
import 'character_creation_screen.dart';
import 'npc_creation_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.medievalGold),
            const SizedBox(width: 8),
            const Text(
              'Grimoire des Héros',
              style: TextStyle(
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people, color: AppTheme.medievalGold),
            tooltip: 'Créer un PNJ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NPCCreationScreen()),
              );
            },
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
            return Column(
              children: [
                _buildGameSelector(context, gameProvider),
                Expanded(child: _buildContent(context, gameProvider)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.medievalGold.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CharacterCreationScreen()),
            );
          },
          icon: const Icon(Icons.add_circle_outline, size: 28),
          label: const Text(
            'Forger un Héros',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameSelector(BuildContext context, GameProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.medievalBronze.withValues(alpha: 0.3),
            AppTheme.medievalGold.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.medievalGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.medievalDarkBrown.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: AppTheme.medievalGold, size: 24),
              const SizedBox(width: 8),
              Text(
                'Système de Jeu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.medievalDarkBrown,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<GameSystem>(
            initialValue: provider.currentGame,
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
            items: provider.gameSystems.map((game) {
              return DropdownMenuItem(
                value: game,
                child: Row(
                  children: [
                    Icon(Icons.casino, color: AppTheme.medievalGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      game.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (game) {
              if (game != null) provider.setCurrentGame(game);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, GameProvider provider) {
    if (provider.currentGame == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: AppTheme.medievalGold.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Choisissez un système de jeu',
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
        _buildEditionSelector(context, provider),
        const SizedBox(height: 16),
        _buildInfoCard(context, provider),
        const SizedBox(height: 16),
        _buildSavedCharactersList(context),
      ],
    );
  }

  Widget _buildEditionSelector(BuildContext context, GameProvider provider) {
    final game = provider.currentGame!;
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
                  Icon(Icons.library_books, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Édition',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: provider.currentEditionId,
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
                items: [
                  ...game.editions.map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Row(
                          children: [
                            Icon(Icons.star, color: AppTheme.medievalGold, size: 18),
                            const SizedBox(width: 8),
                            Text('${e.name} (${e.year})'),
                          ],
                        ),
                      )),
                  DropdownMenuItem(
                    value: 'random',
                    child: Row(
                      children: [
                        const Icon(Icons.casino, color: AppTheme.medievalGold),
                        const SizedBox(width: 8),
                        const Text('🎲 Choix aléatoire'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == 'random') {
                    provider.setRandomEdition();
                  } else if (value != null) {
                    provider.setCurrentEdition(value);
                  }
                },
              ),
              if (provider.currentEditionId != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
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
                    game.getEdition(provider.currentEditionId!)?.description ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, GameProvider provider) {
    final game = provider.currentGame!;
    final edition = game.getEdition(provider.currentEditionId ?? '');
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
                  Icon(Icons.auto_awesome, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Caractéristiques de ${edition.name}',
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
                children: edition.statNames.map((stat) {
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
                          stat,
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
  Widget _buildSavedCharactersList(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, characterProvider, _) {
        if (characterProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final characters = characterProvider.savedCharacters;
        
        if (characters.isEmpty) {
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
                  children: [
                    Icon(Icons.book_outlined, size: 48, color: AppTheme.medievalGold.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun personnage sauvegardé',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.medievalBronze,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
                      Icon(Icons.book, color: AppTheme.medievalGold, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Personnages Sauvegardés (\${characters.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...characters.map((character) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.medievalCream,
                            AppTheme.medievalCream.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.medievalGold.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.medievalGold,
                          child: Text(
                            character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ),
                        title: Text(
                          character.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.medievalDarkBrown,
                          ),
                        ),
                        subtitle: Text(
                          '\${character.type} - \${character.superior}',
                          style: TextStyle(
                            color: AppTheme.medievalBronze,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (character.isNPC)
                              Chip(
                                label: const Text('PNJ', style: TextStyle(fontSize: 10)),
                                backgroundColor: AppTheme.medievalBronze.withValues(alpha: 0.3),
                              ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward, color: AppTheme.medievalGold),
                              onPressed: () {
                                characterProvider.setCurrentCharacter(character);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CharacterDetailScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
}
