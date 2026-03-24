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
    
    return Container(
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
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56, // Slightly increased for top breathing room
          child: Row(
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
                  child: Column(
                    children: [
                      const SizedBox(height: 8), // Added top spacing as requested
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected 
                          ? (isDark ? AppColors.actionGreen : AppColors.dark950) 
                          : unselectedItemColor,
                        size: 28,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTypography.micro.copyWith(
                          fontSize: 11.0,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                          color: isSelected 
                              ? (isDark ? AppColors.actionGreen : AppColors.dark950) 
                              : unselectedItemColor,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
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
