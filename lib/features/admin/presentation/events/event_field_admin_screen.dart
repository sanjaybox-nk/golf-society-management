import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import './event_registrations_admin_screen.dart';

// Reuse the same tab provider for parity
import '../../../events/presentation/tabs/event_tabs_state.dart';

import './widgets/admin_grouping_hub_content.dart';


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
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BoxyArtEmptyCard(
                      title: 'Event Not Found',
                      message: 'The requested event could not be located on the fairway.',
                      icon: Icons.error_outline_rounded,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final competitionAsync = ref.watch(competitionDetailProvider(eventId));
        final selectedTab = ref.watch(eventFieldTabProvider);

        final isTournamentGrouping = competitionAsync.value?.rules.isTournamentStyleGrouping ?? false;

        return HeadlessScaffold(
          title: event.title,
          topPill: BoxyArtPill.committee(label: 'ADMIN'),
          subtitle: 'Event Field and Tee Time',
          showBack: true,
          onBack: () => context.go('/admin/events'),

          pinnedBottom: null,
          slivers: [
            SliverToBoxAdapter(
              child: BoxyArtTabBar<int>(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                selectedValue: selectedTab,
                onTabSelected: (val) => ref.read(eventFieldTabProvider.notifier).set(val),
                tabs: [
                  const ModernFilterTab(label: 'Entries', value: 0),
                  ModernFilterTab(
                    label: isTournamentGrouping ? 'The Draw' : 'Tee Time',
                    value: 1,
                  ),
                ],
              ),
            ),
            // Removed manual SizedBox height: AppSpacing.standard (16.0) to avoid stacking with tabToContent
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
}
