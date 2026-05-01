import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'branding_helper_widgets.dart';

class BrandingStyleSettings extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;

  const BrandingStyleSettings({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: BoxyArtFormColumn(
        children: [
          Text(
            'Choose a structural tone for your society. This adjusts corner rounding and depth.',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: AppTypography.weightMedium,
              color: AppColors.dark600,
            ),
          ),
          BoxyArtSwitchField(
            label: 'Use Shadows',
            subtitle: 'Adds depth to cards and buttons',
            value: config.useShadows,
            onChanged: (v) => controller.setUseShadows(v),
          ),
          if (config.useShadows) ...[
            _buildSliderRow(
              label: 'Intensity',
              value: config.shadowIntensity,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              onChanged: (v) => controller.setShadowIntensity(v),
            ),
            _buildSliderRow(
              label: 'Spread',
              value: config.shadowSpread,
              min: 0.0,
              max: 20.0,
              divisions: 20,
              onChanged: (v) => controller.setShadowSpread(v),
            ),
            _buildSliderRow(
              label: 'Opacity',
              value: config.shadowOpacity,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (v) => controller.setShadowOpacity(v),
            ),
          ],
          BoxyArtSwitchField(
            label: 'Use Borders',
            subtitle: 'Hardens card and field edges',
            value: config.useBorders,
            onChanged: (v) => controller.setUseBorders(v),
          ),
          if (config.useBorders) ...[
            _buildSliderRow(
              label: 'Thickness',
              value: config.borderWidth,
              min: 0.5,
              max: 4.0,
              divisions: 7,
              onChanged: (v) => controller.setBorderWidth(v),
            ),
            CompactColorPicker(
              label: 'Border Color',
              color: Color(config.borderColor),
              onTap: () => BrandingHelper.pickColor(
                context,
                'Border Color',
                Color(config.borderColor),
                (c) => controller.setBorderColor(c),
              ),
            ),
          ],
          const BoxyArtDivider(),
          _buildSliderRow(
            label: 'Divider',
            value: config.dividerThickness,
            min: 0.5,
            max: 3.0,
            divisions: 5,
            onChanged: (v) => controller.setDividerThickness(v),
          ),
          CompactColorPicker(
            label: 'Divider Color',
            color: Color(config.dividerColor),
            onTap: () => BrandingHelper.pickColor(
              context,
              'Divider Color',
              Color(config.dividerColor),
              (c) => controller.setDividerColor(c),
            ),
          ),
          const BoxyArtDivider(),
          _buildSliderRow(
            label: 'Buttons',
            value: config.buttonRadius,
            min: 0.0,
            max: 30.0,
            divisions: 15,
            onChanged: (v) => controller.setButtonRadius(v),
          ),
          _buildSliderRow(
            label: 'Cards',
            value: config.cardRadius,
            min: 0.0,
            max: 32.0,
            divisions: 16,
            onChanged: (v) => controller.setCardRadius(v),
          ),
          _buildSliderRow(
            label: 'Inputs',
            value: config.inputRadius,
            min: 0.0,
            max: 24.0,
            divisions: 12,
            onChanged: (v) => controller.setInputRadius(v),
          ),
          _buildSliderRow(
            label: 'Hero',
            value: config.heroRadius,
            min: 0.0,
            max: 40.0,
            divisions: 20,
            onChanged: (v) => controller.setHeroRadius(v),
          ),
          _buildSliderRow(
            label: 'Metrics',
            value: config.accentRadius,
            min: 0.0,
            max: 20.0,
            divisions: 10,
            onChanged: (v) => controller.setAccentRadius(v),
          ),
        ],
      ),
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
