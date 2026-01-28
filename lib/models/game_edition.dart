class GameEdition {
  final String id;
  final String name;
  final String year;
  final String description;
  final List<String> statNames;
  final Map<String, int> defaultStats;
  final Map<String, Map<String, Archetype>> archetypes;

  GameEdition({
    required this.id,
    required this.name,
    required this.year,
    required this.description,
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
      'statNames': statNames,
      'defaultStats': defaultStats,
      'archetypes': archetypes.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, v.toJson())))),
    };
  }
}

class Archetype {
  final String name;
  final String description;
  final Map<String, int> stats;
  final List<String> talents;
  final List<String> powers;

  Archetype({
    required this.name,
    required this.description,
    required this.stats,
    required this.talents,
    required this.powers,
  });

  factory Archetype.fromJson(Map<String, dynamic> json) {
    return Archetype(
      name: json['name'],
      description: json['description'],
      stats: Map<String, int>.from(json['stats']),
      talents: List<String>.from(json['talents']),
      powers: List<String>.from(json['powers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'stats': stats, 'talents': talents, 'powers': powers};
  }
}
