import '../models/game_system.dart';
import '../models/game_edition.dart';

class GameData {
  static List<GameSystem> getGameSystems() => [
    _getINSMVSystem(),
    _getAgoneSystem(),
    _getProphecySystem(),
    _getDnDSystem(),
  ];

  // INS/MV
  static GameSystem _getINSMVSystem() {
    return GameSystem(
      id: 'ins-mv',
      name: 'INS/MV',
      description: 'In Nomine Satanis / Magna Veritas - Jeu de rôle urbain-fantastique où anges et démons s\'affrontent dans le monde moderne',
      characterTypes: ['Ange', 'Démon', 'Humain'],
      superiors: {
        'Ange': ['Blandine (Rêves)', 'Ange (Convertis)', 'Christophe (Enfants)', 'Dominique (Justice)', 'Michel (Guerre)', 'Novalis (Fleurs)', 'Jordi (Animaux)', 'Joseph (Inquisition)', 'Laurent (Épée)', 'Yves (Sources)', 'Walther (Exorcistes)', 'Didier (Communication)', 'Francis (Diplomatie)', 'Marc (Échanges)', 'Janus (Vents)', 'Jean (Foudre)', 'Alain (Cultures)', 'Daniel (Pierre)', 'Catherine (Femmes)', 'Gabriel (Feu)', 'Georges (Purification)', 'Guy (Guérisseurs)', 'Jean-Luc (Protecteurs)', 'Emmanuel (Double Jeu)', 'Mathias (Confusion)'],
        'Démon': ['Baal (Guerre)', 'Andrealphus (Luxure)', 'Sammael (Colère)', 'Belial (Envie)', 'Lilith (Orgueil)', 'Belphegor (Paresse)', 'Beelzebub (Gloutonnerie)', 'Mammon (Avarice)', 'Asmodée (Jeu)', 'Abalam (Folie)', 'Andromalius (Jugement)', 'Baalberith (Administration)', 'Beleth (Cauchemars)', 'Bifrons (Destruction)', 'Caym (Guerre)', 'Crocell (Eau)', 'Furfur (Tempêtes)', 'Gaziel (Feu)', 'Haagenti (Transformation)', 'Malthus (Mort)', 'Nisroch (Vengeance)', 'Nog (Mensonge)', 'Ouikka (Peur)', 'Shaytan (Tentation)', 'Uphir (Alchimie)'],
        'Humain': ['Indépendant', 'Rechercheur', 'Croyant', 'Sceptique', 'Médiateur', 'Chasseur', 'Érudit', 'Médium'],
      },
      availableTalents: ['Combat rapproché', 'Combat à distance', 'Discrétion', 'Persuasion', 'Intimidation', 'Connaissances religieuses', 'Connaissances occultes', 'Conduite', 'Informatique', 'Médecine', 'Survie', 'Observation', 'Empathie', 'Résistance mentale', 'Résistance physique', 'Protection'],
      powers: {
        'Ange': [
          PowerTemplate(name: 'Guérison divine', costPP: 2, description: 'Guérit les blessures'),
          PowerTemplate(name: 'Bénédiction', costPP: 1, description: 'Protection temporaire'),
          PowerTemplate(name: 'Vision céleste', costPP: 1, description: 'Voir au-delà du voile'),
          PowerTemplate(name: 'Parole divine', costPP: 3, description: 'Commande par la voix'),
          PowerTemplate(name: 'Protection angélique', costPP: 2, description: 'Bouclier de lumière'),
        ],
        'Démon': [
          PowerTemplate(name: 'Malédiction', costPP: 2, description: 'Inflige malchance'),
          PowerTemplate(name: 'Tentation', costPP: 1, description: 'Influence les désirs'),
          PowerTemplate(name: 'Vision infernale', costPP: 1, description: 'Voir les péchés'),
          PowerTemplate(name: 'Parole infernale', costPP: 3, description: 'Commande par la voix'),
          PowerTemplate(name: 'Protection démoniaque', costPP: 2, description: "Bouclier d'ombre"),
        ],
        'Humain': [
          PowerTemplate(name: 'Intuition', costPP: 1, description: 'Pressentiment'),
          PowerTemplate(name: 'Résistance', costPP: 2, description: 'Résistance aux influences'),
          PowerTemplate(name: 'Détermination', costPP: 1, description: 'Bonus de volonté'),
        ],
      },
      competences: ['Discrétion', 'Connaissances religieuses', 'Connaissances occultes', 'Combat', 'Persuasion', 'Observation', 'Survie', 'Médecine', 'Informatique', 'Conduite'],
      playerPoints: 15,
      npcPoints: 12,
      minStatValue: 2,
      maxStatValue: 5,
      editions: _getINSMVEditions(),
    );
  }

