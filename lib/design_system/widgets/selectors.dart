import "package:golf_society/design_system/design_system.dart";
class BoxyHoleSelector extends StatefulWidget {
  final int currentHole;
  final Map<int, int> scores;
  final ValueChanged<int> onHoleChanged;
  final double height;
  final Set<int> conflictedHoles;

  const BoxyHoleSelector({
    super.key,
    required this.currentHole,
    required this.scores,
    required this.onHoleChanged,
    this.height = 48,
    this.conflictedHoles = const {},
  });

  @override
  State<BoxyHoleSelector> createState() => _BoxyHoleSelectorState();
}

class _BoxyHoleSelectorState extends State<BoxyHoleSelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Use addPostFrameCallback to ensure the controller is attached before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHole(widget.currentHole, animate: false);
    });
  }

  @override
  void didUpdateWidget(BoxyHoleSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentHole != oldWidget.currentHole) {
      _scrollToHole(widget.currentHole);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHole(int holeNum, {bool animate = true}) {
    if (!_scrollController.hasClients) return;

    // Each item is 50 width + sm margin (8.0) = 58.0 total
    const itemWidth = 58.0;
    
    // Calculate the target offset. 
    // We try to center the hole if possible.
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetOffset = (holeNum - 1) * itemWidth - (viewportWidth / 2) + (itemWidth / 2);
    
    // Clamp the offset between 0 and maxScrollExtent
    final clampedOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: AppAnimations.medium,
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget chevron(IconData icon, bool enabled, VoidCallback? onTap) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Icon(
            icon,
            size: AppShapes.iconLg,
            color: theme.colorScheme.onSurface.withValues(
              alpha: enabled ? AppColors.opacityHigh : AppColors.opacitySubtle,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          chevron(Icons.chevron_left, widget.currentHole > 1,
              widget.currentHole > 1 ? () => widget.onHoleChanged(widget.currentHole - 1) : null),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 18,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              itemBuilder: (context, index) {
                final holeNum = index + 1;
                final isSelected = holeNum == widget.currentHole;
                final hasScore = widget.scores.containsKey(holeNum);
                final hasConflict = widget.conflictedHoles.contains(holeNum);
                return _buildHoleItem(context, holeNum, isSelected, hasScore, hasConflict);
              },
            ),
          ),
          chevron(Icons.chevron_right, widget.currentHole < 18,
              widget.currentHole < 18 ? () => widget.onHoleChanged(widget.currentHole + 1) : null),
        ],
      ),
    );
  }

  Widget _buildHoleItem(BuildContext context, int holeNum, bool isSelected, bool hasScore, bool hasConflict) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dotColor = hasConflict
        ? AppColors.coral500
        : (isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: AppColors.opacityMuted));

    return GestureDetector(
      onTap: () => widget.onHoleChanged(holeNum),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        width: 50,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: hasConflict
                  ? AppColors.coral500
                  : (isSelected ? theme.colorScheme.primary : Colors.transparent),
              width: AppShapes.borderMedium,
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: (isSelected ? AppTypography.displaySection : AppTypography.body).copyWith(
                color: hasConflict
                    ? AppColors.coral500
                    : (isSelected
                        ? (isDark ? AppColors.pureWhite : AppColors.dark900)
                        : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHalf)),
                fontWeight: isSelected ? AppTypography.weightHeavy : AppTypography.weightRegular,
              ),
              child: Text('$holeNum'),
            ),
            if (hasScore || hasConflict)
              Positioned(
                bottom: AppSpacing.xs,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
