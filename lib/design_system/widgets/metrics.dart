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
    
    // 1. Universal Badge Token Logic
    final Color badgeFill = Color(config.iconBadgeFillColor);
    final Color badgeContent = AppColors.dark800;
    final double badgeOpacity = config.iconBadgeOpacity;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? AppSpacing.md : AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: badgeFill.withValues(alpha: badgeOpacity),
        borderRadius: BorderRadius.circular(config.accentRadius),
        border: Border.all(
          color: badgeFill.withValues(alpha: badgeOpacity * 2).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row 1: Unified Data Cluster (Icon + Metric Value)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon, 
                  size: isCompact ? 18 : 22, 
                  color: AppColors.pureWhite,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  value,
                  style: (isCompact 
                        ? AppTypography.label.copyWith(fontSize: 15) 
                        : AppTypography.metricValue
                    ).copyWith(
                      color: badgeContent,
                      height: 1.0,
                    ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),

          // Row 2: Standardized Context Label
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: badgeContent.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsMicro,
              height: 1.0,
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
class ModernSummaryIcon extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
    final color = active ? (activeColor ?? Color(config.secondaryColor)) : AppColors.dark300;
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
