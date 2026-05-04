import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Radical Theme Simplification (BoxyArt v4.0)

  // 0. Consolidated Heights
  static const double sizeDisplay = 24.0;   // Hero headers (Updated to 24pt)
  static const double sizeHeadline = 20.0;  // Section headers (Previously 28-20)
  static const double sizeBody = 16.0;      // Primary reading (Previously 18-16)
  static const double sizeLabel = 13.0;     // Secondary metadata (Standardized to 13pt)
  static const double sizeMicro = 11.0;     // Captions & Micro-UI (Refined to 11pt)
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
  static const FontWeight weightBlack = weightHeavy;
  static const FontWeight weightExtraBold = weightHeavy;
  static const FontWeight weightSemibold = weightStrong;
  static const FontWeight weightMedium = FontWeight.w500;

  // 0.75 Letterspacing Tokens
  static const double lsHero = -0.2;
  static const double lsTight = 0.0;
  static const double lsStandard = 0.2;
  static const double lsLabel = 1.0;
  static const double lsMicro = 1.0;

  static String uiFont = 'Plus Jakarta Sans';

  static TextStyle _getStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double letterSpacing,
    required double height,
  }) {
    try {
      return GoogleFonts.getFont(
        uiFont,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (e) {
      // Fallback if font fails to load or name is invalid
      return TextStyle(
        fontFamily: uiFont,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  // 1. Core Styles
  static TextStyle get display => _getStyle(
    fontSize: sizeDisplay,
    fontWeight: weightHeavy,
    letterSpacing: lsHero,
    height: 1.0,
  );

  static TextStyle get headline => _getStyle(
    fontSize: sizeHeadline,
    fontWeight: weightHeavy,
    letterSpacing: lsTight,
    height: 1.1,
  );

  static TextStyle get memberName => _getStyle(
    fontSize: sizeBody,
    fontWeight: weightBold,
    letterSpacing: lsTight,
    height: 1.4,
  );

  static TextStyle get body => _getStyle(
    fontSize: sizeBody,
    fontWeight: weightStrong,
    letterSpacing: lsStandard,
    height: 1.5,
  );

  static TextStyle get label => _getStyle(
    fontSize: sizeLabel,
    fontWeight: weightBold,
    letterSpacing: lsLabel,
    height: 1.2,
  );

  static TextStyle get micro => _getStyle(
    fontSize: sizeMicro,
    fontWeight: weightBold,
    letterSpacing: lsMicro,
    height: 1.0,
  );

  static TextStyle get bodySmall => _getStyle(
    fontSize: sizeLabel,
    fontWeight: weightMedium,
    letterSpacing: lsStandard,
    height: 1.4,
  );

  static TextStyle get caption => _getStyle(
    fontSize: sizeMicro,
    fontWeight: weightMedium,
    letterSpacing: lsStandard,
    height: 1.0,
  );

  static TextStyle get metricValue => _getStyle(
    fontSize: sizeMetric,
    fontWeight: weightHeavy,
    letterSpacing: lsTight,
    height: 1.1,
  );

  static TextStyle get metricLabel => _getStyle(
    fontSize: sizeMicro,
    fontWeight: weightBold,
    letterSpacing: lsMicro,
    height: 1.0,
  );

  static TextStyle get button => _getStyle(
    fontSize: sizeLabel,
    fontWeight: weightHeavy,
    letterSpacing: lsLabel,
    height: 1.0,
  );

  // Migration Styles
  static TextStyle get displayHero => display;
  static TextStyle get displayTitle => display;
  static TextStyle get displayPage => display;
  static TextStyle get displayHeading => headline;
  static TextStyle get displayLocker => headline;
  static TextStyle get displaySubPage => headline;
  static TextStyle get displaySection => headline;
  static TextStyle get displayLargeBody => body;
  static TextStyle get displaySmall => label;
  static TextStyle get labelStrong => label;
  static TextStyle get captionStrong => label;
  static TextStyle get help => caption;
  static TextStyle get helper => caption;
  static TextStyle get microSmall => micro;
  static TextStyle get nano => micro;
  static TextStyle get displayUI => headline;
  static TextStyle get ribbonHeader => label;
  static TextStyle get subtext => label;
  static TextStyle get displayMedium => display;

  static TextStyle get cardTitle => body.copyWith(
    fontWeight: weightBold,
    letterSpacing: 0.2,
    height: 1.1,
  );

  static TextTheme createTextTheme() => textTheme;

  static TextTheme get textTheme {
    return TextTheme(
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
