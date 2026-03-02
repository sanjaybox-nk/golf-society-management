import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../../domain/models/golf_event.dart';

class ReportingHubStats {
  final double totalRevenue; // Paid
  final double totalExpenses;
  final double totalCashPrizes;
  final int totalCupsAwarded;
  final int totalVouchersAwarded;
  final double totalVoucherValue;
  final double averageAttendance;
  final int totalRoundsPlayed;
  final int totalCount;
  final int completedCount;
  
  // Phase 11.1 Additions
  final Map<String, double> revenueBreakdown;
  final List<MapEntry<String, int>> topMembers;
  
  // Phase 11.2 Additions
  final double uncollectedRevenue;
  final double totalPotentialRevenue;
  final double greenFeeMarkup;
  final double averageEventCostPerMember;

  // Phase 11.3 Additions
  final List<String> everPresentMemberIds;
  final List<String> churnAlertMemberIds;
  final double retentionRate;

  // Phase 11.4 Additions
  final Map<String, double> courseDifficultyIndex; // Course Name -> Avg Points
  final List<MapEntry<String, int>> podiumConsistency; // Member ID -> Top 3 Count

  ReportingHubStats({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalCashPrizes,
    required this.totalCupsAwarded,
    required this.totalVouchersAwarded,
    required this.totalVoucherValue,
    required this.averageAttendance,
    required this.totalRoundsPlayed,
    required this.totalCount,
    required this.completedCount,
    required this.revenueBreakdown,
    required this.topMembers,
    required this.uncollectedRevenue,
    required this.totalPotentialRevenue,
    required this.greenFeeMarkup,
    required this.averageEventCostPerMember,
    required this.everPresentMemberIds,
    required this.churnAlertMemberIds,
    required this.retentionRate,
    required this.courseDifficultyIndex,
    required this.podiumConsistency,
  });

  double get netTreasury => totalRevenue - totalExpenses - totalCashPrizes;
}

