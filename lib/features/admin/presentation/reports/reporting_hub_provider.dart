import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../../domain/models/golf_event.dart';
import '../../../../domain/models/society_config.dart';
import '../../../../design_system/theme/theme_controller.dart';

class ReportingHubStats {
  final double totalRevenue;
  final double totalExpenses;
  final double totalCashPrizes;
  final int totalCupsAwarded;
  final int totalVouchersAwarded;
  final int totalCashAwardsCount;
  final int totalUniqueWinners;
  final double totalVoucherValue;
  final double averageAttendance;
  final int totalRoundsPlayed;
  final int totalCount;
  final int completedCount;
  final Map<String, double> revenueBreakdown;
  final List<MapEntry<String, int>> topMembers;
  final Map<String, int> attendanceMap;
  final double uncollectedRevenue;
  final double totalPotentialRevenue;
  final double greenFeeMarkup;
  final double averageEventCostPerMember;
  final List<String> everPresentMemberIds;
  final List<String> churnAlertMemberIds;
  final double retentionRate;
  final Map<String, double> courseDifficultyIndex;
  final List<MapEntry<String, int>> podiumConsistency;
  final double totalSocietyCosts;
  final double totalCollectedFines;
  final double totalUnpaidFines;
  final double totalCharity;
  final double startingBalance;
  final List<FinancialEntry> ledgerEntries;

  ReportingHubStats({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalCashPrizes,
    required this.totalCupsAwarded,
    required this.totalVouchersAwarded,
    required this.totalCashAwardsCount,
    required this.totalUniqueWinners,
    required this.totalVoucherValue,
    required this.averageAttendance,
    required this.totalRoundsPlayed,
    required this.totalCount,
    required this.completedCount,
    required this.revenueBreakdown,
    required this.topMembers,
    required this.attendanceMap,
    required this.uncollectedRevenue,
    required this.totalPotentialRevenue,
    required this.greenFeeMarkup,
    required this.averageEventCostPerMember,
    required this.everPresentMemberIds,
    required this.churnAlertMemberIds,
    required this.retentionRate,
    required this.courseDifficultyIndex,
    required this.podiumConsistency,
    required this.totalSocietyCosts,
    required this.totalCollectedFines,
    required this.totalUnpaidFines,
    required this.totalCharity,
    required this.startingBalance,
    required this.ledgerEntries,
  });

  double get totalLedgerRevenue => ledgerEntries
      .where((e) => e.isPaid && (e.type == 'Sponsorship' || e.type == 'Donation'))
      .fold(0.0, (sum, e) => sum + e.amount);
  double get totalUnpaidLedgerRevenue => ledgerEntries
      .where((e) => !e.isPaid && (e.type == 'Sponsorship' || e.type == 'Donation'))
      .fold(0.0, (sum, e) => sum + e.amount);
  double get totalLedgerExpenditure => ledgerEntries
      .where((e) => e.type == 'Expenditure')
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netTreasury => startingBalance + totalRevenue + totalCollectedFines + totalCharity + totalLedgerRevenue - totalExpenses - totalCashPrizes - totalSocietyCosts - totalLedgerExpenditure;
}

