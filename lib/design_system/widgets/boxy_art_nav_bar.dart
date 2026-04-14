import "package:golf_society/design_system/design_system.dart";

class BoxyArtBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<BoxyArtBottomNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? unselectedColor;
  final Color? borderColor;
  final bool isAdmin;

  const BoxyArtBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.unselectedColor,
    this.borderColor,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? AppColors.dark800 : AppColors.pureWhite),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = selectedIndex == index;
            final Color unselectedItemColor = unselectedColor ?? 
                (isDark ? AppColors.dark200 : AppColors.dark600);
  
            return Expanded(
              child: GestureDetector(
                onTap: () => onItemSelected(index),
                behavior: HitTestBehavior.opaque,
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12), // Spacing from top of bar
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected 
                          ? (isDark ? theme.colorScheme.primary : AppColors.dark950) 
                          : unselectedItemColor,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTypography.micro.copyWith(
                          fontSize: 11.0,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected 
                              ? (isDark ? theme.colorScheme.primary : AppColors.dark950) 
                              : unselectedItemColor,
                          letterSpacing: 0.1,
                          decoration: TextDecoration.none, // Safety override
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12), // Spacing from bottom of clickable area
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
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
