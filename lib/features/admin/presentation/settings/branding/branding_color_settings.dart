
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';

import 'branding_helper_widgets.dart';

class BrandingColorSettings extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;

  const BrandingColorSettings({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Brand Colors'),
        BoxyArtCard(
          child: Column(
            children: [
              ResponsiveColorRow(
                children: [
                  CompactColorPicker(
                    label: 'Primary',
                    color: Color(config.primaryColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Primary',
                      Color(config.primaryColor),
                      (c) => controller.setPrimaryColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Action',
                    color: Color(config.secondaryColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Action',
                      Color(config.secondaryColor),
                      (c) => controller.setSecondaryColor(c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ResponsiveColorRow(
                children: [
                  CompactColorPicker(
                    label: 'Foundation',
                    color: Color(config.tertiaryColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Foundation',
                      Color(config.tertiaryColor),
                      (c) => controller.setTertiaryColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Dangerous',
                    color: Color(config.dangerousColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Dangerous',
                      Color(config.dangerousColor),
                      (c) => controller.setDangerousColor(c),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const BoxyArtSectionTitle(title: 'Status Colors'),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              StatusColorRow(
                label: 'PUBLISHED',
                color: Color(config.statusPublishedColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Published',
                  Color(config.statusPublishedColor),
                  (c) => controller.setStatusPublishedColor(c),
                ),
              ),
              StatusColorRow(
                label: 'CONFIRMED',
                color: Color(config.statusConfirmedColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Confirmed',
                  Color(config.statusConfirmedColor),
                  (c) => controller.setStatusConfirmedColor(c),
                ),
              ),
              StatusColorRow(
                label: 'RESERVED',
                color: Color(config.statusReservedColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Reserved',
                  Color(config.statusReservedColor),
                  (c) => controller.setStatusReservedColor(c),
                ),
              ),
              StatusColorRow(
                label: 'WAITLIST',
                color: Color(config.statusWaitlistColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Waitlist',
                  Color(config.statusWaitlistColor),
                  (c) => controller.setStatusWaitlistColor(c),
                ),
              ),
              StatusColorRow(
                label: 'WITHDRAWN',
                color: Color(config.statusWithdrawnColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Withdrawn',
                  Color(config.statusWithdrawnColor),
                  (c) => controller.setStatusWithdrawnColor(c),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
