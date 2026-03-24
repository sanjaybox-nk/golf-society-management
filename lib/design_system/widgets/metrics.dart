import 'package:golf_society/design_system/design_system.dart';

/// A horizontal metrics bar often used in header sections.
class ModernMetricBar extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const ModernMetricBar({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }
}

/// A compact or prominent metric used in registration and summary views.
class ModernMetricStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isCompact;
  final bool isSolid;
  final Color? iconColor;

  const ModernMetricStat({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.isCompact = false,
    this.isSolid = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapeTokens = theme.extension<AppShapeTokens>();
    final accentRadius = shapeTokens?.accent ?? BorderRadius.circular(12);
    final accentOpacity = shapeTokens?.accentOpacity ?? 0.15;
    
    // Design Standard: Action background + Control Setting Glyph
    final defaultBg = shapeTokens?.iconBadgeFill ?? theme.colorScheme.secondary;
    final defaultIconColor = shapeTokens?.iconBadgeIcon ?? 
                             (isSolid ? AppColors.pureWhite : AppColors.dark900);
    final badgeOpacity = shapeTokens?.iconBadgeOpacity ?? 1.0;

    final effectiveBgColor = color ?? defaultBg;
    final effectiveIconColor = iconColor ?? (color != null 
        ? (isSolid ? AppColors.pureWhite : AppColors.dark900)
        : defaultIconColor);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: (theme.extension<AppSpacingTokens>()?.cardVerticalPadding ?? AppSpacing.lg) * (isCompact ? 0.6 : 0.8),
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: effectiveBgColor.withValues(alpha: badgeOpacity),
        borderRadius: accentRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon, 
              size: isCompact ? AppShapes.iconSm : AppShapes.iconMd, 
              color: effectiveIconColor,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            value,
            style: AppTypography.displayHeading.copyWith(
              fontSize: isCompact ? AppTypography.sizeLargeBody : AppTypography.sizeDisplaySubPage,
              color: isSolid ? AppColors.pureWhite : AppColors.dark900,
              letterSpacing: -0.8,
              fontWeight: AppTypography.weightExtraBold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.sizeCaption,
              color: isSolid 
                  ? AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh) 
                  : AppColors.dark800,
              fontWeight: AppTypography.weightSemibold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A simple icon + label column used for summaries (e.g., attending status).
class ModernSummaryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? activeColor;

  const ModernSummaryIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? (activeColor ?? theme.colorScheme.secondary) : AppColors.dark300;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.sizeMicroSmall,
            fontWeight: active ? AppTypography.weightBold : AppTypography.weightRegular,
            color: active ? Colors.black.withValues(alpha: 0.87) : AppColors.dark400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
