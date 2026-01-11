import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/golf_event.dart';
import '../../events/data/events_repository.dart';
import '../../events/data/firestore_events_repository.dart';

enum EventFilter { upcoming, past }

class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => EventFilter.upcoming;
  
  void update(EventFilter filter) => state = filter;
}

final eventFilterProvider = NotifierProvider<EventFilterNotifier, EventFilter>(EventFilterNotifier.new);

// 1. Repository Provider
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return FirestoreEventsRepository(FirebaseFirestore.instance);
});

// 2. Main Events Stream
final eventsProvider = StreamProvider<List<GolfEvent>>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.watchEvents();
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
