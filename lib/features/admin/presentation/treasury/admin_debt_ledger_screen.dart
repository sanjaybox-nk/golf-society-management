
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'controllers/debt_ledger_controller.dart';
import 'widgets/debt_ledger_widgets.dart';

class AdminDebtLedgerScreen extends ConsumerStatefulWidget {
  const AdminDebtLedgerScreen({super.key});

  @override
  ConsumerState<AdminDebtLedgerScreen> createState() => _AdminDebtLedgerScreenState();
}

class _AdminDebtLedgerScreenState extends ConsumerState<AdminDebtLedgerScreen> {
  String _searchQuery = '';

  void _showSettlementDialog(MemberDebtSummary summary) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Settle Balance',
      child: SettlementSheetContent(summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(debtSummariesProvider(_searchQuery));
    final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Central Debt Ledger',
      subtitle: 'Track and Settle Society Finances',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
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
              BoxyArtSearchInput(
                label: 'Search members',
                hintText: 'Search roster...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),

              if (summaries.isEmpty && !membersAsync.isLoading && !eventsAsync.isLoading)
                const BoxyArtEmptyCard(
                  title: 'All Settled',
                  message: 'No outstanding debts or credits found. Your society ledger is currently balanced.',
                  icon: Icons.account_balance_rounded,
                )
              else
                ...summaries.map((s) => DebtSummaryCard(
                  summary: s,
                  onSettle: () => _showSettlementDialog(s),
                )),
              
              if (membersAsync.isLoading || eventsAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              
              const SizedBox(height: AppSpacing.hero),
            ]),
          ),
        ),
      ],
    );
  }
}
