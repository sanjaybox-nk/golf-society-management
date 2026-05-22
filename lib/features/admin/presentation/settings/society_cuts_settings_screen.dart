import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/features/admin/logic/society_cuts_impact_provider.dart';

class SocietyCutsSettingsScreen extends ConsumerStatefulWidget {
  const SocietyCutsSettingsScreen({super.key});

  @override
  ConsumerState<SocietyCutsSettingsScreen> createState() => _SocietyCutsSettingsScreenState();
}

class _SocietyCutsSettingsScreenState extends ConsumerState<SocietyCutsSettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    final config = ref.read(themeControllerProvider);
    _controllers.addAll(config.societyCutRules.map((key, value) => MapEntry(
          key,
          TextEditingController(text: value.toString()),
        )));
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateRule(String key, String value) {
    final double? val = double.tryParse(value);
    if (val != null) {
      final currentRules = Map<String, double>.from(ref.read(themeControllerProvider).societyCutRules);
      currentRules[key] = val;
      ref.read(themeControllerProvider.notifier).setSocietyCutRules(currentRules);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final config = ref.watch(themeControllerProvider);
    final currentMode = config.societyCutMode;
    final theme = Theme.of(context);
    final impactsAsync = ref.watch(societyCutsImpactProvider);

    return HeadlessScaffold(
      title: 'Society Cuts',
      subtitle: (config.societyCutMode != SocietyCutMode.off) ? 'Active' : 'Disabled',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      actions: const [],
      slivers: [
        // 1. Tab Bar
        SliverToBoxAdapter(
          child: BoxyArtTabBar<int>(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            tabs: const [
              ModernFilterTab(label: 'Rules', value: 0),
              ModernFilterTab(label: 'Impacts', value: 1),
            ],
            selectedValue: _selectedTabIndex,
            onTabSelected: (v) => setState(() => _selectedTabIndex = v),
          ),
        ),

        if (_selectedTabIndex == 0)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Mode Selector
                const BoxyArtSectionTitle(
                  title: 'Selection Mode',
                  isPeeking: true,
                ),
                BoxyArtCard(
                  child: BoxyArtSegmentedControl<SocietyCutMode>(
                    value: config.societyCutMode,
                    options: const [
                      BoxyOption(value: SocietyCutMode.off, label: 'Off', icon: Icons.power_settings_new_rounded),
                      BoxyOption(value: SocietyCutMode.global, label: 'Global', icon: Icons.auto_graph_rounded),
                      BoxyOption(value: SocietyCutMode.manual, label: 'Manual', icon: Icons.touch_app_rounded),
                    ],
                    onChanged: (mode) => ref.read(themeControllerProvider.notifier).setSocietyCutMode(mode),
                  ),
                ),

                if (currentMode == SocietyCutMode.off)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x4l,
                      horizontal: AppSpacing.lg,
                    ),
                    child: const BoxyArtEmptyCard(
                      title: 'Society Cuts Disabled',
                      message: 'Select a mode above to begin',
                      icon: Icons.shield_outlined,
                    ),
                  ),

                if (currentMode == SocietyCutMode.global) ...[
                  const BoxyArtSectionTitle(title: 'Rules & Logic'),
                  BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BoxyArtIconBadge(
                          icon: Icons.info_outline_rounded,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(
                            'Cuts follow an Additive Model (cumulative for each podium finish). These rules remain active for a Limited Duration based on the event limit and eligibility settings selected below.',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
                              height: 1.5,
                              fontWeight: AppTypography.weightMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const BoxyArtSectionTitle(title: 'Cut Results (Shots)'),
                  BoxyArtCard(
                    child: Column(
                      children: config.societyCutRules.entries.map((entry) {
                        final isLast = entry.key == config.societyCutRules.keys.last;
                        return Column(
                          children: [
                            BoxyArtMetricInput(
                              label: '${entry.key} Place',
                              subtitle: 'Adjustment for a ${entry.key} finish',
                              value: _controllers[entry.key]!.text,
                              suffixText: 'shots',
                              onChanged: (v) => _updateRule(entry.key, v),
                            ),
                            if (!isLast) ...[
                              const SizedBox(height: AppSpacing.lg),
                              BoxyArtDivider(verticalPadding: AppSpacing.xs),
                              const SizedBox(height: AppSpacing.xs),
                            ],
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const BoxyArtSectionTitle(title: 'Rule Duration'),
                  BoxyArtCard(
                    child: Column(
                      children: [
                        BoxyArtMetricInput(
                          label: 'Active for',
                          subtitle: 'Number of events the cut stays active (0 = Rest of season)',
                          value: config.societyCutEventLimit.toString(),
                          suffixText: 'events',
                          onChanged: (v) {
                            final limit = int.tryParse(v) ?? 0;
                            ref.read(themeControllerProvider.notifier).setSocietyCutEventLimit(limit);
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BoxyArtDivider(verticalPadding: AppSpacing.sm),
                        const SizedBox(height: AppSpacing.sm),
                        BoxyArtSwitchField(
                          label: 'Only count played events',
                          subtitle: 'Only events the member participates in count towards the limit',
                          value: config.societyCutCountPlayedOnly,
                          onChanged: (v) => ref.read(themeControllerProvider.notifier).setSocietyCutCountPlayedOnly(v),
                          labelColor: theme.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                  const BoxyArtSectionTitle(title: 'Event Eligibility'),
                  BoxyArtCard(
                    child: Column(
                      children: [
                        BoxyArtSwitchField(
                          label: 'Season events',
                          subtitle: 'Podium finishes in league events trigger automated cuts',
                          value: config.societyCutFilterSeason,
                          onChanged: (v) => ref.read(themeControllerProvider.notifier).setSocietyCutFilterSeason(v),
                          labelColor: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        BoxyArtDivider(verticalPadding: AppSpacing.sm),
                        const SizedBox(height: AppSpacing.sm),
                        BoxyArtSwitchField(
                          label: 'Non-Season Events',
                          subtitle: 'Podium finishes in non-season events trigger automated cuts',
                          value: config.societyCutFilterInvitational,
                          onChanged: (v) => ref.read(themeControllerProvider.notifier).setSocietyCutFilterInvitational(v),
                          labelColor: theme.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ],

                if (currentMode == SocietyCutMode.manual) ...[
                  const BoxyArtSectionTitle(title: 'Manual Overrides'),
                  BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BoxyArtIconBadge(
                          icon: Icons.info_outline_rounded,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(
                            'Manual overrides are managed on a per-event basis. Visit the Control Tower for any upcoming event to configure specific shot adjustments for individual members.',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
                              height: 1.5,
                              fontWeight: AppTypography.weightMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  BoxyArtButton(
                    title: 'Go to Events',
                    icon: Icons.event_note_rounded,
                    isGhost: true,
                    onTap: () => context.go('/admin/events'),
                  ),
                ],
              ]),
            ),
          ),

        if (_selectedTabIndex == 1)
          impactsAsync.when(
            loading: () => const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: BoxyArtLoadingCard(title: 'Calculating impacts...'),
              ),
            ),
            error: (err, stack) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: BoxyArtEmptyCard(
                  title: 'Calculation Error',
                  message: 'Could not determine cut impacts: $err',
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ),
            data: (impacts) {
              if (impacts.isEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.only(
                    top: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.x4l,
                  ),
                  sliver: const SliverToBoxAdapter(
                    child: BoxyArtEmptyCard(
                      title: 'No Active Cuts',
                      message: 'There are currently no members with active performance adjustments.',
                      icon: Icons.done_all_rounded,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.only(
                  top: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.lg,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final impact = impacts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: BoxyArtMemberRow(
                          name: impact.member.displayName,
                          initials: '${impact.member.firstName[0]}${impact.member.lastName[0]}',
                          avatarUrl: impact.member.avatarUrl,
                          score: '-${impact.breakdown.totalCut.toStringAsFixed(1)}',
                          scoreColor: AppColors.coral500,
                          secondaryName: impact.breakdown.sources.firstOrNull?.eventName,
                          hasSocietyCut: true,
                          accentColor: impact.isManual ? AppColors.amber500 : AppColors.coral500,
                        ),
                      );
                    },
                    childCount: impacts.length,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