final reportingHubStatsProvider = Provider<AsyncValue<ReportingHubStats>>((ref) {
  final eventsAsync = ref.watch(adminEventsProvider);
  final globalExpensesAsync = ref.watch(globalExpensesProvider);
  final config = ref.watch(themeControllerProvider);

  return eventsAsync.when(
    data: (events) => globalExpensesAsync.when(
      data: (globalExpenses) {
        double revenue = 0;
        double potentialRevenue = 0;
        double uncollected = 0;
        double expenses = 0;
        double cashPrizes = 0;
        int cups = 0;
        int vouchers = 0;
        int cashAwardsCount = 0;
        double voucherValue = 0;
        int totalAttendance = 0;
        int roundsPlayed = 0;
        int completedCount = 0;
        double collectedFines = 0;
        double unpaidFines = 0;
        double charityPot = 0;

        // Add global expenses to total
        expenses += globalExpenses.fold(0.0, (sum, e) => sum + e.amount);

        final Map<String, double> breakdown = {
          'Golf': 0,
          'Buggies': 0,
          'Catering': 0,
          'Fines': 0,
          'Sponsorships': 0,
          'Donations': 0,
          'Charity': 0,
          'Overheads': globalExpenses.fold(0.0, (sum, e) => sum + e.amount),
          'Expenditure': 0,
        };

        // Aggregating Ledger Entries (Sponsorships / Donations / Expenditure)
        for (var entry in config.ledgerEntries) {
          if (entry.type == 'Expenditure') {
            breakdown['Expenditure'] = (breakdown['Expenditure'] ?? 0) + entry.amount;
          } else if (entry.isPaid) {
            if (entry.type == 'Sponsorship') {
              breakdown['Sponsorships'] = (breakdown['Sponsorships'] ?? 0) + entry.amount;
            } else if (entry.type == 'Donation') {
              breakdown['Donations'] = (breakdown['Donations'] ?? 0) + entry.amount;
            }
          }
        }

    final Map<String, int> attendanceMap = {};

    double totalMarkup = 0;
    double totalSocietyCosts = 0;
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
      charityPot += event.charityPot;
      breakdown['Charity'] = (breakdown['Charity'] ?? 0) + event.charityPot;

      for (final reg in event.registrations) {
        // Skip withdrawn
        if (reg.statusOverride == 'withdrawn') continue;

        // Attendance tracking (confirmed only)
        if (reg.isConfirmed && reg.attendingGolf) {
          totalAttendance++;
          attendanceMap[reg.memberId] = (attendanceMap[reg.memberId] ?? 0) + 1;
          playingRegistrations++;
          
          final double memberGolf = event.memberCost ?? 0;
          final double guestGolf = event.guestCost ?? 0;
          final double societyGolf = event.societyGreenFee ?? 0;

          // Markup for Member
          totalMarkup += (memberGolf - societyGolf);
          totalSocietyCosts += societyGolf;
          
          // Guests (If applicable)
          if (reg.guestName != null && reg.guestIsConfirmed) {
            playingRegistrations++;
            totalAttendance++;
            totalMarkup += (guestGolf - societyGolf);
            totalSocietyCosts += societyGolf;
          }
          
          if (reg.attendingBreakfast) {
            totalMarkup += ((event.breakfastCost ?? 0) - (event.societyBreakfastCost ?? 0));
            totalSocietyCosts += (event.societyBreakfastCost ?? 0);
          }
          if (reg.attendingLunch) {
            totalMarkup += ((event.lunchCost ?? 0) - (event.societyLunchCost ?? 0));
            totalSocietyCosts += (event.societyLunchCost ?? 0);
          }
          if (reg.attendingDinner) {
            totalMarkup += ((event.dinnerCost ?? 0) - (event.societyDinnerCost ?? 0));
            totalSocietyCosts += (event.societyDinnerCost ?? 0);
          }

          if (reg.guestName != null && reg.guestIsConfirmed) {
            if (reg.guestAttendingBreakfast) {
              totalMarkup += ((event.breakfastCost ?? 0) - (event.societyBreakfastCost ?? 0));
              totalSocietyCosts += (event.societyBreakfastCost ?? 0);
            }
            if (reg.guestAttendingLunch) {
              totalMarkup += ((event.lunchCost ?? 0) - (event.societyLunchCost ?? 0));
              totalSocietyCosts += (event.societyLunchCost ?? 0);
            }
            if (reg.guestAttendingDinner) {
              totalMarkup += ((event.dinnerCost ?? 0) - (event.societyDinnerCost ?? 0));
              totalSocietyCosts += (event.societyDinnerCost ?? 0);
            }
          }
        }

        // Robust Cost Calculation (Ignoring potentially stale reg.cost snapshot)
        double calculateCost(bool isGuest) {
          double total = 0;
          if (event.eventType == EventType.social) {
            total += (event.eventCost ?? 0);
          } else {
            total += isGuest ? (event.guestCost ?? 0) : (event.memberCost ?? 0);
          }
          
          if (isGuest) {
            if (reg.guestAttendingBreakfast) total += (event.breakfastCost ?? 0);
            if (reg.guestAttendingLunch) total += (event.lunchCost ?? 0);
            if (reg.guestAttendingDinner) total += (event.dinnerCost ?? 0);
          } else {
            if (reg.attendingBreakfast) total += (event.breakfastCost ?? 0);
            if (reg.attendingLunch) total += (event.lunchCost ?? 0);
            if (reg.attendingDinner) total += (event.dinnerCost ?? 0);
          }
          return total;
        }

        final double memberRegCost = calculateCost(false);
        final double guestRegCost = reg.guestName != null ? calculateCost(true) : 0;
        final double totalLineCost = memberRegCost + guestRegCost;

        potentialRevenue += totalLineCost;
        
        if (reg.hasPaid) {
          revenue += totalLineCost;
          
          // Breaking down for analytics
          breakdown['Golf'] = (breakdown['Golf'] ?? 0) + (event.memberCost ?? 0);
          if (reg.guestName != null) {
            breakdown['Golf'] = (breakdown['Golf'] ?? 0) + (event.guestCost ?? 0);
          }
          
          double food = 0;
          if (reg.attendingBreakfast) food += (event.breakfastCost ?? 0);
          if (reg.attendingLunch) food += (event.lunchCost ?? 0);
          if (reg.attendingDinner) food += (event.dinnerCost ?? 0);
          
          if (reg.guestName != null) {
            if (reg.guestAttendingBreakfast) food += (event.breakfastCost ?? 0);
            if (reg.guestAttendingLunch) food += (event.lunchCost ?? 0);
            if (reg.guestAttendingDinner) food += (event.dinnerCost ?? 0);
          }
          breakdown['Catering'] = (breakdown['Catering'] ?? 0) + food;
        } else {
          uncollected += totalLineCost;
        }

        // Fines Processing
        if (reg.finePaid) {
          collectedFines += reg.fineAmount;
          breakdown['Fines'] = (breakdown['Fines'] ?? 0) + reg.fineAmount;
        } else {
          unpaidFines += reg.fineAmount;
        }
      }
      
      expenses += event.expenses.fold(0.0, (sum, e) => sum + e.amount);
      
      for (final award in event.awards) {
        if (award.type == 'Cash') {
          cashPrizes += award.value;
          cashAwardsCount++;
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

    return AsyncValue.data(ReportingHubStats(
      totalRevenue: revenue,
      totalExpenses: expenses,
      totalCashPrizes: cashPrizes,
      totalCupsAwarded: cups,
      totalVouchersAwarded: vouchers,
      totalCashAwardsCount: cashAwardsCount,
      totalUniqueWinners: podiumMap.length,
      totalVoucherValue: voucherValue,
      averageAttendance: avgAttendance,
      totalRoundsPlayed: roundsPlayed,
      totalCount: events.length,
      completedCount: completedCount,
      revenueBreakdown: breakdown,
      topMembers: sortedMembers.take(5).toList(),
      attendanceMap: attendanceMap,
      uncollectedRevenue: uncollected,
      totalPotentialRevenue: potentialRevenue,
      greenFeeMarkup: totalMarkup,
      averageEventCostPerMember: avgMemberCost,
      everPresentMemberIds: everPresents,
      churnAlertMemberIds: churnAlerts,
      retentionRate: retention,
      courseDifficultyIndex: courseDifficulty,
      podiumConsistency: sortedPodiums,
      totalSocietyCosts: totalSocietyCosts,
      totalCollectedFines: collectedFines,
      totalUnpaidFines: unpaidFines,
      totalCharity: charityPot,
      startingBalance: config.startingBalance,
      ledgerEntries: config.ledgerEntries,
    ));
  },
  loading: () => const AsyncValue.loading(),
  error: (err, stack) => AsyncValue.error(err, stack),
),
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
