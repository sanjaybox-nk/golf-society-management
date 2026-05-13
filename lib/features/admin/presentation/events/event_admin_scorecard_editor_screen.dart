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
        title: 'Scorecard Editor',
        topPill: BoxyArtPill.committee(label: 'ADMIN'),
        subtitle: _getDisplayName(event, playerId),
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

                  final int phc = HandicapCalculator.calculatePlayingHandicap(
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

                  // Detect conflicted holes (player ≠ marker)
                  final markerScores = scorecard?.playerVerifierScores ?? [];
                  final conflictedHoles = <int>{};
                  for (int i = 0; i < 18; i++) {
                    final p = scorecard?.holeScores.elementAtOrNull(i);
                    final m = markerScores.elementAtOrNull(i);
                    if (p != null && m != null && p != m) conflictedHoles.add(i + 1);
                  }
                  final hasConflicts = conflictedHoles.isNotEmpty;
                  final markerName = _getMarkerName(event, scorecard?.markerId);
                  final isApproved = scorecard?.status == ScorecardStatus.approved;
                  final isApprovable = !hasConflicts && scorecard != null &&
                      (scorecard.status == ScorecardStatus.finalScore ||
                       scorecard.status == ScorecardStatus.reviewed);

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
                            BoxyArtIndicator.phc(context: context, label: '$phc'),
                            const Spacer(),
                            BoxyArtPill.tee(label: playerTeeName, teeColor: _getTeeColor(playerTeeName, playerTeeConfig.tees)),
                          ],
                        ),
                      ),

                      // Conflict banner
                      if (hasConflicts) ...[
                        _StatusBanner(
                          color: AppColors.amber500,
                          icon: Icons.warning_amber_rounded,
                          message: '${conflictedHoles.length} hole${conflictedHoles.length > 1 ? 's' : ''} conflict with marker${markerName != null ? ' ($markerName)' : ''}. Conflicted holes are highlighted below.',
                          shapes: shapes,
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
                        additionalRows: hasConflicts ? [
                          CourseScoreRow(
                            playerName: 'MKR',
                            scores: markerScores,
                            color: AppColors.amber500,
                          ),
                        ] : null,
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
                        _StatusBanner(
                          color: AppColors.lime500,
                          icon: Icons.verified_rounded,
                          message: 'Card approved${scorecard!.approvedAt != null ? ' · ${_formatTimestamp(scorecard.approvedAt!)}' : ''}',
                          shapes: shapes,
                        ),
                        if (scorecard!.holeAuditLog.isNotEmpty) ...[
                          SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                          _buildAuditLog(context, scorecard.holeAuditLog, members, shapes),
                        ],
                      ],

                      // Admin Keypad (hidden when approved)
                      if (!isApproved) ...[
                        BoxyArtCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: AdminScorecardKeypad(
                            currentHole: currentHole,
                            scores: _getHoleScores(scorecard),
                            onHoleChanged: (h) => ref.read(adminEditorHoleProvider.notifier).state = h,
                            onSetScore: (h, score) => _persistScoreWithAudit(context, ref, h, score, scorecard, event, conflictedHoles),
                          ),
                        ),
                        if (isApprovable) ...[
                          SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                          BoxyArtButton(
                            title: 'Approve Card',
                            icon: Icons.verified_rounded,
                            isPrimary: true,
                            fullWidth: true,
                            onTap: () => _approveCard(context, ref, scorecard!, event),
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
        builder: (ctx) => AlertDialog(
          title: Text('Resolve Conflict — Hole $hole'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Reason (e.g. "Player confirmed correct")',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
          ],
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

      // Align playerVerifierScores for this hole so the conflict clears
      final List<int?> verifierScores = List<int?>.from(
        currentCard?.playerVerifierScores ?? List.filled(18, null),
      );
      while (verifierScores.length <= hole - 1) verifierScores.add(null);
      if (isConflictedHole) verifierScores[hole - 1] = score;

      final grossTotal = scores.whereType<int>().fold<int>(0, (a, b) => a + b);

      // Check if all conflicts are now resolved → advance to reviewed
      final remainingConflicts = conflictedHoles.where((h) => h != hole).any((h) {
        final hIdx = h - 1;
        final p = scores.elementAtOrNull(hIdx);
        final m = verifierScores.elementAtOrNull(hIdx);
        return p != null && m != null && p != m;
      });

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
          shotAttributions: {},
          grossTotal: grossTotal,
          status: ScorecardStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      } else {
        final updatedAuditLog = isConflictedHole
            ? [
                ...currentCard.holeAuditLog,
                HoleAuditEntry(
                  hole: hole,
                  playerScore: currentCard.holeScores.elementAtOrNull(hole - 1) ?? score,
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
    try {
      final userId = ref.read(currentUserProvider).id;
      await ref.read(scorecardRepositoryProvider).updateScorecard(card.copyWith(
        status: ScorecardStatus.approved,
        approvedBy: userId,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Card approved'),
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
                  Container(
                    width: 32, height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
                      borderRadius: shapes?.accent ?? BorderRadius.circular(6),
                    ),
                    child: Text('${entry.hole}', style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightBold, color: AppColors.amber500,
                    )),
                  ),
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
    try {
      final reg = event.registrations.firstWhere(
        (r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == id,
      );
      return reg.displayName;
    } catch (_) {
      return 'Unknown Player';
    }
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
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  final AppShapeTokens? shapes;

  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.message,
    required this.shapes,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacityLow),
        borderRadius: shapes?.card ?? BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: AppColors.opacitySubtle), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
