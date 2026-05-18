import 'package:golf_society/design_system/design_system.dart';

class BoxyArtScoreStepper extends StatelessWidget {
  final int? score;
  final int? par;
  final Color? scoreColor;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final bool isLocked;

  const BoxyArtScoreStepper({
    super.key,
    required this.score,
    this.par,
    this.scoreColor,
    this.onDecrement,
    this.onIncrement,
    this.isLocked = false,
  });

  Color? _resolveScoreColor() {
    if (scoreColor != null) return scoreColor;
    if (score == null || par == null) return null;
    final diff = score! - par!;
    if (diff <= -2) return AppColors.scoreEagle;
    if (diff == -1) return AppColors.scoreBirdie;
    if (diff == 0) return AppColors.scorePar;
    if (diff == 1) return AppColors.scoreBogey;
    if (diff == 2) return AppColors.scoreDouble;
    return AppColors.scoreTriplePlus;
  }

  @override
  Widget build(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isLocked ? null : onDecrement,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
            child: Icon(
              Icons.remove_rounded,
              size: 32,
              color: (isLocked || onDecrement == null)
                  ? AppColors.dark400
                  : onSurface,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.dark900.withValues(alpha: AppColors.opacityHalf)
                : AppColors.dark50.withValues(alpha: AppColors.opacityHalf),
            borderRadius: shapes?.input,
            border: Border.all(
              color: isDark ? AppColors.dark700 : AppColors.lightBorder,
            ),
          ),
          child: Text(
            score != null ? '$score' : '–',
            style: AppTypography.display.copyWith(
              color: score == null
                  ? AppColors.dark300
                  : (_resolveScoreColor() ?? onSurface),
              fontWeight: AppTypography.weightHeavy,
              fontSize: 32,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: isLocked ? null : onIncrement,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
            child: Icon(
              Icons.add_rounded,
              size: 32,
              color: (isLocked || onIncrement == null)
                  ? AppColors.dark400
                  : onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
