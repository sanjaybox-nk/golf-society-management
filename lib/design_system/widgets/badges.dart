import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

/// A centralized icon badge for small indicators (location, time, etc.)
class BoxyArtIconBadge extends ConsumerWidget {
  final IconData icon;
  final Color color;
  final double? size;
  final double? iconSize;
  final bool isTinted;
  final bool showFill;
  final bool showBorder;
  final bool useCircle;
  final Color? iconColor;
  final Color? borderColor;
  final double? fillOpacity;
  final String? tooltip;

  const BoxyArtIconBadge({
    super.key,
    required this.icon,
    this.color = Colors.transparent,
    this.size,
    this.iconSize,
    this.isTinted = true,
    this.showFill = true,
    this.showBorder = false,
    this.useCircle = false,
    this.iconColor,
    this.borderColor,
    this.fillOpacity,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shapeTokens = Theme.of(context).extension<AppShapeTokens>();
    final double effectiveSize = size ?? shapeTokens?.iconBadgeSize ?? 38.0;
    final double effectiveIconSize = iconSize ?? shapeTokens?.iconBadgeIconSize ?? 18.0;

    if (!isTinted) {
      return SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: Center(
          child: Icon(icon, size: effectiveIconSize, color: color),
        ),
      );
    }

    final config = ref.watch(themeControllerProvider);
    
    final double effectiveOpacity = fillOpacity ?? shapeTokens?.iconBadgeOpacity ?? config.iconBadgeOpacity;
    
    final Color effectiveFill = showFill 
      ? (shapeTokens?.iconBadgeFill ?? Color(config.iconBadgeFillColor)).withValues(alpha: effectiveOpacity)
      : Colors.transparent;
      
    final Color effectiveIconColor = iconColor ?? (shapeTokens?.iconBadgeIcon ?? (color != Colors.transparent ? color : Color(config.iconBadgeIconColor)));

    final Widget content = Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: effectiveFill,
        shape: useCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: useCircle ? null : BorderRadius.circular(config.accentRadius),
        border: showBorder 
          ? Border.all(
              color: Color(config.iconBadgeFillColor).withValues(alpha: 0.2),
              width: 1.0,
            )
          : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: effectiveIconSize,
          color: effectiveIconColor,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: content,
      );
    }

    return content;
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
          fontWeight: AppTypography.weightBold,
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
  final bool isLegend;
  final bool isAction;
  final bool isFormat;
  final bool isType;

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
    this.isLegend = false,
    this.isAction = false,
    this.isFormat = false,
    this.isType = false,
  });

  /// Factory for Competition Formats (Stableford, Matchplay, etc.)
  /// Spec: Dynamic dark/light matching Neutral Scale
  factory BoxyArtPill.format({
    required String label,
    IconData? icon,
    Color? color,
  }) {
    return BoxyArtPill(
      label: label,
      color: color, 
      icon: icon,
      isLegend: false,
      isFormat: true,
    );
  }

  /// Factory for Event Types (Invitational, Multi-day, etc.)
  /// Spec: Dynamic Accent Scale
  factory BoxyArtPill.type({
    required String label,
    IconData? icon,
  }) {
    return BoxyArtPill(
      label: label,
      icon: icon,
      isLegend: true,
      isType: true,
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
    bool isLegend = false,
    bool isAction = false,
  }) {
    // For high-contrast Action Pills, we enforce the brand lime color by default
    final effectiveColor = isAction ? color : color;
    
    return BoxyArtPill(
      label: label,
      color: effectiveColor,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      hasHorizontalMargin: hasHorizontalMargin,
      isLegend: isLegend,
      isAction: isAction,
    );
  }

  factory BoxyArtPill.hc({
    required String label,
    IconData? icon,
    bool hasHorizontalMargin = true,
  }) {
    return BoxyArtPill(
      label: 'HC: $label',
      color: AppColors.dark400, // Design 4.x: Stronger neutral for HC
      icon: icon,
      hasHorizontalMargin: hasHorizontalMargin,
      fontSize: AppTypography.sizeMicro,
      fontWeight: AppTypography.weightHeavy,
    );
  }

  /// Factory for Playing Handicap (PHC)
  factory BoxyArtPill.phc({
    required BuildContext context,
    required String label,
    IconData? icon,
    bool hasHorizontalMargin = true,
  }) {
    return BoxyArtPill(
      label: 'PHC: $label',
      color: Theme.of(context).primaryColor,
      icon: icon,
      hasHorizontalMargin: hasHorizontalMargin,
      fontSize: AppTypography.sizeMicro,
      fontWeight: AppTypography.weightHeavy,
    );
  }

  /// Factory for Committee/Society Roles
  factory BoxyArtPill.committee({
    required String label,
  }) {
    return BoxyArtPill(
      label: label.toUpperCase(),
      color: AppColors.amber500,
      backgroundColor: AppColors.amber500.withValues(alpha: 0.1),
      borderColor: AppColors.amber500.withValues(alpha: 0.3),
      textColor: AppColors.dark400,
      fontSize: 10,
      fontWeight: AppTypography.weightBold,
      letterSpacing: 0.5,
      hasHorizontalMargin: false,
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
    
    Color? baseColor = color;
    if (isFormat && color == null) {
      baseColor = isDark ? AppColors.dark150 : AppColors.dark600;
    } else if (isType && color == null) {
      baseColor = Color(config.secondaryColor);
    }
    
    final Color? baseBorderColor = borderColor ?? (baseColor?.withValues(alpha: 0.18));
    
    bool showFill = !isLegend || isAction;
    bool showBorder = !isLegend && !isAction && baseBorderColor != null;

    final Color effectiveBgColor = backgroundColor ?? (
      isAction 
        ? (baseColor ?? AppColors.lime500)
        : (showFill ? (baseColor?.withValues(alpha: 0.08) ?? Colors.transparent) : Colors.transparent)
    );
    final Color? effectiveBorderColorActual = showBorder ? baseBorderColor : null;
    final Color effectiveTextColor = textColor ?? (
      isAction 
        ? ContrastHelper.getContrastingText(effectiveBgColor) 
        : (isFormat || isType 
            ? (baseColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900))
            : (isDark ? AppColors.pureWhite : AppColors.dark900))
    );

    return Container(
      margin: EdgeInsets.only(
        left: hasHorizontalMargin ? AppSpacing.xs : 0,
        right: hasHorizontalMargin ? AppSpacing.xs : 0,
        top: 2,
        bottom: 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isLegend ? 0 : AppSpacing.sm,
        vertical: isLegend ? 0 : 3,
      ),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(config.pillRadius),
        border: effectiveBorderColorActual != null ? Border.all(color: effectiveBorderColorActual, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLegend) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (icon != null && !isLegend) ...[
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
              style: AppTypography.label.copyWith(
                fontSize: fontSize ?? AppTypography.sizeLabel,
                color: effectiveTextColor,
                fontWeight: fontWeight ?? AppTypography.weightBold,
                letterSpacing: letterSpacing ?? AppTypography.lsLabel,
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
class BoxyArtDateBadge extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMultiDay = endDate != null && !DateUtils.isSameDay(date, endDate);
    final config = ref.watch(themeControllerProvider);

    // Design 4.x: Use branding tokens for the date badge background
    final Color effectiveBg = Color(config.iconBadgeFillColor).withValues(alpha: config.iconBadgeOpacity);
    final Color effectiveLabelColor = Color(config.iconBadgeIconColor);

    return Container(
      width: 52,
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(config.accentRadius),
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
              color: effectiveLabelColor,
              fontWeight: AppTypography.weightBold,
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
                color: AppColors.dark500,
              ),
            ),
          ),
          Text(
            DateFormat('yyyy').format(date),
            style: AppTypography.micro.copyWith(
              fontSize: AppTypography.sizeMicroSmall,
              color: AppColors.dark500,
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
    return BoxyArtStatusPill(
      isPaid: isPaid,
      onToggle: onToggle,
      paidLabel: 'Fee Paid',
      dueLabel: 'Fee due',
    );
  }
}

class BoxyArtStatusPill extends StatelessWidget {
  final bool isPaid;
  final String paidLabel;
  final String dueLabel;
  final Color? color;
  final VoidCallback? onToggle;

  const BoxyArtStatusPill({
    super.key,
    required this.isPaid,
    this.paidLabel = 'Paid',
    this.dueLabel = 'Due',
    this.color,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = color ?? theme.primaryColor;

    final Widget child = isPaid 
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2), // Reduced for overflow safety
            child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                paidLabel,
                style: AppTypography.caption.copyWith(
                  fontSize: AppTypography.sizeLabelStrong,
                  color: statusColor,
                  fontWeight: AppTypography.weightBold,
                ),
              ),
            ],
          ),
        )
      : BoxyArtPill(
          label: dueLabel,
          color: color ?? AppColors.amber500,
          icon: isPaid ? null : Icons.info_outline_rounded,
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: child,
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
        final shapeTokens = Theme.of(context).extension<AppShapeTokens>();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        Color bg = backgroundColor ?? (isDark ? AppColors.dark600 : AppColors.dark50);
        if (isTinted) {
          bg = (shapeTokens?.iconBadgeFill ?? Color(config.iconBadgeFillColor))
              .withValues(alpha: shapeTokens?.iconBadgeOpacity ?? config.iconBadgeOpacity);
        }

        final Color effectiveIconColor = shapeTokens?.iconBadgeIcon ?? Color(config.iconBadgeIconColor);

        return Container(
          width: size ?? 28,
          height: size ?? 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(shapeTokens?.accentRadius ?? config.accentRadius),
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: effectiveIconColor.withValues(alpha: config.iconOpacity)),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: effectiveIconColor.withValues(alpha: config.iconOpacity),
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
