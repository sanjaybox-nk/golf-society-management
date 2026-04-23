import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/golf_event.dart';

/// A standardized event card used across the application (Member & Admin).
class BoxyArtEventCard extends ConsumerWidget {
  final GolfEvent event;
  final VoidCallback? onTap;
  final Widget? gameTypePill;
  final Widget? statusPill;
  final bool showStatus;
  final bool isHighlighted;
  final Gradient? gradient;

  const BoxyArtEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.gameTypePill,
    this.statusPill,
    this.showStatus = true,
    this.isHighlighted = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final spacing = theme.extension<AppSpacingTokens>();
    final config = ref.watch(themeControllerProvider);

    final isHighContrast = isHighlighted || gradient != null;
    final textColor = isHighContrast 
        ? AppColors.pureWhite 
        : (isDark ? AppColors.pureWhite : AppColors.dark900);
    final subtextColor = isHighContrast 
        ? AppColors.pureWhite.withValues(alpha: 0.8) 
        : (isDark ? AppColors.dark150 : AppColors.dark700);
    final iconColor = isHighContrast 
        ? AppColors.pureWhite.withValues(alpha: 0.6) 
        : AppColors.dark300;

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Identity Column (Badge + Tags)
        SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxyArtDateBadge(
                date: event.date,
                endDate: event.endDate,
                highlightColor: event.isInvitational
                    ? Color(config.secondaryColor)
                    : (event.eventType == EventType.social ? Color(config.secondaryColor) : null),
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
                        label: 'Season',
                        color: textColor,
                      ),
                    if (event.isInvitational)
                      _buildTag(
                        label: 'Invite',
                        color: textColor,
                      ),
                    if (event.eventType == EventType.social)
                      _buildTag(
                        label: 'Social',
                        color: textColor,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 2. Main Content Area (Flexible)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start, // Aligned to top with badge
            children: [
              Text(
                toTitleCase(event.title),
                style: AppTypography.cardTitle.copyWith(
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Metadata: Location
              Text.rich(
                TextSpan(
                  style: AppTypography.subtext.copyWith(
                    color: subtextColor,
                    fontSize: 13,
                    fontWeight: AppTypography.weightSemibold,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.flag_rounded, size: 14, color: iconColor),
                      ),
                    ),
                    TextSpan(
                      text: event.courseName ?? 'TBA',
                      style: TextStyle(
                        color: subtextColor,
                        fontWeight: AppTypography.weightSemibold,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Metadata: Time
              Text.rich(
                TextSpan(
                  style: AppTypography.subtext.copyWith(
                    color: subtextColor,
                    fontSize: 13,
                    fontWeight: AppTypography.weightSemibold,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.timer_rounded, size: 14, color: iconColor),
                      ),
                    ),
                    TextSpan(
                      text: DateFormat('h:mm a').format(event.regTime ?? event.date),
                      style: TextStyle(
                        color: subtextColor,
                        fontWeight: AppTypography.weightBold,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 3. Action / Status Column (Far Right)
        const SizedBox(width: AppSpacing.sm),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Game Type (Top Right)
            if (gameTypePill != null)
              gameTypePill!, // Using ! here because of the if-null check pattern
            
            // Status (Bottom Right)
            if (showStatus && statusPill != null)
              statusPill!, 
            
            // Live Indicator (Fallback / Secondary Status)
            if (statusPill == null && event.status == EventStatus.inPlay && event.occursToday)
              BoxyArtPill.status(
                label: 'Live',
                color: theme.colorScheme.error,
                isAction: true,
                hasHorizontalMargin: false,
              ),
          ],
        ),
      ],
    );

    final double verticalPadding = spacing?.cardVerticalPadding ?? AppSpacing.standard;
    final double horizontalPadding = spacing?.cardHorizontalPadding ?? AppSpacing.standard;

    return BoxyArtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      gradient: isHighlighted ? AppGradients.brandPrimary(context) : gradient,
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
