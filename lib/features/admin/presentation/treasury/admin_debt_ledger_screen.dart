import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';

class MemberDebtSummary {
  final Member member;
  final double totalDebt;
  final double totalCredit;
  final List<GolfEvent> unpaidEvents;
  final List<EventFine> unpaidFines;
  final double totalEventFeesOwed;
  final double totalFinesOwed;

  MemberDebtSummary({
    required this.member,
    required this.totalDebt,
    required this.totalCredit,
    required this.unpaidEvents,
    required this.unpaidFines,
    required this.totalEventFeesOwed,
    required this.totalFinesOwed,
  });

  double get netBalance => totalCredit - totalDebt;
}

class AdminDebtLedgerScreen extends ConsumerStatefulWidget {
  const AdminDebtLedgerScreen({super.key});

  @override
  ConsumerState<AdminDebtLedgerScreen> createState() => _AdminDebtLedgerScreenState();
}

class _AdminDebtLedgerScreenState extends ConsumerState<AdminDebtLedgerScreen> {
  String _searchQuery = '';

  void _settleDebts(MemberDebtSummary summary, {double? partialAmount, bool isPayout = false}) async {
    // If partialAmount is provided, we just add it to the member's credit (or subtract if payout)
    if (partialAmount != null) {
      final adjustment = isPayout ? -partialAmount : partialAmount;
      ref.read(membersRepositoryProvider).updateMember(
        summary.member.copyWith(accountCredit: summary.member.accountCredit + adjustment),
      );
      return;
    }

    // Collect all unique events that need updating
    final eventsToUpdate = <String, GolfEvent>{};

    // Gather latest data
    final allEvents = ref.read(eventsProvider).value ?? [];
    
    // Process Event Fees
    for (final e in summary.unpaidEvents) {
      if (!eventsToUpdate.containsKey(e.id)) {
        eventsToUpdate[e.id] = allEvents.firstWhere((evt) => evt.id == e.id);
      }
      var evt = eventsToUpdate[e.id]!;
      final newRegs = List<EventRegistration>.from(evt.registrations);
      final idx = newRegs.indexWhere((r) => r.memberId == summary.member.id);
      if (idx >= 0) {
        newRegs[idx] = newRegs[idx].copyWith(hasPaid: true, finePaid: true); // Settle both if possible
      }
      eventsToUpdate[e.id] = evt.copyWith(registrations: newRegs);
    }
    
    // Update the events in the backend
    for (final evt in eventsToUpdate.values) {
      ref.read(eventsRepositoryProvider).updateEvent(evt);
    }

    // Process Member Credit reduction if there was credit.
    double remainingCredit = summary.totalCredit;
    if (summary.totalCredit > 0) {
      if (summary.totalDebt >= summary.totalCredit) {
        remainingCredit = 0.0;
      } else {
        remainingCredit = summary.totalCredit - summary.totalDebt;
      }
      ref.read(membersRepositoryProvider).updateMember(summary.member.copyWith(accountCredit: remainingCredit));
    }
  }

