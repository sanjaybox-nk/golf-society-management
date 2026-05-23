import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../events/presentation/widgets/course_info_card.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/features/home/presentation/home_providers.dart';
import 'widgets/admin_scorecard_keypad.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';

// Local provider for the current hole being edited
class AdminEditorHoleNotifier extends Notifier<int> {
  @override
  int build() => 1;
  @override
  set state(int value) => super.state = value;
}

final adminEditorHoleProvider = NotifierProvider.autoDispose<AdminEditorHoleNotifier, int>(AdminEditorHoleNotifier.new);

class EventAdminScorecardEditorScreen extends ConsumerWidget {
  final String eventId;
  final String playerId;

  const EventAdminScorecardEditorScreen({
    super.key,
    required this.eventId,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecard = ref.watch(scorecardByEntryIdProvider((competitionId: eventId, entryId: playerId)));
    final config = ref.watch(themeControllerProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final membersAsync = ref.watch(allMembersProvider);
    final List<Member> members = membersAsync.value ?? [];
    
    final currentHole = ref.watch(adminEditorHoleProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final shapes = Theme.of(context).extension<AppShapeTokens>();

    return eventAsync.when(
      data: (event) => HeadlessScaffold(
        title: _getDisplayName(event, playerId),
        topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
        subtitle: 'Scorecard',
        showBack: true,
 // Nested in EventAdminShell
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.x5l),
            sliver: SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) {
                  final isStableford = comp?.rules.format == CompetitionFormat.stableford;
                  
                  // Calculate PHC for this player
                  final reg = event.registrations.firstWhere(
                    (r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == playerId,
                    orElse: () => event.registrations.firstWhereOrNull((r) => r.memberId == playerId) ?? 
                                  EventRegistration(memberId: playerId, memberName: 'Unknown Player', attendingGolf: true),
                  );
                  
                  final double baseHcp = reg.isGuest 
                    ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                    : (reg.handicap ?? 18.0); 
                    
                  final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                    memberId: reg.memberId, 
                    event: event, 
                    membersList: members,
                  );
                  final playerTeeName = (members.firstWhereOrNull((m) => m.id == reg.memberId)?.gender?.toLowerCase() == 'female')
                      ? (event.selectedFemaleTeeName ?? 'Red')
                      : (event.selectedTeeName ?? 'Yellow');

                  final int phc = scorecard?.playingHandicap ?? HandicapCalculator.calculatePlayingHandicap(
                    handicapIndex: baseHcp,
                    rules: comp?.rules ?? const CompetitionRules(),
                    courseConfig: playerTeeConfig,
                  );

                  // [NEW] Authoritative Calculation for Display
                  final scoringResult = ScoringCalculator.calculate(
                    holeScores: scorecard?.holeScores ?? List.filled(18, null),
                    holes: playerTeeConfig.holes,
                    playingHandicap: phc.toDouble(),
                    format: comp?.rules.format ?? CompetitionFormat.stableford,
                    maxScoreConfig: comp?.rules.maxScoreConfig,
                  );

                  final conflictedHoles = scorecard?.conflictedHoles.toSet() ?? {};
                  final isApproved = scorecard?.status == ScorecardStatus.approved;
                  // Conflicts on an approved card are historical — don't treat as active
                  final hasConflicts = conflictedHoles.isNotEmpty && !isApproved;
                  final markerName = _getMarkerName(event, scorecard?.markerId);
                  final isApprovable = scorecard != null &&
                      scorecard.status != ScorecardStatus.approved &&
                      (scorecard.holeScores.any((s) => s != null && s > 0));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Player Info Row
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                        child: Row(
                          children: [
                            BoxyArtIndicator.hc(label: _formatHcp(baseHcp)),
                            const SizedBox(width: AppSpacing.md),
                            BoxyArtIndicator.phc(label: '$phc'),
                            const Spacer(),
                            BoxyArtIndicator(
                              label: playerTeeName,
                              dotColor: _getTeeColor(playerTeeName, playerTeeConfig.tees),
                              hasHorizontalMargin: false,
                            ),
                          ],
                        ),
                      ),

                      // Conflict banner
                      if (hasConflicts) ...[
                        BoxyArtStatusBanner(
                          color: AppColors.amber500,
                          icon: Icons.warning_amber_rounded,
                          message: '${conflictedHoles.length} hole${conflictedHoles.length > 1 ? 's' : ''} conflict with marker${markerName != null ? ' ($markerName)' : ''}. Conflicted holes are highlighted below.',
                        ),
                      ],

                      // Scorecard Grid — player row with conflicts highlighted, marker row below
                      CourseInfoCard(
                        courseConfig: playerTeeConfig,
                        selectedTeeName: playerTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        holeScores: scoringResult.holeScores,
                        holeNetScores: scoringResult.holeNetScores,
                        holePoints: scoringResult.holePoints,
                        format: comp?.rules.format ?? CompetitionFormat.stableford,
                        maxScoreConfig: comp?.rules.maxScoreConfig,
                        conflictedHoles: conflictedHoles,
                        additionalRows: (scorecard?.verifiedByMarker == true &&
                                (scorecard?.playerVerifierScores.any((s) => s != null && s > 0) ?? false))
                            ? [
                                CourseScoreRow(
                                  playerName: 'MKR',
                                  scores: scorecard!.playerVerifierScores,
                                  // Coral on conflict holes, dimmed on matching — admin sees full picture
                                  color: hasConflicts ? AppColors.amber500 : AppColors.dark300,
                                ),
                              ]
                            : null,
                      ),
                      
                      SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                      
                      // Auto-jump to first conflicted hole
                      Builder(builder: (ctx) {
                        if (conflictedHoles.isNotEmpty && currentHole == 1) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(adminEditorHoleProvider.notifier).state = conflictedHoles.first;
                          });
                        }
                        return const SizedBox.shrink();
                      }),

                      // Approved banner
                      if (isApproved) ...[
                        BoxyArtStatusBanner(
                          color: AppColors.lime500,
                          icon: Icons.verified_rounded,
                          message: 'Card approved${scorecard!.approvedAt != null ? ' · ${_formatTimestamp(scorecard.approvedAt!)}' : ''}',
                        ),
                        if (scorecard.holeAuditLog.isNotEmpty) ...[
                          SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                          _buildAuditLog(context, scorecard.holeAuditLog, members, shapes),
                        ],
                      ],

                      // DQ banner
                      if (scorecard?.scoringStatus == ScoringStatus.dq) ...[
                        SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                        BoxyArtStatusBanner(
                          color: AppColors.coral500,
                          icon: Icons.block_rounded,
                          message: 'Player disqualified${scorecard!.committeeNote != null ? ' — "${scorecard.committeeNote}"' : ''}',
                        ),
                      ],

                      // Committee adjustment banner
                      if ((scorecard?.committeeAdjustment ?? 0) != 0) ...[
                        SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                        BoxyArtStatusBanner(
                          color: AppColors.amber500,
                          icon: Icons.gavel_rounded,
                          message: isStableford
                              ? 'Committee penalty: ${scorecard!.committeeAdjustment > 0 ? '-' : '+'}${scorecard.committeeAdjustment.abs()} point${scorecard.committeeAdjustment.abs() != 1 ? 's' : ''}${scorecard.committeeNote != null ? ' — "${scorecard.committeeNote}"' : ''}'
                              : 'Committee penalty: +${scorecard!.committeeAdjustment} stroke${scorecard.committeeAdjustment != 1 ? 's' : ''}${scorecard.committeeNote != null ? ' — "${scorecard.committeeNote}"' : ''}',
                        ),
                      ],

                      // Action bar
                      if (!isApproved) ...[
                        SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                        Row(children: [
                          Expanded(
                            child: _AdminActionTile(
                              icon: Icons.edit_rounded,
                              label: 'Override',
                              enabled: true,
                              color: hasConflicts ? AppColors.amber500 : null,
                              onTap: () => _showOverrideSheet(context, ref, scorecard, event, conflictedHoles, isStableford, comp, phc, playerTeeConfig, playerTeeName, currentHole),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _AdminActionTile(
                              icon: Icons.gavel_rounded,
                              label: 'Penalty',
                              onTap: () => _showPenaltySheet(context, ref, scorecard, isStableford),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _AdminActionTile(
                              icon: Icons.block_rounded,
                              label: 'DQ',
                              color: AppColors.coral500,
                              onTap: () => _showDQSheet(context, ref, scorecard, event),
                            ),
                          ),
                        ]),
                        if (isApprovable) ...[
                          SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                          BoxyArtButton(
                            title: 'Approve Card',
                            icon: Icons.verified_rounded,
                            isPrimary: true,
                            fullWidth: true,
                            onTap: () => _approveCard(context, ref, scorecard, event),
                          ),
                        ],
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
    );
  }

  Map<int, int> _getHoleScores(Scorecard? card) {
    if (card == null) return {};
    final map = <int, int>{};
    for (int i = 0; i < card.holeScores.length; i++) {
      final score = card.holeScores[i];
      if (score != null) {
        map[i + 1] = score;
      }
    }
    return map;
  }

  Future<void> _persistScoreWithAudit(
    BuildContext context,
    WidgetRef ref,
    int hole,
    int score,
    Scorecard? currentCard,
    GolfEvent event,
    Set<int> conflictedHoles,
  ) async {
    final isConflictedHole = conflictedHoles.contains(hole);
    String reason = 'Admin correction';

    // Prompt for reason when overriding a conflicted hole
    if (isConflictedHole && context.mounted) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => BoxyArtDialog(
          title: 'Resolve Conflict — Hole $hole',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BoxyArtStatusBanner(
                color: AppColors.amber500,
                icon: Icons.edit_note_rounded,
                message: 'Add a note for the member explaining the decision (optional).',
                hasBottomMargin: false,
              ),
              const SizedBox(height: AppSpacing.atomic),
              BoxyArtCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.standard,
                  vertical: AppSpacing.atomic,
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'e.g. "Score confirmed on course"',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.dark300),
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: AppTypography.body,
                  autofocus: true,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          confirmText: 'Confirm',
          cancelText: 'Cancel',
          onConfirm: () => Navigator.of(ctx).pop(true),
          onCancel: () => Navigator.of(ctx).pop(false),
        ),
      );
      if (confirmed != true) return;
      if (controller.text.trim().isNotEmpty) reason = controller.text.trim();
    }

