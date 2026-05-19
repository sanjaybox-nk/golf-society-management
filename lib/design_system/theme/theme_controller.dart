import "package:flutter/material.dart";



import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/society_config_repository.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/domain/models/handicap_system.dart';
import 'package:golf_society/domain/models/visual_tokens.dart';
import 'package:golf_society/domain/models/financial_config.dart';
import 'package:golf_society/domain/models/membership_config.dart';

final themeControllerProvider = NotifierProvider<ThemeController, SocietyConfig>(ThemeController.new);

/// Derived provider — rebuilds only when visual/theme properties change.
/// Prefer this over [themeControllerProvider] in widgets that only consume colors,
/// shapes, or spacing tokens.
final visualTokensProvider = Provider.autoDispose<VisualTokens>((ref) {
  final config = ref.watch(themeControllerProvider);
  return VisualTokens(config);
});

/// Derived provider — rebuilds only when financial properties change.
final financialConfigProvider = Provider.autoDispose<FinancialConfig>((ref) {
  final config = ref.watch(themeControllerProvider);
  return FinancialConfig(config);
});

/// Derived provider — rebuilds only when membership/renewal/handicap properties change.
final membershipConfigProvider = Provider.autoDispose<MembershipConfig>((ref) {
  final config = ref.watch(themeControllerProvider);
  return MembershipConfig(config);
});

class ThemeController extends Notifier<SocietyConfig> {
  @override
  SocietyConfig build() {
    final configAsync = ref.watch(societyConfigStreamProvider);
    return configAsync.maybeWhen(
      data: (config) => config,
      orElse: () => const SocietyConfig(),
    );
  }

