import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_flags/country_flags.dart';
import '../l10n/app_localizations.dart';
import '../l10n/translations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

/// Taille minimale recommandée pour les zones tactiles (doigts).
const double kMinTouchTargetSize = 48.0;

/// Code pays ISO pour afficher le drapeau (fromCountryCode est souvent plus fiable que fromLanguageCode).
const Map<String, String> _languageToCountry = {
  'fr': 'FR', 'en': 'GB', 'de': 'DE', 'es': 'ES', 'it': 'IT',
  'zh': 'CN', 'ko': 'KR', 'lv': 'LV', 'uk': 'UA', 'ar': 'SA',
  'sv': 'SE', 'pt': 'PT', 'hi': 'IN', 'ja': 'JP', 'th': 'TH',
};

/// Affiche un sélecteur de langue par drapeaux (grille responsive, zones tactiles 48dp+).
void showLanguageSelector(BuildContext context) {
  final localeProvider = context.read<LocaleProvider>();
  final l10n = AppLocalizations.of(context);
  final title = l10n?.tr('select_language') ?? 'Choisir la langue';

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: AppTheme.medievalGold.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.medievalBronze.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.medievalDarkBrown,
                  ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: _LanguageGrid(
                currentLocale: localeProvider.locale.languageCode,
                onLocaleSelected: (code) {
                  localeProvider.setLocale(Locale(code));
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LanguageGrid extends StatelessWidget {
  final String currentLocale;
  final ValueChanged<String> onLocaleSelected;

  const _LanguageGrid({
    required this.currentLocale,
    required this.onLocaleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final locales = AppTranslations.supportedLocales.map((l) => l.languageCode).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 400;
    final crossAxisCount = isNarrow ? 2 : 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: locales.map((code) {
            final name = AppTranslations.localeToName[code] ?? code;
            final isSelected = currentLocale == code;
            return _LanguageTile(
              code: code,
              name: name,
              isSelected: isSelected,
              onTap: () => onLocaleSelected(code),
            );
          }).toList(),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.medievalGold.withValues(alpha: 0.25)
          : AppTheme.medievalCream.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.medievalGold.withValues(alpha: 0.3),
        highlightColor: AppTheme.medievalGold.withValues(alpha: 0.15),
        child: Container(
          constraints: const BoxConstraints(minHeight: kMinTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.medievalGold : AppTheme.medievalBronze.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
                width: 42,
                child: CountryFlag.fromCountryCode(
                  _languageToCountry[code] ?? code.toUpperCase(),
                  theme: const ImageTheme(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                code.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.medievalDarkBrown,
                      letterSpacing: 0.8,
                    ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: AppTheme.medievalDarkBrown,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton app bar pour ouvrir le sélecteur de langue (icône drapeau / langue).
class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCode = context.watch<LocaleProvider>().locale.languageCode;
    final l10n = AppLocalizations.of(context);
    final tooltip = l10n?.tr('select_language') ?? 'Choisir la langue';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showLanguageSelector(context),
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMinTouchTargetSize,
            minHeight: kMinTouchTargetSize,
          ),
          child: Center(
            child: Tooltip(
              message: tooltip,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 22,
                    width: 34,
                    child: CountryFlag.fromCountryCode(
                      _languageToCountry[localeCode] ?? localeCode.toUpperCase(),
                      theme: const ImageTheme(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    localeCode.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.medievalDarkBrown,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
