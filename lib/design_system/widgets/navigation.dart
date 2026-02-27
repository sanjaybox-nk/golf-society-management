import 'package:golf_society/design_system/design_system.dart';

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
          color: (isDark ? AppColors.dark600 : AppColors.pureWhite),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark950.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: borderColor ?? (isDark ? AppColors.dark400 : AppColors.dark200), 
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
                final Color unselectedItemColor = unselectedColor ?? 
                    (isDark ? AppColors.dark300 : AppColors.dark400);
                
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
                          style: AppTypography.caption.copyWith(
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

/// A horizontally scrolling, underlined filter bar used as a sleek alternative to pill chips.
/// Matches the interaction style of the Event Top Menus.
class ModernUnderlinedFilterBar<T> extends StatelessWidget {
  final List<ModernFilterTab<T>> tabs;
  final T selectedValue;
  final ValueChanged<T> onTabSelected;
  final EdgeInsetsGeometry padding;

  const ModernUnderlinedFilterBar({
    super.key,
    required this.tabs,
    required this.selectedValue,
    required this.onTabSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tabs.map((tab) {
            final isSelected = selectedValue == tab.value;
            return _UnderlinedTabItem(
              label: tab.label,
              isSelected: isSelected,
              onTap: () => onTabSelected(tab.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ModernFilterTab<T> {
  final String label;
  final T value;

  const ModernFilterTab({
    required this.label,
    required this.value,
  });
}

class _UnderlinedTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnderlinedTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use high contrast text when active, faded when inactive
    final activeTextColor = isDark ? AppColors.pureWhite : AppColors.dark950;
    final inactiveTextColor = isDark ? AppColors.dark300 : AppColors.dark400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48, // Standard touch target
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? activeTextColor : inactiveTextColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
