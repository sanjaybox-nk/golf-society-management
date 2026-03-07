import 'package:intl/intl.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';


class DashboardHeroCard extends StatelessWidget {
  final GolfEvent event;
  final VoidCallback onTap;

  const DashboardHeroCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Premium Gradient
    final gradient = LinearGradient(
      colors: [
        theme.primaryColor,
        theme.primaryColor.withValues(alpha: AppColors.opacityHigh),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x2l),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppShapes.x2l,
        boxShadow: AppShadows.softScale,
      ),
      child: ClipRRect(
        borderRadius: AppShapes.x2l,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x2l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite.withValues(alpha: AppColors.opacityMedium),
                          borderRadius: AppShapes.xl,
                        ),
                        child: Text(
                          'NEXT EVENT',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHalf), size: AppShapes.iconSm),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    event.title,
                    style: AppTypography.displaySubPage.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh), size: AppShapes.iconXs),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('EEEE, d MMMM').format(event.date),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.pureWhite.withValues(alpha: AppColors.opacityStrong),
                          fontWeight: AppTypography.weightMedium,
                        ),
                      ),
                    ],
                  ),
                  if (event.courseName != null && event.courseName!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh), size: AppShapes.iconXs),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          event.courseName!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.pureWhite.withValues(alpha: AppColors.opacityStrong),
                            fontWeight: AppTypography.weightMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.x2l),
                  
                  // Progress / Stats
                  Row(
                    children: [
                      _buildMiniStat(
                        'PLAYING',
                        '${event.playingCount}',
                        '/${event.maxParticipants ?? 40}',
                      ),
                      const SizedBox(width: AppSpacing.x3l),
                      _buildMiniStat(
                        'WAITLIST',
                        '${event.waitlistCount}',
                        '',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.microSmall.copyWith(
            color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHalf),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.displaySection.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            if (total.isNotEmpty)
              Text(
                total,
                style: AppTypography.label.copyWith(
                  color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHalf),
                  fontWeight: AppTypography.weightMedium,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
