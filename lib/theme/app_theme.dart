import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../../domain/models/society_config.dart';

/// Fairway Design System v3.1 Theme Composition
class AppTheme {
  // Layout Tokens (Maintained for compatibility)
  static const double cardSpacing = 16.0;
  static const double sectionSpacing = 8.0;
  static const double pagePadding = 20.0;

  static const double fieldRadius = 18.0;

  // Legacy Compatibility Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  static ThemeData dark(SocietyConfig config) {
    // Dynamic Color Setup
    final primaryColor = Color(config.primaryColor);
    final secondaryColor = Color(config.secondaryColor);
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: AppColors.dark700,
      error: AppColors.coral500,
    ).copyWith(
      surfaceContainer: AppColors.dark900,
      onSurface: AppColors.dark60,
    );

    final textTheme = AppTypography.createTextTheme();

    // Style Presets
    double radius;
    switch (config.brandingStyle) {
      case 'classic': radius = 8.0; break;
      case 'modern':  radius = 28.0; break;
      case 'boxy':
      default:        radius = 18.0; break;
    }
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.dark800,
      fontFamily: AppTypography.uiFont,
      textTheme: textTheme,
      extensions: [
        ScoreColors.dark(),
      ],

      // Components - AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.displayMedium.copyWith(
          fontSize: 20,
          color: AppColors.dark60,
          letterSpacing: -1.0,
          fontWeight: FontWeight.w900,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Components - Cards
      cardTheme: CardThemeData(
        color: AppColors.dark700,
        shape: shape,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      // Components - Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: AppColors.actionText,
          textStyle: AppTypography.label,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dark60,
          side: const BorderSide(color: AppColors.dark500, width: 1.5),
          textStyle: AppTypography.label,
          shape: const StadiumBorder(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: AppTypography.label,
          shape: const StadiumBorder(),
        ),
      ),

      // Components - Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark600,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: config.useBorders 
              ? BorderSide(
                  color: AppColors.dark400, 
                  width: config.borderWidth,
                )
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: BorderSide(color: primaryColor, width: config.useBorders ? config.borderWidth.clamp(2.0, 4.0) : 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: BorderSide(color: AppColors.coral500, width: config.useBorders ? config.borderWidth : 1.0),
        ),
        hintStyle: AppTypography.helper.copyWith(color: AppColors.dark300),
        labelStyle: AppTypography.label.copyWith(color: AppColors.dark150),
      ),

      // Components - Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.dark900,
        indicatorColor: secondaryColor,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(color: AppColors.dark60);
          }
          return AppTypography.caption.copyWith(color: AppColors.dark300);
        }),
      ),

      // Components - Tabs
      tabBarTheme: TabBarThemeData(
        indicatorColor: secondaryColor,
        labelColor: AppColors.dark60,
        unselectedLabelColor: AppColors.dark300,
        labelStyle: AppTypography.label,
        unselectedLabelStyle: AppTypography.label,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // Components - Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.dark600,
        labelStyle: AppTypography.helper.copyWith(color: AppColors.dark60),
        secondaryLabelStyle: AppTypography.helper.copyWith(color: secondaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: StadiumBorder(side: const BorderSide(color: AppColors.dark500)),
      ),

      // Components - Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.dark500,
        thickness: 1,
        space: 1,
      ),

      // Components - Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dark700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius * 1.5)),
        titleTextStyle: AppTypography.displayMedium.copyWith(fontSize: 22, color: AppColors.dark60),
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.dark150),
      ),
    );
  }

  static ThemeData light(SocietyConfig config) {
    // Dynamic Color Setup
    final primaryColor = Color(config.primaryColor);
    final secondaryColor = Color(config.secondaryColor);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: AppColors.lightSurface,
      error: AppColors.coral500,
    ).copyWith(
      surfaceContainer: Color(config.backgroundColor), // Page Background
      onSurface: const Color(0xFF1A1A1A),
    );

    final textTheme = AppTypography.createTextTheme();

    // Style Presets
    double radius;
    switch (config.brandingStyle) {
      case 'classic': radius = 8.0; break;
      case 'modern':  radius = 28.0; break;
      case 'boxy':
      default:        radius = 18.0; break;
    }
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Color(config.backgroundColor),
      fontFamily: AppTypography.uiFont,
      textTheme: textTheme,
      extensions: [
        ScoreColors.light(),
      ],

      // Components - AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.displayMedium.copyWith(
          fontSize: 20,
          color: const Color(0xFF1A1A1A),
          letterSpacing: -1.0,
          fontWeight: FontWeight.w900,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Components - Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        shape: shape,
        elevation: 0,
      ),

      // Components - Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: AppColors.pureWhite,
          textStyle: AppTypography.label,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),

      // Components - Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightHeader,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: config.useBorders 
              ? BorderSide(color: AppColors.lightBorder, width: config.borderWidth)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: BorderSide(color: primaryColor, width: config.useBorders ? config.borderWidth.clamp(2.0, 4.0) : 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius * 0.8),
          borderSide: BorderSide(color: AppColors.coral500, width: config.useBorders ? config.borderWidth : 1.0),
        ),
        hintStyle: AppTypography.helper.copyWith(color: const Color(0xFF888880)),
        labelStyle: AppTypography.label.copyWith(color: const Color(0xFF3A3A3A)),
      ),

      // Components - Tabs
      tabBarTheme: TabBarThemeData(
        indicatorColor: secondaryColor,
        labelColor: const Color(0xFF1A1A1A),
        unselectedLabelColor: const Color(0xFF888880),
        labelStyle: AppTypography.label.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTypography.label.copyWith(fontSize: 12),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // Components - Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
