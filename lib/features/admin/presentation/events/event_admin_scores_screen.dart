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
import '../../../events/domain/registration_logic.dart';
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

        // Determining if it is a match play event - check both template and competition rules
        final bool isMatchPlay = (compAsync.value?.rules.isMatchPlay ?? false) || 
                           event.secondaryTemplateId == 'matchplay' || 
                           event.groupingStrategy == 'matchplay';
        final bool isTournamentStyle = compAsync.value?.rules.isTournamentStyleGrouping ?? false;

        final spacing = Theme.of(context).extension<AppSpacingTokens>();
    
        return HeadlessScaffold(
          title: 'Event Scores',
          subtitle: event.title,
          topPill: BoxyArtPill.committee(label: 'ADMIN'),
          showBack: true,
          slivers: [
            // Status & Quick Actions Card
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: _buildStatusCard(context, ref, event),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: spacing?.cardToCard ?? AppSpacing.cardToCard)),

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
                        ModernFilterTab(label: 'Verify', value: 1),
                      ]
                    : const [
                        ModernFilterTab(label: 'Groups', value: 3),
                        ModernFilterTab(label: 'Standings', value: 0),
                        ModernFilterTab(label: 'Verify', value: 1),
                      ],
                ),
              ),
            ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
            title: isMatchPlay ? 'MATCH STANDINGS' : 'LIVE STANDINGS', 
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
        sliver: SliverToBoxAdapter(child: BoxyArtSectionTitle(title: 'TOURNAMENT BRACKET')),
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
            isAdmin: true,
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
        final totalGolfers = RegistrationLogic.getSortedItems(event).length;
        
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
            const BoxyArtSectionTitle(title: 'Summary'),
            Row(
              children: [
                Expanded(child: _buildStatMiniCard('Pending', '${submitted.length}', Theme.of(context).colorScheme.onSurface)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildStatMiniCard('Incomplete', '${incomplete.length}', Theme.of(context).colorScheme.onSurface)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatMiniCard(
                    'Reviewed', 
                    '${reviewed.length} / $totalGolfers', 
                    Theme.of(context).colorScheme.onSurface,
                  )
                ),
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
              const BoxyArtSectionTitle(title: 'Issues to resolve'),
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

  Widget _buildStatMiniCard(String label, String value, Color color, {String? subtitle}) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: AppColors.dark400,
              fontWeight: AppTypography.weightBold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              color: color,
              fontWeight: AppTypography.weightBlack,
              height: 1.0,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.dark300,
                fontSize: 8,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

  Widget _buildStatusCard(BuildContext context, WidgetRef ref, GolfEvent event) {
    final scoringData = ref.watch(eventScoringControllerProvider(event.id));
    
    final int submitted = scoringData.submittedCount;
    final int total = scoringData.totalParticipants;
    final double progress = total > 0 ? (submitted / total) : 0.0;
    
    final bool isLocked = event.isScoringLocked;
    final bool isPublished = event.isStatsReleased;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUBMISSION PROGRESS',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.dark400,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$submitted of $total Scorecards',
                      style: AppTypography.headline.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked)
                BoxyArtPill(
                  label: 'LOCKED',
                  color: AppColors.dark900,
                  textColor: Colors.white,
                  icon: Icons.lock_rounded,
                )
              else if (isPublished)
                BoxyArtPill(
                  label: 'PUBLISHED',
                  color: AppColors.lime600,
                  textColor: Colors.white,
                  icon: Icons.check_circle_rounded,
                )
              else
                BoxyArtPill(
                  label: 'LIVE',
                  color: AppColors.amber500,
                  textColor: Colors.white,
                  icon: Icons.sensors_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              width: double.infinity,
              color: AppColors.dark500,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.lime500, AppColors.lime600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: BoxyArtButton(
                  title: isPublished ? 'Unpublish' : 'Publish Results',
                  icon: isPublished ? Icons.visibility_off_rounded : Icons.campaign_rounded,
                  isPrimary: !isPublished,
                  onTap: () => _togglePublish(ref, event),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BoxyArtButton(
                  title: isLocked ? 'Unlock' : 'Lock Scores',
                  icon: isLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                  isPrimary: false,
                  onTap: () => _toggleLock(ref, event),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 48,
                height: 48,
                child: BoxyArtCircularIconBtn(
                  icon: Icons.notifications_active_rounded,
                  onTap: () => _sendReminders(context, ref, event),
                  backgroundColor: AppColors.amber500,
                  iconColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _togglePublish(WidgetRef ref, GolfEvent event) async {
    final repo = ref.read(eventsRepositoryProvider);
    await repo.updateEvent(event.copyWith(isStatsReleased: !event.isStatsReleased));
  }

  Future<void> _toggleLock(WidgetRef ref, GolfEvent event) async {
    final repo = ref.read(eventsRepositoryProvider);
    await repo.updateEvent(event.copyWith(isScoringLocked: !event.isScoringLocked));
  }

  void _sendReminders(BuildContext context, WidgetRef ref, GolfEvent event) {
    // Logic for sending push notifications/reminders to players with incomplete cards
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminders sent to players with incomplete scorecards.')),
    );
  }
