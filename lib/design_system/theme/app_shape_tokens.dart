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
  final double iconBadgeSize;
  final double iconBadgeIconSize;
  final double navBarRadius;
  final double tabIndicatorRadius;

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
    this.iconBadgeOpacity = 0.15,
    required this.iconBadgeSize,
    required this.iconBadgeIconSize,
    this.navBarRadius = 20.0,
    this.tabIndicatorRadius = 8.0,
  });

  BorderRadius get hero => BorderRadius.circular(heroRadius);
  BorderRadius get card => BorderRadius.circular(cardRadius);
  BorderRadius get button => BorderRadius.circular(buttonRadius);
  BorderRadius get input => BorderRadius.circular(inputRadius);
  BorderRadius get pill => BorderRadius.circular(pillRadius);
  BorderRadius get accent => BorderRadius.circular(accentRadius);
  BorderRadius get navBar => BorderRadius.only(
    topLeft: Radius.circular(navBarRadius),
    topRight: Radius.circular(navBarRadius),
  );
  BorderRadius get tabIndicator => BorderRadius.circular(tabIndicatorRadius);

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
    double? iconBadgeSize,
    double? iconBadgeIconSize,
    double? navBarRadius,
    double? tabIndicatorRadius,
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
      iconBadgeSize: iconBadgeSize ?? this.iconBadgeSize,
      iconBadgeIconSize: iconBadgeIconSize ?? this.iconBadgeIconSize,
      navBarRadius: navBarRadius ?? this.navBarRadius,
      tabIndicatorRadius: tabIndicatorRadius ?? this.tabIndicatorRadius,
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
      iconBadgeSize: lerpDouble(iconBadgeSize, other.iconBadgeSize, t) ?? iconBadgeSize,
      iconBadgeIconSize: lerpDouble(iconBadgeIconSize, other.iconBadgeIconSize, t) ?? iconBadgeIconSize,
      navBarRadius: lerpDouble(navBarRadius, other.navBarRadius, t) ?? navBarRadius,
      tabIndicatorRadius: lerpDouble(tabIndicatorRadius, other.tabIndicatorRadius, t) ?? tabIndicatorRadius,
    );
  }
}
