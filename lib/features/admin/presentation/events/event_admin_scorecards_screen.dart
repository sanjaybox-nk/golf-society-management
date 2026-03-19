import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../events/presentation/events_provider.dart';
import 'widgets/admin_scorecard_list.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../competitions/presentation/competitions_provider.dart';

class EventAdminScorecardsScreen extends ConsumerWidget {
  final String eventId;
  const EventAdminScorecardsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
    final membersAsync = ref.watch(allMembersProvider);

    return eventAsync.when(
      data: (event) => HeadlessScaffold(
        title: 'Scorecard Management',
        subtitle: event.title,
        showBack: true,
        onBack: () => context.pop(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   BoxyArtSectionTitle(
                    title: 'PLAYER SCORECARDS (${RegistrationLogic.getPlayingParticipants(event).length})',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  scorecardsAsync.when(
                    data: (scorecards) => AdminScorecardList(
                      event: event,
                      scorecards: scorecards,
                      membersList: membersAsync.value ?? [],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      loading: () => const HeadlessScaffold(
        title: 'Loading...',
        slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (e, s) => HeadlessScaffold(
        title: 'Error',
        slivers: [SliverFillRemaining(child: Center(child: Text('Error: $e')))],
      ),
    );
  }
}
