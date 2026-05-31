import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:go_router/go_router.dart';

class EventAdminGroupingScreen extends ConsumerWidget {
  final String eventId;

  const EventAdminGroupingScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        final config = ref.watch(themeControllerProvider);
        final strategy = event.groupingStrategy ?? config.groupingStrategy;
        final isLocked = ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false);

        return HeadlessScaffold(
          title: 'Grouping Settings',
          subtitle: event.title,
          topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
          showBack: true,
          onBack: () => context.pop(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const BoxyArtSectionTitle(title: 'Grouping configuration', isPeeking: true),
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsRow(
                          icon: Icons.auto_awesome_outlined,
                          title: 'Default Strategy',
                          value: toSentenceCase(strategy),
                          onTap: () => _showStrategyPicker(context, ref, event, strategy),
                        ),
                        const BoxyArtDivider(),
                        _SettingsRow(
                          icon: Icons.timer_outlined,
                          title: 'Tee Interval',
                          value: '${event.teeOffInterval} mins',
                          onTap: () => _showIntervalPicker(context, ref, event),
                        ),
                        const BoxyArtDivider(),
                        BoxyArtSwitchTile(
                          icon: Icons.lock_person_outlined,
                          label: 'Lock Grouping',
                          subtitle: 'Prevent accidental changes to the tee sheet while editing.',
                          value: isLocked,
                          onChanged: (val) => _handleLockToggle(context, ref, event, val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.hero),
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Loading...',
        slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (err, st) => HeadlessScaffold(
        title: 'Error',
        slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))],
      ),
    );
  }

  void _showStrategyPicker(BuildContext context, WidgetRef ref, GolfEvent event, String current) {
    Future<void> select(String value) async {
      Navigator.pop(context);
      await ref.read(eventsRepositoryProvider).updateEvent(
        event.copyWith(groupingStrategy: value),
      );
    }

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Default Strategy',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoxyArtSelectCard(
            icon: Icons.shuffle_rounded,
            label: 'Random',
            description: 'Socially varied pairings with no influence from ability.',
            isSelected: current == 'random',
            onTap: () => select('random'),
          ),
          BoxyArtSelectCard(
            icon: Icons.balance_rounded,
            label: 'Balanced',
            description: 'Aims to normalize total handicap across all groups.',
            isSelected: current == 'balanced',
            onTap: () => select('balanced'),
          ),
          BoxyArtSelectCard(
            icon: Icons.trending_up_rounded,
            label: 'Progressive',
            description: 'Ordered by handicap — lower handicaps at the front.',
            isSelected: current == 'progressive',
            onTap: () => select('progressive'),
          ),
          BoxyArtSelectCard(
            icon: Icons.people_outline_rounded,
            label: 'Similar Ability',
            description: 'Groups players with similar handicaps together.',
            isSelected: current == 'similar',
            onTap: () => select('similar'),
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker(BuildContext context, WidgetRef ref, GolfEvent event) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Tee Interval',
      child: _IntervalPickerContent(
        initialValue: event.teeOffInterval,
        onChanged: (value) => ref.read(eventsRepositoryProvider).updateEvent(
          event.copyWith(teeOffInterval: value),
        ),
      ),
    );
  }

  Future<void> _handleLockToggle(BuildContext context, WidgetRef ref, GolfEvent event, bool val) async {
    if (!val) {
      ref.read(groupingIsLockedProvider.notifier).setLocked(false);
      return;
    }

    final members = ref.read(allMembersProvider).value ?? [];
    final societyConfig = ref.read(themeControllerProvider);
    final comp = ref.read(competitionDetailProvider(event.id)).value;

    final groupsData = event.grouping['groups'] as List?;
    final groups = groupsData?.map((g) => TeeGroup.fromJson(g)).toList() ?? [];

    final pool = GroupingService.getUnassignedPlayers(
      event: event,
      groups: groups,
      memberHandicaps: {for (var m in members) m.id: m.handicap},
      rules: comp?.rules,
      useWhs: societyConfig.useWhsHandicaps,
      manualCuts: event.manualCuts,
    );

    if (pool.isNotEmpty) {
      final names = pool.map((p) => p.name).join(', ');
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => BoxyArtDialog(
          title: 'Unassigned Players Found',
          message: 'The following confirmed players are not in any group: $names.\n\nWould you like to auto-fill them into vacancies before locking?',
          confirmText: 'Auto-fill & lock',
          cancelText: 'Just lock',
          onConfirm: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
        ),
      );

      if (confirmed == null) return;

      if (confirmed) {
        final updatedGroups = GroupingService.autoFillVacancies(groups: groups, pool: pool);
        await ref.read(eventsRepositoryProvider).updateEvent(
          event.copyWith(
            grouping: {
              ...event.grouping,
              'groups': updatedGroups.map((g) => g.toJson()).toList(),
              'locked': true,
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
        ref.read(groupingIsLockedProvider.notifier).setLocked(true);
        ref.read(groupingLocalGroupsProvider.notifier).setGroups(updatedGroups);
        return;
      }
    }

    ref.read(groupingIsLockedProvider.notifier).setLocked(true);
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(grouping: {...event.grouping, 'locked': true}),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.md,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.micro.copyWith(
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: 1.0,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTypography.micro.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                      fontWeight: AppTypography.weightMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.dark300),
          ],
        ),
      ),
    );
  }
}

class _IntervalPickerContent extends StatefulWidget {
  final int initialValue;
  final void Function(int) onChanged;

  const _IntervalPickerContent({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_IntervalPickerContent> createState() => _IntervalPickerContentState();
}

class _IntervalPickerContentState extends State<_IntervalPickerContent> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _adjust(int delta) {
    final next = (_value + delta).clamp(5, 20);
    if (next == _value) return;
    setState(() => _value = next);
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BoxyArtCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Opacity(
                opacity: _value <= 5 ? 0.3 : 1.0,
                child: BoxyArtGlassIconButton(
                  icon: Icons.remove_rounded,
                  iconSize: 22,
                  onPressed: _value > 5 ? () => _adjust(-1) : null,
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_value',
                      style: AppTypography.displaySection.copyWith(
                        fontSize: 48,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: ' min',
                      style: AppTypography.label.copyWith(
                        color: AppColors.dark400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: _value >= 20 ? 0.3 : 1.0,
                child: BoxyArtGlassIconButton(
                  icon: Icons.add_rounded,
                  iconSize: 22,
                  onPressed: _value < 20 ? () => _adjust(1) : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.atomic),
        Text(
          '5 – 20 min range',
          style: AppTypography.micro.copyWith(color: AppColors.dark400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
