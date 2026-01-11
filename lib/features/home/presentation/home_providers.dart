import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/golf_event.dart';
import '../../../models/notification.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../notifications/data/firestore_notifications_repository.dart';

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


final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return FirestoreNotificationsRepository();
});

// Real-time Notifications Stream
final homeNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  // TODO: Replace with actual logged-in user ID when Auth is implemented
  const currentUserId = 'current_user_id'; 
  return repository.watchNotifications(currentUserId);
});

// Mock data provider for Leaderboard
final homeLeaderboardProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'name': 'John Smith', 'points': 245, 'position': 1},
    {'name': 'Jane Doe', 'points': 238, 'position': 2},
    {'name': 'Bob Wilson', 'points': 225, 'position': 3},
  ];
});
