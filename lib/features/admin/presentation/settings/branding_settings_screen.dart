import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'branding/branding_refactor.dart';

class BrandingSettingsScreen extends ConsumerWidget {
  const BrandingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final controller = ref.read(themeControllerProvider.notifier);

    return HeadlessScaffold(
      title: 'Branding',
      subtitle: 'Customize colors and identity',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      actions: const [],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtFormColumn(
              spacing: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
              children: [
                const BoxyArtSectionTitle(
                  title: 'Live Preview',
                  isPeeking: true,
                ),
                BrandingPreviewCard(config: config),

                const BoxyArtSectionTitle(title: 'Style Preference'),
                BrandingStyleSettings(config: config, controller: controller),

                BrandingColorSettings(config: config, controller: controller),

                BrandingLayoutSettings(config: config, controller: controller),

                BrandingAestheticsSettings(config: config, controller: controller),

                BrandingPaletteManager(config: config, controller: controller),

                const BoxyArtSectionTitle(title: 'System References'),
                BoxyArtCard(
                  child: Column(
                    children: [
                      const BoxyArtSectionTitle(title: 'DARK SCALES', isLevel2: true),
                      const ResponsiveColorRow(
                        children: [
                          DarkSwatch(label: '950', color: AppColors.dark950),
                          DarkSwatch(label: '900', color: AppColors.dark900),
                          DarkSwatch(label: '800', color: AppColors.dark800),
                          DarkSwatch(label: '700', color: AppColors.dark700),
                          DarkSwatch(label: '600', color: AppColors.dark600),
                          DarkSwatch(label: '500', color: AppColors.dark500),
                          DarkSwatch(label: '400', color: AppColors.dark400),
                          DarkSwatch(label: '300', color: AppColors.dark300),
                          DarkSwatch(label: '200', color: AppColors.dark200),
                          DarkSwatch(label: '150', color: AppColors.dark150),
                          DarkSwatch(label: '100', color: AppColors.dark100),
                          DarkSwatch(label: '60', color: AppColors.dark60),
                          DarkSwatch(label: '50', color: AppColors.dark50),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      const BoxyArtSectionTitle(title: 'DESIGN SYSTEM COLORS', isLevel2: true),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ScoreColorGridItem(label: 'AMBER', color: AppColors.amber500, onTap: () {}),
                          ScoreColorGridItem(label: 'LIME', color: AppColors.lime500, onTap: () {}),
                          ScoreColorGridItem(label: 'CORAL', color: AppColors.coral500, onTap: () {}),
                          ScoreColorGridItem(label: 'SLATE', color: AppColors.dark300, onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x4l),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
