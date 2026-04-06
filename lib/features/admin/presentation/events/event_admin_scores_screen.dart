import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';

import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/presentation/widgets/event_leaderboard.dart';
import '../../../events/presentation/widgets/scorecard_modal.dart';
import '../../../events/presentation/tabs/event_user_placeholders.dart';
import 'package:golf_society/domain/models/competition.dart';

class AdminScoresTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int value) => state = value;
}

final adminScoresTabProvider = NotifierProvider<AdminScoresTabNotifier, int>(AdminScoresTabNotifier.new);

class EventAdminScoresScreen extends ConsumerWidget {
  final String eventId;
  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(adminScoresTabProvider);
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventAsync.when(
      data: (event) {
        
        // Note: Optimistic toggles were removed during the conversion to ConsumerWidget
        // to resolve a potential type stability issue. They can be re-implemented
        // using a specialized provider if needed.

        return HeadlessScaffold(
          title: 'Scores',
          subtitle: event.title,

          showBack: true,
          onBack: () => context.go('/admin/events'),
          actions: const [],
          slivers: [
            SliverToBoxAdapter(
              child: ModernUnderlinedFilterBar<int>(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                isExpanded: true,
                selectedValue: selectedTab,
                onTabSelected: (val) => ref.read(adminScoresTabProvider.notifier).set(val),
                tabs: const [
                  ModernFilterTab(label: 'Leaderboard', value: 0),
                  ModernFilterTab(label: 'Groups', value: 1),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: _buildTabContent(context, ref, event, selectedTab, scorecardsAsync),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Loading...', slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (err, st) => HeadlessScaffold(title: 'Error', slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))]),
    );
  }


  Widget _buildTabContent(BuildContext context, WidgetRef ref, GolfEvent event, int selectedTab, AsyncValue<List<Scorecard>> scorecardsAsync) {
    final membersAsync = ref.watch(allMembersProvider);
    switch (selectedTab) {
      case 0: // Leaderboard
        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'Live standings'),
            scorecardsAsync.when(
              data: (scorecards) => EventLeaderboard(
                event: event,
                comp: ref.watch(competitionDetailProvider(event.id)).value,
                liveScorecards: scorecards,
                membersList: membersAsync.value ?? [],
                showTitles: false, 
                onPlayerTap: (entry) {
                  ScorecardModal.show(
                    context, 
                    ref, 
                    entry: entry, 
                    scorecards: scorecards, 
                    event: event, 
                    comp: ref.watch(competitionDetailProvider(event.id)).value,
                    membersList: membersAsync.value ?? [],
                    isAdmin: true,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error loading leaderboard: $e')),
            ),
          ],
        );
      case 1: // Group Scores
        return Column(
          children: [
            SharedTournamentLogic.buildGroupScoresTab(
              ref: ref,
              eventId: event.id,
              event: event,
              rules: ref.watch(competitionDetailProvider(event.id)).value?.rules ?? const CompetitionRules(),
              playerHoleLimits: const {},
              teeOverrides: const {},
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
