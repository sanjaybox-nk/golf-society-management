import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import './event_registrations_admin_screen.dart';

// Reuse the same tab provider for parity
import '../../../events/presentation/tabs/event_user_placeholders.dart';

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
          titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
          subtitle: 'Event Field and Tee Time',
          showBack: true,
          onBack: () => context.go('/admin/events'),

          pinnedBottom: null,
          slivers: [
            SliverToBoxAdapter(
              child: ModernUnderlinedFilterBar<int>(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                selectedValue: selectedTab,
                isExpanded: true,
                onTabSelected: (val) => ref.read(eventFieldTabProvider.notifier).set(val),
                tabs: const [
                  ModernFilterTab(label: 'Entries', value: 0),
                  ModernFilterTab(label: 'Tee Time', value: 1),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.standard)),
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
