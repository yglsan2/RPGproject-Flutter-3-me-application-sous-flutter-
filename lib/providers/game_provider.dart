import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_system.dart';
import '../data/game_data.dart';
import 'dart:developer' as developer;

class GameProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<GameSystem> _gameSystems = [];
  GameSystem? _currentGame;
  String? _currentEditionId;
  String? _savedArchetype;

  GameProvider(this.prefs) {
    developer.log(('🎮 [GAME_PROVIDER] Initialisation...').toString());
    _loadGameSystems();
    _loadPreferences();
    developer.log(('✅ [GAME_PROVIDER] Initialisé').toString());
  }

  List<GameSystem> get gameSystems => _gameSystems;
  GameSystem? get currentGame => _currentGame;
  String? get currentEditionId => _currentEditionId;
  String? get savedArchetype => _savedArchetype;

  void _loadGameSystems() {
    developer.log(('📚 [GAME_PROVIDER] Chargement des systèmes de jeu...').toString());
    _gameSystems = GameData.getGameSystems();
    developer.log(('✅ [GAME_PROVIDER] ${_gameSystems.length} systèmes chargés').toString());
    if (_gameSystems.isNotEmpty) {
      _currentGame = _gameSystems.first;
      developer.log(('🎯 [GAME_PROVIDER] Jeu par défaut: ${_currentGame!.name}').toString());
    }
  }

  void _loadPreferences() {
    developer.log(('💾 [GAME_PROVIDER] Chargement des préférences...').toString());
    final savedGameId = prefs.getString('saved_game_id');
    final savedEditionId = prefs.getString('saved_edition_id');
    
    if (savedGameId != null) {
      developer.log(('  - Jeu sauvegardé: $savedGameId').toString());
      _currentGame = _gameSystems.firstWhere(
        (g) => g.id == savedGameId,
        orElse: () => _gameSystems.first,
      );
      developer.log(('  ✅ Jeu restauré: ${_currentGame!.name}').toString());
    }
    
    if (savedEditionId != null) {
      developer.log(('  - Édition sauvegardée: $savedEditionId').toString());
      _currentEditionId = savedEditionId;
    } else if (_currentGame != null && _currentGame!.editions.isNotEmpty) {
      _currentEditionId = _currentGame!.editions.first.id;
      developer.log(('  - Édition par défaut: $_currentEditionId').toString());
    }
    
    notifyListeners();
    developer.log(('✅ [GAME_PROVIDER] Préférences chargées').toString());
  }

  void setCurrentGame(GameSystem game) {
    developer.log(('🎮 [GAME_PROVIDER] Changement de jeu: ${game.name}').toString());
    _currentGame = game;
    prefs.setString('saved_game_id', game.id);
    developer.log(('💾 [GAME_PROVIDER] Jeu sauvegardé: ${game.id}').toString());
    
    if (game.editions.isNotEmpty) {
      _currentEditionId = game.editions.first.id;
      prefs.setString('saved_edition_id', _currentEditionId!);
      developer.log(('📖 [GAME_PROVIDER] Édition définie: $_currentEditionId').toString());
    }
    
    notifyListeners();
    developer.log(('✅ [GAME_PROVIDER] Jeu changé avec succès').toString());
  }

  void setCurrentEdition(String editionId) {
    developer.log(('📖 [GAME_PROVIDER] Changement d\'édition: $editionId').toString());
    _currentEditionId = editionId;
    prefs.setString('saved_edition_id', editionId);
    developer.log(('💾 [GAME_PROVIDER] Édition sauvegardée').toString());
    notifyListeners();
  }

  void setRandomEdition() {
    if (_currentGame == null || _currentGame!.editions.isEmpty) {
      developer.log(('⚠️ [GAME_PROVIDER] Impossible de choisir une édition aléatoire').toString());
      return;
    }
    developer.log(('🎲 [GAME_PROVIDER] Sélection aléatoire d\'édition...').toString());
    final random = _currentGame!.editions.toList()..shuffle();
    setCurrentEdition(random.first.id);
    developer.log(('✅ [GAME_PROVIDER] Édition aléatoire: ${random.first.name}').toString());
  }

  void saveArchetype(String characterType, String archetypeName) {
    final key = 'archetype_${_currentGame?.id}_$characterType';
    prefs.setString(key, archetypeName);
    _savedArchetype = archetypeName;
    developer.log(('💾 [GAME_PROVIDER] Archétype sauvegardé: $archetypeName pour $characterType').toString());
    notifyListeners();
  }

  String? getSavedArchetype(String characterType) {
    final key = 'archetype_${_currentGame?.id}_$characterType';
    final archetype = prefs.getString(key);
    if (archetype != null) {
      developer.log(('📖 [GAME_PROVIDER] Archétype restauré: $archetype pour $characterType').toString());
    }
    return archetype;
  }
}
