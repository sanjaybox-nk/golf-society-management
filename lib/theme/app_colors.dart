import 'package:flutter/material.dart';

/// Fairway Design System v3.1 Primitives and Semantic Colors
class AppColors {
  // Primitives - Vivid Emerald
  static const Color lime500 = Color(0xFF4ADE80); // Primary Brand
  static const Color lime400 = Color(0xFF74E89A); // Hover
  static const Color lime300 = Color(0xFF9DEFB6);
  static const Color lime200 = Color(0xFFC2F5D2);
  static const Color lime600 = Color(0xFF22C55E); // Active
  static const Color lime700 = Color(0xFF16A34A);
  static const Color lime900 = Color(0xFF052E16);

  // Primitives - Coral (Over par, alerts)
  static const Color coral500 = Color(0xFFFF5533);
  static const Color coral400 = Color(0xFFFF7A5C);
  static const Color coral300 = Color(0xFFFFAB99);
  static const Color coral100 = Color(0xFFFFF0ED);

  // Primitives - Amber (Achievement)
  static const Color amber500 = Color(0xFFFFAA00);
  static const Color amber400 = Color(0xFFFFBF33);
  static const Color amber100 = Color(0xFFFFF8E6);

  // Primitives - Dark-first Neutral Scale
  static const Color dark950 = Color(0xFF0A0A0A);
  static const Color dark900 = Color(0xFF111111);
  static const Color dark800 = Color(0xFF141414); // Page Background
  static const Color dark700 = Color(0xFF1E1E1E); // Card Surface
  static const Color dark600 = Color(0xFF252525); // Elevated Card
  static const Color dark500 = Color(0xFF303030); // Borders
  static const Color dark400 = Color(0xFF404040); // Strong Borders
  static const Color dark300 = Color(0xFF606060);
  static const Color dark200 = Color(0xFFA0A0A0); // Tertiary Text
  static const Color dark150 = Color(0xFFC8C8C8); // Secondary Text
  static const Color dark100 = Color(0xFFD0D0D0); // Body Text
  static const Color dark60 = Color(0xFFF0F0F0); // Primary Text
  static const Color dark50 = Color(0xFFF9F9F8); // Lightest Neutral
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Semantic Alignment Tokens
  static const Color textPrimary = dark60;
  static const Color textSecondary = dark150;
  static const Color textTertiary = dark200;
  static const Color surfaceSubtle = dark900;
  static const Color borderSubtle = dark500;

  // Semantic Action Colors
  static const Color actionGreen = Color(0xFF86AD92);
  static const Color actionText = Color(0xFF0A1A0F); // Dark green-tinted black for lime buttons

  // Team Participation Colors (v3.1)
  static const Color teamA = Color(0xFF1E40AF); // Deep Blue
  static const Color teamB = Color(0xFF166534); // Deep Green

  // Score State Colors
  static const Color scoreEagle = Color(0xFF34D399);
  static const Color scoreBirdie = lime500;
  static const Color scorePar = dark200;
  static const Color scoreBogey = coral400;
  static const Color scoreDouble = coral500;
  static const Color scoreTriplePlus = Color(0xFFFF3333);

  // Light Theme Specifics (Inferring from SC-LIGHT in spec)
  static const Color lightSurface = pureWhite;
  static const Color lightHeader = Color(0xFFF7F7F5);
  static const Color lightBorder = Color(0xFFE2E2DC);
  static const Color forestGreen = Color(0xFF1A2E20); // Light theme total column bg

  // Opacity Tokens (v3.1)
  static const double opacitySubtle = 0.3; // Ghostly subtle (e.g. card highlights)
  static const double opacityLow = 0.1;    // Very faint (e.g. subtle overlays)
  static const double opacityMedium = 0.2; // Visible lift (e.g. soft shadows)
  static const double opacityMuted = 0.3;  // De-emphasized (e.g. disabled-ish states)
  static const double opacityHalf = 0.5;   // Semi-transparent (e.g. scrims)
  static const double opacityHigh = 0.8;   // Substantial (e.g. text on images)
  static const double opacityStrong = 0.9; // Nearly opaque (e.g. overlays)

