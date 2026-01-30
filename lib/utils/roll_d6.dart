import 'dart:math';

/// Tirage d'un dé à 6 faces (1–6) avec bonne entropie.
/// Évite les biais type "toujours 2" en mélangeant temps et aléatoire cryptographique.
class RollD6 {
  RollD6._();

  static final Random _fallback = Random();

  /// Retourne un entier entre 1 et 6 (inclus).
  static int roll() {
    try {
      final secure = Random.secure();
      return secure.nextInt(6) + 1;
    } catch (_) {
      // Fallback: mélanger avec le temps pour varier
      final t = DateTime.now().microsecondsSinceEpoch;
      final r = Random(t ^ _fallback.nextInt(0x7FFFFFFF));
      return r.nextInt(6) + 1;
    }
  }

  /// Retourne [n] tirages D6.
  static List<int> rollMultiple(int n) {
    if (n <= 0) return [];
    final list = <int>[];
    for (var i = 0; i < n; i++) {
      list.add(roll());
    }
    return list;
  }
}
