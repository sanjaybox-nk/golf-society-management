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
    final config = ref.watch(themeControllerProvider);
    
    // 1. Universal Badge Token Logic
    final Color badgeFill = color ?? Color(config.iconBadgeFillColor);
    final Color badgeContent = Color(config.iconBadgeTextColor);
    final double badgeOpacity = config.iconBadgeOpacity;

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vertPadding = isCompact 
        ? (spacing?.cardVerticalPadding ?? AppSpacing.md) * 0.5
        : (spacing?.cardVerticalPadding ?? AppSpacing.lg);
    final double horizPadding = (spacing?.cardHorizontalPadding ?? AppSpacing.sm) * 0.5;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: vertPadding,
        horizontal: horizPadding,
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
                  size: value.isEmpty ? (isCompact ? 22 : 26) : (isCompact ? 18 : 22), 
                  color: iconColor ?? badgeContent,
                ),
                if (value.isNotEmpty) const SizedBox(width: AppSpacing.xs),
              ],
              if (value.isNotEmpty)
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
              fontSize: isCompact ? 9 : 10,
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
