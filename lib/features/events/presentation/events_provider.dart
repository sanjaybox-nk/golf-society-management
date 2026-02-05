import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/golf_event.dart';
import '../../../models/season.dart';
import '../../events/data/events_repository.dart';
import '../../events/data/firestore_events_repository.dart';
import '../../admin/data/seasons_repository.dart';
import '../../admin/data/firestore_seasons_repository.dart';
import '../../admin/data/leaderboard_templates_repository.dart';

enum EventFilter { upcoming, past }

class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => EventFilter.upcoming;
  
  void update(EventFilter filter) => state = filter;
}

final eventFilterProvider = NotifierProvider<EventFilterNotifier, EventFilter>(EventFilterNotifier.new);

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return FirestoreEventsRepository(FirebaseFirestore.instance);
});

final seasonsRepositoryProvider = Provider<SeasonsRepository>((ref) {
  return FirestoreSeasonsRepository(FirebaseFirestore.instance);
});

final leaderboardTemplatesRepositoryProvider = Provider<LeaderboardTemplatesRepository>((ref) {
  return FirestoreLeaderboardTemplatesRepository(FirebaseFirestore.instance);
});

// Seasons Stream
final seasonsProvider = StreamProvider<List<Season>>((ref) {
  return ref.watch(seasonsRepositoryProvider).watchSeasons();
});

// Active (Current) Season Provider
final activeSeasonProvider = Provider<AsyncValue<Season?>>((ref) {
  final seasonsAsync = ref.watch(seasonsProvider);
  return seasonsAsync.whenData((seasons) {
    try {
      // Prioritize isCurrent, fallback to first active
      return seasons.firstWhere(
        (s) => s.isCurrent, 
        orElse: () => seasons.firstWhere((s) => s.status == SeasonStatus.active),
      );
    } catch (_) {
      return null;
    }
  });
});

// 2. Main Events Stream (Published + Completed for members)
final eventsProvider = StreamProvider<List<GolfEvent>>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  final activeSeasonAsync = ref.watch(activeSeasonProvider);
  
  return activeSeasonAsync.when(
    data: (activeSeason) {
      if (activeSeason == null) return Stream.value([]);
      // Show published and completed events (exclude drafts and cancelled)
      return repository.watchEvents(seasonId: activeSeason.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

// Admin Events Stream (All statuses)
final adminEventsProvider = StreamProvider<List<GolfEvent>>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  final activeSeasonAsync = ref.watch(activeSeasonProvider);
  
  return activeSeasonAsync.when(
    data: (activeSeason) {
      // Admins see events for the active season, or ALL events if no season is active
      return repository.watchEvents(seasonId: activeSeason?.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

// 3. Derived: Upcoming
final upcomingEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.whenData((events) {
    final now = DateTime.now();
    final upcoming = events.where((e) => e.date.isAfter(now)).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  });
});

// 4. Derived: Past
final pastEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.whenData((events) {
    final now = DateTime.now();
    final past = events.where((e) => e.date.isBefore(now)).toList();
    past.sort((a, b) => b.date.compareTo(a.date));
    return past;
  });
});
// Single Event Provider
final eventProvider = StreamProvider.family<GolfEvent, String>((ref, id) {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.watchEvents().map((events) {
    return events.firstWhere((e) => e.id == id);
  });
});
