import "package:golf_society/design_system/design_system.dart";
class BoxyHoleSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHalf), size: AppShapes.iconLg),
            onPressed: currentHole > 1 ? () => onHoleChanged(currentHole - 1) : null,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 18,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              itemBuilder: (context, index) {
                final holeNum = index + 1;
                final isSelected = holeNum == currentHole;
                final hasScore = scores.containsKey(holeNum);
                return _buildHoleItem(context, holeNum, isSelected, hasScore);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHalf), size: AppShapes.iconLg),
            onPressed: currentHole < 18 ? () => onHoleChanged(currentHole + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHoleItem(BuildContext context, int holeNum, bool isSelected, bool hasScore) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onHoleChanged(holeNum),
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
                    : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHalf),
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
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: AppColors.opacityMuted),
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
