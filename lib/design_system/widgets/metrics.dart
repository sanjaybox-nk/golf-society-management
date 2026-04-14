import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class ModernMetricStat extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
    
    // Design 4.x (Boxy Art 4.0) Standard Constants
    final radius = config.accentRadius;
    
    // 1. Background Logic
    final Color baseBgColor = color ?? (isSolid 
        ? theme.colorScheme.primary 
        : Color(config.iconBadgeFillColor));
    
    final double effectiveAlpha = isSolid ? 1.0 : config.accentOpacity;
    final Color effectiveBgColor = baseBgColor.withValues(alpha: effectiveAlpha);
    final borderOpacity = isSolid ? 0.0 : (config.accentOpacity * 2).clamp(0.0, 1.0);

    final Color effectiveIconColor = iconColor ?? (isSolid 
        ? AppColors.pureWhite 
        : Color(config.iconBadgeIconColor));

    // Refinement: Final Symmetry Redesign
    // Ensures all metrics have identical font sizes and centered data baselines.
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 14.0 : AppSpacing.sm,
        horizontal: isCompact ? 4.0 : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: effectiveBgColor.withValues(alpha: effectiveAlpha),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: effectiveBgColor.withValues(alpha: borderOpacity),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Unified Data Cluster (Icon + Optional Metric Value)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(
                  icon, 
                  size: (isCompact || value.isEmpty) ? 22 : 18, 
                  color: effectiveIconColor,
                ),
              if (value.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.atomic),
                Text(
                  value,
                  style: (isCompact 
                        ? AppTypography.body.copyWith(fontSize: 15, fontWeight: AppTypography.weightHeavy) 
                        : AppTypography.metricValue
                    ).copyWith(
                      color: isSolid ? AppColors.pureWhite : AppColors.dark900,
                      height: 1.1,
                    ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),

          // Row 2: Standardized Context Label
          Text(
            label.toUpperCase(),
            style: AppTypography.metricLabel.copyWith(
              color: isSolid 
                  ? AppColors.pureWhite.withValues(alpha: 0.8) 
                  : (color ?? AppColors.dark800),
              fontSize: isCompact ? 9 : 10,
              height: 1.1,
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
    final color = active ? (activeColor ?? theme.colorScheme.primary) : AppColors.dark300;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: AppTypography.micro.copyWith(
            color: active ? Colors.black.withValues(alpha: 0.87) : AppColors.dark400,
          ),
        ),
      ],
    );
  }
}
