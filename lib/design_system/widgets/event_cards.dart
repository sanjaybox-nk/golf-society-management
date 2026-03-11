import 'package:intl/intl.dart';
import '../design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';

/// A standardized event card used across the application (Member & Admin).
class BoxyArtEventCard extends StatelessWidget {
  final GolfEvent event;
  final VoidCallback? onTap;
  final Widget? gameTypePill;
  final Widget? statusPill;
  final bool showStatus;

  const BoxyArtEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.gameTypePill,
    this.statusPill,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final textSecondary = theme.textTheme.bodySmall?.color;

    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Date Badge
          BoxyArtDateBadge(
            date: event.date,
            endDate: event.endDate,
            highlightColor: event.isInvitational
                ? AppColors.amber500
                : (event.eventType == EventType.social ? AppColors.coral500 : null),
          ),
          const SizedBox(width: 14),

          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: AppTypography.weightExtraBold,
                    fontSize: AppTypography.sizeUI,
                    letterSpacing: -0.4,
                  ),
                ),
                
                // Tags (Invitational, Social, Multi-day)
                if (event.isInvitational || event.isMultiDay || event.eventType == EventType.social) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (event.isInvitational)
                        _buildTag(
                          label: 'Invitational event',
                          color: AppColors.amber500,
                          icon: Icons.star_rounded,
                        ),
                      if (event.eventType == EventType.social)
                        _buildTag(
                          label: 'Social event',
                          color: AppColors.coral500,
                          icon: Icons.favorite_rounded,
                        ),
                      if (event.isMultiDay)
                        Text(
                          'Multi-day',
                          style: AppTypography.caption.copyWith(
                            color: textSecondary?.withValues(alpha: 0.6),
                            fontWeight: AppTypography.weightBlack,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),

                // Location Row
                Row(
                  children: [
                    BoxyArtIconBadge(
                      icon: Icons.location_on_rounded,
                      color: primary,
                      showFill: false,
                      showBorder: false,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        event.courseName ?? 'TBA',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: AppTypography.sizeLabelStrong,
                          fontWeight: AppTypography.weightSemibold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Time Row
                Row(
                  children: [
                    BoxyArtIconBadge(
                      icon: Icons.access_time_filled_rounded,
                      color: AppColors.dark600,
                      showFill: false,
                      showBorder: false,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Registration: ${DateFormat('h:mm a').format(event.regTime ?? event.date)}',
                      style: TextStyle(
                        color: textSecondary?.withValues(alpha: 0.75),
                        fontSize: AppTypography.sizeLabel,
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),

                // Bottom Pill Row
                if (gameTypePill != null || (statusPill != null && showStatus)) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (gameTypePill != null) gameTypePill!,
                      if (statusPill != null && showStatus) statusPill!,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({required String label, required Color color, required IconData icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: AppTypography.weightBlack,
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
