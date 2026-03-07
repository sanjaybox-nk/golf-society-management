import 'package:flutter/material.dart';

/// Fairway Design System v3.1 Shapes and Radii
class AppShapes {
  static const double rXs = 4.0;
  static const double rSm = 8.0;
  static const double rMd = 12.0;
  static const double rLg = 16.0;
  static const double rXl = 20.0;
  static const double r2xl = 28.0;
  static const double rPill = 999.0;
  static const double rGrabber = 2.0;
  static const double rSheet = 25.0;
  
  // Border Widths
  static const double borderThin = 1.0;
  static const double borderLight = 1.5;
  static const double borderMedium = 2.0;
  static const double borderSemi = 2.5;
  static const double borderThick = 3.0;

  // Icon Sizes
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconHero = 48.0;
  static const double iconMassive = 64.0;

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
