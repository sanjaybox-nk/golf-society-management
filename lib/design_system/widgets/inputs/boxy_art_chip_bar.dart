import 'package:golf_society/design_system/design_system.dart';

/// Horizontally scrollable pill-chip selector for "pick one from N" navigation.
/// Generic on value type — reuses [BoxyOption] from [BoxyArtSegmentedControl].
/// Suitable for dynamic/unknown item counts where a full-width segmented
/// control would be too wide or restrictive.
class BoxyArtChipBar<T> extends StatelessWidget {
  final T value;
  final List<BoxyOption<T>> options;
  final ValueChanged<T> onChanged;

  const BoxyArtChipBar({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = theme.extension<AppShapeTokens>();
    final spacing = theme.extension<AppSpacingTokens>();
    final chipGap = spacing?.cardToCard ?? AppSpacing.atomic;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = option.value == value;
          return GestureDetector(
            onTap: () => onChanged(option.value),
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              margin: EdgeInsets.only(right: chipGap),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.standard,
                vertical: AppSpacing.atomic,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: shapes?.pill ?? BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withValues(alpha: AppColors.opacityMuted),
                  width: AppShapes.borderThin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: AppShapes.iconXs,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    option.label,
                    style: AppTypography.label.copyWith(
                      fontWeight: isSelected
                          ? AppTypography.weightBold
                          : AppTypography.weightRegular,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
