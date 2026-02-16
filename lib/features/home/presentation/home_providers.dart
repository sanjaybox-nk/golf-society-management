import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/golf_event.dart';
import '../../../models/notification.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../notifications/data/firestore_notifications_repository.dart';

// Mock data provider for Next Match
import '../../../models/leaderboard_standing.dart';
import '../../../models/leaderboard_config.dart';
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

// Active Leaderboard Standings for Home (e.g., top 3 of the main OOM)
final homeSeasonLeaderboardProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final activeSeasonAsync = ref.watch(activeSeasonProvider);
  
  // If still loading or error, propagate that state
  if (activeSeasonAsync is AsyncLoading) return const AsyncValue.loading();
  if (activeSeasonAsync is AsyncError) return AsyncValue.error(activeSeasonAsync.error!, activeSeasonAsync.stackTrace!);

  final season = activeSeasonAsync.value;
  if (season == null || season.leaderboards.isEmpty) {
    return const AsyncValue.data(<Map<String, dynamic>>[]);
  }
    
  // Find the main Order of Merit config
  final oomConfig = season.leaderboards.firstWhere(
    (l) => l is OrderOfMeritConfig,
    orElse: () => season.leaderboards.first,
  );
    
  final standingsAsync = ref.watch(leaderboardStandingsProvider(oomConfig.id));
    
  return standingsAsync.whenData((standings) {
    return standings.take(3).map((s) => {
      'name': s.memberName,
      'points': s.points.round(),
      'position': standings.indexOf(s) + 1,
    }).toList();
  });
});

final leaderboardStandingsProvider = StreamProvider.family<List<LeaderboardStanding>, String>((ref, leaderboardId) {
  final activeSeason = ref.watch(activeSeasonProvider).asData?.value;
  if (activeSeason == null) return Stream.value(<LeaderboardStanding>[]);
  
  return ref.watch(seasonsRepositoryProvider).watchLeaderboardStandings(activeSeason.id, leaderboardId);
});
