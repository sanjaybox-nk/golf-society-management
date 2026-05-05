import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

class TreasurySettingsScreen extends ConsumerStatefulWidget {
  const TreasurySettingsScreen({super.key});

  @override
  ConsumerState<TreasurySettingsScreen> createState() => _TreasurySettingsScreenState();
}

class _TreasurySettingsScreenState extends ConsumerState<TreasurySettingsScreen> {
  late final TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    final initialBalance = ref.read(themeControllerProvider).startingBalance;
    _balanceController = TextEditingController(text: initialBalance.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeControllerProvider);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Starting Balance',
      subtitle: 'Set opening bank balance',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      actions: const [],
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, 
            vertical: spacing?.labelToCard ?? AppSpacing.labelToCard
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'Balance', isPeeking: true),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.standard),
                child: Column(
                  children: [
                    BoxyArtInputField(
                      label: 'Opening bank balance',
                      controller: _balanceController,
                      prefixIcon: const Icon(Icons.account_balance_rounded),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        final balance = double.tryParse(val) ?? 0.0;
                        ref.read(themeControllerProvider.notifier).setStartingBalance(balance);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}
