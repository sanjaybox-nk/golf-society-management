import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/golf_event.dart';

final eventsProvider = Provider<List<GolfEvent>>((ref) {
  return [
    // Upcoming Events
    GolfEvent(
      id: '1',
      title: 'Spring Championship 2026',
      location: 'Royal Pines Golf Club',
      date: DateTime(2026, 3, 15, 9, 0),
      teeOffTime: DateTime(2026, 3, 15, 9, 30),
      description: 'Annual Spring Championship - 18 holes stroke play',
    ),
    GolfEvent(
      id: '2',
      title: 'April Medal',
      location: 'Links Course',
      date: DateTime(2026, 4, 12, 10, 0),
      teeOffTime: DateTime(2026, 4, 12, 10, 30),
      description: 'Monthly Medal competition',
    ),
    
    // Past Events
    GolfEvent(
      id: '3',
      title: 'Winter Warmer',
      location: 'Forest Valley',
      date: DateTime(2025, 12, 10, 9, 0),
      teeOffTime: DateTime(2025, 12, 10, 9, 30),
      description: 'Pre-Christmas get together',
    ),
    GolfEvent(
      id: '4',
      title: 'Autumn Shield',
      location: 'Dunes Club',
      date: DateTime(2025, 10, 15, 8, 30),
      teeOffTime: DateTime(2025, 10, 15, 9, 0),
      description: 'Season closing major',
    ),
  ];
});

final upcomingEventsProvider = Provider<List<GolfEvent>>((ref) {
  final events = ref.watch(eventsProvider);
  final now = DateTime.now();
  final upcoming = events.where((e) => e.date.isAfter(now)).toList();
  upcoming.sort((a, b) => a.date.compareTo(b.date));
  return upcoming;
});

final pastEventsProvider = Provider<List<GolfEvent>>((ref) {
  final events = ref.watch(eventsProvider);
  final now = DateTime.now();
  final past = events.where((e) => e.date.isBefore(now)).toList();
  past.sort((a, b) => b.date.compareTo(a.date)); // Sort descending
  return past;
});
