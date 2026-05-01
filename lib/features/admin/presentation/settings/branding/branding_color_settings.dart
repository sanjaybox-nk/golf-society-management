
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
        const BoxyArtSectionTitle(title: 'Brand Colors', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Define the primary identity and action colors for your society interface.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dark600,
                  fontWeight: AppTypography.weightMedium,
                ),
              ),
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

        const BoxyArtSectionTitle(title: 'Status Colors', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Standardize the semantic colors used for registration and event states.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dark600,
                  fontWeight: AppTypography.weightMedium,
                ),
              ),
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
              StatusColorRow(
                label: 'DINNER',
                color: Color(config.statusDinnerColor),
                onTap: () => BrandingHelper.pickColor(
                  context,
                  'Dinner',
                  Color(config.statusDinnerColor),
                  (c) => controller.setStatusDinnerColor(c),
                ),
              ),
            ],
          ),
        ),

        const BoxyArtSectionTitle(title: 'Scoring Aesthetics', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Customize the visual presentation of results and performance metrics.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dark600,
                  fontWeight: AppTypography.weightMedium,
                ),
              ),
              ResponsiveColorRow(
                children: [
                  StatusColorRow(
                    label: 'EAGLE',
                    color: Color(config.scoreEagleColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Eagle',
                      Color(config.scoreEagleColor),
                      (c) => controller.setScoreEagleColor(c),
                    ),
                  ),
                  StatusColorRow(
                    label: 'BIRDIE',
                    color: Color(config.scoreBirdieColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Birdie',
                      Color(config.scoreBirdieColor),
                      (c) => controller.setScoreBirdieColor(c),
                    ),
                  ),
                ],
              ),
              ResponsiveColorRow(
                children: [
                  StatusColorRow(
                    label: 'PAR',
                    color: Color(config.scoreParColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Par',
                      Color(config.scoreParColor),
                      (c) => controller.setScoreParColor(c),
                    ),
                  ),
                  StatusColorRow(
                    label: 'BOGEY',
                    color: Color(config.scoreBogeyColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Bogey',
                      Color(config.scoreBogeyColor),
                      (c) => controller.setScoreBogeyColor(c),
                    ),
                  ),
                ],
              ),
              ResponsiveColorRow(
                children: [
                  StatusColorRow(
                    label: 'DOUBLE',
                    color: Color(config.scoreDoubleColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Double',
                      Color(config.scoreDoubleColor),
                      (c) => controller.setScoreDoubleColor(c),
                    ),
                  ),
                  StatusColorRow(
                    label: 'TRIPLE+',
                    color: Color(config.scoreTriplePlusColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Triple+',
                      Color(config.scoreTriplePlusColor),
                      (c) => controller.setScoreTriplePlusColor(c),
                    ),
                  ),
                ],
              ),
              ResponsiveColorRow(
                children: [
                  StatusColorRow(
                    label: 'SCORE COLOR',
                    color: Color(config.effectivePointsColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Score Color',
                      Color(config.effectivePointsColor),
                      (c) => controller.setPointsColor(c),
                    ),
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),

        const BoxyArtSectionTitle(title: 'Team Identity', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              ResponsiveColorRow(
                children: [
                  CompactColorPicker(
                    label: 'Team A',
                    color: Color(config.teamAColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Team A',
                      Color(config.teamAColor),
                      (c) => controller.setTeamAColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Team B',
                    color: Color(config.teamBColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Team B',
                      Color(config.teamBColor),
                      (c) => controller.setTeamBColor(c),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const BoxyArtSectionTitle(title: 'Advanced Color Tuning', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Directly override the core background and text color layers of the application.',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: AppTypography.weightMedium,
                  color: AppColors.dark600,
                ),
              ),
              ResponsiveColorRow(
                children: [
                  CompactColorPicker(
                    label: 'Page BG',
                    color: Color(config.backgroundColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Page Background',
                      Color(config.backgroundColor),
                      (c) => controller.setBackgroundColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Card BG',
                    color: Color(config.cardColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Card Background',
                      Color(config.cardColor),
                      (c) => controller.setCardColor(c),
                    ),
                  ),
                ],
              ),
              ResponsiveColorRow(
                children: [
                  CompactColorPicker(
                    label: 'Primary Text',
                    color: Color(config.textPrimaryColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Primary Text',
                      Color(config.textPrimaryColor),
                      (c) => controller.setTextPrimaryColor(c),
                    ),
                  ),
                  CompactColorPicker(
                    label: 'Secondary Text',
                    color: Color(config.textSecondaryColor),
                    onTap: () => BrandingHelper.pickColor(
                      context,
                      'Secondary Text',
                      Color(config.textSecondaryColor),
                      (c) => controller.setTextSecondaryColor(c),
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
