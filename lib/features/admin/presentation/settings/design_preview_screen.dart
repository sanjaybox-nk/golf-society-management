import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

// Local state providers for each preview
final _segmentedTwoProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _segmentedThreeProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _segmentedFourProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _pillTwoProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _pillThreeProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _pillFourProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _underlineTwoProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _underlineFourProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _tabBarTwoProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _tabBarThreeProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);
final _tabBarFourProvider = NotifierProvider<_IntNotifier, int>(_IntNotifier.new);

class _IntNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
}

class DesignPreviewScreen extends ConsumerWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Component Preview',
      subtitle: 'Navigation Variants',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),

              // ── SEGMENTED CONTROL (sliding pill) ──────────────────────────
              const BoxyArtSectionTitle(title: 'Segmented Control — Sliding Pill'),
              SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
              _PreviewCard(
                label: '2 options — content toggle (Scoring / Scorecard)',
                child: BoxyArtSegmentedControl<int>(
                  value: ref.watch(_segmentedTwoProvider),
                  onChanged: (v) => ref.read(_segmentedTwoProvider.notifier).set(v),
                  options: const [
                    BoxyOption(value: 0, label: 'Scoring', icon: Icons.edit_note_rounded),
                    BoxyOption(value: 1, label: 'Scorecard', icon: Icons.grid_on_rounded),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '3 options (Pending / Renewing / Paid)',
                child: BoxyArtSegmentedControl<int>(
                  value: ref.watch(_segmentedThreeProvider),
                  onChanged: (v) => ref.read(_segmentedThreeProvider.notifier).set(v),
                  options: const [
                    BoxyOption(value: 0, label: 'Pending'),
                    BoxyOption(value: 1, label: 'Renewing'),
                    BoxyOption(value: 2, label: 'Paid'),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '4 options — Members (Active / Committee / Other / Guests)',
                child: BoxyArtSegmentedControl<int>(
                  value: ref.watch(_segmentedFourProvider),
                  onChanged: (v) => ref.read(_segmentedFourProvider.notifier).set(v),
                  options: const [
                    BoxyOption(value: 0, label: 'Active'),
                    BoxyOption(value: 1, label: 'Committee'),
                    BoxyOption(value: 2, label: 'Other'),
                    BoxyOption(value: 3, label: 'Guests'),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),

              // ── PILL CHIP BAR (scrollable chips) ──────────────────────────
              const BoxyArtSectionTitle(title: 'Pill Chip Bar — Fixed (Non-scrollable)'),
              SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
              _PreviewCard(
                label: '2 options (News Updates / Event Info)',
                child: BoxyArtChipBar<int>(
                  value: ref.watch(_pillTwoProvider),
                  onChanged: (v) => ref.read(_pillTwoProvider.notifier).set(v),
                  options: const [
                    BoxyOption(value: 0, label: 'News', icon: Icons.campaign_rounded),
                    BoxyOption(value: 1, label: 'Event Info', icon: Icons.info_rounded),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '3 options (Groups / Standings / Bracket)',
                child: BoxyArtChipBar<int>(
                  value: ref.watch(_pillThreeProvider),
                  onChanged: (v) => ref.read(_pillThreeProvider.notifier).set(v),
                  options: const [
                    BoxyOption(value: 0, label: 'Groups', icon: Icons.groups_rounded),
                    BoxyOption(value: 1, label: 'Standings', icon: Icons.leaderboard_rounded),
                    BoxyOption(value: 2, label: 'Bracket', icon: Icons.account_tree_rounded),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '4 options — Members (Active / Committee / Other / Guests)',
                child: BoxyArtChipBar<int>(
                  value: ref.watch(_pillFourProvider),
                  onChanged: (v) => ref.read(_pillFourProvider.notifier).set(v),
                  options: const [
                    BoxyOption(value: 0, label: 'Active', icon: Icons.person_rounded),
                    BoxyOption(value: 1, label: 'Committee', icon: Icons.verified_user_rounded),
                    BoxyOption(value: 2, label: 'Other', icon: Icons.more_horiz_rounded),
                    BoxyOption(value: 3, label: 'Guests', icon: Icons.person_add_rounded),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),

              // ── BOXYART TAB BAR — with icons ──────────────────────────────
              const BoxyArtSectionTitle(title: 'BoxyArt Tab Bar — With Icons'),
              SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
              _PreviewCard(
                label: '2 options',
                child: BoxyArtTabBar<int>(
                  selectedValue: ref.watch(_tabBarTwoProvider),
                  onTabSelected: (v) => ref.read(_tabBarTwoProvider.notifier).set(v),
                  tabs: const [
                    ModernFilterTab(value: 0, label: 'Scoring', icon: Icons.edit_note_rounded),
                    ModernFilterTab(value: 1, label: 'Scorecard', icon: Icons.grid_on_rounded),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '4 options — Members',
                child: BoxyArtTabBar<int>(
                  selectedValue: ref.watch(_tabBarFourProvider),
                  onTabSelected: (v) => ref.read(_tabBarFourProvider.notifier).set(v),
                  tabs: const [
                    ModernFilterTab(value: 0, label: 'Active', icon: Icons.person_rounded),
                    ModernFilterTab(value: 1, label: 'Committee', icon: Icons.verified_user_rounded),
                    ModernFilterTab(value: 2, label: 'Other', icon: Icons.more_horiz_rounded),
                    ModernFilterTab(value: 3, label: 'Guests', icon: Icons.person_add_rounded),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),

              // ── BOXYART TAB BAR — without icons ───────────────────────────
              const BoxyArtSectionTitle(title: 'BoxyArt Tab Bar — Without Icons'),
              SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
              _PreviewCard(
                label: '2 options',
                child: BoxyArtTabBar<int>(
                  selectedValue: ref.watch(_tabBarTwoProvider),
                  onTabSelected: (v) => ref.read(_tabBarTwoProvider.notifier).set(v),
                  tabs: const [
                    ModernFilterTab(value: 0, label: 'Scoring'),
                    ModernFilterTab(value: 1, label: 'Scorecard'),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '3 options',
                child: BoxyArtTabBar<int>(
                  selectedValue: ref.watch(_tabBarThreeProvider),
                  onTabSelected: (v) => ref.read(_tabBarThreeProvider.notifier).set(v),
                  tabs: const [
                    ModernFilterTab(value: 0, label: 'Groups'),
                    ModernFilterTab(value: 1, label: 'Standings'),
                    ModernFilterTab(value: 2, label: 'Bracket'),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '4 options — Members',
                child: BoxyArtTabBar<int>(
                  selectedValue: ref.watch(_tabBarFourProvider),
                  onTabSelected: (v) => ref.read(_tabBarFourProvider.notifier).set(v),
                  tabs: const [
                    ModernFilterTab(value: 0, label: 'Active'),
                    ModernFilterTab(value: 1, label: 'Committee'),
                    ModernFilterTab(value: 2, label: 'Other'),
                    ModernFilterTab(value: 3, label: 'Guests'),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),

              // ── CURRENT (underlined) ───────────────────────────────────────
              const BoxyArtSectionTitle(title: 'Current — Underlined Tab Bar'),
              SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
              _PreviewCard(
                label: '2 options (current style)',
                child: ModernUnderlinedFilterBar<int>(
                  selectedValue: ref.watch(_underlineTwoProvider),
                  onTabSelected: (v) => ref.read(_underlineTwoProvider.notifier).set(v),
                  isExpanded: true,
                  tabs: const [
                    ModernFilterTab(value: 0, label: 'Scoring', icon: Icons.edit_note_rounded),
                    ModernFilterTab(value: 1, label: 'Scorecard', icon: Icons.grid_on_rounded),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard),
              _PreviewCard(
                label: '4 options (current style)',
                child: ModernUnderlinedFilterBar<int>(
                  selectedValue: ref.watch(_underlineFourProvider),
                  onTabSelected: (v) => ref.read(_underlineFourProvider.notifier).set(v),
                  isExpanded: true,
                  tabs: const [
                    ModernFilterTab(value: 0, label: 'Active', icon: Icons.person_rounded),
                    ModernFilterTab(value: 1, label: 'Committee', icon: Icons.verified_user_rounded),
                    ModernFilterTab(value: 2, label: 'Other', icon: Icons.more_horiz_rounded),
                    ModernFilterTab(value: 3, label: 'Guests', icon: Icons.person_add_rounded),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.hero),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _PreviewCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.atomic),
          child,
        ],
      ),
    );
  }
}
