import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/golf_event.dart';

/// A standardized event card used across the application (Member & Admin).
class BoxyArtEventCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final textSecondary = theme.textTheme.bodySmall?.color;
    final config = ref.watch(themeControllerProvider);
    final spacing = theme.extension<AppSpacingTokens>();

    final accentColor = event.isInvitational
        ? AppColors.amber500
        : (event.eventType == EventType.social ? AppColors.coral500 : primary);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Identity Column (Badge + Tags)
        SizedBox(
          width: 72, // Fixed width for alignment consistency
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxyArtDateBadge(
                date: event.date,
                endDate: event.endDate,
                highlightColor: event.isInvitational
                    ? AppColors.amber500
                    : (event.eventType == EventType.social ? AppColors.coral500 : null),
              ),
              if (event.isInvitational || event.eventType == EventType.social || event.isSeasonEvent) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (event.isSeasonEvent)
                      _buildTag(
                        label: 'Season', // Shortened for left column fit
                        color: primary,
                      ),
                    if (event.isInvitational)
                      _buildTag(
                        label: 'Invite', // Shortened
                        color: AppColors.amber500,
                      ),
                    if (event.eventType == EventType.social)
                      _buildTag(
                        label: 'Social',
                        color: AppColors.coral500,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16), // Slightly reduced from 20 due to fixed 72 column

        // 2. Main Content Area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header Row: Title & Game Type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      toTitleCase(event.title),
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                        fontWeight: AppTypography.weightExtraBold,
                        fontSize: AppTypography.sizeBody,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (gameTypePill != null || event.isRegistrationOpen || (event.status == EventStatus.inPlay && event.occursToday)) 
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (gameTypePill != null) gameTypePill!,
                          if (event.status == EventStatus.inPlay && event.occursToday)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.xs),
                              child: BoxyArtPill.status(
                                label: 'Live',
                                color: AppColors.coral500,
                                backgroundColor: AppColors.coral500,
                                textColor: AppColors.pureWhite,
                              ),
                            ),
                          if (event.isRegistrationOpen)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.xs),
                              child: BoxyArtPill.status(
                                label: 'Register Now',
                                color: AppColors.actionGreen,
                                backgroundColor: AppColors.actionGreen,
                                textColor: AppColors.pureWhite,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const Spacer(),

              // Bottom Metadata Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Row
                        Text.rich(
                          TextSpan(
                            style: AppTypography.subtext.copyWith(
                              color: isDark ? AppColors.dark150 : AppColors.dark700,
                              fontSize: 13,
                              fontWeight: AppTypography.weightSemibold,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(Icons.flag_rounded, size: 14, color: AppColors.dark300),
                                ),
                              ),
                              TextSpan(
                                text: event.courseName ?? 'TBA',
                                style: TextStyle(
                                  color: AppColors.dark300,
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Time Row
                        Text.rich(
                          TextSpan(
                            style: AppTypography.subtext.copyWith(
                              color: isDark ? AppColors.dark150 : AppColors.dark700,
                              fontSize: 13,
                              fontWeight: AppTypography.weightSemibold,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(Icons.timer_rounded, size: 14, color: AppColors.dark300),
                                ),
                              ),
                              TextSpan(
                                text: DateFormat('h:mm a').format(event.regTime ?? event.date),
                                style: TextStyle(
                                  color: AppColors.dark300,
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  if (statusPill != null && showStatus) 
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: statusPill!,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final double verticalPadding = spacing?.cardVerticalPadding ?? AppSpacing.standard;
    final double horizontalPadding = spacing?.cardHorizontalPadding ?? AppSpacing.standard;

    return BoxyArtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 124),
        child: IntrinsicHeight(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildTag({required String label, required Color color, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label.toUpperCase(),
          style: AppTypography.caption.copyWith(
            color: color.withValues(alpha: 0.8),
            fontWeight: AppTypography.weightBlack,
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
