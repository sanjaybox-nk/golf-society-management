import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golf_society/utils/json_converters.dart';
import 'handicap_system.dart';

part 'society_config.freezed.dart';
part 'society_config.g.dart';

enum SocietyCutMode {
  off,
  global,
  manual,
}

enum SponsorTier {
  gold,
  silver,
  bronze,
  standard,
}

@freezed
abstract class SocietyConfig with _$SocietyConfig {
  const factory SocietyConfig({
    @Default('Golf Society') String societyName,
    String? logoUrl,
    @Default(0xFFF7D354) int primaryColor, // Default: BoxyArt Yellow
    @Default(0xFF4ADE80) int secondaryColor, // Default: Emerald Green (Action)
    @Default(0xFFFF5533) int dangerousColor, // [NEW] High Alert / Dangerous Action color (Coral)
    @Default(0xFFEFEFED) int backgroundColor, // Default: Light Gray/Neutral
    @Default(0xFF4ADE80) int statusPublishedColor, // [NEW] Pill Subset (Emerald Green - Lifecycle)
    @Default(0xFF4ADE80) int statusConfirmedColor, // [NEW] Pill Subset (Emerald Green - Registration)
    @Default(0xFFFFAA00) int statusReservedColor,  // [NEW] Pill Subset (Brand Amber)
    @Default(0xFFFF5533) int statusWaitlistColor,  // [NEW] Pill Subset (Brand Coral)
    @Default(0xFF6B7280) int statusWithdrawnColor, // [NEW] Pill Subset (Neutral/Slate)
    @Default(0xFF673AB7) int statusDinnerColor,    // [NEW] Pill Subset (Purple)
    @Default(18.0) double cardRadius, // [NEW] Granular Card Radius
    @Default(12.0) double inputRadius, // [NEW] Granular Input Radius
    @Default(true) bool useShadows, // [NEW] Toggle Shadows
    @Default(1.0) double shadowIntensity, // [NEW] Granular Shadow Intensity (0.0 to 2.0)
    @Default(true) bool useBorders, // [NEW] Toggle Borders
    @Default(1.5) double borderWidth, // [NEW] Granular Border Width
    @Default(30.0) double pillRadius, // [NEW] Granular Pill Radius
    @Default(16.0) double buttonRadius, // [NEW] Granular Button Radius (4.x Default)
    @Default(28.0) double heroRadius, // [NEW] Granular Hero Radius (Independent)
    @Default(8.0) double accentRadius, // [NEW] Metric & Icon Radius (4.x Default)
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
    @Default(38.0) double iconBadgeSize, // [NEW] Tokenized Badge Size
    @Default(18.0) double iconBadgeIconSize, // [NEW] Tokenized Badge Glyph Size
    @Default('system') String themeMode, // 'system', 'light', 'dark'
    @Default(<int>[]) List<int> customColors, // User-created custom colors (up to 5)
    @Default(0.1) double cardTintIntensity, // Card background tint intensity (0.0 to 1.0)
    @Default(false) bool useCardGradient,
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
    @Default(0) int societyCutEventLimit, // [NEW] 0 = Rest of Season
    @Default(true) bool societyCutCountPlayedOnly, // [NEW] Toggle: Count all events vs Played only
    @Default(true) bool societyCutFilterSeason, // [NEW] Cut triggers for Season events
    @Default(false) bool societyCutFilterInvitational, // [NEW] Cut triggers for Invitationals
    @Default(0.10) double globalMarkupPercentage, // Default: 10%
    @Default(10.0) double guestMarkupExtra, // Default: £10 extra for guests
    @OptionalTimestampConverter() DateTime? globalMembershipEndDate, // [NEW] Society-wide expiry date
    @Default(30) int renewalWindowDays, // [NEW] Days before expiry to show home screen alert
    @Default(false) bool isRenewalActive, // [NEW] Admin switch to enable the "Renew Now" button
    @OptionalTimestampConverter() DateTime? renewalLaunchDate, // [NEW] When the "Invoke" happened
    @OptionalTimestampConverter() DateTime? renewalDeadline, // [NEW] Hard cutoff for membership
    @OptionalTimestampConverter() DateTime? renewalPaymentDeadline, // [NEW] Adjustable payment limit
    @Default(0.0) double startingBalance, // [NEW] Opening bank balance for the season
    @Default(<FinancialEntry>[]) List<FinancialEntry> ledgerEntries, // [NEW] Society-level sponsorships & donations
    @Default(<Sponsor>[]) List<Sponsor> sponsors, // [NEW] Central sponsorship hub
  }) = _SocietyConfig;

  factory SocietyConfig.fromJson(Map<String, dynamic> json) =>
      _$SocietyConfigFromJson(json);
}

@freezed
abstract class FinancialEntry with _$FinancialEntry {
  const factory FinancialEntry({
    required String id,
    @Default('Sponsorship') String type, // 'Sponsorship', 'Donation', 'Other'
    required String source,
    String? description, // [NEW] Optional detail for display
    String? logoUrl, // [NEW] Optional logo image URL
    String? scope, // [NEW] 'season' or 'event'
    String? eventId, // [NEW] Targeted event if scope is 'event'
    String? sponsorId, // [NEW] Link to a central Sponsor if applicable
    @Default(0.0) double amount,
    @TimestampConverter() required DateTime date,
    @Default(true) bool isPaid,
  }) = _FinancialEntry;

  factory FinancialEntry.fromJson(Map<String, dynamic> json) =>
      _$FinancialEntryFromJson(json);
}

@freezed
abstract class Sponsor with _$Sponsor {
  const factory Sponsor({
    required String id,
    required String name,
    String? logoUrl,
    String? websiteUrl,
    String? description,
    @Default(SponsorTier.silver) SponsorTier tier,
    @Default(true) bool isActive,
  }) = _Sponsor;

  factory Sponsor.fromJson(Map<String, dynamic> json) =>
      _$SponsorFromJson(json);
}
