
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';

import 'branding_helper_widgets.dart';

class BrandingPaletteManager extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;

  const BrandingPaletteManager({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Brand Palettes', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Choose from our curated system palettes or create your own signature look below.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dark600,
                  fontWeight: AppTypography.weightMedium,
                ),
              ),
              ColorPalette(
                selectedColor: Color(config.primaryColor),
                customColors: config.customColors,
                onColorSelected: (c) => controller.setPrimaryColor(c),
                onAddCustomColor: (c) => controller.addCustomColor(c),
                onUpdateCustomColor: (idx, c) => controller.updateCustomColor(idx, c),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
