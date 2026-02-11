import 'package:flutter/material.dart';

class AppPalette {
  final String name;
  final Color background;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const AppPalette({
    required this.name,
    required this.background,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    this.isDark = false,
  });

  static const List<AppPalette> presets = [
    AppPalette(
      name: 'Analytics Gray',
      background: Color(0xFFECECEC),
      cardBg: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF2A2A2A),
      textSecondary: Color(0xFF888888),
    ),
    AppPalette(
      name: 'Soft Lilac',
      background: Color(0xFFF3F0F8),
      cardBg: Color(0xFFFFFBFF),
      textPrimary: Color(0xFF2E2833),
      textSecondary: Color(0xFF8B7E9A),
    ),
    AppPalette(
      name: 'Warm Beige',
      background: Color(0xFFF5F1EA),
      cardBg: Color(0xFFFFFBF5),
      textPrimary: Color(0xFF2A2A2A),
      textSecondary: Color(0xFF8A8A8A),
    ),
    AppPalette(
      name: 'Cool Gray',
      background: Color(0xFFF0F4F8),
      cardBg: Color(0xFFFAFCFF),
      textPrimary: Color(0xFF1A202C),
      textSecondary: Color(0xFF7A8195),
    ),
    AppPalette(
      name: 'Soft Mint',
      background: Color(0xFFF0F8F5),
      cardBg: Color(0xFFFAFFFD),
      textPrimary: Color(0xFF1A2E25),
      textSecondary: Color(0xFF7A9189),
    ),
    AppPalette(
      name: 'Light Rose',
      background: Color(0xFFFFF5F7),
      cardBg: Color(0xFFFFFBFC),
      textPrimary: Color(0xFF2A1A1D),
      textSecondary: Color(0xFF9A7A81),
    ),
    AppPalette(
      name: 'Dark Mode',
      background: Color(0xFF1A1A1A),
      cardBg: Color(0xFF242424),
      textPrimary: Color(0xFFE8E8E8),
      textSecondary: Color(0xFF9A9A9A),
      isDark: true,
    ),
  ];

  static AppPalette? fromName(String? name) {
    if (name == null) return null;
    return presets.firstWhere((p) => p.name == name, orElse: () => presets.first);
  }
}