    try {
      final repo = ref.read(scorecardRepositoryProvider);
      final userId = ref.read(currentUserProvider).id;

      final List<int?> scores = List<int?>.from(currentCard?.holeScores ?? List.filled(18, null));
      scores[hole - 1] = score;

      // Always align playerVerifierScores — admin override is authoritative on both
      // rows. Updating only holeScores would create a new conflict on clean cards.
      final List<int?> verifierScores = List<int?>.from(
        currentCard?.playerVerifierScores ?? List.filled(18, null),
      );
      while (verifierScores.length <= hole - 1) { verifierScores.add(null); }
      verifierScores[hole - 1] = score;

      final grossTotal = scores.whereType<int>().fold<int>(0, (a, b) => a + b);

      // Recompute conflicts after the edit — used to determine status advancement.
      final remainingConflicts = Scorecard.computeConflicts(scores, verifierScores).isNotEmpty;

      final newStatus = (!remainingConflicts &&
              (currentCard?.verifiedByPlayer ?? false) &&
              (currentCard?.verifiedByMarker ?? false))
          ? ScorecardStatus.reviewed
          : (currentCard?.status ?? ScorecardStatus.submitted);

      if (currentCard == null) {
        await repo.addScorecard(Scorecard(
          id: '',
          competitionId: eventId,
          roundId: 'round_1',
          entryId: playerId,
          submittedByUserId: userId,
          holeScores: scores,
          playerVerifierScores: verifierScores,
          conflictedHoles: Scorecard.computeConflicts(scores, verifierScores),
          shotAttributions: {},
          grossTotal: grossTotal,
          status: ScorecardStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      } else {
        final previousScore = currentCard.holeScores.elementAtOrNull(hole - 1);
        final updatedAuditLog = previousScore != score
            ? [
                ...currentCard.holeAuditLog,
                HoleAuditEntry(
                  hole: hole,
                  playerScore: previousScore ?? score,
                  markerScore: currentCard.playerVerifierScores.elementAtOrNull(hole - 1) ?? score,
                  resolvedTo: score,
                  reason: reason,
                  editorId: userId,
                  timestamp: DateTime.now(),
                ),
              ]
            : currentCard.holeAuditLog;

        await repo.updateScorecard(currentCard.copyWith(
          holeScores: scores,
          playerVerifierScores: verifierScores,
          conflictedHoles: Scorecard.computeConflicts(scores, verifierScores),
          grossTotal: grossTotal,
          status: newStatus,
          holeAuditLog: updatedAuditLog,
          updatedAt: DateTime.now(),
        ));
      }

      if (context.mounted && newStatus == ScorecardStatus.reviewed) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('All conflicts resolved — card marked as reviewed'),
          backgroundColor: AppColors.lime500,
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving score: $e'), backgroundColor: AppColors.coral500),
      );
    }
  }

