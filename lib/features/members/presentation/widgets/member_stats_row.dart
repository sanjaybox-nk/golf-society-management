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
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final cardGap = spacing?.cardToCard ?? AppSpacing.atomic;

    return BoxyArtCard(
      child: Row(
        children: [
          if (wins > 0) ...[
            Expanded(
              child: ModernMetricStat(
                label: 'Wins',
                value: '$wins',
                isCompact: true,
              ),
            ),
            SizedBox(width: cardGap),
          ],
          Expanded(
            child: ModernMetricStat(
              label: 'Top 5',
              value: '$top5',
              isCompact: true,
            ),
          ),
          SizedBox(width: cardGap),
          Expanded(
            child: ModernMetricStat(
              label: 'Avg Pts',
              value: avgPts.toStringAsFixed(1),
              isCompact: true,
            ),
          ),
          SizedBox(width: cardGap),
          Expanded(
            child: ModernMetricStat(
              label: 'Best',
              value: '$bestPts',
              isCompact: true,
            ),
          ),
          SizedBox(width: cardGap),
          Expanded(
            child: ModernMetricStat(
              label: 'Rank',
              value: rank != null ? '#$rank' : '-',
              isCompact: true,
            ),
          ),
        ],
      ),
    );
  }
}
