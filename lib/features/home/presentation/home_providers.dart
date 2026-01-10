import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/golf_event.dart';
import '../../../models/notification.dart';

// Mock data provider for Next Match
final homeNextMatchProvider = Provider<GolfEvent>((ref) {
  return GolfEvent(
    id: '1',
    title: 'Spring Championship 2026',
    location: 'Royal Pines Golf Club',
    date: DateTime(2026, 3, 15, 9, 0),
    description: 'Annual Spring Championship - 18 holes stroke play',
    imageUrl: null,
    teeOffTime: DateTime(2026, 3, 15, 9, 30),
  );
});

// Mock data provider for Notifications
final homeNotificationsProvider = Provider<List<AppNotification>>((ref) {
  return [
    AppNotification(
      id: '1',
      title: 'Event Reminder',
      message: 'Spring Championship - Registration closes in 2 days',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'Payment Due',
      message: 'Annual membership fee is due on March 15th',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
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
