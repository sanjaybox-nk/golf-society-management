import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

/// A centralized icon badge for small indicators (location, time, etc.)
class BoxyArtIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const BoxyArtIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
    this.iconSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          icon,
          size: iconSize + 2, // Slightly larger since container is gone
          color: color,
        ),
      ),
    );
  }
}

/// A centralized number/position badge (e.g. for leaderboards).
class BoxyArtNumberBadge extends StatelessWidget {
  final int number;
  final Color? color;
  final Color? textColor;
  final double size;
  final bool isRanking;
  final bool isFilled;

  const BoxyArtNumberBadge({
    super.key,
    required this.number,
    this.color,
    this.textColor,
    this.size = 28,
    this.isRanking = true,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Spec: Rank #1 is amber, others are dark/neutral
    Color bg;
    Color fg;
    
    if (isRanking && number == 1) {
      bg = AppColors.amber500;
      fg = AppColors.dark900;
    } else if (isRanking && number == 2) {
      bg = isDark ? AppColors.dark600 : AppColors.dark150;
      fg = isDark ? AppColors.dark150 : AppColors.dark900;
    } else {
      bg = isDark ? AppColors.dark700 : AppColors.dark100;
      fg = isDark ? AppColors.dark200 : AppColors.dark300;
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: !isFilled ? Colors.transparent : (color ?? bg),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: AppTypography.caption.copyWith(
          color: textColor ?? (!isFilled ? AppColors.pureWhite : (color != null ? AppColors.pureWhite : fg)),
          fontSize: size * 0.45,
          fontWeight: AppTypography.weightBlack,
        ),
      ),
    );
  }
}

/// A standardized pill for status badges and tags (v3.1 3-family taxonomy).
class BoxyArtPill extends ConsumerWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const BoxyArtPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
  });

  /// Factory for Competition Formats (Stableford, Matchplay, etc.)
  /// Spec: alpha 0.08 bg, 0.18 border, lime400 text
  factory BoxyArtPill.format({
    required String label,
    IconData? icon,
  }) {
    return BoxyArtPill(
      label: label,
      color: AppColors.lime400,
      icon: icon,
      backgroundColor: AppColors.lime500.withValues(alpha: AppColors.opacitySubtle),
      borderColor: AppColors.lime500.withValues(alpha: AppColors.opacityMedium),
    );
  }

  /// Factory for Event Types (Invitational, Multi-day, etc.)
  /// Spec: bg-elevated bg, border-subtle, dark-100 text
  factory BoxyArtPill.type({
    required String label,
    IconData? icon,
  }) {
    return BoxyArtPill(
      label: label,
      color: AppColors.dark100,
      icon: icon,
      // No explicit bg/border colors, dynamic logic in build() will handle it
    );
  }

  /// Factory for Lifecycle Status (Published, Live, etc.)
  factory BoxyArtPill.status({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return BoxyArtPill(
      label: label,
      color: color,
      icon: icon,
      backgroundColor: color.withValues(alpha: AppColors.opacitySubtle),
      borderColor: color.withValues(alpha: AppColors.opacityMedium),
    );
  }

  /// Factory for Handicap (HC)
  factory BoxyArtPill.hc({
    required String label,
  }) {
    return BoxyArtPill(
      label: 'HC: $label',
      color: AppColors.dark150,
      icon: Icons.show_chart_rounded,
    );
  }

  /// Factory for Playing Handicap (PHC)
  factory BoxyArtPill.phc({
    required BuildContext context,
    required String label,
  }) {
    return BoxyArtPill(
      label: 'PHC: $label',
      color: Theme.of(context).primaryColor,
      icon: Icons.flash_on_rounded,
    );
  }

  /// Factory for Tee Marker
  factory BoxyArtPill.tee({
    required String label,
    required Color teeColor,
  }) {
    return BoxyArtPill(
      label: label,
      color: teeColor,
      backgroundColor: teeColor.withValues(alpha: AppColors.opacityLow),
      borderColor: teeColor.withValues(alpha: AppColors.opacityMuted),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Derived text color for better contrast in light mode
    Color effectiveTextColor = textColor ?? color;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppShapes.iconXs, color: effectiveTextColor),
            SizedBox(width: AppSpacing.xs),
          ] else ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: effectiveTextColor.withValues(alpha: AppColors.opacityHalf), 
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            toTitleCase(label),
            style: AppTypography.caption.copyWith(
              color: effectiveTextColor,
              fontWeight: isDark ? AppTypography.weightSemibold : AppTypography.weightExtraBold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A stylized date badge for event lists.
class BoxyArtDateBadge extends StatelessWidget {
  final DateTime date;
  final DateTime? endDate;
  final Color? highlightColor;

  const BoxyArtDateBadge({
    super.key, 
    required this.date,
    this.endDate,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMultiDay = endDate != null && !DateUtils.isSameDay(date, endDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // In light mode, we need much darker accent colors for text legibility
    Color accentColor = highlightColor ?? AppColors.lime500;
    Color effectiveLabelColor = accentColor;
    
    if (!isDark) {
      final hsl = HSLColor.fromColor(accentColor);
      effectiveLabelColor = hsl.withLightness((hsl.lightness - 0.45).clamp(0.0, 1.0)).toColor();
    }

    return Container(
      width: 52,
      constraints: const BoxConstraints(minHeight: 62),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppShapes.sm,
        border: Border.all(
          color: accentColor,
          width: highlightColor != null ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.sizeMicroSmall,
              color: effectiveLabelColor,
              fontWeight: AppTypography.weightBlack,
            ),
          ),
          Text(
            isMultiDay 
              ? '${date.day}-${endDate!.day}'
              : DateFormat('d').format(date),
            style: AppTypography.displayHero.copyWith(
              fontSize: isMultiDay ? 18 : 28,
              height: 1.0,
              color: isDark ? AppColors.pureWhite : AppColors.dark900,
            ),
          ),
          Text(
            DateFormat('yyyy').format(date),
            style: AppTypography.micro.copyWith(
              fontSize: AppTypography.sizeMicroSmall, // Keeping 9 for specialized multi-day logic but using micro as base
              color: isDark ? AppColors.dark300 : AppColors.dark400,
              fontWeight: AppTypography.weightSemibold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A specialized pill for fee status.
class BoxyArtFeePill extends StatelessWidget {
  final bool isPaid;
  final VoidCallback? onToggle;

  const BoxyArtFeePill({
    super.key,
    required this.isPaid,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.lime500 : AppColors.amber500;
    
    return GestureDetector(
      onTap: onToggle,
      child: BoxyArtPill(
        label: isPaid ? 'Fee paid' : 'Fee due',
        color: color,
        icon: isPaid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
      ),
    );
  }
}

/// A small square badge for indicators (Guerst, Buggy, etc.)
class BoxyArtSquareBadge extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? size;

  const BoxyArtSquareBadge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size ?? 24,
      height: size ?? 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.dark600 : AppColors.dark50),
        borderRadius: AppShapes.sm,
      ),
      child: child,
    );
  }
}
