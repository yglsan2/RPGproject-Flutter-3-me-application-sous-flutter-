import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../providers/character_provider.dart';
import '../providers/game_provider.dart';
import '../models/character.dart' show Character, Power;
import '../widgets/stat_card.dart';
import '../widgets/parchment_widget.dart';
import '../widgets/dice_roller.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/character_generator_service.dart';
import '../data/game_data.dart';

class CharacterDetailScreen extends StatefulWidget {
  const CharacterDetailScreen({super.key});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  final TextEditingController _fatigueController = TextEditingController();
  final TextEditingController _powerPointsController = TextEditingController();
  String? _lastCharacterId;

  @override
  void initState() {
    super.initState();
    final character = context.read<CharacterProvider>().currentCharacter;
    if (character != null) {
      _lastCharacterId = character.id;
      _nameController.text = character.name;
      _motivationController.text = character.motivation;
      _fatigueController.text = character.fatiguePoints.toString();
      _powerPointsController.text = character.powerPoints.toString();
    }
  }

  void _syncControllersFromCharacter(Character character) {
    _lastCharacterId = character.id;
    _nameController.text = character.name;
    _motivationController.text = character.motivation;
    _fatigueController.text = character.fatiguePoints.toString();
    _powerPointsController.text = character.powerPoints.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _motivationController.dispose();
    _fatigueController.dispose();
    _powerPointsController.dispose();
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
              title: Text(AppLocalizations.trSafe(context, 'detail_screen_title')),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: AppTheme.medievalGold.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.trSafe(context, 'no_character_selected'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.medievalBronze,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(AppLocalizations.trSafe(context, 'back')),
                  ),
                ],
              ),
            ),
          );
        }

        if (_lastCharacterId != character.id) _syncControllersFromCharacter(character);

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
                Text(AppLocalizations.trSafe(context,'detail_sheet_title')),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveCharacter(characterProvider, character),
                tooltip: AppLocalizations.trSafe(context,'detail_save_tooltip'),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(value, characterProvider, character),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        const Icon(Icons.save, color: AppTheme.medievalGold),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.trSafe(context,'detail_save')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export_omf',
                    child: Row(
                      children: [
                        const Icon(Icons.folder_special, color: AppTheme.medievalGold),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.trSafe(context,'detail_export_omf')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export_pdf',
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppTheme.medievalGold),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.trSafe(context,'detail_export_pdf')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export_odt',
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: AppTheme.medievalGold),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.trSafe(context,'detail_export_odt')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        const Icon(Icons.download, color: AppTheme.medievalGold),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.trSafe(context,'detail_export_json')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.trSafe(context,'detail_delete')),
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
                _buildHeaderCard(character, characterProvider),
                const SizedBox(height: 16),
                _buildBasicInfoCard(character, characterProvider),
                const SizedBox(height: 16),
                _buildStatsCard(character, characterProvider),
                const SizedBox(height: 16),
                _buildTalentsCard(character, characterProvider),
                const SizedBox(height: 16),
                _buildPowersCard(character, characterProvider),
                const SizedBox(height: 16),
                _buildCompetencesCard(character, characterProvider),
                const SizedBox(height: 16),
                _buildEquipmentCard(character, characterProvider),
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

  Widget _buildHeaderCard(Character character, CharacterProvider characterProvider) {
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
          TextField(
            controller: _nameController,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.medievalDarkBrown,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: AppLocalizations.trSafe(context, 'name_hint'),
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
            onChanged: (value) => characterProvider.updateCharacter(character.copyWith(name: value)),
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
                label: Text(character.isNPC ? AppLocalizations.trSafe(context,'npc') : AppLocalizations.trSafe(context,'player')),
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

  Widget _buildBasicInfoCard(Character character, CharacterProvider characterProvider) {
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
                    AppLocalizations.trSafe(context,'informations'),
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
                  Expanded(child: Text(AppLocalizations.trSafe(context, 'fatigue_points'), style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.medievalDarkBrown))),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _fatigueController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) characterProvider.updateCharacter(character.copyWith(fatiguePoints: n));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(AppLocalizations.trSafe(context,'power_points'), style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.medievalDarkBrown))),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _powerPointsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) characterProvider.updateCharacter(character.copyWith(powerPoints: n));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Motivation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.medievalDarkBrown,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _motivationController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: AppLocalizations.trSafe(context,'motivation_hint'),
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
                onChanged: (value) => characterProvider.updateCharacter(character.copyWith(motivation: value)),
              ),
            ],
          ),
        ),
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

  Widget _buildTalentsCard(Character character, CharacterProvider characterProvider) {
    final candidates = GameData.getGameSystems().where((g) => g.id == character.gameId).toList();
    final gameSystem = candidates.isEmpty ? null : candidates.first;
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
                  Expanded(
                    child: Text(
                      AppLocalizations.trSafe(context,'talents'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.medievalDarkBrown,
                          ),
                    ),
                  ),
                  if (gameSystem != null) ...[
                    IconButton(
                      icon: const Icon(Icons.casino, size: 20),
                      onPressed: () {
                        final newList = CharacterGeneratorService.generateRandomTalents(gameSystem, isNPC: character.isNPC);
                        characterProvider.updateCharacter(character.copyWith(talents: newList));
                      },
                      tooltip: AppLocalizations.trSafe(context,'roll_all'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        final name = gameSystem.availableTalents.isNotEmpty
                            ? CharacterGeneratorService.pickRandomTalent(gameSystem)
                            : AppLocalizations.trSafe(context, 'new_talent');
                        characterProvider.updateCharacter(character.copyWith(
                          talents: [...character.talents, name],
                        ));
                      },
                      tooltip: 'Ajouter (tirage)',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (character.talents.isEmpty)
                Text(
                  AppLocalizations.trSafe(context, 'no_talents'),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.medievalBronze,
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: character.talents.asMap().entries.map((entry) {
                    final index = entry.key;
                    final talent = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.casino, size: 16),
                            onPressed: gameSystem != null
                                ? () {
                                    final newTalent = CharacterGeneratorService.pickRandomTalent(gameSystem);
                                    final newList = List<String>.from(character.talents)..[index] = newTalent;
                                    characterProvider.updateCharacter(character.copyWith(talents: newList));
                                  }
                                : null,
                            tooltip: AppLocalizations.trSafe(context,'roll_draw'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => _showEditTalentDialog(character, characterProvider, index, talent),
                            tooltip: AppLocalizations.trSafe(context, 'modify'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              final newList = List<String>.from(character.talents)..removeAt(index);
                              characterProvider.updateCharacter(character.copyWith(talents: newList));
                            },
                            tooltip: AppLocalizations.trSafe(context,'detail_delete'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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

  Future<void> _showEditTalentDialog(Character character, CharacterProvider characterProvider, int index, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.trSafe(context,'edit_talent')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: AppLocalizations.trSafe(context,'talent_name')),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.trSafe(ctx, 'cancel'))),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) Navigator.pop(ctx, true);
            },
            child: Text(AppLocalizations.trSafe(context,'dialog_save')),
          ),
        ],
      ),
    );
    if (result == true && controller.text.trim().isNotEmpty) {
      final newList = List<String>.from(character.talents)..[index] = controller.text.trim();
      characterProvider.updateCharacter(character.copyWith(talents: newList));
    }
  }

  Widget _buildPowersCard(Character character, CharacterProvider characterProvider) {
    final candidates = GameData.getGameSystems().where((g) => g.id == character.gameId).toList();
    final gameSystem = candidates.isEmpty ? null : candidates.first;
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
                  Expanded(
                    child: Text(
                      AppLocalizations.trSafe(context,'powers'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.medievalDarkBrown,
                          ),
                    ),
                  ),
                  if (gameSystem != null) ...[
                    IconButton(
                      icon: const Icon(Icons.casino, size: 20),
                      onPressed: () {
                        final newList = CharacterGeneratorService.generateRandomPowers(gameSystem, character.type, isNPC: character.isNPC);
                        characterProvider.updateCharacter(character.copyWith(powers: newList));
                      },
                      tooltip: AppLocalizations.trSafe(context,'roll_all'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        final p = CharacterGeneratorService.pickRandomPower(gameSystem, character.type);
                        characterProvider.updateCharacter(character.copyWith(
                          powers: [...character.powers, p],
                        ));
                      },
                      tooltip: 'Ajouter (tirage)',
                    ),
                  ],
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
                ...character.powers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final power = entry.value;
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
                                power.nameKey != null
                                    ? AppLocalizations.trSafe(context, power.nameKey!)
                                    : power.name,
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
                            if (gameSystem != null) ...[
                              IconButton(
                                icon: const Icon(Icons.casino, size: 16),
                                onPressed: () {
                                  final p = CharacterGeneratorService.pickRandomPower(gameSystem, character.type);
                                  final newList = List<Power>.from(character.powers)..[index] = p;
                                  characterProvider.updateCharacter(character.copyWith(powers: newList));
                                },
                                tooltip: AppLocalizations.trSafe(context,'roll_draw'),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                onPressed: () => _showEditPowerDialog(character, characterProvider, index, power),
                                tooltip: AppLocalizations.trSafe(context, 'modify'),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  final newList = List<Power>.from(character.powers)..removeAt(index);
                                  characterProvider.updateCharacter(character.copyWith(powers: newList));
                                },
                                tooltip: AppLocalizations.trSafe(context,'detail_delete'),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              ),
                            ],
                          ],
                        ),
                        if (power.descriptionKey != null || power.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            power.descriptionKey != null
                                ? AppLocalizations.trSafe(context, power.descriptionKey!)
                                : power.description,
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

  Future<void> _showEditPowerDialog(Character character, CharacterProvider characterProvider, int index, Power power) async {
    final nameCtrl = TextEditingController(text: power.name);
    final costCtrl = TextEditingController(text: power.costPP.toString());
    final descCtrl = TextEditingController(text: power.description);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.trSafe(context,'edit_power')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.trSafe(context,'power_name')),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.trSafe(context, 'power_cost')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.trSafe(context,'power_description')),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.trSafe(ctx, 'cancel'))),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final cost = int.tryParse(costCtrl.text);
              if (name.isNotEmpty && cost != null && cost >= 0) Navigator.pop(ctx, true);
            },
            child: Text(AppLocalizations.trSafe(context,'dialog_save')),
          ),
        ],
      ),
    );
    if (result == true &&
        nameCtrl.text.trim().isNotEmpty &&
        int.tryParse(costCtrl.text) != null &&
        (int.tryParse(costCtrl.text) ?? 0) >= 0) {
      final p = Power(
        name: nameCtrl.text.trim(),
        costPP: int.tryParse(costCtrl.text) ?? power.costPP,
        description: descCtrl.text.trim(),
        nameKey: null,
        descriptionKey: null,
      );
      final newList = List<Power>.from(character.powers)..[index] = p;
      characterProvider.updateCharacter(character.copyWith(powers: newList));
    }
  }

  Widget _buildCompetencesCard(Character character, CharacterProvider characterProvider) {
    final candidates = GameData.getGameSystems().where((g) => g.id == character.gameId).toList();
    final gameSystem = candidates.isEmpty ? null : candidates.first;
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
                  Expanded(
                    child: Text(
                      AppLocalizations.trSafe(context,'competences'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.medievalDarkBrown,
                          ),
                    ),
                  ),
                  if (gameSystem != null)
                    IconButton(
                      icon: const Icon(Icons.casino, size: 20),
                      onPressed: () {
                        final newMap = CharacterGeneratorService.generateRandomCompetences(gameSystem, isNPC: character.isNPC);
                        characterProvider.updateCharacter(character.copyWith(competences: newMap));
                      },
                      tooltip: AppLocalizations.trSafe(context, 'roll_all'),
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
                  final compName = entry.key;
                  final level = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            compName,
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
                            '${AppLocalizations.trSafe(context,'level_label')} $level',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ),
                        if (gameSystem != null) ...[
                          IconButton(
                            icon: const Icon(Icons.casino, size: 16),
                            onPressed: () {
                              final newEntry = CharacterGeneratorService.pickRandomCompetence(gameSystem, isNPC: character.isNPC);
                              final newMap = Map<String, int>.from(character.competences)..remove(compName)..[newEntry.key] = newEntry.value;
                              characterProvider.updateCharacter(character.copyWith(competences: newMap));
                            },
                            tooltip: AppLocalizations.trSafe(context,'roll_draw'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => _showEditCompetenceDialog(character, characterProvider, compName, level),
                            tooltip: AppLocalizations.trSafe(context, 'modify'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              final newMap = Map<String, int>.from(character.competences)..remove(compName);
                              characterProvider.updateCharacter(character.copyWith(competences: newMap));
                            },
                            tooltip: AppLocalizations.trSafe(context,'detail_delete'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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

  Future<void> _showEditCompetenceDialog(Character character, CharacterProvider characterProvider, String oldName, int oldLevel) async {
    final nameCtrl = TextEditingController(text: oldName);
    final levelCtrl = TextEditingController(text: oldLevel.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.trSafe(context, 'edit_competence')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.trSafe(context, 'competence_name')),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: levelCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.trSafe(context, 'level_label')),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.trSafe(ctx, 'cancel'))),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final lvl = int.tryParse(levelCtrl.text);
              if (name.isNotEmpty && lvl != null && lvl >= 1) Navigator.pop(ctx, true);
            },
            child: Text(AppLocalizations.trSafe(context,'dialog_save')),
          ),
        ],
      ),
    );
    if (result == true &&
        nameCtrl.text.trim().isNotEmpty &&
        int.tryParse(levelCtrl.text) != null &&
        (int.tryParse(levelCtrl.text) ?? 0) >= 1) {
      final newMap = Map<String, int>.from(character.competences)..remove(oldName)..[nameCtrl.text.trim()] = int.parse(levelCtrl.text);
      characterProvider.updateCharacter(character.copyWith(competences: newMap));
    }
  }

  Widget _buildEquipmentCard(Character character, CharacterProvider characterProvider) {
    final candidates = GameData.getGameSystems().where((g) => g.id == character.gameId).toList();
    final gameSystem = candidates.isEmpty ? null : candidates.first;
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
                  Expanded(
                    child: Text(
                      AppLocalizations.trSafe(context,'equipment'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.medievalDarkBrown,
                          ),
                    ),
                  ),
                  if (gameSystem != null) ...[
                    IconButton(
                      icon: const Icon(Icons.casino, size: 20),
                      onPressed: () {
                        final newList = CharacterGeneratorService.generateRandomEquipmentList(character.type, character.gameId);
                        characterProvider.updateCharacter(character.copyWith(equipment: newList));
                      },
                      tooltip: AppLocalizations.trSafe(context,'roll_all'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        final item = CharacterGeneratorService.pickRandomEquipment(character.type, character.gameId);
                        characterProvider.updateCharacter(character.copyWith(
                          equipment: [...character.equipment, item],
                        ));
                      },
                      tooltip: 'Ajouter (tirage)',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (character.equipment.isEmpty)
                Text(
                  AppLocalizations.trSafe(context, 'no_equipment'),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.medievalBronze,
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: character.equipment.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          if (gameSystem != null) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.casino, size: 16),
                              onPressed: () {
                                final newItem = CharacterGeneratorService.pickRandomEquipment(character.type, character.gameId);
                                final newList = List<String>.from(character.equipment)..[index] = newItem;
                                characterProvider.updateCharacter(character.copyWith(equipment: newList));
                              },
                              tooltip: AppLocalizations.trSafe(context,'roll_draw'),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              onPressed: () => _showEditEquipmentDialog(character, characterProvider, index, item),
                              tooltip: AppLocalizations.trSafe(context, 'modify'),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                final newList = List<String>.from(character.equipment)..removeAt(index);
                                characterProvider.updateCharacter(character.copyWith(equipment: newList));
                              },
                              tooltip: AppLocalizations.trSafe(context,'detail_delete'),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                          ],
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

  Future<void> _showEditEquipmentDialog(Character character, CharacterProvider characterProvider, int index, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.trSafe(context,'edit_equipment')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: AppLocalizations.trSafe(context,'equipment_item')),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.trSafe(ctx, 'cancel'))),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) Navigator.pop(ctx, true);
            },
            child: Text(AppLocalizations.trSafe(context,'dialog_save')),
          ),
        ],
      ),
    );
    if (result == true && controller.text.trim().isNotEmpty) {
      final newList = List<String>.from(character.equipment)..[index] = controller.text.trim();
      characterProvider.updateCharacter(character.copyWith(equipment: newList));
    }
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
                    AppLocalizations.trSafe(context,'dice_roller_title'),
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
      fatiguePoints: int.tryParse(_fatigueController.text) ?? character.fatiguePoints,
      powerPoints: int.tryParse(_powerPointsController.text) ?? character.powerPoints,
    );
    characterProvider.updateCharacter(updated);
    characterProvider.saveCharacter(updated);
    StorageService.saveCharacter(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.trSafe(context, 'detail_saved_snackbar')),
        backgroundColor: AppTheme.medievalGold,
      ),
    );
  }

  void _handleMenuAction(String action, CharacterProvider characterProvider, Character character) {
    switch (action) {
      case 'save':
        _saveCharacter(characterProvider, character);
        break;
      case 'export_omf':
        _exportCharacterOmf(character);
        break;
      case 'export_pdf':
        _exportCharacterPdf(character);
        break;
      case 'export_odt':
        _exportCharacterOdt(character);
        break;
      case 'export':
        _exportCharacter(character);
        break;
      case 'delete':
        _deleteCharacter(characterProvider, character);
        break;
    }
  }

  Future<void> _exportCharacterOmf(Character character) async {
    try {
      final filePath = await StorageService.exportCharacterToOmf(character);
      await SharePlus.instance.share(ShareParams(
        text: AppLocalizations.trSafe(context, 'detail_share_text_omf', {'name': character.name}),
        subject: AppLocalizations.trSafe(context, 'detail_share_subject_omf', {'name': character.name}),
        files: [XFile(filePath)],
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.trSafe(context, 'detail_omf_ready')),
          backgroundColor: AppTheme.medievalGold,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.trSafe(context, 'omf_export_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportCharacterPdf(Character character) async {
    try {
      final filePath = await StorageService.exportCharacterToPdf(character, Localizations.localeOf(context));
      await SharePlus.instance.share(ShareParams(
        text: AppLocalizations.trSafe(context, 'sheet_title_pdf', {'name': character.name}),
        subject: AppLocalizations.trSafe(context, 'detail_share_subject', {'name': character.name}),
        files: [XFile(filePath)],
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.trSafe(context,'detail_pdf_ready')),
          backgroundColor: AppTheme.medievalGold,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.trSafe(context, 'pdf_export_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportCharacterOdt(Character character) async {
    try {
      final filePath = await StorageService.exportCharacterToOdt(character, Localizations.localeOf(context));
      await SharePlus.instance.share(ShareParams(
        text: AppLocalizations.trSafe(context, 'detail_share_text_odt', {'name': character.name}),
        subject: AppLocalizations.trSafe(context, 'detail_share_subject_odt', {'name': character.name}),
        files: [XFile(filePath)],
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.trSafe(context,'detail_odt_ready')),
          backgroundColor: AppTheme.medievalGold,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.trSafe(context, 'odt_export_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportCharacter(Character character) async {
    try {
      final filePath = await StorageService.exportCharacterToFile(character);
      await SharePlus.instance.share(ShareParams(
        text: AppLocalizations.trSafe(context, 'detail_share_text_json', {'name': character.name}),
        subject: AppLocalizations.trSafe(context, 'detail_share_subject_json', {'name': character.name}),
        files: [XFile(filePath)],
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.trSafe(context,'detail_json_ready')),
          backgroundColor: AppTheme.medievalGold,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.trSafe(context,'export_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCharacter(CharacterProvider characterProvider, Character character) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.trSafe(context,'detail_delete_confirm')),
        content: Text(AppLocalizations.trSafe(context,'detail_delete_confirm_msg', {'name': character.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.trSafe(context,'cancel')),
          ),
          TextButton(
            onPressed: () {
              characterProvider.deleteCharacter(character.id);
              StorageService.deleteCharacter(character.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.trSafe(context,'character_deleted_snackbar')),
                  backgroundColor: AppTheme.medievalGold,
                ),
              );
            },
            child: Text(AppLocalizations.trSafe(context,'detail_delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
