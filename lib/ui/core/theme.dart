import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF10B981); // Emerald
  static const Color primaryLight = Color(0xFF34D399);
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan
  static const Color background = Color(0xFF0B0F19); // Deep Obsidian
  static const Color cardDark = Color(0xFF131B2E); // Elevated Navy
  static const Color cardBorder = Color(0xFF1F2B47);
  static const Color surfaceElevated = Color(0xFF182238);

  // Status Colors
  static const Color dryColor = Color(0xFFEF4444); // Vibrant Red/Amber
  static const Color normalColor = Color(0xFF10B981); // Lush Emerald
  static const Color wetColor = Color(0xFF3B82F6); // Blue

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF141D33), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentCyan,
        surface: cardDark,
        onSurface: Color(0xFFF1F5F9),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
    );
  }
}
