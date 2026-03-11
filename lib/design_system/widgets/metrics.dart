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
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isSolid ? effectiveColor : AppColors.actionGreen.withValues(alpha: 0.20),
        borderRadius: AppShapes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon, 
              size: AppShapes.iconMd, 
              color: isSolid ? AppColors.pureWhite : AppColors.dark900,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            value,
            style: AppTypography.displayHeading.copyWith(
              fontSize: AppTypography.sizeLargeBody,
              color: isSolid 
                  ? AppColors.pureWhite 
                  : (isDark ? AppColors.pureWhite : AppColors.dark900),
              letterSpacing: -0.8,
              fontWeight: AppTypography.weightBlack,
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
                  : (isDark ? AppColors.dark200 : AppColors.dark800),
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
