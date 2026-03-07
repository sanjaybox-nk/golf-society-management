import 'package:flutter/material.dart';

class AppTypography {
  // Brand v3.1 Typography System

  // 0. Base Sizes
  static const double sizeDisplayHero = 64.0;
  static const double sizeDisplayLarge = 44.0;
  static const double sizeDisplayMedium = 32.0;
  static const double sizeDisplaySmall = 26.0;
  static const double sizeDisplayTitle = 40.0;
  static const double sizeDisplayPage = 34.0;
  static const double sizeDisplayHeading = 28.0;
  static const double sizeDisplayLocker = 24.0;
  static const double sizeDisplaySubPage = 22.0;
  static const double sizeDisplaySection = 20.0;
  static const double sizeLargeBody = 18.0;
  static const double sizeUI = 17.0;
  static const double sizeBody = 16.0;
  static const double sizeButton = 15.0;
  static const double sizeBodySmall = 14.0;
  static const double sizeLabelStrong = 13.0;
  static const double sizeLabel = 12.0;
  static const double sizeCaptionStrong = 11.0;
  static const double sizeCaption = 10.0;
  static const double sizeMicro = 10.0;
  static const double sizeMicroSmall = 9.0;
  static const double sizeNano = 8.0;

  // 0.5 Font Weights
  static const FontWeight weightBlack = FontWeight.w900;
  static const FontWeight weightExtraBold = FontWeight.w800;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightRegular = FontWeight.w400;

  // 1. Display (Syne - Expressive)
  // Usage: Massive marketing numbers or "Hero" stats.
  static const TextStyle displayHero = TextStyle(
    fontFamily: 'Syne',
    fontSize: sizeDisplayHero,
    fontWeight: weightExtraBold,
    letterSpacing: -2.0,
    height: 1.0,
  );

  // Usage: Main editorial titles (e.g., Login welcome).
  static const TextStyle displayTitle = TextStyle(
    fontFamily: 'Syne',
    fontSize: sizeDisplayTitle,
    fontWeight: weightExtraBold,
    letterSpacing: -1.8,
    height: 1.0,
  );

  // Usage: Primary Page Header (scrolling titles in HeadlessScaffold).
  static const TextStyle displayPage = TextStyle(
    fontFamily: 'Syne',
    fontSize: sizeDisplayPage,
    fontWeight: weightBlack,
    letterSpacing: -1.8,
    height: 1.0,
  );

  // Usage: Standard section headers within a page.
  static const TextStyle displayHeading = TextStyle(
    fontFamily: 'Syne',
    fontSize: sizeDisplayHeading,
    fontWeight: weightBold,
    letterSpacing: -1.0,
    height: 1.0,
  );

  // Usage: Specialized locker room or large numeric headers (24px).
  static const TextStyle displayLocker = TextStyle(
    fontFamily: 'Syne',
    fontSize: sizeDisplayLocker,
    fontWeight: weightExtraBold,
    letterSpacing: -0.8,
    height: 1.1,
  );

  // Usage: Secondary page titles or deep-linked headers (22px).
  static const TextStyle displaySubPage = TextStyle(
    fontFamily: 'Syne',
    fontSize: sizeDisplaySubPage,
    fontWeight: weightExtraBold,
    letterSpacing: -0.6,
    height: 1.1,
  );

  // Usage: Standard section headers or prominent card titles (20px).
  static const TextStyle displaySection = TextStyle(
    fontFamily: 'Syne',
    fontSize: sizeDisplaySection,
    fontWeight: weightBold,
    letterSpacing: -0.5,
    height: 1.1,
  );

  // Usage: High-emphasis prominence body or prominent numeric labels (18px).
  static const TextStyle displayLargeBody = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeLargeBody,
    fontWeight: weightBold,
    letterSpacing: -0.2,
    height: 1.2,
  );

  // Usage: Specialized tactical UI headers (17px).
  static const TextStyle displayUI = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeUI,
    fontWeight: weightSemibold,
    letterSpacing: -0.2,
    height: 1.2,
  );

  // 2. Body (Plus Jakarta Sans - Functional)
  // Usage: Primary reading content (default size).
  static const TextStyle body = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeBody,
    fontWeight: weightMedium,
    letterSpacing: 0,
    height: 1.5,
  );

  // Usage: Secondary text, descriptions, and list items (14px).
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeBodySmall,
    fontWeight: weightMedium,
    letterSpacing: 0,
    height: 1.5,
  );

  // 3. Label & UI (Plus Jakarta Sans - Precise)
  // Usage: Emphasis metadata, bolded list items (13px).
  static const TextStyle labelStrong = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeLabelStrong,
    fontWeight: weightBold,
    letterSpacing: 0,
    height: 1.2,
  );

  // Usage: Input labels, navigation items, and small tactical markers (12px).
  static const TextStyle label = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeLabel,
    fontWeight: weightBold,
    letterSpacing: 1.0,
    height: 1.0,
  );

  // 4. Semantic Helpers (v3.1)
  // Usage: Explanatory subtext or hints.
  static const TextStyle subtext = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeBodySmall,
    fontWeight: weightMedium,
    letterSpacing: 0,
    height: 1.5,
  );

  // Usage: Technical helpers and UI metadata.
  static const TextStyle helper = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: AppTypography.sizeLabel,
    fontWeight: weightSemibold,
    letterSpacing: 0,
    height: 1.0,
  );

  // Usage: Prominent specialized micro-copy (11px).
  static const TextStyle captionStrong = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeCaptionStrong,
    fontWeight: weightBold,
    letterSpacing: 0.2,
    height: 1.1,
  );

  // Usage: Captions, small badge text, and copyright info (10px).
  static const TextStyle caption = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeCaption,
    fontWeight: weightSemibold,
    letterSpacing: 0.5,
    height: 1.0,
  );

  // Usage: Micro-UI markers (e.g. badge labels, multi-day date segments).
  static const TextStyle micro = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeMicro,
    fontWeight: weightBold,
    height: 1.0,
  );

  // Usage: Extreme small text (v3.1 legacy support or dense data) (9px).
  static const TextStyle microSmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeMicroSmall,
    fontWeight: weightExtraBold,
    height: 1.0,
  );

  // Usage: Tactical markers for dense scoring grids (8px).
  static const TextStyle nano = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeNano,
    fontWeight: weightExtraBold,
    height: 1.0,
  );

  // Usage: Primary and secondary button text (15px).
  static const TextStyle button = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeButton,
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
