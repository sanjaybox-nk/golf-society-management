import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../events/presentation/widgets/registration_stats_card.dart';
import '../../../events/presentation/tabs/event_stats_tab.dart';

class AdminReportsTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int value) => state = value;
}

final adminReportsTabProvider = NotifierProvider.autoDispose<AdminReportsTabNotifier, int>(AdminReportsTabNotifier.new);

class EventAdminReportsScreen extends ConsumerWidget {
  final String eventId;
  const EventAdminReportsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final currency = config.currencySymbol;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final eventAsync = ref.watch(eventProvider(eventId));
    final selectedTab = ref.watch(adminReportsTabProvider);

    return eventAsync.when(
      data: (event) {
        return HeadlessScaffold(
          title: 'Event Analysis',
          topPill: BoxyArtPill.committee(label: 'ADMIN'),
          subtitle: event.title,
          showBack: true,
          onBack: () => context.go('/admin/events'),
          slivers: [
            SliverToBoxAdapter(
              child: BoxyArtTabBar<int>(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                selectedValue: selectedTab,
                onTabSelected: (val) => ref.read(adminReportsTabProvider.notifier).set(val),
                tabs: const [
                  ModernFilterTab(label: 'Financials', value: 0),
                  ModernFilterTab(label: 'Event Stats', value: 1),
                ],
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel)),
            SliverToBoxAdapter(
              child: selectedTab == 0
                  ? _buildReport(context, ref, event, currency)
                  : _buildStatsTab(ref, event),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading...', slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (err, _) => HeadlessScaffold(title: 'Error', slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))]),
    );
  }

  Widget _buildStatsTab(WidgetRef ref, GolfEvent event) {
    return Column(
      children: [
        EventStatsTab(
          eventId: event.id,
          isAdmin: true,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildReport(BuildContext context, WidgetRef ref, GolfEvent event, String currency) {
    final maxParticipants = event.maxParticipants ?? 0;
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
    
    // Get items using RegistrationLogic
    final sortedItems = RegistrationLogic.getSortedItems(event);
    final dinnerOnlyItems = RegistrationLogic.getDinnerOnlyItems(event);
    
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

    // [AUTOMATION] Calculate Club Costs (Society Owed)
    double totalClubGolf = 0;
    double totalClubFood = 0;
    
    for (final item in confirmedItems) {
      totalClubGolf += (event.societyGreenFee ?? 0.0);
      if (item.isGuest) {
        totalClubFood += (item.registration.guestAttendingBreakfast ? (event.societyBreakfastCost ?? 0.0) : 0);
        totalClubFood += (item.registration.guestAttendingLunch ? (event.societyLunchCost ?? 0.0) : 0);
        totalClubFood += (item.registration.guestAttendingDinner ? (event.societyDinnerCost ?? 0.0) : 0);
      } else {
        totalClubFood += (item.registration.attendingBreakfast ? (event.societyBreakfastCost ?? 0.0) : 0);
        totalClubFood += (item.registration.attendingLunch ? (event.societyLunchCost ?? 0.0) : 0);
        totalClubFood += (item.registration.attendingDinner ? (event.societyDinnerCost ?? 0.0) : 0);
      }
    }
    // Dinner only items society food cost
    for (final item in dinnerOnlyItems) {
      totalClubFood += (item.registration.attendingDinner ? (event.societyDinnerCost ?? 0.0) : 0);
    }
    final totalClubBill = totalClubGolf + totalClubFood;

    final totalPotentialRevenue = confirmedPaid + confirmedDue;

    return Column(
      children: [
          // HEADER SUMMARY
          RegistrationStatsCard(event: event, isCompact: false),
          const SizedBox(height: AppSpacing.cardToLabel),

          // FINANCIALS
          const BoxyArtSectionTitle(
            title: 'Financial summary',
            isPeeking: true,
          ),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _buildReportRow(context, Icons.check_circle_rounded, 'Fees collected (Paid)', '$currency${confirmedPaid.toStringAsFixed(0)}'),
                _buildReportRow(context, Icons.pending_rounded, 'Fees outstanding (Due)', '$currency${confirmedDue.toStringAsFixed(0)}'),
                if (unconfirmedPaid > 0)
                  _buildReportRow(context, Icons.undo_rounded, 'Possible reimbursements', '$currency${unconfirmedPaid.toStringAsFixed(0)}'),
                
                const Divider(height: AppSpacing.x3l, color: AppColors.dark400),
                _buildMinorRow('Golf Total', '$currency${golfTotal.toStringAsFixed(0)}'),
                _buildMinorRow('Catering Total', '$currency${foodTotal.toStringAsFixed(0)}'),
                const Divider(height: AppSpacing.x3l, color: AppColors.dark400),
                
                _buildReportRow(context, Icons.account_balance_wallet_rounded, 'Potential event income', '$currency${totalPotentialRevenue.toStringAsFixed(0)}', isBold: true),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Calculated based on confirmed participants.', 
                    style: AppTypography.subtext.copyWith(color: AppColors.dark600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardToLabel),

          // LEDGER SECTION (Merged from Financials)
          const BoxyArtSectionTitle(
            title: 'Event ledger',
            isPeeking: true,
          ),
          _buildBalanceOverview(context, event, confirmedPaid, totalClubBill),
          const SizedBox(height: AppSpacing.cardToLabel),
          const BoxyArtSectionTitle(
            title: 'Misc expenses',
            isPeeking: true,
          ),
          const SizedBox(height: AppSpacing.md),
          ...event.expenses.where((e) {
            // Filter out manual entries that are now automated
            final label = e.label.toLowerCase();
            return !label.contains('green fee') && !label.contains('catering');
          }).map((e) => _buildExpenseRow(context, ref, event, e)),
          _buildAddExpenseButton(context, ref, event),
          const SizedBox(height: AppSpacing.cardToLabel),
          const BoxyArtSectionTitle(
            title: 'Prizes & awards',
            isPeeking: true,
          ),
          const SizedBox(height: AppSpacing.md),
          ...event.awards.map((a) => _buildAwardRow(context, ref, event, a)),
          _buildAddAwardButton(context, ref, event),

          const SizedBox(height: 120), // Extra space for FAB/BottomBar
        ],
      );
    }

  // Cost calculation helpers (matching RegistrationScreen logic)
  double _calculateMemberGolfCost(GolfEvent event, dynamic registration) {
    if (event.eventType == EventType.social) return event.eventCost ?? 0;
    double total = event.memberCost ?? 0.0;
    if (registration.attendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (registration.attendingLunch) total += event.lunchCost ?? 0.0;
    if (registration.attendingDinner) total += event.dinnerCost ?? 0.0;
    // Buggy cost is indicative and paid to pro shop directly, so we exclude it from society ledger
    return total;
  }

  double _calculateGuestCost(GolfEvent event, dynamic registration) {
    if (event.eventType == EventType.social) return event.eventCost ?? 0;
    double total = event.guestCost ?? 0.0;
    if (registration.guestAttendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (registration.guestAttendingLunch) total += event.lunchCost ?? 0.0;
    if (registration.guestAttendingDinner) total += event.dinnerCost ?? 0.0;
    // Buggy cost is indicative and paid to pro shop directly, so we exclude it from society ledger
    return total;
  }

  double _calculateMemberDinnerOnlyCost(GolfEvent event, dynamic registration) {
    double total = 0;
    if (registration.attendingBreakfast) total += event.breakfastCost ?? 0.0;
    if (registration.attendingLunch) total += event.lunchCost ?? 0.0;
    if (registration.attendingDinner) total += event.dinnerCost ?? 0.0;
    return total;
  }

  Widget _buildBalanceOverview(BuildContext context, GolfEvent event, double registrationRevenue, double clubBill) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Total Expenses includes manual misc expenses + automated club bill
    final miscExpenses = event.expenses.where((e) {
       final label = e.label.toLowerCase();
       return !label.contains('green fee') && !label.contains('catering');
    }).fold(0.0, (sum, e) => sum + e.amount);

    final totalExpenses = miscExpenses + clubBill;
    final cashPrizes = event.awards.where((a) => a.type == 'Cash').fold(0.0, (sum, a) => sum + a.value);
    
    final netProfit = registrationRevenue - totalExpenses - cashPrizes;
    final isPositive = netProfit >= 0;
    final statusColor = isPositive ? AppColors.lime500 : AppColors.coral500;

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
                  Text('Net position', 
                    style: AppTypography.micro.copyWith(
                      color: AppColors.dark600, 
                      letterSpacing: 1.0,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${isPositive ? '+' : ''}£${netProfit.toStringAsFixed(2)}',
                    style: AppTypography.displayPage.copyWith(
                      color: isDark ? AppColors.pureWhite : AppColors.dark950,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: AppShapes.lg,
                ),
                child: Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: isDark ? statusColor : AppColors.dark950,
                  size: AppShapes.iconLg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2l),
          const Divider(height: 1, color: AppColors.dark400),
          const SizedBox(height: AppSpacing.lg),
          const SizedBox(height: AppSpacing.lg),
          _buildReportRow(context, Icons.payments_outlined, 'Member revenue', '£${registrationRevenue.toStringAsFixed(2)}'),
          _buildReportRow(context, Icons.account_balance_rounded, 'Club bill (Auto)', '-£${clubBill.toStringAsFixed(2)}'),
          _buildReportRow(context, Icons.receipt_long_outlined, 'Misc expenses', '-£${miscExpenses.toStringAsFixed(2)}'),
          _buildReportRow(context, Icons.emoji_events_outlined, 'Cash payouts', '-£${cashPrizes.toStringAsFixed(2)}'),
        ],
      ),
    );
  }



  Widget _buildExpenseRow(BuildContext context, WidgetRef ref, GolfEvent event, EventExpense expense) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _showExpenseDialog(context, ref, event, expense: expense),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.dark700.withValues(alpha: AppColors.opacityHigh) 
                      : AppColors.dark150.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.lg,
                ),
                child: Icon(
                  _getCategoryIcon(expense.category), 
                  size: AppShapes.iconMd, 
                  color: isDark ? AppColors.pureWhite : AppColors.dark950,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toSentenceCase(expense.label), 
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                        fontWeight: AppTypography.weightBold,
                        fontSize: AppTypography.sizeBody,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      toSentenceCase(expense.category),
                      style: AppTypography.label.copyWith(
                        color: AppColors.dark300,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '£${expense.amount.toStringAsFixed(2)}', 
                style: AppTypography.labelStrong.copyWith(
                  color: isDark ? AppColors.pureWhite : AppColors.dark950,
                  fontWeight: AppTypography.weightBlack,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () => _deleteExpense(ref, event, expense.id),
                child: const Icon(
                  Icons.delete_outline_rounded, 
                  size: AppShapes.iconMd, 
                  color: AppColors.coral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAwardRow(BuildContext context, WidgetRef ref, GolfEvent event, EventAward award) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _showAwardDialog(context, ref, event, award: award),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
               Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.dark700.withValues(alpha: AppColors.opacityHigh) 
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppShapes.lg,
                ),
                child: Icon(
                  award.type == 'Cup' ? Icons.emoji_events_rounded : Icons.account_balance_wallet_rounded, 
                  size: AppShapes.iconMd, 
                  color: isDark ? AppColors.pureWhite : AppColors.dark950,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toSentenceCase(award.label), 
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                        fontWeight: AppTypography.weightBold,
                        fontSize: AppTypography.sizeBody,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      toTitleCase(award.winnerName ?? 'Unassigned'), 
                      style: AppTypography.label.copyWith(
                        color: award.winnerName != null ? AppColors.lime500 : AppColors.amber500,
                        fontWeight: AppTypography.weightBold,
                      ),
                    ),
                  ],
                ),
              ),
              if (award.value > 0)
                Text(
                  '£${award.value.toStringAsFixed(2)}', 
                  style: AppTypography.labelStrong.copyWith(
                    color: isDark ? AppColors.pureWhite : AppColors.dark950,
                    fontWeight: AppTypography.weightBlack,
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () => _deleteAward(ref, event, award.id),
                child: const Icon(
                  Icons.delete_outline_rounded, 
                  size: AppShapes.iconMd, 
                  color: AppColors.coral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddExpenseButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(
      title: 'Add expense',
      onTap: () => _showExpenseDialog(context, ref, event),
      isGhost: true,
      fullWidth: true,
    );
  }

  Widget _buildAddAwardButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(
      title: 'Add prize slot',
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

              // Financial Airdrop: Link Voucher prizes to Member Account Credit
              if (type == 'Voucher') {
                final allMembers = ref.read(allMembersProvider).value ?? [];

                // Handle Old Winner (if winner changed)
                if (award != null && award.type == 'Voucher' && award.winnerId != null && award.winnerId != selectedWinnerId) {
                  final oldMember = allMembers.firstWhereOrNull((m) => m.id == award.winnerId);
                  if (oldMember != null) {
                    await ref.read(membersRepositoryProvider).updateMember(
                      oldMember.copyWith(accountCredit: (oldMember.accountCredit - award.value).clamp(0, double.infinity)),
                    );
                  }
                }

                // Handle New/Current Winner
                if (selectedWinnerId != null) {
                  final member = allMembers.firstWhereOrNull((m) => m.id == selectedWinnerId);
                  if (member != null) {
                    double amountToAdd = newAward.value;
                    // If same winner, only add the difference
                    if (award != null && award.type == 'Voucher' && award.winnerId == selectedWinnerId) {
                      amountToAdd = newAward.value - award.value;
                    }

                    if (amountToAdd != 0) {
                      await ref.read(membersRepositoryProvider).updateMember(
                        member.copyWith(accountCredit: member.accountCredit + amountToAdd),
                      );
                    }
                  }
                }
              }

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

  Widget _buildReportRow(BuildContext context, IconData icon, String label, String value, {bool isBold = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
               color: isDark 
                  ? AppColors.dark700.withValues(alpha: AppColors.opacityHigh) 
                  : theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: AppShapes.lg,
            ),
            child: Icon(
              icon, 
              size: AppShapes.iconMd, 
              color: isDark ? AppColors.pureWhite : AppColors.dark950,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              label, 
              style: AppTypography.displayLargeBody.copyWith(
                fontSize: AppTypography.sizeBody, 
                height: 1.0,
                color: isDark ? AppColors.dark100 : AppColors.dark950, 
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ),
          Text(
            value, 
            style: AppTypography.displayLargeBody.copyWith(
              fontSize: AppTypography.sizeBody, 
              height: 1.0,
              color: isDark ? AppColors.pureWhite : AppColors.dark950,
              fontWeight: AppTypography.weightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.md),
      child: Row(
        children: [
          Text(
            label, 
            style: AppTypography.labelStrong.copyWith(
              color: AppColors.dark600, 
              fontWeight: AppTypography.weightBold,
            ),
          ),
          const Spacer(),
          Text(
            value, 
            style: AppTypography.labelStrong.copyWith(
              color: AppColors.dark950, 
              fontWeight: AppTypography.weightBold,
            ),
          ),
        ],
      ),
    );
  }
}
