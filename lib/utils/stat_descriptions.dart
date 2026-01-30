import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Descriptions des caractéristiques principales pour les bulles d'information
/// (utile pour les joueurs qui débutent en jeu de rôle).
class StatDescriptions {
  StatDescriptions._();

  /// Carte nom français → clé de traduction pour le nom affiché.
  static const Map<String, String> _nameToKey = {
    'Force': 'stat_force', 'Agilité': 'stat_agilite', 'Volonté': 'stat_volonte',
    'Perception': 'stat_perception', 'Présence': 'stat_presence', 'Intelligence': 'stat_intelligence',
    'Rêve': 'stat_reve', 'Empathie': 'stat_empathie', 'Intuition': 'stat_intuition',
    'Apparence': 'stat_apparence', 'Corps': 'stat_corps', 'Âme': 'stat_ame', 'Esprit': 'stat_esprit',
    'Dextérité': 'stat_dexterite', 'Constitution': 'stat_constitution', 'Sagesse': 'stat_sagesse', 'Charisme': 'stat_charisme',
  };

  /// Carte nom français → clé de traduction pour la description (bulle d'aide).
  static const Map<String, String> _nameToDescKey = {
    'Force': 'stat_desc_force', 'Agilité': 'stat_desc_agilite', 'Volonté': 'stat_desc_volonte',
    'Perception': 'stat_desc_perception', 'Présence': 'stat_desc_presence', 'Intelligence': 'stat_desc_intelligence',
    'Rêve': 'stat_desc_reve', 'Empathie': 'stat_desc_empathie', 'Intuition': 'stat_desc_intuition',
    'Apparence': 'stat_desc_apparence', 'Corps': 'stat_desc_corps', 'Âme': 'stat_desc_ame', 'Esprit': 'stat_desc_esprit',
    'Dextérité': 'stat_desc_dexterite', 'Constitution': 'stat_desc_constitution', 'Sagesse': 'stat_desc_sagesse', 'Charisme': 'stat_desc_charisme',
  };

  static const Map<String, String> _descriptions = {
    'Force': 'Capacité physique, musculation, portée et dégâts en mêlée.',
    'Agilité': 'Dextérité, réflexes, coordination, esquive et précision.',
    'Intelligence': 'Raisonnement, logique, mémoire et connaissances.',
    'Volonté': 'Résistance mentale, détermination, résistance aux influences.',
    'Perception': 'Vigilance, sens aiguisés, repérage et lecture des situations.',
    'Présence': 'Charisme, impact social, autorité et capacité à impressionner.',
    'Rêve': 'Lien avec l\'onirique, intuition créative et imagination (éditions récentes INS/MV).',
    'Empathie': 'Ressenti des émotions d\'autrui, lien avec les autres et compréhension (éd. INS/MV).',
    'Intuition': 'Pressentiment, lecture des situations et flair (éditions INS/MV).',
    'Corps': 'Vigueur physique, santé et résistance aux blessures.',
    'Âme': 'Force spirituelle et résistance aux influences surnaturelles.',
    'Esprit': 'Intellect, raison et facultés mentales.',
    'Dextérité': 'Adresse, réflexes et précision (équivalent Agilité).',
    'Constitution': 'Endurance, résistance physique et santé.',
    'Sagesse': 'Perception, intuition et force de caractère.',
    'Charisme': 'Force de personnalité, influence et présence.',
    'Apparence': 'Aspect physique et première impression.',
  };

  /// Retourne le nom traduit de la caractéristique pour l'affichage.
  static String getTranslatedName(BuildContext context, String statName) {
    final key = _nameToKey[statName];
    if (key == null) return statName;
    return AppLocalizations.trSafe(context, key);
  }

  /// Retourne la description traduite pour la bulle d'aide.
  static String getTranslatedDescription(BuildContext context, String statName) {
    final key = _nameToDescKey[statName];
    if (key == null) return AppLocalizations.trSafe(context, 'stat_desc_default');
    return AppLocalizations.trSafe(context, key);
  }

  /// Retourne la description d'une caractéristique, ou null si inconnue.
  static String? get(String statName) => _descriptions[statName];

  /// Retourne la description ou une phrase par défaut (sans traduction).
  static String getOrDefault(String statName) =>
      _descriptions[statName] ?? 'Caractéristique du personnage.';
}