  Future<void> _approveCard(BuildContext context, WidgetRef ref, Scorecard card, GolfEvent event) async {
    final playerIsGuest = card.entryId.endsWith('_guest');
    final markerIsGuest = card.markerId?.endsWith('_guest') == true;
    final String message;
    if (playerIsGuest && markerIsGuest) {
      message = 'Both the player and their marker are guests. Scores were recorded on paper cards. Approve this card?';
    } else if (playerIsGuest) {
      message = 'This is a guest player\'s card. Their scores were recorded on a paper card. Approve this card?';
    } else if (markerIsGuest) {
      message = 'The marker for this card is a guest — scores were recorded on a paper card rather than digitally confirmed. Approve this card?';
    } else {
      message = 'Approve this scorecard and mark it as verified?';
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => BoxyArtConfirmDialog(
        title: 'Approve Card',
        message: message,
        confirmLabel: 'Approve',
        cancelLabel: 'Cancel',
      ),
    );
    if (confirmed != true) return;

    try {
      final userId = ref.read(currentUserProvider).id;
      await ref.read(scorecardRepositoryProvider).updateScorecard(card.copyWith(
        status: ScorecardStatus.approved,
        approvedBy: userId,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Notify the player — best effort
      try {
        final playerId = card.entryId.replaceAll('_guest', '');
        final hasAmendments = card.holeAuditLog.isNotEmpty;
        final amendmentNote = hasAmendments
            ? ' ${card.holeAuditLog.length} score amendment${card.holeAuditLog.length > 1 ? 's were' : ' was'} made — tap to view your card.'
            : '';
        await ref.read(notificationsRepositoryProvider).sendNotification(AppNotification(
          id: '',
          recipientId: playerId,
          title: 'Scorecard Verified',
          message: 'Your scorecard for ${event.title} has been verified.$amendmentNote',
          timestamp: DateTime.now(),
          category: 'Scoring',
          eventId: event.id,
          actionUrl: '/events/${event.id}/live?tab=1',
        ));
      } catch (_) {}

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Card approved — player notified'),
          backgroundColor: AppColors.lime500,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving card: $e'), backgroundColor: AppColors.coral500),
      );
    }
  }

  Widget _buildAuditLog(BuildContext context, List<HoleAuditEntry> log, List<Member> members, AppShapeTokens? shapes) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score Amendments', style: AppTypography.labelStrong.copyWith(
            fontWeight: AppTypography.weightBold,
            letterSpacing: AppTypography.lsLabel,
          )),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < log.length; i++) ...[
            if (i > 0) ...[
              const Divider(height: AppSpacing.xl, thickness: 0.5),
            ],
            Builder(builder: (ctx) {
              final entry = log[i];
              final editor = members.firstWhereOrNull((m) => m.id == entry.editorId);
              final editorName = editor != null ? '${editor.firstName} ${editor.lastName}' : 'Admin';
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxyArtNumberBadge(number: entry.hole, size: 32, isRanking: false),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player ${entry.playerScore} · Marker ${entry.markerScore} → resolved to ${entry.resolvedTo}',
                          style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightBold),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '"${entry.reason}"',
                          style: AppTypography.micro.copyWith(color: AppColors.dark400),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Resolved by $editorName · ${_formatTimestamp(entry.timestamp)}',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.dark300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} $h:$m';
  }

  String _getDisplayName(GolfEvent event, String id) {
    // Try exact match first (handles both guest and non-guest IDs)
    final exact = event.registrations.firstWhereOrNull(
      (r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == id,
    );
    if (exact != null) return exact.displayName;

    // For guest IDs, also try matching by base memberId
    if (id.endsWith('_guest')) {
      final baseId = id.replaceAll('_guest', '');
      final byBase = event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
      if (byBase != null) return byBase.guestName ?? byBase.memberName;
    }

    // Try matching by memberId directly (covers cases where _guest suffix is unexpected)
    final byMemberId = event.registrations.firstWhereOrNull((r) => r.memberId == id);
    if (byMemberId != null) return byMemberId.displayName;

    return 'Unknown Player';
  }

  String? _getMarkerName(GolfEvent event, String? markerId) {
    if (markerId == null || markerId.isEmpty) return null;
    try {
      final baseId = markerId.replaceAll('_guest', '');
      final reg = event.registrations.firstWhere(
        (r) => r.memberId == baseId || r.memberId == markerId,
      );
      return reg.displayName;
    } catch (_) {
      return null;
    }
  }

  String _formatHcp(double hcp) {
    return hcp.truncateToDouble() == hcp ? hcp.toInt().toString() : hcp.toStringAsFixed(1);
  }

  Color _getTeeColor(String teeName, [List<TeeConfig>? teeConfigs]) {
    return AppColors.getTeeColor(teeName, teeConfigs);
  }

  // _resolvePlayerCourseConfig removed as we now use ScoringCalculator

  void _showOverrideSheet(
    BuildContext context,
    WidgetRef ref,
    Scorecard? scorecard,
    GolfEvent event,
    Set<int> conflictedHoles,
    bool isStableford,
    Competition? comp,
    int phc,
    CourseConfig playerTeeConfig,
    String playerTeeName,
    int currentHole,
  ) {
    BoxyArtBottomSheet.show(
      context: context,
      title: conflictedHoles.isNotEmpty ? 'Resolve Conflict' : 'Override Score',
      child: _OverrideSheet(
        initialHole: conflictedHoles.isNotEmpty ? conflictedHoles.first : currentHole,
        scores: _getHoleScores(scorecard),
        conflictedHoles: conflictedHoles,
        isStableford: isStableford,
        holes: playerTeeConfig.holes,
        onSetScore: (h, score) =>
            _persistScoreWithAudit(context, ref, h, score, scorecard, event, conflictedHoles),
      ),
    );
  }

  void _showPenaltySheet(
    BuildContext context,
    WidgetRef ref,
    Scorecard? scorecard,
    bool isStableford,
  ) {
    if (scorecard == null) return;
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Committee Penalty',
      child: _PenaltySheet(
        current: scorecard.committeeAdjustment,
        currentNote: scorecard.scoringStatus == ScoringStatus.dq ? null : scorecard.committeeNote,
        isStableford: isStableford,
        onApply: (adjustment, note) async {
          Navigator.of(context).pop();
          await _applyPenalty(context, ref, scorecard, adjustment, note);
        },
      ),
    );
  }

  void _showDQSheet(
    BuildContext context,
    WidgetRef ref,
    Scorecard? scorecard,
    GolfEvent event,
  ) {
    if (scorecard == null) return;
    final isDQ = scorecard.scoringStatus == ScoringStatus.dq;
    BoxyArtBottomSheet.show(
      context: context,
      title: isDQ ? 'Player Disqualified' : 'Disqualify Player',
      child: _DQSheet(
        playerName: _getDisplayName(event, scorecard.entryId),
        isDQ: isDQ,
        currentReason: isDQ ? scorecard.committeeNote : null,
        onConfirm: (reason) async {
          Navigator.of(context).pop();
          await _applyDQ(context, ref, scorecard, reason);
        },
        onRemoveDQ: () async {
          Navigator.of(context).pop();
          await _removeDQ(context, ref, scorecard);
        },
      ),
    );
  }

  Future<void> _removeDQ(BuildContext context, WidgetRef ref, Scorecard card) async {
    try {
      await ref.read(scorecardRepositoryProvider).updateScorecard(card.copyWith(
        scoringStatus: ScoringStatus.ok,
        committeeNote: null,
        updatedAt: DateTime.now(),
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DQ removed'), backgroundColor: AppColors.lime500),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.coral500),
        );
      }
    }
  }

  Future<void> _applyPenalty(
    BuildContext context,
    WidgetRef ref,
    Scorecard card,
    int adjustment,
    String note,
  ) async {
    try {
      await ref.read(scorecardRepositoryProvider).updateScorecard(card.copyWith(
        committeeAdjustment: adjustment,
        committeeNote: note.isNotEmpty ? note : null,
        updatedAt: DateTime.now(),
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(adjustment == 0 ? 'Penalty removed' : 'Committee penalty applied'), backgroundColor: AppColors.amber500),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.coral500),
        );
      }
    }
  }

  Future<void> _applyDQ(
    BuildContext context,
    WidgetRef ref,
    Scorecard card,
    String reason,
  ) async {
    try {
      await ref.read(scorecardRepositoryProvider).updateScorecard(card.copyWith(
        scoringStatus: ScoringStatus.dq,
        status: ScorecardStatus.reviewed,
        committeeNote: reason.isNotEmpty ? reason : 'Disqualified by committee',
        updatedAt: DateTime.now(),
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player disqualified'), backgroundColor: AppColors.coral500),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.coral500),
        );
      }
    }
  }
}

