import "package:flutter/material.dart";



import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/society_config_repository.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/domain/models/handicap_system.dart';

final themeControllerProvider = NotifierProvider<ThemeController, SocietyConfig>(ThemeController.new);

class ThemeController extends Notifier<SocietyConfig> {
  @override
  SocietyConfig build() {
    final configAsync = ref.watch(societyConfigStreamProvider);
    return configAsync.maybeWhen(
      data: (config) => config,
      orElse: () => const SocietyConfig(),
    );
  }

  Future<void> setSocietyName(String name) async {
    final newConfig = state.copyWith(societyName: name);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setLogoUrl(String? url) async {
    final newConfig = state.copyWith(logoUrl: url);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setPrimaryColor(Color color) async {
    final hex = color.toARGB32(); // Store as ARGB int
    final newConfig = state.copyWith(primaryColor: hex);
    state = newConfig; // Optimistic update
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSecondaryColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(secondaryColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setDangerousColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(dangerousColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setTertiaryColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(tertiaryColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setCardColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(cardColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSurfaceElevatedColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(surfaceElevatedColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setTextPrimaryColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(textPrimaryColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setTextSecondaryColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(textSecondaryColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setTextMutedColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(textMutedColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setScoreEagleColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(scoreEagleColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setScoreBirdieColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(scoreBirdieColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setScoreParColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(scoreParColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setScoreBogeyColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(scoreBogeyColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setScoreDoubleColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(scoreDoubleColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setScoreTriplePlusColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(scoreTriplePlusColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setTeamAColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(teamAColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setTeamBColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(teamBColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setBackgroundColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(backgroundColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setStatusPublishedColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(statusPublishedColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setStatusConfirmedColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(statusConfirmedColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setStatusReservedColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(statusReservedColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setStatusWaitlistColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(statusWaitlistColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setStatusWithdrawnColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(statusWithdrawnColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setStatusDinnerColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(statusDinnerColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setUseShadows(bool use) async {
    final newConfig = state.copyWith(useShadows: use);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setShadowIntensity(double intensity) async {
    final newConfig = state.copyWith(shadowIntensity: intensity);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setUseBorders(bool use) async {
    final newConfig = state.copyWith(useBorders: use);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setBorderWidth(double width) async {
    final newConfig = state.copyWith(borderWidth: width);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setBorderColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(borderColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setDividerColor(Color color) async {
    final hex = color.toARGB32();
    final newConfig = state.copyWith(dividerColor: hex);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setPillRadius(double radius) async {
    final newConfig = state.copyWith(pillRadius: radius);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setButtonRadius(double radius) async {
    final newConfig = state.copyWith(buttonRadius: radius);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setDividerThickness(double thickness) async {
    final newConfig = state.copyWith(dividerThickness: thickness);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setHeroRadius(double radius) async {
    final newConfig = state.copyWith(heroRadius: radius);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setCardRadius(double radius) async {
    final newConfig = state.copyWith(cardRadius: radius);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setInputRadius(double radius) async {
    final newConfig = state.copyWith(inputRadius: radius);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setAccentRadius(double radius) async {
    final newConfig = state.copyWith(accentRadius: radius);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setAccentOpacity(double opacity) async {
    final newConfig = state.copyWith(accentOpacity: opacity);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setShadowSpread(double spread) async {
    final newConfig = state.copyWith(shadowSpread: spread);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setShadowOpacity(double opacity) async {
    final newConfig = state.copyWith(shadowOpacity: opacity);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setLabelToCardSpacing(double spacing) async {
    final newConfig = state.copyWith(labelToCardSpacing: spacing);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setCardToLabelSpacing(double spacing) async {
    final newConfig = state.copyWith(cardToLabelSpacing: spacing);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setFieldToFieldSpacing(double spacing) async {
    final newConfig = state.copyWith(fieldToFieldSpacing: spacing);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setCardToCardSpacing(double spacing) async {
    final newConfig = state.copyWith(cardToCardSpacing: spacing);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setCardVerticalPadding(double padding) async {
    final newConfig = state.copyWith(cardVerticalPadding: padding);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setCardHorizontalPadding(double padding) async {
    final newConfig = state.copyWith(cardHorizontalPadding: padding);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setTabToContentSpacing(double spacing) async {
    final newConfig = state.copyWith(tabToContentSpacing: spacing);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setIconBadgeFillColor(Color color) async {
    final newConfig = state.copyWith(iconBadgeFillColor: color.toARGB32());
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setIconBadgeIconColor(Color color) async {
    final newConfig = state.copyWith(iconBadgeIconColor: color.toARGB32());
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setIconBadgeOpacity(double opacity) async {
    final newConfig = state.copyWith(iconBadgeOpacity: opacity);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setIconOpacity(double opacity) async {
    final newConfig = state.copyWith(iconOpacity: opacity);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setStartingBalance(double balance) async {
    final newConfig = state.copyWith(startingBalance: balance);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> addLedgerEntry(FinancialEntry entry) async {
    final currentEntries = List<FinancialEntry>.from(state.ledgerEntries);
    currentEntries.add(entry);
    final newConfig = state.copyWith(ledgerEntries: currentEntries);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> updateLedgerEntry(FinancialEntry entry) async {
    final currentEntries = List<FinancialEntry>.from(state.ledgerEntries);
    final index = currentEntries.indexWhere((e) => e.id == entry.id);
    if (index == -1) return;
    currentEntries[index] = entry;
    final newConfig = state.copyWith(ledgerEntries: currentEntries);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> removeLedgerEntry(String id) async {
    final currentEntries = List<FinancialEntry>.from(state.ledgerEntries);
    currentEntries.removeWhere((e) => e.id == id);
    final newConfig = state.copyWith(ledgerEntries: currentEntries);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }


  Future<void> setThemeMode(String mode) async {
    final newConfig = state.copyWith(themeMode: mode);
    state = newConfig; // Optimistic update
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setFontFamily(String family) async {
    final newConfig = state.copyWith(fontFamily: family);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> addCustomColor(Color color) async {
    final hex = color.toARGB32();
    final currentCustomColors = List<int>.from(state.customColors);
    
    // Limit to 5 custom colors
    if (currentCustomColors.length >= 5) return;
    
    currentCustomColors.add(hex);
    final newConfig = state.copyWith(customColors: currentCustomColors);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> updateCustomColor(int index, Color color) async {
    final hex = color.toARGB32();
    final currentCustomColors = List<int>.from(state.customColors);
    
    if (index < 0 || index >= currentCustomColors.length) return;
    
    currentCustomColors[index] = hex;
    final newConfig = state.copyWith(customColors: currentCustomColors);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> removeCustomColor(int index) async {
    final currentCustomColors = List<int>.from(state.customColors);
    
    if (index < 0 || index >= currentCustomColors.length) return;
    
    currentCustomColors.removeAt(index);
    final newConfig = state.copyWith(customColors: currentCustomColors);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }



  Future<void> setCurrency(String symbol, String code) async {
    final newConfig = state.copyWith(currencySymbol: symbol, currencyCode: code);
    state = newConfig; // Optimistic update
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setGroupingStrategy(String strategy) async {
    final newConfig = state.copyWith(groupingStrategy: strategy);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setDistanceUnit(String unit) async {
    final newConfig = state.copyWith(distanceUnit: unit);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }



  Future<void> setHandicapSystem(HandicapSystem system) async {
    final newConfig = state.copyWith(handicapSystem: system);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSeparateGuestLeaderboard(bool separate) async {
    final newConfig = state.copyWith(separateGuestLeaderboard: separate);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }


  Future<void> setSocietyCutMode(SocietyCutMode mode) async {
    final newConfig = state.copyWith(societyCutMode: mode);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSocietyCutRules(Map<String, double> rules) async {
    final newConfig = state.copyWith(societyCutRules: rules);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSocietyCutEventLimit(int limit) async {
    final newConfig = state.copyWith(societyCutEventLimit: limit);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSocietyCutCountPlayedOnly(bool countPlayedOnly) async {
    final newConfig = state.copyWith(societyCutCountPlayedOnly: countPlayedOnly);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSocietyCutFilterSeason(bool active) async {
    final newConfig = state.copyWith(societyCutFilterSeason: active);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setSocietyCutFilterInvitational(bool active) async {
    final newConfig = state.copyWith(societyCutFilterInvitational: active);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setGlobalMembershipEndDate(DateTime? date) async {
    final newConfig = state.copyWith(globalMembershipEndDate: date);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setRenewalWindowDays(int days) async {
    final newConfig = state.copyWith(renewalWindowDays: days);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setIsRenewalActive(bool active) async {
    final newConfig = state.copyWith(isRenewalActive: active);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setRenewalLaunchDate(DateTime? date) async {
    final newConfig = state.copyWith(renewalLaunchDate: date);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setRenewalDeadline(DateTime? date) async {
    final newConfig = state.copyWith(renewalDeadline: date);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setRenewalPaymentDeadline(DateTime? date) async {
    final newConfig = state.copyWith(renewalPaymentDeadline: date);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  // --- Sponsorship Hub Management ---

  Future<void> addSponsor(Sponsor sponsor) async {
    final newConfig = state.copyWith(
      sponsors: [...state.sponsors, sponsor],
    );
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> updateSponsor(Sponsor sponsor) async {
    final newConfig = state.copyWith(
      sponsors: state.sponsors.map((s) => s.id == sponsor.id ? sponsor : s).toList(),
    );
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> removeSponsor(String id) async {
    final newConfig = state.copyWith(
      sponsors: state.sponsors.where((s) => s.id != id).toList(),
    );
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }
}
