import 'package:flutter/material.dart';

/// Fairway Design System v3.1 Shapes and Radii
class AppShapes {
  static const double rXs = 4.0;   // Micro-elements (e.g. small badges)
  static const double rSm = 8.0;   // Standard buttons / small cards
  static const double rMd = 12.0;  // Default card radius
  static const double rLg = 16.0;  // Large section containers
  static const double rXl = 20.0;  // Prominent hero cards
  static const double r2xl = 28.0; // Specialized oversized surfaces
  static const double rPill = 999.0; // Fully rounded ends
  static const double rGrabber = 2.0; // Modal handle indicators
  static const double rSheet = 25.0; // Bottom sheet top corners
  
  // Border Widths - Standardized for Whitelabeling
  static const double borderThin = 1.0;   // Default hairline border
  static const double borderLight = 1.5;  // Subtle emphasis (e.g. grid lines)
  static const double borderMedium = 2.0; // Pronounced outer borders
  static const double borderSemi = 2.5;   // Heavy decorative strokes
  static const double borderThick = 3.0;  // Structural highlight borders

  // Icon Sizes - Unified Scale
  static const double iconXs = 14.0;      // Tiny inline markers
  static const double iconSm = 16.0;      // Standard button icons
  static const double iconMd = 20.0;      // List item leading icons
  static const double iconLg = 24.0;      // Primary action icons
  static const double iconXl = 32.0;      // Large status indicators
  static const double iconHero = 48.0;    // Featured section icons
  static const double iconMassive = 64.0; // Massive decorative icons

  static const BorderRadius xs = BorderRadius.all(Radius.circular(rXs));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(rXl));
  static const BorderRadius x2l = BorderRadius.all(Radius.circular(r2xl));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(rPill));
  static const BorderRadius grabber = BorderRadius.all(Radius.circular(rGrabber));
  static const BorderRadius sheet = BorderRadius.vertical(top: Radius.circular(rSheet));

  // Legacy/Alias support
  static BorderRadius get cardRadius => lg;

  // Common card shape
  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: lg,
  );

  // Common button shape
  static final RoundedRectangleBorder pillShape = RoundedRectangleBorder(
    borderRadius: pill,
  );
}
