import 'package:flutter/material.dart';

class AppTheme {
  // Theme Colors
  static const Color spaceBlack = Color(0xFF0B0E17);
  static const Color nebulaCard = Color(0xFF161B2E);
  static const Color nebulaCardBorder = Color(0xFF252D47);
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color solarAmber = Color(0xFFFFC107);
  static const Color cosmicPurple = Color(0xFF7C4DFF);
  static const Color starlightWhite = Color(0xFFF0F4F8);
  static const Color starlightMuted = Color(0xFF94A3B8);
  static const Color visibilityGreen = Color(0xFF00E676);

  // Red Night Vision Mode (Astro Mode)
  static const Color astroRedBg = Color(0xFF100000);
  static const Color astroRedCard = Color(0xFF260505);
  static const Color astroRedAccent = Color(0xFFFF3333);
  static const Color astroRedText = Color(0xFFFF8888);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spaceBlack,
      colorScheme: const ColorScheme.dark(
        primary: electricCyan,
        secondary: solarAmber,
        tertiary: cosmicPurple,
        surface: nebulaCard,
        onSurface: starlightWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: spaceBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: starlightWhite,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: nebulaCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: nebulaCardBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: spaceBlack,
        selectedItemColor: electricCyan,
        unselectedItemColor: starlightMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get astroRedTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: astroRedBg,
      colorScheme: const ColorScheme.dark(
        primary: astroRedAccent,
        secondary: astroRedAccent,
        tertiary: astroRedAccent,
        surface: astroRedCard,
        onSurface: astroRedText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: astroRedBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: astroRedAccent,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: astroRedCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: astroRedAccent, width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: astroRedBg,
        selectedItemColor: astroRedAccent,
        unselectedItemColor: astroRedText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
