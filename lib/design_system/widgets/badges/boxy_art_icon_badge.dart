
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

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
  final bool isTertiary;
  final bool isPrimary;
  final bool isSecondary;
  final String? tooltip;

  const BoxyArtIconBadge({
    super.key,
    required this.icon,
    this.color = Colors.transparent,
    this.size,
    this.iconSize,
    this.isTinted = true,
    this.isTertiary = false,
    this.isPrimary = false,
    this.isSecondary = false,
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
    
    // When an explicit color is provided, use it as a low-opacity tint fill
    // with the full-saturation color as the icon — matching the banner pattern.
    const double tintOpacity = 0.15;

    final Color effectiveFill = !showFill
        ? Colors.transparent
        : (color != Colors.transparent
            ? color.withValues(alpha: tintOpacity)
            : (isTertiary
                ? Theme.of(context).colorScheme.tertiary.withValues(alpha: effectiveOpacity)
                : (isPrimary
                    ? Color(config.primaryColor).withValues(alpha: effectiveOpacity)
                    : (isSecondary
                        ? Color(config.secondaryColor).withValues(alpha: effectiveOpacity)
                        : (shapeTokens?.iconBadgeFill ?? Color(config.iconBadgeFillColor)).withValues(alpha: effectiveOpacity)))));

    final Color effectiveIconColor = iconColor ?? (color != Colors.transparent
        ? color
        : (isTertiary
            ? Theme.of(context).colorScheme.tertiary
            : (isPrimary
                ? Color(config.primaryColor)
                : (isSecondary
                    ? Color(config.secondaryColor)
                    : (shapeTokens?.iconBadgeIcon ?? Color(config.iconBadgeIconColor))))));

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
