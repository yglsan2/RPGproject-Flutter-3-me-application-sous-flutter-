import 'dart:math';
import 'dart:developer' as developer;
import '../models/character.dart';
import '../models/game_system.dart';
import '../models/game_edition.dart';
import 'npc_generator_service.dart';

class CharacterGeneratorService {
  static final Random _random = Random();

  static Character generateCharacter({
    required GameSystem gameSystem,
    required String editionId,
    required String characterType,
    String? archetypeName,
    bool isNPC = false,
    bool useArchetype = true,
  }) {
    developer.log(('🎲 [CHAR_GEN] Début génération personnage').toString());
    developer.log(('  - Système: ${gameSystem.name}').toString());
    developer.log(('  - Édition: $editionId').toString());
    developer.log(('  - Type: $characterType').toString());
    developer.log(('  - Archétype: ${archetypeName ?? "Aucun"}').toString());
    developer.log(('  - PNJ: $isNPC').toString());
    
    final edition = gameSystem.getEdition(editionId);
    if (edition == null) {
      developer.log(('❌ [CHAR_GEN] ERREUR: Édition non trouvée').toString());
      throw Exception('Édition non trouvée');
    }
    developer.log(('✅ [CHAR_GEN] Édition trouvée: ${edition.name}').toString());

    final totalPoints = isNPC ? gameSystem.npcPoints : gameSystem.playerPoints;
    developer.log(('📊 [CHAR_GEN] Points totaux: $totalPoints (${isNPC ? "PNJ" : "Joueur"})').toString());
    
    Map<String, int> characteristics;

    if (useArchetype && archetypeName != null) {
      developer.log(('🎯 [CHAR_GEN] Génération depuis archétype: $archetypeName').toString());
      final archetype = edition.archetypes[characterType]?[archetypeName];
      characteristics = archetype != null
          ? _generateStatsFromArchetype(archetype, totalPoints, edition, gameSystem)
          : _generateBalancedStats(edition.statNames, totalPoints, gameSystem.minStatValue, gameSystem.maxStatValue);
    } else {
      developer.log(('🎲 [CHAR_GEN] Génération aléatoire complète').toString());
      characteristics = _generateBalancedStats(edition.statNames, totalPoints, gameSystem.minStatValue, gameSystem.maxStatValue);
    }
    
    developer.log(('📈 [CHAR_GEN] Caractéristiques générées: $characteristics').toString());
    final statsTotal = characteristics.values.reduce((a, b) => a + b);
    developer.log(('  - Total: $statsTotal / $totalPoints').toString());

    int fatiguePoints = 0;
    int powerPoints = 0;

    if (gameSystem.id == 'ins-mv') {
      final force = characteristics['Force'] ?? 0;
      final volonte = characteristics['Volonté'] ?? 0;
      fatiguePoints = force + volonte;
      powerPoints = volonte + (characterType == 'Ange' || characterType == 'Démon' ? 2 : 0);
      developer.log(('💪 [CHAR_GEN] INS/MV - PF: $fatiguePoints, PP: $powerPoints').toString());
    } else if (gameSystem.id == 'agone') {
      final corps = characteristics['Corps'] ?? 0;
      final ame = characteristics['Âme'] ?? 0;
      fatiguePoints = corps + ame;
      powerPoints = (characteristics['Esprit'] ?? 0) + (characteristics['Rêve'] ?? 0);
      developer.log(('💪 [CHAR_GEN] Agone - PV: $fatiguePoints, PM: $powerPoints').toString());
    } else if (gameSystem.id == 'prophecy' || gameSystem.id == 'dnd') {
      final constitution = characteristics['Constitution'] ?? 0;
      fatiguePoints = constitution * 2;
      powerPoints = (characteristics['Intelligence'] ?? 0) + (characteristics['Sagesse'] ?? 0);
      developer.log(('💪 [CHAR_GEN] Prophecy/D&D - PV: $fatiguePoints, PM: $powerPoints').toString());
    }

    final superior = gameSystem.superiors[characterType]?.first ?? 'Indépendant';
    developer.log(('👑 [CHAR_GEN] Supérieur: $superior').toString());

    List<String> talents = [];
    List<Power> powers = [];

    if (useArchetype && archetypeName != null) {
      final archetype = edition.archetypes[characterType]?[archetypeName];
      if (archetype != null) {
        talents = List.from(archetype.talents);
        powers = archetype.powers.map((powerName) {
          final powerList = gameSystem.powers[characterType] ?? [];
          final template = powerList.firstWhere(
            (p) => p.name == powerName,
            orElse: () => PowerTemplate(name: powerName, costPP: 1),
          );
          return Power(name: template.name, costPP: template.costPP, description: template.description);
        }).toList();
        developer.log(('🎭 [CHAR_GEN] Talents depuis archétype: ${talents.length}').toString());
        developer.log(('✨ [CHAR_GEN] Pouvoirs depuis archétype: ${powers.length}').toString());
      }
    }

    if (talents.isEmpty) {
      talents = _generateRandomTalents(gameSystem.availableTalents, isNPC: isNPC);
      developer.log(('🎲 [CHAR_GEN] Talents aléatoires générés: ${talents.length}').toString());
    }
    if (powers.isEmpty) {
      powers = _generateRandomPowers(gameSystem.powers[characterType] ?? [], isNPC: isNPC);
      developer.log(('🎲 [CHAR_GEN] Pouvoirs aléatoires générés: ${powers.length}').toString());
    }

    // Enrichir les PNJ avec le service NPC
    String motivation = '';
    if (isNPC) {
      final role = NPCGeneratorService.generateNPCRole();
      final npcMotivation = NPCGeneratorService.generateNPCMotivation();
      final personality = NPCGeneratorService.generateNPCPersonality();
      final factionRelation = NPCGeneratorService.generateNPCFactionRelation();
      motivation = NPCGeneratorService.generateNPCDescription(
        role: role,
        motivation: npcMotivation,
        personality: personality,
        factionRelation: factionRelation,
      );
      developer.log(('🎭 [CHAR_GEN] PNJ enrichi - Rôle: $role, Motivation: $npcMotivation').toString());
    }

    final character = Character(
      name: 'Nouveau Personnage',
      type: characterType,
      superior: superior,
      motivation: motivation,
      characteristics: characteristics,
      fatiguePoints: fatiguePoints,
      powerPoints: powerPoints,
      talents: talents,
      powers: powers,
      competences: _generateCompetences(gameSystem.competences, isNPC: isNPC),
      equipment: _generateEquipment(characterType, gameSystem.id),
      gameId: gameSystem.id,
      editionId: editionId,
      isNPC: isNPC,
    );

    developer.log(('✅ [CHAR_GEN] Personnage généré avec succès: ${character.id}').toString());
    return character;
  }

