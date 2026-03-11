import 'dart:ui';
import 'package:golf_society/design_system/design_system.dart';



class AppShadows extends ThemeExtension<AppShadows> {
  final bool useShadows;
  final double intensity;
  final double spread;
  final double opacity;

  const AppShadows({
    this.useShadows = true,
    this.intensity = 1.0,
    this.spread = 0.0,
    this.opacity = 0.12,
  });

  /// For main content cards. 
  /// Layered shadows for a very subtle 'lift' that doesn't look dirty.
  List<BoxShadow> get softScale {
    if (!useShadows) return [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity * intensity),
        offset: const Offset(0, 4),
        blurRadius: 15,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: (opacity * 0.5) * intensity),
        offset: const Offset(0, 10),
        blurRadius: 30,
        spreadRadius: spread,
      ),
    ];
  }

  /// Specifically for form inputs to keep them extremely subtle.
  List<BoxShadow> get inputSoft {
    if (!useShadows) return [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: (opacity * 0.5) * intensity),
        offset: const Offset(0, 4),
        blurRadius: 10,
        spreadRadius: spread * 0.5,
      ),
    ];
  }

  /// For floating elements like bottom search bar or action buttons.
  /// Stronger shadow to show elevation above content.
  List<BoxShadow> get floatingAlt {
    if (!useShadows) return [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: (opacity * 1.5) * intensity),
        offset: const Offset(0, 10),
        blurRadius: 20,
        spreadRadius: spread,
      ),
    ];
  }

  /// Subtle shadow for text on colored backgrounds.
  List<Shadow> get textHighlight {
    if (!useShadows) return [];
    return [
      Shadow(
        color: Colors.black.withValues(alpha: (opacity * 0.8) * intensity),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ];
  }

  /// Glow effect for primary yellow buttons.
  List<BoxShadow> get primaryButtonGlow {
    if (!useShadows) return [];
    return [
      BoxShadow(
        color: const Color(0xFFB89E00).withValues(alpha: (opacity * 1.5) * intensity),
        offset: const Offset(0, 8),
        blurRadius: 16,
        spreadRadius: spread,
      ),
    ];
  }

  @override
  AppShadows copyWith({
    bool? useShadows, 
    double? intensity,
    double? spread,
    double? opacity,
  }) {
    return AppShadows(
      useShadows: useShadows ?? this.useShadows,
      intensity: intensity ?? this.intensity,
      spread: spread ?? this.spread,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      useShadows: t < 0.5 ? useShadows : other.useShadows,
      intensity: lerpDouble(intensity, other.intensity, t) ?? intensity,
      spread: lerpDouble(spread, other.spread, t) ?? spread,
      opacity: lerpDouble(opacity, other.opacity, t) ?? opacity,
    );
  }
}
