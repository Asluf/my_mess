import 'package:flutter/material.dart';

// Dark Mode Theme
ThemeData darkModeTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF212121),
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
    secondary: const Color(0xFFFFA726), // Replaces accentColor
    surface: const Color(0xFF1E1E1E),
    onSurface: const Color(0xFFE0E0E0),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: const Color(0xFF404040),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Color(0xFFFFFFFF)),
    displayMedium: TextStyle(color: Color(0xFFFFFFFF)),
    displaySmall: TextStyle(color: Color(0xFFFFFFFF)),
    headlineLarge: TextStyle(color: Color(0xFFFFFFFF)),
    headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
    headlineSmall: TextStyle(color: Color(0xFFFFFFFF)),
    titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
    titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
    titleSmall: TextStyle(color: Color(0xFFFFFFFF)),
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
    bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
    bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
    labelLarge: TextStyle(color: Color(0xFFE0E0E0)),
    labelMedium: TextStyle(color: Color(0xFFB0B0B0)),
    labelSmall: TextStyle(color: Color(0xFFB0B0B0)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFFA726)),
);

// Sunny Citrus Theme
ThemeData sunnyCitrusTheme = ThemeData(
  primaryColor: const Color(0xFFFFA726),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange).copyWith(
    secondary: const Color(0xFFFFEB3B), // Replaces accentColor
  ),
  scaffoldBackgroundColor: const Color(0xFFFFF8E1),
  cardColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF424242)), // Replaces bodyText1
    bodyMedium: TextStyle(color: Color(0xFF424242)), // Replaces bodyText2
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFF9800)),
);
