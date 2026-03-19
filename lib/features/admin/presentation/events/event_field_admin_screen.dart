import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import './event_registrations_admin_screen.dart';

// Reuse the same tab provider for parity
import '../../../events/presentation/tabs/event_user_placeholders.dart';

import './widgets/admin_grouping_toolbar.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';
import './widgets/admin_grouping_hub_content.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../../../events/domain/registration_logic.dart';

class EventFieldAdminScreen extends ConsumerWidget {
  final String eventId;

  const EventFieldAdminScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(adminEventsProvider);
    final allMembersAsync = ref.watch(allMembersProvider);
    return eventAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const HeadlessScaffold(
            title: 'Not Found',
            showBack: true,
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyState(
                  title: 'Event Not Found',
                  message: 'The requested event could not be located.',
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ],
          );
        }

        final selectedTab = ref.watch(eventFieldTabProvider);

        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Event Field and Tee Time',
          showBack: true,
          onBack: () => context.go('/admin/events'),
          useScaffold: false,
          subtitleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Field and Tee Time',
                style: TextStyle(
                  fontSize: AppTypography.sizeBodySmall,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                  fontWeight: AppTypography.weightSemibold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Hub Toggle
              ModernUnderlinedFilterBar<int>(
                selectedValue: selectedTab,
                isExpanded: true,
                onTabSelected: (val) => ref.read(eventFieldTabProvider.notifier).set(val),
                tabs: const [
                  ModernFilterTab(label: 'Entries', value: 0),
                  ModernFilterTab(label: 'Tee Time', value: 1),
                ],
              ),
            ],
          ),
          pinnedBottom: null,
          slivers: [
            if (selectedTab == 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: AdminGroupingToolbar(
                    event: event,
                    onReset: () {
                      ref.read(groupingLocalGroupsProvider.notifier).setGroups(null);
                      ref.read(groupingDirtyProvider.notifier).setDirty(true);
                    },
                    onSave: () async {
                      _handleSave(context, ref, event);
                    },
                    onAutoGenerate: () {
                      _showGenerationOptions(context, ref, event);
                    },
                  ),
                ),
              ),
            if (selectedTab == 0)
              allMembersAsync.when(
                data: (members) => EventRegistrationsAdminScreen.buildSliver(context, ref, event, members),
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
              )
            else
              AdminGroupingHubContent(eventId: eventId, isHubMode: true),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => HeadlessScaffold(
        title: 'Error',
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }


  void _showGenerationOptions(BuildContext context, WidgetRef ref, GolfEvent event) {
    final strategy = ref.read(groupingStrategyProvider);
    final hasGroups = (ref.read(groupingLocalGroupsProvider)?.isNotEmpty ?? false);

    if (hasGroups) {
      showDialog(
        context: context,
        builder: (context) => Material(
        color: Colors.transparent,
        child: BoxyArtDialog(
          title: 'Regenerate Tee Time?',
          message: 'Current groups will be cleared. Strategy: ${toTitleCase(strategy)}.',
          onConfirm: () {
            Navigator.pop(context);
            _executeGeneration(context, ref, strategy);
          },
          onCancel: () => Navigator.pop(context),
          confirmText: 'Regenerate',
        ),
      ),
    );
  }  else {
      _executeGeneration(context, ref, strategy);
    }
  }

  void _executeGeneration(BuildContext context, WidgetRef ref, String strategy) {
    final events = ref.read(adminEventsProvider).value ?? [];
    final event = events.firstWhereOrNull((e) => e.id == eventId);
    if (event == null) return;

    final members = ref.read(allMembersProvider).value ?? [];
    final handicapMap = {for (var m in members) m.id: m.handicap};
    
    // Get confirmed participants for grouping
    final participants = RegistrationLogic.getPlayingParticipants(event);

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No confirmed participants to group'), backgroundColor: AppColors.coral500),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating groups using $strategy strategy...'), duration: const Duration(seconds: 1)),
    );

    // Call actual generation service
    final newGroups = GroupingService.generateInitialGrouping(
      event: event,
      participants: participants,
      previousEventsInSeason: events.where((e) => e.id != eventId).toList(),
      memberHandicaps: handicapMap,
      strategy: strategy,
    );

    // Update local state and trigger UI refresh
    ref.read(groupingLocalGroupsProvider.notifier).setGroups(newGroups);
    ref.read(groupingDirtyProvider.notifier).setDirty(true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Groups Generated Successfully!'), backgroundColor: AppColors.teamA),
    );
  }
}

void _handleSave(BuildContext context, WidgetRef ref, GolfEvent event) async {
  final groups = ref.read(groupingLocalGroupsProvider);
  if (groups == null) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Saving Tee Times...'), duration: Duration(milliseconds: 500)));

  // Save logic: update the event repository
  await ref.read(eventsRepositoryProvider).updateEvent(
    event.copyWith(grouping: {...event.grouping, 'groups': groups.map((g) => g.toJson()).toList()}),
  );

  ref.read(groupingDirtyProvider.notifier).setDirty(false);

  if (context.mounted) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Tee Times Saved Successfully'), backgroundColor: AppColors.teamA),
    );
  }
}
