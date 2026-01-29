import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class ArchetypeSelector extends StatelessWidget {
  final String characterType;
  final String? selectedArchetype;
  final ValueChanged<String?> onArchetypeChanged;
  final ValueChanged<bool> onUseArchetypeChanged;
  final bool useArchetype;

  const ArchetypeSelector({
    super.key,
    required this.characterType,
    required this.selectedArchetype,
    required this.onArchetypeChanged,
    required this.onUseArchetypeChanged,
    required this.useArchetype,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final game = gameProvider.currentGame;
        if (game == null) return const SizedBox();

        final edition = game.getEdition(gameProvider.currentEditionId ?? '');
        if (edition == null) return const SizedBox();

        final archetypes = edition.archetypes[characterType];
        if (archetypes == null || archetypes.isEmpty) return const SizedBox();

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
                        'Archétype',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Utiliser un archétype'),
                    value: useArchetype,
                    onChanged: onUseArchetypeChanged,
                    activeThumbColor: AppTheme.medievalGold,
                  ),
                  if (useArchetype) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedArchetype,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Archétype',
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
                        DropdownMenuItem(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.casino, color: AppTheme.medievalGold, size: 18),
                              const SizedBox(width: 8),
                              const Text('Aléatoire complet'),
                            ],
                          ),
                        ),
                        ...archetypes.keys.map((name) {
                          final archetype = archetypes[name]!;
                          return DropdownMenuItem(
                            value: name,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 60),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: AppTheme.medievalGold, size: 18),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 26, top: 4),
                                    child: Text(
                                      archetype.description,
                                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      onChanged: onArchetypeChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
