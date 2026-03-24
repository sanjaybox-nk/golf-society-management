import 'package:freezed_annotation/freezed_annotation.dart';
import 'handicap_system.dart';

part 'society_config.freezed.dart';
part 'society_config.g.dart';

enum SocietyCutMode {
  off,
  global,
  manual,
}

@freezed
abstract class SocietyConfig with _$SocietyConfig {
  const factory SocietyConfig({
    @Default('Golf Society') String societyName,
    String? logoUrl,
    @Default(0xFFF7D354) int primaryColor, // Default: BoxyArt Yellow
    @Default(0xFF4ADE80) int secondaryColor, // Default: Emerald Green (Action)
    @Default(0xFFEFEFED) int backgroundColor, // Default: Light Gray/Neutral
    @Default(0xFF22C55E) int statusConfirmedColor, // [NEW] Pill Subset
    @Default(0xFFFFAA00) int statusReservedColor,  // [NEW] Pill Subset
    @Default(0xFFFF5533) int statusWaitlistColor,  // [NEW] Pill Subset
    @Default(0xFF6B7280) int statusWithdrawnColor, // [NEW] Pill Subset
    @Default(0xFF673AB7) int statusDinnerColor,    // [NEW] Pill Subset
    @Default(18.0) double cardRadius, // [NEW] Granular Card Radius
    @Default(12.0) double inputRadius, // [NEW] Granular Input Radius
    @Default(true) bool useShadows, // [NEW] Toggle Shadows
    @Default(1.0) double shadowIntensity, // [NEW] Granular Shadow Intensity (0.0 to 2.0)
    @Default(true) bool useBorders, // [NEW] Toggle Borders
    @Default(1.5) double borderWidth, // [NEW] Granular Border Width
    @Default(30.0) double pillRadius, // [NEW] Granular Pill Radius
    @Default(30.0) double buttonRadius, // [NEW] Granular Button Radius
    @Default(28.0) double heroRadius, // [NEW] Granular Hero Radius (Independent)
    @Default(12.0) double accentRadius, // [NEW] Metric & Icon Radius
    @Default(0.15) double accentOpacity, // [NEW] Metric & Icon Background Opacity
    @Default(0.0) double shadowSpread, // [NEW] Granular Shadow Spread
    @Default(0.12) double shadowOpacity, // [NEW] Granular Shadow Opacity
    @Default(8.0) double labelToCardSpacing, // [NEW] Vertical rhythm: Label to Card
    @Default(16.0) double cardToLabelSpacing, // [NEW] Vertical rhythm: Card to Label
    @Default(16.0) double cardToCardSpacing, // [NEW] Vertical rhythm: Card to Card (List Density)
    @Default(16.0) double cardVerticalPadding, // [NEW] Global Card Internal Padding
    @Default(16.0) double cardHorizontalPadding, // [NEW] Global Card Internal Padding
    @Default(0x264ADE80) int iconBadgeFillColor, // [NEW] Icon Badge BG (15% Emerald)
    @Default(0xFF4ADE80) int iconBadgeIconColor, // [NEW] Icon Badge Glyph (Emerald)
    @Default(1.0) double iconBadgeOpacity, // [NEW] Icon Badge background opacity
    @Default(1.0) double iconOpacity, // [NEW] Icon Glyph opacity
    @Default('system') String themeMode, // 'system', 'light', 'dark'
    @Default([]) List<int> customColors, // User-created custom colors (up to 5)
    @Default(0.1) double cardTintIntensity, // Card background tint intensity (0.0 to 1.0)
    @Default(true) bool useCardGradient,
    @Default('£') String currencySymbol, // Default currency symbol
    @Default('GBP') String currencyCode, // Default currency code
    @Default('balanced') String groupingStrategy, // 'balanced', 'progressive', 'similar', 'random'
    @Default(true) bool useWhsHandicaps, // Default: Use WHS (Slope/Rating)
    @Default('yards') String distanceUnit, // 'yards' or 'meters'
    @Default(HandicapSystem.igolf) HandicapSystem handicapSystem, // Global provider
    String? selectedPaletteName,
    @Default(true) bool separateGuestLeaderboard, // Single toggle: ON = Separate, OFF = Hidden
    @Default(SocietyCutMode.off) SocietyCutMode societyCutMode,
    @Default({
      '1st': 2.0,
      '2nd': 1.0,
      '3rd': 0.5,
    }) Map<String, double> societyCutRules,
    @Default(0.10) double globalMarkupPercentage, // Default: 10%
    @Default(10.0) double guestMarkupExtra, // Default: £10 extra for guests
  }) = _SocietyConfig;

  factory SocietyConfig.fromJson(Map<String, dynamic> json) =>
      _$SocietyConfigFromJson(json);
}
