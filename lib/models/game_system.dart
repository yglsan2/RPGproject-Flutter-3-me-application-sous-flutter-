import 'game_edition.dart';

class GameSystem {
  final String id;
  final String name;
  final String description;
  final List<String> characterTypes;
  /// Description courte par type de personnage (ex. "Ange" -> "Être céleste au service du Ciel…").
  final Map<String, String> characterTypeDescriptions;
  final Map<String, List<String>> superiors;
  final List<String> availableTalents;
  final Map<String, List<PowerTemplate>> powers;
  final List<String> competences;
  final int playerPoints;
  final int npcPoints;
  final int minStatValue;
  final int maxStatValue;
  /// Nombre minimal de dés pour un jet (ex. INS/MV : 1).
  final int minRollDice;
  /// Nombre maximal de dés pour un jet (ex. INS/MV : 3).
  final int maxRollDice;
  final List<GameEdition> editions;

  GameSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.characterTypes,
    this.characterTypeDescriptions = const {},
    required this.superiors,
    required this.availableTalents,
    required this.powers,
    required this.competences,
    required this.playerPoints,
    required this.npcPoints,
    this.minStatValue = 2,
    this.maxStatValue = 5,
    this.minRollDice = 1,
    this.maxRollDice = 3,
    required this.editions,
  });

  GameEdition? getEdition(String editionId) {
    try {
      return editions.firstWhere((e) => e.id == editionId);
    } catch (e) {
      return null;
    }
  }
}

class PowerTemplate {
  final String name;
  final int costPP;
  final String description;
  /// Clé l10n pour le nom (si non null, l'UI utilisera la traduction).
  final String? nameKey;
  /// Clé l10n pour la description (si non null, l'UI utilisera la traduction).
  final String? descriptionKey;
  PowerTemplate({
    required this.name,
    required this.costPP,
    this.description = '',
    this.nameKey,
    this.descriptionKey,
  });
}
