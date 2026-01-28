import 'dart:math';

class NameGeneratorService {
  static final Map<String, Map<String, List<String>>> _nameBases = {
    'Fantasy': {
      'first': ['Ael', 'Bryn', 'Cael', 'Dara', 'Eira', 'Fael', 'Gwen', 'Hael', 'Iris', 'Jade', 'Kael', 'Lira', 'Mira', 'Nara', 'Ora', 'Pael', 'Quinn', 'Rael', 'Sara', 'Tara'],
      'last': ['Shadow', 'Bright', 'Storm', 'Fire', 'Ice', 'Wind', 'Earth', 'Star', 'Moon', 'Sun', 'Dawn', 'Dusk', 'Light', 'Dark', 'Silver', 'Gold'],
    },
    'Médiéval': {
      'first': ['William', 'Richard', 'Henry', 'Edward', 'John', 'Robert', 'Thomas', 'Geoffrey', 'Hugh', 'Roger', 'Ralph', 'Walter', 'Simon', 'Peter'],
      'last': ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez'],
    },
    'Moderne': {
      'first': ['Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Avery', 'Quinn', 'Sage', 'River', 'Phoenix', 'Skylar'],
      'last': ['Anderson', 'Brown', 'Davis', 'Garcia', 'Harris', 'Jackson', 'Johnson', 'Jones', 'Lee', 'Martinez', 'Miller'],
    },
    'Sci-Fi': {
      'first': ['Zara', 'Nex', 'Kira', 'Jax', 'Lyra', 'Zane', 'Nova', 'Orion', 'Astra', 'Vex', 'Luna', 'Cosmo'],
      'last': ['Prime', 'Vector', 'Nexus', 'Quantum', 'Nova', 'Stellar', 'Cosmic', 'Orbit', 'Pulse', 'Matrix'],
    },
    'Asiatique': {
      'first': ['Hiro', 'Kenji', 'Yuki', 'Sakura', 'Ren', 'Akira', 'Mei', 'Takeshi', 'Hana', 'Ryo', 'Kai', 'Maya'],
      'last': ['Tanaka', 'Sato', 'Suzuki', 'Takahashi', 'Watanabe', 'Ito', 'Yamamoto', 'Nakamura', 'Kobayashi', 'Kato'],
    },
    'Nordique': {
      'first': ['Bjorn', 'Erik', 'Freya', 'Gunnar', 'Helga', 'Ingrid', 'Leif', 'Magnus', 'Olaf', 'Ragnar', 'Sigrid', 'Thor'],
      'last': ['Andersen', 'Berg', 'Dahl', 'Eriksen', 'Hansen', 'Johansen', 'Larsen', 'Nielsen', 'Olsen', 'Pedersen'],
    },
    'Latino': {
      'first': ['Alejandro', 'Carlos', 'Diego', 'Elena', 'Fernando', 'Gabriela', 'Hector', 'Isabella', 'Javier', 'Karla'],
      'last': ['Garcia', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Perez', 'Sanchez', 'Ramirez', 'Torres'],
    },
    'Arabe': {
      'first': ['Ahmed', 'Ali', 'Fatima', 'Hassan', 'Ibrahim', 'Khadija', 'Mahmoud', 'Mariam', 'Mohammed', 'Nadia'],
      'last': ['Al-Ahmad', 'Al-Hassan', 'Al-Mahmoud', 'Al-Rashid', 'Al-Zahra', 'Ibn Ali', 'Ibn Hassan', 'Al-Farouk'],
    },
  };

  static final List<String> _origins = ['Fantasy', 'Médiéval', 'Moderne', 'Sci-Fi', 'Asiatique', 'Nordique', 'Latino', 'Arabe'];
  static final List<String> _styles = ['Classique', 'Court', 'Long', 'Élégant', 'Brutal', 'Mystique'];

  static List<String> get origins => _origins;
  static List<String> get styles => _styles;

  static String generate({String origin = 'Fantasy', String style = 'Classique'}) {
    final base = _nameBases[origin] ?? _nameBases['Fantasy']!;
    final firstName = base['first']![Random().nextInt(base['first']!.length)];
    final lastName = base['last']![Random().nextInt(base['last']!.length)];

    switch (style) {
      case 'Court':
        return firstName;
      case 'Long':
        return '$firstName $lastName ${base['last']![Random().nextInt(base['last']!.length)]}';
      case 'Élégant':
        return '$firstName de $lastName';
      case 'Brutal':
        final suffixes = ['Sang', 'Fer', 'Ombre', 'Feu'];
        return '$firstName $lastName-${suffixes[Random().nextInt(suffixes.length)]}';
      case 'Mystique':
        final mystical = ['Ael', 'Zara', 'Nex'];
        return '${mystical[Random().nextInt(mystical.length)]} $lastName';
      default:
        return '$firstName $lastName';
    }
  }
}
