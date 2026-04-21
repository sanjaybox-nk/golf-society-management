import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

/// A horizontally scrolling, underlined filter bar used as a sleek alternative to pill chips.
/// Matches the interaction style of the Event Top Menus.
class ModernUnderlinedFilterBar<T> extends StatefulWidget {
  final List<ModernFilterTab<T>> tabs;
  final T selectedValue;
  final ValueChanged<T> onTabSelected;
  final EdgeInsetsGeometry padding;
  final bool isExpanded;
  final double? indicatorWidth;

  const ModernUnderlinedFilterBar({
    super.key,
    required this.tabs,
    required this.selectedValue,
    required this.onTabSelected,
    this.padding = EdgeInsets.zero,
    this.isExpanded = false,
    this.indicatorWidth,
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
        duration: animate ? AppAnimations.medium : Duration.zero,
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
          indicatorWidth: widget.indicatorWidth,
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
        margin: widget.padding,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.pureWhite.withValues(alpha: AppColors.opacityLow) : Colors.black.withValues(alpha: AppColors.opacityLow),
              width: AppShapes.borderThin,
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

/// A drop-in replacement for [TabBar] that uses the same premium underlined style
/// as [ModernUnderlinedFilterBar]. Used for [SliverPersistentHeader] or standard
/// tab implementations to ensure architectural parity.
class ModernUnderlinedTabBar extends StatefulWidget implements PreferredSizeWidget {
  final TabController? controller;
  final List<String> tabLabels;
  final EdgeInsetsGeometry padding;

  const ModernUnderlinedTabBar({
    super.key,
    this.controller,
    required this.tabLabels,
    this.padding = EdgeInsets.zero,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<ModernUnderlinedTabBar> createState() => _ModernUnderlinedTabBarState();
}

class _ModernUnderlinedTabBarState extends State<ModernUnderlinedTabBar> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateController();
  }

  @override
  void didUpdateWidget(ModernUnderlinedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateController();
    }
  }

  void _updateController() {
    final newController = widget.controller ?? DefaultTabController.maybeOf(context);
    if (newController != _controller) {
      _controller?.removeListener(_handleTabChange);
      _controller = newController;
      _controller?.addListener(_handleTabChange);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();

    return Container(
      margin: widget.padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? AppColors.pureWhite.withValues(alpha: AppColors.opacityLow) 
                : Colors.black.withValues(alpha: AppColors.opacityLow),
            width: AppShapes.borderThin,
          ),
        ),
      ),
      child: Row(
        children: List.generate(widget.tabLabels.length, (index) {
          final isSelected = controller.index == index;
          return Expanded(
            child: _UnderlinedTabItem(
              label: widget.tabLabels[index],
              isSelected: isSelected,
              onTap: () => controller.animateTo(index),
            ),
          );
        }),
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
  final double? indicatorWidth;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnderlinedTabItem({
    super.key,
    required this.label,
    this.icon,
    this.indicatorWidth,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeTextColor = isDark ? AppColors.pureWhite : AppColors.dark950;
    final inactiveTextColor = isDark ? AppColors.dark300 : AppColors.dark400;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppShapes.rMd),
        topRight: Radius.circular(AppShapes.rMd),
      ),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Label Content
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: AppShapes.iconSm,
                      color: isSelected ? activeTextColor : inactiveTextColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      toTitleCase(label),
                      style: AppTypography.displayLocker.copyWith(
                        fontSize: AppTypography.sizeBodySmall,
                        fontWeight: isSelected ? AppTypography.weightExtraBold : AppTypography.weightSemibold,
                        color: isSelected ? activeTextColor : inactiveTextColor,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Indicator
            Positioned(
              bottom: 0,
              width: indicatorWidth ?? 80, // Default to 80 if not specified
              height: 4,
              child: AnimatedOpacity(
                duration: AppAnimations.fast,
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
