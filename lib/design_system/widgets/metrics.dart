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

/// A circular metric used within a ModernMetricBar.
class ModernMetricCircle extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  const ModernMetricCircle({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;

    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: themeColor,
            shape: BoxShape.circle,
            boxShadow: AppShadows.softScale,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: value.length > 4 ? 12 : 16,
                fontWeight: AppTypography.weightBold,
                color: AppColors.pureWhite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.sizeCaptionStrong,
            color: textSecondary,
            fontWeight: AppTypography.weightMedium,
          ),
        ),
      ],
    );
  }
}

/// A compact or prominent metric used in registration and summary views.
class ModernMetricStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color color;
  final bool isCompact;
  final bool isSolid;

  const ModernMetricStat({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    required this.color,
    this.isCompact = false,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSolid ? color : color.withValues(alpha: AppColors.opacityMedium),
          borderRadius: AppShapes.lg,
          border: isSolid ? null : Border.all(color: color.withValues(alpha: AppColors.opacityLow), width: AppShapes.borderThin),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppShapes.iconMd, color: isSolid ? AppColors.pureWhite : color),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              value,
              style: AppTypography.displayHeading.copyWith(
                fontSize: AppTypography.sizeLargeBody,
                color: isSolid 
                    ? AppColors.pureWhite 
                    : (isDark ? color : AppColors.dark900),
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
                    : (isDark ? AppColors.dark200 : AppColors.dark300),
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

    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: AppShadows.softScale,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: value.length > 4 ? 12 : 16,
                fontWeight: AppTypography.weightBold,
                color: AppColors.pureWhite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.sizeCaptionStrong,
            color: textSecondary,
            fontWeight: AppTypography.weightMedium,
          ),
        ),
      ],
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
  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? const Color(0xFF27AE60)) : AppColors.dark300;
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
