import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        child: Row(
          children: [
            if (wins > 0) ...[
              Expanded(child: _StatItem(label: 'Wins', value: '$wins')),
              const SizedBox(width: AppSpacing.atomic),
            ],
            Expanded(child: _StatItem(label: 'Top 5', value: '$top5')),
            const SizedBox(width: AppSpacing.atomic),
            Expanded(child: _StatItem(label: 'Avg Pts', value: avgPts.toStringAsFixed(1))),
            const SizedBox(width: AppSpacing.atomic),
            Expanded(child: _StatItem(label: 'Best', value: '$bestPts')),
            const SizedBox(width: AppSpacing.atomic),
            Expanded(child: _StatItem(label: 'Rank', value: rank != null ? '#$rank' : '-')),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends ConsumerWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    
    final badgeBg = Color(config.iconBadgeFillColor).withValues(alpha: config.iconBadgeOpacity);
    const badgeFg = AppColors.dark900; // Overridden to black for these badges
    
    return BoxyArtCard(
      showShadow: false,
      backgroundColor: isDark 
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : badgeBg,
      borderRadius: config.cardRadius * 0.75,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTypography.headline.copyWith(
              color: badgeFg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: badgeFg.withValues(alpha: 0.8),
              fontWeight: AppTypography.weightStrong,
              fontSize: 10,
              letterSpacing: AppTypography.lsMicro,
            ),
          ),
        ],
      ),
    );
  }
}

