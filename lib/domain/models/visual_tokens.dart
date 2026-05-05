import 'package:golf_society/domain/models/society_config.dart';

/// A read-only view of the visual/theme properties of [SocietyConfig].
/// Consumers that only need colors, shapes, or spacing should watch
/// [visualTokensProvider] instead of [themeControllerProvider] to avoid
/// rebuilding on financial or membership config changes.
class VisualTokens {
  const VisualTokens(this._c);
  final SocietyConfig _c;

  // ── Colors ──────────────────────────────────────────────────────────────
  int get primaryColor => _c.primaryColor;
  int get secondaryColor => _c.secondaryColor;
  int get tertiaryColor => _c.tertiaryColor;
  int get dangerousColor => _c.dangerousColor;
  int get backgroundColor => _c.backgroundColor;
  int get cardColor => _c.cardColor;
  int get surfaceElevatedColor => _c.surfaceElevatedColor;
  int get textPrimaryColor => _c.textPrimaryColor;
  int get textSecondaryColor => _c.textSecondaryColor;
  int get textMutedColor => _c.textMutedColor;
  int get borderColor => _c.borderColor;
  int get dividerColor => _c.dividerColor;

  // ── Scoring palette ──────────────────────────────────────────────────────
  int get scoreEagleColor => _c.scoreEagleColor;
  int get scoreBirdieColor => _c.scoreBirdieColor;
  int get scoreParColor => _c.scoreParColor;
  int get scoreBogeyColor => _c.scoreBogeyColor;
  int get scoreDoubleColor => _c.scoreDoubleColor;
  int get scoreTriplePlusColor => _c.scoreTriplePlusColor;
  int get effectivePointsColor => _c.effectivePointsColor;

  // ── Status / pill colors ─────────────────────────────────────────────────
  int get statusPublishedColor => _c.statusPublishedColor;
  int get statusConfirmedColor => _c.statusConfirmedColor;
  int get statusReservedColor => _c.statusReservedColor;
  int get statusWaitlistColor => _c.statusWaitlistColor;
  int get statusWithdrawnColor => _c.statusWithdrawnColor;
  int get statusDinnerColor => _c.statusDinnerColor;

  // ── Team colors ──────────────────────────────────────────────────────────
  int get teamAColor => _c.teamAColor;
  int get teamBColor => _c.teamBColor;

  // ── Hero / card tint ─────────────────────────────────────────────────────
  int get heroGradientColor => _c.heroGradientColor;
  int get heroGradientColorSecondary => _c.heroGradientColorSecondary;
  double get heroGradientOpacity => _c.heroGradientOpacity;
  int get heroTextColor => _c.heroTextColor;
  int get cardTintColor => _c.cardTintColor;
  double get cardTintIntensity => _c.cardTintIntensity;
  bool get useCardGradient => _c.useCardGradient;

  // ── Icon badge ───────────────────────────────────────────────────────────
  int get iconBadgeFillColor => _c.iconBadgeFillColor;
  int get iconBadgeIconColor => _c.iconBadgeIconColor;
  int get iconBadgeTextColor => _c.iconBadgeTextColor;
  double get iconBadgeOpacity => _c.iconBadgeOpacity;
  double get iconOpacity => _c.iconOpacity;
  double get iconBadgeSize => _c.iconBadgeSize;
  double get iconBadgeIconSize => _c.iconBadgeIconSize;

  // ── Shape / radius ───────────────────────────────────────────────────────
  double get cardRadius => _c.cardRadius;
  double get inputRadius => _c.inputRadius;
  double get pillRadius => _c.pillRadius;
  double get buttonRadius => _c.buttonRadius;
  double get heroRadius => _c.heroRadius;
  double get accentRadius => _c.accentRadius;
  double get accentOpacity => _c.accentOpacity;

  // ── Borders & shadows ────────────────────────────────────────────────────
  bool get useBorders => _c.useBorders;
  double get borderWidth => _c.borderWidth;
  bool get useShadows => _c.useShadows;
  double get shadowIntensity => _c.shadowIntensity;
  double get shadowSpread => _c.shadowSpread;
  double get shadowOpacity => _c.shadowOpacity;
  double get dividerThickness => _c.dividerThickness;

  // ── Spacing / rhythm ─────────────────────────────────────────────────────
  double get labelToCardSpacing => _c.labelToCardSpacing;
  double get cardToLabelSpacing => _c.cardToLabelSpacing;
  double get fieldToFieldSpacing => _c.fieldToFieldSpacing;
  double get cardToCardSpacing => _c.cardToCardSpacing;
  double get cardVerticalPadding => _c.cardVerticalPadding;
  double get cardHorizontalPadding => _c.cardHorizontalPadding;
  double get tabToContentSpacing => _c.tabToContentSpacing;
  double get groupFooterToLabelSpacing => _c.groupFooterToLabelSpacing;

  // ── Component sizes ──────────────────────────────────────────────────────
  double get buttonHeight => _c.buttonHeight;
  double get buttonSmallHeight => _c.buttonSmallHeight;
  double get buttonHorizontalPadding => _c.buttonHorizontalPadding;
  double get sliderTrackHeight => _c.sliderTrackHeight;
  double get sliderThumbRadius => _c.sliderThumbRadius;
  double get surfaceHeightLarge => _c.surfaceHeightLarge;
  double get surfaceHeightMedium => _c.surfaceHeightMedium;

  // ── Typography / theme identity ──────────────────────────────────────────
  String get fontFamily => _c.fontFamily;
  String get themeMode => _c.themeMode;
  String? get selectedPaletteName => _c.selectedPaletteName;
  List<int> get customColors => _c.customColors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VisualTokens && other._c == _c);

  @override
  int get hashCode => _c.hashCode;
}