final reportingHubStatsProvider = Provider<AsyncValue<ReportingHubStats>>((ref) {
  final eventsAsync = ref.watch(adminEventsProvider);

  return eventsAsync.whenData((events) {
    double revenue = 0;
    double potentialRevenue = 0;
    double uncollected = 0;
    double expenses = 0;
    double cashPrizes = 0;
    int cups = 0;
    int vouchers = 0;
    double voucherValue = 0;
    int totalAttendance = 0;
    int roundsPlayed = 0;
    int completedCount = 0;

    final Map<String, double> breakdown = {
      'Golf': 0,
      'Buggies': 0,
      'Catering': 0,
    };

    final Map<String, int> attendanceMap = {};

    double totalMarkup = 0;
    int playingRegistrations = 0;

    // Sort events by date to identify "recent" ones
    final sortedEvents = events.sortedBy((e) => e.date);
    final recentEvents = sortedEvents.where((e) => e.status == EventStatus.completed || e.status == EventStatus.published).toList();
    final lastTwoIds = recentEvents.length >= 2 
        ? recentEvents.sublist(recentEvents.length - 2).map((e) => e.id).toSet() 
        : <String>{};

    // Phase 11.4 Data Accumulators
    final Map<String, List<int>> coursePointsMap = {}; // Course -> List of points
    final Map<String, int> podiumMap = {}; // Member -> Top 3 Count

    for (final event in events) {
      if (event.status == EventStatus.completed) completedCount++;

      for (final reg in event.registrations) {
        // Attendance tracking (confirmed only)
        if (reg.isConfirmed && reg.attendingGolf) {
          totalAttendance++;
          attendanceMap[reg.memberId] = (attendanceMap[reg.memberId] ?? 0) + 1;
          playingRegistrations++;
          
          final double memberGolf = event.memberCost ?? 0;
          final double societyGolf = event.societyGreenFee ?? 0;
          totalMarkup += (memberGolf - societyGolf);
          
          if (reg.attendingBreakfast) totalMarkup += ((event.breakfastCost ?? 0) - (event.societyBreakfastCost ?? 0));
          if (reg.attendingLunch) totalMarkup += ((event.lunchCost ?? 0) - (event.societyLunchCost ?? 0));
          if (reg.attendingDinner) totalMarkup += ((event.dinnerCost ?? 0) - (event.societyDinnerCost ?? 0));
        }

        final double regCost = reg.cost;
        potentialRevenue += regCost;
        
        if (reg.hasPaid) {
          revenue += regCost;
          breakdown['Golf'] = (breakdown['Golf'] ?? 0) + (event.memberCost ?? 0);
          if (reg.needsBuggy) breakdown['Buggies'] = (breakdown['Buggies'] ?? 0) + (event.buggyCost ?? 0);
          
          double food = 0;
          if (reg.attendingBreakfast) food += (event.breakfastCost ?? 0);
          if (reg.attendingLunch) food += (event.lunchCost ?? 0);
          if (reg.attendingDinner) food += (event.dinnerCost ?? 0);
          breakdown['Catering'] = (breakdown['Catering'] ?? 0) + food;
        } else if (reg.isConfirmed) {
          uncollected += regCost;
        }
      }
      
      expenses += event.expenses.fold(0.0, (sum, e) => sum + e.amount);
      
      for (final award in event.awards) {
        if (award.type == 'Cash') {
          cashPrizes += award.value;
        } else if (award.type == 'Cup' && award.winnerId != null) {
          cups++;
        } else if (award.type == 'Voucher') {
          vouchers++;
          voucherValue += award.value;
        }
      }

      // Results Processing (Performance Analytics)
      for (final res in event.results) {
        final memberId = res['memberId'] as String?;
        final points = res['points'] as int?;
        final pos = res['position'] as int?;
        
        if (memberId != null) {
          // Podium tracking
          if (pos != null && pos <= 3) {
            podiumMap[memberId] = (podiumMap[memberId] ?? 0) + 1;
          }
          
          // Course points tracking
          if (points != null && event.courseName != null) {
            final course = event.courseName!;
            coursePointsMap[course] ??= [];
            coursePointsMap[course]!.add(points);
          }
        }
      }

      roundsPlayed += event.results.length;
    }

    final avgAttendance = events.isEmpty ? 0.0 : totalAttendance / events.length;
    final avgMemberCost = playingRegistrations == 0 ? 0.0 : potentialRevenue / playingRegistrations;

    // Phase 11.4 Calculations
    final courseDifficulty = coursePointsMap.map((course, pointsList) {
      final avg = pointsList.isEmpty ? 0.0 : pointsList.reduce((a, b) => a + b) / pointsList.length;
      return MapEntry(course, avg);
    });

    final sortedPodiums = podiumMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Phase 11.3 Calculations
    final uniquePlayersCount = attendanceMap.length;
    final repeatPlayersCount = attendanceMap.values.where((count) => count > 1).length;
    final retention = uniquePlayersCount == 0 ? 0.0 : (repeatPlayersCount / uniquePlayersCount) * 100;

    final everPresents = attendanceMap.entries
        .where((e) => e.value == events.length && events.isNotEmpty)
        .map((e) => e.key)
        .toList();

    // Churn Alert: Members who have played at least twice but missed the last 2 events
    final churnAlerts = <String>[];
    if (recentEvents.length >= 3) {
      for (final entry in attendanceMap.entries) {
        final memberId = entry.key;
        final playCount = entry.value;
        
        if (playCount >= 2) {
          bool playedInRecent = false;
          // Check last 2 events
          for (final eventId in lastTwoIds) {
             final event = events.firstWhere((e) => e.id == eventId);
             if (event.registrations.any((r) => r.memberId == memberId && r.isConfirmed && r.attendingGolf)) {
               playedInRecent = true;
               break;
             }
          }
          if (!playedInRecent) churnAlerts.add(memberId);
        }
      }
    }

    // Sort top members
    final sortedMembers = attendanceMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ReportingHubStats(
      totalRevenue: revenue,
      totalExpenses: expenses,
      totalCashPrizes: cashPrizes,
      totalCupsAwarded: cups,
      totalVouchersAwarded: vouchers,
      totalVoucherValue: voucherValue,
      averageAttendance: avgAttendance,
      totalRoundsPlayed: roundsPlayed,
      totalCount: events.length,
      completedCount: completedCount,
      revenueBreakdown: breakdown,
      topMembers: sortedMembers.take(5).toList(),
      uncollectedRevenue: uncollected,
      totalPotentialRevenue: potentialRevenue,
      greenFeeMarkup: totalMarkup,
      averageEventCostPerMember: avgMemberCost,
      everPresentMemberIds: everPresents,
      churnAlertMemberIds: churnAlerts,
      retentionRate: retention,
      courseDifficultyIndex: courseDifficulty,
      podiumConsistency: sortedPodiums,
    );
  });
});
