import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

// Live stats provider for members

// [REDESIGNED] User statistics provider (Real Data Aggregate)
final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final currentUser = ref.watch(effectiveUserProvider);
  final scorecardsAsync = ref.watch(memberScorecardsProvider(currentUser.id));

  return scorecardsAsync.when(
    data: (scorecards) {
      if (scorecards.isEmpty) {
        return {
          'roundsPlayed': 0,
          'averageScore': 0.0,
          'wins': 0,
          'bestScore': 0,
        };
      }

      final completedScorecards = scorecards.where((s) => 
        s.status == ScorecardStatus.finalScore || s.status == ScorecardStatus.submitted
      ).toList();

      if (completedScorecards.isEmpty) {
        return {
          'roundsPlayed': 0,
          'averageScore': 0.0,
          'wins': 0,
          'bestScore': 0,
        };
      }

      int totalGross = 0;
      int bestScore = 999;
      int wins = 0; 

      for (var s in completedScorecards) {
        final gross = s.holeScores.whereType<int>().fold(0, (a, b) => a + b);
        if (gross > 0) {
          totalGross += gross;
          if (gross < bestScore) bestScore = gross;
        }
      }

      final roundsPlayed = completedScorecards.length;
      final avgScore = roundsPlayed > 0 ? (totalGross / roundsPlayed) : 0.0;

      return {
        'roundsPlayed': roundsPlayed,
        'averageScore': double.parse(avgScore.toStringAsFixed(1)),
        'wins': wins,
        'bestScore': bestScore == 999 ? 0 : bestScore,
      };
    },
    loading: () => {
      'roundsPlayed': '...',
      'averageScore': '...',
      'wins': '...',
      'bestScore': '...',
    },
    error: (e, s) => {
      'roundsPlayed': 0,
      'averageScore': 0.0,
      'wins': 0,
      'bestScore': 0,
    },
  );
});

// New provider to watch scorecards for a specific member
final memberScorecardsProvider = StreamProvider.family<List<Scorecard>, String>((ref, memberId) {
  return ref.watch(scorecardRepositoryProvider).watchMemberScorecards(memberId);
});
