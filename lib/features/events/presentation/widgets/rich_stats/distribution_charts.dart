import 'package:golf_society/design_system/design_system.dart';

class ScoringTypeDistributionChart extends StatelessWidget {
  final Map<String, int> counts;

  const ScoringTypeDistributionChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final types = ['EAGLE', 'BIRDIE', 'PAR', 'BOGEY', 'DBL BOGEY', 'BLOB'];
    final scoreColors = Theme.of(context).extension<ScoreColors>()!;
    final colors = {
      'EAGLE': scoreColors.eagle,
      'BIRDIE': scoreColors.birdie,
      'PAR': scoreColors.par,
      'BOGEY': scoreColors.bogey,
      'DBL BOGEY': scoreColors.doubleBogey,
      'BLOB': scoreColors.triplePlus,
    };
    
    final maxCount = counts.values.fold(0, (max, v) => v > max ? v : max).clamp(1, 999);

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'SCORING BREAKDOWN',
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppTypography.weightHeavy,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: types.map((t) {
                final count = counts[t] ?? 0;
                final barHeight = (count / maxCount) * 100;
                final color = colors[t] ?? AppColors.textSecondary;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        count.toString(),
                        style: AppTypography.displayLocker.copyWith(
                          color: color,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        height: barHeight.toDouble().clamp(4, 100),
                        decoration: BoxDecoration(
                          gradient: AppGradients.verticalSurface(Theme.of(context).colorScheme.primary),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rXs)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 32, // Fixed height to handle multi-line labels like DBL BOGEY
                        child: Text(
                          t,
                          textAlign: TextAlign.center,
                          style: AppTypography.micro.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'A breakdown of every score recorded across the entire field.',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StablefordDistributionChart extends StatelessWidget {
  final Map<String, int> bucketCounts;

  const StablefordDistributionChart({super.key, required this.bucketCounts});

  @override
  Widget build(BuildContext context) {
    final buckets = ['<20', '20-25', '26-30', '31-35', '36+'];
    final maxCount = bucketCounts.values.fold(0, (max, v) => v > max ? v : max).clamp(1, 999);

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'STABLEFORD DISTRIBUTION',
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppTypography.weightHeavy,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.map((b) {
                final count = bucketCounts[b] ?? 0;
                final barHeight = (count / maxCount) * 100;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        count.toString(),
                        style: AppTypography.displayLocker.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        height: barHeight.toDouble().clamp(4, 100),
                        decoration: BoxDecoration(
                          gradient: AppGradients.verticalSurface(Theme.of(context).colorScheme.primary),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rXs)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 24,
                        child: Text(
                          b,
                          textAlign: TextAlign.center,
                          style: AppTypography.micro.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Counts how many players finished within each point range.',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
