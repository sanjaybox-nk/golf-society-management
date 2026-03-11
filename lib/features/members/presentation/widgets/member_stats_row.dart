import 'package:golf_society/design_system/design_system.dart';

class MemberStatsRow extends StatelessWidget {
  final int starts;
  final int wins;
  final int top5;
  final double avgPts;
  final int bestPts;
  final int? rank;

  const MemberStatsRow({
    super.key,
    required this.starts,
    required this.wins,
    required this.top5,
    required this.avgPts,
    required this.bestPts,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            if (wins > 0) ...[
              Expanded(child: _StatItem(label: 'WINS', value: '$wins')),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(child: _StatItem(label: 'TOP 5', value: '$top5')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatItem(label: 'AVG PTS', value: avgPts.toStringAsFixed(1))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatItem(label: 'BEST', value: '$bestPts')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatItem(label: 'RANK', value: rank != null ? '#$rank' : '-')),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppShapes.rMd),
        border: Border.all(
          color: isDark 
              ? AppColors.pureWhite.withValues(alpha: 0.12) 
              : AppColors.dark700.withValues(alpha: AppColors.opacitySubtle),
          width: AppShapes.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTypography.displaySection.copyWith(
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.captionStrong.copyWith(
              color: AppColors.dark500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

