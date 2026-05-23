
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../controllers/debt_ledger_controller.dart';

class DebtSummaryCard extends ConsumerWidget {
  final MemberDebtSummary summary;
  final VoidCallback onSettle;

  const DebtSummaryCard({
    super.key,
    required this.summary,
    required this.onSettle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

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
                  child: Text(summary.member.displayName, style: AppTypography.memberName),
                ),
                if (summary.netBalance > 0)
                  BoxyArtIndicator.status(
                    label: 'CREDIT: +£${summary.netBalance.toStringAsFixed(0)}',
                    color: AppColors.lime500,
                  )
                else if (summary.netBalance < 0)
                  BoxyArtIndicator.status(
                    label: 'OWES: £${summary.netBalance.abs().toStringAsFixed(0)}',
                    color: AppColors.coral500,
                  )
                else
                  BoxyArtIndicator.status(
                    label: 'Settled',
                    color: AppColors.dark300,
                  )
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (summary.totalCredit > 0) ...[
              Text(
                'Available Voucher Credit: £${summary.totalCredit.toStringAsFixed(0)}', 
                style: AppTypography.micro.copyWith(color: AppColors.lime500, fontWeight: AppTypography.weightBold)
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (summary.totalEventFeesOwed > 0) ...[
              Text('Event Entry Fees Owed: £${summary.totalEventFeesOwed.toStringAsFixed(0)}', style: AppTypography.micro),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (summary.totalFinesOwed > 0) ...[
              Text('Accumulated Fines Owed: £${summary.totalFinesOwed.toStringAsFixed(0)}', style: AppTypography.micro.copyWith(color: AppColors.coral500)),
              ...summary.unpaidFines.map((f) => Padding(
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
                  isPrimary: summary.netBalance < 0,
                  onTap: onSettle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettlementSheetContent extends ConsumerStatefulWidget {
  final MemberDebtSummary summary;

  const SettlementSheetContent({super.key, required this.summary});

  @override
  ConsumerState<SettlementSheetContent> createState() => _SettlementSheetContentState();
}

class _SettlementSheetContentState extends ConsumerState<SettlementSheetContent> {
  late final TextEditingController _amountController;
  bool _isPartial = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.summary.netBalance.abs().toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPayoutMode = widget.summary.netBalance > 0 && widget.summary.totalDebt == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      widget.summary.member.displayName,
                      style: AppTypography.cardTitle.copyWith(
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Current Net Balance: £${widget.summary.netBalance.abs().toStringAsFixed(0)} ${widget.summary.netBalance < 0 ? 'Owed' : 'Credit'}',
                      style: AppTypography.subtext.copyWith(
                        color: widget.summary.netBalance < 0 ? AppColors.coral500 : AppColors.lime500,
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
                      isPrimary: !_isPartial,
                      isSecondary: _isPartial,
                      isGhost: _isPartial,
                      isSmall: true,
                      onTap: () => setState(() => _isPartial = false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: BoxyArtButton(
                      title: isPayoutMode ? 'Payout' : 'Partial',
                      isPrimary: _isPartial,
                      isSecondary: !_isPartial,
                      isGhost: !_isPartial,
                      isSmall: true,
                      onTap: () => setState(() => _isPartial = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isPartial) ...[
                BoxyArtInputField(
                  label: isPayoutMode ? 'Payout Amount' : 'Payment Amount',
                  controller: _amountController,
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
          title: _isPartial 
              ? (isPayoutMode ? 'Confirm Payout' : 'Record Payment')
              : 'Confirm Settlement',
          fullWidth: true,
          backgroundColor: AppColors.actionMidnight,
          onTap: () {
            final controller = ref.read(debtLedgerControllerProvider.notifier);
            if (_isPartial) {
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              if (amount > 0) {
                controller.settleDebts(widget.summary, partialAmount: amount, isPayout: isPayoutMode);
                Navigator.pop(context);
              }
            } else {
              controller.settleDebts(widget.summary);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
