
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
        const BoxyArtSectionTitle(title: 'Hero Dashboard Aesthetics'),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Configure the visual style of your primary society dashboard. The hero gradient creates a professional, editorial look.',
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                ),
              ),
              CompactColorPicker(
                label: 'Hero Gradient Color',
                color: Color(config.heroGradientColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Hero Gradient',
                  Color(config.heroGradientColor),
                  (c) => controller.setHeroGradientColor(c),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Background Tint',
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
