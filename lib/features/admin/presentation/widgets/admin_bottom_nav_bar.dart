import 'package:golf_society/design_system/design_system.dart';
import 'dart:ui';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalMargin = 24.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
      height: 72,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.black.withValues(alpha: 0.7) 
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Stack(
            children: [
              // Sliding Indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  (items.length > 1) ? (currentIndex / (items.length - 1)) * 2 - 1 : 0,
                  -0.5,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (screenWidth - (horizontalMargin * 2)) / (items.length * 2) - 21,
                  ),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                
                // Tab Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = currentIndex == index;
                    final Color unselectedItemColor = primaryColor.withValues(alpha: 0.4);
  
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 6),
                            // Extract icon widget from BottomNavigationBarItem
                            IconTheme(
                              data: IconThemeData(
                                color: isSelected ? Colors.white : unselectedItemColor,
                                size: 22,
                              ),
                              child: isSelected ? (item.activeIcon) : (item.icon),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.label ?? '',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                color: isSelected ? primaryColor : unselectedItemColor,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
    );
  }
}
