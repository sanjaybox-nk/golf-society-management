import 'package:golf_society/design_system/design_system.dart';

class AdminScorecardKeypad extends StatelessWidget {
  final int currentHole;
  final Map<int, int> scores;
  final ValueChanged<int> onHoleChanged;
  final Function(int hole, int score) onSetScore;
  final int? cap;

  const AdminScorecardKeypad({
    super.key,
    required this.currentHole,
    required this.scores,
    required this.onHoleChanged,
    required this.onSetScore,
    this.cap,
  });

  @override
  Widget build(BuildContext context) {
    final int currentScore = scores[currentHole] ?? 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Hole Selector (Ribbon)
        BoxyHoleSelector(
          currentHole: currentHole,
          scores: scores,
          onHoleChanged: onHoleChanged,
        ),
        
        const SizedBox(height: 12),

        // 2. Number Keypad Row (3, 4, 5, 6, 7+)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 3; i <= 6; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildNumberButton(context, i, currentScore == i),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildNumberButton(
                  context, 
                  7, 
                  currentScore >= 7, 
                  label: '7+',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. Action Row ([-] [NEXT HOLE] [+])
        Row(
          children: [
            Expanded(
              flex: 1,
              child: BoxyArtButton(
                title: '',
                icon: Icons.remove,
                isSecondary: true,
                onTap: currentScore > 1 
                    ? () => onSetScore(currentHole, currentScore - 1) 
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: BoxyArtButton(
                title: 'NEXT HOLE',
                isPrimary: true,
                onTap: () {
                  if (currentHole < 18) {
                    onHoleChanged(currentHole + 1);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: BoxyArtButton(
                title: '',
                icon: Icons.add,
                isSecondary: true,
                onTap: (cap == null || currentScore < cap!) 
                    ? () => onSetScore(currentHole, currentScore + 1) 
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, int value, bool isSelected, {String? label}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onSetScore(currentHole, value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.primaryColor 
              : (isDark ? AppColors.dark700 : AppColors.dark50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.primaryColor 
                : (isDark ? AppColors.dark600 : AppColors.dark100),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            label ?? '$value',
            style: AppTypography.displayHeading.copyWith(
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? AppColors.dark100 : AppColors.dark800),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
