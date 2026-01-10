import 'package:flutter/material.dart';

class AppShadows {
  /// For main content cards. 
  /// Layered shadows for a very subtle 'lift' that doesn't look dirty.
  static final List<BoxShadow> softScale = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12), // Darker
      offset: const Offset(0, 4),
      blurRadius: 15,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08), // Darker
      offset: const Offset(0, 10),
      blurRadius: 30,
      spreadRadius: 0,
    ),
  ];

  /// For floating elements like bottom search bar or action buttons.
  /// Stronger shadow to show elevation above content.
  static final List<BoxShadow> floatingAlt = [
    BoxShadow(
      color: Colors.black.withOpacity(0.20), // Darker, was 0.10
      offset: const Offset(0, 10),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Subtle shadow for text on colored backgrounds.
  static final List<Shadow> textHighlight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  /// Glow effect for primary yellow buttons.
  /// Darker yellow with 20% opacity.
  static final List<BoxShadow> primaryButtonGlow = [
    BoxShadow(
      color: const Color(0xFFB89E00).withOpacity(0.20), // Darker yellow
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}
