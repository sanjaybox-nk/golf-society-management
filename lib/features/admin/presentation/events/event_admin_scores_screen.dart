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
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/features/home/presentation/home_providers.dart';
import 'widgets/admin_verify_tab.dart';

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
                sliver: SliverToBoxAdapter(child: _buildStatusCard(context, ref, event)),
              ),
              SliverToBoxAdapter(child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: AdminVerifyTab(
                    event: event,
                    scorecardsAsync: scorecardsAsync,
                    isStableford: compAsync.value?.rules.format == CompetitionFormat.stableford,
                    onUnlockCard: (entryId, markerEntryId, playerName, markerName) =>
                        _confirmUnlock(context, ref, event, entryId, markerEntryId, playerName, markerName),
                  ),
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

  // ---------------------------------------------------------------------------
  // Status card
  // ---------------------------------------------------------------------------

  Widget _buildStatusCard(BuildContext context, WidgetRef ref, GolfEvent event) {
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    final scorecards = scorecardsAsync.value ?? [];

    final int verifiedCount = scorecards.where((s) => s.status == ScorecardStatus.approved).length;
    final int conflictCount = scorecards.where((s) =>
        s.status != ScorecardStatus.approved && s.conflictedHoles.isNotEmpty).length;
    final int readyCount = scorecards.where((s) =>
        s.status != ScorecardStatus.approved &&
        (s.status == ScorecardStatus.finalScore || s.status == ScorecardStatus.reviewed)).length;
    final int fieldCount = scorecards.length - verifiedCount - conflictCount - readyCount;

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
                Expanded(child: _ScoreMetric(label: 'Field', value: '$fieldCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'Conflicts', value: '$conflictCount', isAlert: conflictCount > 0)),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'To Verify', value: '$readyCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _ScoreMetric(label: 'Verified', value: '$verifiedCount', highlight: true)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          _ActionRow(
            label: isPublished ? 'Unpublish' : 'Publish',
            description: isPublished ? 'Hide standings from members' : 'Make final standings visible to all members',
            onTap: () => _togglePublish(ref, event),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionRow(
            label: isLocked ? 'Unlock' : 'Lock',
            description: isLocked ? 'Re-open scores for editing' : 'Finalise all scorecards — no further changes allowed',
            onTap: () => _toggleLock(ref, event),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionRow(
            label: 'Remind',
            description: 'Notify members who have not yet submitted their scorecard',
            onTap: () => _sendReminders(context, ref, event),
          ),
        ],
      ),
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
            onUnlockCard: (entryId, markerEntryId, playerName, markerName) =>
                _confirmUnlock(context, ref, event, entryId, markerEntryId, playerName, markerName),
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

  Future<void> _togglePublish(WidgetRef ref, GolfEvent event) async {
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(isStatsReleased: !event.isStatsReleased));
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
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(
      status: isClosed ? EventStatus.inPlay : EventStatus.completed,
      isScoringLocked: isClosed ? false : true,
    ));
  }

  Future<void> _toggleLock(WidgetRef ref, GolfEvent event) async {
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(isScoringLocked: !event.isScoringLocked));
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
    await BoxyArtBottomSheet.show(
      context: context,
      title: 'Unlock Scorecard',
      child: _UnlockConfirmSheet(
        playerName: playerName,
        markerName: markerName,
        onConfirm: () async {
          Navigator.of(context).pop();
          await _unlockCard(ref, event.id, entryId, markerEntryId, playerName, markerName);
        },
      ),
    );
  }

  Future<void> _unlockCard(WidgetRef ref, String eventId, String entryId, String markerEntryId, String playerName, String markerName) async {
    final repo = ref.read(scorecardRepositoryProvider);
    final scorecards = ref.read(scorecardsListProvider(eventId)).value ?? [];
    final playerCard = scorecards.firstWhereOrNull((s) => s.entryId == entryId);
    final markerCard = scorecards.firstWhereOrNull((s) => s.entryId == markerEntryId);
    if (playerCard != null) await repo.updateScorecard(playerCard.copyWith(status: ScorecardStatus.draft, verifiedByPlayer: false, verifiedByMarker: false, updatedAt: DateTime.now()));
    if (markerCard != null) await repo.updateScorecard(markerCard.copyWith(status: ScorecardStatus.draft, verifiedByPlayer: false, verifiedByMarker: false, updatedAt: DateTime.now()));
    _sendUnlockNotifications(ref, eventId, entryId, markerEntryId, playerName, markerName);
  }

  void _sendUnlockNotifications(WidgetRef ref, String eventId, String entryId, String markerEntryId, String playerName, String markerName) {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final now = DateTime.now();
      repo.sendNotification(AppNotification(id: '', recipientId: entryId.replaceAll('_guest', ''), title: 'Scorecard Unlocked', message: 'An admin has unlocked your scorecard. Please review your scores and re-verify.', timestamp: now, category: 'Scoring', eventId: eventId));
      final markerMemberId = markerEntryId.replaceAll('_guest', '');
      if (markerMemberId != entryId.replaceAll('_guest', '')) {
        repo.sendNotification(AppNotification(id: '', recipientId: markerMemberId, title: 'Scorecard Unlocked', message: 'An admin has unlocked $playerName\'s scorecard. Please re-verify their scores.', timestamp: now, category: 'Scoring', eventId: eventId));
      }
    } catch (_) {}
  }

  void _sendReminders(BuildContext context, WidgetRef ref, GolfEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminders sent to players with incomplete scorecards.')));
  }
}

