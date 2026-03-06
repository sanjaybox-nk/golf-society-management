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
    @Default('boxy') String brandingStyle, // 'classic', 'boxy', 'modern'
    @Default(true) bool useShadows, // [NEW] Toggle Shadows
    @Default(true) bool useBorders, // [NEW] Toggle Borders
    @Default(1.5) double borderWidth, // [NEW] Granular Border Width
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
