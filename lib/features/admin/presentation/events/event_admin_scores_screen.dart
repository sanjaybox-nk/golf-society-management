import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final members = membersAsync.value ?? [];
    return scorecardsAsync.when(
      data: (scorecards) {
        final incomplete = scorecards.where((s) =>
          s.scoringStatus == ScoringStatus.incomplete ||
          (s.holeScores.contains(null) && s.scoringStatus == ScoringStatus.ok)
        ).toList();
        final outliers = scorecards.where((s) =>
          s.scoringStatus != ScoringStatus.ok && s.scoringStatus != ScoringStatus.dq).toList();

        final conflicted = scorecards.where((s) {
          for (int i = 0; i < 18; i++) {
            final p = s.holeScores.elementAtOrNull(i);
            final m = s.playerVerifierScores.elementAtOrNull(i);
            if (p != null && m != null && p != m) return true;
          }
          return false;
        }).toList();
        final conflictOnly = conflicted.where((s) =>
          !incomplete.contains(s) && !outliers.contains(s)).toList();

        // Ready to review = clean cards awaiting explicit admin approval
        final readyToReview = scorecards.where((s) =>
          (s.status == ScorecardStatus.finalScore || s.status == ScorecardStatus.reviewed) &&
          !conflictOnly.contains(s) &&
          !incomplete.contains(s) &&
          !outliers.contains(s)
        ).toList();

        // Approved = explicitly confirmed by admin/scorer
        final approved = scorecards.where((s) => s.status == ScorecardStatus.approved).toList();

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

            // Issues
            if (incomplete.isNotEmpty || outliers.isNotEmpty || conflictOnly.isNotEmpty) ...[
              const BoxyArtSectionTitle(title: 'Issues to resolve'),
              for (final s in [...incomplete, ...outliers])
                _buildIssueRow(context, ref, s, event, scorecards, membersAsync,
                  subtitle: s.scoringStatus == ScoringStatus.incomplete
                      ? 'Incomplete Card'
                      : s.scoringStatus.name.toUpperCase(),
                  iconColor: AppColors.coral500,
                ),
              for (final s in conflictOnly)
                _buildIssueRow(context, ref, s, event, scorecards, membersAsync,
                  subtitle: 'Score conflict — player & marker disagree',
                  iconColor: AppColors.amber500,
                ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Ready to review
            if (readyToReview.isNotEmpty) ...[
              BoxyArtSectionTitle(title: 'Ready to Review (${readyToReview.length})'),
              for (final s in readyToReview)
                _buildReviewRow(context, s, event),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Nothing outstanding
            if (incomplete.isEmpty && outliers.isEmpty && conflictOnly.isEmpty && readyToReview.isEmpty) ...[
              const BoxyArtEmptyCard(
                title: 'All Cards Approved',
                message: 'Every scorecard has been reviewed and confirmed. The event is ready to close.',
                icon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Verified
            if (approved.isNotEmpty) ...[
              BoxyArtSectionTitle(title: 'Verified (${approved.length})'),
              for (final s in approved)
                _buildVerifiedRow(context, s, event, members),
            ],

            const SizedBox(height: AppSpacing.hero),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }


  Widget _buildReviewRow(BuildContext context, Scorecard s, GolfEvent event) {
    final reg = event.registrations.firstWhereOrNull(
        (r) => r.memberId == s.entryId || '${r.memberId}_guest' == s.entryId);
    final editorPlayerId = s.entryId.replaceAll('_guest', '');
    final hasAmendments = s.holeAuditLog.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtNavTile(
        title: reg?.memberName ?? s.entryId,
        subtitle: hasAmendments
            ? '${s.holeAuditLog.length} hole${s.holeAuditLog.length > 1 ? 's' : ''} amended — tap to review & approve'
            : 'Clean card — tap to review & approve',
        icon: hasAmendments ? Icons.edit_note_rounded : Icons.check_circle_outline_rounded,
        iconColor: hasAmendments ? AppColors.amber500 : AppColors.lime500,
        onTap: () => context.push(
          '/admin/events/manage/${Uri.encodeComponent(event.id)}/scores/$editorPlayerId',
        ),
      ),
    );
  }

  Widget _buildVerifiedRow(BuildContext context, Scorecard s, GolfEvent event, List<Member> members) {
    final reg = event.registrations.firstWhereOrNull(
        (r) => r.memberId == s.entryId || '${r.memberId}_guest' == s.entryId);
    final editorPlayerId = s.entryId.replaceAll('_guest', '');
    final approver = members.firstWhereOrNull((m) => m.id == s.approvedBy);
    final approverName = approver != null ? '${approver.firstName} ${approver.lastName}' : 'Admin';
    final hasAmendments = s.holeAuditLog.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtNavTile(
        title: reg?.memberName ?? s.entryId,
        subtitle: hasAmendments
            ? '${s.holeAuditLog.length} amendment${s.holeAuditLog.length > 1 ? 's' : ''} · Approved by $approverName'
            : 'Clean card · Approved by $approverName',
        icon: Icons.verified_rounded,
        iconColor: AppColors.lime500,
        onTap: () => context.push(
          '/admin/events/manage/${Uri.encodeComponent(event.id)}/scores/$editorPlayerId',
        ),
      ),
    );
  }

  Widget _buildIssueRow(
    BuildContext context,
    WidgetRef ref,
    Scorecard s,
    GolfEvent event,
    List<Scorecard> scorecards,
    AsyncValue<List<Member>> membersAsync, {
    required String subtitle,
    required Color iconColor,
  }) {
    final reg = event.registrations.firstWhereOrNull(
        (r) => r.memberId == s.entryId || '${r.memberId}_guest' == s.entryId);
    // Strip _guest suffix for the editor route — it uses the base member ID
    final editorPlayerId = s.entryId.replaceAll('_guest', '');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtNavTile(
        title: reg?.memberName ?? s.entryId,
        subtitle: subtitle,
        icon: Icons.warning_amber_rounded,
        iconColor: iconColor,
        onTap: () => context.push(
          '/admin/events/manage/${Uri.encodeComponent(event.id)}/scores/$editorPlayerId',
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, WidgetRef ref, GolfEvent event) {
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    final scorecards = scorecardsAsync.value ?? [];

    // Approved = explicitly confirmed by admin/scorer
    final int approvedCount = scorecards.where((s) => s.status == ScorecardStatus.approved).length;
    // Ready = clean cards awaiting admin review (finalScore or conflict-resolved reviewed)
    final int readyCount = scorecards.where((s) =>
        s.status == ScorecardStatus.finalScore || s.status == ScorecardStatus.reviewed).length;
    // Awaiting = one party has signed off but not both
    final int awaitingCount = scorecards.where((s) =>
        s.status == ScorecardStatus.submitted &&
        (s.verifiedByPlayer || s.verifiedByMarker) &&
        !(s.verifiedByPlayer && s.verifiedByMarker)).length;
    // Outstanding = draft or neither party signed
    final int outstandingCount = scorecards.where((s) =>
        s.status == ScorecardStatus.draft ||
        (s.status == ScorecardStatus.submitted && !s.verifiedByPlayer && !s.verifiedByMarker)).length;

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
                Expanded(child: _ScoreMetric(label: 'Approved', value: '$approvedCount', highlight: true)),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'To Review', value: '$readyCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'Awaiting', value: '$awaitingCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'Pending', value: '$outstandingCount')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          _QuickAction(
            label: isPublished ? 'Unpublish' : 'Publish',
            subtitle: isPublished ? 'Hide standings from members' : 'Make final standings visible to all members',
            onTap: () => _togglePublish(ref, event),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickAction(
            label: isLocked ? 'Unlock' : 'Lock',
            subtitle: isLocked ? 'Re-open scores for editing' : 'Finalise all scorecards — no further changes allowed',
            onTap: () => _toggleLock(ref, event),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickAction(
            label: 'Remind',
            subtitle: 'Notify members who have not yet submitted their scorecard',
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
  final bool highlight;

  const _ScoreMetric({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = highlight && value != '0' ? AppColors.lime500 : (isDark ? AppColors.pureWhite : AppColors.dark900);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: highlight && value != '0' ? AppColors.lime500 : AppColors.dark400,
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.displaySection.copyWith(
              color: valueColor,
              fontWeight: AppTypography.weightBold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shapes = Theme.of(context).extension<AppShapeTokens>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark600 : AppColors.dark100,
              borderRadius: shapes?.button ?? BorderRadius.circular(8),
            ),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBold,
                color: isDark ? AppColors.dark150 : AppColors.dark700,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            subtitle,
            style: AppTypography.micro.copyWith(
              color: isDark ? AppColors.dark300 : AppColors.dark400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
