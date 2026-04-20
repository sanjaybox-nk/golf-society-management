import 'package:flutter/material.dart';

class AppTypography {
  // Radical Theme Simplification (BoxyArt v4.0)

  // 0. Consolidated Heights
  static const double sizeDisplay = 30.0;   // Hero headers (Previously 64-32)
  static const double sizeHeadline = 20.0;  // Section headers (Previously 28-20)
  static const double sizeBody = 16.0;      // Primary reading (Previously 18-16)
  static const double sizeLabel = 13.0;     // Secondary metadata (Standardized to 13pt)
  static const double sizeMicro = 10.0;     // Captions & Micro-UI (Previously 11-8)
  static const double sizeMetric = 18.0;    // [NEW] Dashboard metrics

  // Legacy Size Aliases
  static const double sizeLargeDisplay = sizeDisplay;
  static const double sizeBodySmall = sizeLabel;
  static const double sizeLabelStrong = sizeLabel;
  static const double sizeButton = sizeLabel;
  static const double sizeCaption = sizeMicro;
  static const double sizeCaptionStrong = 13.0;
  static const double sizeMicroSmall = sizeMicro;
  static const double sizeLargeBody = sizeHeadline;
  static const double sizeDisplayMedium = sizeDisplay;
  static const double sizeDisplayLocker = sizeHeadline;
  static const double sizeDisplayHeading = sizeHeadline;
  static const double sizeDisplaySection = sizeHeadline;
  static const double sizeDisplaySubPage = sizeHeadline;
  static const double sizeDisplayPage = sizeDisplay;
  static const double sizeDisplayLarge = sizeDisplay;
  static const double sizeDisplaySmall = sizeHeadline;
  static const double sizeUI = sizeLabel;
  static const double sizeNano = sizeMicro;

  // 0.5 Consolidated Weights
  static const FontWeight weightHeavy = FontWeight.w800;   // ExtraBold (Pop Headers)
  static const FontWeight weightBold = FontWeight.w700;    // Bold
  static const FontWeight weightStrong = FontWeight.w600;  // Semibold (Labels/Emphasis)
  static const FontWeight weightRegular = FontWeight.w400; // Regular (Reading)
  static const FontWeight weightLight = FontWeight.w300;   // Light (Elegant Labels)

  // 0.75 Letterspacing Tokens
  static const double lsHero = -0.2;
  static const double lsTight = 0.0;
  static const double lsStandard = 0.2;
  static const double lsLabel = 0.4;
  static const double lsMicro = 0.8;

  // 1. Core Styles
  static const TextStyle display = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeDisplay,
    fontWeight: weightHeavy,
    letterSpacing: lsHero,
    height: 1.0,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeHeadline,
    fontWeight: weightHeavy,
    letterSpacing: lsTight,
    height: 1.1,
  );

  static const TextStyle memberName = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeBody,
    fontWeight: weightStrong,
    letterSpacing: lsTight,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeBody,
    fontWeight: weightMedium,
    letterSpacing: lsStandard,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeLabel,
    fontWeight: weightBold,
    letterSpacing: lsLabel,
    height: 1.2,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeMicro,
    fontWeight: weightBold,
    letterSpacing: lsMicro,
    height: 1.0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeLabel,
    fontWeight: weightMedium,
    letterSpacing: lsStandard,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeMicro,
    fontWeight: weightMedium,
    letterSpacing: lsStandard,
    height: 1.0,
  );

  static const TextStyle metricValue = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeMetric,
    fontWeight: weightHeavy,
    letterSpacing: lsTight,
    height: 1.1,
  );

  static const TextStyle metricLabel = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeMicro,
    fontWeight: weightBold,
    letterSpacing: lsMicro,
    height: 1.0,
  );

  // Specialized styles (Button)
  static const TextStyle button = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: sizeLabel,
    fontWeight: weightHeavy,
    letterSpacing: lsLabel,
    height: 1.0,
  );

  // Legacy & Migration Layer (Aliases to new standard)
  static const TextStyle displayHero = display;
  static const TextStyle displayTitle = display;
  static const TextStyle displayPage = display;
  static const TextStyle displayHeading = headline;
  static const TextStyle displayLocker = headline;
  static const TextStyle displaySubPage = headline;
  static const TextStyle displaySection = headline;
  static const TextStyle displayLargeBody = body;
  static const TextStyle displaySmall = label;
  static const TextStyle labelStrong = label;
  static const TextStyle captionStrong = label;
  static const TextStyle help = caption;
  static const TextStyle helper = caption;
  static const TextStyle microSmall = micro;
  static const TextStyle nano = micro;
  static const TextStyle displayUI = headline;
  static const TextStyle ribbonHeader = label;
  static const TextStyle subtext = label;

  // Migration Weights (Internal helpers)
  static const FontWeight weightBlack = weightHeavy;
  static const FontWeight weightExtraBold = weightHeavy;
  static const FontWeight weightSemibold = weightStrong;
  static const FontWeight weightMedium = FontWeight.w500;

  static String get uiFont => 'Plus Jakarta Sans';
  static TextStyle get displayMedium => display;
  
  static TextTheme createTextTheme() => textTheme;

  static TextStyle get cardTitle => body.copyWith(
    fontWeight: weightBold,
    letterSpacing: 0.2,
    height: 1.1,
  );

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: headline,
      headlineMedium: headline,
      headlineSmall: label,
      bodyLarge: body,
      bodyMedium: label,
      labelLarge: button,
      labelMedium: label,
      labelSmall: micro,
    );
  }
}
