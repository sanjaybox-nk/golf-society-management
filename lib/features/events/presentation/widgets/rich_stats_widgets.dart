import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SCORING BREAKDOWN',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STABLEFORD DISTRIBUTION',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FRONT vs BACK PERFORMANCE',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERFORMANCE BY HOLE TYPE',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
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

class DifficultyHeatmap extends StatelessWidget {
  final Map<int, double> holeAverages;
  final List<dynamic> holes;

  const DifficultyHeatmap({super.key, required this.holeAverages, required this.holes});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HOLE-BY-HOLE HEATMAP',
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
                width: (MediaQuery.of(context).size.width - (hPadding * 2) - 40) / 6,
                child: _buildHoleBubble(context, i),
              )),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'A visual guide to course difficulty: Red shades indicate harder (over-par) holes, while green indicates easier ones.',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoleBubble(BuildContext context, int i) {
    final avg = holeAverages[i] ?? 4.0;
    final par = holes.length > i ? (holes[i] is Map ? (holes[i]['par'] as int? ?? 4) : holes[i].par).toDouble() : 4.0;
    final diff = avg - par;
    
    Color color;
    if (diff > 1.0) {
      color = AppColors.scoreTriplePlus;
    } else if (diff > 0.5) {
      color = AppColors.scoreDouble;
    } else if (diff > 0.2) {
      color = AppColors.scoreBogey;
    } else if (diff > -0.2) {
      color = AppColors.scorePar;
    } else {
      color = AppColors.scoreBirdie;
    }

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
          Text(
            '${diff > 0 ? "+" : ""}${diff.toStringAsFixed(1)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
              fontSize: AppTypography.sizeMicroSmall,
              fontWeight: AppTypography.weightBold,
            ),
          ),
        ],
      ),
    );
  }
}

class HoleDifficultyChart extends StatelessWidget {
  final Map<int, double> holeAverages;
  final List<dynamic> holes;

  const HoleDifficultyChart({
    super.key,
    required this.holeAverages,
    required this.holes,
  });

  @override
  Widget build(BuildContext context) {
    // Sort holes by difficulty (average relative to par)
    final sortedHoleIndices = holeAverages.keys.toList()
      ..sort((a, b) {
        final parA = (holes[a] is Map ? (holes[a]['par'] as int? ?? 4) : holes[a].par).toDouble();
        final diffA = holeAverages[a]! - parA;
        final parB = (holes[b] is Map ? (holes[b]['par'] as int? ?? 4) : holes[b].par).toDouble();
        final diffB = holeAverages[b]! - parB;
        return diffB.compareTo(diffA); // Toughest first
      });

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOUGHEST TEST (AVG VS PAR)',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...sortedHoleIndices.take(5).map((idx) {
              final avg = holeAverages[idx]!;
              final par = (holes[idx] is Map ? (holes[idx]['par'] as int? ?? 4) : holes[idx].par).toDouble();
              final diff = avg - par;
              final isOverPar = diff > 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
                        borderRadius: AppShapes.xs,
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: AppTypography.weightHeavy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'HOLE ${idx + 1}',
                                style: const TextStyle(fontWeight: AppTypography.weightBold),
                              ),
                              Text(
                                '${isOverPar ? "+" : ""}${diff.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ClipRRect(
                            borderRadius: AppShapes.grabber,
                            child: LinearProgressIndicator(
                              value: (diff.abs() / 2).clamp(0.1, 1.0),
                              backgroundColor: AppColors.textSecondary,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOverPar ? AppColors.coral500.withValues(alpha: AppColors.opacityHigh) : AppColors.lime500.withValues(alpha: AppColors.opacityHigh),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Identifies the most challenging holes based on average relative to par.',
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

class AchievementTile extends StatelessWidget {
  final String title;
  final String playerName;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AchievementTile({
    super.key,
    required this.title,
    required this.playerName,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.lg;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.lg,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: AppSpacing.xs)),
          ),
          child: Row(
            children: [
              // Premium Icon Container
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.lg,
                  border: Border.all(color: color.withValues(alpha: AppColors.opacityLow)),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: AppTypography.weightHeavy,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      toTitleCase(playerName),
                      style: AppTypography.body.copyWith(
                        fontWeight: AppTypography.weightExtraBold,
                        fontSize: AppTypography.sizeBody,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: AppColors.dark100, size: AppShapes.iconMd),
            ],
          ),
        ),
      ),
    );
  }
}

class FieldEclecticCard extends StatelessWidget {
  final List<int?> eclecticScores;
  final List<dynamic> holes;

  const FieldEclecticCard({
    super.key,
    required this.eclecticScores,
    required this.holes,
  });

