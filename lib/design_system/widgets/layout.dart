import "package:golf_society/design_system/design_system.dart";
import "package:golf_society/utils/string_utils.dart";






/// A floating bottom bar with Search and Filter segments.
class FloatingBottomSearch extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const FloatingBottomSearch({super.key, this.onSearchTap, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x2l, left: AppSpacing.x3l, right: AppSpacing.x3l),
      height: 60,
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
                   SizedBox(width: AppSpacing.sm),
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
                   SizedBox(width: AppSpacing.sm),
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
class FloatingFilterBar<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Find index of selected value for animation alignment
    final selectedIndex = options.indexWhere((o) => o.value == selectedValue);
    final count = options.length;
    
    // Calculate alignment for AnimatedAlign (-1.0 to 1.0)
    // For 2 items: 0 -> -1.0, 1 -> 1.0
    // formula: (index / (count - 1)) * 2 - 1
    final alignmentX = count > 1 ? (selectedIndex / (count - 1)) * 2 - 1 : 0.0;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: AppShapes.borderMedium,
        height: 50,
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
            // Layer 0: Border Ring
            Positioned.fill(
              child: Container(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(
                    side: BorderSide(color: Color(0x339E9E9E)), // Grey with opacity 0.2 approx
                  ),
                ),
              ),
            ),

            // Layer 1: Active Indicator
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
            
            // Layer 2: Text Buttons
            Row(
              children: options.map((option) {
                final isSelected = option.value == selectedValue;
                
                // Calculate text color based on background
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

/// A standard info row for profile/detail screens.
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon, 
              size: AppShapes.iconMd, 
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toTitleCase(label),
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark300,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: AppTypography.sizeBody,
                      color: isDark ? AppColors.dark60 : AppColors.dark950,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A standard section title with BoxyArt styling (uppercase, bold, grey).
class BoxyArtSectionTitle extends StatelessWidget {
  final String title;
  final bool isLevel2;
  final bool isPeeking;
  final IconData? icon;
  final int? count;
  final Color? color;

  const BoxyArtSectionTitle({
    super.key,
    required this.title,
    this.isLevel2 = false,
    this.isPeeking = false,
    this.icon,
    this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final String formattedTitle = toTitleCase(title); // [Standard] Enforce Title Case for 4.x
    final displayTitle = count != null ? '$formattedTitle ($count)' : formattedTitle;

    final double topPadding = isPeeking ? 0 : (spacing?.cardToLabel ?? AppSpacing.sectionTitleTop);
    final double bottomPadding = spacing?.labelToCard ?? AppSpacing.labelToCard;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: isLevel2 ? AppShapes.iconXs : AppShapes.iconSm,
                color: isDark ? AppColors.dark300 : AppColors.dark400,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                displayTitle,
                style: (isLevel2 ? AppTypography.micro : AppTypography.label).copyWith(
                  fontWeight: AppTypography.weightHeavy, // [Standard] 800 weight for 4.x
                  color: color ?? (isDark ? AppColors.dark60 : AppColors.dark900),
                  letterSpacing: AppTypography.lsLabel,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A standardized subtle divider for the Boxy Art design system.
class BoxyArtDivider extends StatelessWidget {
  final double verticalPadding;

  const BoxyArtDivider({
    super.key,
    this.verticalPadding = AppSpacing.xs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
      ),
    );
  }
}

/// A standardized subtle vertical divider for the Boxy Art design system.
class BoxyArtVerticalDivider extends StatelessWidget {
  final double horizontalPadding;
  final double? height;

  const BoxyArtVerticalDivider({
    super.key,
    this.horizontalPadding = AppSpacing.xs,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: 1,
        height: height,
        color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
      ),
    );
  }
}
