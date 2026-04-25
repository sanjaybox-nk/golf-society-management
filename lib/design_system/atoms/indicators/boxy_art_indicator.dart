import 'package:flutter/material.dart';
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

  const BoxyArtIndicator({
    super.key,
    required this.label,
    required this.dotColor,
    this.onTap,
    this.hasHorizontalMargin = true,
    this.fontSize,
    this.textColor,
  });

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
    bool hasHorizontalMargin = true,
    double? fontSize,
  }) {
    return BoxyArtIndicator(
      label: label,
      dotColor: teeColor,
      hasHorizontalMargin: hasHorizontalMargin,
      fontSize: fontSize ?? 11.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final Widget content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hasHorizontalMargin ? AppSpacing.xs : 0,
        vertical: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Perfect Circle Indicator
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
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
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
