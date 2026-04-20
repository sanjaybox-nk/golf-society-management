import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/events/logic/event_scoring_processor.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';

import '../../events/presentation/events_provider.dart';
import '../../competitions/presentation/competitions_provider.dart'; // For scorecardRepositoryProvider
import '../../members/presentation/members_provider.dart';
import 'calculators/leaderboard_calculator.dart';
import 'calculators/oom_calculator.dart';
import 'calculators/best_of_series_calculator.dart';
import 'calculators/eclectic_calculator.dart';
import 'calculators/marker_counter_calculator.dart';

final leaderboardInvokerServiceProvider = Provider((ref) => LeaderboardInvokerService(ref));

class LeaderboardInvokerService {
  final Ref ref;

  LeaderboardInvokerService(this.ref);

  Future<void> recalculateAll(String seasonId, {List<LeaderboardConfig>? overrideConfigs}) async {
    // 1. Fetch Season
    final seasonRepo = ref.read(seasonsRepositoryProvider);
    final seasons = await seasonRepo.getSeasons();
    final season = seasons.firstWhere((s) => s.id == seasonId);

    // Use overrideConfigs if provided (e.g. from a form), otherwise use the ones in the saved season
    final configs = overrideConfigs ?? season.leaderboards;

    // 2. Fetch All Competitions in Date Range
    final compRepo = ref.read(competitionsRepositoryProvider);
    final allComps = await compRepo.getCompetitions(); 
    final dateFilteredComps = allComps.where((c) => 
      c.startDate.isAfter(season.startDate.subtract(const Duration(days: 1))) && 
      c.endDate.isBefore(season.endDate.add(const Duration(days: 1)))
    ).toList();

    // 2.5 Fetch All relevant Events for Grouping Context & Invitational Filtering
    final eventRepo = ref.read(eventsRepositoryProvider);
    final List<Competition> allSeasonComps = [];
    final Map<String, GolfEvent> seasonEvents = {};
    final Map<String, ProcessedEventData> processedSeasonEvents = {};

    // 2.6 Fetch Members for name resolution and scoring processing
    final memberRepo = ref.read(membersRepositoryProvider);
    final members = await memberRepo.getMembers();
    final Map<String, String> memberNames = {for (var m in members) m.id: m.displayName};

    final scorecardRepo = ref.read(scorecardRepositoryProvider);

    for (var comp in dateFilteredComps) {
      final event = await eventRepo.getEvent(comp.id);
      if (event == null) continue;

      allSeasonComps.add(comp);
      seasonEvents[comp.id] = event;
      
      final cards = await scorecardRepo.getScorecards(comp.id);
      
      // Use the CENTRAL SCORING ENGINE logic to process this event's results
      final processedData = EventScoringProcessor.process(
        eventId: comp.id, 
        event: event, 
        comp: comp, 
        liveScorecards: cards, 
        members: members, 
        markerSelection: MarkerSelection(isSelfMarking: true),
      );
      
      processedSeasonEvents[comp.id] = processedData;
    }

    // 3. For each Leaderboard, calculate
    for (var config in configs) {
      LeaderboardCalculator? calculator;

      config.map(
        orderOfMerit: (_) => calculator = OOMCalculator(),
        bestOfSeries: (_) => calculator = BestOfSeriesCalculator(),
        eclectic: (_) => calculator = EclecticCalculator(),
        markerCounter: (_) => calculator = MarkerCounterCalculator(), 
      );

      if (calculator != null) {
        // FILTER Competitions based on Scope
        final filteredComps = allSeasonComps.where((comp) {
          final event = seasonEvents[comp.id];
          if (event == null) return false;
          
          final isInvitational = event.isInvitational;
          
          return config.scope == LeaderboardScope.global || 
                 (config.scope == LeaderboardScope.seasonOnly && !isInvitational) ||
                 (config.scope == LeaderboardScope.invitationalsOnly && isInvitational);
        }).toList();

        final filteredProcessedEvents = Map<String, ProcessedEventData>.fromEntries(
          processedSeasonEvents.entries.where((e) => filteredComps.any((c) => c.id == e.key))
        );

        // Calculate using the filtered data
        final standings = await calculator!.calculate(
          config: config,
          competitions: filteredComps,
          scorecards: [], 
          groupings: {}, 
          processedEvents: filteredProcessedEvents,
        );

        // Update standings with real names
        final namedStandings = standings.map((s) => s.copyWith(
          memberName: memberNames[s.memberId] ?? s.memberName,
        )).toList();

        // Save
        await seasonRepo.updateLeaderboardStandings(seasonId, config.id, namedStandings);
      }
    }
  }
}
