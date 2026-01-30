import 'package:flutter/material.dart';
import 'translations.dart';
import '../data/game_data.dart';

/// Accès aux traductions : AppLocalizations.of(context).tr('key')
/// ou AppLocalizations.of(context)!.tr('key').
class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale) {
    _strings = AppTranslations.stringsFor(locale);
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Retourne la traduction ou la clé si le délégué n'est pas encore chargé (évite le crash au premier frame).
  static String trSafe(BuildContext context, String key, [Map<String, String>? params]) {
    final l10n = of(context);
    return l10n?.tr(key, params) ?? key;
  }

  /// Nom du supérieur traduit (ex. Blandine (Rêves) → ブランディーヌ（夢） en ja). Si pas de clé ou traduction manquante, retourne le nom d'origine.
  static String trSuperiorName(BuildContext context, String superiorName) {
    final key = GameData.getSuperiorNameKey(superiorName);
    if (key == null) return superiorName;
    final t = trSafe(context, key);
    return t != key ? t : superiorName;
  }

  /// Traduction par locale sans BuildContext (pour exports PDF/ODT, etc.).
  static String trWithLocale(Locale locale, String key, [Map<String, String>? params]) {
    final strings = AppTranslations.stringsFor(locale);
    String s = strings[key] ?? key;
    if (params != null) {
      for (final e in params.entries) {
        s = s.replaceAll('{${e.key}}', e.value);
      }
    }
    return s;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String tr(String key, [Map<String, String>? params]) {
    String s = _strings[key] ?? key;
    if (params != null) {
      for (final e in params.entries) {
        s = s.replaceAll('{${e.key}}', e.value);
      }
    }
    return s;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppTranslations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    try {
      return AppLocalizations(locale);
    } catch (_) {
      return AppLocalizations(const Locale('fr'));
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
