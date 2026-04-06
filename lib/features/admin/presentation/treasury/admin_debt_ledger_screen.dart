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

  void _settleDebts(MemberDebtSummary summary, {double? partialAmount}) async {
    // If partialAmount is provided, we just add it to the member's credit
    if (partialAmount != null) {
      ref.read(membersRepositoryProvider).updateMember(
        summary.member.copyWith(accountCredit: summary.member.accountCredit + partialAmount),
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

    BoxyArtBottomSheet.show(
      context: context,
      title: 'SETTLE BALANCE',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Member: ${summary.member.displayName}',
                style: AppTypography.displaySection.copyWith(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Current Net Balance: £${summary.netBalance.abs().toStringAsFixed(0)} ${summary.netBalance < 0 ? 'Owed' : 'Credit'}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Settlement Mode Selection
              Row(
                children: [
                  Expanded(
                    child: BoxyArtButton(
                      title: 'FULL SETTLE',
                      isPrimary: !isPartial,
                      isSecondary: isPartial,
                      onTap: () => setModalState(() => isPartial = false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: BoxyArtButton(
                      title: 'PARTIAL',
                      isPrimary: isPartial,
                      isSecondary: !isPartial,
                      onTap: () => setModalState(() => isPartial = true),
                    ),
                  ),
                ],
              ),
              
              if (isPartial) ...[
                const SizedBox(height: AppSpacing.xl),
                BoxyArtInputField(
                  label: 'PARTIAL PAYMENT AMOUNT',
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.payments_rounded),
                ),
                Text(
                  'The amount entered will be added as credit to the member\'s account to offset their debt.',
                  style: AppTypography.micro.copyWith(color: AppColors.textSecondary),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Full settlement will mark all current outstanding events and fines as paid, consuming any available society credit.',
                  style: AppTypography.micro.copyWith(color: AppColors.textSecondary),
                ),
              ],
              
              const SizedBox(height: AppSpacing.x2l),
              BoxyArtButton(
                title: isPartial ? 'RECORD PAYMENT' : 'CONFIRM FULL SETTLE',
                fullWidth: true,
                onTap: () {
                  if (isPartial) {
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > 0) {
                      _settleDebts(summary, partialAmount: amount);
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
              showBack: true,
              onBack: () => context.pop(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        child: BoxyArtInputField(
                          label: '',
                          hint: 'Search members...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                      if (filteredSummaries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Text('All settled! No outstanding debts or credits found.', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ...filteredSummaries.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          loading: () => const HeadlessScaffold(title: 'Loading Ledger...', slivers: []),
          error: (err, st) => HeadlessScaffold(title: 'Error', slivers: [SliverFillRemaining(child: Center(child: Text(err.toString())))]),
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading Members...', slivers: []),
      error: (err, st) => HeadlessScaffold(title: 'Error', slivers: [SliverFillRemaining(child: Center(child: Text(err.toString())))]),
    );
  }
}
