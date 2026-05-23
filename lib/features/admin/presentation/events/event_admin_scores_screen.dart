import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../events/logic/event_scoring_controller.dart';
import '../../../events/presentation/widgets/event_leaderboard.dart';
import '../../../events/presentation/widgets/scorecard_modal.dart';
import '../../../matchplay/presentation/widgets/match_play_bracket_hub.dart';
import '../../../events/presentation/tabs/event_shared_logic.dart';

class EventAdminScoresScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminScoresScreen> createState() => _EventAdminScoresScreenState();
}

class _EventAdminScoresScreenState extends ConsumerState<EventAdminScoresScreen> {
  int _selectedTab = 3;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(adminEventsProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == widget.eventId);
        if (event == null) return const Center(child: Text('Event not found'));

        final compAsync = ref.watch(competitionDetailProvider(event.id));
        final membersAsync = ref.watch(allMembersProvider);

        final bool isMatchPlay = (compAsync.value?.rules.isMatchPlay ?? false) ||
            event.secondaryTemplateId == 'matchplay' ||
            event.groupingStrategy == 'matchplay';
        final bool isTournamentStyle = compAsync.value?.rules.isTournamentStyleGrouping ?? false;

        final spacing = Theme.of(context).extension<AppSpacingTokens>();

        final bool isClosed = event.status == EventStatus.completed;
        final bool isLocked = event.isScoringLocked;
        final bool isPublished = event.isStatsReleased;
        final statusLabel = isClosed ? 'Closed' : isPublished ? 'Published' : isLocked ? 'Locked' : 'Live';
        final statusColor = isClosed
            ? AppColors.dark400
            : isPublished
                ? AppColors.lime600
                : isLocked
                    ? AppColors.dark700
                    : AppColors.amber500;

