import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

/// Unified legend/pill indicator.
///
/// Default (showBackground: false) — dot + text, no container. Use for
/// inline metadata: HC, PHC, tee, status labels.
///
/// With showBackground: true — adds a tinted background and border, turning
/// the indicator into a contained pill badge. Use for tags that need to
/// stand out: format, event type, committee role, lifecycle status.
class BoxyArtIndicator extends ConsumerWidget {
  final String label;

  // Leading element — at most one used; priority: iconWidget > icon > dotColor
  final Color? dotColor;
  final IconData? icon;
  final Widget? iconWidget;

  // Container mode
  final bool showBackground;
  final bool isAction; // filled bg (no tint), for interactive action pills
  final Color? backgroundColor;
  final Color? borderColor;

  // Typography
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final Color? textColor;

  // Layout
  final bool hasHorizontalMargin;

  // Interaction
  final VoidCallback? onTap;
  final IconData? actionIcon;
  final bool showActionIcon;

  const BoxyArtIndicator({
    super.key,
    required this.label,
    this.dotColor,
    this.icon,
    this.iconWidget,
    this.showBackground = false,
    this.isAction = false,
    this.backgroundColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.textColor,
    this.hasHorizontalMargin = true,
    this.onTap,
    this.actionIcon,
    this.showActionIcon = true,
  });

  // ── Factories ──────────────────────────────────────────────────────────────

  factory BoxyArtIndicator.hc({
    required String label,
    bool hasHorizontalMargin = true,
    double? fontSize,
    FontWeight? fontWeight,
  }) =>
      BoxyArtIndicator(
        label: 'HC: $label',
        dotColor: AppColors.dark300,
        hasHorizontalMargin: hasHorizontalMargin,
        fontSize: fontSize ?? AppTypography.sizeLabel,
        fontWeight: fontWeight ?? FontWeight.w500,
      );

  factory BoxyArtIndicator.phc({
    required String label,
    bool hasHorizontalMargin = true,
    double? fontSize,
    FontWeight? fontWeight,
  }) =>
      BoxyArtIndicator(
        label: 'PHC: $label',
        dotColor: AppColors.amber500,
        hasHorizontalMargin: hasHorizontalMargin,
        fontSize: fontSize ?? AppTypography.sizeLabel,
        fontWeight: fontWeight ?? FontWeight.w500,
      );

