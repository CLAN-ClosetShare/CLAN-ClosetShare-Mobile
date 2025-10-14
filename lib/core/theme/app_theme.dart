import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFFFC107);
  static const Color secondaryVariant = Color(0xFFFFA000);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53E3E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB3B3B3);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryColor),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceColor,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: darkSurfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryColor),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
