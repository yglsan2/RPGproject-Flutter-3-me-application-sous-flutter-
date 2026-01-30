import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/translations.dart';

const String _localeKey = 'app_locale';
const String _defaultLocaleCode = 'fr';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale(_defaultLocaleCode);
  final SharedPreferences _prefs;

  Locale get locale => _locale;

  LocaleProvider(this._prefs) {
    _loadLocale();
  }

  static bool _isSupported(String code) {
    return AppTranslations.supportedLocales.any((l) => l.languageCode == code);
  }

  Future<void> _loadLocale() async {
    try {
      final code = _prefs.getString(_localeKey);
      if (code != null && code.isNotEmpty && _isSupported(code)) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // Garder la locale par défaut en cas d'erreur
    }
  }

  Future<void> setLocale(Locale value) async {
    if (_locale == value) return;
    _locale = value;
    await _prefs.setString(_localeKey, value.languageCode);
    notifyListeners();
  }
}
