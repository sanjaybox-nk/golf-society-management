import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import './event_registrations_admin_screen.dart';

// Reuse the same tab provider for parity
import '../../../events/presentation/tabs/event_user_placeholders.dart';

import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';
import './widgets/admin_grouping_toolbar.dart';
import './widgets/admin_grouping_hub_content.dart';

class EventFieldAdminScreen extends ConsumerWidget {
  final String eventId;

  const EventFieldAdminScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(adminEventsProvider);
    final allMembersAsync = ref.watch(allMembersProvider);
    final competitionAsync = ref.watch(competitionDetailProvider(eventId));
    
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
        final members = allMembersAsync.value ?? [];
        final handicapMap = {for (var m in members) m.id: m.handicap};

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
              if (selectedTab == 1) ...[
                const SizedBox(height: AppSpacing.md),
                AdminGroupingToolbar(
                  event: event,
                  allEvents: events,
                  handicapMap: handicapMap,
                  competition: competitionAsync.value,
                  onReset: () {
                     // Reset logic
                  },
                  onSave: () {
                     // Save logic
                  },
                  onAutoGenerate: () {
                     // Show generation options
                     ref.read(groupingShowGenerationOptionsProvider.notifier).set(true);
                  },
                ),
              ],
            ],
          ),
          slivers: [
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

// Extension methods to be added to the target screens to support Hub integration
extension EventFieldAdminExtensions on Widget {
  // This is a placeholder for the refactoring I'm about to do in the actual screens
  // to support returning slivers instead of a full HeadlessScaffold.
}
