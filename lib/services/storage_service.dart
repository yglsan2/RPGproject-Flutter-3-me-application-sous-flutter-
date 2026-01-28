import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../models/character.dart';

class StorageService {
  static const String _charactersKey = 'saved_characters';

  static Future<void> saveCharacter(Character character) async {
    developer.log(('💾 [STORAGE] Sauvegarde du personnage: ${character.name}').toString());
    try {
      final prefs = await SharedPreferences.getInstance();
      final characters = await getSavedCharacters();
      
      final index = characters.indexWhere((c) => c.id == character.id);
      if (index >= 0) {
        characters[index] = character;
        developer.log(('  - Personnage mis à jour').toString());
      } else {
        characters.add(character);
        developer.log(('  - Personnage ajouté').toString());
      }
      
      final jsonList = characters.map((c) => c.toJson()).toList();
      await prefs.setString(_charactersKey, jsonEncode(jsonList));
      developer.log(('✅ [STORAGE] Personnage sauvegardé (Total: ${characters.length})').toString());
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de la sauvegarde: $e').toString());
      rethrow;
    }
  }

  static Future<List<Character>> getSavedCharacters() async {
    developer.log(('📖 [STORAGE] Chargement des personnages sauvegardés...').toString());
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_charactersKey);
      if (jsonString == null) {
        developer.log(('  - Aucun personnage sauvegardé').toString());
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List;
      final characters = jsonList.map((json) => Character.fromJson(json)).toList();
      developer.log(('✅ [STORAGE] ${characters.length} personnage(s) chargé(s)').toString());
      return characters;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors du chargement: $e').toString());
      return [];
    }
  }

  static Future<void> deleteCharacter(String id) async {
    developer.log(('🗑️ [STORAGE] Suppression du personnage: $id').toString());
    try {
      final characters = await getSavedCharacters();
      characters.removeWhere((c) => c.id == id);
      final prefs = await SharedPreferences.getInstance();
      final jsonList = characters.map((c) => c.toJson()).toList();
      await prefs.setString(_charactersKey, jsonEncode(jsonList));
      developer.log(('✅ [STORAGE] Personnage supprimé (Total: ${characters.length})').toString());
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de la suppression: $e').toString());
      rethrow;
    }
  }

  static Future<String> exportCharacterToFile(Character character) async {
    developer.log(('📤 [STORAGE] Export du personnage vers fichier: ${character.name}').toString());
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${character.name}_${character.id}.json');
      await file.writeAsString(jsonEncode(character.toJson()));
      developer.log(('✅ [STORAGE] Personnage exporté: ${file.path}').toString());
      return file.path;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de l\'export: $e').toString());
      rethrow;
    }
  }

  static Future<Character?> importCharacterFromFile(String filePath) async {
    developer.log(('📥 [STORAGE] Import du personnage depuis fichier: $filePath').toString());
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString);
      final character = Character.fromJson(json);
      developer.log(('✅ [STORAGE] Personnage importé: ${character.name}').toString());
      return character;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de l\'import: $e').toString());
      return null;
    }
  }
}
