
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';

import 'branding_helper_widgets.dart';

class BrandingAestheticsSettings extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;

  const BrandingAestheticsSettings({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Hero Dashboard Aesthetics', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Configure the visual style of your primary society dashboard. The hero gradient creates a professional, editorial look.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dark600,
                  fontWeight: AppTypography.weightMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // --- LIVE PREVIEW BOX ---
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(config.cardRadius),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(config.cardRadius - 1),
                  child: Stack(
                    children: [
                      // The Actual Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(config.heroGradientColor).withValues(alpha: config.heroGradientOpacity),
                              Color(config.heroGradientColorSecondary).withValues(alpha: config.heroGradientOpacity),
                            ],
                          ),
                        ),
                      ),
                      // Sample text to show legibility
                      Center(
                        child: Text(
                          'GRADIENT PREVIEW',
                          style: AppTypography.label.copyWith(
                            color: Color(config.heroTextColor),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ResponsiveColorRow(
                children: [
                  CompactColorPicker(
                    label: 'Hero Gradient Start',
                    color: Color(config.heroGradientColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Gradient Start',
                      Color(config.heroGradientColor),
                      (c) => controller.setHeroGradientColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Hero Gradient End',
                    color: Color(config.heroGradientColorSecondary),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Gradient End',
                      Color(config.heroGradientColorSecondary),
                      (c) => controller.setHeroGradientColorSecondary(c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gradient Opacity',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Text(
                          'Overall strength of the hero gradient',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BoxyArtSlider(
                      value: config.heroGradientOpacity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: '${(config.heroGradientOpacity * 100).toStringAsFixed(0)}%',
                      isNeutral: true,
                      onChanged: (v) => controller.setHeroGradientOpacity(v),
                    ),
                  ),
                ],
              ),
              const BoxyArtDivider(),
              CompactColorPicker(
                label: 'Hero Text Color',
                color: Color(config.heroTextColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Hero Text',
                  Color(config.heroTextColor),
                  (c) => controller.setHeroTextColor(c),
                ),
              ),
              const BoxyArtDivider(),
              CompactColorPicker(
                label: 'Background Tint Color',
                color: Color(config.cardTintColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Tint Color',
                  Color(config.cardTintColor),
                  (c) => controller.setCardTintColor(c),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tint Intensity',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Text(
                          'Subtle brand color in card backgrounds',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BoxyArtSlider(
                      value: config.cardTintIntensity,
                      min: 0.0,
                      max: 0.3,
                      divisions: 15,
                      label: '${(config.cardTintIntensity * 100).toStringAsFixed(0)}%',
                      isNeutral: true,
                      onChanged: (v) => controller.setCardTintIntensity(v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
