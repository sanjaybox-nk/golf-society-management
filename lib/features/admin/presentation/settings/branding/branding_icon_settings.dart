
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'branding_helper_widgets.dart';

class BrandingIconSettings extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;

  const BrandingIconSettings({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Icons & Badges', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Configure the styling for standard icon badges and indicators across the app.',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: AppTypography.weightMedium,
                  color: AppColors.dark600,
                ),
              ),
              // --- BADGE PREVIEW ---
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(config.cardRadius),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Style Preview
                    Container(
                      width: config.iconBadgeSize,
                      height: config.iconBadgeSize,
                      decoration: BoxDecoration(
                        color: Color(config.iconBadgeFillColor).withValues(alpha: config.iconBadgeOpacity),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: Color(config.iconBadgeIconColor).withValues(alpha: config.iconOpacity),
                          size: config.iconBadgeIconSize,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    // Text Style Preview (Calendar Style)
                    Container(
                      width: config.iconBadgeSize * 1.2,
                      height: config.iconBadgeSize * 1.2,
                      decoration: BoxDecoration(
                        color: Color(config.iconBadgeFillColor).withValues(alpha: config.iconBadgeOpacity),
                        borderRadius: BorderRadius.circular(config.accentRadius),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MAR',
                            style: AppTypography.micro.copyWith(
                              color: Color(config.iconBadgeTextColor),
                              fontWeight: AppTypography.weightBlack,
                              fontSize: config.iconBadgeIconSize * 0.4,
                            ),
                          ),
                          Text(
                            '12',
                            style: AppTypography.headline.copyWith(
                              color: Color(config.iconBadgeTextColor),
                              fontWeight: AppTypography.weightBlack,
                              fontSize: config.iconBadgeIconSize * 0.8,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ResponsiveColorRow(
                children: [
                  CompactColorPicker(
                    label: 'Badge Fill',
                    color: Color(config.iconBadgeFillColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Badge Fill',
                      Color(config.iconBadgeFillColor),
                      (c) => controller.setIconBadgeFillColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Badge Glyph',
                    color: Color(config.iconBadgeIconColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Badge Glyph',
                      Color(config.iconBadgeIconColor),
                      (c) => controller.setIconBadgeIconColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Badge Text',
                    color: Color(config.iconBadgeTextColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Badge Text',
                      Color(config.iconBadgeTextColor),
                      (c) => controller.setIconBadgeTextColor(c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSliderRow(
                label: 'Badge Opacity',
                value: config.iconBadgeOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                onChanged: (v) => controller.setIconBadgeOpacity(v),
              ),
              _buildSliderRow(
                label: 'Glyph Opacity',
                value: config.iconOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                onChanged: (v) => controller.setIconOpacity(v),
              ),
              const BoxyArtDivider(),
              _buildSliderRow(
                label: 'Badge Size',
                value: config.iconBadgeSize,
                min: 24.0,
                max: 64.0,
                divisions: 20,
                onChanged: (v) => controller.setIconBadgeSize(v),
              ),
              _buildSliderRow(
                label: 'Glyph Size',
                value: config.iconBadgeIconSize,
                min: 12.0,
                max: 32.0,
                divisions: 20,
                onChanged: (v) => controller.setIconBadgeIconSize(v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.helper.copyWith(
            fontWeight: AppTypography.weightBold,
          ),
        ),
        Expanded(
          child: BoxyArtSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            isNeutral: true,
            onChanged: onChanged,
          ),
        ),
        Text(
          value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
          style: AppTypography.helper.copyWith(
            fontWeight: AppTypography.weightBlack,
          ),
        ),
      ],
    );
  }
}
