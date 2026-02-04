import '../../../../models/leaderboard_config.dart';
import '../../../../models/leaderboard_standing.dart';
import '../../../../models/competition.dart';
import '../../../../models/scorecard.dart';
import 'leaderboard_calculator.dart';

class OOMCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
  }) async {
    final oomConfig = config as OrderOfMeritConfig;
    
    // Map of Member ID -> List of (Event ID, Points)
    final Map<String, List<_EventScore>> memberScores = {};

    // Process each competition
    for (var comp in competitions) {
      final compCards = scorecards.where((s) => s.competitionId == comp.id && s.scoringStatus == ScoringStatus.ok).toList();
      
      // Sort for position if needed
      if (oomConfig.source == OOMSource.position) {
         compCards.sort((a, b) {
            if (oomConfig.rankingBasis == OOMRankingBasis.gross) {
               final grossA = (a.grossTotal != null && a.grossTotal! > 0) ? a.grossTotal! : 9999;
               final grossB = (b.grossTotal != null && b.grossTotal! > 0) ? b.grossTotal! : 9999;
               if (grossA != grossB) return grossA.compareTo(grossB);
               return _compareCountback(a, b); 
            } else {
               final ptsA = a.points ?? 0;
               final ptsB = b.points ?? 0;
               if (ptsA != ptsB) return ptsB.compareTo(ptsA);
               final grossA = (a.grossTotal != null && a.grossTotal! > 0) ? a.grossTotal! : 9999;
               final grossB = (b.grossTotal != null && b.grossTotal! > 0) ? b.grossTotal! : 9999;
               return grossA.compareTo(grossB);
            }
         });
      }

      for (int i = 0; i < compCards.length; i++) {
        final card = compCards[i];
        final position = i + 1;

        // Resolve Member IDs (Single or Team)
        List<String> memberIds = [];
        final eventGrouping = groupings?[comp.id];
        
        if (card.entryId.startsWith('team_') && eventGrouping != null) {
          final teamData = eventGrouping[card.entryId];
          if (teamData != null && teamData['members'] is List) {
            memberIds = List<String>.from(teamData['members']);
          } else {
            memberIds = [card.submittedByUserId];
          }
        } else {
          memberIds = [card.submittedByUserId];
        }

        // Calculate Points
        double pointsEarned = 0;
        if (oomConfig.source == OOMSource.position) {
          bool isValid = true;
          if (oomConfig.rankingBasis == OOMRankingBasis.gross) {
             if (card.grossTotal == null || card.grossTotal == 0) isValid = false;
          }
          if (isValid) {
             pointsEarned = (oomConfig.positionPointsMap[position] ?? 0).toDouble();
          }
        } else if (oomConfig.source == OOMSource.stableford) {
          pointsEarned = (card.points ?? 0).toDouble();
        } else if (oomConfig.source == OOMSource.gross) {
          pointsEarned = (card.grossTotal ?? 0).toDouble();
        }
        
        // Participation points added to every finisher
        pointsEarned += oomConfig.appearancePoints;

        // Attribute points to each member in the entry
        for (var mId in memberIds) {
          memberScores.putIfAbsent(mId, () => []);
          memberScores[mId]!.add(_EventScore(comp.id, pointsEarned));
        }
      }
    }

    // Convert scores to Standings, applying Best N rule
    final List<LeaderboardStanding> standings = [];
    for (var entry in memberScores.entries) {
      final mId = entry.key;
      final scores = entry.value;

      // Sort scores descending to take Best N
      scores.sort((a, b) => b.points.compareTo(a.points));

      final int roundsPlayed = scores.length;
      final int bestN = oomConfig.bestN > 0 ? oomConfig.bestN : roundsPlayed;
      final countingScores = scores.take(bestN).toList();
      final double totalPoints = countingScores.fold(0.0, (sum, s) => sum + s.points);

      standings.add(LeaderboardStanding(
        leaderboardId: config.id,
        memberId: mId,
        memberName: 'Member $mId', // In real use, this would be updated with actual name
        currentHandicap: 0.0,
        points: totalPoints,
        roundsPlayed: roundsPlayed,
        roundsCounted: countingScores.length,
      ));
    }

    // Final sorting of standings
    standings.sort((a, b) => b.points.compareTo(a.points));

    return standings;
  }

  int _compareCountback(Scorecard a, Scorecard b) {
    if (a.holeScores.length != 18 || b.holeScores.length != 18) return 0;

    int sumRange(Scorecard card, int start, int count) {
      return card.holeScores
          .skip(start)
          .take(count)
          .whereType<int>()
          .fold(0, (sum, val) => sum + val);
    }

    // Back 9
    int back9A = sumRange(a, 9, 9);
    int back9B = sumRange(b, 9, 9);
    if (back9A != back9B) return back9A.compareTo(back9B);

    // Last 6
    int last6A = sumRange(a, 12, 6);
    int last6B = sumRange(b, 12, 6);
    if (last6A != last6B) return last6A.compareTo(last6B);

    // Last 3
    int last3A = sumRange(a, 15, 3);
    int last3B = sumRange(b, 15, 3);
    if (last3A != last3B) return last3A.compareTo(last3B);

    // Last 1
    int last1A = a.holeScores[17] ?? 0;
    int last1B = b.holeScores[17] ?? 0;
    return last1A.compareTo(last1B);
  }
}

class _EventScore {
  final String eventId;
  final double points;
  _EventScore(this.eventId, this.points);
}
