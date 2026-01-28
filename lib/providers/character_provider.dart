import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../services/storage_service.dart';
import 'dart:developer' as developer;

class CharacterProvider extends ChangeNotifier {
  Character? _currentCharacter;
  List<Character> _savedCharacters = [];
  bool _isLoading = false;

  Character? get currentCharacter => _currentCharacter;
  List<Character> get savedCharacters => _savedCharacters;
  bool get isLoading => _isLoading;

  CharacterProvider() {
    _loadSavedCharacters();
  }

  Future<void> _loadSavedCharacters() async {
    developer.log(('📚 [CHAR_PROVIDER] Chargement des personnages sauvegardés...').toString());
    _isLoading = true;
    notifyListeners();
    
    try {
      _savedCharacters = await StorageService.getSavedCharacters();
      developer.log(('✅ [CHAR_PROVIDER] ${_savedCharacters.length} personnage(s) chargé(s)').toString());
    } catch (e) {
      developer.log(('❌ [CHAR_PROVIDER] Erreur lors du chargement: $e').toString());
      _savedCharacters = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentCharacter(Character character) {
    developer.log(('👤 [CHAR_PROVIDER] Définition du personnage actuel: ${character.name}').toString());
    _currentCharacter = character;
    notifyListeners();
    developer.log(('✅ [CHAR_PROVIDER] Personnage défini').toString());
  }

  void updateCharacter(Character character) {
    developer.log(('✏️ [CHAR_PROVIDER] Mise à jour du personnage: ${character.name}').toString());
    _currentCharacter = character;
    notifyListeners();
    developer.log(('✅ [CHAR_PROVIDER] Personnage mis à jour').toString());
  }

  Future<void> saveCharacter(Character character) async {
    developer.log(('💾 [CHAR_PROVIDER] Sauvegarde du personnage: ${character.name}').toString());
    try {
      await StorageService.saveCharacter(character);
      final index = _savedCharacters.indexWhere((c) => c.id == character.id);
      if (index >= 0) {
        _savedCharacters[index] = character;
        developer.log(('  - Personnage mis à jour dans la liste').toString());
      } else {
        _savedCharacters.add(character);
        developer.log(('  - Personnage ajouté à la liste').toString());
      }
      developer.log(('✅ [CHAR_PROVIDER] Personnage sauvegardé (Total: ${_savedCharacters.length})').toString());
      notifyListeners();
    } catch (e) {
      developer.log(('❌ [CHAR_PROVIDER] Erreur lors de la sauvegarde: $e').toString());
      rethrow;
    }
  }

  Future<void> deleteCharacter(String id) async {
    developer.log(('🗑️ [CHAR_PROVIDER] Suppression du personnage: $id').toString());
    try {
      await StorageService.deleteCharacter(id);
      _savedCharacters.removeWhere((c) => c.id == id);
      if (_currentCharacter?.id == id) {
        _currentCharacter = null;
        developer.log(('  - Personnage actuel supprimé').toString());
      }
      developer.log(('✅ [CHAR_PROVIDER] Personnage supprimé (Total: ${_savedCharacters.length})').toString());
      notifyListeners();
    } catch (e) {
      developer.log(('❌ [CHAR_PROVIDER] Erreur lors de la suppression: $e').toString());
      rethrow;
    }
  }
}
