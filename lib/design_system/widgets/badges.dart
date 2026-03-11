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
  final bool isTinted;
  final bool showFill;
  final bool showBorder;
  final bool useCircle;
  final Color? iconColor;
  final Color? borderColor;
  final double? fillOpacity;

  const BoxyArtIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 38,
    this.iconSize = 18,
    this.isTinted = true,
    this.showFill = true,
    this.showBorder = false,
    this.useCircle = false,
    this.iconColor,
    this.borderColor,
    this.fillOpacity = 0.20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTinted) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(icon, size: iconSize, color: color),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showFill ? color.withValues(alpha: fillOpacity ?? AppColors.opacityLow) : Colors.transparent,
        shape: useCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: useCircle ? null : AppShapes.md,
        border: showBorder 
          ? Border.all(
              color: borderColor ?? color.withValues(alpha: 0.25),
              width: AppShapes.borderLight,
            )
          : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? color,
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
    
    // Spec: Rank #1 is amber, others are dark/neutral
    Color bg;
    Color fg;
    
    if (isRanking && number == 1) {
      bg = AppColors.amber500;
      fg = AppColors.dark900;
    } else {
      bg = AppColors.actionGreen.withValues(alpha: 0.20);
      fg = AppColors.dark900;
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
          fontWeight: AppTypography.weightExtraBold,
        ),
      ),
    );
  }
}

/// A standardized pill for status badges and tags (v3.1 3-family taxonomy).
class BoxyArtPill extends ConsumerWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final bool hasHorizontalMargin;
  final Widget? iconWidget;

  const BoxyArtPill({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.hasHorizontalMargin = true,
    this.iconWidget,
  });

  /// Factory for Competition Formats (Stableford, Matchplay, etc.)
  /// Spec: alpha 0.08 bg, 0.18 border, lime400 text
  factory BoxyArtPill.format({
    required String label,
    IconData? icon,
    Color? color,
  }) {
    return BoxyArtPill(
      label: label,
      color: color,
      icon: icon,
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
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    bool hasHorizontalMargin = true,
  }) {
    return BoxyArtPill(
      label: label,
      color: color,
      icon: icon,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      hasHorizontalMargin: hasHorizontalMargin,
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
      iconWidget: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: teeColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final config = ref.watch(themeControllerProvider);
    Color effectiveTextColor = textColor ?? AppColors.dark300;

    return Container(
      margin: EdgeInsets.only(
        left: hasHorizontalMargin ? AppSpacing.xs : 0,
        right: hasHorizontalMargin ? AppSpacing.xs : 0,
        top: 4,
        bottom: 4,
      ),
      padding: EdgeInsets.only(
        left: (backgroundColor != null || icon != null || hasHorizontalMargin) ? AppSpacing.sm : 0,
        right: AppSpacing.sm,
        top: 2,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor, // Will be null (transparent) for most pills
        borderRadius: BorderRadius.circular(config.pillRadius),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppShapes.iconXs, color: effectiveTextColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (iconWidget != null) ...[
            iconWidget!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            toTitleCase(label),
            style: AppTypography.caption.copyWith(
              fontSize: fontSize ?? AppTypography.sizeLabelStrong,
              color: effectiveTextColor,
              fontWeight: fontWeight ?? (isDark ? AppTypography.weightSemibold : AppTypography.weightBold),
              letterSpacing: letterSpacing,
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

    return Container(
      width: 52,
      constraints: const BoxConstraints(minHeight: 62),
      decoration: BoxDecoration(
        color: AppColors.actionGreen.withValues(alpha: 0.20),
        borderRadius: AppShapes.sm,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.sizeMicroSmall,
              color: isDark ? AppColors.pureWhite : AppColors.dark900,
              fontWeight: AppTypography.weightExtraBold,
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
              fontSize: AppTypography.sizeMicroSmall,
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
    if (!isPaid) {
      return BoxyArtPill(
        label: 'Fee due',
        color: AppColors.amber500,
        icon: Icons.info_outline_rounded,
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.dark400 : AppColors.dark300,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 12,
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Fee Paid',
              style: AppTypography.caption.copyWith(
                fontSize: AppTypography.sizeLabelStrong,
                color: isDark ? AppColors.dark150 : AppColors.dark800,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small square badge for indicators (Guerst, Buggy, etc.)
class BoxyArtSquareBadge extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? size;
  final bool isTinted;

  const BoxyArtSquareBadge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.size,
    this.isTinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final config = ref.watch(themeControllerProvider);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        Color bg = backgroundColor ?? (isDark ? AppColors.dark600 : AppColors.dark50);
        if (isTinted) {
          bg = AppColors.actionGreen.withValues(alpha: AppColors.opacityMedium);
        }

        return Container(
          width: size ?? 28,
          height: size ?? 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(config.pillRadius * 0.4),
          ),
          child: this.child,
        );
      },
    );
  }
}
