import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1A60EB); // Vibrant Sky Blue for buttons/primary actions (Duolingo style)
  static const Color primaryLight = Color(0xFFEBF2FF); // Light blue tint
  static const Color secondaryOrange = Color(0xFFF97316); // Saffron/Orange accent
  static const Color accentYellow = Color(0xFFFFB300); // Coin/Star Yellow
  static const Color successGreen = Color(0xFF10B981); // Completed/Correct Green
  static const Color errorRed = Color(0xFFEF4444); // Incorrect/Red alert

  // Neutral colors - Light Mode
  static const Color lightBg = Color(0xFFEFF6FF); // Soft Light Blue Background Tint
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Neutral colors - Dark Mode
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Custom shadows
  static List<BoxShadow> premiumShadow({bool isDark = false}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.3)
            : const Color(0xFF000000).withOpacity(0.04),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.1)
            : const Color(0xFF3B82F6).withOpacity(0.02),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // Soft Glassmorphism Border decoration
  static BoxDecoration glassCardDecoration({
    required BuildContext context,
    double radius = 24,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? darkCard.withOpacity(0.8) : lightCard.withOpacity(0.8),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? darkBorder.withOpacity(0.5)
            : lightBorder.withOpacity(0.8),
        width: 1.5,
      ),
      boxShadow: premiumShadow(isDark: isDark),
    );
  }

  // Test-friendly Google Font Wrapper
  static TextStyle outfit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Test-friendly TextTheme Generator
  static TextTheme _getTextTheme({required bool isDark}) {
    final Color txtColor = isDark ? darkTextPrimary : lightTextPrimary;
    final Color secColor = isDark ? darkTextSecondary : lightTextSecondary;
    final Color accent = secondaryOrange;

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: accent),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accent),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: accent),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: txtColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: txtColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: secColor),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryBlue),
      );
    }

    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: accent),
      displayMedium: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: accent),
      titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: accent),
      titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: txtColor),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.normal, color: txtColor),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.normal, color: secColor),
      labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: primaryBlue),
    );
  }

  // Main themes
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      dividerColor: lightBorder,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryOrange,
        tertiary: accentYellow,
        surface: lightCard,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: _getTextTheme(isDark: false),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryBlue.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: outfit(color: lightTextSecondary, fontSize: 15),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkBorder,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: secondaryOrange,
        tertiary: accentYellow,
        surface: darkCard,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: _getTextTheme(isDark: true),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: darkBorder, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: outfit(color: darkTextSecondary, fontSize: 15),
      ),
    );
  }
}
