
import 'match_definition.dart';
import 'match_play_calculator.dart';
import '../../../../models/scorecard.dart';

class MatchGroupEntry {
  final String playerId;
  final String playerName;
  int played;
  int won;
  int lost;
  int halved;
  int holesUp;
  int holesDown;
  
  MatchGroupEntry({
    required this.playerId,
    required this.playerName,
    this.played = 0,
    this.won = 0,
    this.lost = 0,
    this.halved = 0,
    this.holesUp = 0,
    this.holesDown = 0,
  });

  int get points => (won * 3) + (halved * 1);
  int get holeDiff => holesUp - holesDown;

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'playerName': playerName,
    'played': played,
    'won': won,
    'lost': lost,
    'halved': halved,
    'holesUp': holesUp,
    'holesDown': holesDown,
    'points': points,
    'holeDiff': holeDiff,
  };
}

class MatchStandingsCalculator {
  static List<MatchGroupEntry> calculateStandings({
    required List<MatchDefinition> matches,
    required List<Scorecard> scorecards,
    required Map<String, dynamic> courseConfig,
  }) {
    final Map<String, MatchGroupEntry> entries = {};

    for (var m in matches) {
      if (m.team1Ids.isEmpty || m.team2Ids.isEmpty) continue;

      final result = MatchPlayCalculator.calculate(
        match: m,
        scorecards: scorecards,
        courseConfig: courseConfig,
        holesToPlay: courseConfig['holes']?.length ?? 18,
      );

      // Only count final results
      if (!result.isFinal) continue;

      for (var id in m.team1Ids) {
        final name = m.team1Name ?? id;
        entries.putIfAbsent(id, () => MatchGroupEntry(playerId: id, playerName: name));
      }
      for (var id in m.team2Ids) {
        final name = m.team2Name ?? id;
        entries.putIfAbsent(id, () => MatchGroupEntry(playerId: id, playerName: name));
      }

      final t1Id = m.team1Ids.firstOrNull;
      final t2Id = m.team2Ids.firstOrNull;
      if (t1Id == null || t2Id == null) continue;

      final entry1 = entries[t1Id]!;
      final entry2 = entries[t2Id]!;

      entry1.played++;
      entry2.played++;

      if (result.winningTeamIndex == 0) {
        entry1.won++;
        entry2.lost++;
      } else if (result.winningTeamIndex == 1) {
        entry2.won++;
        entry1.lost++;
      } else {
        entry1.halved++;
        entry2.halved++;
      }

      // Holes Up/Down tracking
      // If result.score is +4, Team 1 is 4 up.
      if (result.score > 0) {
        entry1.holesUp += result.score;
        entry2.holesDown += result.score;
      } else if (result.score < 0) {
        entry2.holesUp += result.score.abs();
        entry1.holesDown += result.score.abs();
      }
    }

    final sortedList = entries.values.toList();
    sortedList.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      return b.holeDiff.compareTo(a.holeDiff);
    });

    return sortedList;
  }

}
