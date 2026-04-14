import 'package:flutter/services.dart';
import '../../domain/models/society_config.dart';
import 'package:golf_society/design_system/design_system.dart';

/// Fairway Design System v3.1 Theme Composition
class AppTheme {
  // Layout Tokens (Maintained for compatibility)
  static const double cardSpacing = AppSpacing.standard;
  static const double sectionSpacing = AppSpacing.atomic;
  static const double pagePadding = AppSpacing.standard;

  static const double fieldRadius = 18.0;

  // Legacy Compatibility Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  static ThemeData dark(SocietyConfig config) {
    // Dynamic Color Setup
    final primaryColor = Color(config.primaryColor);
    final secondaryColor = Color(config.secondaryColor);
    final dangerousColor = Color(config.dangerousColor);
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: AppColors.dark700,
      error: dangerousColor,
    ).copyWith(
      surfaceContainer: AppColors.dark900,
      onSurface: AppColors.dark60,
    );

    final textTheme = AppTypography.createTextTheme();

    // Granular Shapes
    final cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(config.cardRadius));
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(config.buttonRadius));
    final inputRadius = BorderRadius.circular(config.inputRadius);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.dark800,
      fontFamily: AppTypography.uiFont,
      textTheme: textTheme,
      extensions: [
        ScoreColors.dark(),
        AppShapeTokens(
          heroRadius: config.heroRadius,
          cardRadius: config.cardRadius,
          buttonRadius: config.buttonRadius,
          inputRadius: config.inputRadius,
          pillRadius: config.pillRadius,
          accentRadius: config.accentRadius,
          accentOpacity: config.accentOpacity,
          iconBadgeFill: Color(config.iconBadgeFillColor),
          iconBadgeIcon: Color(config.iconBadgeIconColor),
          iconBadgeOpacity: config.iconBadgeOpacity,
          iconBadgeSize: config.iconBadgeSize,
          iconBadgeIconSize: config.iconBadgeIconSize,
        ),
        AppShadows(
          useShadows: config.useShadows,
          intensity: config.shadowIntensity,
          spread: config.shadowSpread,
          opacity: config.shadowOpacity,
        ),
        AppSpacingTokens(
          labelToCard: config.labelToCardSpacing,
          cardToLabel: config.cardToLabelSpacing,
          cardToCard: config.cardToCardSpacing,
          cardVerticalPadding: config.cardVerticalPadding,
          cardHorizontalPadding: config.cardHorizontalPadding,
        ),
      ],

      // Components - AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.displaySection.copyWith(
          color: AppColors.dark60,
          fontWeight: AppTypography.weightBlack,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Components - Cards
      cardTheme: CardThemeData(
        color: AppColors.dark700,
        shape: cardShape,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      // Components - Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: AppColors.actionText,
          textStyle: AppTypography.label,
          shape: buttonShape,
          elevation: 0,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dark60,
          side: const BorderSide(color: AppColors.dark500, width: AppShapes.borderLight),
          textStyle: AppTypography.label,
          shape: buttonShape,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: AppTypography.label,
          shape: buttonShape,
        ),
      ),

      // Components - Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark600,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: config.useBorders 
              ? BorderSide(
                  color: AppColors.dark400, 
                  width: config.borderWidth,
                )
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: primaryColor, width: config.useBorders ? config.borderWidth.clamp(2.0, 4.0) : 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: dangerousColor, width: config.useBorders ? config.borderWidth : 1.0),
        ),
        hintStyle: AppTypography.helper.copyWith(color: AppColors.dark300),
        labelStyle: AppTypography.label.copyWith(color: AppColors.dark150),
      ),

      // Components - Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.dark900,
        indicatorColor: primaryColor,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(color: AppColors.dark60);
          }
          return AppTypography.caption.copyWith(color: AppColors.dark300);
        }),
      ),

      // Components - Tabs
      tabBarTheme: TabBarThemeData(
        indicatorColor: primaryColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(config.cardRadius * 1.5)),
        titleTextStyle: AppTypography.displaySubPage.copyWith(color: AppColors.dark60),
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.dark150),
      ),
    );
  }

  static ThemeData light(SocietyConfig config) {
    // Dynamic Color Setup
    final primaryColor = Color(config.primaryColor);
    final secondaryColor = Color(config.secondaryColor);
    final dangerousColor = Color(config.dangerousColor);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: AppColors.lightSurface,
      error: dangerousColor,
    ).copyWith(
      surfaceContainer: Color(config.backgroundColor), // Page Background
      onSurface: const Color(0xFF1A1A1A),
    );

    final textTheme = AppTypography.createTextTheme();

    // Granular Shapes
    final cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(config.cardRadius));
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(config.buttonRadius));
    final inputRadius = BorderRadius.circular(config.inputRadius);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Color(config.backgroundColor),
      fontFamily: AppTypography.uiFont,
      textTheme: textTheme,
      extensions: [
        ScoreColors.light(),
        AppShadows(
          useShadows: config.useShadows,
          intensity: config.shadowIntensity,
          spread: config.shadowSpread,
          opacity: config.shadowOpacity,
        ),
        AppShapeTokens(
          heroRadius: config.heroRadius,
          cardRadius: config.cardRadius,
          buttonRadius: config.buttonRadius,
          inputRadius: config.inputRadius,
          pillRadius: config.pillRadius,
          accentRadius: config.accentRadius,
          accentOpacity: config.accentOpacity,
          iconBadgeFill: Color(config.iconBadgeFillColor),
          iconBadgeIcon: Color(config.iconBadgeIconColor),
          iconBadgeOpacity: config.iconBadgeOpacity,
          iconBadgeSize: config.iconBadgeSize,
          iconBadgeIconSize: config.iconBadgeIconSize,
        ),
        AppSpacingTokens(
          labelToCard: config.labelToCardSpacing,
          cardToLabel: config.cardToLabelSpacing,
          cardToCard: config.cardToCardSpacing,
          cardVerticalPadding: config.cardVerticalPadding,
          cardHorizontalPadding: config.cardHorizontalPadding,
        ),
      ],

      // Components - AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.displaySection.copyWith(
          color: const Color(0xFF1A1A1A),
          fontWeight: AppTypography.weightBlack,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Components - Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        shape: cardShape,
        elevation: 0,
      ),

      // Components - Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: AppColors.pureWhite,
          textStyle: AppTypography.label,
          shape: buttonShape,
          elevation: 0,
        ),
      ),

      // Components - Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightHeader,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: config.useBorders 
              ? BorderSide(color: AppColors.lightBorder, width: config.borderWidth)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: primaryColor, width: config.useBorders ? config.borderWidth.clamp(2.0, 4.0) : 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: dangerousColor, width: config.useBorders ? config.borderWidth : 1.0),
        ),
        hintStyle: AppTypography.helper.copyWith(color: const Color(0xFF888880)),
        labelStyle: AppTypography.label.copyWith(color: const Color(0xFF3A3A3A)),
      ),

      // Components - Tabs
      tabBarTheme: TabBarThemeData(
        indicatorColor: primaryColor,
        labelColor: const Color(0xFF1A1A1A),
        unselectedLabelColor: const Color(0xFF888880),
        labelStyle: AppTypography.label,
        unselectedLabelStyle: AppTypography.label,
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
