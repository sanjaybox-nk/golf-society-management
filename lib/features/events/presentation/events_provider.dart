import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/season.dart';
import '../../events/data/events_repository.dart';
import '../../events/data/firestore_events_repository.dart';
import '../../admin/data/seasons_repository.dart';
import '../../admin/data/firestore_seasons_repository.dart';
import '../../admin/data/leaderboard_templates_repository.dart';

enum EventFilter { season, social }

final eventFilterProvider = NotifierProvider<EventFilterNotifier, EventFilter>(EventFilterNotifier.new);

class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => EventFilter.season;
  
  void update(EventFilter filter) => state = filter;
}

class AdminEventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => EventFilter.season;
  
  void update(EventFilter filter) => state = filter;
}

final adminEventFilterProvider = NotifierProvider<AdminEventFilterNotifier, EventFilter>(AdminEventFilterNotifier.new);

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

// 2. Main Events Stream (Published + Completed for members)
final eventsProvider = StreamProvider<List<GolfEvent>>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  final activeSeasonAsync = ref.watch(activeSeasonProvider);
  
  return activeSeasonAsync.when(
    data: (activeSeason) {
      if (activeSeason == null) return Stream.value([]);
      // Show published, live and completed events (exclude drafts and cancelled)
      return repository.watchEvents(seasonId: activeSeason.id).map((events) {
        return events.where((e) => 
          e.status != EventStatus.draft && 
          e.status != EventStatus.cancelled
        ).toList();
      });
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

// Global (Non-event) Expenses Stream
final globalExpensesProvider = StreamProvider<List<EventExpense>>((ref) {
  return ref.watch(eventsRepositoryProvider).watchGlobalExpenses();
});

// 3. Derived: Upcoming
final upcomingEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.whenData((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final upcoming = events.where((e) {
      final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eventDate.isAtSameMomentAs(today) || 
             eventDate.isAfter(today) || 
             e.status == EventStatus.inPlay;
    }).toList();
    
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  });
});

// 4. Derived: Past
final pastEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.whenData((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final past = events.where((e) {
      final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eventDate.isBefore(today);
    }).toList();
    
    past.sort((a, b) => b.date.compareTo(a.date));
    return past;
  });
});

// 5. Derived: Social
final socialEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.whenData((events) {
    // Only social events, regardless of season status
    final social = events.where((e) => e.eventType == EventType.social).toList();
    social.sort((a, b) => b.date.compareTo(a.date));
    return social;
  });
});

// 6. Derived: Season Events (Split into Upcoming/Past)
final seasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.whenData((events) {
    // All non-social events (includes both Season and Invitationals)
    return events.where((e) => e.eventType != EventType.social).toList();
  });
});

final upcomingSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final seasonEventsAsync = ref.watch(seasonEventsProvider);
  return seasonEventsAsync.whenData((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = events.where((e) {
      final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eventDate.isAtSameMomentAs(today) || 
             eventDate.isAfter(today) || 
             e.status == EventStatus.inPlay;
    }).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  });
});

final pastSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final seasonEventsAsync = ref.watch(seasonEventsProvider);
  return seasonEventsAsync.whenData((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final past = events.where((e) {
      final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eventDate.isBefore(today);
    }).toList();
    past.sort((a, b) => b.date.compareTo(a.date));
    return past;
  });
});

// Admin Derived Providers (Include all statuses)
final adminSocialEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(adminEventsProvider);
  return eventsAsync.whenData((events) {
    final social = events.where((e) => e.eventType == EventType.social).toList();
    social.sort((a, b) => b.date.compareTo(a.date));
    return social;
  });
});

final adminSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(adminEventsProvider);
  return eventsAsync.whenData((events) {
    return events.where((e) => e.eventType != EventType.social).toList();
  });
});

final adminUpcomingSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(adminSeasonEventsProvider);
  return eventsAsync.whenData((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = events.where((e) {
      final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eventDate.isAtSameMomentAs(today) || 
             eventDate.isAfter(today) || 
             e.status == EventStatus.inPlay;
    }).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  });
});

final adminPastSeasonEventsProvider = Provider<AsyncValue<List<GolfEvent>>>((ref) {
  final eventsAsync = ref.watch(adminSeasonEventsProvider);
  return eventsAsync.whenData((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final past = events.where((e) {
      final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eventDate.isBefore(today);
    }).toList();
    past.sort((a, b) => b.date.compareTo(a.date));
    return past;
  });
});

// 7. Single Event Provider
final eventProvider = StreamProvider.family<GolfEvent, String>((ref, id) {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.watchEvent(id).map((event) {
    if (event == null) throw Exception('Event $id not found');
    return event;
  });
});
