
import '../../../../models/scorecard.dart';
import 'match_definition.dart';

class MatchPlayCalculator {
  
  static MatchResult calculate({
    required MatchDefinition match,
    required List<Scorecard> scorecards, // Must contain cards for all participants
    required Map<String, dynamic> courseConfig,
    required int holesToPlay, // Usually 18
  }) {
    int currentScore = 0; // + for T1, - for T2
    List<int> holeResults = [];
    int holesCompleted = 0;
    bool matchFinalized = false;
    String finalStatus = 'A/S';
    int winner = -1; // -1 Draw, 0 Team 1, 1 Team 2

    final holes = courseConfig['holes'] as List? ?? [];
    if (holes.isEmpty) {
        return MatchResult(matchId: match.id, winningTeamIndex: -1, status: 'Error', score: 0, holeResults: [], holesPlayed: 0);
    }

    // Handle Byes (One side missing)
    if (match.team1Ids.isEmpty && match.team2Ids.isNotEmpty) {
      return MatchResult(matchId: match.id, winningTeamIndex: 1, status: 'BYE', score: 18, holeResults: [], holesPlayed: 0, isFinal: true);
    }
    if (match.team2Ids.isEmpty && match.team1Ids.isNotEmpty) {
      return MatchResult(matchId: match.id, winningTeamIndex: 0, status: 'BYE', score: 18, holeResults: [], holesPlayed: 0, isFinal: true);
    }
    if (match.team1Ids.isEmpty && match.team2Ids.isEmpty) {
      return MatchResult(matchId: match.id, winningTeamIndex: -1, status: 'TBD', score: 0, holeResults: [], holesPlayed: 0, isFinal: false);
    }

    // Identify participants
    final t1Cards = scorecards.where((s) => match.team1Ids.contains(s.entryId.replaceFirst('_guest', '')) || match.team1Ids.contains(s.entryId)).toList();
    final t2Cards = scorecards.where((s) => match.team2Ids.contains(s.entryId.replaceFirst('_guest', '')) || match.team2Ids.contains(s.entryId)).toList();

    for (int i = 0; i < holesToPlay; i++) {
      if (i >= holes.length) break;
      
      final holePar = holes[i]['par'] as int? ?? 4;
      final holeSi = holes[i]['si'] as int? ?? 18;

      // Calculate Best Net Score for Team 1
      int? t1Score = _getBestTeamScore(t1Cards, i, match.strokesReceived, holePar, holeSi);
      
      // Calculate Best Net Score for Team 2
      int? t2Score = _getBestTeamScore(t2Cards, i, match.strokesReceived, holePar, holeSi);

      if (t1Score == null || t2Score == null) {
        // Hole not fully played by at least one side
        // If we are simulating, maybe we stop here?
        // Or if in real life, we just stop calculation here.
        break; 
      }

      holesCompleted++;

      if (t1Score < t2Score) {
        currentScore++;
        holeResults.add(1); // T1 Win
      } else if (t2Score < t1Score) {
        currentScore--;
        holeResults.add(-1); // T2 Win
      } else {
        holeResults.add(0); // Halve
      }

      // Check for Match End
      final holesRemaining = holesToPlay - (i + 1);
      final absScore = currentScore.abs();
      
      if (absScore > holesRemaining) {
        matchFinalized = true;
        break;
      }
    }

    // Determine Result Text
    if (matchFinalized) {
      final winningTeam = currentScore > 0 ? 0 : 1;
      // Logic: Score is stored as UP holes.
      // E.g. 15 holes played. Score +4. Remaining 3.
      // Status: 4&3.
      // Wait, calculation:
      // If score is +4 after 15 holes. 3 left. 4 > 3 is true.
      // So status is 4&3.
      
      // But standard notation is "X & Y" where X is lead, Y is holes to play.
      // Y = holesRemaining (from loop break above?)
      // Loop ends. i was 14 (15th hole). holesRemaining was 3.
      // Correct.
      
      final margin = currentScore.abs();
      // Recalculate remaining from loop break
      final remaining = holesToPlay - holesCompleted; 
      finalStatus = '$margin & $remaining'; 
      winner = winningTeam;
    } else {
      // In Progress / All Square / Dormie
      if (currentScore == 0) {
        finalStatus = 'A/S';
        winner = -1;
        if (holesCompleted == holesToPlay) {
          matchFinalized = true;
        }
      } else {
        final leader = currentScore > 0 ? 0 : 1; // 0=Team1
        final margin = currentScore.abs();
        final remaining = holesToPlay - holesCompleted;
        
        // Check Dormie (Margin == Remaining)
        if (margin == remaining && remaining > 0) {
           finalStatus = '$margin UP'; // Or "Dormie $margin"? Often just "2 UP" is shown until win.
           // Usually shown as "2 UP"
        } else {
           finalStatus = '$margin UP';
        }
        
        // If 18 holes played and score not 0
        if (holesCompleted == holesToPlay) {
           finalStatus = '$margin UP'; // e.g. "1 UP" or "2 UP"
           winner = leader;
           matchFinalized = true; 
        } else {
           winner = leader; // Leader so far
        }
      }
    }

    // Safety: Adjust final status for 1 UP (18th hole)
    // The loop breaks if > remaining.
    // If it goes to 18th hole:
    // 17 holes played. Score +1. Remaining 1. 1 > 1 False.
    // Play 18th. T1 wins. Score +2. Remaining 0. 2 > 0 True. Break. Status 2&0? No, 2 UP.
    // Play 18th. Halve. Score +1. Remaining 0. 1 > 0 True. Break. Status 1 UP.

    if (finalStatus.endsWith('& 0')) {
       finalStatus = finalStatus.replaceAll('& 0', 'UP');
    }

    return MatchResult(
        matchId: match.id,
        winningTeamIndex: winner,
        status: finalStatus,
        score: currentScore,
        holeResults: holeResults,
        holesPlayed: holesCompleted,
        isFinal: matchFinalized
    );
  }

  static int? _getBestTeamScore(List<Scorecard> teamCards, int holeIdx, Map<String, int> strokesReceived, int par, int si) {
    int? bestNet;
    
    for (var card in teamCards) {
       final raw = card.holeScores.length > holeIdx ? card.holeScores[holeIdx] : null;
       if (raw == null) continue;

       // Calculate Net Matchplay Score
       // Formula: Gross - (Shots Received on this hole)
       // Shots received based on Difference lookup?
       // Usually Matchplay is: Lower HC plays off 0. Higher HC gets X shots.
       // The `strokesReceived` map should contain the FULL handicap strokes for the match?
       // OR the "Shots to Give".
       // Implementation Plan assumption: `strokesReceived` = { 'playerB_id': 5 } 
       // If player not in map, 0 strokes.
       
       // Clean ID
       final cleanId = card.entryId.replaceFirst('_guest', '');
       final strokesGiven = strokesReceived[cleanId] ?? 0;
       
       // Distribute strokes by SI
       // If strokesGiven = 5. Get shots on SI 1-5.
       final shotsOnHole = (strokesGiven ~/ 18) + (si <= (strokesGiven % 18) ? 1 : 0);
       
       final net = raw - shotsOnHole;
       if (bestNet == null || net < bestNet) {
         bestNet = net;
       }
    }
    return bestNet;
  }
}
