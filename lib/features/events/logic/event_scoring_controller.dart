import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import '../domain/models/processed_event_data.dart';
import 'event_scoring_processor.dart';
import 'package:collection/collection.dart';

part 'event_scoring_controller.g.dart';

@riverpod
class EventScoringController extends _$EventScoringController {
  @override
  ProcessedEventData build(String eventId) {
    // 1. Watch inputs
    final eventAsync = ref.watch(eventProvider(eventId));
    final event = eventAsync.value;
    
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final comp = compAsync.value;
    final liveScorecards = ref.watch(scorecardsListProvider(eventId)).value ?? [];
    final members = ref.watch(allMembersProvider).value ?? [];
    final markerSelection = ref.watch(markerSelectionProvider);

    if (event == null || comp == null) {
      return ProcessedEventData(
        eventId: eventId,
        individualScores: [],
        leaderboard: [],
        groupRankings: [],
        eventStats: {},
        holePars: [],
        lastComputedAt: DateTime.now(),
      );
    }

    // 2. Delegate to Processor
    return EventScoringProcessor.process(
      eventId: eventId,
      event: event,
      comp: comp,
      liveScorecards: liveScorecards,
      members: members,
      markerSelection: markerSelection,
      currentUserId: ref.watch(effectiveUserProvider).id,
    );
  }
}
