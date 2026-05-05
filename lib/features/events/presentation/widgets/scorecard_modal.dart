import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/utils/guest_id_helper.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scorecard_factory.dart';
import 'scorecard_resolver.dart';
import 'package:golf_society/utils/firestore_normalizer.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/models/course_config.dart';
import '../../../matchplay/domain/match_play_calculator.dart';
import '../../../matchplay/domain/match_definition.dart';
import 'course_info_card.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../courses/presentation/courses_provider.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../events_provider.dart';


class ScorecardModal {
  static void show(
    BuildContext context, 
    WidgetRef ref, {
    required LeaderboardEntry entry,
    required List<Scorecard> scorecards,
    required GolfEvent event,
    required Competition? comp,
    List<Member> membersList = const [],
    int? holeLimit,
    bool isAdmin = false,
    Map<String, String>? teeOverrides, // [NEW] Manual tee overrides
  }) {
    final actualScorecard = ScorecardResolver.resolve(
      entry: entry,
      scorecards: scorecards,
      event: event,
    );

    
    // Respect Lab Mode override
    final currentFormat = comp?.rules.format ?? CompetitionFormat.stableford;
    // Determine if this entry is a guest

    // Dynamic Height Adjustment for Team/Multiple Names
    final nameCount = entry.teamMemberNames?.length ?? 1;
    final isTeamDisplay = nameCount > 1;
    
    // "Come out further" -> Increase initial height to fit full scorecard
    final double dynamicInitialSize = isTeamDisplay ? 0.95 : 0.90;

    // Initial focused player for mixed tee context
    // If team mode, default to 'team' if it's a cumulative format, else if mixed tee choice matters, stay on first player.
    // Let's default to the first player now (as per user request)
    final isFourball = comp?.rules.subtype == CompetitionSubtype.fourball;
    String focusedPlayerId = (entry.teamMemberIds != null && entry.teamMemberIds!.isNotEmpty)
        ? entry.teamMemberIds!.first
        : entry.entryId;
    
    // [NEW] Resolve authoritative marker from scorecard
    String? activeMarkerId = actualScorecard.markerId ?? actualScorecard.submittedByUserId;
    if (activeMarkerId == 'system') activeMarkerId = null;

    final currentUserId = ref.read(effectiveUserProvider).id;

    // --- Pre-compute match play result before opening the sheet ---
    // This block previously ran inside the StatefulBuilder, re-executing on every
    // setModalState() call (e.g. player name tap). Moving it here means it runs once.
    List<String>? matchPlayResults;
    String? matchPlaySummary;
    int? conclusionHole;
    if (comp != null && comp.rules.isMatchPlay == true) {
      final myIds = entry.teamMemberIds ?? [entry.entryId];
      List<String>? myGroupIds;
      final groupsData = event.grouping["groups"] as List? ?? [];
      for (var g in groupsData) {
        final players = g['players'] as List? ?? [];
        final playerIds = players.map((p) => p['registrationMemberId']?.toString()).whereType<String>().toList();
        if (playerIds.any((id) => myIds.contains(id))) {
          myGroupIds = playerIds;
          break;
        }
      }
      if (myGroupIds != null) {
        final oppIds = myGroupIds.where((id) => !myIds.contains(id)).toList();
        if (oppIds.isNotEmpty) {
          final Map<String, double> playerIndices = {};
          final Map<String, CourseConfig> courseConfigs = {};
          for (final pid in myGroupIds) {
            final manualTee = teeOverrides?[pid];
            courseConfigs[pid] = ScoringCalculator.resolvePlayerCourseConfig(
              memberId: pid,
              event: event,
              membersList: membersList,
              manualTeeName: manualTee,
            );
            if (GuestIdHelper.isGuestId(pid)) {
              final baseId = GuestIdHelper.stripGuestSuffix(pid);
              final reg = event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
              playerIndices[pid] = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
            } else {
              final member = membersList.firstWhereOrNull((m) => m.id == pid);
              playerIndices[pid] = member?.handicap ?? 18.0;
            }
          }
          final strokesReceived = MatchPlayCalculator.calculateRelativeStrokes(
            playerIds: myGroupIds,
            playerIndices: playerIndices,
            courseConfigs: courseConfigs,
            rules: comp.rules,
            baseRating: event.courseConfig.rating ?? 72.0,
          );
          final virtualMatch = MatchDefinition(
            id: 'virtual_modal_${entry.entryId}',
            type: comp.rules.subtype == CompetitionSubtype.fourball ? MatchType.fourball : MatchType.foursomes,
            team1Ids: myIds,
            team2Ids: oppIds,
            strokesReceived: strokesReceived,
          );
          final List<Scorecard> sourceCards = [];
          for (var pid in myGroupIds) {
            Scorecard? card = scorecards.firstWhereOrNull((s) => s.entryId == pid);
            if (card == null) {
              final seeded = event.results.firstWhereOrNull((r) => FirestoreNormalizer.resolveMemberId(r) == pid);
              if (seeded != null && seeded['holeScores'] != null) {
                card = ScorecardFactory.fromSeededResult(entryId: pid, competitionId: event.id, result: seeded);
              }
            }
            if (card != null) sourceCards.add(card);
          }
          final result = MatchPlayCalculator.calculate(
            match: virtualMatch,
            scorecards: sourceCards,
            courseConfig: event.courseConfig,
            holesToPlay: event.courseConfig.holes.length,
          );
          conclusionHole = result.isFinal ? result.holesPlayed : null;
          matchPlayResults = result.holeResults.map((r) {
            if (r == 1) return 'W';
            if (r == -1) return 'L';
            if (r == 0) return 'H';
            return '';
          }).toList();
          if (result.score == 0) {
            matchPlaySummary = result.holesPlayed == 0 ? 'AS' : (result.isFinal ? 'HALVED' : 'AS');
          } else if (result.score > 0) {
            matchPlaySummary = result.isFinal ? 'WIN ${result.status}' : '${result.status} (UP)';
          } else {
            matchPlaySummary = result.isFinal ? 'LOSS ${result.status}' : '${result.status} (DN)';
          }
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use branch navigator so the global bottom nav bar stays visible behind the sheet.
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: dynamicInitialSize,
          minChildSize: 0.60,
          maxChildSize: dynamicInitialSize > 0.92 ? dynamicInitialSize : 0.92, 
          builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: AppShapes.sheet,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: AppSpacing.x4l,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: AppColors.dark400.withValues(alpha: AppColors.opacityMedium),
                  borderRadius: AppShapes.grabber,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Constrain width to prevent overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (() {
                            final effectiveFocusId = focusedPlayerId == 'team' 
                                ? (entry.teamMemberIds?.first ?? entry.entryId) 
                                : focusedPlayerId;
                            final manualTee = teeOverrides?[effectiveFocusId];
                            final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                              memberId: effectiveFocusId, 
                              event: event, 
                              membersList: membersList, 
                              manualTeeName: manualTee,
                            );
                            final teeName = manualTee ?? (playerTeeConfig.selectedTeeName ?? (event.selectedTeeName ?? 'Yellow'));
                            final teeColor = _getTeeColor(teeName, playerTeeConfig.tees);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          toTitleCase(entry.playerName),
                                          style: AppTypography.display.copyWith(
                                            color: AppColors.dark900,
                                            fontWeight: AppTypography.weightHeavy,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isAdmin && actualScorecard.status == ScorecardStatus.submitted)
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.lime500),
                                            tooltip: 'Approve Scorecard',
                                            onPressed: () async {
                                              final confirmed = await showBoxyArtDialog<bool>(
                                                context: context,
                                                title: 'Approve Scorecard?',
                                                message: 'Mark this scorecard as Reviewed.',
                                                confirmText: 'Approve',
                                              );
                                              if (confirmed == true) {
                                                try {
                                                  await ref.read(scorecardRepositoryProvider).updateScorecardStatus(actualScorecard.id, ScorecardStatus.reviewed);
                                                  if (context.mounted) Navigator.pop(context);
                                                } catch (_) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Failed to approve scorecard — check your connection.')),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        if (isAdmin)
                                          IconButton(
                                            icon: const Icon(Icons.edit_note_rounded, color: AppColors.lime500),
                                            tooltip: 'Edit Scores',
                                            onPressed: () {
                                              Navigator.pop(context); // Close modal
                                              context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/scores/${entry.entryId}');
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: AppColors.dark150),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (isFourball || (entry.teamMemberNames != null && entry.teamMemberNames!.length > 1)) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (isFourball)
                                        _buildViewPill(
                                          label: 'Team View',
                                          isSelected: focusedPlayerId == 'team',
                                          onTap: () => setModalState(() => focusedPlayerId = 'team'),
                                        ),
                                      ...entry.teamMemberNames!.asMap().entries.map((e) {
                                        final idx = e.key;
                                        final name = e.value;
                                        final id = entry.teamMemberIds![idx];
                                        
                                        final isMarker = activeMarkerId == id;
                                        final isMe = currentUserId == id;
                                        final isFocused = focusedPlayerId == id;

                                        return _buildViewPill(
                                          label: name,
                                          isSelected: isMarker, // Green if marker
                                          isFocused: isFocused, // Border if focused
                                          onTap: () async {
                                            setModalState(() => focusedPlayerId = id);
                                            
                                            // [NEW] Claim logic: If I tap my own name and I'm not the marker, claim it!
                                            if (isMe && !isMarker) {
                                              if (kDebugMode) debugPrint(" [Claim] User $id claiming marker role for scorecard ${actualScorecard.id}");
                                              final updatedCard = actualScorecard.copyWith(
                                                markerId: id,
                                                submittedByUserId: id, // Fallback for legacy
                                                updatedAt: DateTime.now(),
                                              );
                                              try {
                                                await ref.read(scorecardRepositoryProvider).updateScorecard(updatedCard);
                                              } catch (_) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Failed to update scorecard — check your connection.')),
                                                  );
                                                }
                                              }
                                              // Immediate UI feedback regardless of write outcome
                                              setModalState(() => activeMarkerId = id);
                                            }
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    BoxyArtIndicator.hc(label: entry.handicapIndex.toStringAsFixed(1)),
                                    if (entry.playingHandicap != null) ...[
                                      const SizedBox(width: AppSpacing.md),
                                      BoxyArtIndicator.phc(context: context, label: '${entry.playingHandicap}'),
                                    ],
                                    const Spacer(),
                                    BoxyArtIndicator.tee(
                                      label: teeName, 
                                      teeColor: teeColor,
                                      onTap: (isAdmin || activeMarkerId == currentUserId) ? () {
                                        _showTeeSelector(
                                          context: context,
                                          ref: ref,
                                          event: event,
                                          memberId: effectiveFocusId,
                                          currentTeeName: teeName,
                                          membersList: membersList,
                                          onTeeSelected: (newTee) async {
                                            // 1. Update local state for immediate feedback if possible
                                            // Actually, since this is a static modal, we better just update Firestore and let the parent refresh
                                            
                                            // 2. Update EventRegistration in Firestore
                                            final registrations = List<EventRegistration>.from(event.registrations);
                                            final idx = registrations.indexWhere((r) => r.memberId == effectiveFocusId);
                                            if (idx >= 0) {
                                              final reg = registrations[idx];
                                              // Determine if guest or member
                                              final isGuestId = GuestIdHelper.isGuestId(effectiveFocusId);
                                              final updatedReg = isGuestId 
                                                  ? reg.copyWith(guestTeeName: newTee)
                                                  : reg.copyWith(teeName: newTee);
                                              
                                              registrations[idx] = updatedReg;
                                              
                                              final updatedEvent = event.copyWith(registrations: registrations);
                                              await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
                                              
                                              // Trigger a rebuild of the modal by calling setModalState (passed down)
                                              setModalState(() {
                                                // This will trigger a re-resolve of teeName in the build method
                                              });
                                            }
                                          },
                                        );
                                      } : null,
                                    ),
                                  ],
                                ),
                                if (entry.thruLabel != null || entry.tieBreakLabel != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (entry.thruLabel != null)
                                        BoxyArtPill.status(label: entry.thruLabel!, color: AppColors.lime500, isLegend: true),
                                      if (entry.tieBreakLabel != null)
                                        BoxyArtPill.status(label: entry.tieBreakLabel!, color: AppColors.dark400, isLegend: true),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          })(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100.0),
                  child: Builder(
                    builder: (context) {
                      if (comp == null) return const Center(child: CircularProgressIndicator());
                      // Resolve effective rules/format for modal
                      final effectiveMaxScore = comp.rules.maxScoreConfig;

                      // [NEW] Logic for Team/Pairs Display
                      List<CourseScoreRow> additionalRows = [];
                      List<int?>? bestBallPoints;
                      
                      final isFourball = comp.rules.subtype == CompetitionSubtype.fourball;
                      final isTeam = comp.rules.mode == CompetitionMode.teams;
                      final isStableford = comp.rules.format == CompetitionFormat.stableford;
                      final isScrambleFormat = comp.rules.format == CompetitionFormat.scramble;
                      
                      if ((isStableford || comp.rules.scoringType == 'STABLEFORD') && (isFourball || isTeam)) {
                        bestBallPoints = entry.holePoints;
                      }

                      final totalPoints = entry.holePoints?.whereType<int>().fold<int>(0, (a, b) => a + b);

                      // matchPlayResults / matchPlaySummary / conclusionHole are now
                      // pre-computed before showModalBottomSheet to avoid re-running on
                      // every setModalState() call.

                      final config = ref.watch(themeControllerProvider);
                      final pointsColor = Color(config.effectivePointsColor);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (() {
                             // Context resolution
                             final effectiveFocusId = focusedPlayerId == 'team' 
                                 ? (entry.teamMemberIds?.first ?? entry.entryId) 
                                 : focusedPlayerId;

                             final manualTee = teeOverrides?[effectiveFocusId];
                             final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                               memberId: effectiveFocusId, 
                               event: event, 
                               membersList: membersList, 
                               manualTeeName: manualTee,
                             );
                             final playerTeeName = manualTee ?? (playerTeeConfig.selectedTeeName ?? (event.selectedTeeName ?? 'Yellow'));

                             return CourseInfoCard(
                               courseConfig: playerTeeConfig,
                               selectedTeeName: playerTeeName,
                               isStableford: isStableford,
                               isNet: comp.rules.scoringType != 'GROSS',
                               format: currentFormat,
                               maxScoreConfig: effectiveMaxScore,
                               holeScores: entry.holeScores,
                               holeNetScores: entry.holeNetScores,
                               holePoints: entry.holePoints,
                               holePars: event.courseConfig.holes.map((h) => h.par).toList(),
                               holeSIs: event.courseConfig.holes.map((h) => h.si).toList(),
                               holeDistances: event.courseConfig.holes.map((h) => h.yardage ?? 0).toList(),
                               mainRowLabel: focusedPlayerId == 'team' ? (isFourball ? 'BEST BALL' : 'TEAM') : 'Strokes',
                               additionalRows: additionalRows, 
                               holeLimit: holeLimit,
                               overrideTotalPoints: totalPoints,
                               matchPlayResults: matchPlayResults,
                               conclusionHole: conclusionHole,
                             );
                          })(),
                          const SizedBox(height: AppSpacing.x2l),
                          ScorecardModal.buildUnifiedComparisonFooter(
                            context,
                            event: event,
                            membersList: membersList,
                            teamPoints: bestBallPoints,
                            isScramble: isScrambleFormat,
                            scorecard: actualScorecard,
                            playerName: isFourball == true ? 'TEAM BEST BALL' : (isTeam == true ? 'TEAM SCORE' : entry.playerName),
                            matchPlayResults: matchPlayResults,
                            matchPlaySummary: matchPlaySummary,
                            mode: comp.rules.mode,
                            pointsColor: pointsColor,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  static Widget buildUnifiedComparisonFooter(
    BuildContext context, {
    required GolfEvent event,
    required List<Member> membersList,
    required bool isScramble,
    required Color pointsColor,
    Scorecard? scorecard,
    List<int?>? teamPoints,
    String? playerName,
    List<String>? matchPlayResults,
    String? matchPlaySummary,
    CompetitionMode? mode,
  }) {
    final List<int?> scores = teamPoints ?? scorecard?.holeScores ?? [];
    
    // REDUNDANCY CHECK: 
    // If it's not a Team game, not Match Play, and not showing Scramble attributions, 
    // then showing a "Group Score" summary of the SAME player is redundant.
    final bool isTeamGame = teamPoints != null || (mode != null && mode != CompetitionMode.singles);
    final bool hasMatchPlay = matchPlayResults != null;
    final bool hasScrambleAttributions = isScramble && (scorecard?.shotAttributions.isNotEmpty ?? false);

    if (!isTeamGame && !hasMatchPlay && !hasScrambleAttributions) {
      return const SizedBox.shrink();
    }

    if (matchPlayResults == null && (scores.isEmpty || scores.every((s) => s == null))) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            (isScramble ? "DRIVE ATTRIBUTIONS" : (matchPlayResults != null ? "MATCH PLAY RESULT" : "GROUP SCORE")),
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (isScramble && scorecard != null && scorecard.shotAttributions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: scorecard.shotAttributions.entries.map((attr) {
                final holeNum = attr.key + 1;
                final memberId = attr.value;
                // Note: additionalRows removed from signature, we'll try to find name from membersList
                final member = membersList.firstWhereOrNull((m) => m.id == memberId);
                final name = member?.displayName.split(' ').first ?? 'Player';
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                    borderRadius: AppShapes.xs,
                    border: Border.all(color: AppColors.lime500.withValues(alpha: AppColors.opacityMuted)),
                  ),
                  child: Text(
                    "H$holeNum: $name",
                    style: const TextStyle(
                      fontSize: AppTypography.sizeCaption,
                      fontWeight: AppTypography.weightBlack,
                      color: AppColors.lime500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        
        // Unified Team Row
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: AppSpacing.md,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teamA,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Text(
                    toTitleCase(playerName ?? "Team"),
                    style: TextStyle(
                      fontSize: AppTypography.sizeCaption,
                      fontWeight: AppTypography.weightBlack,
                      color: pointsColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    matchPlayResults != null 
                        ? "Total: ${matchPlaySummary ?? 'AS'}"
                        : "Total: ${scores.where((s) => s != null).fold<int>(0, (sum, s) => sum + (s as int))}",
                    style: TextStyle(
                      fontSize: AppTypography.sizeLabel, 
                      fontWeight: AppTypography.weightBlack, 
                      color: matchPlayResults != null ? AppColors.textSecondary : pointsColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Column(
                children: [
                  _buildNineHoleRow(context, event, membersList, scores, 0, pointsColor, matchPlayResults: matchPlayResults),
                  const SizedBox(height: AppSpacing.xs),
                  _buildNineHoleRow(context, event, membersList, scores, 9, pointsColor, matchPlayResults: matchPlayResults),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildNineHoleRow(
    BuildContext context, 
    GolfEvent event, 
    List<Member> membersList, 
    List<int?> scores, 
    int startIdx, 
    Color pointsColor, {
    List<String>? matchPlayResults,
  }) {
    // We use the event course config by default for the UNIFIED view

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.dark600,
        borderRadius: AppShapes.sm,
        border: Border.all(color: AppColors.dark500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(9, (i) {
          final hIdx = startIdx + i;
          
          if (matchPlayResults != null) {
              final result = matchPlayResults.length > hIdx ? matchPlayResults[hIdx] : '';
              Color bgColor = Colors.transparent;
              Color textColor = AppColors.textSecondary;
              Color borderColor = AppColors.textSecondary;
              
              if (result == 'W') {
                  bgColor = AppColors.lime500;
                  textColor = AppColors.pureWhite;
                  borderColor = AppColors.lime500;
              } else if (result == 'L') {
                  bgColor = AppColors.coral500;
                  textColor = AppColors.pureWhite;
                  borderColor = AppColors.coral500;
              } else if (result == 'H') {
                  bgColor = AppColors.textSecondary;
                  textColor = AppColors.pureWhite;
                  borderColor = AppColors.textSecondary;
              }

              return Expanded(
                child: Container(
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppShapes.sm,
                    border: Border.all(color: borderColor, width: AppShapes.borderThin),
                  ),
                  child: Text(
                    result.isEmpty ? '-' : result,
                      style: AppTypography.label.copyWith(
                        fontWeight: AppTypography.weightHeavy,
                        color: textColor,
                      ),
                  ),
                ),
              );
          }

          final score = scores.length > hIdx ? scores[hIdx] : null;

          // Points Calculation (Assuming Stableford for unified view unless it's Medal)
          
          final points = score; // We assume the passed 'scores' are already points if it's Fourball

          return Expanded(
            child: Container(
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: points != null ? AppColors.dark500 : Colors.transparent,
                borderRadius: AppShapes.sm,
                border: Border.all(
                  color: points != null ? AppColors.dark400 : AppColors.dark500,
                  width: AppShapes.borderThin,
                ),
              ),
              child: Text(
                points?.toString() ?? '-',
                style: TextStyle(
                  fontSize: AppTypography.sizeCaptionStrong,
                  fontWeight: points != null ? AppTypography.weightBlack : AppTypography.weightBold,
                  color: points != null ? pointsColor : AppColors.dark400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }



  static Widget _buildViewPill({
    required String label,
    required bool isSelected,
    bool isFocused = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.lime500.withValues(alpha: AppColors.opacityLow) 
              : (isFocused ? AppColors.dark400.withValues(alpha: 0.1) : Colors.transparent),
          borderRadius: AppShapes.pill,
          border: Border.all(
            color: isSelected 
                ? AppColors.lime500 
                : (isFocused ? AppColors.dark400 : AppColors.dark500),
            width: (isSelected || isFocused) ? 1.5 : AppShapes.borderThin,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.micro.copyWith(
            fontWeight: (isSelected || isFocused) ? AppTypography.weightBold : AppTypography.weightStrong,
            color: isSelected 
                ? AppColors.lime500 
                : (isFocused ? AppColors.dark900 : AppColors.dark300),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  static Color _getTeeColor(String teeName, [List<TeeConfig>? teeConfigs]) {
    return AppColors.getTeeColor(teeName, teeConfigs);
  }

  static void _showTeeSelector({
    required BuildContext context,
    required WidgetRef ref,
    required GolfEvent event,
    required String memberId,
    required String currentTeeName,
    required List<Member> membersList,
    required Function(String) onTeeSelected,
  }) {
    // Try to get course from provider if possible
    final courseDetail = event.courseId != null 
        ? ref.read(courseDetailProvider(event.courseId!)).value 
        : null;
    
    final tees = courseDetail?.tees ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppShapes.sheet,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'SELECT TEE'),
            const SizedBox(height: AppSpacing.md),
            if (tees.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'NO TEES DEFINED FOR THIS COURSE. PLEASE ENSURE THE COURSE CONFIGURATION IS COMPLETE.',
                  style: TextStyle(
                    fontSize: AppTypography.sizeCaption,
                    color: AppColors.dark400,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: SingleChildScrollView(
                  child: Column(
                    children: tees.map((t) => BoxyArtCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      onTap: () {
                         onTeeSelected(t.name);
                         Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.getTeeColor(t.name, tees),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            t.name.toUpperCase(), 
                            style: const TextStyle(
                              fontWeight: AppTypography.weightBlack,
                              fontSize: AppTypography.sizeButton,
                              letterSpacing: 0.5,
                            )
                          ),
                          const Spacer(),
                          if (t.name == currentTeeName)
                            const Icon(Icons.check_circle_rounded, color: AppColors.lime500),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
