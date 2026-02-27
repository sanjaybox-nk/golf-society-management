import "package:flutter/material.dart";



class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  
  // Curves
  static const Curve emphasizingCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve entranceCurve = Curves.easeOutQuart;

  // Stagger Delays
  static Duration stagger(int index) => Duration(milliseconds: index * 100);
  
  // Slide offsets
  static const Offset slideUp = Offset(0, 0.1);
  static const Offset slideDown = Offset(0, -0.1);
}
