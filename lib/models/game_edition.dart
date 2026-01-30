class GameEdition {
  final String id;
  final String name;
  final String year;
  final String description;
  /// Clé l10n pour la description (si non null, l'UI utilisera la traduction).
  final String? descriptionKey;
  /// Texte optionnel : ce qui change par rapport à l'édition précédente (ex. "Par rapport à la v4 : …").
  final String? changesFromPrevious;
  /// Clé l10n pour changesFromPrevious (si non null, l'UI utilisera la traduction).
  final String? changesFromPreviousKey;
  final List<String> statNames;
  final Map<String, int> defaultStats;
  final Map<String, Map<String, Archetype>> archetypes;

  GameEdition({
    required this.id,
    required this.name,
    required this.year,
    required this.description,
    this.descriptionKey,
    this.changesFromPrevious,
    this.changesFromPreviousKey,
    required this.statNames,
    required this.defaultStats,
    required this.archetypes,
  });

  factory GameEdition.fromJson(Map<String, dynamic> json) {
    return GameEdition(
      id: json['id'],
      name: json['name'],
      year: json['year'],
      description: json['description'],
      descriptionKey: json['descriptionKey'] as String?,
      changesFromPrevious: json['changesFromPrevious'] as String?,
      changesFromPreviousKey: json['changesFromPreviousKey'] as String?,
      statNames: List<String>.from(json['statNames']),
      defaultStats: Map<String, int>.from(json['defaultStats']),
      archetypes: (json['archetypes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as Map<String, dynamic>).map((k, v) => MapEntry(k, Archetype.fromJson(v)))),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'description': description,
      'descriptionKey': descriptionKey,
      'changesFromPrevious': changesFromPrevious,
      'changesFromPreviousKey': changesFromPreviousKey,
      'statNames': statNames,
      'defaultStats': defaultStats,
      'archetypes': archetypes.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, v.toJson())))),
    };
  }
}

class Archetype {
  final String name;
  final String description;
  /// Clé l10n pour le nom (si non null, l'UI utilisera la traduction).
  final String? nameKey;
  /// Clé l10n pour la description (si non null, l'UI utilisera la traduction).
  final String? descriptionKey;
  final Map<String, int> stats;
  final List<String> talents;
  final List<String> powers;

  Archetype({
    required this.name,
    required this.description,
    this.nameKey,
    this.descriptionKey,
    required this.stats,
    required this.talents,
    required this.powers,
  });

  factory Archetype.fromJson(Map<String, dynamic> json) {
    return Archetype(
      name: json['name'],
      description: json['description'],
      nameKey: json['nameKey'] as String?,
      descriptionKey: json['descriptionKey'] as String?,
      stats: Map<String, int>.from(json['stats']),
      talents: List<String>.from(json['talents']),
      powers: List<String>.from(json['powers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'nameKey': nameKey,
      'descriptionKey': descriptionKey,
      'stats': stats,
      'talents': talents,
      'powers': powers,
    };
  }
}
