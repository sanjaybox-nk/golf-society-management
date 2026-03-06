import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/notification.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../notifications/data/firestore_notifications_repository.dart';
import '../../members/presentation/profile_provider.dart';

// Mock data provider for Next Match
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
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
  final user = ref.watch(effectiveUserProvider);
  return repository.watchNotifications(user.id);
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
    final currentMember = ref.watch(effectiveUserProvider);
    final memberIndex = standings.indexWhere((s) => s.memberId == currentMember.id);
    
    // If user is in Top 3 or not found, just show Top 3
    if (memberIndex == -1 || memberIndex < 3) {
      return standings.take(3).map((s) => {
        'name': s.memberName,
        'points': s.points.round(),
        'position': standings.indexOf(s) + 1,
      }).toList();
    }
    
    // "Sandwich" Logic: Show Top 2 + current member
    final result = standings.take(2).map((s) => {
      'name': s.memberName,
      'points': s.points.round(),
      'position': standings.indexOf(s) + 1,
    }).toList();
    
    final s = standings[memberIndex];
    result.add({
      'name': s.memberName,
      'points': s.points.round(),
      'position': memberIndex + 1,
    });
    
    return result;
  });
});

// Member's personal standing for the primary seasonal competition
final homeMemberStandingProvider = Provider<AsyncValue<Map<String, dynamic>?>>((ref) {
  final activeSeasonAsync = ref.watch(activeSeasonProvider);
  
  if (activeSeasonAsync is AsyncLoading) return const AsyncValue.loading();
  if (activeSeasonAsync is AsyncError) return AsyncValue.error(activeSeasonAsync.error!, activeSeasonAsync.stackTrace!);

  final season = activeSeasonAsync.value;
  if (season == null || season.leaderboards.isEmpty) return const AsyncValue.data(null);
    
  final oomConfig = season.leaderboards.firstWhere(
    (l) => l is OrderOfMeritConfig,
    orElse: () => season.leaderboards.first,
  );
    
  final standingsAsync = ref.watch(leaderboardStandingsProvider(oomConfig.id));
  final currentMember = ref.watch(effectiveUserProvider);

  return standingsAsync.whenData((standings) {
    final index = standings.indexWhere((s) => s.memberId == currentMember.id);
    if (index == -1) return null;
    
    return {
      'standing': standings[index],
      'rank': index + 1,
    };
  });
});

final homeSeasonStakesProvider = Provider<AsyncValue<String?>>((ref) {
  final nextMatchAsync = ref.watch(homeNextMatchProvider);
  final memberStandingAsync = ref.watch(homeMemberStandingProvider);
  
  if (nextMatchAsync is AsyncLoading || memberStandingAsync is AsyncLoading) return const AsyncValue.loading();
  
  final nextMatch = nextMatchAsync.value;
  final standingData = memberStandingAsync.value;
  
  if (nextMatch == null || standingData == null) return const AsyncValue.data(null);
  
  // Logic: "A Top 5 finish at [Course] could move you into the Top [N]!"
  // For demo purposes, we'll calculate a potential jump.
  
  return AsyncValue.data(
    "A win at ${nextMatch.courseName ?? 'the next course'} could move you into the Top 10 of the Order of Merit!"
  );
});

final leaderboardStandingsProvider = StreamProvider.family<List<LeaderboardStanding>, String>((ref, leaderboardId) {
  final activeSeason = ref.watch(activeSeasonProvider).asData?.value;
  if (activeSeason == null) return Stream.value(<LeaderboardStanding>[]);
  
  return ref.watch(seasonsRepositoryProvider).watchLeaderboardStandings(activeSeason.id, leaderboardId);
});