// ── Unlock Confirm Sheet ───────────────────────────────────────────────────────

class _UnlockConfirmSheet extends StatefulWidget {
  final String playerName;
  final String markerName;
  final Future<void> Function() onConfirm;

  const _UnlockConfirmSheet({required this.playerName, required this.markerName, required this.onConfirm});

  @override
  State<_UnlockConfirmSheet> createState() => _UnlockConfirmSheetState();
}

class _UnlockConfirmSheetState extends State<_UnlockConfirmSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.playerName.split(' ').first;
    final hasMarker = widget.markerName.isNotEmpty;
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_open_rounded, color: AppColors.amber500, size: AppShapes.iconSmall),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  hasMarker
                      ? 'This will reset verification for $firstName and their marker (${widget.markerName}). Both will need to re-verify before the card can be approved again.'
                      : 'This will reset verification for $firstName. They will need to re-verify before the card can be approved again.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.amber500),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          BoxyArtButton(
            title: _loading ? 'Unlocking…' : 'Unlock ${widget.playerName}',
            icon: Icons.lock_open_rounded,
            isPrimary: true,
            fullWidth: true,
            onTap: _loading ? null : () async { setState(() => _loading = true); await widget.onConfirm(); },
          ),
        ],
      ),
    );
  }
}

// ── Score metric ──────────────────────────────────────────────────────────────

class _ScoreMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool isAlert;

  const _ScoreMetric({required this.label, required this.value, this.highlight = false, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color valueColor = isAlert && value != '0' ? AppColors.coral500 : highlight && value != '0' ? AppColors.lime500 : (isDark ? AppColors.pureWhite : AppColors.dark900);
    final Color labelColor = isAlert && value != '0' ? AppColors.coral500 : highlight && value != '0' ? AppColors.lime500 : AppColors.dark400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: AppTypography.micro.copyWith(color: labelColor, fontWeight: AppTypography.weightBold, letterSpacing: AppTypography.lsLabel)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.displaySection.copyWith(color: valueColor, fontWeight: AppTypography.weightBold, height: 1.0)),
        ],
      ),
    );
  }
}

// ── Action row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ActionRow({required this.label, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final primary = Theme.of(context).colorScheme.primary;
    final radius = shapes?.button ?? BorderRadius.circular(8);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 160,
          child: Material(
            color: primary.withValues(alpha: AppColors.opacityLow),
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              highlightColor: primary.withValues(alpha: AppColors.opacitySubtle),
              splashColor: primary.withValues(alpha: AppColors.opacitySubtle),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: Text(label.toUpperCase(), style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold, color: primary, letterSpacing: AppTypography.lsLabel))),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(description, style: AppTypography.micro.copyWith(color: isDark ? AppColors.dark300 : AppColors.dark400, height: 1.4))),
      ],
    );
  }
}
