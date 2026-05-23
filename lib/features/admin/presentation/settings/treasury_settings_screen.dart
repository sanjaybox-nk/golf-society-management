import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

class TreasurySettingsScreen extends ConsumerStatefulWidget {
  const TreasurySettingsScreen({super.key});

  @override
  ConsumerState<TreasurySettingsScreen> createState() => _TreasurySettingsScreenState();
}

class _TreasurySettingsScreenState extends ConsumerState<TreasurySettingsScreen> {
  late final TextEditingController _balanceController;
  late final TextEditingController _socialFeeController;

  @override
  void initState() {
    super.initState();
    final config = ref.read(themeControllerProvider);
    _balanceController = TextEditingController(text: config.startingBalance.toStringAsFixed(0));
    _socialFeeController = TextEditingController(text: config.socialMemberFee.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _socialFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(themeControllerProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Treasury Settings',
      subtitle: 'Balances & membership fees',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: spacing?.labelToCard ?? AppSpacing.labelToCard,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              const BoxyArtSectionTitle(title: 'Opening Balance', isPeeking: true),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.standard),
                child: BoxyArtInputField(
                  label: 'Opening bank balance',
                  controller: _balanceController,
                  prefixIcon: const Icon(Icons.account_balance_rounded),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    final balance = double.tryParse(val) ?? 0.0;
                    ref.read(themeControllerProvider.notifier).setStartingBalance(balance);
                  },
                ),
              ),

              if (config.enableSocialMembership) ...[
                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
                const BoxyArtSectionTitle(title: 'Social Membership', isPeeking: true),
                BoxyArtCard(
                  padding: const EdgeInsets.all(AppSpacing.standard),
                  child: BoxyArtInputField(
                    label: 'Annual social membership fee',
                    controller: _socialFeeController,
                    prefixIcon: const Icon(Icons.people_outline_rounded),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      final fee = double.tryParse(val) ?? 0.0;
                      ref.read(themeControllerProvider.notifier).setSocialMemberFee(fee);
                    },
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.pageBottom),
            ]),
          ),
        ),
      ],
    );
  }
}
