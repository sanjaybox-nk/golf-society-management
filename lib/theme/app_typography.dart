import 'package:flutter/material.dart';

class AppTypography {
  // Brand v3.1 Typography System

  // 1. Display (Syne - Expressive)
  // Usage: Massive marketing numbers or "Hero" stats.
  static const TextStyle displayHero = TextStyle(
    fontFamily: 'Syne',
    fontSize: 64,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    height: 1.0,
  );

  // Usage: Main editorial titles (e.g., Login welcome).
  static const TextStyle displayTitle = TextStyle(
    fontFamily: 'Syne',
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.8,
    height: 1.0,
  );

  // Usage: Primary Page Header (scrolling titles in HeadlessScaffold).
  static const TextStyle displayPage = TextStyle(
    fontFamily: 'Syne',
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.8,
    height: 1.0,
  );

  // Usage: Standard section headers within a page.
  static const TextStyle displayHeading = TextStyle(
    fontFamily: 'Syne',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.0,
  );

  // Usage: Secondary headers or prominent card titles.
  static const TextStyle displaySection = TextStyle(
    fontFamily: 'Syne',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  // 2. Body (Plus Jakarta Sans - Functional)
  // Usage: Primary reading content (default size).
  static const TextStyle body = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  // Usage: Secondary text, descriptions, and list items.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  // 3. Label & UI (Inter / Plus Jakarta Sans - Precise)
  // Usage: Input labels, navigation items, and small tactical markers.
  static const TextStyle label = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1.0,
  );

  // 4. Semantic Helpers (v3.1)
  // Usage: Explanatory subtext or hints.
  static const TextStyle subtext = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  // Usage: Technical helpers and UI metadata.
  static const TextStyle helper = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.0,
  );

  // Usage: Captions, small badge text, and copyright info.
  static const TextStyle caption = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  // Usage: Micro-UI markers (e.g. badge labels, multi-day date segments).
  static const TextStyle micro = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  // Usage: Extreme small text (v3.1 legacy support or dense data).
  static const TextStyle microSmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 9,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  // Usage: Primary and secondary button text.
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
      headlineMedium: displayPage,
      headlineSmall: displaySection,
      bodyLarge: body,
      bodyMedium: bodySmall,
      labelLarge: button,
      labelMedium: label,
      labelSmall: caption,
    );
  }
}
