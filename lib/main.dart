import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/character_provider.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'dart:developer' as developer;

void main() async {
  developer.log(('🚀 [MAIN] Démarrage de l\'application...').toString());
  WidgetsFlutterBinding.ensureInitialized();
  developer.log(('✅ [MAIN] WidgetsFlutterBinding initialisé').toString());
  
  try {
    developer.log(('💾 [MAIN] Initialisation de SharedPreferences...').toString());
    final prefs = await SharedPreferences.getInstance();
    developer.log(('✅ [MAIN] SharedPreferences initialisé').toString());
    
    developer.log(('🎮 [MAIN] Lancement de l\'application...').toString());
    runApp(MyApp(prefs: prefs));
    developer.log(('✅ [MAIN] Application lancée').toString());
  } catch (e) {
    developer.log(('❌ [MAIN] Erreur lors de l\'initialisation: $e').toString());
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
      ],
      child: MaterialApp(
        title: 'Générateur de Personnages JDR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
