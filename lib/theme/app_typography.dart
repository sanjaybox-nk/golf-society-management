import 'package:flutter/material.dart';

class AppTypography {
  // Brand v3.1 Typography System

  // 1. Display (Syne - Expressive)
  static const TextStyle displayHero = TextStyle(
    fontFamily: 'Syne',
    fontSize: 64,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    height: 1.0,
  );

  static const TextStyle displayTitle = TextStyle(
    fontFamily: 'Syne',
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.0,
  );

  static const TextStyle displayHeading = TextStyle(
    fontFamily: 'Syne',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.0,
  );

  // 2. Body (Plus Jakarta Sans - Functional)
  static const TextStyle body = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  // 3. Label & UI (Inter / Plus Jakarta Sans - Precise)
  static const TextStyle label = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1.0,
  );

  // 4. Semantic Helpers (v3.1)
  static const TextStyle subtext = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle helper = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.0,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
    height: 1.0,
  );

  // Legacy & Compatibility Layer
  static String get uiFont => 'Plus Jakarta Sans';
  static TextStyle get displayMedium => displayTitle;
  
  static TextTheme createTextTheme() => textTheme;

  // Mapped TextTheme for Flutter
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: displayHero,
      displayMedium: displayTitle,
      displaySmall: displayHeading,
      bodyLarge: body,
      bodyMedium: bodySmall,
      labelLarge: button,
      labelMedium: label,
      labelSmall: caption,
    );
  }
}