  factory BoxyArtIndicator.tee({
    required String label,
    required Color teeColor,
    VoidCallback? onTap,
    bool hasHorizontalMargin = true,
    double? fontSize,
  }) =>
      BoxyArtIndicator(
        label: label,
        iconWidget: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: teeColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
          ),
        ),
        dotColor: teeColor,
        onTap: onTap,
        hasHorizontalMargin: hasHorizontalMargin,
        fontSize: fontSize ?? AppTypography.sizeMicro,
        showActionIcon: onTap != null,
      );

  factory BoxyArtIndicator.status({
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
  }) =>
      BoxyArtIndicator(
        label: label,
        dotColor: color,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        hasHorizontalMargin: hasHorizontalMargin,
        showBackground: !isLegend,
        isAction: isAction,
      );

  factory BoxyArtIndicator.format({
    required String label,
    IconData? icon,
    Color? color,
    double? fontSize,
    bool isLegend = false,
  }) =>
      BoxyArtIndicator(
        label: label,
        dotColor: color,
        icon: icon,
        showBackground: !isLegend,
        fontSize: fontSize,
      );

  factory BoxyArtIndicator.type({
    required String label,
    IconData? icon,
    double? fontSize,
    bool isLegend = false,
  }) =>
      BoxyArtIndicator(
        label: label,
        icon: icon,
        showBackground: !isLegend,
        fontSize: fontSize,
      );

  factory BoxyArtIndicator.committee({
    required String label,
    double? fontSize,
  }) =>
      BoxyArtIndicator(
        label: label.toUpperCase(),
        dotColor: AppColors.amber500,
        showBackground: true,
        backgroundColor: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
        borderColor: AppColors.amber500.withValues(alpha: AppColors.opacitySubtle),
        textColor: AppColors.dark900,
        fontSize: fontSize ?? AppTypography.sizeMicro,
        fontWeight: AppTypography.weightBold,
        letterSpacing: AppTypography.lsLabel,
        hasHorizontalMargin: false,
      );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);

    final bool isInteractive = onTap != null;
    final bool hasBg = showBackground || isAction || (isInteractive && showActionIcon);

    // Resolve color for dynamic (non-dotColor) pill variants
    Color? baseColor = dotColor;
    if (baseColor == null && hasBg) {
      if (isAction) {
        baseColor = Color(config.primaryColor);
      } else {
        // format/type: use neutral text colour for tinting
        baseColor = isDark ? AppColors.dark150 : AppColors.dark600;
      }
    }

    // Background / border
    Color? effectiveBg;
    Color? effectiveBorder;
    if (hasBg) {
      if (isAction) {
        effectiveBg = backgroundColor ?? baseColor;
        effectiveBorder = null;
      } else {
        effectiveBg = backgroundColor ?? baseColor?.withValues(alpha: AppColors.opacityFaint);
        effectiveBorder = borderColor ?? baseColor?.withValues(alpha: AppColors.opacityBorder);
      }
    }

    // Text colour
    final Color effectiveText = textColor ?? (
      isAction
          ? ContrastHelper.getContrastingText(effectiveBg ?? Colors.transparent)
          : (isDark ? AppColors.dark150 : AppColors.dark600)
    );

    // Leading widget
    Widget? leading;
    if (iconWidget != null) {
      leading = iconWidget!;
    } else if (icon != null) {
      leading = BoxyArtIconBadge(
        icon: icon!,
        color: baseColor ?? effectiveText,
        iconColor: isAction ? effectiveText : null,
        size: 18,
        iconSize: 10,
        useCircle: true,
        showFill: !isAction,
      );
    } else if (dotColor != null) {
      leading = Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 0.5),
        ),
      );
    }

    final double innerHPad = hasBg ? AppSpacing.md : (hasHorizontalMargin ? AppSpacing.xs : 0);

    final content = Container(
      margin: EdgeInsets.symmetric(
        horizontal: hasHorizontalMargin ? AppSpacing.xs : 0,
        vertical: 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: innerHPad,
        vertical: hasBg ? AppSpacing.xs : 2,
      ),
      decoration: hasBg
          ? BoxDecoration(
              color: effectiveBg,
              borderRadius: BorderRadius.circular(config.pillRadius),
              border: effectiveBorder != null
                  ? Border.all(color: effectiveBorder, width: 1)
                  : null,
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              toTitleCase(label).toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontSize: fontSize,
                color: effectiveText,
                fontWeight: fontWeight,
                letterSpacing: letterSpacing,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (isInteractive && showActionIcon) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              actionIcon ?? Icons.edit_rounded,
              size: 11,
              color: effectiveText.withValues(alpha: AppColors.opacityHigh),
            ),
          ],
        ],
      ),
    );

    if (isInteractive) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

// ── Convenience wrappers ───────────────────────────────────────────────────

class BoxyArtFeePill extends StatelessWidget {
  final bool isPaid;
  final VoidCallback? onToggle;
  final bool hasHorizontalMargin;

  const BoxyArtFeePill({
    super.key,
    required this.isPaid,
    this.onToggle,
    this.hasHorizontalMargin = true,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtStatusPill(
      isPaid: isPaid,
      onToggle: onToggle,
      paidLabel: 'Fee Paid',
      dueLabel: 'Fee due',
      hasHorizontalMargin: hasHorizontalMargin,
    );
  }
}

class BoxyArtStatusPill extends StatelessWidget {
  final bool isPaid;
  final String paidLabel;
  final String dueLabel;
  final Color? color;
  final IconData? customActionIcon;
  final VoidCallback? onToggle;
  final bool hasHorizontalMargin;
  final bool showActionIcon;

  const BoxyArtStatusPill({
    super.key,
    required this.isPaid,
    this.paidLabel = 'Paid',
    this.dueLabel = 'Due',
    this.color,
    this.customActionIcon,
    this.onToggle,
    this.hasHorizontalMargin = true,
    this.showActionIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = color ?? theme.primaryColor;
    final dotColor = isPaid ? statusColor : (color ?? AppColors.amber500);

    return BoxyArtIndicator(
      label: isPaid ? paidLabel : dueLabel,
      dotColor: dotColor,
      onTap: onToggle,
      actionIcon: customActionIcon,
      hasHorizontalMargin: hasHorizontalMargin,
      showActionIcon: showActionIcon,
    );
  }
}
