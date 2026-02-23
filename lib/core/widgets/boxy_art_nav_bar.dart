import 'dart:ui';
import 'package:flutter/material.dart';

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
    
    // Adaptive parameters

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 72, // Slightly tighter height
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark 
            ? Colors.black.withValues(alpha: 0.7) 
            : Colors.white.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: borderColor ?? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          width: borderColor != null ? 1.5 : 1,
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
              // Sliding Indicator (Circle behind icon)
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  (items.length > 1) ? (selectedIndex / (items.length - 1)) * 2 - 1 : 0,
                  -0.5,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (screenWidth - 32) / (items.length * 2) - 21,
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
                    final isSelected = selectedIndex == index;
                    final Color unselectedItemColor = unselectedColor?.withValues(alpha: 0.7) ?? 
                        (isDark ? Colors.white60 : Colors.black45);
  
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onItemSelected(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 6),
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? Colors.white : unselectedItemColor,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.label,
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
