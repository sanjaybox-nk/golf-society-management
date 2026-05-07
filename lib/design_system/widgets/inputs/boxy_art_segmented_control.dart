
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A premium, sliding segmented control for mutually exclusive options.
class BoxyArtSegmentedControl<T> extends ConsumerWidget {
  final T value;
  final List<BoxyOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool fullWidth;

  const BoxyArtSegmentedControl({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    final shapes = theme.extension<AppShapeTokens>();
    final radius = shapes?.pill.topLeft.x ?? config.inputRadius;

    final selectedIndex = options.indexWhere((o) => o.value == value);
    final count = options.length;
    
    // Ensure we have at least 2 options
    if (count < 2) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = fullWidth ? constraints.maxWidth : 300.0;
        final itemWidth = totalWidth / count;
        
        return Container(
          width: totalWidth,
          height: config.surfaceHeightMedium, // Design 4.x standard for segmented inputs
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark700 : AppColors.lightHeader,
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              // Sliding Indicator
              AnimatedAlign(
                duration: AppAnimations.medium,
                curve: Curves.easeInOut,
                alignment: Alignment(
                  (selectedIndex / (count - 1)) * 2 - 1,
                  0,
                ),
                child: Container(
                  width: itemWidth - 8,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(radius - 2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Option labels
              Row(
                children: options.map((option) {
                  final isSelected = option.value == value;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onChanged(option.value),
                      borderRadius: BorderRadius.circular(radius),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (option.icon != null) ...[
                              Icon(
                                option.icon,
                                size: 18,
                                color: isSelected 
                                    ? ContrastHelper.getContrastingText(theme.primaryColor)
                                    : (isDark ? AppColors.dark300 : AppColors.dark400),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              option.label,
                              style: AppTypography.label.copyWith(
                                fontSize: AppTypography.sizeLabel,
                                letterSpacing: AppTypography.lsStandard,
                                fontWeight: isSelected ? AppTypography.weightBlack : AppTypography.weightBold,
                                color: isSelected 
                                    ? ContrastHelper.getContrastingText(theme.primaryColor)
                                    : (isDark ? AppColors.dark300 : AppColors.dark400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A simple configuration object for segmented options.
class BoxyOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const BoxyOption({
    required this.value,
    required this.label,
    this.icon,
  });
}
