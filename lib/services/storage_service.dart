import 'dart:convert';
import 'package:flutter/material.dart' show Locale;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../models/character.dart';
import 'sheet_pdf_service.dart';
import 'sheet_odt_service.dart';

/// Format OMF (Open ManyFaces) – format de fiche personnage de l'application.
class OmfFormat {
  static const String formatId = 'OMF';
  static const int version = 1;
  static const String generator = 'ManyFaces';

  static Map<String, dynamic> toOmfDocument(Character character) {
    return {
      'format': formatId,
      'version': version,
      'generator': generator,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'character': character.toJson(),
    };
  }

  /// Retourne le personnage si [json] est un document OMF ou un JSON personnage brut ; sinon null.
  static Character? characterFromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    if (json['format'] == formatId && json['character'] != null) {
      return Character.fromJson(Map<String, dynamic>.from(json['character'] as Map));
    }
    return Character.fromJson(json);
  }
}

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

  /// Exporte la fiche personnage au format OMF (Open ManyFaces), format natif de l'application.
  static Future<String> exportCharacterToOmf(Character character) async {
    developer.log(('📤 [STORAGE] Export fiche OMF: ${character.name}').toString());
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory('${directory.path}/ManyFaces_fiches');
      if (!await dir.exists()) await dir.create(recursive: true);
      final fileName = '${_sanitizeFileName(character.name)}_${character.id.substring(0, 8)}.omf';
      final file = File('${dir.path}/$fileName');
      final doc = OmfFormat.toOmfDocument(character);
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(doc), encoding: utf8);
      developer.log(('✅ [STORAGE] Fiche OMF exportée: ${file.path}').toString());
      return file.path;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de l\'export OMF: $e').toString());
      rethrow;
    }
  }

  /// Exporte les données brutes du personnage en JSON (sauvegarde / import).
  static Future<String> exportCharacterToFile(Character character) async {
    developer.log(('📤 [STORAGE] Export données brutes: ${character.name}').toString());
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory('${directory.path}/ManyFaces_fiches');
      if (!await dir.exists()) await dir.create(recursive: true);
      final fileName = '${_sanitizeFileName(character.name)}_${character.id.substring(0, 8)}.json';
      final file = File('${dir.path}/$fileName');
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(character.toJson()), encoding: utf8);
      developer.log(('✅ [STORAGE] Données brutes exportées: ${file.path}').toString());
      return file.path;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de l\'export JSON: $e').toString());
      rethrow;
    }
  }

  /// Exporte la fiche personnage en PDF A4 (style INS/MV) et retourne le chemin du fichier.
  static Future<String> exportCharacterToPdf(Character character, Locale locale) async {
    developer.log(('📤 [STORAGE] Export fiche PDF A4: ${character.name}').toString());
    try {
      final bytes = await SheetPdfService.buildFichePdf(character, locale);
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory('${directory.path}/ManyFaces_fiches');
      if (!await dir.exists()) await dir.create(recursive: true);
      final fileName = '${_sanitizeFileName(character.name)}_fiche_${character.id.substring(0, 8)}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      developer.log(('✅ [STORAGE] Fiche PDF exportée: ${file.path}').toString());
      return file.path;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de l\'export PDF: $e').toString());
      rethrow;
    }
  }

  /// Exporte la fiche personnage en ODT (LibreOffice / Word) pour édition.
  static Future<String> exportCharacterToOdt(Character character, Locale locale) async {
    developer.log(('📤 [STORAGE] Export fiche ODT: ${character.name}').toString());
    try {
      final bytes = await SheetOdtService.buildFicheOdt(character, locale);
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory('${directory.path}/ManyFaces_fiches');
      if (!await dir.exists()) await dir.create(recursive: true);
      final fileName = '${_sanitizeFileName(character.name)}_fiche_${character.id.substring(0, 8)}.odt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      developer.log(('✅ [STORAGE] Fiche ODT exportée: ${file.path}').toString());
      return file.path;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de l\'export ODT: $e').toString());
      rethrow;
    }
  }

  static String _sanitizeFileName(String name) {
    final s = name.replaceAll(RegExp(r'[^\w\s\-àâäéèêëïîôùûüç]'), '').replaceAll(RegExp(r'\s+'), '_').trim();
    return s.isEmpty ? 'fiche' : s;
  }

  /// Importe un personnage depuis un fichier .omf (Open ManyFaces) ou .json (brut ou legacy).
  static Future<Character?> importCharacterFromFile(String filePath) async {
    developer.log(('📥 [STORAGE] Import du personnage depuis fichier: $filePath').toString());
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString);
      final character = OmfFormat.characterFromJson(json);
      if (character == null) {
        developer.log(('❌ [STORAGE] Format de fichier non reconnu').toString());
        return null;
      }
      developer.log(('✅ [STORAGE] Personnage importé: ${character.name}').toString());
      return character;
    } catch (e) {
      developer.log(('❌ [STORAGE] Erreur lors de l\'import: $e').toString());
      return null;
    }
  }
}
