import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

class BoxyArtStatusBanner extends ConsumerWidget {
  final Color color;
  final IconData icon;
  final String message;
  final String? subtitle;
  final bool hasBottomMargin;
  final VoidCallback? onTap;

  const BoxyArtStatusBanner({
    super.key,
    required this.color,
    required this.icon,
    required this.message,
    this.subtitle,
    this.hasBottomMargin = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final config = ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.pureWhite : AppColors.dark900;
    final mutedColor = isDark ? AppColors.dark300 : AppColors.dark400;

    final banner = Container(
      width: double.infinity,
      margin: hasBottomMargin
          ? EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard)
          : EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacityLow),
        borderRadius: shapes?.card ?? AppShapes.md,
        border: config.useBorders
            ? Border.all(
                color: color.withValues(alpha: AppColors.opacitySubtle),
                width: config.borderWidth,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment:
            subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: subtitle != null
                ? const EdgeInsets.only(top: 2)
                : EdgeInsets.zero,
            child: Icon(icon, color: color, size: AppShapes.iconSmall),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: subtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message, style: AppTypography.cardTitle),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(color: mutedColor),
                      ),
                    ],
                  )
                : Text(
                    message,
                    style: AppTypography.bodySmall.copyWith(color: textColor),
                  ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppShapes.iconXs,
              color: color.withValues(alpha: AppColors.opacityHalf),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: banner,
      );
    }
    return banner;
  }
}
