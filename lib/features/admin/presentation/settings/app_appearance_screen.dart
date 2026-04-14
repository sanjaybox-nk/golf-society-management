import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import 'widgets/theme_mode_tile.dart';

class AppAppearanceScreen extends ConsumerWidget {
  const AppAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'App Appearance',
      subtitle: 'Customize light and dark mode',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      actions: const [],
      slivers: [
        // Heading Section
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(
              title: 'Theme Preference',
              isPeeking: true,
            ),
          ),
        ),

        // Main Content
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  BoxyArtThemeModeTile(
                    title: 'System Default',
                    value: 'system',
                    groupValue: config.themeMode,
                    icon: Icons.brightness_auto_rounded,
                    onChanged: (v) => controller.setThemeMode(v!),
                  ),
                  const BoxyArtDivider(),
                  BoxyArtThemeModeTile(
                    title: 'Always Light',
                    value: 'light',
                    groupValue: config.themeMode,
                    icon: Icons.light_mode_rounded,
                    onChanged: (v) => controller.setThemeMode(v!),
                  ),
                  const BoxyArtDivider(),
                  BoxyArtThemeModeTile(
                    title: 'Always Dark',
                    value: 'dark',
                    groupValue: config.themeMode,
                    icon: Icons.dark_mode_rounded,
                    onChanged: (v) => controller.setThemeMode(v!),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}
