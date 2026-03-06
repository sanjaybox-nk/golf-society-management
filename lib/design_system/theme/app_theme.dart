import "package:flutter/material.dart";


import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';
import 'contrast_helper.dart';
import 'app_palettes.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryYellow = Color(0xFFF7D354);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F5F5);
  static const Color backgroundGrey = Color(0xFFF0F2F5);
  static const double fieldRadius = 18.0;
  
  // Layout Tokens
  static const double cardSpacing = 24.0;
  static const double sectionSpacing = 8.0;
  static const double pagePadding = 20.0;

  static ThemeData generateTheme({
    required Color seedColor,
    required Brightness brightness,
    AppPalette? palette,
  }) {
    final isDark = brightness == Brightness.dark || (palette?.isDark ?? false);
    
    // palette colors take precedence
    final backgroundColor = palette?.background ?? (isDark ? const Color(0xFF121212) : Color.alphaBlend(seedColor.withValues(alpha: 0.05), backgroundGrey));
    final cardColor = palette?.cardBg ?? (isDark ? const Color(0xFF1E1E1E) : surfaceWhite);
    final textPrimary = palette?.textPrimary ?? (isDark ? Colors.white : primaryBlack);

    // Calculate contrasting text color for the primary color (buttons, etc)
    final onPrimaryColor = ContrastHelper.getContrastingText(seedColor);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: seedColor,
      onPrimary: onPrimaryColor, // Dynamic contrast
      surface: cardColor,
      onSurface: textPrimary,
    );

    // Dynamic Text Theme - Using premium geometric fonts
    final textTheme = _applyLetterSpacing(
      GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      -0.2, // Tighter base spacing for modern look
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      primaryColor: seedColor,
      tabBarTheme: TabBarThemeData(
        indicatorColor: seedColor,
      ),

      // Typography
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // Blends with scaffold
        scrolledUnderElevation: 0,
        foregroundColor: isDark ? Colors.white : primaryBlack,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : primaryBlack,
          letterSpacing: -1.0, // Tightened
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : primaryBlack,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: onPrimaryColor,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        iconSize: 28,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor, 
          foregroundColor: onPrimaryColor, // Dynamic contrast
          elevation: 6, 
          shadowColor: seedColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.8,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : primaryBlack,
          side: BorderSide(color: isDark ? Colors.white70 : primaryBlack, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87),
      ),

      // Cards & Dialogs
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 10,
        color: isDark ? const Color(0xFF1E1E1E) : surfaceWhite,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : surfaceWhite,
        titleTextStyle: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : primaryBlack,
            letterSpacing: 0.8,
        ),
        contentTextStyle: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
            letterSpacing: 0.8,
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : primaryBlack,
        indicatorColor: isDark ? seedColor : surfaceWhite,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey, letterSpacing: 0.8),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlack); 
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),

      // Date Picker Theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : surfaceWhite,
        headerBackgroundColor: seedColor,
        headerForegroundColor: onPrimaryColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        dayStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, letterSpacing: 0.8),
        weekdayStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
        yearStyle: GoogleFonts.inter(letterSpacing: 0.8),
        headerHeadlineStyle: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        headerHelpStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.8),
      ),

      // Time Picker Theme
      timePickerTheme: TimePickerThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : surfaceWhite,
        hourMinuteColor: isDark ? Colors.white10 : Colors.grey.shade100,
        hourMinuteTextColor: isDark ? Colors.white : primaryBlack,
        dayPeriodColor: seedColor.withValues(alpha: 0.1),
        dayPeriodTextColor: seedColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        helpTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.8),
      ),
    );
  }
  
  static TextTheme _applyLetterSpacing(TextTheme theme, double spacing) {
    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(letterSpacing: -1.5, fontWeight: FontWeight.w900),
      displayMedium: theme.displayMedium?.copyWith(letterSpacing: -1.2, fontWeight: FontWeight.w800),
      displaySmall: theme.displaySmall?.copyWith(letterSpacing: -1.0, fontWeight: FontWeight.w800),
      headlineLarge: theme.headlineLarge?.copyWith(letterSpacing: -1.0, fontWeight: FontWeight.w800),
      headlineMedium: theme.headlineMedium?.copyWith(letterSpacing: -0.8, fontWeight: FontWeight.w700),
      headlineSmall: theme.headlineSmall?.copyWith(letterSpacing: -0.5, fontWeight: FontWeight.w700),
      titleLarge: theme.titleLarge?.copyWith(letterSpacing: -0.5, fontWeight: FontWeight.w700),
      titleMedium: theme.titleMedium?.copyWith(letterSpacing: -0.2, fontWeight: FontWeight.w600),
      titleSmall: theme.titleSmall?.copyWith(letterSpacing: 0.0, fontWeight: FontWeight.w600),
      bodyLarge: theme.bodyLarge?.copyWith(letterSpacing: spacing),
      bodyMedium: theme.bodyMedium?.copyWith(letterSpacing: spacing),
      bodySmall: theme.bodySmall?.copyWith(letterSpacing: spacing),
      labelLarge: theme.labelLarge?.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.bold),
      labelMedium: theme.labelMedium?.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.bold),
      labelSmall: theme.labelSmall?.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.bold),
    );
  }
}
