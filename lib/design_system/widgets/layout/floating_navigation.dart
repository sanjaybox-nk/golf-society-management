
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A floating bottom bar with Search and Filter segments.
class FloatingBottomSearch extends ConsumerWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const FloatingBottomSearch({super.key, this.onSearchTap, this.onFilterTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x2l, left: AppSpacing.x3l, right: AppSpacing.x3l),
      height: config.surfaceHeightLarge,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.pureWhite,
        borderRadius: AppShapes.md,
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
      ),
      child: Row(
        children: [
          // Search Button (Left)
          Expanded(
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppShapes.rMd),
                bottomLeft: Radius.circular(AppShapes.rMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   BoxyArtThemedCircleIcon(Icons.search),
                   const SizedBox(width: AppSpacing.sm),
                   Text(
                     "Search", 
                     style: AppTypography.displayMedium.copyWith(
                       color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark950
                     ),
                   ),
                ],
              ),
            ),
          ),
          
          // Divider
          Container(width: AppShapes.borderThin, height: AppSpacing.x2l, color: AppColors.dark200),

          // Filter Button (Right)
          Expanded(
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppShapes.rMd),
                bottomRight: Radius.circular(AppShapes.rMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   BoxyArtThemedCircleIcon(Icons.tune), // Filter icon
                   const SizedBox(width: AppSpacing.sm),
                   Text(
                     "Filter", 
                     style: AppTypography.displayMedium.copyWith(
                       color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark950
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A segment control style filter bar.
class FloatingFilterBar<T> extends ConsumerWidget {
  final T selectedValue;
  final List<FloatingFilterOption<T>> options;
  final ValueChanged<T> onChanged;

  const FloatingFilterBar({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final selectedIndex = options.indexWhere((o) => o.value == selectedValue);
    final count = options.length;
    final alignmentX = count > 1 ? (selectedIndex / (count - 1)) * 2 - 1 : 0.0;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: 220,
        height: config.surfaceHeightMedium,
        decoration: ShapeDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.pureWhite,
          shape: const StadiumBorder(),
          shadows: [
            BoxShadow(
              color: AppColors.dark950.withValues(alpha: AppColors.opacityMedium),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const ShapeDecoration(
                  shape: StadiumBorder(
                    side: BorderSide(color: Color(0x339E9E9E)),
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: AppAnimations.medium,
              curve: Curves.easeInOut,
              alignment: Alignment(alignmentX.toDouble(), 0),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Container(
                  width: (220 / count) - 8,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityMedium),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
            Row(
              children: options.map((option) {
                final isSelected = option.value == selectedValue;
                final backgroundColor = isSelected 
                    ? Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityHigh)
                    : (Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.pureWhite);
                final textColor = ContrastHelper.getContrastingText(backgroundColor);
                final inactiveTextColor = Theme.of(context).brightness == Brightness.dark ? AppColors.dark300 : AppColors.dark400;
                
                return Expanded(
                  child: InkWell(
                    onTap: () => onChanged(option.value),
                    borderRadius: AppShapes.sheet,
                    child: Center(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected ? textColor : inactiveTextColor,
                          fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                          fontSize: AppTypography.sizeBodySmall,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingFilterOption<T> {
  final String label;
  final T value;

  FloatingFilterOption({required this.label, required this.value});
}
