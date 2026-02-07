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
      for (var hole in holes) {
        final par = hole['par'] as int? ?? 4;
        // Generate a score: Par +/- 2 with a bias towards Par/Bogey
        final roll = _random.nextDouble();
        int score;
        if (roll < 0.05) {
          score = par - 1; // Birdie
        } else if (roll < 0.45) {
          score = par; // Par
        } else if (roll < 0.80) {
          score = par + 1; // Bogey
        } else if (roll < 0.95) {
          score = par + 2; // Double
        } else {
          score = par + 3; // Disaster
        }
        
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
        int shots = (playingHandicap / 18).floor();
        if (playingHandicap % 18 >= si) shots++;

        final netScore = score - shots;
        final points = max(0, par - netScore + 2).toInt();
        totalPoints += points;
      }

      results.add({
        'playerId': member.id,
        'playerName': member.displayName,
        'handicap': baseHandicap, // Keep original for reference
        'playingHandicap': playingHandicap, // The one used for scoring
        'holeScores': holeScores,
        'grossTotal': grossTotal,
        'netTotal': grossTotal - playingHandicap,
        'points': totalPoints,
        'status': ScorecardStatus.finalScore.name,
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
