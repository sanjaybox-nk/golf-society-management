import 'package:golf_society/design_system/design_system.dart';

/// A horizontally scrolling, underlined filter bar used as a sleek alternative to pill chips.
/// Matches the interaction style of the Event Top Menus.
class ModernUnderlinedFilterBar<T> extends StatefulWidget {
  final List<ModernFilterTab<T>> tabs;
  final T selectedValue;
  final ValueChanged<T> onTabSelected;
  final EdgeInsetsGeometry padding;
  final bool isExpanded;

  const ModernUnderlinedFilterBar({
    super.key,
    required this.tabs,
    required this.selectedValue,
    required this.onTabSelected,
    this.padding = EdgeInsets.zero,
    this.isExpanded = false,
  });

  @override
  State<ModernUnderlinedFilterBar<T>> createState() => _ModernUnderlinedFilterBarState<T>();
}

class _ModernUnderlinedFilterBarState<T> extends State<ModernUnderlinedFilterBar<T>> {
  final Map<T, GlobalKey> _tabKeys = {};

  @override
  void initState() {
    super.initState();
    _ensureKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(widget.selectedValue, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant ModernUnderlinedFilterBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureKeys();
    if (oldWidget.selectedValue != widget.selectedValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected(widget.selectedValue, animate: true);
      });
    }
  }

  void _ensureKeys() {
    for (var tab in widget.tabs) {
      if (!_tabKeys.containsKey(tab.value)) {
        _tabKeys[tab.value] = GlobalKey();
      }
    }
  }

  void _scrollToSelected(T value, {bool animate = true}) {
    if (widget.isExpanded) return;
    final key = _tabKeys[value];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
        curve: Curves.easeInOut,
        alignment: 0.5, // Centers the item in the view
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit, // Always force center alignment
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final childRow = Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: widget.tabs.map((tab) {
        final isSelected = widget.selectedValue == tab.value;
        final item = _UnderlinedTabItem(
          key: _tabKeys[tab.value],
          label: tab.label,
          icon: tab.icon,
          isSelected: isSelected,
          onTap: () {
            widget.onTabSelected(tab.value);
            // Scroll logic is handled by didUpdateWidget when the parent rebuilds and passes the new selectedValue
          },
        );
        return widget.isExpanded ? Expanded(child: item) : item;
      }).toList(),
    );

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
        ),
        child: widget.isExpanded 
            ? childRow 
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: childRow,
              ),
      ),
    );
  }
}

class ModernFilterTab<T> {
  final String label;
  final IconData? icon;
  final T value;

  const ModernFilterTab({
    required this.label,
    this.icon,
    required this.value,
  });
}

class _UnderlinedTabItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnderlinedTabItem({
    super.key,
    required this.label,
    this.icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 2.0, // Thinner, sharper underline
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeTextColor : inactiveTextColor,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? activeTextColor : inactiveTextColor,
                  letterSpacing: 0.3,
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
