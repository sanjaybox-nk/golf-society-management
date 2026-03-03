import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:collection/collection.dart';
import '../../events/presentation/events_provider.dart';
import '../../home/presentation/home_providers.dart';

import '../data/members_repository.dart';
import '../data/firestore_members_repository.dart';

// Repository Provider
final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  return FirestoreMembersRepository();
});

// Search Query State
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) => state = query;
}

final memberSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final adminMemberSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// Filter State for Admin
enum AdminMemberFilter { current, committee, other }

class AdminMemberFilterNotifier extends Notifier<AdminMemberFilter> {
  @override
  AdminMemberFilter build() => AdminMemberFilter.current;
  
  void update(AdminMemberFilter filter) => state = filter;
}

final adminMemberFilterProvider = NotifierProvider<AdminMemberFilterNotifier, AdminMemberFilter>(AdminMemberFilterNotifier.new);
final userMemberFilterProvider = NotifierProvider<AdminMemberFilterNotifier, AdminMemberFilter>(AdminMemberFilterNotifier.new);

// All Members Data (Stream)
final allMembersProvider = StreamProvider<List<Member>>((ref) {
  final repo = ref.read(membersRepositoryProvider);
  return repo.watchMembers();
});

// Filtered List based on Search
final filteredMembersProvider = Provider<AsyncValue<List<Member>>>((ref) {
  final allMembersAsync = ref.watch(allMembersProvider);
  final searchQuery = ref.watch(memberSearchQueryProvider).toLowerCase();

  return allMembersAsync.whenData((members) {
    if (searchQuery.isEmpty) {
      return members;
    }

    return members.where((member) {
      final fullName = '${member.firstName} ${member.lastName}'.toLowerCase();
      return fullName.contains(searchQuery);
    }).toList();
  });
});

class MemberPerformance {
  final int starts;
  final int wins;
  final int top5;
  final double avgPts;
  final int bestPts;
  final int? rank;

  const MemberPerformance({
    this.starts = 0,
    this.wins = 0,
    this.top5 = 0,
    this.avgPts = 0.0,
    this.bestPts = 0,
    this.rank,
  });
}

// Detailed Member Stats Provider (Wins, Top 5, etc.)
final memberPerformanceProvider = Provider.family<AsyncValue<MemberPerformance>, String>((ref, memberId) {
  final eventsAsync = ref.watch(adminEventsProvider);
  final activeSeasonAsync = ref.watch(activeSeasonProvider);
  
  // Find primary OOM for ranking
  final activeSeason = activeSeasonAsync.value;
  AsyncValue<List<LeaderboardStanding>> standingsAsync = const AsyncValue.data([]);
  
  if (activeSeason != null && activeSeason.leaderboards.isNotEmpty) {
     final oomConfig = activeSeason.leaderboards.firstWhereOrNull((l) => l is OrderOfMeritConfig) ?? activeSeason.leaderboards.first;
     standingsAsync = ref.watch(leaderboardStandingsProvider(oomConfig.id));
  }

  return eventsAsync.whenData((events) {
    int starts = 0;
    int wins = 0;
    int top5 = 0;
    List<int> points = [];
    int bestPts = 0;

    // 1. Process Event History
    for (final event in events) {
      if (event.status == EventStatus.cancelled) continue;

      if (event.registrations.any((r) => r.memberId == memberId && r.isConfirmed && r.attendingGolf)) {
        starts++;
      }

      final result = event.results.firstWhereOrNull((r) => r['memberId'] == memberId);
      if (result != null) {
        final pos = result['position'] as int?;
        final pts = result['points'] as int?;
        
        if (pos == 1) wins++;
        if (pos != null && pos <= 5) top5++;
        if (pts != null) {
          points.add(pts);
          if (pts > bestPts) bestPts = pts;
        }
      }
    }

    // 2. Resolve Season Rank
    int? rank;
    if (standingsAsync.hasValue) {
      final index = standingsAsync.value!.indexWhere((s) => s.memberId == memberId);
      if (index != -1) rank = index + 1;
    }

    double avgPts = points.isEmpty ? 0.0 : points.reduce((a, b) => a + b) / points.length;

    return MemberPerformance(
      starts: starts,
      wins: wins,
      top5: top5,
      avgPts: avgPts,
      bestPts: bestPts,
      rank: rank,
    );
  });
});

// Legacy Simple Stats Provider (Count of confimed event participations)
final memberStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final eventsAsync = ref.watch(adminEventsProvider);

  return eventsAsync.whenData((events) {
    final stats = <String, int>{};

    for (final event in events) {
      if (event.status != EventStatus.cancelled) { // Count all except cancelled
         for (final reg in event.registrations) {
           if (reg.isConfirmed && reg.attendingGolf) { 
              stats[reg.memberId] = (stats[reg.memberId] ?? 0) + 1;
           }
         }
      }
    }
    return stats;
  });
});
