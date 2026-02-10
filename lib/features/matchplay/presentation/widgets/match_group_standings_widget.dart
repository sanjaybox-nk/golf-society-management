
import 'package:flutter/material.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_standings_calculator.dart';
import '../../domain/golf_event_match_extensions.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/golf_event.dart';

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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(groupName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13)),
          const SizedBox(height: 16),
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(h, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
              ...standings.map((s) => TableRow(
                children: [
                   Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s.playerName, style: const TextStyle(fontSize: 12))),
                   Text(s.played.toString(), style: const TextStyle(fontSize: 12)),
                   Text(s.won.toString(), style: const TextStyle(fontSize: 12)),
                   Text(s.lost.toString(), style: const TextStyle(fontSize: 12)),
                   Text(s.halved.toString(), style: const TextStyle(fontSize: 12)),
                   Text(s.holeDiff > 0 ? '+${s.holeDiff}' : s.holeDiff.toString(), 
                       style: TextStyle(fontSize: 11, color: s.holeDiff > 0 ? Colors.green : (s.holeDiff < 0 ? Colors.red : Colors.grey))),
                   Text(s.points.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber)),
                ].map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Center(child: c))).toList(),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
