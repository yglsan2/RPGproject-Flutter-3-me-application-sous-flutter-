import 'package:uuid/uuid.dart';

class Character {
  final String id;
  String name;
  String type;
  String superior;
  String motivation;
  Map<String, int> characteristics;
  int fatiguePoints;
  int powerPoints;
  List<String> talents;
  List<Power> powers;
  Map<String, int> competences;
  List<String> equipment;
  String gameId;
  String editionId;
  bool isNPC;
  DateTime createdAt;
  DateTime? updatedAt;

  Character({
    String? id,
    required this.name,
    required this.type,
    required this.superior,
    this.motivation = '',
    required this.characteristics,
    required this.fatiguePoints,
    required this.powerPoints,
    required this.talents,
    required this.powers,
    required this.competences,
    required this.equipment,
    required this.gameId,
    required this.editionId,
    this.isNPC = false,
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      superior: json['superior'],
      motivation: json['motivation'] ?? '',
      characteristics: Map<String, int>.from(json['characteristics']),
      fatiguePoints: json['fatiguePoints'],
      powerPoints: json['powerPoints'],
      talents: List<String>.from(json['talents']),
      powers: (json['powers'] as List).map((p) => Power.fromJson(p)).toList(),
      competences: Map<String, int>.from(json['competences']),
      equipment: List<String>.from(json['equipment']),
      gameId: json['gameId'],
      editionId: json['editionId'],
      isNPC: json['isNPC'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'superior': superior,
      'motivation': motivation,
      'characteristics': characteristics,
      'fatiguePoints': fatiguePoints,
      'powerPoints': powerPoints,
      'talents': talents,
      'powers': powers.map((p) => p.toJson()).toList(),
      'competences': competences,
      'equipment': equipment,
      'gameId': gameId,
      'editionId': editionId,
      'isNPC': isNPC,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Character copyWith({
    String? name,
    String? type,
    String? superior,
    String? motivation,
    Map<String, int>? characteristics,
    int? fatiguePoints,
    int? powerPoints,
    List<String>? talents,
    List<Power>? powers,
    Map<String, int>? competences,
    List<String>? equipment,
    bool? isNPC,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      superior: superior ?? this.superior,
      motivation: motivation ?? this.motivation,
      characteristics: characteristics ?? this.characteristics,
      fatiguePoints: fatiguePoints ?? this.fatiguePoints,
      powerPoints: powerPoints ?? this.powerPoints,
      talents: talents ?? this.talents,
      powers: powers ?? this.powers,
      competences: competences ?? this.competences,
      equipment: equipment ?? this.equipment,
      gameId: gameId,
      editionId: editionId,
      isNPC: isNPC ?? this.isNPC,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Power {
  final String name;
  final int costPP;
  final String description;
  /// Clé l10n pour le nom (si non null, l'UI utilisera la traduction).
  final String? nameKey;
  /// Clé l10n pour la description (si non null, l'UI utilisera la traduction).
  final String? descriptionKey;

  Power({
    required this.name,
    required this.costPP,
    this.description = '',
    this.nameKey,
    this.descriptionKey,
  });

  factory Power.fromJson(Map<String, dynamic> json) {
    return Power(
      name: json['name'],
      costPP: json['costPP'],
      description: json['description'] ?? '',
      nameKey: json['nameKey'] as String?,
      descriptionKey: json['descriptionKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'costPP': costPP,
      'description': description,
      'nameKey': nameKey,
      'descriptionKey': descriptionKey,
    };
  }
}
