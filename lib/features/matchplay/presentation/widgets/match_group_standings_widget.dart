
import '../../domain/match_definition.dart';
import '../../domain/match_standings_calculator.dart';
import '../../domain/golf_event_match_extensions.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';

class MatchGroupStandingsWidget extends StatelessWidget {
  final GolfEvent event;
  final List<Scorecard> scorecards;

  const MatchGroupStandingsWidget({
    super.key,
    required this.event,
    required this.scorecards,
  });

  @override
  Widget build(BuildContext context) {
    final groupMatches = event.matches.where((m) => m.round == MatchRoundType.group).toList();
    if (groupMatches.isEmpty) return const SizedBox.shrink();

    // Group matches by their internal groupId if available
    final Map<String, List<MatchDefinition>> groups = {};
    for (var m in groupMatches) {
      final gid = m.groupId ?? 'default';
      groups.putIfAbsent(gid, () => []).add(m);
    }

    return Column(
      children: groups.entries.map((entry) {
        final standings = MatchStandingsCalculator.calculateStandings(
          matches: entry.value,
          scorecards: scorecards,
          courseConfig: event.courseConfig,
        );

        return _StandingsTable(
          groupName: entry.key == 'default' ? 'Groups' : 'Group ${entry.key}',
          standings: standings,
        );
      }).toList(),
    );
  }
}

class _StandingsTable extends StatelessWidget {
  final String groupName;
  final List<MatchGroupEntry> standings;

  const _StandingsTable({required this.groupName, required this.standings});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: AppColors.opacityMuted),
        borderRadius: AppShapes.md,
        border: Border.all(color: AppColors.pureWhite.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(groupName.toUpperCase(), style: const TextStyle(fontWeight: AppTypography.weightBold, color: AppColors.amber500, fontSize: AppTypography.sizeLabelStrong)),
          const SizedBox(height: AppSpacing.lg),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: ['Player', 'P', 'W', 'L', 'D', 'Diff', 'Pts'].map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(h, style: const TextStyle(fontSize: AppTypography.sizeCaption, color: AppColors.textSecondary, fontWeight: AppTypography.weightBold)),
                )).toList(),
              ),
              ...standings.map((s) => TableRow(
                children: [
                   Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Text(s.playerName, style: const TextStyle(fontSize: AppTypography.sizeLabel))),
                   Text(s.played.toString(), style: const TextStyle(fontSize: AppTypography.sizeLabel)),
                   Text(s.won.toString(), style: const TextStyle(fontSize: AppTypography.sizeLabel)),
                   Text(s.lost.toString(), style: const TextStyle(fontSize: AppTypography.sizeLabel)),
                   Text(s.halved.toString(), style: const TextStyle(fontSize: AppTypography.sizeLabel)),
                   Text(s.holeDiff > 0 ? '+${s.holeDiff}' : s.holeDiff.toString(), 
                       style: TextStyle(fontSize: AppTypography.sizeCaptionStrong, color: s.holeDiff > 0 ? AppColors.lime500 : (s.holeDiff < 0 ? AppColors.coral500 : AppColors.textSecondary))),
                   Text(s.points.toString(), style: const TextStyle(fontSize: AppTypography.sizeLabelStrong, fontWeight: AppTypography.weightBold, color: AppColors.amber500)),
                ].map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Center(child: c))).toList(),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
