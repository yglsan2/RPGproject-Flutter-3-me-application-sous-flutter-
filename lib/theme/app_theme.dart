import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs médiévales-fantastiques
  static const Color medievalGold = Color(0xFFD4AF37);
  static const Color medievalBronze = Color(0xFFCD7F32);
  static const Color medievalBrown = Color(0xFF8B4513);
  static const Color medievalDarkBrown = Color(0xFF5C4033);
  static const Color medievalForest = Color(0xFF2D5016);
  static const Color medievalDark = Color(0xFF1A1A1A);
  static const Color medievalCream = Color(0xFFF5E6D3);
  static const Color medievalRed = Color(0xFF8B0000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: medievalGold,
        brightness: Brightness.light,
        primary: medievalGold,
        secondary: medievalBronze,
        surface: medievalCream,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5E6D3), // Parchemin vieilli
      appBarTheme: AppBarTheme(
        backgroundColor: medievalDarkBrown,
        foregroundColor: medievalGold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: medievalGold,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: medievalGold),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: medievalDarkBrown.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: medievalBronze.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        color: medievalCream,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: medievalBronze, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: medievalBronze, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: medievalGold, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: medievalDarkBrown),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: medievalGold,
          foregroundColor: medievalDarkBrown,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: medievalGold,
        foregroundColor: medievalDarkBrown,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: medievalBronze.withValues(alpha: 0.2),
        selectedColor: medievalGold,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: medievalBronze, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: medievalDarkBrown,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: medievalDarkBrown,
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: medievalDarkBrown,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: medievalDarkBrown,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: medievalGold,
        brightness: Brightness.dark,
        primary: medievalGold,
        secondary: medievalBronze,
        surface: const Color(0xFF2C2416),
      ),
      scaffoldBackgroundColor: const Color(0xFF2A2419), // Parchemin sombre
      appBarTheme: AppBarTheme(
        backgroundColor: medievalDarkBrown,
        foregroundColor: medievalGold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: medievalGold,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: medievalGold),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: medievalGold.withValues(alpha: 0.4), width: 2),
        ),
        color: const Color(0xFF2C2416),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: medievalBronze, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: medievalBronze, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: medievalGold, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF3A3328),
        labelStyle: const TextStyle(color: medievalGold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: medievalGold,
          foregroundColor: medievalDarkBrown,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: medievalGold,
        foregroundColor: medievalDarkBrown,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: medievalBronze.withValues(alpha: 0.3),
        selectedColor: medievalGold,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: medievalBronze, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: medievalGold,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: medievalGold,
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: medievalGold,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: medievalCream,
        ),
      ),
    );
  }
}