  /// Centralized update logic for all configuration changes.
  /// Handles both optimistic UI updates and Firestore persistence.
  Future<void> _updateConfig(SocietyConfig newConfig) async {
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  // Simplified transformation helper for complex updates
  Future<void> _transform(SocietyConfig Function(SocietyConfig) fn) => _updateConfig(fn(state));

  Future<void> setSocietyName(String name) => _updateConfig(state.copyWith(societyName: name));
  Future<void> setLogoUrl(String? url) => _updateConfig(state.copyWith(logoUrl: url));

  Future<void> setPrimaryColor(Color color) => _updateConfig(state.copyWith(primaryColor: color.toARGB32()));
  Future<void> setSecondaryColor(Color color) => _updateConfig(state.copyWith(secondaryColor: color.toARGB32()));
  Future<void> setDangerousColor(Color color) => _updateConfig(state.copyWith(dangerousColor: color.toARGB32()));
  Future<void> setTertiaryColor(Color color) => _updateConfig(state.copyWith(tertiaryColor: color.toARGB32()));

  Future<void> setCardColor(Color color) => _updateConfig(state.copyWith(cardColor: color.toARGB32()));
  Future<void> setSurfaceElevatedColor(Color color) => _updateConfig(state.copyWith(surfaceElevatedColor: color.toARGB32()));

  Future<void> setTextPrimaryColor(Color color) => _updateConfig(state.copyWith(textPrimaryColor: color.toARGB32()));
  Future<void> setTextSecondaryColor(Color color) => _updateConfig(state.copyWith(textSecondaryColor: color.toARGB32()));
  Future<void> setTextMutedColor(Color color) => _updateConfig(state.copyWith(textMutedColor: color.toARGB32()));

  Future<void> setScoreEagleColor(Color color) => _updateConfig(state.copyWith(scoreEagleColor: color.toARGB32()));
  Future<void> setScoreBirdieColor(Color color) => _updateConfig(state.copyWith(scoreBirdieColor: color.toARGB32()));
  Future<void> setScoreParColor(Color color) => _updateConfig(state.copyWith(scoreParColor: color.toARGB32()));
  Future<void> setScoreBogeyColor(Color color) => _updateConfig(state.copyWith(scoreBogeyColor: color.toARGB32()));
  Future<void> setScoreDoubleColor(Color color) => _updateConfig(state.copyWith(scoreDoubleColor: color.toARGB32()));
  Future<void> setScoreTriplePlusColor(Color color) => _updateConfig(state.copyWith(scoreTriplePlusColor: color.toARGB32()));
  Future<void> setTeamAColor(Color color) => _updateConfig(state.copyWith(teamAColor: color.toARGB32()));
  Future<void> setTeamBColor(Color color) => _updateConfig(state.copyWith(teamBColor: color.toARGB32()));

  Future<void> setPointsColor(Color color) => _updateConfig(state.copyWith(pointsColor: color.toARGB32()));
  Future<void> setHeroGradientColor(Color color) => _updateConfig(state.copyWith(heroGradientColor: color.toARGB32()));
  Future<void> setBackgroundColor(Color color) => _updateConfig(state.copyWith(backgroundColor: color.toARGB32()));
  Future<void> setStatusPublishedColor(Color color) => _updateConfig(state.copyWith(statusPublishedColor: color.toARGB32()));
  Future<void> setStatusConfirmedColor(Color color) => _updateConfig(state.copyWith(statusConfirmedColor: color.toARGB32()));
  Future<void> setStatusReservedColor(Color color) => _updateConfig(state.copyWith(statusReservedColor: color.toARGB32()));
  Future<void> setStatusWaitlistColor(Color color) => _updateConfig(state.copyWith(statusWaitlistColor: color.toARGB32()));
  Future<void> setStatusWithdrawnColor(Color color) => _updateConfig(state.copyWith(statusWithdrawnColor: color.toARGB32()));
  Future<void> setStatusDinnerColor(Color color) => _updateConfig(state.copyWith(statusDinnerColor: color.toARGB32()));

  Future<void> setUseShadows(bool use) => _updateConfig(state.copyWith(useShadows: use));
  Future<void> setShadowIntensity(double intensity) => _updateConfig(state.copyWith(shadowIntensity: intensity));
  Future<void> setUseBorders(bool use) => _updateConfig(state.copyWith(useBorders: use));
  Future<void> setBorderWidth(double width) => _updateConfig(state.copyWith(borderWidth: width));
  Future<void> setBorderColor(Color color) => _updateConfig(state.copyWith(borderColor: color.toARGB32()));
  Future<void> setDividerColor(Color color) => _updateConfig(state.copyWith(dividerColor: color.toARGB32()));
  Future<void> setPillRadius(double radius) => _updateConfig(state.copyWith(pillRadius: radius));
  Future<void> setButtonRadius(double radius) => _updateConfig(state.copyWith(buttonRadius: radius));
  Future<void> setDividerThickness(double thickness) => _updateConfig(state.copyWith(dividerThickness: thickness));
  Future<void> setHeroRadius(double radius) => _updateConfig(state.copyWith(heroRadius: radius));
  Future<void> setCardRadius(double radius) => _updateConfig(state.copyWith(cardRadius: radius));
  Future<void> setInputRadius(double radius) => _updateConfig(state.copyWith(inputRadius: radius));
  Future<void> setAccentRadius(double radius) => _updateConfig(state.copyWith(accentRadius: radius));
  Future<void> setAccentOpacity(double opacity) => _updateConfig(state.copyWith(accentOpacity: opacity));
  Future<void> setNavBarRadius(double radius) => _updateConfig(state.copyWith(navBarRadius: radius));
  Future<void> setTabIndicatorRadius(double radius) => _updateConfig(state.copyWith(tabIndicatorRadius: radius));
  Future<void> setShadowSpread(double spread) => _updateConfig(state.copyWith(shadowSpread: spread));
  Future<void> setShadowOpacity(double opacity) => _updateConfig(state.copyWith(shadowOpacity: opacity));

  Future<void> setLabelToCardSpacing(double spacing) => _updateConfig(state.copyWith(labelToCardSpacing: spacing));
  Future<void> setCardToLabelSpacing(double spacing) => _updateConfig(state.copyWith(cardToLabelSpacing: spacing));
  Future<void> setFieldToFieldSpacing(double spacing) => _updateConfig(state.copyWith(fieldToFieldSpacing: spacing));
  Future<void> setCardToCardSpacing(double spacing) => _updateConfig(state.copyWith(cardToCardSpacing: spacing));
  Future<void> setCardVerticalPadding(double padding) => _updateConfig(state.copyWith(cardVerticalPadding: padding));
  Future<void> setCardHorizontalPadding(double padding) => _updateConfig(state.copyWith(cardHorizontalPadding: padding));

  Future<void> setTabToContentSpacing(double spacing) => _updateConfig(state.copyWith(tabToContentSpacing: spacing));
  Future<void> setGroupFooterToLabelSpacing(double spacing) => _updateConfig(state.copyWith(groupFooterToLabelSpacing: spacing));

  Future<void> setIconBadgeFillColor(Color color) => _updateConfig(state.copyWith(iconBadgeFillColor: color.toARGB32()));
  Future<void> setIconBadgeIconColor(Color color) => _updateConfig(state.copyWith(iconBadgeIconColor: color.toARGB32()));
  Future<void> setIconBadgeOpacity(double opacity) => _updateConfig(state.copyWith(iconBadgeOpacity: opacity));
  Future<void> setIconOpacity(double opacity) => _updateConfig(state.copyWith(iconOpacity: opacity));
  Future<void> setStartingBalance(double balance) => _updateConfig(state.copyWith(startingBalance: balance));
  Future<void> setSocialMemberFee(double fee) => _updateConfig(state.copyWith(socialMemberFee: fee));

  Future<void> addLedgerEntry(FinancialEntry entry) => _updateConfig(state.copyWith(ledgerEntries: [...state.ledgerEntries, entry]));
  Future<void> updateLedgerEntry(FinancialEntry entry) => _updateConfig(state.copyWith(ledgerEntries: state.ledgerEntries.map((item) => item.id == entry.id ? entry : item).toList()));
  Future<void> removeLedgerEntry(String id) => _updateConfig(state.copyWith(ledgerEntries: state.ledgerEntries.where((item) => item.id != id).toList()));

  Future<void> setThemeMode(String mode) => _updateConfig(state.copyWith(themeMode: mode));
  Future<void> setFontFamily(String family) => _updateConfig(state.copyWith(fontFamily: family));

  Future<void> addCustomColor(Color color) => _transform((s) {
    if (s.customColors.length >= 5) return s;
    return s.copyWith(customColors: [...s.customColors, color.toARGB32()]);
  });

  Future<void> updateCustomColor(int index, Color color) => _transform((s) {
    if (index < 0 || index >= s.customColors.length) return s;
    final colors = List<int>.from(s.customColors);
    colors[index] = color.toARGB32();
    return s.copyWith(customColors: colors);
  });
  Future<void> removeCustomColor(int index) => _transform((s) {
    if (index < 0 || index >= s.customColors.length) return s;
    final colors = List<int>.from(s.customColors);
    colors.removeAt(index);
    return s.copyWith(customColors: colors);
  });

  Future<void> setCurrency(String symbol, String code) => _updateConfig(state.copyWith(currencySymbol: symbol, currencyCode: code));
  Future<void> setGroupingStrategy(String strategy) => _updateConfig(state.copyWith(groupingStrategy: strategy));
  Future<void> setDistanceUnit(String unit) => _updateConfig(state.copyWith(distanceUnit: unit));
  Future<void> setHandicapSystem(HandicapSystem system) => _updateConfig(state.copyWith(handicapSystem: system));
  Future<void> setSeparateGuestLeaderboard(bool separate) => _updateConfig(state.copyWith(separateGuestLeaderboard: separate));
  Future<void> setSocietyCutMode(SocietyCutMode mode) => _updateConfig(state.copyWith(societyCutMode: mode));
  Future<void> setSocietyCutRules(Map<String, double> rules) => _updateConfig(state.copyWith(societyCutRules: rules));
  Future<void> setSocietyCutEventLimit(int limit) => _updateConfig(state.copyWith(societyCutEventLimit: limit));

  Future<void> setSocietyCutCountPlayedOnly(bool countPlayedOnly) => _updateConfig(state.copyWith(societyCutCountPlayedOnly: countPlayedOnly));
  Future<void> setSocietyCutFilterSeason(bool active) => _updateConfig(state.copyWith(societyCutFilterSeason: active));
  Future<void> setSocietyCutFilterInvitational(bool active) => _updateConfig(state.copyWith(societyCutFilterInvitational: active));

  Future<void> setGlobalMembershipEndDate(DateTime? date) => _updateConfig(state.copyWith(globalMembershipEndDate: date));
  Future<void> setRenewalWindowDays(int days) => _updateConfig(state.copyWith(renewalWindowDays: days));
  Future<void> setIsRenewalActive(bool active) => _updateConfig(state.copyWith(isRenewalActive: active));
  Future<void> setRenewalLaunchDate(DateTime? date) => _updateConfig(state.copyWith(renewalLaunchDate: date));
  Future<void> setRenewalDeadline(DateTime? date) => _updateConfig(state.copyWith(renewalDeadline: date));
  Future<void> setRenewalPaymentDeadline(DateTime? date) => _updateConfig(state.copyWith(renewalPaymentDeadline: date));

  Future<void> addSponsor(Sponsor sponsor) => _updateConfig(state.copyWith(sponsors: [...state.sponsors, sponsor]));
  Future<void> updateSponsor(Sponsor sponsor) => _updateConfig(state.copyWith(sponsors: state.sponsors.map((item) => item.id == sponsor.id ? sponsor : item).toList()));
  Future<void> removeSponsor(String id) => _updateConfig(state.copyWith(sponsors: state.sponsors.where((item) => item.id != id).toList()));

  Future<void> setCardTintIntensity(double intensity) => _updateConfig(state.copyWith(cardTintIntensity: intensity));
  Future<void> setHeroGradientColorSecondary(Color color) => _updateConfig(state.copyWith(heroGradientColorSecondary: color.toARGB32()));
  Future<void> setHeroGradientOpacity(double opacity) => _updateConfig(state.copyWith(heroGradientOpacity: opacity));
  Future<void> setHeroTextColor(Color color) => _updateConfig(state.copyWith(heroTextColor: color.toARGB32()));
  Future<void> setCardTintColor(Color color) => _updateConfig(state.copyWith(cardTintColor: color.toARGB32()));
  Future<void> setButtonHeight(double height) => _updateConfig(state.copyWith(buttonHeight: height));
  Future<void> setSliderTrackHeight(double height) => _updateConfig(state.copyWith(sliderTrackHeight: height));
  Future<void> setSurfaceHeightLarge(double height) => _updateConfig(state.copyWith(surfaceHeightLarge: height));
  Future<void> setIconBadgeSize(double size) => _updateConfig(state.copyWith(iconBadgeSize: size));
  Future<void> setIconBadgeIconSize(double size) => _updateConfig(state.copyWith(iconBadgeIconSize: size));
  Future<void> setIconBadgeTextColor(Color color) => _updateConfig(state.copyWith(iconBadgeTextColor: color.toARGB32()));
}
