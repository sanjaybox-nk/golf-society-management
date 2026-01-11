import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryYellow = Color(0xFFF7D354);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F5F5);
  static const Color backgroundGrey = Color(0xFFF0F2F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        onPrimary: primaryBlack,
        secondary: primaryBlack,
        onSecondary: Colors.white,
        surface: surfaceWhite,
        onSurface: primaryBlack,
        surfaceContainerHighest: surfaceGrey, // slightly darker than surface
      ),
      scaffoldBackgroundColor: backgroundGrey,
      
      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: primaryBlack,
        displayColor: primaryBlack,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: primaryBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryBlack,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: primaryBlack,
          elevation: 6, // Increased for glow visibility
          shadowColor: const Color(0xFFB89E00).withValues(alpha: 0.8), // Darker yellow for glow
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
          foregroundColor: primaryBlack,
          side: const BorderSide(color: primaryBlack, width: 1.5),
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
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Matching card radii
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),

      // Cards & Dialogs - Highly Rounded
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 10,
        color: surfaceWhite,
        shadowColor: Colors.black.withValues(alpha: 0.05), // Very soft diffused shadow
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: surfaceWhite,
      ),

      // Navigation Bar (Dark Style)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: primaryBlack,
        indicatorColor: surfaceWhite,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlack); // Black icon on White circle
          }
          return const IconThemeData(color: Colors.grey); // Grey icon on Black background
        }),
      ),
    );
  }
}
