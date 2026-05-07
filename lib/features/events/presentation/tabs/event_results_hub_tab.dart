import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../widgets/event_leaderboard.dart';
import '../widgets/scorecard_modal.dart';
import '../state/marker_selection_provider.dart';
import 'event_tabs_state.dart';
import 'event_shared_logic.dart';
import 'event_stats_tab.dart';
import '../../logic/event_scoring_controller.dart';
import '../widgets/submission_progress_bar.dart';

class TournamentScoresUserTab extends ConsumerWidget {
  final String eventId;
  const TournamentScoresUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final eventAsync = ref.watch(eventProvider(eventId));
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final currentTab = ref.watch(eventScoresHubTabProvider);

    return eventAsync.when(
      data: (event) {
        return compAsync.when(
          data: (comp) {
            final rules = comp?.rules ?? const CompetitionRules();
            final effectiveRules = rules;
            
            final int activeTab = (currentTab == 1 || currentTab == 2) ? currentTab : 1;
            
            return HeadlessScaffold(
              title: event.title,
              subtitle: 'Event Scores',
              showBack: true,
              onBack: () => context.go('/events'),

              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: _ScoresHubToggle(event: event),
                  ),
                ),
                
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl, 
                    right: AppSpacing.xl,
                    top: spacing?.tabToContent ?? AppSpacing.tabToContent,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Builder(builder: (context) {
                      final scoringData = ref.watch(eventScoringControllerProvider(eventId));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (scoringData.totalParticipants > 0)
                            SubmissionProgressBar(
                              total: scoringData.totalParticipants,
                              submitted: scoringData.submittedCount,
                              inProgress: scoringData.inProgressCount,
                            ),
                          if (activeTab == 1)
                            Builder(builder: (context) {
                              final markerSelection = ref.watch(markerSelectionProvider);
                              return _TournamentGroupScoresView(
                                event: event, 
                                rules: effectiveRules, 
                                markerSelection: markerSelection,
                                followsCard: scoringData.totalParticipants > 0,
                              );
                            })
                          else
                            Builder(builder: (context) {
                              final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
                              final membersAsync = ref.watch(allMembersProvider);
                              return scorecardsAsync.when(
                                data: (scorecards) {
                                  final comp = compAsync.value;
                                  return EventLeaderboard(
                                    event: event, 
                                    comp: comp, 
                                    liveScorecards: scorecards, 
                                    membersList: membersAsync.value ?? [], 
                                    playerHoleLimits: const {},
                                    followsCard: scoringData.totalParticipants > 0,
                                    onPlayerTap: (entry) => ScorecardModal.show(
                                      context, ref, 
                                      entry: entry, 
                                      scorecards: scorecards, 
                                      event: event, 
                                      comp: comp, 
                                      membersList: membersAsync.value ?? [], 
                                      holeLimit: null, 
                                      teeOverrides: ref.read(markerSelectionProvider).teeOverrides,
                                    ),
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (e, s) => Center(child: Text(e.toString())),
                              );
                            }),
                        ],
                      );
                    }),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading competition: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading event: $e')),
    );
  }
}

class _TournamentGroupScoresView extends ConsumerStatefulWidget {
  final GolfEvent event;
  final CompetitionRules rules;
  final MarkerSelection markerSelection;
  final bool followsCard;

  const _TournamentGroupScoresView({
    required this.event,
    required this.rules,
    required this.markerSelection,
    this.followsCard = true,
  });

  @override
  ConsumerState<_TournamentGroupScoresView> createState() => __TournamentGroupScoresViewState();
}

class __TournamentGroupScoresViewState extends ConsumerState<_TournamentGroupScoresView> {
  @override
  Widget build(BuildContext context) {
    return SharedTournamentLogic.buildGroupScoresTab(
      ref: ref,
      eventId: widget.event.id,
      event: widget.event,
      rules: widget.rules,
      playerHoleLimits: const {},
      teeOverrides: widget.markerSelection.teeOverrides,
      followsCard: widget.followsCard,
      onTapParticipant: (p, g) => SharedTournamentLogic.handleParticipantTap(
        context: context,
        ref: ref,
        event: widget.event,
        participant: p,
      ),
    );
  }
}

class _ScoresHubToggle extends ConsumerWidget {
  final GolfEvent event;

  const _ScoresHubToggle({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventScoresHubTabProvider);

    const tabs = <ModernFilterTab<int>>[
      ModernFilterTab(label: 'Groups', value: 1),
      ModernFilterTab(label: 'Standings', value: 2),
    ];

    return BoxyArtTabBar<int>(
      selectedValue: (selectedTab == 1 || selectedTab == 2) ? selectedTab : 1,
      onTabSelected: (val) => ref.read(eventScoresHubTabProvider.notifier).set(val),
      tabs: tabs,
    );
  }
}

class EventStatsUserTab extends ConsumerWidget {
  final String eventId;
  const EventStatsUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventAsync.when(
      data: (event) {
        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Event Stats',
          showAdminShortcut: false, 
          showBack: true,
          onBack: () => context.go('/events'),

          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
            SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) => scorecardsAsync.when(
                  data: (scorecards) => Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.pageBottom),
                    child: EventStatsTab(
                      eventId: event.id,
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
