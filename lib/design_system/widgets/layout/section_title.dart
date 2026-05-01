
import 'package:golf_society/design_system/design_system.dart';

/// A standard section title with BoxyArt styling (uppercase, bold, grey).
class BoxyArtSectionTitle extends StatelessWidget {
  final String title;
  final bool isLevel2;
  final bool isPeeking;
  final bool followsCard;
  final IconData? icon;
  final int? count;
  final Color? color;
  final double? topPadding;
  final double? horizontalPadding; // [NEW]
  final Widget? trailing;

  const BoxyArtSectionTitle({
    super.key,
    required this.title,
    this.isLevel2 = false,
    this.isPeeking = false,
    this.followsCard = false,
    this.icon,
    this.count,
    this.color,
    this.topPadding,
    this.horizontalPadding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final onSurface = theme.colorScheme.onSurface;
    final displayTitle = count != null ? '$title ($count)' : title;

    final double topPaddingValue = topPadding ?? (followsCard 
      ? (spacing?.cardToLabel ?? AppSpacing.cardToLabel)
      : (isPeeking 
          ? 0 
          : (spacing?.cardToLabel ?? AppSpacing.cardToLabel)));
    final double bottomPadding = spacing?.labelToCard ?? AppSpacing.labelToCard;

    return Padding(
      padding: EdgeInsets.only(
        top: topPaddingValue,
        bottom: bottomPadding,
        left: horizontalPadding ?? 0,
        right: horizontalPadding ?? 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isLevel2 ? AppShapes.iconXs : AppShapes.iconSm,
                  color: color ?? onSurface.withValues(alpha: AppColors.opacitySecondary),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  displayTitle.toUpperCase(),
                  style: (isLevel2 ? AppTypography.micro : AppTypography.label).copyWith(
                    color: color ?? onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
