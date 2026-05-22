import 'package:golf_society/design_system/design_system.dart';

class SplitPerformanceCard extends StatelessWidget {
  final double front9Avg;
  final double back9Avg;
  final bool isStableford;

  const SplitPerformanceCard({
    super.key,
    required this.front9Avg,
    required this.back9Avg,
    required this.isStableford,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final diff = back9Avg - front9Avg;
    final isColapse = isStableford ? diff < 0 : diff > 0;
    final label = isStableford ? 'pts' : 'strokes';

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'FRONT vs BACK PERFORMANCE',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          Row(
            children: [
              _buildHalfCard(context, 'FRONT 9', front9Avg, AppColors.lime500, 'AVG $label'),
              const SizedBox(width: AppSpacing.standard),
              _buildHalfCard(context, 'BACK 9', back9Avg, AppColors.coral500, 'AVG $label'),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          Container(
            padding: const EdgeInsets.all(AppSpacing.atomic),
            decoration: BoxDecoration(
              color: (isColapse
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.primaryContainer)
                  .withValues(alpha: AppColors.opacityMedium),
              borderRadius: shapes?.button,
            ),
            child: Row(
              children: [
                Icon(
                  isColapse ? Icons.trending_down : Icons.trending_up,
                  color: isColapse
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  size: AppShapes.iconMd,
                ),
                const SizedBox(width: AppSpacing.atomic),
                Expanded(
                  child: Text(
                    isColapse
                        ? 'The field faded on the Back 9 today.'
                        : 'Strong finish! The field improved on the Back 9.',
                    style: AppTypography.labelStrong.copyWith(
                      color: isColapse
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          Text(
            'Compares total points or strokes between the first and last 9 holes.',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalfCard(BuildContext context, String title, double val, Color color, String unit) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.weightHeavy,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.atomic),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.standard,
              vertical: AppSpacing.atomic,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
              borderRadius: shapes?.pill,
            ),
            child: Text(
              val.toStringAsFixed(1),
              style: AppTypography.displayLocker.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 32,
            child: Text(
              unit.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.micro.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParTypeBreakdown extends StatelessWidget {
  final Map<int, double> parTypeAverages;

  const ParTypeBreakdown({super.key, required this.parTypeAverages});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'PERFORMANCE BY HOLE TYPE',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          Row(
            children: [
              _buildParTypeStat(context, 'PAR 3', parTypeAverages[3] ?? 0),
              _buildParTypeStat(context, 'PAR 4', parTypeAverages[4] ?? 0),
              _buildParTypeStat(context, 'PAR 5', parTypeAverages[5] ?? 0),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          Text(
            'Breaks down performance averages against par for different hole lengths.',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParTypeStat(BuildContext context, String label, double avg) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final vsPar = avg > 0;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.weightHeavy,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.atomic),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.atomic),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
              borderRadius: shapes?.pill,
            ),
            child: Text(
              '${vsPar ? "+" : ""}${avg.toStringAsFixed(1)}',
              style: AppTypography.displayLocker.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 32,
            child: Text(
              'AVG VS PAR',
              textAlign: TextAlign.center,
              style: AppTypography.micro.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsistencyStatCard extends StatelessWidget {
  final double myVariance;
  final double fieldAvgVariance;

  const ConsistencyStatCard({
    super.key,
    required this.myVariance,
    required this.fieldAvgVariance,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final diff = ((fieldAvgVariance - myVariance) / (fieldAvgVariance > 0 ? fieldAvgVariance : 1)) * 100;
    final moreConsistent = myVariance < fieldAvgVariance;
    final color = moreConsistent ? AppColors.lime500 : AppColors.amber500;

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONSISTENCY (ROUND VARIANCE)',
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.weightHeavy,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.atomic),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moreConsistent ? 'STEADY HAND' : 'ROLLERCOASTER',
                      style: AppTypography.body.copyWith(
                        fontWeight: AppTypography.weightBlack,
                        color: color,
                      ),
                    ),
                    Text(
                      'You were ${diff.abs().toStringAsFixed(0)}% ${moreConsistent ? "more" : "less"} consistent than the field.',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.atomic),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppColors.opacitySubtle),
                  borderRadius: shapes?.button,
                ),
                child: Icon(
                  moreConsistent ? Icons.balance : Icons.auto_graph,
                  color: color,
                  size: AppShapes.iconMd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NetComparisonCard extends StatelessWidget {
  final int myNet;
  final double fieldAvgNet;
  final bool isStableford;

  const NetComparisonCard({
    super.key,
    required this.myNet,
    required this.fieldAvgNet,
    this.isStableford = false,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final diff = myNet - fieldAvgNet;
    final better = diff < 0;

    return BoxyArtCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NET VS FIELD AVG',
                  style: AppTypography.label.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: AppTypography.weightHeavy,
                    letterSpacing: AppTypography.lsLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      isStableford ? '$myNet pts' : '$myNet',
                      style: AppTypography.displayLocker.copyWith(
                        fontWeight: AppTypography.weightBlack,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.atomic),
                    Text(
                      'vs ${fieldAvgNet.toStringAsFixed(1)}${isStableford ? ' pts' : ''} AVG',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.atomic, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: (better ? AppColors.lime500 : AppColors.coral500).withValues(alpha: AppColors.opacitySubtle),
              borderRadius: shapes?.pill,
            ),
            child: Text(
              '${better ? "-" : "+"}${diff.abs().toStringAsFixed(1)}',
              style: AppTypography.label.copyWith(
                fontWeight: AppTypography.weightSemibold,
                color: better ? AppColors.lime500 : AppColors.coral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BounceBackStatCard extends StatelessWidget {
  final double myRate;
  final double fieldRate;

  const BounceBackStatCard({
    super.key,
    required this.myRate,
    required this.fieldRate,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final better = myRate >= fieldRate;
    final color = better ? AppColors.teamA : AppColors.textSecondary;

    return BoxyArtCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.atomic),
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppColors.opacitySubtle),
              borderRadius: shapes?.button,
            ),
            child: Icon(Icons.replay_circle_filled, color: color, size: AppShapes.iconMd),
          ),
          const SizedBox(width: AppSpacing.atomic),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BOUNCE BACK RATE',
                  style: AppTypography.label.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: AppTypography.weightHeavy,
                    letterSpacing: AppTypography.lsLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${(myRate * 100).toStringAsFixed(0)}%',
                  style: AppTypography.displayLocker.copyWith(
                    fontWeight: AppTypography.weightBlack,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'FIELD AVG',
                style: AppTypography.micro.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${(fieldRate * 100).toStringAsFixed(0)}%',
                style: AppTypography.micro.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoundHoleGrid extends StatelessWidget {
  final List<int?> holeScores;
  final List<int?> holePoints;
  final List<dynamic> holes;
  final bool isStableford;

  const RoundHoleGrid({
    super.key,
    required this.holeScores,
    required this.holePoints,
    required this.holes,
    this.isStableford = false,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final sc = Theme.of(context).extension<ScoreColors>()!;

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'YOUR ROUND',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          _buildHalfRow(context, 'FRONT 9', 0, 9, shapes, sc),
          const SizedBox(height: AppSpacing.atomic),
          _buildHalfRow(context, 'BACK 9', 9, 18, shapes, sc),
        ],
      ),
    );
  }

  Widget _buildHalfRow(BuildContext context, String label, int from, int to,
      AppShapeTokens? shapes, ScoreColors sc) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: muted,
            fontWeight: AppTypography.weightBold,
            letterSpacing: AppTypography.lsLabel,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Hole number header row
        Row(
          children: [
            for (int i = from; i < to && i < holes.length; i++) ...[
              if (i > from) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${i + 1}',
                  textAlign: TextAlign.center,
                  style: AppTypography.micro.copyWith(
                    color: muted,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        // Score tile row
        Row(
          children: [
            for (int i = from; i < to && i < holes.length; i++) ...[
              if (i > from) const SizedBox(width: 4),
              Expanded(
                child: _HoleTile(
                  holeIndex: i,
                  holeScores: holeScores,
                  holePoints: holePoints,
                  holes: holes,
                  isStableford: isStableford,
                  shapes: shapes,
                  sc: sc,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _HoleTile extends StatelessWidget {
  final int holeIndex;
  final List<int?> holeScores;
  final List<int?> holePoints;
  final List<dynamic> holes;
  final bool isStableford;
  final AppShapeTokens? shapes;
  final ScoreColors sc;

  const _HoleTile({
    required this.holeIndex,
    required this.holeScores,
    required this.holePoints,
    required this.holes,
    required this.isStableford,
    required this.shapes,
    required this.sc,
  });

  @override
  Widget build(BuildContext context) {
    final score = holeIndex < holeScores.length ? holeScores[holeIndex] : null;
    int par = 4;
    if (holeIndex < holes.length) {
      final h = holes[holeIndex];
      if (h is Map) {
        par = (h['par'] as num?)?.toInt() ?? 4;
      } else {
        try { par = h.par as int; } catch (_) {}
      }
    }

    Color bg;
    String centerLabel;

    if (score == null) {
      bg = Theme.of(context).colorScheme.surface.withValues(alpha: 0.5);
      centerLabel = '–';
    } else if (isStableford) {
      final pts = holeIndex < holePoints.length ? holePoints[holeIndex] : null;
      final p = pts ?? 0;
      bg = _pointsColor(p);
      centerLabel = '$p';
    } else {
      final diff = score - par;
      bg = _diffColor(diff);
      centerLabel = diff == 0 ? 'E' : (diff > 0 ? '+$diff' : '$diff');
    }

    final played = score != null;
    final labelColor = played
        ? AppColors.pureWhite
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25);

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: shapes?.button,
        ),
        child: Center(
          child: Text(
            centerLabel,
            style: AppTypography.micro.copyWith(
              color: labelColor,
              fontWeight: AppTypography.weightBlack,
            ),
          ),
        ),
      ),
    );
  }

  Color _diffColor(int diff) {
    if (diff <= -2) return sc.eagle;
    if (diff == -1) return sc.birdie;
    if (diff == 0) return sc.par;
    if (diff == 1) return sc.bogey;
    if (diff == 2) return sc.doubleBogey;
    return sc.triplePlus;
  }

  Color _pointsColor(int pts) {
    if (pts >= 4) return sc.eagle;
    if (pts == 3) return sc.birdie;
    if (pts == 2) return sc.par;
    if (pts == 1) return sc.bogey;
    return sc.triplePlus;
  }
}