        return HeadlessScaffold(
          title: 'Event Scores',
          subtitle: event.title,
          topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
          showBack: true,
          actions: [
            GestureDetector(
              onTap: () => _toggleClose(context, ref, event),
              child: BoxyArtIndicator.status(
                label: statusLabel,
                color: statusColor,
                hasHorizontalMargin: false,
                isLegend: true,
              ),
            ),
          ],
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: BoxyArtTabBar<int>(
                  selectedValue: _selectedTab,
                  onTabSelected: (val) => setState(() => _selectedTab = val),
                  tabs: isTournamentStyle
                      ? const [
                          ModernFilterTab(label: 'Groups', value: 3),
                          ModernFilterTab(label: 'Standings', value: 0),
                          ModernFilterTab(label: 'Bracket', value: 2),
                        ]
                      : const [
                          ModernFilterTab(label: 'Groups', value: 3),
                          ModernFilterTab(label: 'Standings', value: 0),
                        ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: spacing?.tabToContent ?? AppSpacing.tabToContent)),

            if (_selectedTab == 0)
              ..._buildStandingsSlivers(context, ref, event, compAsync.value, scorecardsAsync, membersAsync, isMatchPlay: isMatchPlay)
            else if (_selectedTab == 2)
              ..._buildBracketSlivers(context, event)
            else
              ..._buildGroupsSlivers(context, event, compAsync.value, scorecardsAsync, membersAsync),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  // ---------------------------------------------------------------------------
  // Other tabs
  // ---------------------------------------------------------------------------

  List<Widget> _buildStandingsSlivers(
    BuildContext context,
    WidgetRef ref,
    GolfEvent event,
    Competition? comp,
    AsyncValue<List<Scorecard>> scorecardsAsync,
    AsyncValue<List<Member>> membersAsync, {
    required bool isMatchPlay,
  }) {
    return [
      scorecardsAsync.when(
        data: (scorecards) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: EventLeaderboard(
              event: event,
              comp: comp,
              liveScorecards: scorecards,
              membersList: membersAsync.value ?? [],
              showTitles: true,
              onPlayerTap: (entry) {
                ScorecardModal.show(context, ref, entry: entry, scorecards: scorecards, event: event, comp: comp, membersList: membersAsync.value ?? [], isAdmin: true);
              },
            ),
          ),
        ),
        loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
        error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error loading leaderboard: $e'))),
      ),
    ];
  }

  List<Widget> _buildBracketSlivers(BuildContext context, GolfEvent event) {
    return [
      const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        sliver: SliverToBoxAdapter(child: BoxyArtSectionTitle(title: 'TOURNAMENT BRACKET')),
      ),
      SliverFillRemaining(hasScrollBody: true, child: MatchPlayBracketHub(eventId: event.id)),
    ];
  }

  List<Widget> _buildGroupsSlivers(
    BuildContext context,
    GolfEvent event,
    Competition? comp,
    AsyncValue<List<Scorecard>> scorecardsAsync,
    AsyncValue<List<Member>> membersAsync,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        sliver: SliverToBoxAdapter(
          child: SharedTournamentLogic.buildGroupScoresTab(
            key: ValueKey('admin_groups_${event.id}'),
            ref: ref,
            eventId: event.id,
            event: event,
            rules: comp?.rules ?? const CompetitionRules(),
            playerHoleLimits: const {},
            teeOverrides: const {},
            isAdmin: true,
            onUnlockCard: null,
            onTapParticipant: (p, g) {
              final scoringData = ref.read(eventScoringControllerProvider(event.id));
              final entryId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
              final processedEntry = scoringData.leaderboard.firstWhereOrNull((e) => e.entryId == entryId);
              if (processedEntry != null) {
                final uiEntry = LeaderboardEntry(
                  entryId: processedEntry.entryId,
                  playerName: processedEntry.playerName,
                  score: processedEntry.score,
                  scoreLabel: processedEntry.scoreLabel,
                  handicap: processedEntry.individualPlayingHandicaps.isNotEmpty ? processedEntry.individualPlayingHandicaps.first : 0,
                  handicapIndex: processedEntry.handicapIndex ?? 0.0,
                  playingHandicap: processedEntry.individualPlayingHandicaps.isNotEmpty ? processedEntry.individualPlayingHandicaps.first : 0,
                  holesPlayed: processedEntry.holesPlayed,
                  isGuest: processedEntry.isGuest,
                  teamMemberIds: processedEntry.teamMemberIds,
                  teamMemberNames: processedEntry.teamMemberNames,
                  individualPlayingHandicaps: processedEntry.individualPlayingHandicaps,
                  holeNetScores: processedEntry.holeNetScores,
                  individualHoleScores: processedEntry.individualHoleScores,
                  individualHoleNetScores: processedEntry.individualHoleNetScores,
                  individualHolePoints: processedEntry.individualHolePoints,
                  holeScores: processedEntry.holeScores,
                  holePoints: processedEntry.holePoints,
                  hasSocietyCut: processedEntry.hasSocietyCut,
                  position: processedEntry.position,
                  tieBreakMetrics: processedEntry.tieBreakMetrics,
                  scoringStatus: processedEntry.scoringStatus,
                  tieBreakLabel: processedEntry.tieBreakLabel,
                );
                ScorecardModal.show(context, ref, entry: uiEntry, scorecards: scorecardsAsync.value ?? [], event: event, comp: comp, membersList: membersAsync.value ?? [], isAdmin: true);
              }
            },
          ),
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _toggleClose(BuildContext context, WidgetRef ref, GolfEvent event) async {
    final isClosed = event.status == EventStatus.completed;
    if (!isClosed) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const BoxyArtConfirmDialog(
          title: 'Close Event?',
          message: 'This will archive the event and move it to Past Events for all members. Scores will be locked automatically if not already.',
          confirmLabel: 'Close Event',
          cancelLabel: 'Cancel',
          isDestructive: false,
        ),
      );
      if (confirmed != true) return;
    }
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(
      status: isClosed ? EventStatus.inPlay : EventStatus.completed,
      isScoringLocked: isClosed ? false : true,
    ));
  }

}
