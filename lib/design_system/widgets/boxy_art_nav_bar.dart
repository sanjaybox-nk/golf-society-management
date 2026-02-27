import "package:golf_society/design_system/design_system.dart";
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
    final itemWidth = availableWidth / items.length;
    final indicatorWidth = itemWidth * 0.65; // Narrower highlight
    const double indicatorHeight = 36.0;
    const double dockHeight = 60.0;
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(32, 0, 32, 12),
        height: dockHeight,
        width: availableWidth,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark 
              ? const Color(0xFF1A1C1E) // Deep dark card
              : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Selection Island (Dock Background Behind Icon)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutQuart,
              left: (selectedIndex * itemWidth) + (itemWidth - indicatorWidth) / 2,
              top: 5.0, // Tighter alignment for slim dock
              child: Container(
                width: indicatorWidth,
                height: indicatorHeight,
                decoration: ShapeDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
                  
            // Interaction Row
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = selectedIndex == index;
                final Color unselectedItemColor = unselectedColor?.withValues(alpha: 0.4) ?? 
                    (isDark ? Colors.white54 : Colors.black38);
  
                return Expanded(
                  child: GestureDetector(
                        onTap: () => onItemSelected(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 2),
                            AnimatedScale(
                              duration: const Duration(milliseconds: 300),
                              scale: isSelected ? 1.1 : 1.0,
                              curve: Curves.easeOutBack,
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected ? primaryColor : unselectedItemColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? primaryColor : unselectedItemColor,
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
