import 'package:golf_society/design_system/design_system.dart';

class PersonalBenchmarkingCard extends StatelessWidget {
  final Map<int, double> myAverages;
  final Map<int, double> fieldAverages;

  const PersonalBenchmarkingCard({
    super.key,
    required this.myAverages,
    required this.fieldAverages,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOU VS THE FIELD',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _buildBenchStat(context, 'PAR 3', myAverages[3] ?? 0, fieldAverages[3] ?? 0),
                _buildBenchStat(context, 'PAR 4', myAverages[4] ?? 0, fieldAverages[4] ?? 0),
                _buildBenchStat(context, 'PAR 5', myAverages[5] ?? 0, fieldAverages[5] ?? 0),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Compares your average performance relative to par against the rest of the field.',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchStat(BuildContext context, String label, double myAvg, double fieldAvg) {
    final diff = myAvg - fieldAvg;
    final betterThanField = diff < 0; // Scoring lower vs par is better
    final color = myAvg > 0 ? AppColors.coral500 : AppColors.lime500;

    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTypography.micro.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppColors.opacitySubtle),
              borderRadius: AppShapes.x2l,
            ),
            child: Text(
              '${myAvg > 0 ? "+" : ""}${myAvg.toStringAsFixed(1)}',
              style: AppTypography.body.copyWith(fontWeight: AppTypography.weightBlack, color: color),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                betterThanField ? Icons.trending_up : Icons.trending_down,
                size: AppShapes.iconXs,
                color: betterThanField ? AppColors.lime500 : AppColors.coral500,
              ),
              const SizedBox(width: AppShapes.borderMedium),
              Text(
                '${betterThanField ? "-" : "+"}${diff.abs().toStringAsFixed(1)} FIELD',
                style: AppTypography.micro.copyWith(
                  fontWeight: AppTypography.weightBlack,
                  color: betterThanField ? AppColors.lime500 : AppColors.coral500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HoleComparisonHeatmap extends StatelessWidget {
  final List<int?> myHoleScores;
  final Map<int, double> fieldAverages;
  final List<dynamic> holes;

  const HoleComparisonHeatmap({
    super.key,
    required this.myHoleScores,
    required this.fieldAverages,
    required this.holes,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHERE YOU BEAT THE FIELD',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(18, (i) => SizedBox(
                width: (MediaQuery.of(context).size.width - (32) - 40) / 6,
                child: _buildComparisonBubble(context, i),
              )),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Gold holes are where you personally beat the field average. Grey holes are where the field got the better of you.',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonBubble(BuildContext context, int i) {
    final myScore = (myHoleScores.length > i ? myHoleScores[i] : null)?.toDouble();
    if (myScore == null) return Container();

    final fieldAvg = fieldAverages[i] ?? 4.0;
    final diff = myScore - fieldAvg;
    final beatField = diff < 0;
    
    final color = beatField ? AppColors.amber500 : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacityHigh),
        borderRadius: AppShapes.md,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${i + 1}',
            style: AppTypography.microSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          Icon(
            beatField ? Icons.star : Icons.remove,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
            size: AppShapes.iconXs,
          ),
        ],
      ),
    );
  }
}

class HoleNemesisComparison extends StatelessWidget {
  final int myHardestHoleIdx;
  final double myHardestHoleDiff;
  final int fieldHardestHoleIdx;
  final double fieldHardestHoleDiff;

  const HoleNemesisComparison({
    super.key,
    required this.myHardestHoleIdx,
    required this.myHardestHoleDiff,
    required this.fieldHardestHoleIdx,
    required this.fieldHardestHoleDiff,
  });

  @override
  Widget build(BuildContext context) {
    final isSame = myHardestHoleIdx == fieldHardestHoleIdx;

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOUGHEST TEST (NEMESIS)',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _buildNemesis(context, 'YOURS', myHardestHoleIdx, myHardestHoleDiff, AppColors.teamA)),
                Container(width: AppShapes.borderThin, height: AppSpacing.x4l, color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMedium)),
                Expanded(child: _buildNemesis(context, 'FIELD', fieldHardestHoleIdx, fieldHardestHoleDiff, AppColors.coral500)),
              ],
            ),
            if (isSame) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.amber500.withValues(alpha: AppColors.opacitySubtle),
                  borderRadius: AppShapes.sm,
                ),
                child: Text(
                  '🤝 You struggled where everyone else did!',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelStrong.copyWith(
                    color: AppColors.amber500, // Keep themed for special alerts
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNemesis(BuildContext context, String label, int idx, double diff, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: AppTypography.weightHeavy,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'HOLE ${idx + 1}',
          style: TextStyle(
            fontWeight: AppTypography.weightHeavy,
            fontSize: AppTypography.sizeHeadline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          '+${diff.toStringAsFixed(1)} VS PAR',
          style: const TextStyle(fontSize: AppTypography.sizeCaption, color: AppColors.textSecondary, fontWeight: AppTypography.weightBold),
        ),
      ],
    );
  }
}
