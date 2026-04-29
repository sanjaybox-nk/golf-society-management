
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';


class BrandingLayoutSettings extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;

  const BrandingLayoutSettings({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Spacing & Rhythm'),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              _buildSliderRow(
                label: 'Label to Card',
                value: config.labelToCardSpacing,
                min: 0.0,
                max: 32.0,
                divisions: 16,
                onChanged: (v) => controller.setLabelToCardSpacing(v),
              ),
              _buildSliderRow(
                label: 'Card to Label',
                value: config.cardToLabelSpacing,
                min: 0.0,
                max: 48.0,
                divisions: 12,
                onChanged: (v) => controller.setCardToLabelSpacing(v),
              ),
              _buildSliderRow(
                label: 'Field Spacing',
                value: config.fieldToFieldSpacing,
                min: 4.0,
                max: 32.0,
                divisions: 14,
                onChanged: (v) => controller.setFieldToFieldSpacing(v),
              ),
              _buildSliderRow(
                label: 'List Density',
                value: config.cardToCardSpacing,
                min: 4.0,
                max: 32.0,
                divisions: 14,
                onChanged: (v) => controller.setCardToCardSpacing(v),
              ),
              _buildSliderRow(
                label: 'Vertical Padding',
                value: config.cardVerticalPadding,
                min: 4.0,
                max: 40.0,
                divisions: 18,
                onChanged: (v) => controller.setCardVerticalPadding(v),
              ),
              _buildSliderRow(
                label: 'Horizontal Padding',
                value: config.cardHorizontalPadding,
                min: 4.0,
                max: 40.0,
                divisions: 18,
                onChanged: (v) => controller.setCardHorizontalPadding(v),
              ),
              _buildSliderRow(
                label: 'Footer Buffer',
                value: config.groupFooterToLabelSpacing,
                min: 0.0,
                max: 60.0,
                divisions: 20,
                onChanged: (v) => controller.setGroupFooterToLabelSpacing(v),
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
