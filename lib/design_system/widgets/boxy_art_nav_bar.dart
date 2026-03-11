import "package:golf_society/design_system/design_system.dart";
import "dart:ui";
class BoxyArtBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<BoxyArtBottomNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? unselectedColor;
  final Color? borderColor;

  const BoxyArtBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.unselectedColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = activeColor ?? theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Dock Proportions
    final availableWidth = screenWidth - 64; // Horizontal margins (32 * 2)
    const double dockHeight = 60.0;
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(32, 0, 32, 16),
        height: dockHeight,
        width: availableWidth,
        decoration: BoxDecoration(
          borderRadius: AppShapes.x2l,
          boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
        ),
        child: ClipRRect(
          borderRadius: AppShapes.x2l,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? (isDark 
                    ? AppColors.dark700.withValues(alpha: AppColors.opacityHigh) 
                    : AppColors.pureWhite.withValues(alpha: 0.65)),
                borderRadius: AppShapes.x2l,
                border: Border.all(
                  color: isDark 
                      ? AppColors.pureWhite.withValues(alpha: 0.12) 
                      : AppColors.dark700.withValues(alpha: AppColors.opacitySubtle),
                  width: AppShapes.borderThin,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Interaction Row
                  Row(
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = selectedIndex == index;
                      final Color unselectedItemColor = unselectedColor ?? 
                          (isDark ? AppColors.dark150 : AppColors.dark300);
        
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onItemSelected(index),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 2),
                              AnimatedScale(
                                duration: AppAnimations.medium,
                                scale: isSelected ? 1.1 : 1.0,
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  color: isSelected 
                                    ? (isDark ? AppColors.pureWhite : primaryColor) 
                                    : unselectedItemColor,
                                  size: AppShapes.iconMd,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                item.label,
                                style: AppTypography.caption.copyWith(
                                  fontSize: AppTypography.sizeCaption,
                                  fontWeight: isSelected ? AppTypography.weightSemibold : AppTypography.weightRegular,
                                  color: isSelected 
                                      ? (isDark ? AppColors.pureWhite : primaryColor) 
                                      : unselectedItemColor,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BoxyArtBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BoxyArtBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
