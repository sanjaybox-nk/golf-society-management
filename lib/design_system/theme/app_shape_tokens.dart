import 'dart:ui';
import 'package:golf_society/design_system/design_system.dart';

class AppShapeTokens extends ThemeExtension<AppShapeTokens> {
  final double heroRadius;

  const AppShapeTokens({
    required this.heroRadius,
  });

  BorderRadius get hero => BorderRadius.circular(heroRadius);

  @override
  AppShapeTokens copyWith({double? heroRadius}) {
    return AppShapeTokens(
      heroRadius: heroRadius ?? this.heroRadius,
    );
  }

  @override
  AppShapeTokens lerp(ThemeExtension<AppShapeTokens>? other, double t) {
    if (other is! AppShapeTokens) return this;
    return AppShapeTokens(
      heroRadius: lerpDouble(heroRadius, other.heroRadius, t) ?? heroRadius,
    );
  }
}
