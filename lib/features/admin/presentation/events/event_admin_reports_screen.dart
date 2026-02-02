import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../../core/theme/theme_controller.dart';
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
      data: (event) => _buildReport(context, ref, event, currency),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildReport(BuildContext context, WidgetRef ref, GolfEvent event, String currency) {
    final maxParticipants = event.maxParticipants ?? 0;
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
    
    // Get items using RegistrationLogic
    final sortedItems = RegistrationLogic.getSortedItems(event);
    final dinnerOnlyItems = RegistrationLogic.getDinnerOnlyItems(event);
    final withdrawnItems = RegistrationLogic.getWithdrawnItems(event);

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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: BoxyArtAppBar(
        title: 'Event Report',
        subtitle: event.title,
        centerTitle: true,
        isLarge: true,
        showBack: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/admin/events'),
            child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HEADER SUMMARY
            BoxyArtFloatingCard(
              child: Column(
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${event.courseName} • ${DateFormat('EEE, d MMM yyyy').format(event.date)}', 
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Confirmed', '${stats.confirmedGolfers}', Colors.green),
                        _buildStatColumn('Reserved', '${stats.reserveGolfers}', Colors.orange),
                        _buildStatColumn('Capacity', '$maxParticipants', Colors.blue),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PARTICIPATION
            const BoxyArtSectionTitle(title: 'PARTICIPATION BREAKDOWN'),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                    _buildReportRow(Icons.person, 'Members Playing', '${stats.confirmedMembers}'),
                    _buildReportRow(Icons.person_add, 'Guests Playing', '${stats.confirmedGuests}'),
                    _buildReportRow(Icons.restaurant, 'Dinner Only', '${stats.dinnerOnlyCount}'),
                    _buildReportRow(Icons.history, 'Withdrawn (Total)', '${stats.withdrawnCount}', color: Colors.grey),
                    if (stats.withdrawnConfirmedCount > 0)
                      _buildReportRow(Icons.warning_amber_rounded, 'Confirmed but Withdrawn', '${stats.withdrawnConfirmedCount}', color: Colors.red[400]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SERVICES
            const BoxyArtSectionTitle(title: 'SERVICES & CATERING'),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                  _buildReportRow(Icons.electric_rickshaw, 'Buggy Requests', '$buggyRequests'),
                  _buildReportRow(Icons.breakfast_dining, 'Breakfasts', '$breakfasts'),
                  _buildReportRow(Icons.lunch_dining, 'Lunches', '$lunches'),
                  _buildReportRow(Icons.restaurant_menu, 'Dinners', '$dinners'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FINANCIALS
            const BoxyArtSectionTitle(title: 'FINANCIAL SUMMARY'),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                  _buildReportRow(Icons.check_circle, 'Fees Collected (Paid)', '$currency${confirmedPaid.toStringAsFixed(0)}', color: Colors.green),
                  _buildReportRow(Icons.pending, 'Fees Outstanding (Due)', '$currency${confirmedDue.toStringAsFixed(0)}', color: Colors.orange),
                  if (unconfirmedPaid > 0)
                    _buildReportRow(Icons.undo, 'Possible Reimbursements', '$currency${unconfirmedPaid.toStringAsFixed(0)}', color: Colors.red[400]),
                  
                  const Divider(height: 24),
                  _buildMinorRow('Golf Total', '$currency${golfTotal.toStringAsFixed(0)}'),
                  _buildMinorRow('Buggies Total', '$currency${buggyTotal.toStringAsFixed(0)}'),
                  _buildMinorRow('Catering Total', '$currency${foodTotal.toStringAsFixed(0)}'),
                  const Divider(height: 24),
                  
                  _buildReportRow(Icons.account_balance_wallet, 'Potential Event Income', '$currency${totalPotentialRevenue.toStringAsFixed(0)}', isBold: true),
                  Text('Calculated based on confirmed participants.', 
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildReportRow(IconData icon, String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey[700]!).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: color ?? Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[850], fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text(value, style: TextStyle(
            fontSize: 15, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
            color: color ?? Colors.black87,
          )),
        ],
      ),
    );
  }

  Widget _buildMinorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
