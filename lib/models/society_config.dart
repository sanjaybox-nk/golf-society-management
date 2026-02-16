import 'package:freezed_annotation/freezed_annotation.dart';
import 'handicap_system.dart';

part 'society_config.freezed.dart';
part 'society_config.g.dart';

@freezed
abstract class SocietyConfig with _$SocietyConfig {
  const factory SocietyConfig({
    @Default('Golf Society') String societyName,
    String? logoUrl,
    @Default(0xFFF7D354) int primaryColor, // Default: BoxyArt Yellow
    @Default('system') String themeMode, // 'system', 'light', 'dark'
    @Default([]) List<int> customColors, // User-created custom colors (up to 5)
    @Default(0.1) double cardTintIntensity, // Card background tint intensity (0.0 to 1.0)
    @Default(true) bool useCardGradient, // Whether to use gradient on cards
    @Default('£') String currencySymbol, // Default currency symbol
    @Default('GBP') String currencyCode, // Default currency code
    @Default('balanced') String groupingStrategy, // 'balanced', 'progressive', 'similar', 'random'
    @Default(true) bool useWhsHandicaps, // Default: Use WHS (Slope/Rating)
    @Default('yards') String distanceUnit, // 'yards' or 'meters'
    @Default(HandicapSystem.igolf) HandicapSystem handicapSystem, // Global provider
    String? selectedPaletteName, // Selected Modern Card palette name
  }) = _SocietyConfig;

  factory SocietyConfig.fromJson(Map<String, dynamic> json) =>
      _$SocietyConfigFromJson(json);
}
