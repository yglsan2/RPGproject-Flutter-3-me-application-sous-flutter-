import 'game_edition.dart';

class GameSystem {
  final String id;
  final String name;
  final String description;
  final List<String> characterTypes;
  final Map<String, List<String>> superiors;
  final List<String> availableTalents;
  final Map<String, List<PowerTemplate>> powers;
  final List<String> competences;
  final int playerPoints;
  final int npcPoints;
  final int minStatValue;
  final int maxStatValue;
  final List<GameEdition> editions;

  GameSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.characterTypes,
    required this.superiors,
    required this.availableTalents,
    required this.powers,
    required this.competences,
    required this.playerPoints,
    required this.npcPoints,
    this.minStatValue = 2,
    this.maxStatValue = 5,
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
  PowerTemplate({required this.name, required this.costPP, this.description = ''});
}
