import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../events/logic/event_scoring_controller.dart';
import '../../../events/presentation/widgets/event_leaderboard.dart';
import '../../../events/presentation/widgets/scorecard_modal.dart';
import '../../../matchplay/presentation/widgets/match_play_bracket_hub.dart';
import '../../../events/presentation/tabs/event_user_placeholders.dart'; // [NEW] For shared GroupScoresView logic

class EventAdminScoresScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminScoresScreen> createState() => _EventAdminScoresScreenState();
}

class _EventAdminScoresScreenState extends ConsumerState<EventAdminScoresScreen> {
  int _selectedTab = 0;

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

        // Determining if it is a match play event - check both template and competition rules
        final isMatchPlay = event.secondaryTemplateId == 'matchplay' || 
                           event.groupingStrategy == 'matchplay' ||
                           compAsync.value?.rules.format == CompetitionFormat.matchPlay;

        final spacing = Theme.of(context).extension<AppSpacingTokens>();
        final config = ref.watch(themeControllerProvider);

        return HeadlessScaffold(
          title: 'Event Scores',
          subtitle: event.title,
          titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
          showBack: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: ModernUnderlinedFilterBar<int>(
                  selectedValue: _selectedTab,
                  isExpanded: false,
                  onTabSelected: (val) => setState(() => _selectedTab = val),
                  tabs: isMatchPlay && config.showMatchPlayOverlay
                    ? [
                        const ModernFilterTab(label: 'Leaderboard', value: 0, icon: Icons.leaderboard_rounded),
                        const ModernFilterTab(label: 'Groups', value: 3, icon: Icons.groups_rounded),
                        const ModernFilterTab(label: 'Bracket', value: 2, icon: Icons.account_tree_rounded),
                        const ModernFilterTab(label: 'Verify', value: 1, icon: Icons.verified_user_rounded),
                      ]
                    : [
                        const ModernFilterTab(label: 'Leaderboard', value: 0, icon: Icons.leaderboard_rounded),
                        const ModernFilterTab(label: 'Groups', value: 3, icon: Icons.groups_rounded),
                        const ModernFilterTab(label: 'Verify', value: 1, icon: Icons.verified_user_rounded),
                      ],
                ),
              ),
            ),
            // Standardized gap from tabs (16.0)
            SliverToBoxAdapter(child: SizedBox(height: spacing?.tabToContent ?? AppSpacing.tabToContent)),

            if (_selectedTab == 0)
              ..._buildStandingsSlivers(context, ref, event, compAsync.value, scorecardsAsync, membersAsync, isMatchPlay: isMatchPlay)
            else if (_selectedTab == 3)
              ..._buildGroupsSlivers(context, event, compAsync.value, scorecardsAsync, membersAsync)
            else if (_selectedTab == 2)
              ..._buildBracketSlivers(context, event)
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: _buildVerificationSliver(context, ref, event, scorecardsAsync),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

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
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        sliver: SliverToBoxAdapter(
          child: BoxyArtSectionTitle(
            title: isMatchPlay ? 'MATCH LEADERBOARD' : 'LIVE LEADERBOARD', 
            topPadding: 0,
          ),
        ),
      ),
      scorecardsAsync.when(
        data: (scorecards) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: EventLeaderboard(
              event: event,
              comp: comp,
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
                  comp: comp,
                  membersList: membersAsync.value ?? [],
                  isAdmin: true,
                );
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
        sliver: SliverToBoxAdapter(child: BoxyArtSectionTitle(title: 'TOURNAMENT BRACKET', topPadding: 0)),
      ),
      SliverFillRemaining(
        hasScrollBody: true,
        child: MatchPlayBracketHub(eventId: event.id),
      ),
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
            teeOverrides: const {}, // Admin views typically don't need personal tee overrides
            onTapParticipant: (p, g) {
              final scoringData = ref.read(eventScoringControllerProvider(event.id));
              final entryId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
              final processedEntry = scoringData.leaderboard.firstWhereOrNull((e) => e.entryId == entryId);
              
              if (processedEntry != null) {
                // Convert ProcessedLeaderboardEntry to LeaderboardEntry (UI Model)
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

                ScorecardModal.show(
                  context, 
                  ref, 
                  entry: uiEntry, 
                  scorecards: scorecardsAsync.value ?? [], 
                  event: event, 
                  comp: comp,
                  membersList: membersAsync.value ?? [],
                  isAdmin: true,
                );
              }
            },
          ),
        ),
      ),
    ];
  }

  Widget _buildVerificationSliver(BuildContext context, WidgetRef ref, GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) {
    final membersAsync = ref.read(allMembersProvider);
    return scorecardsAsync.when(
      data: (scorecards) {
        final totalGolfers = event.registrations.where((r) => r.attendingGolf).length;
        final submitted = scorecards.where((s) => s.status == ScorecardStatus.submitted).toList();
        final reviewed = scorecards.where((s) => s.status == ScorecardStatus.reviewed || s.status == ScorecardStatus.finalScore).toList();
        final incomplete = scorecards.where((s) => 
          s.scoringStatus == ScoringStatus.incomplete || 
          (s.holeScores.contains(null) && s.scoringStatus == ScoringStatus.ok)
        ).toList();
        
        final outliers = scorecards.where((s) => s.scoringStatus != ScoringStatus.ok).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'Summary', isPeeking: true),
            Row(
              children: [
                Expanded(child: _buildStatMiniCard('Pending', '${submitted.length}', AppColors.amber500)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStatMiniCard('Incomplete', '${incomplete.length}', AppColors.coral500)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStatMiniCard('Reviewed', '${reviewed.length} / $totalGolfers', AppColors.lime500)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            if (submitted.isNotEmpty) ...[
              BoxyArtButton(
                title: 'Review All Submitted',
                icon: Icons.done_all_rounded,
                isPrimary: true,
                fullWidth: true,
                onTap: () async {
                  final confirmed = await showBoxyArtDialog<bool>(
                    context: context,
                    title: 'Approve Scorecards?',
                    message: 'This will mark all ${submitted.length} submitted scorecards as Reviewed.',
                    confirmText: 'Approve',
                  );
                  if (confirmed == true) {
                    await ref.read(scorecardRepositoryProvider).approveAllScorecards(event.id);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            if (incomplete.isNotEmpty || outliers.isNotEmpty) ...[
              const BoxyArtSectionTitle(title: 'Issues to resolve', isPeeking: true),
              ...[...incomplete, ...outliers].map((s) {
                 final reg = event.registrations.firstWhereOrNull((r) => r.memberId == s.entryId);
                 return Padding(
                   padding: const EdgeInsets.only(bottom: AppSpacing.md),
                   child: BoxyArtNavTile(
                     title: reg?.memberName ?? 'Unknown Player',
                     subtitle: s.scoringStatus == ScoringStatus.incomplete ? 'Incomplete Card' : s.scoringStatus.name.toUpperCase(),
                     icon: Icons.warning_amber_rounded,
                     iconColor: AppColors.coral500,
                     onTap: () {
                        // Open scorecard modal for editing
                        final comp = ref.read(competitionDetailProvider(event.id)).value;
                        final members = membersAsync.value ?? [];
                        final entry = LeaderboardEntry(
                          entryId: s.entryId,
                          playerName: reg?.memberName ?? 'Unknown',
                          score: (s.points ?? 0).toInt(),
                          handicap: s.playingHandicap ?? (s.handicapIndex ?? 0).round(),
                          handicapIndex: s.handicapIndex ?? 0,
                          scoringStatus: s.scoringStatus,
                          mode: comp?.rules.mode ?? CompetitionMode.singles,
                          avatarUrl: members.firstWhereOrNull((m) => m.id == s.entryId)?.avatarUrl,
                        );
                        ScorecardModal.show(context, ref, entry: entry, scorecards: scorecards, event: event, comp: comp, membersList: members, isAdmin: true);
                     },
                   ),
                 );
              }),
            ] else ...[
               const BoxyArtEmptyCard(
                 title: 'Verification Complete',
                 message: 'No score discrepancies or incomplete cards found. The field is ready for finalization.',
                 icon: Icons.verified_user_outlined,
               ),
            ],
            const SizedBox(height: AppSpacing.hero),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatMiniCard(String label, String value, Color color) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(label, style: AppTypography.micro.copyWith(color: AppColors.textSecondary, fontWeight: AppTypography.weightBold)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.headline.copyWith(color: color)),
        ],
      ),
    );
  }
}
