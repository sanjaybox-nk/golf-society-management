import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
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
          title: 'Event Reporting',
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // HEADER SUMMARY
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: Column(
              children: [
                Text(
                  event.title, 
                  textAlign: TextAlign.center,
                  style: AppTypography.displayHeading.copyWith(
                    color: AppColors.pureWhite,
                    fontSize: AppTypography.sizeDisplaySubPage,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${event.courseName} • ${DateFormat('EEE, d MMM yyyy').format(event.date)}', 
                  style: AppTypography.bodySmall.copyWith(color: AppColors.dark200),
                ),
                const SizedBox(height: AppSpacing.x2l),
                const Divider(color: AppColors.dark500),
                const SizedBox(height: AppSpacing.x2l),
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
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernMetricStat(
                        value: '${stats.reserveGolfers}',
                        label: 'Reserved',
                        color: AppColors.amber500,
                        isCompact: true,
                        isSolid: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.x2l),

          // PARTICIPATION
          const BoxyArtSectionTitle(title: 'PARTICIPATION BREAKDOWN'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.x2l),

          // SERVICES
          const BoxyArtSectionTitle(title: 'SERVICES & CATERING'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Column(
              children: [
                _buildReportRow(context, Icons.electric_rickshaw_rounded, 'Buggy Requests', '$buggyRequests'),
                _buildReportRow(context, Icons.breakfast_dining_rounded, 'Breakfasts', '$breakfasts'),
                _buildReportRow(context, Icons.lunch_dining_rounded, 'Lunches', '$lunches'),
                _buildReportRow(context, Icons.restaurant_menu_rounded, 'Dinners', '$dinners'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),

          // FINANCIALS
          const BoxyArtSectionTitle(title: 'FINANCIAL SUMMARY'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _buildReportRow(context, Icons.check_circle_rounded, 'Fees Collected (Paid)', '$currency${confirmedPaid.toStringAsFixed(0)}', color: AppColors.lime500),
                _buildReportRow(context, Icons.pending_rounded, 'Fees Outstanding (Due)', '$currency${confirmedDue.toStringAsFixed(0)}', color: AppColors.amber500),
                if (unconfirmedPaid > 0)
                  _buildReportRow(context, Icons.undo_rounded, 'Possible Reimbursements', '$currency${unconfirmedPaid.toStringAsFixed(0)}', color: AppColors.coral500),
                
                const Divider(height: AppSpacing.x3l, color: AppColors.dark400),
                _buildMinorRow('Golf Total', '$currency${golfTotal.toStringAsFixed(0)}'),
                _buildMinorRow('Buggies Total', '$currency${buggyTotal.toStringAsFixed(0)}'),
                _buildMinorRow('Catering Total', '$currency${foodTotal.toStringAsFixed(0)}'),
                const Divider(height: AppSpacing.x3l, color: AppColors.dark400),
                
                _buildReportRow(context, Icons.account_balance_wallet_rounded, 'Potential Event Income', '$currency${totalPotentialRevenue.toStringAsFixed(0)}', isBold: true),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Calculated based on confirmed participants.', 
                  style: AppTypography.caption.copyWith(color: AppColors.dark300, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),

          // LEDGER SECTION (Merged from Financials)
          const BoxyArtSectionTitle(title: 'EVENT LEDGER'),
          _buildBalanceOverview(context, event, confirmedPaid),
          const SizedBox(height: AppSpacing.x2l),
          const BoxyArtSectionTitle(title: 'EXPENSES'),
          const SizedBox(height: AppSpacing.md),
          ...event.expenses.map((e) => _buildExpenseRow(context, ref, event, e)),
          _buildAddExpenseButton(context, ref, event),
          const SizedBox(height: AppSpacing.x3l),
          const BoxyArtSectionTitle(title: 'PRIZES & AWARDS'),
          const SizedBox(height: AppSpacing.md),
          ...event.awards.map((a) => _buildAwardRow(context, ref, event, a)),
          _buildAddAwardButton(context, ref, event),

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

  Widget _buildBalanceOverview(BuildContext context, GolfEvent event, double registrationRevenue) {
    final totalExpenses = event.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final cashPrizes = event.awards.where((a) => a.type == 'Cash').fold(0.0, (sum, a) => sum + a.value);
    
    final netProfit = registrationRevenue - totalExpenses - cashPrizes;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NET POSITION', style: TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBlack, color: AppColors.textSecondary, letterSpacing: 1.2)),
                  Text(
                    '${netProfit >= 0 ? '+' : ''}£${netProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppTypography.sizeDisplayMedium, 
                      fontWeight: AppTypography.weightBlack, 
                      color: netProfit >= 0 ? AppColors.lime500 : Colors.redAccent,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: (netProfit >= 0 ? AppColors.lime500 : Colors.redAccent).withValues(alpha: AppColors.opacityLow),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  netProfit >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: netProfit >= 0 ? AppColors.lime500 : Colors.redAccent,
                  size: AppShapes.iconLg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2l),
          const Divider(color: AppColors.dark400),
          const SizedBox(height: AppSpacing.lg),
          _buildMetricRow('Registration Revenue', '£${registrationRevenue.toStringAsFixed(2)}', Icons.payments_outlined),
          const SizedBox(height: AppSpacing.md),
          _buildMetricRow('Operational Costs', '-£${totalExpenses.toStringAsFixed(2)}', Icons.receipt_long_outlined),
          const SizedBox(height: AppSpacing.md),
          _buildMetricRow('Cash Payouts', '-£${cashPrizes.toStringAsFixed(2)}', Icons.emoji_events_outlined),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: AppShapes.iconSm, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: const TextStyle(fontSize: AppTypography.sizeLabelStrong, color: AppColors.textSecondary, fontWeight: AppTypography.weightSemibold)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: AppTypography.sizeBodySmall, fontWeight: AppTypography.weightBlack, color: AppColors.pureWhite)),
      ],
    );
  }

  Widget _buildExpenseRow(BuildContext context, WidgetRef ref, GolfEvent event, EventExpense expense) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _showExpenseDialog(context, ref, event, expense: expense),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.dark700.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.md,
                ),
                child: Icon(_getCategoryIcon(expense.category), size: AppShapes.iconSm, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.label, style: const TextStyle(fontWeight: AppTypography.weightExtraBold, fontSize: AppTypography.sizeButton, color: AppColors.pureWhite)),
                    Text(expense.category.toUpperCase(), style: const TextStyle(fontSize: AppTypography.sizeCaption, color: AppColors.textSecondary, fontWeight: AppTypography.weightBlack, letterSpacing: 0.5)),
                  ],
                ),
              ),
              Text('£${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody, color: AppColors.pureWhite)),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: AppShapes.iconMd, color: Colors.redAccent),
                onPressed: () => _deleteExpense(ref, event, expense.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAwardRow(BuildContext context, WidgetRef ref, GolfEvent event, EventAward award) {
     return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _showAwardDialog(context, ref, event, award: award),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
               Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.md,
                ),
                child: Icon(award.type == 'Cup' ? Icons.emoji_events_rounded : Icons.account_balance_wallet_rounded, size: AppShapes.iconSm, color: AppColors.lime500),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(award.label, style: const TextStyle(fontWeight: AppTypography.weightExtraBold, fontSize: AppTypography.sizeButton, color: AppColors.pureWhite)),
                    Text(award.winnerName ?? 'UNASSIGNED', style: TextStyle(fontSize: AppTypography.sizeCaption, color: award.winnerName != null ? AppColors.lime500 : AppColors.amber500, fontWeight: AppTypography.weightBlack, letterSpacing: 0.5)),
                  ],
                ),
              ),
              if (award.value > 0)
                Text('£${award.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody, color: AppColors.pureWhite)),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: AppShapes.iconMd, color: Colors.redAccent),
                onPressed: () => _deleteAward(ref, event, award.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddExpenseButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(
      title: 'ADD EXPENSE',
      onTap: () => _showExpenseDialog(context, ref, event),
      isGhost: true,
      fullWidth: true,
    );
  }

  Widget _buildAddAwardButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(
      title: 'ADD PRIZE SLOT',
      onTap: () => _showAwardDialog(context, ref, event),
      isGhost: true,
      fullWidth: true,
    );
  }

  void _showExpenseDialog(BuildContext context, WidgetRef ref, GolfEvent event, {EventExpense? expense}) {
    final labelController = TextEditingController(text: expense?.label);
    final amountController = TextEditingController(text: expense?.amount.toString());
    String category = expense?.category ?? 'Misc';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BoxyArtDialog(
          title: expense == null ? 'Add Expense' : 'Edit Expense',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxyArtFormField(label: 'Description', controller: labelController),
              const SizedBox(height: AppSpacing.lg),
              BoxyArtFormField(label: 'Amount (£)', controller: amountController, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.lg),
              _buildCategorySelector(category, (val) => setDialogState(() => category = val)),
            ],
          ),
          onConfirm: () async {
            final amount = double.tryParse(amountController.text) ?? 0.0;
            if (labelController.text.isNotEmpty && amount > 0) {
              final newExpense = EventExpense(
                id: expense?.id ?? 'exp_${DateTime.now().millisecondsSinceEpoch}',
                label: labelController.text,
                amount: amount,
                category: category,
              );
              
              final List<EventExpense> updatedExpenses = List.from(event.expenses);
              if (expense != null) {
                final index = updatedExpenses.indexWhere((e) => e.id == expense.id);
                updatedExpenses[index] = newExpense;
              } else {
                updatedExpenses.add(newExpense);
              }

              await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(expenses: updatedExpenses));
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector(String current, ValueChanged<String> onChanged) {
    final categories = ['Venue', 'Food', 'Prize', 'Misc'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: categories.map((cat) => ChoiceChip(
            label: Text(cat),
            selected: current == cat,
            onSelected: (selected) => selected ? onChanged(cat) : null,
          )).toList(),
        ),
      ],
    );
  }

  void _showAwardDialog(BuildContext context, WidgetRef ref, GolfEvent event, {EventAward? award}) {
    final labelController = TextEditingController(text: award?.label);
    final valueController = TextEditingController(text: award?.value.toString());
    String type = award?.type ?? 'Cup';
    String? selectedWinnerId = award?.winnerId;
    String? selectedWinnerName = award?.winnerName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BoxyArtDialog(
          title: award == null ? 'Add Prize Slot' : 'Edit Prize Slot',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxyArtFormField(label: 'Prize Label (e.g. Winner)', controller: labelController),
              const SizedBox(height: AppSpacing.lg),
              BoxyArtFormField(label: 'Cash Value (£)', controller: valueController, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.lg),
              _buildTypeSelector(type, (val) => setDialogState(() => type = val)),
              const SizedBox(height: AppSpacing.lg),
              _buildWinnerPicker(context, event, selectedWinnerId, (id, name) {
                setDialogState(() {
                  selectedWinnerId = id;
                  selectedWinnerName = name;
                });
              }),
            ],
          ),
          onConfirm: () async {
            if (labelController.text.isNotEmpty) {
              final newAward = EventAward(
                id: award?.id ?? 'award_${DateTime.now().millisecondsSinceEpoch}',
                label: labelController.text,
                type: type,
                value: double.tryParse(valueController.text) ?? 0.0,
                winnerId: selectedWinnerId,
                winnerName: selectedWinnerName,
              );

              final List<EventAward> updatedAwards = List.from(event.awards);
              if (award != null) {
                final index = updatedAwards.indexWhere((a) => a.id == award.id);
                updatedAwards[index] = newAward;
              } else {
                updatedAwards.add(newAward);
              }

              await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(awards: updatedAwards));
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String current, ValueChanged<String> onChanged) {
    final types = ['Cup', 'Cash', 'Voucher'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Award Type', style: TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: types.map((t) => ChoiceChip(
            label: Text(t),
            selected: current == t,
            onSelected: (selected) => selected ? onChanged(t) : null,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildWinnerPicker(BuildContext context, GolfEvent event, String? selectedId, Function(String?, String?) onChanged) {
    // Basic winner picker using registrations
    final eligible = event.registrations.where((r) => r.attendingGolf).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Winner (Optional)', style: TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: AppShapes.md,
            border: Border.all(color: AppColors.dark300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedId,
              hint: const Text('Assign Winner'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None / TBD')),
                ...eligible.map((r) => DropdownMenuItem(
                  value: r.memberId,
                  child: Text(r.memberName),
                )),
              ],
              onChanged: (id) {
                final name = eligible.firstWhereOrNull((r) => r.memberId == id)?.memberName;
                onChanged(id, name);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteExpense(WidgetRef ref, GolfEvent event, String id) async {
    final updatedExpenses = event.expenses.where((e) => e.id != id).toList();
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(expenses: updatedExpenses));
  }

  Future<void> _deleteAward(WidgetRef ref, GolfEvent event, String id) async {
    final updatedAwards = event.awards.where((a) => a.id != id).toList();
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(awards: updatedAwards));
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Venue': return Icons.park_rounded;
      case 'Food': return Icons.restaurant_rounded;
      case 'Prize': return Icons.emoji_events_outlined;
      default: return Icons.receipt_long_outlined;
    }
  }

  Widget _buildReportRow(BuildContext context, IconData icon, String label, String value, {Color? color, bool isBold = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = color ?? AppColors.lime500;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: AppSpacing.x4l,
            height: AppSpacing.x4l,
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.dark700.withValues(alpha: AppColors.opacityHigh) 
                  : iconColor.withValues(alpha: AppColors.opacityLow),
              borderRadius: AppShapes.md,
              border: Border.all(
                color: isDark 
                    ? AppColors.pureWhite.withValues(alpha: 0.12) 
                    : iconColor.withValues(alpha: AppColors.opacityLow),
                width: AppShapes.borderThin,
              ),
            ),
            child: Icon(
              icon, 
              size: AppShapes.iconMd, 
              color: isDark ? (color ?? AppColors.pureWhite) : iconColor,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              label, 
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.dark100 : AppColors.dark950, 
                fontWeight: isBold ? AppTypography.weightBlack : AppTypography.weightSemibold,
              ),
            ),
          ),
          Text(
            value, 
            style: AppTypography.displayHeading.copyWith(
              fontSize: AppTypography.sizeBody, 
              color: color ?? (isDark ? AppColors.pureWhite : AppColors.dark950),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      child: Row(
        children: [
          Text(
            label, 
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.dark100, 
              fontWeight: AppTypography.weightSemibold,
            ),
          ),
          const Spacer(),
          Text(
            value, 
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.pureWhite, 
              fontWeight: AppTypography.weightExtraBold,
            ),
          ),
        ],
      ),
    );
  }
}
