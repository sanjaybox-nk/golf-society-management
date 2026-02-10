import 'dart:math';
import 'package:golf_society/models/competition.dart';
import '../../models/member.dart';
import '../../models/scorecard.dart';

class MockDataSeeder {
  final Random _random = Random();

  /// Generates a realistic field of results for an event based on raw strokes.
  List<Map<String, dynamic>> generateFieldResults({
    required List<Member> members,
    required Map<String, dynamic> courseConfig,
    int? playerCount,
    List<String>? specificMemberIds,
    CompetitionRules? rules,
  }) {
    final results = <Map<String, dynamic>>[];
    final holes = courseConfig['holes'] as List? ?? List.generate(18, (i) => {'par': 4, 'si': i + 1});

    // Determine target players
    final List<Member> targetPlayers = [];
    if (specificMemberIds != null && specificMemberIds.isNotEmpty) {
      for (var id in specificMemberIds) {
        final member = members.firstWhere((m) => m.id == id, orElse: () => 
          Member(id: id, firstName: 'Guest', lastName: 'Player', email: '', handicap: 18.0)
        );
        targetPlayers.add(member);
      }
    } else {
      final count = playerCount ?? (12 + _random.nextInt(20));
      for (int i = 0; i < count; i++) {
        targetPlayers.add(i < members.length ? members[i] : 
          Member(id: 'mock_$i', firstName: 'Mock', lastName: 'Player $i', email: '', handicap: _random.nextInt(28).toDouble())
        );
      }
    }

    for (var member in targetPlayers) {
      // 1. Calculate Handicaps based on Rules
      final double baseHandicap = member.handicap;
      double cappedHandicap = baseHandicap;
      
      if (rules != null) {
        // Apply Cap
        if (baseHandicap > rules.handicapCap) {
          cappedHandicap = rules.handicapCap.toDouble();
        }
        // Apply Allowance (e.g. 95%)
        cappedHandicap = cappedHandicap * rules.handicapAllowance;
      }

      final int playingHandicap = cappedHandicap.round();
      final holeScores = <int>[];
      int grossTotal = 0;

        // 2. Generate 18 holes of strokes (Gross)
        // Realistic distribution based on handicap
        // Low Hcp (0-9): Mostly Par/Bogey
        // Mid Hcp (10-18): Mostly Bogey/Double
      for (int h = 0; h < 18; h++) {
        final hole = holes[h];
        final par = hole['par'] as int? ?? 4;
        
        double performanceFactor = _random.nextDouble(); // 0.0=Great Day, 1.0=Bad Day
        
        int baseStrokesOverPar;
        if (playingHandicap < 10) {
           // Low: 0..2 over par (rare birdie)
           baseStrokesOverPar = (performanceFactor * 2).round(); 
           if (_random.nextDouble() < 0.15) baseStrokesOverPar = -1; // 15% birdie chance
        } else if (playingHandicap < 20) {
           // Mid: 1..2 over par
           baseStrokesOverPar = 1 + (performanceFactor * 1.5).round();
        } else {
           // High: 2..3 over par
           baseStrokesOverPar = 2 + (performanceFactor * 1.5).round();
        }
        
        final score = par + baseStrokesOverPar;
        
        holeScores.add(score);
        grossTotal += score;
      }

      // 3. Calculate Stableford Points using Playing Handicap
      int totalPoints = 0;
      for (int h = 0; h < 18; h++) {
        final hole = holes[h];
        final par = hole['par'] as int? ?? 4;
        final si = hole['si'] as int? ?? (h + 1);
        final score = holeScores[h];

        // Shots received on this hole
        // Standard calculation: Base shots per hole + extra for remainder
        int shots = (playingHandicap / 18).floor();
        if ((playingHandicap % 18) >= si) {
           shots++;
        }
        
        final netScore = score - shots;
        // stableford: 2 points for net par. 
        final holePoints = max(0, 2 + (par - netScore));
        totalPoints += holePoints.toInt();
      }
      
      // Calculate Gross Points (for Gross Stableford)
      int grossPoints = 0;
      for (int h = 0; h < 18; h++) {
        final hole = holes[h];
        final par = hole['par'] as int? ?? 4;
        final score = holeScores[h];
        grossPoints += max(0, 2 + (par - score)).toInt();
      }

      results.add({
        'playerId': member.id,
        'playerName': member.displayName,
        'handicap': baseHandicap, // Keep original for reference
        'playingHandicap': playingHandicap, // The one used for scoring
        'holeScores': holeScores,
        'grossTotal': grossTotal,
        'grossPoints': grossPoints,
        'netTotal': grossTotal - playingHandicap,
        'points': totalPoints,
        'status': ScorecardStatus.finalScore.name,
        'rank': 0, // Assigned later
      });
    }

    // Sort results by points descending (Stableford) as default
    results.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    
    // Assign ranks
    for (int i = 0; i < results.length; i++) {
        results[i]['rank'] = i + 1;
    }

    return results;
  }
}
