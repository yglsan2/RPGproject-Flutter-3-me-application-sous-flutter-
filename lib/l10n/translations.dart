import 'package:flutter/material.dart';
import 'strings_fr.dart';
import 'strings_en.dart';
import 'strings_de.dart';
import 'strings_es.dart';
import 'strings_it.dart';
import 'strings_zh.dart';
import 'strings_ko.dart';
import 'strings_lv.dart';
import 'strings_uk.dart';
import 'strings_ar.dart';
import 'strings_sv.dart';
import 'strings_pt.dart';
import 'strings_hi.dart';
import 'strings_ja.dart';
import 'strings_th.dart';

abstract class AppTranslations {
  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('it'),
    Locale('zh'),
    Locale('ko'),
    Locale('lv'),
    Locale('uk'),
    Locale('ar'),
    Locale('sv'),
    Locale('pt'),
    Locale('hi'),
    Locale('ja'),
    Locale('th'),
  ];

  static const Map<String, String> localeToFlag = {
    'fr': '🇫🇷',
    'en': '🇬🇧',
    'de': '🇩🇪',
    'es': '🇪🇸',
    'it': '🇮🇹',
    'zh': '🇨🇳',
    'ko': '🇰🇷',
    'lv': '🇱🇻',
    'uk': '🇺🇦',
    'ar': '🇸🇦',
    'sv': '🇸🇪',
    'pt': '🇵🇹',
    'hi': '🇮🇳',
    'ja': '🇯🇵',
    'th': '🇹🇭',
  };

  static const Map<String, String> localeToName = {
    'fr': 'Français',
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Español',
    'it': 'Italiano',
    'zh': '中文',
    'ko': '한국어',
    'lv': 'Latviešu',
    'uk': 'Українська',
    'ar': 'العربية',
    'sv': 'Svenska',
    'pt': 'Português',
    'hi': 'हिन्दी',
    'ja': '日本語',
    'th': 'ไทย',
  };

  static Map<String, String> stringsFor(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return stringsEn;
      case 'de':
        return stringsDe;
      case 'es':
        return stringsEs;
      case 'it':
        return stringsIt;
      case 'zh':
        return stringsZh;
      case 'ko':
        return stringsKo;
      case 'lv':
        return stringsLv;
      case 'uk':
        return stringsUk;
      case 'ar':
        return stringsAr;
      case 'sv':
        return stringsSv;
      case 'pt':
        return stringsPt;
      case 'hi':
        return stringsHi;
      case 'ja':
        return stringsJa;
      case 'th':
        return stringsTh;
      case 'fr':
      default:
        return stringsFr;
    }
  }
}
