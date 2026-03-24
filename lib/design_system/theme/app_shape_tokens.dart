import 'dart:ui';
import 'package:golf_society/design_system/design_system.dart';

class AppShapeTokens extends ThemeExtension<AppShapeTokens> {
  final double heroRadius;
  final double cardRadius;
  final double buttonRadius;
  final double inputRadius;
  final double pillRadius;
  final double accentRadius;
  final double accentOpacity;
  final Color? iconBadgeFill;
  final Color? iconBadgeIcon;
  final double iconBadgeOpacity;

  const AppShapeTokens({
    required this.heroRadius,
    required this.cardRadius,
    required this.buttonRadius,
    required this.inputRadius,
    required this.pillRadius,
    required this.accentRadius,
    required this.accentOpacity,
    this.iconBadgeFill,
    this.iconBadgeIcon,
    this.iconBadgeOpacity = 1.0,
  });

  BorderRadius get hero => BorderRadius.circular(heroRadius);
  BorderRadius get card => BorderRadius.circular(cardRadius);
  BorderRadius get button => BorderRadius.circular(buttonRadius);
  BorderRadius get input => BorderRadius.circular(inputRadius);
  BorderRadius get pill => BorderRadius.circular(pillRadius);
  BorderRadius get accent => BorderRadius.circular(accentRadius);

  @override
  AppShapeTokens copyWith({
    double? heroRadius,
    double? cardRadius,
    double? buttonRadius,
    double? inputRadius,
    double? pillRadius,
    double? accentRadius,
    double? accentOpacity,
    Color? iconBadgeFill,
    Color? iconBadgeIcon,
    double? iconBadgeOpacity,
  }) {
    return AppShapeTokens(
      heroRadius: heroRadius ?? this.heroRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      pillRadius: pillRadius ?? this.pillRadius,
      accentRadius: accentRadius ?? this.accentRadius,
      accentOpacity: accentOpacity ?? this.accentOpacity,
      iconBadgeFill: iconBadgeFill ?? this.iconBadgeFill,
      iconBadgeIcon: iconBadgeIcon ?? this.iconBadgeIcon,
      iconBadgeOpacity: iconBadgeOpacity ?? this.iconBadgeOpacity,
    );
  }

  @override
  AppShapeTokens lerp(ThemeExtension<AppShapeTokens>? other, double t) {
    if (other is! AppShapeTokens) return this;
    
    return AppShapeTokens(
      heroRadius: lerpDouble(heroRadius, other.heroRadius, t) ?? heroRadius,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t) ?? buttonRadius,
      inputRadius: lerpDouble(inputRadius, other.inputRadius, t) ?? inputRadius,
      pillRadius: lerpDouble(pillRadius, other.pillRadius, t) ?? pillRadius,
      accentRadius: lerpDouble(accentRadius, other.accentRadius, t) ?? accentRadius,
      accentOpacity: lerpDouble(accentOpacity, other.accentOpacity, t) ?? accentOpacity,
      iconBadgeFill: Color.lerp(iconBadgeFill, other.iconBadgeFill, t) ?? iconBadgeFill,
      iconBadgeIcon: Color.lerp(iconBadgeIcon, other.iconBadgeIcon, t) ?? iconBadgeIcon,
      iconBadgeOpacity: lerpDouble(iconBadgeOpacity, other.iconBadgeOpacity, t) ?? iconBadgeOpacity,
    );
  }
}
