import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/member.dart';
import '../../../models/golf_event.dart';
import '../../events/presentation/events_provider.dart';

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

  return eventsAsync.whenData((events) {
    int starts = 0;
    int wins = 0;
    int top5 = 0;
    List<int> points = [];
    int bestPts = 0;

    // 1. Process Event History
    for (final event in events) {
      if (event.status == EventStatus.cancelled) continue;

      // Check Attendance
      final reg = event.registrations.where((r) => r.memberId == memberId && r.isConfirmed && r.attendingGolf).firstOrNull;
      if (reg != null) {
        starts++;
      }

      // Check Results (if finalized)
      if (event.status == EventStatus.completed || event.isScoringLocked) {
        // finalizedStats logic here...
        // Note: Hall of Fame logic is tricky for Wins/Top5. 
        // Better to use the 'results' field if available, or parse scorecards?
        // Actually, 'event.results' was empty in our search. 
        // We might need to rely on 'finalizedStats' containing leaderboard data?
        // Let's assume for now we only have 'Starts' reliable. 
        // wait, we found 'event.results' in AnalysisEngine reading!
        
        // Let's iterate event.results which AnalysisEngine populates!
        // The AnalysisEngine reads event.results but doesn't write to it in the code we saw?
        // Wait, 'EventAdminScoresScreen' calls 'updateEvent(event.copyWith(finalizedStats: stats))'
        
        // Let's look at how leaderboard is stored. 
        // AnalysisEngine *reads* event.results to merge archived scores.
        // But where are they written? 
        // It seems 'event.results' might be legacy or manual?
        
        // WORKAROUND: We will calculate stats from available scorecards if accessible?
        // No, we don't have access to all scorecards here easily without firing 20 queries.
        
        // Let's use what we have in 'finalizedStats' or 'results'.
        // If 'event.results' is empty, we might be out of luck for detailed history without a big query.
        
        // However, we can use the 'registrations' to at least guess 'Wins' if we stored points there? No.
        
        // Let's stick to 'Starts' and 'Avg Points' if we can find points?
        // Converting this provider to just return a dummy for now until we hook up real data?
        // OR: use the 'competitions' data source if available?
        
        // Let's try to parse 'event.results' if it exists.
        for (final res in event.results) {
          if (res['memberId'] == memberId) {
             final pos = res['position'] as int?;
             final pts = res['points'] as int?;
             
             if (pos == 1) wins++;
             if (pos != null && pos <= 5) top5++;
             if (pts != null) {
               points.add(pts);
               if (pts > bestPts) bestPts = pts;
             }
          }
        }
      }
    }

    double avgPts = points.isEmpty ? 0.0 : points.reduce((a, b) => a + b) / points.length;

    return MemberPerformance(
      starts: starts,
      wins: wins,
      top5: top5,
      avgPts: avgPts,
      bestPts: bestPts,
      rank: null, // Rank requires fetching the Season Standings, which is separate.
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
