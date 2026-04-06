import "package:golf_society/design_system/design_system.dart";
class BoxyHoleSelector extends StatefulWidget {
  final int currentHole;
  final Map<int, int> scores;
  final ValueChanged<int> onHoleChanged;
  final double height;

  const BoxyHoleSelector({
    super.key,
    required this.currentHole,
    required this.scores,
    required this.onHoleChanged,
    this.height = 48,
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
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface.withOpacity(AppColors.opacityHalf), size: AppShapes.iconLg),
            onPressed: widget.currentHole > 1 ? () => widget.onHoleChanged(widget.currentHole - 1) : null,
          ),
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
                return _buildHoleItem(context, holeNum, isSelected, hasScore);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(AppColors.opacityHalf), size: AppShapes.iconLg),
            onPressed: widget.currentHole < 18 ? () => widget.onHoleChanged(widget.currentHole + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHoleItem(BuildContext context, int holeNum, bool isSelected, bool hasScore) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: AppShapes.borderMedium,
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: AppTypography.displayHeading.copyWith(
                color: isSelected
                    ? (isDark ? AppColors.pureWhite : AppColors.dark900)
                    : theme.colorScheme.onSurface.withOpacity(AppColors.opacityHalf),
                fontSize: isSelected ? 24 : 18,
              ),
              child: Text('$holeNum'),
            ),
            if (hasScore)
              Positioned(
                bottom: AppSpacing.xs,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(AppColors.opacityMuted),
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
