import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import '../widgets/grouping_widgets.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../logic/event_scoring_controller.dart';
import 'event_tabs_state.dart';
import 'event_user_registration_tab.dart';
import 'event_shared_logic.dart';
import '../events_provider.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import '../../../members/presentation/profile_provider.dart';

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  final bool isAdminMode;
  const EventGroupingUserTab({super.key, required this.eventId, this.isAdminMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final eventAsync = ref.watch(eventProvider(eventId));
    final membersAsync = ref.watch(allMembersProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventAsync.when(
      data: (event) {
        final List<GolfEvent> allEvents = []; // History will be empty if not in active season
        
        var effectiveEvent = event;
        
        final bool isPublished = effectiveEvent.isGroupingPublished;
        final bool isSocial = effectiveEvent.eventType == EventType.social;
        
        final groupsData = effectiveEvent.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        final user = ref.watch(effectiveUserProvider);
        final isStaff = user.role != MemberRole.member;

        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Event Field and Tee Times',
          showAdminShortcut: false, 
          showBack: true,
          onBack: () => context.go('/events'),

          actions: [
            if (isAdminMode && isStaff)
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                tooltip: 'Manage Pairings',
                onPressed: () => context.push('/admin/events/manage/${event.id}/event/grouping'),
              ),
          ],
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: _FieldHubToggle(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: spacing?.tabToContent ?? AppSpacing.tabToContent)),
            
            if (ref.watch(eventFieldTabProvider) == 0)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: membersAsync.when(
                    data: (members) => EventRegistrationUserTab.buildStaticContent(context, ref, event, members, isAdminMode: isAdminMode),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => BoxyArtEmptyState(
                      title: 'Loading Error',
                      message: 'Error loading member registrations: $error',
                      icon: Icons.error_outline_rounded,
                      isCompact: true,
                    ),
                  ),
                ),
              )
            else
              if (isSocial)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: BoxyArtEmptyCard(
                    title: 'No Pairings',
                    message: 'Social events typically favor a relaxed atmosphere without formal tee times.',
                    icon: Icons.favorite_border_rounded,
                  ),
                )
              else if (!isPublished || groups.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: BoxyArtEmptyCard(
                    title: 'Tee Times Not Published',
                    message: 'Official pairings are currently being finalized. Keep an eye on the clubhouse!',
                    icon: Icons.schedule_rounded,
                  ),
                )
              else
                SliverPadding(
                   padding: EdgeInsets.fromLTRB(
                     AppSpacing.xl, 
                     0, 
                     AppSpacing.xl, 
                     AppSpacing.pageBottom,
                   ),
                   sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                         (context, index) {
                             final group = groups[index];
                             final members = membersAsync.value ?? [];
                             final memberMap = {for (var m in members) m.id: m};
                            final history = allEvents.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
                            final comp = compAsync.value;
                            
                             final scoringData = ref.watch(eventScoringControllerProvider(eventId));
                             final computedEntries = { for (var e in scoringData.leaderboard) e.entryId : e };
                             final Map<String, String> scoreMap = { for (var s in scoringData.individualScores) s.playerId : s.result.label };
                             final Map<String, int> phcMap = { for (var s in scoringData.individualScores) s.playerId : s.playingHandicap.round() };
                             final Map<String, String> thruMap = { for (var s in scoringData.individualScores) if (s.thruLabel != null) s.playerId : s.thruLabel! };
                             final Map<String, String> tieBreakMap = { for (var s in scoringData.individualScores) if (s.tieBreakLabel != null) s.playerId : s.tieBreakLabel! };
                             final Map<String, ScoringStatus> statusMap = { for (var s in scoringData.individualScores) s.playerId : s.scoringStatus };
                             final Map<String, bool> winnerMap = { for (var e in scoringData.leaderboard) e.entryId : e.position == 1 };
                             final allScorecards = scorecardsAsync.asData?.value ?? [];
                             final Map<String, Scorecard> scorecardMap = { for (var s in allScorecards) s.entryId : s };
 
                            final spacing = Theme.of(context).extension<AppSpacingTokens>();

                            return Padding(
                               padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.md),
                               child: GroupingCard(
                                  group: group,
                                  memberMap: memberMap,
                                  history: history,
                                  totalGroups: groups.length,
                                  rules: comp?.rules,
                                  courseConfig: event.courseConfig,
                                  isAdmin: false,
                                  isScoreMode: false,
                                  scoreMap: scoreMap,
                                  phcMap: phcMap,
                                  hcMap: { for (var s in scoringData.individualScores) s.playerId : s.handicapIndex },
                                   scorecardMap: scorecardMap,
                                   tieBreakMap: tieBreakMap,
                                   thruMap: thruMap,
                                   statusMap: statusMap,
                                   winnerMap: winnerMap,
                                   showScoring: event.isGroupingPublished,
                                   computedEntries: computedEntries,
                                   matches: event.matches,
                                   isEventClosed: event.isClosed,
                                   onTapParticipant: (p, g) => SharedTournamentLogic.handleParticipantTap(
                                     context: context,
                                     ref: ref,
                                     event: event,
                                     participant: p,
                                   ),
                                ),
                            );
                         },
                         childCount: groups.length,
                      ),
                   ),
                ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Loading...',
        slivers: [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (err, stack) => HeadlessScaffold(
        title: 'Error',
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: BoxyArtEmptyState(
              title: 'Unexpected Error',
              message: err.toString(),
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldHubToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventFieldTabProvider);

    return BoxyArtTabBar<int>(
      selectedValue: selectedTab,
      onTabSelected: (val) => ref.read(eventFieldTabProvider.notifier).set(val),
      tabs: const [
        ModernFilterTab(label: 'Entries', value: 0),
        ModernFilterTab(label: 'Tee Times', value: 1),
      ],
    );
  }
}

// Placeholder for SharedTournamentLogic if needed locally, but usually it's in results tab.
// I'll import it if I move it to a shared file later.
// For now, I'll assume it's available or moved.
// Actually, it was in the placeholders file. I'll move it to a shared helper file.