  void _showSettlementDialog(MemberDebtSummary summary) {
    final amountController = TextEditingController(text: summary.netBalance.abs().toStringAsFixed(0));
    bool isPartial = false;
    bool isPayoutMode = summary.netBalance > 0 && summary.totalDebt == 0;

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Settle Balance',
      initialChildSize: 0.6, // Slightly increased to allow space for the Partial input field
      minChildSize: 0.45,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Identity Component (Branded Card)
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const BoxyArtSquareBadge(
                      size: 48,
                      isTinted: true,
                      child: Icon(Icons.account_balance_wallet_rounded, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.member.displayName,
                            style: AppTypography.cardTitle.copyWith(
                              color: isDark ? AppColors.pureWhite : AppColors.dark900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Current Net Balance: £${summary.netBalance.abs().toStringAsFixed(0)} ${summary.netBalance < 0 ? 'Owed' : 'Credit'}',
                            style: AppTypography.subtext.copyWith(
                              color: summary.netBalance < 0 ? AppColors.coral500 : AppColors.lime500,
                              fontWeight: AppTypography.weightBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // 2. Settlement Configuration Card (Based on User suggestion)
              Text(
                'SETTLEMENT TYPE', 
                style: AppTypography.micro.copyWith(
                  color: isDark ? AppColors.dark300 : AppColors.dark400,
                  fontWeight: AppTypography.weightBold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: BoxyArtButton(
                            title: 'Full Settle',
                            isPrimary: !isPartial,
                            isSecondary: isPartial,
                            isGhost: isPartial,
                            isSmall: true,
                            onTap: () => setModalState(() => isPartial = false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: BoxyArtButton(
                            title: isPayoutMode ? 'Payout' : 'Partial',
                            isPrimary: isPartial,
                            isSecondary: !isPartial,
                            isGhost: !isPartial,
                            isSmall: true,
                            onTap: () => setModalState(() => isPartial = true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    if (isPartial) ...[
                      BoxyArtInputField(
                        label: isPayoutMode ? 'Payout Amount' : 'Payment Amount',
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icon(isPayoutMode ? Icons.redeem_rounded : Icons.payments_rounded),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          isPayoutMode 
                            ? 'Deducted from available voucher credit.' 
                            : 'Added as credit to offset debt.',
                          style: AppTypography.micro.copyWith(
                            color: isDark ? AppColors.dark300 : AppColors.dark400,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.dark800 : AppColors.dark50,
                          borderRadius: BorderRadius.circular(AppShapes.rLg),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: isDark ? AppColors.dark300 : AppColors.dark400),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'This will mark all outstanding items as paid using any available credit.',
                                style: AppTypography.micro.copyWith(
                                  color: isDark ? AppColors.dark200 : AppColors.dark500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.standard),
              BoxyArtButton(
                title: isPartial 
                    ? (isPayoutMode ? 'Confirm Payout' : 'Record Payment')
                    : 'Confirm Settlement',
                fullWidth: true,
                backgroundColor: AppColors.actionMidnight,
                onTap: () {
                  if (isPartial) {
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > 0) {
                      _settleDebts(summary, partialAmount: amount, isPayout: isPayoutMode);
                      Navigator.pop(context);
                    }
                  } else {
                    _settleDebts(summary);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return membersAsync.when(
      data: (members) {
        return eventsAsync.when(
          data: (events) {
            // Compute central ledger
            final summaries = <MemberDebtSummary>[];

            for (final member in members) {
              double eventFeesOwed = 0.0;
              double finesOwed = 0.0;
              final unpaidEvts = <GolfEvent>[];
              final unpaidFines = <EventFine>[];

              for (final evt in events) {
                final reg = evt.registrations.firstWhere((r) => r.memberId == member.id, orElse: () => const EventRegistration(memberId: '', memberName: ''));
                if (reg.memberId.isNotEmpty) {
                  // Check Event Cost
                  if (!reg.hasPaid && reg.cost > 0 && reg.isConfirmed) {
                    eventFeesOwed += reg.cost;
                    unpaidEvts.add(evt);
                  }
                  // Check Fines
                  if (!reg.finePaid && reg.fineAmount > 0) {
                    finesOwed += reg.fineAmount;
                    unpaidFines.addAll(reg.fines); // Add detailed itemization
                    // If we didn't add the event yet for entry fees, add it so we can update it
                    if (!unpaidEvts.contains(evt)) {
                      unpaidEvts.add(evt);
                    }
                  }
                }
              }

              final totalDebt = eventFeesOwed + finesOwed;
              final totalCredit = member.accountCredit;

              if (totalDebt != 0 || totalCredit != 0) {
                summaries.add(MemberDebtSummary(
                  member: member,
                  totalDebt: totalDebt,
                  totalCredit: totalCredit,
                  unpaidEvents: unpaidEvts,
                  unpaidFines: unpaidFines,
                  totalEventFeesOwed: eventFeesOwed,
                  totalFinesOwed: finesOwed,
                ));
              }
            }

            final filteredSummaries = _searchQuery.isEmpty 
              ? summaries 
              : summaries.where((s) => s.member.displayName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

            return HeadlessScaffold(
              title: 'Central Debt Ledger',
              subtitle: 'Track and Settle Society Finances',
              titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
              showBack: true,
              onBack: () => context.pop(),
              actions: const [],
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const BoxyArtSectionTitle(
                        title: 'Global ledger',
                        isPeeking: true,
                      ),
                      // Standardized 4.x Search Input
                      BoxyArtSearchInput(
                        label: 'Search members',
                        hintText: 'Search roster...',
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                      SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),

                      if (filteredSummaries.isEmpty)
                        const BoxyArtEmptyCard(
                          title: 'All Settled',
                          message: 'No outstanding debts or credits found. Your society ledger is currently balanced.',
                          icon: Icons.account_balance_rounded,
                        ),
                      ...filteredSummaries.map((s) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.md),
                          child: BoxyArtCard(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(s.member.displayName, style: AppTypography.memberName),
                                    ),
                                    if (s.netBalance > 0)
                                      BoxyArtPill.status(
                                        label: 'CREDIT: +£${s.netBalance.toStringAsFixed(0)}',
                                        color: AppColors.lime500,
                                      )
                                    else if (s.netBalance < 0)
                                      BoxyArtPill.status(
                                        label: 'OWES: £${s.netBalance.abs().toStringAsFixed(0)}',
                                        color: AppColors.coral500,
                                      )
                                    else
                                      BoxyArtPill.status(
                                        label: 'Settled',
                                        color: AppColors.dark300,
                                      )
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (s.totalCredit > 0) ...[
                                  Text('Available Voucher Credit: £${s.totalCredit.toStringAsFixed(0)}', style: AppTypography.micro.copyWith(color: AppColors.lime500, fontWeight: AppTypography.weightBold)),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                                if (s.totalEventFeesOwed > 0) ...[
                                  Text('Event Entry Fees Owed: £${s.totalEventFeesOwed.toStringAsFixed(0)}', style: AppTypography.micro),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                                if (s.totalFinesOwed > 0) ...[
                                  Text('Accumulated Fines Owed: £${s.totalFinesOwed.toStringAsFixed(0)}', style: AppTypography.micro.copyWith(color: AppColors.coral500)),
                                  ...s.unpaidFines.map((f) => Padding(
                                    padding: const EdgeInsets.only(left: AppSpacing.md, top: 2),
                                    child: Text('• ${f.reason} (£${f.amount.toStringAsFixed(0)})', style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                                  )),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    BoxyArtButton(
                                      title: 'Settle',
                                      isSmall: true,
                                      isPrimary: s.netBalance < 0,
                                      onTap: () => _showSettlementDialog(s),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.hero),
                    ]),
                  ),
                ),
              ],
            );
          },
          loading: () => HeadlessScaffold(
            title: 'Loading Events...', 
            titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
            slivers: const [],
          ),
          error: (err, st) => HeadlessScaffold(
            title: 'Error', 
            titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
            slivers: [SliverFillRemaining(child: Center(child: Text('Error')))],
          ),
        );
      },
      loading: () => HeadlessScaffold(
        title: 'Loading Members...', 
        titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
        slivers: const [],
      ),
      error: (err, st) => HeadlessScaffold(
        title: 'Error', 
        titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
        slivers: [SliverFillRemaining(child: Center(child: Text('Error')))],
      ),
    );
  }
}