  // Archétypes INS/MV v1 - Anges
  static Map<String, Map<String, Archetype>> _getINSMVArchetypesV1() {
    return {
      'Ange': {
        'Blandine (Rêves)': Archetype(
          name: 'Blandine (Rêves)',
          description: 'Ange des Rêves, protecteur des songes et des espoirs. Maître de l\'onirisme et de la communication avec l\'inconscient',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 5, 'Volonté': 4, 'Perception': 4, 'Présence': 2},
          talents: ['Observation', 'Connaissances occultes', 'Empathie', 'Discrétion'],
          powers: ['Vision céleste', 'Parole divine'],
        ),
        'Ange (Convertis)': Archetype(
          name: 'Ange (Convertis)',
          description: 'Ange de la Conversion, spécialisé dans le retour des âmes vers la lumière. Maître de la persuasion et de la rédemption',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 3, 'Perception': 3, 'Présence': 5},
          talents: ['Persuasion', 'Empathie', 'Connaissances religieuses', 'Protection'],
          powers: ['Bénédiction', 'Guérison divine'],
        ),
        'Christophe (Enfants)': Archetype(
          name: 'Christophe (Enfants)',
          description: 'Ange protecteur des Enfants, gardien de l\'innocence et de la pureté. Défenseur des plus vulnérables',
          stats: {'Force': 3, 'Agilité': 4, 'Intelligence': 3, 'Volonté': 4, 'Perception': 4, 'Présence': 3},
          talents: ['Protection', 'Empathie', 'Observation', 'Survie'],
          powers: ['Bénédiction', 'Protection angélique'],
        ),
        'Dominique (Justice)': Archetype(
          name: 'Dominique (Justice)',
          description: 'Ange de la Justice, exécuteur du jugement divin. Implacable dans la recherche de la vérité et de l\'équité',
          stats: {'Force': 4, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 4, 'Perception': 3, 'Présence': 2},
          talents: ['Combat rapproché', 'Intimidation', 'Connaissances religieuses', 'Observation'],
          powers: ['Parole divine', 'Protection angélique'],
        ),
        'Michel (Guerre)': Archetype(
          name: 'Michel (Guerre)',
          description: 'Ange de la Guerre, chef des armées célestes. Guerrier légendaire et stratège incomparable',
          stats: {'Force': 5, 'Agilité': 4, 'Intelligence': 2, 'Volonté': 4, 'Perception': 3, 'Présence': 3},
          talents: ['Combat rapproché', 'Combat à distance', 'Intimidation', 'Résistance physique'],
          powers: ['Protection angélique', 'Guérison divine'],
        ),
        'Novalis (Fleurs)': Archetype(
          name: 'Novalis (Fleurs)',
          description: 'Ange des Fleurs, symbole de beauté et de renaissance. Porteur de paix et de réconciliation',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 3, 'Perception': 4, 'Présence': 4},
          talents: ['Empathie', 'Persuasion', 'Survie', 'Observation'],
          powers: ['Bénédiction', 'Guérison divine'],
        ),
        'Jordi (Animaux)': Archetype(
          name: 'Jordi (Animaux)',
          description: 'Ange des Animaux, protecteur de la nature et des créatures sauvages. Maître de la communication avec le monde animal',
          stats: {'Force': 4, 'Agilité': 4, 'Intelligence': 3, 'Volonté': 4, 'Perception': 4, 'Présence': 2},
          talents: ['Survie', 'Observation', 'Protection', 'Empathie'],
          powers: ['Guérison divine', 'Protection angélique'],
        ),
        'Joseph (Inquisition)': Archetype(
          name: 'Joseph (Inquisition)',
          description: 'Ange de l\'Inquisition, chasseur d\'hérétiques et de démons. Inquisiteur implacable et purificateur',
          stats: {'Force': 4, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 5, 'Perception': 3, 'Présence': 2},
          talents: ['Intimidation', 'Combat rapproché', 'Connaissances religieuses', 'Observation'],
          powers: ['Parole divine', 'Protection angélique'],
        ),
        'Laurent (Épée)': Archetype(
          name: 'Laurent (Épée)',
          description: 'Ange de l\'Épée, guerrier céleste et défenseur de la foi. Maître du combat et de la stratégie militaire',
          stats: {'Force': 5, 'Agilité': 4, 'Intelligence': 3, 'Volonté': 4, 'Perception': 3, 'Présence': 2},
          talents: ['Combat rapproché', 'Combat à distance', 'Protection', 'Résistance physique'],
          powers: ['Protection angélique', 'Guérison divine', 'Parole divine'],
        ),
        'Yves (Sources)': Archetype(
          name: 'Yves (Sources)',
          description: 'Ange des Sources, gardien du savoir et de la connaissance. Archiviste divin et maître de l\'information',
          stats: {'Force': 2, 'Agilité': 2, 'Intelligence': 5, 'Volonté': 3, 'Perception': 5, 'Présence': 3},
          talents: ['Connaissances religieuses', 'Connaissances occultes', 'Observation', 'Informatique'],
          powers: ['Vision céleste', 'Parole divine'],
        ),
        'Walther (Exorcistes)': Archetype(
          name: 'Walther (Exorcistes)',
          description: 'Ange des Exorcistes, spécialiste de la purification et de l\'expulsion des démons. Maître des rituels de bannissement',
          stats: {'Force': 3, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 5, 'Perception': 4, 'Présence': 2},
          talents: ['Connaissances religieuses', 'Connaissances occultes', 'Intimidation', 'Résistance mentale'],
          powers: ['Parole divine', 'Bénédiction', 'Protection angélique'],
        ),
        'Didier (Communication)': Archetype(
          name: 'Didier (Communication)',
          description: 'Ange de la Communication, maître des médias et de l\'information. Porteur de messages et de nouvelles',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 3, 'Perception': 3, 'Présence': 5},
          talents: ['Persuasion', 'Informatique', 'Observation', 'Discrétion'],
          powers: ['Parole divine', 'Vision céleste'],
        ),
        'Francis (Diplomatie)': Archetype(
          name: 'Francis (Diplomatie)',
          description: 'Ange de la Diplomatie, négociateur et médiateur. Spécialiste de la résolution pacifique des conflits',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 3, 'Perception': 3, 'Présence': 5},
          talents: ['Persuasion', 'Empathie', 'Connaissances religieuses', 'Discrétion'],
          powers: ['Bénédiction', 'Parole divine'],
        ),
        'Marc (Échanges)': Archetype(
          name: 'Marc (Échanges)',
          description: 'Ange des Échanges, facilitateur de commerce et de transactions. Maître de la négociation et du troc',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 3, 'Perception': 3, 'Présence': 4},
          talents: ['Persuasion', 'Observation', 'Informatique', 'Discrétion'],
          powers: ['Bénédiction', 'Parole divine'],
        ),
        'Janus (Vents)': Archetype(
          name: 'Janus (Vents)',
          description: 'Ange des Vents, maître de la mobilité et du voyage. Porteur de messages et de nouvelles',
          stats: {'Force': 3, 'Agilité': 5, 'Intelligence': 3, 'Volonté': 3, 'Perception': 4, 'Présence': 2},
          talents: ['Conduite', 'Survie', 'Observation', 'Discrétion'],
          powers: ['Vision céleste', 'Bénédiction'],
        ),
        'Jean (Foudre)': Archetype(
          name: 'Jean (Foudre)',
          description: 'Ange de la Foudre, maître de l\'énergie et de la puissance. Porteur de la colère divine',
          stats: {'Force': 4, 'Agilité': 4, 'Intelligence': 3, 'Volonté': 4, 'Perception': 3, 'Présence': 2},
          talents: ['Combat à distance', 'Intimidation', 'Observation', 'Informatique'],
          powers: ['Protection angélique', 'Parole divine'],
        ),
        'Alain (Cultures)': Archetype(
          name: 'Alain (Cultures)',
          description: 'Ange des Cultures, protecteur des arts et des traditions. Gardien du patrimoine et de la diversité',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 3, 'Perception': 4, 'Présence': 4},
          talents: ['Connaissances religieuses', 'Empathie', 'Observation', 'Persuasion'],
          powers: ['Bénédiction', 'Guérison divine'],
        ),
        'Daniel (Pierre)': Archetype(
          name: 'Daniel (Pierre)',
          description: 'Ange de la Pierre, maître de la construction et de la stabilité. Gardien des fondations et des structures',
          stats: {'Force': 4, 'Agilité': 2, 'Intelligence': 3, 'Volonté': 4, 'Perception': 3, 'Présence': 2},
          talents: ['Protection', 'Résistance physique', 'Observation', 'Survie'],
          powers: ['Protection angélique', 'Bénédiction'],
        ),
        'Catherine (Femmes)': Archetype(
          name: 'Catherine (Femmes)',
          description: 'Ange des Femmes, protecteur de la féminité et de l\'égalité. Défenseur des droits et de la dignité',
          stats: {'Force': 3, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 4, 'Perception': 3, 'Présence': 4},
          talents: ['Protection', 'Empathie', 'Persuasion', 'Connaissances religieuses'],
          powers: ['Bénédiction', 'Guérison divine'],
        ),
        'Gabriel (Feu)': Archetype(
          name: 'Gabriel (Feu)',
          description: 'Ange du Feu, porteur de lumière et de purification. Maître de la transformation et du renouveau',
          stats: {'Force': 4, 'Agilité': 3, 'Intelligence': 3, 'Volonté': 4, 'Perception': 3, 'Présence': 3},
          talents: ['Combat rapproché', 'Intimidation', 'Protection', 'Résistance physique'],
          powers: ['Protection angélique', 'Guérison divine'],
        ),
        'Georges (Purification)': Archetype(
          name: 'Georges (Purification)',
          description: 'Ange de la Purification, nettoyeur et purificateur. Spécialiste de l\'élimination des souillures',
          stats: {'Force': 3, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 4, 'Perception': 4, 'Présence': 2},
          talents: ['Connaissances religieuses', 'Observation', 'Protection', 'Résistance mentale'],
          powers: ['Bénédiction', 'Protection angélique'],
        ),
        'Guy (Guérisseurs)': Archetype(
          name: 'Guy (Guérisseurs)',
          description: 'Ange des Guérisseurs, maître de la médecine et de la réparation. Porteur de soins et de réconfort',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 4, 'Volonté': 3, 'Perception': 3, 'Présence': 4},
          talents: ['Médecine', 'Empathie', 'Observation', 'Protection'],
          powers: ['Guérison divine', 'Bénédiction'],
        ),
        'Jean-Luc (Protecteurs)': Archetype(
          name: 'Jean-Luc (Protecteurs)',
          description: 'Ange des Protecteurs, gardien et défenseur. Spécialiste de la protection et de la défense',
          stats: {'Force': 4, 'Agilité': 3, 'Intelligence': 3, 'Volonté': 4, 'Perception': 4, 'Présence': 3},
          talents: ['Protection', 'Combat rapproché', 'Observation', 'Empathie'],
          powers: ['Protection angélique', 'Bénédiction'],
        ),
        'Emmanuel (Double Jeu)': Archetype(
          name: 'Emmanuel (Double Jeu)',
          description: 'Ange du Double Jeu, maître de l\'infiltration et de l\'espionnage. Spécialiste de la dissimulation',
          stats: {'Force': 2, 'Agilité': 4, 'Intelligence': 4, 'Volonté': 3, 'Perception': 4, 'Présence': 3},
          talents: ['Discrétion', 'Observation', 'Persuasion', 'Connaissances occultes'],
          powers: ['Vision céleste', 'Parole divine'],
        ),
        'Mathias (Confusion)': Archetype(
          name: 'Mathias (Confusion)',
          description: 'Ange de la Confusion, maître du chaos et de la désinformation. Spécialiste de la manipulation de l\'information',
          stats: {'Force': 2, 'Agilité': 3, 'Intelligence': 5, 'Volonté': 3, 'Perception': 4, 'Présence': 2},
          talents: ['Connaissances occultes', 'Discrétion', 'Observation', 'Informatique'],
          powers: ['Parole divine', 'Vision céleste'],
        ),
      },

    };
  }
  // Éditions INS/MV
  static List<GameEdition> _getINSMVEditions() {
    return [
      GameEdition(
        id: 'ins-mv-v1',
        name: 'INS/MV v1',
        year: '1997',
        description: 'Première édition du jeu',
        statNames: ['Force', 'Agilité', 'Intelligence', 'Volonté', 'Perception', 'Présence'],
        defaultStats: {'Force': 3, 'Agilité': 3, 'Intelligence': 3, 'Volonté': 3, 'Perception': 3, 'Présence': 3},
        archetypes: _getINSMVArchetypesV1(),
      ),
    ];
  }

  // Agone (système simplifié)
  static GameSystem _getAgoneSystem() {
    return GameSystem(
      id: 'agone',
      name: 'Agone',
      description: 'Jeu de rôle médiéval-fantastique',
      characterTypes: ['Humain', 'Demi-Dieu'],
      superiors: {
        'Humain': ['Indépendant'],
        'Demi-Dieu': ['Indépendant'],
      },
      availableTalents: ['Combat', 'Magie', 'Diplomatie'],
      powers: {
        'Humain': [],
        'Demi-Dieu': [PowerTemplate(name: 'Pouvoir divin', costPP: 2)],
      },
      competences: ['Combat', 'Magie'],
      playerPoints: 20,
      npcPoints: 15,
      minStatValue: 1,
      maxStatValue: 6,
      editions: [
        GameEdition(
          id: 'agone-v1',
          name: 'Agone v1',
          year: '1999',
          description: 'Première édition',
          statNames: ['Corps', 'Âme', 'Esprit', 'Rêve'],
          defaultStats: {'Corps': 5, 'Âme': 5, 'Esprit': 5, 'Rêve': 5},
          archetypes: {},
        ),
      ],
    );
  }

  // Prophecy (système simplifié)
  static GameSystem _getProphecySystem() {
    return GameSystem(
      id: 'prophecy',
      name: 'Prophecy',
      description: 'Jeu de rôle fantasy',
      characterTypes: ['Humain', 'Elfe', 'Nain'],
      superiors: {
        'Humain': ['Indépendant'],
        'Elfe': ['Indépendant'],
        'Nain': ['Indépendant'],
      },
      availableTalents: ['Combat', 'Magie', 'Furtivité'],
      powers: {
        'Humain': [],
        'Elfe': [PowerTemplate(name: 'Magie elfique', costPP: 2)],
        'Nain': [PowerTemplate(name: 'Résistance', costPP: 1)],
      },
      competences: ['Combat', 'Magie'],
      playerPoints: 18,
      npcPoints: 14,
      minStatValue: 1,
      maxStatValue: 6,
      editions: [
        GameEdition(
          id: 'prophecy-v1',
          name: 'Prophecy v1',
          year: '2000',
          description: 'Première édition',
          statNames: ['Force', 'Dextérité', 'Constitution', 'Intelligence', 'Sagesse', 'Charisme'],
          defaultStats: {'Force': 3, 'Dextérité': 3, 'Constitution': 3, 'Intelligence': 3, 'Sagesse': 3, 'Charisme': 3},
          archetypes: {},
        ),
      ],
    );
  }

  // D&D (système simplifié)
  static GameSystem _getDnDSystem() {
    return GameSystem(
      id: 'dnd',
      name: 'D&D',
      description: 'Dungeons & Dragons',
      characterTypes: ['Humain', 'Elfe', 'Nain', 'Halfelin'],
      superiors: {
        'Humain': ['Indépendant'],
        'Elfe': ['Indépendant'],
        'Nain': ['Indépendant'],
        'Halfelin': ['Indépendant'],
      },
      availableTalents: ['Combat', 'Magie', 'Furtivité', 'Diplomatie'],
      powers: {
        'Humain': [],
        'Elfe': [PowerTemplate(name: 'Magie', costPP: 2)],
        'Nain': [PowerTemplate(name: 'Résistance', costPP: 1)],
        'Halfelin': [PowerTemplate(name: 'Chance', costPP: 1)],
      },
      competences: ['Combat', 'Magie', 'Furtivité'],
      playerPoints: 20,
      npcPoints: 15,
      minStatValue: 1,
      maxStatValue: 6,
      editions: [
        GameEdition(
          id: 'dnd-5e',
          name: 'D&D 5e',
          year: '2014',
          description: 'Cinquième édition',
          statNames: ['Force', 'Dextérité', 'Constitution', 'Intelligence', 'Sagesse', 'Charisme'],
          defaultStats: {'Force': 3, 'Dextérité': 3, 'Constitution': 3, 'Intelligence': 3, 'Sagesse': 3, 'Charisme': 3},
          archetypes: {},
        ),
      ],
    );
  }
}