  @override
  Widget build(BuildContext context) {
    int eaglesCount = 0;
    int birdiesCount = 0;
    int parsCount = 0;

    for (int i = 0; i < eclecticScores.length; i++) {
      final score = eclecticScores[i];
      if (score == null) continue;
      final par = (holes[i] is Map ? (holes[i]['par'] as int? ?? 4) : holes[i].par) as int;

      final diff = score - par;
      if (diff <= -2) {
        eaglesCount++;
      } else if (diff == -1) {
        birdiesCount++;
      } else if (diff == 0) {
        parsCount++;
      }
    }

    final totalStrokes = eclecticScores.whereType<int>().fold(0, (sum, s) => sum + s);
    final parTotal = holes.fold(0, (sum, h) => sum + ((h is Map ? (h['par'] as int? ?? 4) : h.par) as int));
    final vsPar = totalStrokes - parTotal;

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.xl;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        decoration: BoxDecoration(
          gradient: AppGradients.brandPrimary(context),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOCIETY\'S BEST ROUND',
                        style: AppTypography.label.copyWith(
                          color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'FIELD ECLECTIC',
                        style: AppTypography.displaySubPage.copyWith(
                          color: AppColors.pureWhite,
                          fontWeight: AppTypography.weightBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle),
                    borderRadius: AppShapes.lg,
                    border: Border.all(color: AppColors.pureWhite.withValues(alpha: AppColors.opacityLow)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        totalStrokes.toString(),
                        style: AppTypography.displayHeading.copyWith(
                          fontSize: AppTypography.sizeDisplayLarge,
                          color: AppColors.pureWhite,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        vsPar == 0 ? 'PAR' : (vsPar > 0 ? '+$vsPar' : '$vsPar'),
                        style: AppTypography.labelStrong.copyWith(
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.md,
                border: Border.all(color: AppColors.pureWhite.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatRow('EAGLES', eaglesCount.toString()),
                  _buildStatRow('BIRDIES', birdiesCount.toString()),
                  _buildStatRow('PARS', parsCount.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.displayHeading.copyWith(
            fontSize: AppTypography.sizeDisplayLocker,
            fontWeight: AppTypography.weightBlack,
            color: AppColors.pureWhite,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
            fontWeight: AppTypography.weightSemibold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class SocietyRecapSummaryCard extends StatelessWidget {
  final int totalPlayers;
  final int totalHolesPlayed;
  final String topHoleName;
  final double topHoleDiff;

  const SocietyRecapSummaryCard({
    super.key,
    required this.totalPlayers,
    required this.totalHolesPlayed,
    required this.topHoleName,
    required this.topHoleDiff,
  });

  @override
  Widget build(BuildContext context) {

    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3l, horizontal: AppSpacing.x2l),
        child: Column(
          children: [
            // Top Icon with Subtle Glow
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityLow),
                shape: BoxShape.circle,
                boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
              ),
              child: Icon(Icons.flag_rounded, color: Theme.of(context).colorScheme.primary, size: AppShapes.iconXl),
            ),
            const SizedBox(height: AppSpacing.x2l),
            
            // Header
            Text(
              'SOCIETY RECAP COMPLETE',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Main Stat
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: AppTypography.displaySubPage.copyWith(
                    fontSize: AppTypography.sizeDisplayHeading,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                children: [
                  TextSpan(text: '$totalPlayers'),
                  TextSpan(
                    text: ' PLAYERS  •  ',
                    style: AppTypography.displayLargeBody.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                    ),
                  ),
                  TextSpan(text: '$totalHolesPlayed'),
                  TextSpan(
                    text: ' HOLES',
                    style: AppTypography.displayLargeBody.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            
            // Glass Chip for Toughest Test
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityLow),
                borderRadius: AppShapes.pill,
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityMedium)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart_rounded, color: Theme.of(context).colorScheme.primary, size: AppShapes.iconSm),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Toughest Test: $topHoleName (+${topHoleDiff.toStringAsFixed(1)})',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: AppTypography.weightBlack,
                      fontSize: AppTypography.sizeBodySmall,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),
            
            // Footer Text
            Text(
              'What a day for the society!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
                fontSize: AppTypography.sizeButton,
                fontStyle: FontStyle.italic,
                fontWeight: AppTypography.weightMedium,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'See you at the 19th hole.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
                fontSize: AppTypography.sizeButton,
                fontStyle: FontStyle.italic,
                fontWeight: AppTypography.weightMedium,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
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
    final color = myAvg > 0 ? Theme.of(context).colorScheme.error : AppColors.lime500;
    
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTypography.micro.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
              borderRadius: AppShapes.x2l,
            ),
            child: Text(
              '${myAvg > 0 ? "+" : ""}${myAvg.toStringAsFixed(1)}',
              style: TextStyle(fontWeight: AppTypography.weightBlack, color: color, fontSize: AppTypography.sizeLargeBody),
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
                style: TextStyle(
                  fontSize: AppTypography.sizeNano, 
                  fontWeight: AppTypography.weightBlack, 
                  color: betterThanField ? AppColors.lime500 : AppColors.coral500
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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
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
                width: (MediaQuery.of(context).size.width - (hPadding * 2) - 40) / 6,
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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.md;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.md;

    return BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
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
