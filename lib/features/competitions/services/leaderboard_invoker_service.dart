import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/leaderboard_config.dart';
import '../../../../models/scorecard.dart';
import '../../events/presentation/events_provider.dart';
import '../../competitions/presentation/competitions_provider.dart'; // For scorecardRepositoryProvider
import 'calculators/leaderboard_calculator.dart';
import 'calculators/oom_calculator.dart';
import 'calculators/best_of_series_calculator.dart';
import 'calculators/eclectic_calculator.dart';
import 'calculators/marker_counter_calculator.dart';

final leaderboardInvokerServiceProvider = Provider((ref) => LeaderboardInvokerService(ref));

class LeaderboardInvokerService {
  final Ref ref;

  LeaderboardInvokerService(this.ref);

  Future<void> recalculateAll(String seasonId) async {
    // 1. Fetch Season
    final seasonRepo = ref.read(seasonsRepositoryProvider);
    final seasons = await seasonRepo.getSeasons();
    final season = seasons.firstWhere((s) => s.id == seasonId);

    // 2. Fetch All Competitions in Date Range
    final compRepo = ref.read(competitionsRepositoryProvider);
    final allComps = await compRepo.getCompetitions(); 
    final seasonComps = allComps.where((c) => 
      c.startDate.isAfter(season.startDate.subtract(const Duration(days: 1))) && 
      c.endDate.isBefore(season.endDate.add(const Duration(days: 1)))
    ).toList();

    // 2.5 Fetch All relevant Events for Grouping Context
    final eventRepo = ref.read(eventsRepositoryProvider);
    final Map<String, Map<String, dynamic>> groupings = {};
    for (var comp in seasonComps) {
      final event = await eventRepo.getEvent(comp.id);
      if (event != null && event.grouping.isNotEmpty) {
        groupings[comp.id] = event.grouping;
      }
    }

    // 3. For each Leaderboard, calculate
    for (var config in season.leaderboards) {
      LeaderboardCalculator? calculator;

      config.map(
        orderOfMerit: (_) => calculator = OOMCalculator(),
        bestOfSeries: (_) => calculator = BestOfSeriesCalculator(),
        eclectic: (_) => calculator = EclecticCalculator(),
        markerCounter: (_) => calculator = MarkerCounterCalculator(), 
      );

      if (calculator != null) {
        // Fetch Scorecards for these competitions
        List<Scorecard> allScorecards = [];
        final scorecardRepo = ref.read(scorecardRepositoryProvider);

        for (var comp in seasonComps) {
           // Create a safe fetch wrapper
           try {
             final stream = scorecardRepo.watchScorecards(comp.id);
             final cards = await stream.first; 
             allScorecards.addAll(cards);
           } catch (_) {
             // Silently fail or use a logger
           }
        }
        
        // Calculate
        final standings = await calculator!.calculate(
          config: config,
          competitions: seasonComps,
          scorecards: allScorecards,
          groupings: groupings,
        );

        // Save
        await seasonRepo.updateLeaderboardStandings(seasonId, config.id, standings);
      }
    }
  }
}
