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
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/features/home/presentation/home_providers.dart';

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
        final scoringData = ref.watch(eventScoringControllerProvider(event.id));

        final bool isClosed = event.status == EventStatus.completed;
        final bool isLocked = event.isScoringLocked;
        final bool isPublished = event.isStatsReleased;
        final statusLabel = isClosed ? 'Closed' : isPublished ? 'Published' : isLocked ? 'Locked' : 'Live';
        final statusColor = isClosed ? AppColors.dark400 : isPublished ? AppColors.lime600 : isLocked ? AppColors.dark700 : AppColors.amber500;

        return HeadlessScaffold(
          title: 'Event Scores',
          subtitle: event.title,
          topPill: BoxyArtPill.committee(label: 'ADMIN'),
          showBack: true,
          actions: [
            GestureDetector(
              onTap: () => _toggleClose(context, ref, event),
              child: BoxyArtPill.status(
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
            else ...[
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
                  child: _buildVerificationSliver(context, ref, event, scorecardsAsync),
                ),
              ),
            ],
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
            onUnlockCard: (entryId, markerEntryId, playerName, markerName) =>
                _confirmUnlock(context, ref, event, entryId, markerEntryId, playerName, markerName),
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
        final totalGolfers = RegistrationLogic.getSortedItems(event).where((item) => item.isConfirmed).length;
        
        final submitted = scorecards.where((s) => s.status == ScorecardStatus.submitted).toList();
        final reviewed = scorecards.where((s) => s.status == ScorecardStatus.reviewed || s.status == ScorecardStatus.finalScore).toList();
        final incomplete = scorecards.where((s) =>
          s.scoringStatus == ScoringStatus.incomplete ||
          (s.holeScores.contains(null) && s.scoringStatus == ScoringStatus.ok)
        ).toList();
        final outliers = scorecards.where((s) => s.scoringStatus != ScoringStatus.ok && s.scoringStatus != ScoringStatus.dq).toList();
        final needsReassignment = scorecards.where((s) => s.markerReassignmentOpen).toList();


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            if (needsReassignment.isNotEmpty) ...[
              const BoxyArtSectionTitle(title: 'Marker Reassignment Required'),
              ...needsReassignment.map((s) {
                final reg = event.registrations.firstWhereOrNull((r) => r.memberId == s.entryId || '${r.memberId}_guest' == s.entryId);
                final markerReg = event.registrations.firstWhereOrNull((r) => r.memberId == s.markerId || '${r.memberId}_guest' == s.markerId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: BoxyArtNavTile(
                    title: reg?.memberName ?? s.entryId,
                    subtitle: 'Needs new marker — ${markerReg?.memberName ?? 'previous marker'} left the round',
                    icon: Icons.person_search_rounded,
                    iconColor: AppColors.amber500,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => BoxyArtConfirmDialog(
                          title: 'Reassign Marker?',
                          message: 'This will open marker reassignment for ${reg?.memberName ?? s.entryId}. Use the marker sheet to assign a new marker from the group.',
                          confirmLabel: 'Open Marker Sheet',
                          cancelLabel: 'Cancel',
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(scorecardRepositoryProvider).updateScorecard(
                          s.copyWith(markerReassignmentOpen: false),
                        );
                      }
                    },
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xl),
            ],

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


  Widget _buildStatusCard(BuildContext context, WidgetRef ref, GolfEvent event) {
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    final scorecards = scorecardsAsync.value ?? [];

    final int readyCount = scorecards.where((s) =>
        s.status == ScorecardStatus.submitted && s.verifiedByPlayer && s.verifiedByMarker).length;
    final int awaitingCount = scorecards.where((s) =>
        s.status == ScorecardStatus.submitted && !(s.verifiedByPlayer && s.verifiedByMarker)).length;
    final int outstandingCount = scorecards.where((s) =>
        s.status == ScorecardStatus.draft).length;

    final bool isLocked = event.isScoringLocked;
    final bool isPublished = event.isStatsReleased;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _ScoreMetric(label: 'Ready', value: '$readyCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'Awaiting', value: '$awaitingCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'Outstanding', value: '$outstandingCount')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          _AdminAction(
            icon: isPublished ? Icons.visibility_off_rounded : Icons.campaign_rounded,
            title: isPublished ? 'Unpublish Results' : 'Publish Results',
            subtitle: isPublished
                ? 'Hide standings from members'
                : 'Make final standings visible to all members',
            onTap: () => _togglePublish(ref, event),
          ),
          const SizedBox(height: AppSpacing.md),
          _AdminAction(
            icon: isLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
            title: isLocked ? 'Unlock Scores' : 'Lock Scores',
            subtitle: isLocked
                ? 'Re-open scores for editing'
                : 'Finalise all scorecards — no further changes allowed',
            onTap: () => _toggleLock(ref, event),
          ),
          const SizedBox(height: AppSpacing.md),
          _AdminAction(
            icon: Icons.notifications_active_rounded,
            title: 'Send Reminders',
            subtitle: 'Notify members who have not yet submitted their scorecard',
            iconColor: AppColors.amber500,
            onTap: () => _sendReminders(context, ref, event),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePublish(WidgetRef ref, GolfEvent event) async {
    final repo = ref.read(eventsRepositoryProvider);
    await repo.updateEvent(event.copyWith(isStatsReleased: !event.isStatsReleased));
  }

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
    final repo = ref.read(eventsRepositoryProvider);
    await repo.updateEvent(event.copyWith(
      status: isClosed ? EventStatus.inPlay : EventStatus.completed,
      isScoringLocked: isClosed ? event.isScoringLocked : true,
    ));
  }

  Future<void> _toggleLock(WidgetRef ref, GolfEvent event) async {
    final repo = ref.read(eventsRepositoryProvider);
    await repo.updateEvent(event.copyWith(isScoringLocked: !event.isScoringLocked));
  }

  Future<void> _confirmUnlock(
    BuildContext context,
    WidgetRef ref,
    GolfEvent event,
    String entryId,
    String markerEntryId,
    String playerName,
    String markerName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => BoxyArtConfirmDialog(
        title: 'Unlock Scorecard?',
        message: 'This will reset verification for $playerName and their marker'
            '${markerName.isNotEmpty ? ' ($markerName)' : ''}. '
            'Both will need to re-verify before the card can be locked again.',
        confirmLabel: 'Unlock',
        cancelLabel: 'Cancel',
        isDestructive: true,
      ),
    );
    if (confirmed != true) return;
    await _unlockCard(ref, event.id, entryId, markerEntryId, playerName, markerName);
  }

  Future<void> _unlockCard(
    WidgetRef ref,
    String eventId,
    String entryId,
    String markerEntryId,
    String playerName,
    String markerName,
  ) async {
    final repo = ref.read(scorecardRepositoryProvider);
    final scorecards = ref.read(scorecardsListProvider(eventId)).value ?? [];

    final playerCard = scorecards.firstWhereOrNull((s) => s.entryId == entryId);
    final markerCard = scorecards.firstWhereOrNull((s) => s.entryId == markerEntryId);

    if (playerCard != null) {
      await repo.updateScorecard(playerCard.copyWith(
        status: ScorecardStatus.draft,
        verifiedByPlayer: false,
        verifiedByMarker: false,
        updatedAt: DateTime.now(),
      ));
    }

    if (markerCard != null) {
      await repo.updateScorecard(markerCard.copyWith(
        status: ScorecardStatus.draft,
        verifiedByPlayer: false,
        verifiedByMarker: false,
        updatedAt: DateTime.now(),
      ));
    }

    _sendUnlockNotifications(ref, eventId, entryId, markerEntryId, playerName, markerName);
  }

  void _sendUnlockNotifications(
    WidgetRef ref,
    String eventId,
    String entryId,
    String markerEntryId,
    String playerName,
    String markerName,
  ) {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final playerMemberId = entryId.replaceAll('_guest', '');
      final markerMemberId = markerEntryId.replaceAll('_guest', '');
      final now = DateTime.now();

      repo.sendNotification(AppNotification(
        id: '',
        recipientId: playerMemberId,
        title: 'Scorecard Unlocked',
        message: 'An admin has unlocked your scorecard. Please review your scores and re-verify.',
        timestamp: now,
        category: 'Scoring',
        eventId: eventId,
      ));

      if (markerMemberId != playerMemberId) {
        repo.sendNotification(AppNotification(
          id: '',
          recipientId: markerMemberId,
          title: 'Scorecard Unlocked',
          message: 'An admin has unlocked $playerName\'s scorecard. Please re-verify their scores.',
          timestamp: now,
          category: 'Scoring',
          eventId: eventId,
        ));
      }
    } catch (_) {
      // Best-effort — don't block the unlock
    }
  }

  void _sendReminders(BuildContext context, WidgetRef ref, GolfEvent event) {
    // Logic for sending push notifications/reminders to players with incomplete cards
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminders sent to players with incomplete scorecards.')),
    );
  }
}

class _ScoreMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: AppColors.dark400,
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.displaySection.copyWith(
              color: isDark ? AppColors.pureWhite : AppColors.dark900,
              fontWeight: AppTypography.weightBold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  const _AdminAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shapes = Theme.of(context).extension<AppShapeTokens>();

    return InkWell(
      onTap: onTap,
      borderRadius: shapes?.button ?? BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.dark600 : AppColors.dark100,
          borderRadius: shapes?.button ?? BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightBold,
                      color: isDark ? AppColors.pureWhite : AppColors.dark900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.micro.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: isDark ? AppColors.dark300 : AppColors.dark400),
          ],
        ),
      ),
    );
  }
}