// ── Admin Action Tile ─────────────────────────────────────────────────────────

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool enabled;

  const _AdminActionTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabledColor = isDark ? AppColors.dark500 : AppColors.dark200;
    final effectiveColor = enabled ? (color ?? AppColors.dark600) : disabledColor;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: BoxyArtCard(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.atomic),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: effectiveColor, size: AppShapes.iconSm),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.micro.copyWith(
                  color: effectiveColor,
                  fontWeight: AppTypography.weightStrong,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Override Sheet ────────────────────────────────────────────────────────────

class _OverrideSheet extends StatefulWidget {
  final int initialHole;
  final Map<int, int> scores;
  final Set<int> conflictedHoles;
  final Future<void> Function(int hole, int score) onSetScore;
  final bool isStableford;
  final List<dynamic>? holes;

  const _OverrideSheet({
    required this.initialHole,
    required this.scores,
    required this.conflictedHoles,
    required this.onSetScore,
    required this.isStableford,
    this.holes,
  });

  @override
  State<_OverrideSheet> createState() => _OverrideSheetState();
}

class _OverrideSheetState extends State<_OverrideSheet> {
  int _currentHole = 1;
  Map<int, int> _scores = {};
  Map<int, int> _savedScores = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentHole = widget.initialHole;
    _scores = Map.from(widget.scores);
    _savedScores = Map.from(widget.scores);
  }

  // Save the current hole's score if it changed since last save
  Future<void> _commitCurrentHole() async {
    final score = _scores[_currentHole];
    if (score == null || score == _savedScores[_currentHole]) return;
    if (_saving) return;
    setState(() => _saving = true);
    await widget.onSetScore(_currentHole, score);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _savedScores = {..._savedScores, _currentHole: score};
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.conflictedHoles
        .where((h) => h != _currentHole)
        .toList()
      ..sort();

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.conflictedHoles.isNotEmpty && remaining.isNotEmpty) ...[
            BoxyArtCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_rounded, color: AppColors.coral500, size: AppShapes.iconSmall),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${widget.conflictedHoles.length} conflict${widget.conflictedHoles.length > 1 ? 's' : ''} — holes ${widget.conflictedHoles.join(', ')}. Set the correct score for each.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.coral500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
          ],
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.standard),
            child: AdminScorecardKeypad(
              currentHole: _currentHole,
              scores: _scores,
              conflictedHoles: widget.conflictedHoles,
              isStableford: widget.isStableford,
              holes: widget.holes,
              onHoleChanged: (h) async {
                await _commitCurrentHole();
                if (!mounted) return;
                setState(() => _currentHole = h);
              },
              // ± only updates local state — no save, no dialog on every tap
              onSetScore: (h, score) =>
                  setState(() => _scores = {..._scores, h: score}),
            ),
          ),
        ],
    );
  }
}

