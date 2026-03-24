import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

/// A centralized icon badge for small indicators (location, time, etc.)
class BoxyArtIconBadge extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isTinted) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(icon, size: iconSize, color: color),
        ),
      );
    }

    final config = ref.watch(themeControllerProvider);
    
    // Logic: If the provided color is roughly the "Action Color" (default behavior), 
    // we allow the branding config to override it.
    final bool isStandardAction = color.toARGB32() == config.secondaryColor || color.toARGB32() == 0xFF4ADE80;
    
    // Design 4.x: Always prioritize the global iconBadgeOpacity token for the fill alpha
    final double effectiveOpacity = fillOpacity ?? config.iconBadgeOpacity;
    
    final Color effectiveFill = showFill 
      ? (isStandardAction ? Color(config.iconBadgeFillColor) : color.withValues(alpha: effectiveOpacity))
      : Colors.transparent;
      
    final Color effectiveIconColor = iconColor ?? (isStandardAction ? Color(config.iconBadgeIconColor) : color);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveFill,
        shape: useCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: useCircle ? null : BorderRadius.circular(Theme.of(context).extension<AppShapeTokens>()?.accentRadius ?? AppShapes.rMd),
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
          color: effectiveIconColor.withValues(alpha: config.iconOpacity),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Spec: Rank #1 is amber, others are dark/neutral
    Color bg;
    Color fg;
    
    if (isRanking) {
      if (number == 1) {
        bg = AppColors.amber500;
        fg = AppColors.pureWhite;
      } else if (number == 2) {
        bg = isDark ? AppColors.dark200 : AppColors.dark600;
        fg = AppColors.pureWhite;
      } else if (number == 3) {
        bg = const Color(0xFFCD7F32); // Bronze
        fg = AppColors.pureWhite;
      } else {
        bg = isDark ? AppColors.dark600 : AppColors.dark100;
        fg = isDark ? AppColors.dark100 : AppColors.dark800;
      }
    } else {
      bg = Theme.of(context).primaryColor.withValues(alpha: 0.20);
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
      color: color ?? AppColors.lime400,
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
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    bool hasHorizontalMargin = true,
  }) {
    return BoxyArtPill(
      label: label,
      color: color,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      hasHorizontalMargin: hasHorizontalMargin,
    );
  }

  /// Factory for Handicap (HC)
  factory BoxyArtPill.hc({
    required String label,
    IconData? icon = Icons.show_chart_rounded,
    bool hasHorizontalMargin = true,
  }) {
    return BoxyArtPill(
      label: 'HC: $label',
      color: AppColors.dark150,
      icon: icon,
      hasHorizontalMargin: hasHorizontalMargin,
    );
  }

  /// Factory for Playing Handicap (PHC)
  factory BoxyArtPill.phc({
    required BuildContext context,
    required String label,
    IconData? icon = Icons.flash_on_rounded,
    bool hasHorizontalMargin = true,
  }) {
    return BoxyArtPill(
      label: 'PHC: $label',
      color: Theme.of(context).primaryColor,
      icon: icon,
      hasHorizontalMargin: hasHorizontalMargin,
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
    
    // Effective Colors derived from 'color' if specific ones aren't provided
    final Color effectiveBgColor = backgroundColor ?? (color?.withValues(alpha: 0.08) ?? Colors.transparent);
    final Color? effectiveBorderColor = borderColor ?? (color?.withValues(alpha: 0.18));
    final Color effectiveTextColor = textColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900);

    return Container(
      margin: EdgeInsets.only(
        left: hasHorizontalMargin ? AppSpacing.xs : 0,
        right: hasHorizontalMargin ? AppSpacing.xs : 0,
        top: 2,
        bottom: 2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(config.pillRadius),
        border: effectiveBorderColor != null ? Border.all(color: effectiveBorderColor, width: 1) : null,
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
          Flexible(
            child: Text(
              label.contains(':') ? label : toTitleCase(label),
              style: AppTypography.caption.copyWith(
                fontSize: fontSize ?? AppTypography.sizeLabelStrong,
                color: effectiveTextColor,
                fontWeight: fontWeight ?? AppTypography.weightRegular,
                letterSpacing: letterSpacing,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(Theme.of(context).extension<AppShapeTokens>()?.accentRadius ?? AppShapes.rSm),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.sizeMicroSmall,
              color: isDark ? AppColors.pureWhite : AppColors.dark900,
              fontWeight: AppTypography.weightExtraBold,
              height: 1.0,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isMultiDay 
                ? '${date.day}-${endDate!.day}'
                : DateFormat('d').format(date),
              style: AppTypography.displayHero.copyWith(
                fontSize: 24, 
                height: 1.0,
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
              ),
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
                  color: theme.primaryColor,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 12,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Fee Paid',
              style: AppTypography.caption.copyWith(
                fontSize: AppTypography.sizeLabelStrong,
                color: theme.primaryColor,
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
        final theme = Theme.of(context);
        final config = ref.watch(themeControllerProvider);
        final isDark = theme.brightness == Brightness.dark;

        Color bg = backgroundColor ?? (isDark ? AppColors.dark600 : AppColors.dark50);
        if (isTinted) {
          bg = Color(config.iconBadgeFillColor).withValues(alpha: config.iconBadgeOpacity);
        }

        return Container(
          width: size ?? 28,
          height: size ?? 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(config.accentRadius),
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: Color(config.iconBadgeIconColor).withValues(alpha: config.iconOpacity)),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: Color(config.iconBadgeIconColor).withValues(alpha: config.iconOpacity),
                ),
                child: this.child,
                ),
              ),
            ),
          );
      },
    );
  }
}