  /// Generates the Dark ColorScheme based on v3.1 spec
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: lime500,
      onPrimary: actionText,
      secondary: lime400,
      onSecondary: actionText,
      error: coral500,
      onError: pureWhite,
      surface: dark700,
      onSurface: dark60,
      surfaceContainer: dark900, // Page Background mapped to container
      onSurfaceVariant: dark150, // Secondary text
    );
  }

  /// Generates the Light ColorScheme based on v3.1 spec (inferred)
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: lime700,
      onPrimary: pureWhite,
      secondary: lime600,
      onSecondary: pureWhite,
      error: coral500,
      onError: pureWhite,
      surface: lightSurface,
      onSurface: Color(0xFF1A1A1A),
      surfaceContainer: Color(0xFFEFEFED), // Page Background
      onSurfaceVariant: Color(0xFF3A3A3A), // Secondary text
    );
  }

  /// Returns the brand color associated with a Tee name
  static Color getTeeColor(String? teeName) {
    if (teeName == null) return textSecondary;
    final name = teeName.toLowerCase();
    if (name.contains('white')) return dark400;
    if (name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('red')) return const Color(0xFFFF4D4D);
    if (name.contains('blue')) return const Color(0xFF1E90FF);
    if (name.contains('black')) return const Color(0xFF2F2F2F);
    if (name.contains('green')) return const Color(0xFF2ECC71);
    if (name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('silver')) return const Color(0xFFC0C0C0);
    if (name.contains('orange')) return amber500;
    if (name.contains('purple')) return const Color(0xFF8E44AD); // Standard purple
    return textSecondary;
  }
}

/// Theme Extension for Score Colors since ColorScheme doesn't cover all golf states
class ScoreColors extends ThemeExtension<ScoreColors> {
  final Color eagle;
  final Color birdie;
  final Color par;
  final Color bogey;
  final Color doubleBogey; // Renamed from 'double' to avoid keyword conflict
  final Color triplePlus;

  const ScoreColors({
    required this.eagle,
    required this.birdie,
    required this.par,
    required this.bogey,
    required this.doubleBogey, // Renamed in constructor
    required this.triplePlus,
  });

  @override
  ThemeExtension<ScoreColors> copyWith({
    Color? eagle,
    Color? birdie,
    Color? par,
    Color? bogey,
    Color? doubleBogey, // Renamed in copyWith
    Color? triplePlus,
  }) {
    return ScoreColors(
      eagle: eagle ?? this.eagle,
      birdie: birdie ?? this.birdie,
      par: par ?? this.par,
      bogey: bogey ?? this.bogey,
      doubleBogey: doubleBogey ?? this.doubleBogey, // Renamed in copyWith
      triplePlus: triplePlus ?? this.triplePlus,
    );
  }

  @override
  ThemeExtension<ScoreColors> lerp(ThemeExtension<ScoreColors>? other, double t) {
    if (other is! ScoreColors) return this;
    return ScoreColors(
      eagle: Color.lerp(eagle, other.eagle, t)!,
      birdie: Color.lerp(birdie, other.birdie, t)!,
      par: Color.lerp(par, other.par, t)!,
      bogey: Color.lerp(bogey, other.bogey, t)!,
      doubleBogey: Color.lerp(doubleBogey, other.doubleBogey, t)!, // Renamed in lerp
      triplePlus: Color.lerp(triplePlus, other.triplePlus, t)!,
    );
  }

  static ScoreColors dark() => const ScoreColors(
    eagle: AppColors.scoreEagle,
    birdie: AppColors.scoreBirdie,
    par: AppColors.dark200,
    bogey: AppColors.scoreBogey,
    doubleBogey: AppColors.scoreDouble, // Renamed here
    triplePlus: AppColors.scoreTriplePlus,
  );

  static ScoreColors light() => const ScoreColors(
    eagle: Color(0xFF065F46),
    birdie: Color(0xFF166534),
    par: Color(0xFF555550),
    bogey: Color(0xFFC2410C),
    doubleBogey: Color(0xFF9A3412),
    triplePlus: Color(0xFF7F1D1D),
  );
}
