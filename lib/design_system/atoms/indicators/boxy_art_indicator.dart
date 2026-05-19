import 'package:golf_society/design_system/design_system.dart';

/// A sleek status indicator using the 'Legend' pattern (Circle + Text).
/// Designed to be light and non-intrusive on data-heavy cards.
class BoxyArtIndicator extends StatelessWidget {
  final String label;
  final Color dotColor;
  final VoidCallback? onTap;
  final bool hasHorizontalMargin;
  final double? fontSize;
  final Color? textColor;
  final IconData? customActionIcon;
  final bool showBackground;

  const BoxyArtIndicator({
    super.key,
    required this.label,
    required this.dotColor,
    this.onTap,
    this.hasHorizontalMargin = true,
    this.fontSize,
    this.textColor,
    this.customActionIcon,
    this.icon,
    this.showBackground = true,
  });

  final IconData? icon;

  /// Factory for World Handicap System Index (HC)
  factory BoxyArtIndicator.hc({
    required String label,
    bool hasHorizontalMargin = true,
    double? fontSize,
  }) {
    return BoxyArtIndicator(
      label: 'HC: $label',
      dotColor: AppColors.dark300,
      hasHorizontalMargin: hasHorizontalMargin,
      fontSize: fontSize ?? 11.0,
    );
  }

  /// Factory for Playing Handicap (PHC)
  factory BoxyArtIndicator.phc({
    required BuildContext context,
    required String label,
    bool hasHorizontalMargin = true,
    double? fontSize,
  }) {
    return BoxyArtIndicator(
      label: 'PHC: $label',
      dotColor: AppColors.amber500,
      hasHorizontalMargin: hasHorizontalMargin,
      fontSize: fontSize ?? 11.0,
    );
  }

  /// Factory for Tee Color
  factory BoxyArtIndicator.tee({
    required String label,
    required Color teeColor,
    VoidCallback? onTap,
    bool hasHorizontalMargin = true,
    double? fontSize,
  }) {
    return BoxyArtIndicator(
      label: label,
      dotColor: teeColor,
      onTap: onTap,
      hasHorizontalMargin: hasHorizontalMargin,
      fontSize: fontSize ?? 11.0,
      showBackground: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = onTap != null;
    
    final bool applyBackground = isInteractive && showBackground;
    final Widget content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: hasHorizontalMargin ? (applyBackground ? AppSpacing.md : AppSpacing.xs) : 0,
        vertical: applyBackground ? 4 : 2,
      ),
      decoration: applyBackground ? BoxDecoration(
        color: dotColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: dotColor.withValues(alpha: 0.15)),
      ) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Indicator (Badge Icon or Circle)
          if (icon != null)
            BoxyArtIconBadge(
              icon: icon!,
              color: dotColor,
              size: 18,
              iconSize: 10,
              useCircle: true,
            )
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1), 
                  width: 0.5,
                ),
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
          
          // The Label
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontSize: fontSize,
                color: textColor ?? (theme.brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark600),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          if (applyBackground) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              customActionIcon ?? Icons.edit_rounded,
              size: 11,
              color: textColor ?? (theme.brightness == Brightness.dark ? AppColors.dark300 : AppColors.dark400),
            ),
          ],
        ],
      ),
    );

    if (isInteractive) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
