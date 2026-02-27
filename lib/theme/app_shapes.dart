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

  static const BorderRadius xs = BorderRadius.all(Radius.circular(rXs));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(rXl));
  static const BorderRadius x2l = BorderRadius.all(Radius.circular(r2xl));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(rPill));

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
