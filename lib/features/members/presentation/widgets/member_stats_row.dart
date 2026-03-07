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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
        borderRadius: 24,
        child: Row(
          children: [
            if (wins > 0) ...[
              Expanded(child: _StatItem(label: 'WINS', value: '$wins', isHighlight: true)),
              _Divider(),
            ],
            Expanded(child: _StatItem(label: 'TOP 5', value: '$top5')),
            _Divider(),
            Expanded(child: _StatItem(label: 'AVG PTS', value: avgPts.toStringAsFixed(1))),
            _Divider(),
            Expanded(child: _StatItem(label: 'BEST', value: '$bestPts')),
            _Divider(),
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
  final bool isHighlight;

  const _StatItem({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.displaySection.copyWith(
            color: isHighlight ? const Color(0xFFFFD700) : Theme.of(context).colorScheme.onSurface, // Gold for wins
            shadows: isHighlight ? [
              Shadow(color: Colors.black.withValues(alpha: AppColors.opacityLow), blurRadius: 4, offset: Offset(0, 2))
            ] : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: AppColors.dark500,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppShapes.borderThin,
      height: AppSpacing.x3l,
      color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMedium),
    );
  }
}
