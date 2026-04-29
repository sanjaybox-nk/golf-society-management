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
    final diff = back9Avg - front9Avg;
    final isColapse = isStableford ? diff < 0 : diff > 0;
    final label = isStableford ? 'pts' : 'strokes';

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'FRONT vs BACK PERFORMANCE',
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppTypography.weightHeavy,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _buildHalfCard(context, 'FRONT 9', front9Avg, AppColors.lime500, label),
                const SizedBox(width: AppSpacing.lg),
                _buildHalfCard(context, 'BACK 9', back9Avg, AppColors.coral500, label),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: (isColapse ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.primaryContainer).withValues(alpha: AppColors.opacityMedium),
                    borderRadius: AppShapes.sm,
                  ),
                  child: Row(
                    children: [
                       Icon(
                         isColapse ? Icons.trending_down : Icons.trending_up, 
                         color: isColapse ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary, 
                         size: AppShapes.iconMd,
                       ),
                       const SizedBox(width: AppSpacing.md),
                       Expanded(
                         child: Text(
                           isColapse 
                            ? 'The field faded on the Back 9 today.' 
                            : 'Strong finish! The field improved on the Back 9.',
                           style: AppTypography.labelStrong.copyWith(
                             color: isColapse ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onPrimaryContainer,
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Compares total points or strokes between the first and last 9 holes.',
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildHalfCard(BuildContext context, String title, double val, Color color, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: AppTypography.micro.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                val.toStringAsFixed(1),
                style: AppTypography.displayLocker.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(unit, style: AppTypography.label.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh))),
            ],
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'PERFORMANCE BY HOLE TYPE',
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppTypography.weightHeavy,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _buildParTypeStat(context, 'PAR 3', parTypeAverages[3] ?? 0),
                _buildParTypeStat(context, 'PAR 4', parTypeAverages[4] ?? 0),
                _buildParTypeStat(context, 'PAR 5', parTypeAverages[5] ?? 0),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Breaks down performance averages against par for different hole lengths.',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParTypeStat(BuildContext context, String label, double avg) {
    final vsPar = avg > 0;
    
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.weightHeavy,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
              borderRadius: AppShapes.x2l,
            ),
            child: Text(
              '${vsPar ? "+" : ""}${avg.toStringAsFixed(1)}',
              style: AppTypography.displayLocker.copyWith(color: Theme.of(context).colorScheme.onSurface),
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
    final diff = ((fieldAvgVariance - myVariance) / (fieldAvgVariance > 0 ? fieldAvgVariance : 1)) * 100;
    final moreConsistent = myVariance < fieldAvgVariance;
    final color = moreConsistent ? AppColors.lime500 : AppColors.amber500;

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONSISTENCY (ROUND VARIANCE)',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moreConsistent ? 'STEADY HAND' : 'ROLLERCOASTER',
                        style: TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody, color: color),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(moreConsistent ? Icons.balance : Icons.auto_graph, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NetComparisonCard extends StatelessWidget {
  final int myNet;
  final double fieldAvgNet;

  const NetComparisonCard({
    super.key,
    required this.myNet,
    required this.fieldAvgNet,
  });

  @override
  Widget build(BuildContext context) {
    final diff = myNet - fieldAvgNet;
    final better = diff < 0;

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        '$myNet',
                        style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeDisplayLocker),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'vs ${fieldAvgNet.toStringAsFixed(1)} AVG',
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.xl,
              ),
              child: Text(
                '${better ? "-" : "+"}${diff.abs().toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: better ? AppColors.lime500 : AppColors.coral500,
                ),
              ),
            ),
          ],
        ),
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
    final better = myRate >= fieldRate;
    final color = better ? AppColors.teamA : AppColors.textSecondary;

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.md,
              ),
              child: Icon(Icons.replay_circle_filled, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BOUNCE BACK RATE',
                    style: AppTypography.label.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: AppTypography.weightHeavy,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${(myRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeDisplayLocker),
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
      ),
    );
  }
}