  static Map<String, int> _generateBalancedStats(List<String> statNames, int totalPoints, int minValue, int maxValue) {
    developer.log(('📊 [CHAR_GEN] Génération stats équilibrées').toString());
    developer.log(('  - Stats: ${statNames.length}').toString());
    developer.log(('  - Points: $totalPoints').toString());
    developer.log(('  - Min: $minValue, Max: $maxValue').toString());
    
    final stats = <String, int>{};
    final numStats = statNames.length;
    final targetAverage = totalPoints / numStats;
    var remainingPoints = totalPoints;
    final guaranteedPoints = minValue * numStats;
    remainingPoints -= guaranteedPoints;

    developer.log(('  - Moyenne cible: ${targetAverage.toStringAsFixed(2)}').toString());
    developer.log(('  - Points garantis: $guaranteedPoints').toString());
    developer.log(('  - Points restants: $remainingPoints').toString());

    for (final stat in statNames) { stats[stat] = minValue; }

    final maxPerStat = maxValue - minValue;
    final variations = List.filled(numStats, 0);
    var pointsDistributed = 0;
    final targetDistribution = (remainingPoints * 0.8).round();

    developer.log(('  - Distribution pondérée: $targetDistribution points').toString());

    while (pointsDistributed < targetDistribution && remainingPoints > 0) {
      final statIndex = _selectStatIndexForDistribution(stats, statNames, targetAverage, minValue, maxValue, variations, maxPerStat);
      if (statIndex != -1 && variations[statIndex] < maxPerStat) {
        variations[statIndex]++;
        pointsDistributed++;
        remainingPoints--;
      } else {
        break;
      }
    }

    while (remainingPoints > 0) {
      var attempts = 0;
      while (attempts < 100 && remainingPoints > 0) {
        final statIndex = _random.nextInt(numStats);
        if (variations[statIndex] < maxPerStat) {
          variations[statIndex]++;
          remainingPoints--;
          break;
        }
        attempts++;
      }
      if (attempts >= 100) break;
    }

    for (var i = 0; i < statNames.length; i++) {
      stats[statNames[i]] = stats[statNames[i]]! + variations[i];
    }

    final currentTotal = stats.values.reduce((a, b) => a + b);
    final difference = totalPoints - currentTotal;

    if (difference != 0) {
      developer.log(('⚠️ [CHAR_GEN] Ajustement final: $difference points').toString());
      final avg = totalPoints / numStats;
      var closestIndex = 0;
      var closestDiff = (stats[statNames[0]]! - avg).abs();
      for (var i = 1; i < statNames.length; i++) {
        final diff = (stats[statNames[i]]! - avg).abs();
        if (diff < closestDiff) {
          closestDiff = diff;
          closestIndex = i;
        }
      }
      stats[statNames[closestIndex]] = (stats[statNames[closestIndex]]! + difference).clamp(minValue, maxValue);
    }

    _optimizeLowValues(stats, statNames, minValue, maxValue, totalPoints);
    
    final finalTotal = stats.values.reduce((a, b) => a + b);
    developer.log(('✅ [CHAR_GEN] Stats finales: $stats (Total: $finalTotal)').toString());
    return stats;
  }

