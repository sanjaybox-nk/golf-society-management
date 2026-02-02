import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';
import 'contrast_helper.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryYellow = Color(0xFFF7D354);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F5F5);
  static const Color backgroundGrey = Color(0xFFF0F2F5);

  static ThemeData generateTheme({required Color seedColor, required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    
    // Calculate contrasting text color for the primary color (buttons, etc)
    final onPrimaryColor = ContrastHelper.getContrastingText(seedColor);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      primary: seedColor,
      onPrimary: onPrimaryColor, // Dynamic contrast
      surface: isDark ? const Color(0xFF1E1E1E) : surfaceWhite, // Dark Card Color
      onSurface: isDark ? Colors.white : primaryBlack,
    );

    // Dynamic Text Theme
    final textTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: isDark ? Colors.white : primaryBlack,
      displayColor: isDark ? Colors.white : primaryBlack,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : backgroundGrey,
      cardColor: isDark ? const Color(0xFF1E1E1E) : surfaceWhite,
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
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : primaryBlack,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconSize: 28,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor, 
          foregroundColor: onPrimaryColor, // Dynamic contrast
          elevation: 6, 
          shadowColor: seedColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : primaryBlack,
          side: BorderSide(color: isDark ? Colors.white70 : primaryBlack, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87),
      ),

      // Cards & Dialogs
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 10,
        color: isDark ? const Color(0xFF1E1E1E) : surfaceWhite,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : surfaceWhite,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : primaryBlack,
        ),
        contentTextStyle: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : primaryBlack,
        indicatorColor: isDark ? seedColor : surfaceWhite,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
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
        dayStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        weekdayStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey),
        yearStyle: GoogleFonts.poppins(),
        headerHeadlineStyle: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        headerHelpStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
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
        helpTextStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
