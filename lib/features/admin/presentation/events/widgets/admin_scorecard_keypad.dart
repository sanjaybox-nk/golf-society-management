import 'package:golf_society/design_system/design_system.dart';

class AdminScorecardKeypad extends StatelessWidget {
  final int currentHole;
  final Map<int, int> scores;
  final ValueChanged<int> onHoleChanged;
  final Function(int hole, int score) onSetScore;
  final int? cap;
  final Set<int> conflictedHoles;
  final bool isStableford;
  final List<dynamic>? holes;

  const AdminScorecardKeypad({
    super.key,
    required this.currentHole,
    required this.scores,
    required this.onHoleChanged,
    required this.onSetScore,
    this.cap,
    this.conflictedHoles = const {},
    this.isStableford = false,
    this.holes,
  });

  @override
  Widget build(BuildContext context) {
    final int currentScore = scores[currentHole] ?? 4;
    final canDecrement = currentScore > 1;
    final canIncrement = cap == null || currentScore < cap!;

    final hole = (holes != null && currentHole - 1 < holes!.length)
        ? holes![currentHole - 1]
        : null;
    final int? par = hole?.par as int?;
    final int? si = hole?.si as int?;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BoxyHoleSelector(
          currentHole: currentHole,
          scores: scores,
          onHoleChanged: onHoleChanged,
          conflictedHoles: conflictedHoles,
        ),
        const SizedBox(height: AppSpacing.atomic),
        if (par != null || si != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (par != null)
                BoxyArtIndicator(
                  label: 'P$par',
                  dotColor: AppColors.dark400,
                  hasHorizontalMargin: false,
                ),
              if (si != null) ...[
                const SizedBox(width: AppSpacing.xs),
                BoxyArtIndicator(
                  label: 'SI $si',
                  dotColor: AppColors.dark400,
                  hasHorizontalMargin: false,
                ),
              ],
            ],
          ),
        const SizedBox(height: AppSpacing.atomic),
        BoxyArtScoreStepper(
          score: currentScore,
          par: par,
          onDecrement: canDecrement
              ? () => onSetScore(currentHole, currentScore - 1)
              : null,
          onIncrement: canIncrement
              ? () => onSetScore(currentHole, currentScore + 1)
              : null,
        ),
      ],
    );
  }
}
