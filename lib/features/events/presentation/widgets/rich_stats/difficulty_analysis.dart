import 'package:golf_society/design_system/design_system.dart';

class DifficultyHeatmap extends StatelessWidget {
  final Map<int, double> holeAverages;
  final List<dynamic> holes;

  const DifficultyHeatmap({super.key, required this.holeAverages, required this.holes});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'HOLE-BY-HOLE HEATMAP',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: List.generate(18, (i) => SizedBox(
              width: (MediaQuery.of(context).size.width - 32 - 40) / 6,
              child: _buildHoleBubble(context, i),
            )),
          ),
          const SizedBox(height: AppSpacing.standard),
          Text(
            'A visual guide to course difficulty: Red shades indicate harder (over-par) holes, while green indicates easier ones.',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoleBubble(BuildContext context, int i) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final avg = holeAverages[i] ?? 4.0;
    final par = holes.length > i
        ? (holes[i] is Map ? (holes[i]['par'] as int? ?? 4) : holes[i].par).toDouble()
        : 4.0;
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacityHigh),
        borderRadius: shapes?.button,
        border: Border.all(color: color, width: AppShapes.borderThin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${i + 1}',
            style: AppTypography.microSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '${diff > 0 ? "+" : ""}${diff.toStringAsFixed(1)}',
            style: AppTypography.microSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
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
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final sortedHoleIndices = holeAverages.keys.toList()
      ..sort((a, b) {
        final parA = (holes[a] is Map ? (holes[a]['par'] as int? ?? 4) : holes[a].par).toDouble();
        final diffA = holeAverages[a]! - parA;
        final parB = (holes[b] is Map ? (holes[b]['par'] as int? ?? 4) : holes[b].par).toDouble();
        final diffB = holeAverages[b]! - parB;
        return diffB.compareTo(diffA);
      });

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'TOUGHEST TEST (AVG VS PAR)',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          ...sortedHoleIndices.take(5).map((idx) {
            final avg = holeAverages[idx]!;
            final par = (holes[idx] is Map
                    ? (holes[idx]['par'] as int? ?? 4)
                    : holes[idx].par)
                .toDouble();
            final diff = avg - par;
            final isOverPar = diff > 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.atomic),
              child: Row(
                children: [
                  Container(
                    width: AppSpacing.section,
                    height: AppSpacing.section,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
                      borderRadius: shapes?.button,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${idx + 1}',
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: AppTypography.weightHeavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.atomic),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HOLE ${idx + 1}',
                              style: AppTypography.label.copyWith(
                                fontWeight: AppTypography.weightBold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${isOverPar ? "+" : ""}${diff.toStringAsFixed(1)}',
                              style: AppTypography.label.copyWith(
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
                              isOverPar
                                  ? AppColors.coral500.withValues(alpha: AppColors.opacityHigh)
                                  : AppColors.lime500.withValues(alpha: AppColors.opacityHigh),
                            ),
                            minHeight: AppSpacing.xs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.atomic),
          Text(
            'Identifies the most challenging holes based on average relative to par.',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
            ),
          ),
        ],
      ),
    );
  }
}
