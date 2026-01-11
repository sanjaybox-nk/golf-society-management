import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/golf_event.dart';
import '../../../models/notification.dart';

// Mock data provider for Next Match
import '../../events/presentation/events_provider.dart';

// Next Match derived from Upcoming Events
final homeNextMatchProvider = Provider<AsyncValue<GolfEvent?>>((ref) {
  final upcomingAsync = ref.watch(upcomingEventsProvider);
  return upcomingAsync.whenData((events) {
    if (events.isEmpty) return null;
    return events.first; // First element is the nearest upcoming event
  });
});

// Mock data provider for Notifications
final homeNotificationsProvider = Provider<List<AppNotification>>((ref) {
  return [
    AppNotification(
      id: '1',
      title: 'Event Reminder',
      message: 'Spring Championship - Registration closes in 2 days',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Urgent',
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'Course Update',
      message: 'The front nine is now open after maintenance.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      category: 'Info',
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: 'Payment Due',
      message: 'Annual membership fee is due on March 15th',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Info',
      isRead: true,
    ),
  ];
});

// Mock data provider for Leaderboard
final homeLeaderboardProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'name': 'John Smith', 'points': 245, 'position': 1},
    {'name': 'Jane Doe', 'points': 238, 'position': 2},
    {'name': 'Bob Wilson', 'points': 225, 'position': 3},
  ];
});
