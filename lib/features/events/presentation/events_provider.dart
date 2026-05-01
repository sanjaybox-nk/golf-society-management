import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/utils/date_utils.dart';
import 'package:golf_society/utils/firebase_providers.dart';
import '../../events/data/events_repository.dart';
import '../../events/data/firestore_events_repository.dart';
import '../../admin/data/seasons_repository.dart';
import '../../admin/data/firestore_seasons_repository.dart';
import '../../admin/data/leaderboard_templates_repository.dart';

enum EventFilter { season, social }

/// Member Events tab filter — isolated from admin tab state.
final eventFilterProvider = NotifierProvider<EventFilterNotifier, EventFilter>(EventFilterNotifier.new);

class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => EventFilter.season;
  void update(EventFilter filter) => state = filter;
}

/// Admin Events tab filter — isolated from member tab state.
final adminEventFilterProvider = NotifierProvider<AdminEventFilterNotifier, EventFilter>(AdminEventFilterNotifier.new);

class AdminEventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => EventFilter.season;
  void update(EventFilter filter) => state = filter;
}

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return FirestoreEventsRepository(ref.watch(firestoreProvider));
});

final seasonsRepositoryProvider = Provider<SeasonsRepository>((ref) {
  return FirestoreSeasonsRepository(ref.watch(firestoreProvider));
});

final leaderboardTemplatesRepositoryProvider = Provider<LeaderboardTemplatesRepository>((ref) {
  return FirestoreLeaderboardTemplatesRepository(ref.watch(firestoreProvider));
});

// Seasons Stream
final seasonsProvider = StreamProvider<List<Season>>((ref) {
  return ref.watch(seasonsRepositoryProvider).watchSeasons();
});

// Active (Current) Season Provider
final activeSeasonProvider = Provider<AsyncValue<Season?>>((ref) {
  final seasonsAsync = ref.watch(seasonsProvider);
  return seasonsAsync.whenData((seasons) {
    if (seasons.isEmpty) return null;
    
    try {
      // 1. Primary: isCurrent
      return seasons.firstWhere(
        (s) => s.isCurrent, 
        // 2. Secondary: Any active status
        orElse: () => seasons.firstWhere(
          (s) => s.status == SeasonStatus.active,
          // 3. Last Resort: Most recent by date
          orElse: () {
            final sorted = List<Season>.from(seasons)..sort((a, b) => b.startDate.compareTo(a.startDate));
            return sorted.first;
          },
        ),
      );
    } catch (_) {
      return null;
    }
  });
});

// Specific Season Provider
final seasonByIdProvider = Provider.family<AsyncValue<Season?>, String>((ref, id) {
  final seasonsAsync = ref.watch(seasonsProvider);
  return seasonsAsync.whenData((seasons) => seasons.firstWhereOrNull((s) => s.id == id));
});

// 2. Main Events Stream (Source of Truth)
final allEventsProvider = StreamProvider<List<GolfEvent>>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  final activeSeasonAsync = ref.watch(activeSeasonProvider);
  
  return activeSeasonAsync.when(
    data: (s) => repository.watchEvents(seasonId: s?.id),
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.value(<GolfEvent>[]),
  );
});

/// Member Events (Exclude Drafts/Cancelled)
final eventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(allEventsProvider).whenData((events) => 
    events.where((e) => 
      e.status != EventStatus.draft && 
      e.status != EventStatus.cancelled
    ).toList()
  );
});

/// Admin Events (All statuses)
final adminEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(allEventsProvider);
});

// Global (Non-event) Expenses Stream
final globalExpensesProvider = StreamProvider<List<EventExpense>>((ref) {
  return ref.watch(eventsRepositoryProvider).watchGlobalExpenses();
});

// Helper for Social filtering
List<GolfEvent> _filterSocial(List<GolfEvent> events) {
  final social = events.where((e) => e.eventType == EventType.social).toList();
  social.sort((a, b) => b.date.compareTo(a.date));
  return social;
}

// Helper for Season/Invitational filtering
List<GolfEvent> _filterSeason(List<GolfEvent> events) {
  return events.where((e) => e.eventType != EventType.social).toList();
}

// 3. Member Derived Providers
final upcomingEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(eventsProvider).whenData(DateUtils.filterUpcoming);
});

final pastEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(eventsProvider).whenData(DateUtils.filterPast);
});

final socialEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(eventsProvider).whenData(_filterSocial);
});

final seasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(eventsProvider).whenData(_filterSeason);
});

final upcomingSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(seasonEventsProvider).when(
    data: (events) => AsyncValue.data(DateUtils.filterUpcoming(events)),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

final pastSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(seasonEventsProvider).when(
    data: (events) => AsyncValue.data(DateUtils.filterPast(events)),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// 4. Admin Derived Providers
final adminSocialEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(adminEventsProvider).whenData(_filterSocial);
});

final adminSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(adminEventsProvider).whenData(_filterSeason);
});

final adminUpcomingSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(adminSeasonEventsProvider).when(
    data: (events) => AsyncValue.data(DateUtils.filterUpcoming(events)),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

final adminPastSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  return ref.watch(adminSeasonEventsProvider).when(
    data: (events) => AsyncValue.data(DateUtils.filterPast(events)),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// 7. Single Event Provider
final eventProvider = StreamProvider.family<GolfEvent, String>((ref, id) {
  if (id.isEmpty) {
    debugPrint('DEBUG_PROVIDER: eventProvider called with EMPTY ID');
    throw Exception('Event ID cannot be empty');
  }
  debugPrint('DEBUG_PROVIDER: eventProvider(id=$id)');
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.watchEvent(id).map((event) {
    if (event == null) {
      debugPrint('DEBUG_PROVIDER: Event $id NOT FOUND in Firestore');
      throw Exception('Event $id not found');
    }
    return event;
  });
});