  static int _selectStatIndexForDistribution(
    Map<String, int> currentStats,
    List<String> statNames,
    double targetAverage,
    int minValue,
    int maxValue,
    List<int> variations,
    int maxPerStat,
  ) {
    final candidates = <int, double>{};
    
    for (var i = 0; i < statNames.length; i++) {
      if (variations[i] >= maxPerStat) continue;
      final currentValue = currentStats[statNames[i]]! + variations[i];
      final distanceFromAverage = (currentValue - targetAverage).abs();
      double weight = 1.0;
      
      if (currentValue <= minValue + 1) {
        weight = 2.5;
      } else if (currentValue >= maxValue - 1) {
        weight = 0.5;
      } else if (distanceFromAverage < 1.0) {
        weight = 1.5;
      } else {
        weight = 1.0;
      }
      
      candidates[i] = weight;
    }
    
    if (candidates.isEmpty) return -1;
    
    final totalWeight = candidates.values.reduce((a, b) => a + b);
    var randomValue = _random.nextDouble() * totalWeight;
    
    for (final entry in candidates.entries) {
      randomValue -= entry.value;
      if (randomValue <= 0) return entry.key;
    }
    
    return candidates.keys.first;
  }

  static void _optimizeLowValues(Map<String, int> stats, List<String> statNames, int minValue, int maxValue, int totalPoints) {
    final lowValueThreshold = minValue + 1;
    var lowValueCount = 0;
    
    for (final value in stats.values) {
      if (value <= lowValueThreshold) lowValueCount++;
    }
    
    final maxLowValues = (statNames.length * 0.3).ceil();
    
    if (lowValueCount > maxLowValues) {
      developer.log(('🔧 [CHAR_GEN] Optimisation des valeurs basses: $lowValueCount > $maxLowValues').toString());
      final lowStats = <int>[];
      final highStats = <int>[];
      
      for (var i = 0; i < statNames.length; i++) {
        final value = stats[statNames[i]]!;
        if (value <= lowValueThreshold) {
          lowStats.add(i);
        } else if (value >= maxValue - 1) {
          highStats.add(i);
        }
      }
      
      var pointsToRedistribute = (lowValueCount - maxLowValues) * 2;
      developer.log(('  - Points à redistribuer: $pointsToRedistribute').toString());
      
      while (pointsToRedistribute > 0 && highStats.isNotEmpty && lowStats.isNotEmpty) {
        final highIndex = highStats[_random.nextInt(highStats.length)];
        final lowIndex = lowStats[_random.nextInt(lowStats.length)];
        
        if (stats[statNames[highIndex]]! > minValue + 1 && stats[statNames[lowIndex]]! < maxValue - 1) {
          stats[statNames[highIndex]] = stats[statNames[highIndex]]! - 1;
          stats[statNames[lowIndex]] = stats[statNames[lowIndex]]! + 1;
          pointsToRedistribute--;
          
          if (stats[statNames[highIndex]]! <= maxValue - 1) highStats.remove(highIndex);
          if (stats[statNames[lowIndex]]! > lowValueThreshold) lowStats.remove(lowIndex);
        } else {
          break;
        }
      }
      
      final currentTotal = stats.values.reduce((a, b) => a + b);
      final difference = totalPoints - currentTotal;
      
      if (difference != 0) {
        final avg = totalPoints / statNames.length;
        var closestIndex = 0;
        var closestDiff = (stats[statNames[0]]! - avg).abs();
        for (var i = 1; i < statNames.length; i++) {
          final diff = (stats[statNames[i]]! - avg).abs();
          if (diff < closestDiff) {
            closestDiff = diff;
            closestIndex = i;
          }
        }
        stats[statNames[closestIndex]] = (stats[statNames[closestIndex]]! + difference).clamp(minValue, maxValue);
      }
      
      developer.log(('✅ [CHAR_GEN] Optimisation terminée').toString());
    }
  }

  static Map<String, int> _generateStatsFromArchetype(Archetype archetype, int totalPoints, GameEdition edition, GameSystem gameSystem) {
    developer.log(('🎯 [CHAR_GEN] Génération depuis archétype: ${archetype.name}').toString());
    final stats = <String, int>{};
    for (final statName in edition.statNames) {
      stats[statName] = archetype.stats[statName] ?? 3;
    }

    final currentTotal = stats.values.reduce((a, b) => a + b);
    if (currentTotal != totalPoints) {
      developer.log(('  - Ajustement des points: $currentTotal -> $totalPoints').toString());
      final ratio = totalPoints / currentTotal;
      for (final stat in stats.keys) {
        stats[stat] = (stats[stat]! * ratio).round();
      }
    }

    for (final stat in stats.keys) {
      final variation = _getWeightedVariation();
      stats[stat] = (stats[stat]! + variation).clamp(gameSystem.minStatValue, gameSystem.maxStatValue);
    }

    _optimizeLowValues(stats, edition.statNames, gameSystem.minStatValue, gameSystem.maxStatValue, totalPoints);
    return stats;
  }

