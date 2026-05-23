import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';

/// A standardized event card used across the application (Member & Admin).
class BoxyArtEventCard extends ConsumerWidget {
  final GolfEvent event;
  final VoidCallback? onTap;
  final Widget? gameTypePill;
  final Widget? statusPill;
  final bool showStatus;
  final bool isHighlighted;
  final Gradient? gradient;
  final bool showSponsorStrip;

  const BoxyArtEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.gameTypePill,
    this.statusPill,
    this.showStatus = true,
    this.isHighlighted = false,
    this.gradient,
    this.showSponsorStrip = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

    Widget? activePill;
    if (showStatus && statusPill != null) {
      activePill = statusPill;
    } else if (statusPill == null && event.status == EventStatus.inPlay && event.occursToday) {
      activePill = BoxyArtIndicator.status(
        label: 'Live',
        color: theme.colorScheme.error,
        isAction: true,
        hasHorizontalMargin: false,
      );
    }

    final content = Stack(
      children: [
        Row(
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
                          _buildTag(label: 'Season', color: textColor),
                        if (event.isInvitational)
                          _buildTag(label: 'Invite', color: textColor),
                        if (event.eventType == EventType.social)
                          _buildTag(label: 'Social', color: textColor),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 2. Main Content Area — full width, no pill stealing space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  gameTypePill ?? const SizedBox.shrink(),
                  if (gameTypePill != null) const SizedBox(height: 4),
                  Text(
                    toTitleCase(event.title),
                    style: AppTypography.cardTitle.copyWith(color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                          style: TextStyle(color: subtextColor, fontWeight: AppTypography.weightSemibold),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                          text: DateFormat.Hm().format(event.regTime ?? event.date),
                          style: TextStyle(color: subtextColor, fontWeight: AppTypography.weightBold),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Space so pill never overlaps last metadata line
                  if (activePill != null) const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),

        // Status pill — bottom right, outside the Row
        if (activePill != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: activePill,
          ),
      ],
    );

    final double verticalPadding = spacing?.cardVerticalPadding ?? AppSpacing.standard;
    final double horizontalPadding = spacing?.cardHorizontalPadding ?? AppSpacing.standard;

    final eventSponsors = showSponsorStrip && !event.isClosed
        ? config.ledgerEntries.where((e) =>
            e.type == 'Sponsorship' &&
            e.scope?.toLowerCase() == 'event' &&
            e.eventId == event.id).toList()
        : <FinancialEntry>[];

    return BoxyArtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      gradient: isHighlighted
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(config.heroGradientColor).withValues(alpha: config.heroGradientOpacity),
                Color(config.heroGradientColorSecondary).withValues(alpha: config.heroGradientOpacity * 0.2),
              ],
            )
          : gradient,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 124),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: content,
            ),
            if (eventSponsors.isNotEmpty) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: isHighContrast
                    ? AppColors.pureWhite.withValues(alpha: 0.15)
                    : AppColors.dark500.withValues(alpha: 0.2),
              ),
              _SponsorStrip(
                sponsors: eventSponsors,
                isHighContrast: isHighContrast,
                horizontalPadding: horizontalPadding,
              ),
            ],
          ],
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
          style: AppTypography.micro.copyWith(
            color: color,
            fontWeight: AppTypography.weightBlack,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ── Event sponsor strip ───────────────────────────────────────────────────────

class _SponsorStrip extends StatelessWidget {
  final List<FinancialEntry> sponsors;
  final bool isHighContrast;
  final double horizontalPadding;

  const _SponsorStrip({
    required this.sponsors,
    required this.isHighContrast,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final muted = isHighContrast
        ? AppColors.pureWhite.withValues(alpha: 0.6)
        : AppColors.dark400;
    final textColor = isHighContrast ? AppColors.pureWhite : AppColors.dark900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.atomic),
      child: Row(
        children: [
          Text(
            'SPONSORED BY',
            style: AppTypography.micro.copyWith(
              color: muted,
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(width: AppSpacing.atomic),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.atomic,
              runSpacing: 4,
              children: sponsors.map((s) => _SponsorChip(
                entry: s,
                textColor: textColor,
                muted: muted,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorChip extends StatelessWidget {
  final FinancialEntry entry;
  final Color textColor;
  final Color muted;

  const _SponsorChip({required this.entry, required this.textColor, required this.muted});

  @override
  Widget build(BuildContext context) {
    final hasLogo = entry.logoUrl != null && entry.logoUrl!.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLogo) ...[
          _logo(entry.logoUrl!),
          const SizedBox(width: 4),
        ],
        Text(
          toTitleCase(entry.source),
          style: AppTypography.micro.copyWith(
            color: textColor,
            fontWeight: AppTypography.weightBold,
          ),
        ),
      ],
    );
  }

  Widget _logo(String url) {
    final isLocal = url.startsWith('/') || url.contains('cache');
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 20,
        height: 20,
        child: isLocal
            ? Image.file(File(url), fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const SizedBox.shrink())
            : BoxyArtImage(url: url, errorWidget: const SizedBox.shrink()),
      ),
    );
  }
}
