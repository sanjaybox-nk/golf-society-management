import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../events/domain/registration_logic.dart';
import 'package:intl/intl.dart';

class EventAdminReportsScreen extends ConsumerWidget {
  final String eventId;

  const EventAdminReportsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final config = ref.watch(themeControllerProvider);
    final currency = config.currencySymbol;

    return eventAsync.when(
      data: (event) {
        return HeadlessScaffold(
          title: 'Manage Reports',
          subtitle: event.title,
          useScaffold: false,
          showBack: true,
          onBack: () => context.go('/admin/events'),
          slivers: [
            SliverToBoxAdapter(
              child: _buildReport(context, ref, event, currency),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading...', useScaffold: false, slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (err, _) => HeadlessScaffold(title: 'Error', useScaffold: false, slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))]),
    );
  }

  Widget _buildReport(BuildContext context, WidgetRef ref, GolfEvent event, String currency) {
    final maxParticipants = event.maxParticipants ?? 0;
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
    
    // Get items using RegistrationLogic
    final sortedItems = RegistrationLogic.getSortedItems(event);
    final dinnerOnlyItems = RegistrationLogic.getDinnerOnlyItems(event);

    // Standardized Stats
    final stats = RegistrationLogic.getRegistrationStats(event);
    
    // Use same confirmed items list logic as RegistrationLogic (via calculateStatus)
    int rollingCount = 0;
    final confirmedItems = sortedItems.where((item) {
      final status = RegistrationLogic.calculateStatus(
        isGuest: item.isGuest,
        isConfirmed: item.isConfirmed,
        hasPaid: item.hasPaid,
        capacity: maxParticipants,
        confirmedCount: rollingCount,
        isEventClosed: isClosed,
        statusOverride: item.registration.statusOverride,
      );
      if (status == RegistrationStatus.confirmed) {
        rollingCount++;
        return true;
      }
      return false;
    }).toList();

    // 3. Financial Totals
    double confirmedPaid = 0;
    double confirmedDue = 0;
    double unconfirmedPaid = 0; // REIMBURSEMENTS
    
    // 4. Breakdown (Detailed totals for confirmed only)
    double golfTotal = 0;
    double buggyTotal = 0;
    double foodTotal = 0;

    // We need to look at both golf participants AND dinner-only participants for financials
    // Step A: Handle Golf Participants (sortedItems contains both members and guests)
    for (final item in sortedItems) {
      final isConfirmed = confirmedItems.contains(item);
      final cost = item.isGuest ? _calculateGuestCost(event, item.registration) : _calculateMemberGolfCost(event, item.registration);
      
      if (isConfirmed) {
        if (item.hasPaid) {
          confirmedPaid += cost;
        } else {
          confirmedDue += cost;
        }
        
        // Detailed Breakdown
        golfTotal += (item.isGuest ? (event.guestCost ?? 0.0) : (event.memberCost ?? 0.0));
        if (item.needsBuggy) buggyTotal += (event.buggyCost ?? 0.0);
        
        // Food portion
        if (item.isGuest) {
          foodTotal += (item.registration.guestAttendingBreakfast ? (event.breakfastCost ?? 0.0) : 0);
          foodTotal += (item.registration.guestAttendingLunch ? (event.lunchCost ?? 0.0) : 0);
          foodTotal += (item.registration.guestAttendingDinner ? (event.dinnerCost ?? 0.0) : 0);
        } else {
          foodTotal += (item.registration.attendingBreakfast ? (event.breakfastCost ?? 0.0) : 0);
          foodTotal += (item.registration.attendingLunch ? (event.lunchCost ?? 0.0) : 0);
          foodTotal += (item.registration.attendingDinner ? (event.dinnerCost ?? 0.0) : 0);
        }
      } else if (item.hasPaid) {
        unconfirmedPaid += cost;
      }
    }

    // Step B: Handle Dinner-Only Participants (these are NOT in sortedItems as it's golf-focused)
    for (final item in dinnerOnlyItems) {
      // Dinner only are always "confirmed" for dinner if they are in this list
      final cost = _calculateMemberDinnerOnlyCost(event, item.registration);
      if (item.hasPaid) {
        confirmedPaid += cost;
      } else {
        confirmedDue += cost;
      }
      foodTotal += (item.registration.attendingDinner ? (event.dinnerCost ?? 0.0) : 0);
    }

    final totalPotentialRevenue = confirmedPaid + confirmedDue;

    // Service Counts (Standardized from Stats)
    final buggyRequests = stats.buggyCount;
    final breakfasts = stats.breakfastCount;
    final lunches = stats.lunchCount;
    final dinners = stats.dinnerCount;

    return Container(
      color: AppColors.dark800,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // HEADER SUMMARY
          BoxyArtCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  event.title, 
                  textAlign: TextAlign.center,
                  style: AppTypography.displayHeading.copyWith(
                    color: AppColors.pureWhite,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${event.courseName} • ${DateFormat('EEE, d MMM yyyy').format(event.date)}', 
                  style: AppTypography.bodySmall.copyWith(color: AppColors.dark200),
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.dark500),
                const SizedBox(height: 24),
                ModernMetricBar(
                  children: [
                    Expanded(
                      child: ModernMetricStat(
                        value: '${stats.confirmedGolfers}',
                        label: 'Confirmed',
                        color: AppColors.lime600,
                        isCompact: true,
                        isSolid: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernMetricStat(
                        value: '${stats.reserveGolfers}',
                        label: 'Reserved',
                        color: AppColors.amber500,
                        isCompact: true,
                        isSolid: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernMetricStat(
                        value: '$maxParticipants',
                        label: 'Capacity',
                        color: AppColors.dark300,
                        isCompact: true,
                        isSolid: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // PARTICIPATION
          const BoxyArtSectionTitle(title: 'PARTICIPATION BREAKDOWN'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                _buildReportRow(context, Icons.groups_rounded, 'Members Playing', '${stats.confirmedMembers}'),
                _buildReportRow(context, Icons.person_add_rounded, 'Guests Playing', '${stats.confirmedGuests}'),
                _buildReportRow(context, Icons.restaurant_rounded, 'Dinner Only', '${stats.dinnerOnlyCount}'),
                _buildReportRow(context, Icons.history_rounded, 'Withdrawn (Total)', '${stats.withdrawnCount}', color: AppColors.dark300),
                if (stats.withdrawnConfirmedCount > 0)
                  _buildReportRow(context, Icons.warning_amber_rounded, 'Confirmed but Withdrawn', '${stats.withdrawnConfirmedCount}', color: AppColors.coral500),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SERVICES
          const BoxyArtSectionTitle(title: 'SERVICES & CATERING'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                _buildReportRow(context, Icons.electric_rickshaw_rounded, 'Buggy Requests', '$buggyRequests'),
                _buildReportRow(context, Icons.breakfast_dining_rounded, 'Breakfasts', '$breakfasts'),
                _buildReportRow(context, Icons.lunch_dining_rounded, 'Lunches', '$lunches'),
                _buildReportRow(context, Icons.restaurant_menu_rounded, 'Dinners', '$dinners'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FINANCIALS
          const BoxyArtSectionTitle(title: 'FINANCIAL SUMMARY'),
          BoxyArtCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildReportRow(context, Icons.check_circle_rounded, 'Fees Collected (Paid)', '$currency${confirmedPaid.toStringAsFixed(0)}', color: AppColors.lime500),
                _buildReportRow(context, Icons.pending_rounded, 'Fees Outstanding (Due)', '$currency${confirmedDue.toStringAsFixed(0)}', color: AppColors.amber500),
                if (unconfirmedPaid > 0)
                  _buildReportRow(context, Icons.undo_rounded, 'Possible Reimbursements', '$currency${unconfirmedPaid.toStringAsFixed(0)}', color: AppColors.coral500),
                
                const Divider(height: 32, color: AppColors.dark400),
                _buildMinorRow('Golf Total', '$currency${golfTotal.toStringAsFixed(0)}'),
                _buildMinorRow('Buggies Total', '$currency${buggyTotal.toStringAsFixed(0)}'),
                _buildMinorRow('Catering Total', '$currency${foodTotal.toStringAsFixed(0)}'),
                const Divider(height: 32, color: AppColors.dark400),
                
                _buildReportRow(context, Icons.account_balance_wallet_rounded, 'Potential Event Income', '$currency${totalPotentialRevenue.toStringAsFixed(0)}', isBold: true),
                const SizedBox(height: 8),
                Text(
                  'Calculated based on confirmed participants.', 
                  style: AppTypography.caption.copyWith(color: AppColors.dark300, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120), // Extra space for FAB/BottomBar
        ],
      ),
    );
  }

  // Cost calculation helpers (matching RegistrationScreen logic)
  double _calculateMemberGolfCost(GolfEvent event, dynamic registration) {
    double total = event.memberCost ?? 0.0;
    if (registration.attendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (registration.attendingLunch) total += event.lunchCost ?? 0.0;
    if (registration.attendingDinner) total += event.dinnerCost ?? 0.0;
    if (registration.needsBuggy) total += event.buggyCost ?? 0.0;
    return total;
  }

  double _calculateGuestCost(GolfEvent event, dynamic registration) {
    double total = event.guestCost ?? 0.0;
    if (registration.guestAttendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (registration.guestAttendingLunch) total += event.lunchCost ?? 0.0;
    if (registration.guestAttendingDinner) total += event.dinnerCost ?? 0.0;
    if (registration.guestNeedsBuggy) total += event.buggyCost ?? 0.0;
    return total;
  }

  double _calculateMemberDinnerOnlyCost(GolfEvent event, dynamic registration) {
    double total = 0;
    if (registration.attendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (registration.attendingLunch) total += event.lunchCost ?? 0.0;
    if (registration.attendingDinner) total += event.dinnerCost ?? 0.0;
    return total;
  }

  Widget _buildReportRow(BuildContext context, IconData icon, String label, String value, {Color? color, bool isBold = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = color ?? AppColors.lime500;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.dark700.withValues(alpha: 0.8) 
                  : iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.12) 
                    : iconColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: isDark ? (color ?? AppColors.pureWhite) : iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label, 
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.dark100 : AppColors.dark950, 
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value, 
            style: AppTypography.displayHeading.copyWith(
              fontSize: 16, 
              color: color ?? (isDark ? AppColors.pureWhite : AppColors.dark950),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Text(
            label, 
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.dark100, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value, 
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.pureWhite, 
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
