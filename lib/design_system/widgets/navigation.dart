import 'package:flutter/material.dart';

/// A high-fidelity tab bar for sub-navigation (e.g. within an event).
class ModernSubTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<ModernSubTabItem> items;
  final ValueChanged<int> onSelected;
  final Color? unselectedColor;
  final Color? borderColor;

  const ModernSubTabBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onSelected,
    this.unselectedColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Dock Proportions
    final availableWidth = screenWidth - 64; // Horizontal margins (32 * 2)
    final itemWidth = availableWidth / items.length;
    final indicatorWidth = itemWidth * 0.65;
    const double indicatorHeight = 36.0;
    const double dockHeight = 60.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(32, 0, 32, 12),
        height: dockHeight,
        width: availableWidth,
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF1A1C1E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: borderColor ?? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25), 
            width: 0.5,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Precision Highlight
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
              left: (selectedIndex * itemWidth) + (itemWidth - indicatorWidth) / 2,
              top: 5.0,
              child: Container(
                width: indicatorWidth,
                height: indicatorHeight,
                decoration: ShapeDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            
            // Tab Items
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == selectedIndex;
                final Color unselectedItemColor = unselectedColor?.withValues(alpha: 0.45) ?? 
                    (isDark ? Colors.white54 : Colors.black45);
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(index),
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
                            color: isSelected ? primary : unselectedItemColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? primary : unselectedItemColor,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

class ModernSubTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ModernSubTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
