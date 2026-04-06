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
    
    // 1. Background Logic: Default to iconBadgeFillColor (which has baked-in opacity)
    final Color baseBgColor = color ?? (isSolid 
        ? theme.colorScheme.primary 
        : Color(config.iconBadgeFillColor));
    
    // 2. Opacity Logic: If isSolid = 1.0. 
    // Otherwise, strictly use the accentOpacity token from design configuration.
    final double effectiveAlpha = isSolid ? 1.0 : config.accentOpacity;
    
    // Applying alpha to the solid version of the base color
    final Color effectiveBgColor = baseBgColor.withValues(alpha: effectiveAlpha);
    final borderOpacity = isSolid ? 0.0 : (config.accentOpacity * 2).clamp(0.0, 1.0);

    // 3. Icon/Glyph Color logic: Default to iconBadgeIconColor
    final Color effectiveIconColor = iconColor ?? (isSolid 
        ? AppColors.pureWhite 
        : Color(config.iconBadgeIconColor));

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.md * (isCompact ? 0.6 : 1.0),
        horizontal: AppSpacing.sm,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon, 
              size: isCompact ? 14 : 18, 
              color: effectiveIconColor,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            value,
            style: AppTypography.displayHeading.copyWith(
              fontSize: isCompact ? 14 : 18,
              color: isSolid ? AppColors.pureWhite : AppColors.dark900,
              letterSpacing: -1.0,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8, // Aggressively reduced to prevent truncation
              color: isSolid 
                  ? AppColors.pureWhite.withValues(alpha: 0.8) 
                  : (color ?? AppColors.dark800),
              fontWeight: FontWeight.w800, 
              letterSpacing: 0.2, // Tighter for long words like WITHDRAWN
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
