import 'package:flutter/material.dart';

class ContrastHelper {
  /// Returns Colors.black or Colors.white based on the luminance of the background color.
  /// If the background is light (> 0.5 luminance), return black.
  /// If the background is dark (<= 0.5 luminance), return white.
  static Color getContrastingText(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
