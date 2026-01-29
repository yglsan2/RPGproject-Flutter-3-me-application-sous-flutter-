import 'dart:math';
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
  String? _selectedSuperior;
  String? _selectedArchetype;
  bool _isNPC = false;
  bool _npcDiminished = true;
  bool _useArchetype = true;
  String _nameOrigin = 'Fantasy';
  String _nameStyle = 'Classique';
  int _currentStep = 0;
  static const int _maxStep = 4;
  final Random _random = Random();

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
          TextButton.icon(
            onPressed: _generateFullRandomCharacter,
            icon: const Icon(Icons.casino, color: AppTheme.medievalGold, size: 22),
            label: const Text('Tout Aléatoire'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.medievalGold),
          ),
          const SizedBox(width: 8),
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

            return Column(
              children: [
                _buildBreadcrumb(game, gameProvider),
                Expanded(
                  child: SingleChildScrollView(
                    child: Stepper(
                      currentStep: _currentStep,
                      onStepTapped: (index) {
                        if (index < _currentStep) {
                          setState(() => _currentStep = index);
                        }
                      },
                      onStepContinue: () {
                        if (!_validateCurrentStep(game, gameProvider)) return;
                        if (_currentStep < _maxStep) {
                          setState(() {
                            final nextStep = _currentStep + 1;
                            if (nextStep == 2 && _selectedSuperior != null && _selectedCharacterType != null) {
                              final editionId = gameProvider.currentEditionId ?? (game.editions.isEmpty ? '' : game.editions.first.id);
                              final edition = game.getEdition(editionId);
                              final archMap = edition?.archetypes[_selectedCharacterType];
                              if (archMap != null && archMap.containsKey(_selectedSuperior)) {
                                _selectedArchetype = _selectedSuperior;
                                gameProvider.saveArchetype(_selectedCharacterType!, _selectedSuperior!);
                              }
                            }
                            _currentStep = nextStep;
                          });
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) setState(() => _currentStep--);
                      },
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            children: [
                              if (_currentStep > 0) ...[
                                OutlinedButton.icon(
                                  onPressed: details.onStepCancel,
                                  icon: const Icon(Icons.arrow_back, size: 18),
                                  label: const Text('Précédent'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.medievalDarkBrown,
                                    side: BorderSide(color: AppTheme.medievalGold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              ElevatedButton.icon(
                                onPressed: details.onStepContinue,
                                icon: Icon(_currentStep == _maxStep ? Icons.check_circle : Icons.arrow_forward, size: 18),
                                label: Text(_currentStep == _maxStep ? 'Récapitulatif' : 'Suivant'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.medievalGold,
                                  foregroundColor: AppTheme.medievalDarkBrown,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      steps: [
                        Step(
                          title: const Text('Type & options'),
                          subtitle: _selectedCharacterType != null ? Text(_selectedCharacterType!) : null,
                          isActive: _currentStep >= 0,
                          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildCharacterTypeSelector(game),
                              const SizedBox(height: 16),
                              _buildNPCSelector(),
                            ],
                          ),
                        ),
                        Step(
                          title: const Text('Supérieur'),
                          subtitle: _selectedSuperior != null ? Text(_selectedSuperior!, overflow: TextOverflow.ellipsis) : null,
                          isActive: _currentStep >= 1,
                          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 400),
                            child: SingleChildScrollView(child: _buildSuperiorSelector(game)),
                          ),
                        ),
                        Step(
                          title: const Text('Archétype'),
                          subtitle: _selectedArchetype != null ? Text(_selectedArchetype!, overflow: TextOverflow.ellipsis) : null,
                          isActive: _currentStep >= 2,
                          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 400),
                            child: SingleChildScrollView(
                              child: _selectedCharacterType == null
                                  ? const Padding(padding: EdgeInsets.all(16), child: Text('Choisissez d\'abord un type.'))
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ArchetypeSelector(
                                          characterType: _selectedCharacterType!,
                                          selectedArchetype: _selectedArchetype,
                                          onArchetypeChanged: (archetype) {
                                            setState(() {
                                              _selectedArchetype = archetype;
                                              gameProvider.saveArchetype(_selectedCharacterType!, archetype ?? '');
                                            });
                                          },
                                          onUseArchetypeChanged: (value) => setState(() => _useArchetype = value),
                                          useArchetype: _useArchetype,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Step(
                        title: const Text('Nom'),
                        subtitle: Text(_nameOrigin != 'Fantasy' || _nameStyle != 'Classique' ? '$_nameOrigin · $_nameStyle' : ''),
                        isActive: _currentStep >= 3,
                        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                        content: _buildNameGenerator(),
                      ),
                      Step(
                        title: const Text('Récapitulatif'),
                        isActive: _currentStep >= 4,
                        state: StepState.indexed,
                        content: _buildSummaryStep(game, gameProvider),
                      ),
                    ],
                  ),
                ),
              ),
                _buildBottomNavBar(game, gameProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Barre de navigation fixe en bas : Précédent / Suivant toujours visibles (évite le blocage à l'étape Archétype).
  Widget _buildBottomNavBar(GameSystem game, GameProvider gameProvider) {
    return Material(
      elevation: 8,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _currentStep--),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Précédent'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.medievalDarkBrown,
                    side: BorderSide(color: AppTheme.medievalGold),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(child: const SizedBox()),
              ElevatedButton.icon(
                onPressed: () {
                  if (!_validateCurrentStep(game, gameProvider)) return;
                  if (_currentStep < _maxStep) {
                    setState(() {
                      final nextStep = _currentStep + 1;
                      if (nextStep == 2 && _selectedSuperior != null && _selectedCharacterType != null) {
                        final editionId = gameProvider.currentEditionId ?? (game.editions.isEmpty ? '' : game.editions.first.id);
                        final edition = game.getEdition(editionId);
                        final archMap = edition?.archetypes[_selectedCharacterType];
                        if (archMap != null && archMap.containsKey(_selectedSuperior)) {
                          _selectedArchetype = _selectedSuperior;
                          gameProvider.saveArchetype(_selectedCharacterType!, _selectedSuperior!);
                        }
                      }
                      _currentStep = nextStep;
                    });
                  }
                },
                icon: Icon(_currentStep == _maxStep ? Icons.check_circle : Icons.arrow_forward, size: 18),
                label: Text(_currentStep == _maxStep ? 'Récapitulatif' : 'Suivant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.medievalGold,
                  foregroundColor: AppTheme.medievalDarkBrown,
                ),
              ),
            ],
          ),
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
                          _selectedSuperior = null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              if (_selectedCharacterType != null && game.characterTypeDescriptions[_selectedCharacterType] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.medievalGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.medievalGold.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.medievalGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          game.characterTypeDescriptions[_selectedCharacterType]!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.medievalDarkBrown,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              subtitle: Text(_isNPC && _npcDiminished ? 'Capacités réduites' : _isNPC ? 'Même niveau que joueur' : 'Personnage joueur'),
              value: _isNPC,
              onChanged: (value) {
                setState(() {
                  _isNPC = value;
                });
              },
              activeThumbColor: AppTheme.medievalGold,
            ),
            if (_isNPC) ...[
              SwitchListTile(
                title: const Text('PNJ amoindri'),
                subtitle: const Text('Désactiver = PNJ avec caractéristiques de joueur'),
                value: _npcDiminished,
                onChanged: (value) => setState(() => _npcDiminished = value),
                activeThumbColor: AppTheme.medievalGold,
              ),
            ],
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

  Widget _buildBreadcrumb(GameSystem game, GameProvider gameProvider) {
    final editionName = game.getEdition(gameProvider.currentEditionId ?? '')?.name ?? '';
    final chips = <Widget>[
      Chip(
        avatar: const Icon(Icons.menu_book, size: 18, color: AppTheme.medievalGold),
        label: Text(game.name, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppTheme.medievalBronze.withValues(alpha: 0.2),
      ),
      if (editionName.isNotEmpty)
        Chip(
          label: Text(editionName, style: const TextStyle(fontSize: 12)),
          backgroundColor: AppTheme.medievalGold.withValues(alpha: 0.15),
        ),
      if (_selectedCharacterType != null)
        Chip(
          label: Text(_selectedCharacterType!, style: const TextStyle(fontSize: 12)),
          backgroundColor: AppTheme.medievalGold.withValues(alpha: 0.2),
        ),
      if (_selectedSuperior != null)
        Chip(
          label: Text(_selectedSuperior!, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
          backgroundColor: AppTheme.medievalBronze.withValues(alpha: 0.2),
        ),
      if (_isNPC)
        Chip(
          label: Text(_npcDiminished ? 'PNJ amoindri' : 'PNJ pleine puissance', style: const TextStyle(fontSize: 11)),
          backgroundColor: AppTheme.medievalBronze.withValues(alpha: 0.2),
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: chips.map((c) => Padding(padding: const EdgeInsets.only(right: 6), child: c)).toList(),
      ),
    );
  }

  Widget _buildSuperiorSelector(GameSystem game) {
    final superiors = game.superiors[_selectedCharacterType];
    if (superiors == null || superiors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Aucun supérieur pour ce type.',
          style: TextStyle(color: AppTheme.medievalBronze, fontStyle: FontStyle.italic),
        ),
      );
    }
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
                  Icon(Icons.star, color: AppTheme.medievalGold, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Supérieur (Blandine, Baal, etc.)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.medievalDarkBrown,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _selectedSuperior = superiors[_random.nextInt(superiors.length)]);
                    },
                    icon: const Icon(Icons.casino, size: 18),
                    label: const Text('Aléatoire'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.medievalGold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...superiors.take(12).map((s) {
                return RadioListTile<String>(
                  title: Text(s),
                  value: s,
                  groupValue: _selectedSuperior,
                  onChanged: (value) => setState(() => _selectedSuperior = value),
                  activeColor: AppTheme.medievalGold,
                );
              }),
              if (superiors.length > 12)
                TextButton(
                  onPressed: () => _showAllSuperiors(superiors),
                  child: Text('Voir tous (${superiors.length})'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllSuperiors(List<String> superiors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choisir un supérieur'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: superiors.length,
            itemBuilder: (ctx, i) {
              return RadioListTile<String>(
                title: Text(superiors[i]),
                value: superiors[i],
                groupValue: _selectedSuperior,
                onChanged: (v) {
                  setState(() => _selectedSuperior = v);
                  Navigator.pop(ctx);
                },
                activeColor: AppTheme.medievalGold,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStep(GameSystem game, GameProvider gameProvider) {
    final editionName = game.getEdition(gameProvider.currentEditionId ?? '')?.name ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.medievalDarkBrown,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Jeu', game.name),
            _buildInfoRow('Édition', editionName),
            _buildInfoRow('Type', _selectedCharacterType ?? '—'),
            _buildInfoRow('Supérieur', _selectedSuperior ?? 'Aléatoire'),
            _buildInfoRow('Archétype', _useArchetype ? (_selectedArchetype ?? 'Aléatoire') : 'Non'),
            _buildInfoRow('PNJ', _isNPC ? (_npcDiminished ? 'Oui (amoindri)' : 'Oui (pleine puissance)') : 'Non'),
            _buildInfoRow('Nom', '$_nameOrigin · $_nameStyle'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateCharacter,
                icon: const Icon(Icons.check_circle),
                label: const Text('Créer le personnage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.medievalGold,
                  foregroundColor: AppTheme.medievalDarkBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
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
          Text(label, style: const TextStyle(color: AppTheme.medievalDarkBrown, fontWeight: FontWeight.w500)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, textAlign: TextAlign.end)),
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

  /// Crée un personnage entièrement aléatoire (type, supérieur, archétype, nom, stats, talents, pouvoirs…) puis ouvre la fiche.
  Future<void> _generateFullRandomCharacter() async {
    final gameProvider = context.read<GameProvider>();
    final characterProvider = context.read<CharacterProvider>();
    final game = gameProvider.currentGame;
    if (game == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélectionnez un système de jeu')));
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
            Text('Tout Aléatoire'),
          ],
        ),
        content: const Text(
          'Créer un personnage entièrement aléatoire (type, supérieur, archétype, nom, caractéristiques, talents, pouvoirs…) ? '
          'Vous pourrez tout modifier sur la fiche ensuite.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.casino, size: 20),
            label: const Text('Générer'),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.medievalGold, foregroundColor: AppTheme.medievalDarkBrown),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final types = game.characterTypes;
    final characterType = types[_random.nextInt(types.length)];
    List<String>? superiorList = game.superiors[characterType];
    String? superiorOverride;
    if (superiorList != null && superiorList.isNotEmpty) {
      superiorOverride = superiorList[_random.nextInt(superiorList.length)];
    }
    final archMap = edition.archetypes[characterType];
    String? archetypeName;
    bool useArchetype = true;
    if (archMap != null && archMap.isNotEmpty) {
      final names = archMap.keys.toList();
      archetypeName = names[_random.nextInt(names.length)];
    } else {
      useArchetype = false;
    }
    const origins = ['Fantasy', 'Médiéval', 'Moderne', 'Antique'];
    const styles = ['Classique', 'Épique', 'Court'];
    final nameOrigin = origins[_random.nextInt(origins.length)];
    final nameStyle = styles[_random.nextInt(styles.length)];
    try {
      final character = CharacterGeneratorService.generateCharacter(
        gameSystem: game,
        editionId: editionId,
        characterType: characterType,
        archetypeName: archetypeName,
        isNPC: _isNPC,
        useArchetype: useArchetype,
        npcDiminished: _npcDiminished,
        superiorOverride: superiorOverride,
      );
      character.name = NameGeneratorService.generate(origin: nameOrigin, style: nameStyle);
      characterProvider.setCurrentCharacter(character);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CharacterDetailScreen()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personnage aléatoire créé — modifiez la fiche si besoin.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  bool _validateCurrentStep(GameSystem game, GameProvider gameProvider) {
    switch (_currentStep) {
      case 0:
        if (_selectedCharacterType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choisissez un type de personnage avant de continuer.')),
          );
          return false;
        }
        return true;
      case 1: {
        final superiors = game.superiors[_selectedCharacterType];
        if (superiors != null && superiors.isNotEmpty && (_selectedSuperior == null || _selectedSuperior!.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choisissez un supérieur (archange ou prince) avant de continuer.')),
          );
          return false;
        }
        return true;
      }
      default:
        return true;
    }
  }

  Future<void> _generateCharacter() async {
    developer.log(('🎲 [CHAR_CREATION] Début de génération de personnage').toString());
    final gameProvider = context.read<GameProvider>();
    final characterProvider = context.read<CharacterProvider>();
    final game = gameProvider.currentGame;

    if (game == null || _selectedCharacterType == null) {
      developer.log(('❌ [CHAR_CREATION] Erreur: Type de personnage non sélectionné').toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un type de personnage')));
      return;
    }

    final editionName = game.getEdition(gameProvider.currentEditionId ?? '')?.name ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppTheme.medievalGold),
            SizedBox(width: 8),
            Text('Créer ce personnage ?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vous êtes sur le point de forger le personnage avec les choix suivants :',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Jeu', game.name),
              _buildInfoRow('Édition', editionName),
              _buildInfoRow('Type', _selectedCharacterType ?? '—'),
              _buildInfoRow('Supérieur', _selectedSuperior ?? '—'),
              _buildInfoRow('Archétype', _useArchetype ? (_selectedArchetype ?? 'Aléatoire') : 'Non'),
              _buildInfoRow('PNJ', _isNPC ? (_npcDiminished ? 'Oui (amoindri)' : 'Oui (pleine puissance)') : 'Non'),
              _buildInfoRow('Nom', '$_nameOrigin · $_nameStyle'),
              const SizedBox(height: 8),
              Text(
                'Vous pourrez modifier tous les détails sur la fiche après création.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text('Créer le personnage'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.medievalGold,
              foregroundColor: AppTheme.medievalDarkBrown,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

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
        npcDiminished: _npcDiminished,
        superiorOverride: _selectedSuperior,
      );

      character.name = NameGeneratorService.generate(origin: _nameOrigin, style: _nameStyle);
      developer.log(('✨ [CHAR_CREATION] Nom généré: ${character.name}').toString());

      characterProvider.setCurrentCharacter(character);
      developer.log(('✅ [CHAR_CREATION] Personnage créé avec succès').toString());

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CharacterDetailScreen()));
    } catch (e) {
      developer.log(('❌ [CHAR_CREATION] Erreur lors de la génération: $e').toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}
