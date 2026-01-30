import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/game_provider.dart';
import '../providers/character_provider.dart';
import '../services/storage_service.dart';
import 'character_detail_screen.dart';
import '../models/character.dart';
import '../models/game_system.dart';
import 'character_creation_screen.dart';
import 'npc_creation_screen.dart';
import '../theme/app_theme.dart';
import '../utils/stat_descriptions.dart';
import '../widgets/language_selector.dart';

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
            Text(
              AppLocalizations.trSafe(context, 'home_title'),
              style: const TextStyle(
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          LanguageSelectorButton(),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.medievalGold),
            tooltip: AppLocalizations.trSafe(context, 'home_about'),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: AppLocalizations.trSafe(context, 'about_app_name'),
                applicationVersion: AppLocalizations.trSafe(context, 'about_version'),
                applicationLegalese: AppLocalizations.trSafe(context, 'about_legal'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: AppTheme.medievalGold),
            tooltip: AppLocalizations.trSafe(context, 'home_import_character'),
            onPressed: () => _importCharacter(context),
          ),
          IconButton(
            icon: const Icon(Icons.people, color: AppTheme.medievalGold),
            tooltip: AppLocalizations.trSafe(context, 'home_create_npc'),
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
          label: Text(
            AppLocalizations.trSafe(context, 'home_forge_hero'),
            style: const TextStyle(
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
                AppLocalizations.trSafe(context, 'game_system'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.medievalDarkBrown,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<GameSystem>(
            value: provider.gameSystems.isEmpty
                ? null
                : (provider.gameSystems.contains(provider.currentGame) ? provider.currentGame : provider.gameSystems.first),
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
          if (provider.currentGame != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.medievalGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.medievalGold.withValues(alpha: 0.25)),
              ),
              child: Text(
                provider.currentGame!.id == 'ins-mv'
                    ? AppLocalizations.trSafe(context, 'game_insmv_description')
                    : provider.currentGame!.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.medievalDarkBrown,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
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
              AppLocalizations.trSafe(context, 'choose_game_system'),
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
    final editionIds = game.editions.map((e) => e.id).toList();
    final validEditionId = provider.currentEditionId != null &&
            (provider.currentEditionId == 'random' || editionIds.contains(provider.currentEditionId))
        ? provider.currentEditionId
        : (game.editions.isNotEmpty ? game.editions.first.id : null);
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
                    AppLocalizations.trSafe(context, 'edition'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: validEditionId,
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
                        Text(AppLocalizations.trSafe(context,'random_choice')),
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
              if (provider.currentEditionId != null) ...[
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
                  child: Builder(
                    builder: (context) {
                      final edition = game.getEdition(provider.currentEditionId!);
                      if (edition == null) return const SizedBox();
                      final descText = edition.descriptionKey != null
                          ? AppLocalizations.trSafe(context, edition.descriptionKey!)
                          : edition.description;
                      final changesText = edition.changesFromPreviousKey != null
                          ? AppLocalizations.trSafe(context, edition.changesFromPreviousKey!)
                          : edition.changesFromPrevious;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            descText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.medievalDarkBrown,
                                ),
                          ),
                          if (changesText != null && changesText.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Text(
                              changesText,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.medievalBronze,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
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
                        AppLocalizations.trSafe(context, 'characteristics_edition', {'name': edition.name}),
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
                  return Tooltip(
                    message: StatDescriptions.getTranslatedDescription(context, stat),
                    preferBelow: false,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.help,
                      child: Container(
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
                              StatDescriptions.getTranslatedName(context, stat),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.medievalDarkBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      AppLocalizations.trSafe(context,'no_saved_characters'),
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
                        AppLocalizations.trSafe(context, 'saved_characters_count', {'count': '${characters.length}'}),
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
                          '${character.type} - ${character.superior}',
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
                                label: Text(AppLocalizations.trSafe(context,'npc'), style: const TextStyle(fontSize: 10)),
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

  static Future<void> _importCharacter(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['omf', 'json'],
      allowMultiple: false,
    );
    final path = result?.files.singleOrNull?.path;
    if (path == null) return;

    Character? character;
    try {
      character = await StorageService.importCharacterFromFile(path);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.trSafe(context, 'import_error_file'))),
      );
      return;
    }

    if (!context.mounted) return;
    if (character == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.trSafe(context, 'import_error_invalid'))),
      );
      return;
    }

    final characterProvider = context.read<CharacterProvider>();
    await characterProvider.saveCharacter(character);
    characterProvider.setCurrentCharacter(character);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.trSafe(context, 'import_success', {'name': character.name}))),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CharacterDetailScreen()),
    );
  }
}
