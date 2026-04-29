
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';

class BrandingPreviewCard extends StatelessWidget {
  final SocietyConfig config;

  const BrandingPreviewCard({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final primary = Color(config.primaryColor);
    final tertiary = Color(config.tertiaryColor);
    final textPrimary = Color(config.textPrimaryColor);
    final textSecondary = Color(config.textSecondaryColor);
    final textMuted = Color(config.textMutedColor);
    final cardColor = Color(config.cardColor);
    final elevatedColor = Color(config.surfaceElevatedColor);
    final borderColor = Color(config.borderColor);
    final dividerColor = Color(config.dividerColor);

    final iconBadgeFill = Color(config.iconBadgeFillColor);
    final iconBadgeIcon = Color(config.iconBadgeIconColor);
    
    final bool isDark =
        config.themeMode == 'dark' ||
        (config.themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    final finalBgColor = isDark ? elevatedColor : cardColor;
    
    final pText = isDark ? AppColors.pureWhite : textPrimary;
    final sText = isDark ? AppColors.dark150 : textSecondary;
    final mText = isDark ? AppColors.dark200 : textMuted;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      showShadow: config.useShadows,
      child: Column(
        children: [
          const BoxyArtSectionTitle(title: 'LIVE PREVIEW', isLevel2: true),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: config.cardVerticalPadding,
              horizontal: config.cardHorizontalPadding,
            ),
            decoration: BoxDecoration(
              color: finalBgColor,
              borderRadius: BorderRadius.circular(config.cardRadius),
              border: config.useBorders
                  ? Border.all(
                      color: borderColor,
                      width: config.borderWidth,
                    )
                  : null,
              boxShadow: config.useShadows
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: config.shadowOpacity * config.shadowIntensity.clamp(0.0, 1.0)),
                        blurRadius: 20 * config.shadowIntensity,
                        offset: Offset(0, 4 * config.shadowIntensity),
                        spreadRadius: config.shadowSpread,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: tertiary.withValues(alpha: AppColors.opacityLow),
                      radius: 20,
                      child: Icon(Icons.person, color: tertiary, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontWeight: AppTypography.weightBlack,
                              fontSize: AppTypography.sizeBody,
                              color: pText,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Premium Member • 14.2 HC',
                            style: TextStyle(
                              color: sText,
                              fontSize: 12,
                              fontWeight: AppTypography.weightSemibold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconBadgeFill.withValues(alpha: config.iconBadgeOpacity),
                        borderRadius: BorderRadius.circular(config.accentRadius),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: iconBadgeIcon.withValues(alpha: config.iconOpacity),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Next Competition: Spring Trophy',
                  style: TextStyle(
                    color: mText,
                    fontSize: 11,
                    fontWeight: AppTypography.weightBold,
                    letterSpacing: 0.5,
                  ),
                ),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: dividerColor.withValues(alpha: 0.3),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: ContrastHelper.getContrastingText(primary),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(config.buttonRadius),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'JOIN',
                            style: TextStyle(
                              fontWeight: AppTypography.weightBlack,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tertiary,
                            foregroundColor: ContrastHelper.getContrastingText(tertiary),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(config.buttonRadius),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'DETAILS',
                            style: TextStyle(
                              fontWeight: AppTypography.weightBlack,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const BoxyArtSectionTitle(title: 'STYLE SETTINGS', isLevel2: true),
        ],
      ),
    );
  }
}
