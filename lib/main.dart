import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/character_provider.dart';
import 'providers/game_provider.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'l10n/translations.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'dart:developer' as developer;

void main() async {
  developer.log(('🚀 [MAIN] Démarrage de l\'application...').toString());
  WidgetsFlutterBinding.ensureInitialized();

  // Afficher l'erreur réelle sur l'écran rouge pour pouvoir la copier
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.red.shade900,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ERREUR (copiez ce texte)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: SelectableText(
                    '${details.exception}\n\n${details.stack?.toString() ?? ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  try {
    developer.log(('💾 [MAIN] Initialisation de SharedPreferences...').toString());
    final prefs = await SharedPreferences.getInstance();
    developer.log(('✅ [MAIN] SharedPreferences initialisé').toString());

    developer.log(('🎮 [MAIN] Lancement de l\'application...').toString());
    runApp(MyApp(prefs: prefs));
    developer.log(('✅ [MAIN] Application lancée').toString());
  } catch (e, stack) {
    developer.log(('❌ [MAIN] Erreur lors de l\'initialisation: $e\n$stack').toString());
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    developer.log(('🎨 [MAIN] Construction de MyApp').toString());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider(prefs)),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          final locale = localeProvider.locale;
          final supported = AppTranslations.supportedLocales;
          return MaterialApp(
            title: 'ManyFaces',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: locale,
            supportedLocales: supported,
            localeResolutionCallback: (Locale? requested, Iterable<Locale> supportedLocales) {
              if (requested != null) {
                for (final l in supportedLocales) {
                  if (l.languageCode == requested.languageCode) return l;
                }
              }
              return supportedLocales.first;
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
