
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A small square badge for indicators (Guest, Buggy, etc.)
class BoxyArtSquareBadge extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? size;
  final bool isTinted;
  final bool isPrimary;
  final bool isSecondary;

  const BoxyArtSquareBadge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.size,
    this.isTinted = false,
    this.isPrimary = false,
    this.isSecondary = false,
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
          final Color baseColor = isPrimary 
              ? Color(config.primaryColor) 
              : (isSecondary ? Color(config.secondaryColor) : (shapeTokens?.iconBadgeFill ?? Color(config.iconBadgeFillColor)));
          
          bg = baseColor.withValues(alpha: shapeTokens?.iconBadgeOpacity ?? config.iconBadgeOpacity);
        }

        final Color effectiveIconColor = isPrimary 
            ? Color(config.primaryColor) 
            : (isSecondary ? Color(config.secondaryColor) : (shapeTokens?.iconBadgeIcon ?? Color(config.iconBadgeIconColor)));

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