  static int _getWeightedVariation() {
    final rand = _random.nextDouble();
    if (rand < 0.6) return 0;
    if (rand < 0.85) return 1;
    return -1;
  }

  static int randomizeSingleStat(Map<String, int> currentStats, String statName, int totalPoints, int minValue, int maxValue) {
    developer.log(('🎲 [CHAR_GEN] Randomisation stat unique: $statName').toString());
    final otherStats = Map<String, int>.from(currentStats)..remove(statName);
    final otherTotal = otherStats.values.reduce((a, b) => a + b);
    final remainingPoints = totalPoints - otherTotal;
    final numStats = currentStats.length;

    final statMin = (remainingPoints - (numStats - 1) * maxValue).clamp(minValue, maxValue);
    final statMax = (remainingPoints - (numStats - 1) * minValue).clamp(minValue, maxValue);
    
    developer.log(('  - Points restants: $remainingPoints').toString());
    developer.log(('  - Plage possible: $statMin - $statMax').toString());
    
    if (statMax - statMin <= 0) {
      developer.log(('  ⚠️ Plage invalide, retour de $statMin').toString());
      return statMin;
    }
    
    final weights = <int, double>{};
    for (int i = statMin; i <= statMax; i++) {
      if (i == statMin || i == statMax) {
        weights[i] = 0.5;
      } else if (i == statMin + 1 || i == statMax - 1) {
        weights[i] = 1.0;
      } else {
        weights[i] = 2.0;
      }
    }
    
    final totalWeight = weights.values.reduce((a, b) => a + b);
    var randomValue = _random.nextDouble() * totalWeight;
    
    for (final entry in weights.entries) {
      randomValue -= entry.value;
      if (randomValue <= 0) {
        developer.log(('  ✅ Nouvelle valeur: ${entry.key}').toString());
        return entry.key;
      }
    }
    
    final result = (statMin + statMax) ~/ 2;
    developer.log(('  ✅ Nouvelle valeur (moyenne): $result').toString());
    return result;
  }

  static List<String> _generateRandomTalents(List<String> availableTalents, {bool isNPC = false}) {
    // PNJ : 2-3 talents, Joueur : 3-5 talents
    final numTalents = isNPC ? (_random.nextInt(2) + 2) : (_random.nextInt(3) + 3);
    final selected = <String>[];
    final available = List.from(availableTalents);
    for (var i = 0; i < numTalents && available.isNotEmpty; i++) {
      selected.add(available.removeAt(_random.nextInt(available.length)));
    }
    return selected;
  }

  static List<Power> _generateRandomPowers(List<PowerTemplate> availablePowers, {bool isNPC = false}) {
    // PNJ : 1-2 pouvoirs, Joueur : 2-3 pouvoirs
    final numPowers = isNPC ? (_random.nextInt(2) + 1) : (_random.nextInt(2) + 2);
    final selected = <Power>[];
    final available = List.from(availablePowers);
    for (var i = 0; i < numPowers && available.isNotEmpty; i++) {
      final template = available.removeAt(_random.nextInt(available.length));
      selected.add(Power(name: template.name, costPP: template.costPP, description: template.description));
    }
    return selected;
  }

  static Map<String, int> _generateCompetences(List<String> competences, {bool isNPC = false}) {
    // PNJ : compétences à 1-2, Joueur : compétences à 1-3
    if (isNPC) {
      // Pour les PNJ, seulement quelques compétences à niveau basique
      final selectedCompetences = competences.take(_random.nextInt(competences.length ~/ 2) + competences.length ~/ 3).toList();
      return {for (final comp in selectedCompetences) comp: _random.nextInt(2) + 1};
    } else {
      return {for (final comp in competences) comp: _random.nextInt(3) + 1};
    }
  }

  static List<String> _generateEquipment(String characterType, String gameId) {
    final equipment = ['Vêtements', 'Portable', 'Portefeuille'];
    if (gameId == 'ins-mv' && (characterType == 'Ange' || characterType == 'Démon')) {
      equipment.add('Artefact surnaturel');
    } else if (gameId == 'agone') {
      equipment.add('Objet d\'art');
    } else if (gameId == 'prophecy' || gameId == 'dnd') {
      equipment.add('Arme de base');
      equipment.add('Armure légère');
    }
    return equipment;
  }
}
