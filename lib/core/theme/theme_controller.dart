
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/society_config_repository.dart';
import '../../models/society_config.dart';
import '../../models/handicap_system.dart';

final themeControllerProvider = NotifierProvider<ThemeController, SocietyConfig>(ThemeController.new);

class ThemeController extends Notifier<SocietyConfig> {
  @override
  SocietyConfig build() {
    _init();
    return const SocietyConfig();
  }

  void _init() {
    // Listen to real-time updates from Firestore via StreamProvider
    ref.listen<AsyncValue<SocietyConfig>>(societyConfigStreamProvider, (previous, next) {
      next.whenData((config) {
        state = config;
      });
    });
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

  Future<void> setThemeMode(String mode) async {
    final newConfig = state.copyWith(themeMode: mode);
    state = newConfig; // Optimistic update
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

  Future<void> setCardTintIntensity(double intensity) async {
    // Clamp intensity between 0.0 and 1.0
    final clampedIntensity = intensity.clamp(0.0, 1.0);
    final newConfig = state.copyWith(cardTintIntensity: clampedIntensity);
    state = newConfig; // Optimistic update
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setUseCardGradient(bool useGradient) async {
    final newConfig = state.copyWith(useCardGradient: useGradient);
    state = newConfig; // Optimistic update
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

  Future<void> setSelectedPaletteName(String? name) async {
    final newConfig = state.copyWith(selectedPaletteName: name);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }

  Future<void> setHandicapSystem(HandicapSystem system) async {
    final newConfig = state.copyWith(handicapSystem: system);
    state = newConfig;
    await ref.read(societyConfigRepositoryProvider).updateConfig(newConfig);
  }
}
