import 'dart:math';

class NPCGeneratorService {
  static final Random _random = Random();

  // Rôles PNJ pour INS/MV
  static const List<String> npcRoles = [
    'Marchand',
    'Garde',
    'Prêtre',
    'Médecin',
    'Journaliste',
    'Détective',
    'Artiste',
    'Étudiant',
    'Policier',
    'Avocat',
    'Bibliothécaire',
    'Serveur',
    'Taxi',
    'Propriétaire de bar',
    'Vagabond',
    'Noble',
    'Mécanicien',
    'Informaticien',
    'Architecte',
    'Psychologue',
  ];

  // Motivations PNJ
  static const List<String> npcMotivations = [
    'Survivre dans un monde dangereux',
    'Protéger sa famille',
    "Gagner de l'argent",
    'Découvrir la vérité',
    'Servir une cause',
    'Venger un proche',
    'Trouver sa place',
    'Échapper au passé',
    'Aider les autres',
    'Accumuler du pouvoir',
    'Comprendre le surnaturel',
    'Rester neutre',
    'Servir les anges',
    'Servir les démons',
    'Éviter les conflits',
  ];

  // Traits de personnalité
  static const List<String> npcPersonalityTraits = [
    'Méfiant',
    'Curieux',
    'Courageux',
    'Lâche',
    'Généreux',
    'Avare',
    'Optimiste',
    'Pessimiste',
    'Calme',
    'Nerveux',
    'Sociable',
    'Solitaire',
    'Méticuleux',
    'Négligent',
    'Loyal',
    'Traitre',
  ];

  // Relations avec les factions
  static const List<String> npcFactionRelations = [
    'Neutre',
    'Pro-angélique',
    'Pro-démoniaque',
    'Anti-surnaturel',
    'Ignorant',
    'Manipulé',
    'Allié temporaire',
    'Ennemi déclaré',
  ];

  // Générer un rôle PNJ
  static String generateNPCRole() {
    return npcRoles[_random.nextInt(npcRoles.length)];
  }

  // Générer une motivation PNJ
  static String generateNPCMotivation() {
    return npcMotivations[_random.nextInt(npcMotivations.length)];
  }

  // Générer des traits de personnalité
  static List<String> generateNPCPersonality({int count = 2}) {
    final traits = List<String>.from(npcPersonalityTraits);
    final selected = <String>[];
    for (var i = 0; i < count && traits.isNotEmpty; i++) {
      selected.add(traits.removeAt(_random.nextInt(traits.length)));
    }
    return selected;
  }

  // Générer une relation avec les factions
  static String generateNPCFactionRelation() {
    return npcFactionRelations[_random.nextInt(npcFactionRelations.length)];
  }

  // Générer une description PNJ enrichie
  static String generateNPCDescription({
    required String role,
    required String motivation,
    required List<String> personality,
    required String factionRelation,
  }) {
    final personalityStr = personality.join(', ');
    return '$role motivé par "$motivation". Traits: $personalityStr. Relation avec le surnaturel: $factionRelation.';
  }
}