// ── Penalty Sheet ─────────────────────────────────────────────────────────────

class _PenaltySheet extends StatefulWidget {
  final int current;
  final String? currentNote;
  final bool isStableford;
  final Future<void> Function(int adjustment, String note) onApply;

  const _PenaltySheet({
    required this.current,
    this.currentNote,
    required this.isStableford,
    required this.onApply,
  });

  @override
  State<_PenaltySheet> createState() => _PenaltySheetState();
}

class _PenaltySheetState extends State<_PenaltySheet> {
  late int _adjustment;
  late TextEditingController _noteController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _adjustment = widget.current;
    _noteController = TextEditingController(text: widget.currentNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = widget.isStableford
        ? (_adjustment == 0 ? 'No penalty' : '−$_adjustment point${_adjustment != 1 ? 's' : ''}')
        : (_adjustment == 0 ? 'No penalty' : '+$_adjustment stroke${_adjustment != 1 ? 's' : ''}');

    return BoxyArtCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepperButton(
                icon: Icons.remove_rounded,
                enabled: _adjustment > 0,
                onTap: () => setState(() => _adjustment--),
              ),
              Column(
                children: [
                  Text(
                    label,
                    style: AppTypography.headline.copyWith(
                      fontWeight: AppTypography.weightBold,
                      color: _adjustment > 0 ? AppColors.coral500 : null,
                    ),
                  ),
                  if (widget.current > 0 && _adjustment != widget.current)
                    Text(
                      'Changed from ${widget.isStableford ? '${widget.current} pts' : '${widget.current} str'}',
                      style: AppTypography.micro.copyWith(color: AppColors.dark300),
                    ),
                ],
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                enabled: true,
                onTap: () => setState(() => _adjustment++),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          TextField(
            controller: _noteController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Reason for penalty (optional)',
              hintStyle: AppTypography.body.copyWith(
                color: isDark ? AppColors.dark400 : AppColors.dark300,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: AppTypography.body,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.standard),
          BoxyArtButton(
            title: _loading
                ? 'Applying…'
                : (_adjustment == 0 ? 'Remove Penalty' : 'Apply Penalty'),
            isPrimary: _adjustment > 0,
            isGhost: _adjustment == 0,
            fullWidth: true,
            onTap: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    await widget.onApply(_adjustment, _noteController.text.trim());
                  },
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtButton(
      title: '',
      icon: icon,
      isGhost: true,
      isSmall: false,
      onTap: enabled ? onTap : null,
    );
  }
}

// ── DQ Sheet ──────────────────────────────────────────────────────────────────

class _DQSheet extends StatefulWidget {
  final String playerName;
  final bool isDQ;
  final String? currentReason;
  final Future<void> Function(String reason) onConfirm;
  final Future<void> Function() onRemoveDQ;

  const _DQSheet({
    required this.playerName,
    required this.onConfirm,
    required this.onRemoveDQ,
    this.isDQ = false,
    this.currentReason,
  });

  @override
  State<_DQSheet> createState() => _DQSheetState();
}

class _DQSheetState extends State<_DQSheet> {
  late final TextEditingController _reasonController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.currentReason ?? '');
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasReason = _reasonController.text.trim().isNotEmpty;
    final firstName = widget.playerName.split(' ').first;

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.isDQ ? Icons.block_rounded : Icons.warning_rounded,
                color: AppColors.coral500,
                size: AppShapes.iconSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.isDQ
                      ? '$firstName is currently disqualified. You can update the reason or remove the DQ.'
                      : 'Disqualifying $firstName removes them from the leaderboard. A reason is required and will be visible to the player.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.coral500),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          TextField(
            controller: _reasonController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: widget.isDQ ? 'Update reason (optional)' : 'Reason for DQ (required)',
              hintStyle: AppTypography.body.copyWith(
                color: isDark ? AppColors.dark400 : AppColors.dark300,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: AppTypography.body,
            maxLines: 2,
            autofocus: !widget.isDQ,
          ),
          const SizedBox(height: AppSpacing.standard),
          BoxyArtButton(
            title: _loading
                ? (widget.isDQ ? 'Updating…' : 'Disqualifying…')
                : (widget.isDQ ? 'Update DQ' : 'Disqualify $firstName'),
            icon: Icons.block_rounded,
            isPrimary: hasReason,
            isGhost: !hasReason,
            backgroundColor: hasReason ? AppColors.coral500 : null,
            textColor: hasReason ? AppColors.pureWhite : null,
            fullWidth: true,
            onTap: (_loading || !hasReason) ? null : () async {
              setState(() => _loading = true);
              await widget.onConfirm(_reasonController.text.trim());
            },
          ),
          if (widget.isDQ) ...[
            const SizedBox(height: AppSpacing.sm),
            BoxyArtButton(
              title: _loading ? 'Removing…' : 'Remove DQ',
              isGhost: true,
              fullWidth: true,
              onTap: _loading ? null : () async {
                setState(() => _loading = true);
                await widget.onRemoveDQ();
              },
            ),
          ],
        ],
      ),
    );
  }
}

