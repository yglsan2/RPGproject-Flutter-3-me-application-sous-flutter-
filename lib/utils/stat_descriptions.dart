/// Descriptions des caractéristiques principales pour les bulles d'information
/// (utile pour les joueurs qui débutent en jeu de rôle).
class StatDescriptions {
  StatDescriptions._();

  static const Map<String, String> _descriptions = {
    // INS/MV v1–v3, DnD
    'Force': 'Capacité physique, musculation, portée et dégâts en mêlée.',
    'Agilité': 'Dextérité, réflexes, coordination, esquive et précision.',
    'Intelligence': 'Raisonnement, logique, mémoire et connaissances.',
    'Volonté': 'Résistance mentale, détermination, résistance aux influences.',
    'Perception': 'Vigilance, sens aiguisés, repérage et lecture des situations.',
    'Présence': 'Charisme, impact social, autorité et capacité à impressionner.',
    // INS/MV v4–v6 (6e caractéristique)
    'Rêve': 'Lien avec l\'onirique, intuition créative et imagination (éditions récentes INS/MV).',
    'Empathie': 'Ressenti des émotions d\'autrui, lien avec les autres et compréhension (éd. INS/MV).',
    'Intuition': 'Pressentiment, lecture des situations et flair (éditions INS/MV).',
    // Agone
    'Corps': 'Vigueur physique, santé et résistance aux blessures.',
    'Âme': 'Force spirituelle et résistance aux influences surnaturelles.',
    'Esprit': 'Intellect, raison et facultés mentales.',
    // DnD / Prophécy
    'Dextérité': 'Adresse, réflexes et précision (équivalent Agilité).',
    'Constitution': 'Endurance, résistance physique et santé.',
    'Sagesse': 'Perception, intuition et force de caractère.',
    'Charisme': 'Force de personnalité, influence et présence.',
    // Fallback
    'Apparence': 'Aspect physique et première impression.',
  };

  /// Retourne la description d'une caractéristique, ou null si inconnue.
  static String? get(String statName) => _descriptions[statName];

  /// Retourne la description ou une phrase par défaut.
  static String getOrDefault(String statName) =>
      _descriptions[statName] ?? 'Caractéristique du personnage.';
}
