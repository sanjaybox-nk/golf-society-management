import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../domain/models/processed_event_data.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/course_config.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/match_play_calculator.dart';

import 'grouping_player_avatar.dart';
import 'grouping_player_tile.dart';
class GroupingCard extends ConsumerWidget {
  final TeeGroup group;
  final Map<String, Member> memberMap;
  final List<GolfEvent> history;
  final int totalGroups;
  final CompetitionRules? rules;
  final CourseConfig? courseConfig;
  final bool useWhs;
  final bool isAdmin;
  final bool isLocked;
  final Function(TeeGroupParticipant p, TeeGroup g)? onPlayerDragStart;
  final Function(
    TeeGroupParticipant sourceP,
    TeeGroup? sourceG,
    TeeGroup targetG,
    TeeGroupParticipant? targetP,
  )?
  onMove;
  final Function(String action, TeeGroupParticipant p, TeeGroup g)? onAction;
  final Function(TeeGroupParticipant p, TeeGroup g)? onTapParticipant;
  final bool Function(TeeGroupParticipant p)? isSelected;
  final Widget Function(TeeGroup group)? emptySlotBuilder;
  final bool isScoreMode;
  final Map<String, String>? scoreMap;
  final Map<String, Scorecard>? scorecardMap;
  final Map<String, bool>? winnerMap; // [NEW] Official ranks
  final Map<String, int>? phcMap; // [NEW] Explicit PHC overrides (Team PHCs)
  final bool matchPlayMode;
  final List<MatchDefinition> matches;
  final Map<String, List<int?>>? betterBallMap;
  final Map<String, String>? tieBreakMap;
  final Map<String, String>? thruMap;
  final Map<String, double>? hcMap;
  final Map<String, ScoringStatus>? statusMap;
  final int? groupIndex;
  final bool showScoring; // [NEW] Master toggle for hiding all scores/winners in organization views
  final Map<String, ProcessedLeaderboardEntry>? computedEntries; // [NEW] Centralized results lookup
  final Map<int, ProcessedGroupResult>? computedGroupResults; // [NEW] Centralized group results lookup
  final bool isEventClosed;
  final Function(String entryId, String markerEntryId, String playerName, String markerName)? onUnlockCard;

  const GroupingCard({
    super.key,
    required this.group,
    required this.memberMap,
    required this.history,
    required this.totalGroups,
    this.rules,
    this.courseConfig,
    this.useWhs = true,
    this.isAdmin = false,
    this.isLocked = false,
    this.onPlayerDragStart,
    this.onMove,
    this.onAction,
    this.onTapParticipant,
    this.isSelected,
    this.emptySlotBuilder,
    this.isScoreMode = false,
    this.scoreMap,
    this.scorecardMap,
    this.winnerMap,
    this.phcMap,
    this.matchPlayMode = false,
    this.matches = const [],
    this.betterBallMap,
    this.tieBreakMap,
    this.thruMap,
    this.hcMap,
    this.statusMap,
    this.groupIndex,
    this.showScoring = true,
    this.computedEntries,
    this.computedGroupResults,
    this.isEventClosed = false,
    this.onUnlockCard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    
    // 1. Calculate Total PHC dynamically
    double displayTotalHandicap = 0;
    if (rules != null) {
      final isScramble = rules!.format == CompetitionFormat.scramble;
      final isFoursomes = rules!.subtype == CompetitionSubtype.foursomes;

      if (isScramble || isFoursomes) {
        final List<double> indices = group.players.map((p) => p.handicapIndex).toList();
        displayTotalHandicap = HandicapCalculator.calculateTeamHandicap(
          individualIndices: indices,
          rules: rules!,
          courseConfig: courseConfig ?? const CourseConfig(),
        ).toDouble();
      } else {
        for (var p in group.players) {
          final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
          final livePhc = phcMap?[id];
          displayTotalHandicap += livePhc?.toDouble() ?? p.playingHandicap;
        }
      }
    } else {
      displayTotalHandicap = group.totalHandicap.roundToDouble();
    }

    final isStableford = rules?.format == CompetitionFormat.stableford;
    final isScramble = rules?.format == CompetitionFormat.scramble;
    final isFourball = rules?.subtype == CompetitionSubtype.fourball;
    final int bestX = rules?.teamBestXCount ?? 2;
    final isMatchPlay = rules?.isMatchPlay ?? false;

    // 2. Relative PHC Map for Match Play
    final Map<String, int> relativePhcMap = phcMap != null ? Map.from(phcMap!) : {};
    if (isMatchPlay && rules != null) {
      final List<String> playerIds = group.players.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList();
      final Map<String, double> playerIndices = { for (var p in group.players) (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) : p.handicapIndex };
      final baseRating = courseConfig?.rating ?? 72.0;
      
      final Map<String, int> centralizedStrokes = MatchPlayCalculator.calculateRelativeStrokes(
        playerIds: playerIds,
        playerIndices: playerIndices,
        courseConfigs: { for (var id in playerIds) id : courseConfig ?? const CourseConfig() },
        rules: rules!,
        baseRating: baseRating,
      );
      relativePhcMap.addAll(centralizedStrokes);
    }

    // 3. Centralized Result Mapping (Unified source of truth)
    final Map<String, MatchResult> playerMatchResults = {};
    if (isScoreMode && computedEntries != null) {
      for (final id in group.players.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId)) {
        final entry = computedEntries![id];
        if (entry != null && entry.isMatch && entry.matchStatus != null) {
           // Create a lightweight result for display
           playerMatchResults[id] = MatchResult(
             matchId: 'centralized',
             winningTeamIndex: entry.matchScore != null ? (entry.matchScore! > 0 ? 0 : 1) : -1,
             status: entry.matchStatus!
                 .replaceAll('WIN', 'Won')
                 .replaceAll('LOSS', 'Lost')
                 .replaceAll('HALVED', 'Halved'),
             score: entry.matchScore ?? 0,
             holeResults: [],
             holesPlayed: entry.holesPlayed,
             isFinal: entry.matchStatus!.startsWith('WIN') || entry.matchStatus!.startsWith('LOSS') || entry.matchStatus == 'HALVED',
           );
        }
      }
    }

    // 4. Split Team Logic (CENTRALIZED)
    final bool isSplitTeam = ((isScramble && rules?.teamSize == 2) || (rules?.mode == CompetitionMode.pairs) || isFourball) && group.players.length >= 3;
    final groupResult = (groupIndex != null && computedGroupResults != null) 
        ? computedGroupResults![groupIndex!] 
        : null;
    
    String? teamALabel = groupResult?.sideALabel;
    String? teamBLabel = groupResult?.sideBLabel;
    
    bool hasScoreA = teamALabel != null && teamALabel != '-';
    bool hasScoreB = teamBLabel != null && teamBLabel != '-';

    // 5. Scoring & Winners
    final Map<String, bool> internalWinnerMap = winnerMap != null ? Map.from(winnerMap!) : {};
    final Map<String, String?> playerScoresForTies = {};
    final Map<String, int> scoreFreq = {};

    if (isScoreMode && scoreMap != null) {
      final List<MapEntry<String, int>> playerScores = [];
      int parseScore(String text) {
        if (text == 'E') return 0;
        final clean = text.replaceAll('+', '').trim();
        return int.tryParse(clean) ?? (isStableford ? 0 : 999);
      }

      for (int i = 0; i < group.players.length; i++) {
        final p = group.players[i];
        final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final scoreText = scoreMap![id];

        if (scoreText != null && scoreText != '-') {
          final score = parseScore(scoreText);
          playerScores.add(MapEntry(id, score));
          playerScoresForTies[id] = scoreText;
          scoreFreq[scoreText] = (scoreFreq[scoreText] ?? 0) + 1;
        }
      }

      if (playerScores.isNotEmpty && !isScramble && !isSplitTeam) {
        if (isStableford) {
          playerScores.sort((a, b) => b.value.compareTo(a.value));
        } else {
          playerScores.sort((a, b) => a.value.compareTo(b.value));
        }
        if (playerScores.isNotEmpty) internalWinnerMap[playerScores.first.key] = true;
      }
    }


    return Padding(
      padding: EdgeInsets.only(bottom: spacing?.groupFooterToLabel ?? AppSpacing.x2l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group ${group.index + 1}',
                style: AppTypography.displaySection.copyWith(
                  color: isDark ? AppColors.pureWhite : AppColors.dark900,
                  fontWeight: AppTypography.weightExtraBold,
                  fontSize: AppTypography.sizeHeadline,
                ),
              ),
              Row(
                children: [
                  // Ready for approval count — admin only
                  if (isAdmin && scorecardMap != null) ...() {
                    final readyCount = group.players.where((p) {
                      final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                      final sc = scorecardMap![id];
                      return sc != null && sc.status == ScorecardStatus.submitted && sc.verifiedByPlayer && sc.verifiedByMarker;
                    }).length;
                    if (readyCount == 0) return [];
                    return [
                      BoxyArtIndicator(
                        label: '$readyCount ready',
                        icon: Icons.check_circle_rounded,
                        dotColor: AppColors.lime500,
                        showBackground: true,
                        hasHorizontalMargin: false,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ];
                  }(),
                  // Finished but not submitted — admin only
                  if (isAdmin && scorecardMap != null && isScoreMode) ...() {
                    final unsubmittedCount = group.players.where((p) {
                      final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                      final sc = scorecardMap![id];
                      return sc != null && sc.status == ScorecardStatus.draft && thruMap?[id] == 'F';
                    }).length;
                    if (unsubmittedCount == 0) return [];
                    return [
                      BoxyArtIndicator(
                        label: '$unsubmittedCount not submitted',
                        icon: Icons.pending_rounded,
                        dotColor: AppColors.amber500,
                        isAction: true,
                        hasHorizontalMargin: false,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ];
                  }(),
                  BoxyArtIndicator(
                    label: _formatTime(context, group.teeTime),
                    icon: Icons.access_time_filled_rounded,
                    isAction: true,
                    hasHorizontalMargin: false,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The vertical bracket / timeline
                Container(
                  width: 1, // Made thinner
                  margin: const EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.md, top: AppSpacing.sm, bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dark500 : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                ...() {
            Widget buildParticipantTile(TeeGroupParticipant p, String id, String? side, {bool useCard = true}) {
              final bool hasGuestInGroupP = !p.isGuest && group.players.any((other) => other.isGuest && other.registrationMemberId == p.registrationMemberId);
              final sc = scorecardMap?[id];
              final bool readyForApproval = isAdmin &&
                  sc != null &&
                  sc.status == ScorecardStatus.submitted &&
                  sc.verifiedByPlayer &&
                  sc.verifiedByMarker &&
                  sc.conflictedHoles.isEmpty;
              final tile = GroupingPlayerTile(
                player: p,
                group: group,
                member: p.isGuest
                    ? memberMap[p.registrationMemberId]?.copyWith(avatarUrl: null)
                    : memberMap[p.registrationMemberId],
                history: history,
                totalGroups: totalGroups,
                rules: rules,
                courseConfig: courseConfig,
                useWhs: useWhs,
                isAdmin: isAdmin,
                isSelected: isSelected?.call(p) ?? false,
                onAction: onAction,
                isScoreMode: isScoreMode,
                scoreDisplay: isScoreMode
                    ? (playerMatchResults[id]?.status ?? scoreMap?[id])
                    : null,
                isWinner: isScoreMode ? (internalWinnerMap[id] ?? false) : false,
                thruLabel: isScoreMode ? (thruMap?[id]) : null,
                tieBreakLabel: isScoreMode ? (tieBreakMap?[id]) : null,
                handicapIndex: hcMap?[id],
                scoringStatus: statusMap?[id] ?? ScoringStatus.ok,
                onTap: () => onTapParticipant?.call(p, group),
                hasSocietyCut: p.hasSocietyCut,
                hasGuestInGroup: hasGuestInGroupP,
                matchSide: side,
                useCard: useCard,
                isStableford: rules?.format == CompetitionFormat.stableford,
                phcOverride: (isScramble || rules?.subtype == CompetitionSubtype.foursomes)
                    ? displayTotalHandicap.toInt()
                    : (isScoreMode ? relativePhcMap[id] : null),
                isEventClosed: isEventClosed,
              );
              final bool isCardLocked = isAdmin && sc != null &&
                  (sc.status == ScorecardStatus.finalScore ||
                   sc.status == ScorecardStatus.reviewed ||
                   sc.status == ScorecardStatus.approved);

              if (!readyForApproval && !isCardLocked) return tile;

              final markerName = isCardLocked
                  ? group.players.firstWhereOrNull((mp) {
                      final mId = mp.isGuest ? '${mp.registrationMemberId}_guest' : mp.registrationMemberId;
                      return mId == sc.markerId;
                    })?.name ?? sc.markerId
                  : null;

              final isDqTile = (statusMap?[id] ?? ScoringStatus.ok) == ScoringStatus.dq;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  tile,
                  if (isDqTile)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.coral500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('DQ', style: AppTypography.micro.copyWith(
                          color: AppColors.pureWhite,
                          fontWeight: AppTypography.weightHeavy,
                          fontSize: 8,
                          height: 1.0,
                        )),
                      ),
                    ),
                  if (isCardLocked && onUnlockCard != null)
                    Positioned(
                      top: -6,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => onUnlockCard!(id, sc.markerId ?? '', p.name, markerName ?? ''),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.dark500,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.lock_rounded, size: 11, color: AppColors.pureWhite),
                        ),
                      ),
                    ),
                  if (!isCardLocked && isAdmin && sc.status == ScorecardStatus.draft && thruMap?[id] == 'F')
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.amber500,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.pending_rounded, size: 11, color: AppColors.pureWhite),
                      ),
                    ),
                ],
              );
            }

            final List<Widget> children = [];
            final List<TeeGroupParticipant> players = List.from(group.players);

            // [NEW] Unified Team Format Check (Scramble, Fourball, etc)
            if (rules?.isUnifiedTeamFormat == true) {
              return players.asMap().entries.map((entry) {
                final p = entry.value;
                final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                final isLast = entry.key == players.length - 1;

                return Column(
                  children: [
                    buildParticipantTile(p, id, null, useCard: true),
                    if (!isLast)
                      SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                  ],
                );
              }).toList();
            }
            
            // Reordering and Vertical Rhythm for Match Play (v4.x)
            if (config.showMatchPlayOverlay && (isMatchPlay || matchPlayMode || matches.isNotEmpty)) {
              final Set<String> processedIds = {};
              int matchIndex = 1;
              
              // 1. Render Defined Matches
              for (final match in matches) {
                final List<TeeGroupParticipant> sideA = [];
                final List<TeeGroupParticipant> sideB = [];

                for (var p in players) {
                  final pid = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                  if (processedIds.contains(pid)) continue;

                  if (match.team1Ids.contains(pid) || match.team1Ids.contains(p.registrationMemberId)) {
                    sideA.add(p);
                  } else if (match.team2Ids.contains(pid) || match.team2Ids.contains(p.registrationMemberId)) {
                    sideB.add(p);
                  }
                }

                if (sideA.isNotEmpty || sideB.isNotEmpty) {
                  // Add Match Header (Microtext)
                  children.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                      child: Text(
                        'MATCH $matchIndex',
                        style: AppTypography.micro.copyWith(
                          color: (isDark ? AppColors.pureWhite : AppColors.dark900).withValues(alpha: 0.6),
                          fontWeight: AppTypography.weightExtraBold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  );

                  // Add Side A Cards
                  for (var p in sideA) {
                    final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                    processedIds.add(id);
                    final tile = buildParticipantTile(p, id, 'A');
                    children.add(isAdmin ? _wrapWithDraggable(context, p, tile) : tile);
                    if (p != sideA.last) {
                      children.add(SizedBox(height: spacing?.cardToCard ?? AppSpacing.sm));
                    }
                  }

                  // Add "v" Separator
                  if (sideA.isNotEmpty && sideB.isNotEmpty) {
                    children.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Center(
                          child: Text(
                            'v',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: AppTypography.weightExtraBold,
                              color: (isDark ? AppColors.pureWhite : AppColors.dark900).withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Add Side B Cards
                  for (var p in sideB) {
                    final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                    processedIds.add(id);
                    final tile = buildParticipantTile(p, id, 'B');
                    children.add(isAdmin ? _wrapWithDraggable(context, p, tile) : tile);
                    if (p != sideB.last) {
                      children.add(SizedBox(height: spacing?.cardToCard ?? AppSpacing.sm));
                    }
                  }

                  matchIndex++;
                  // Spacing between matches
                  children.add(SizedBox(height: spacing?.cardToCard ?? AppSpacing.x2l));
                }
              }

              // 2. Add remaining players (Fallback)
              for (var p in players) {
                final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                if (!processedIds.contains(id)) {
                  final tile = buildParticipantTile(p, id, null);
                  children.add(isAdmin ? _wrapWithDraggable(context, p, tile) : tile);
                  children.add(SizedBox(height: spacing?.cardToCard ?? AppSpacing.md));
                }
              }
            } else {
              // Legacy Flat List / Split Team Logic
              for (int index = 0; index < group.players.length; index++) {
                final p = group.players[index];
                final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                
                final tile = buildParticipantTile(p, id, null, useCard: true);
                Widget playerWidget = isAdmin ? _wrapWithDraggable(context, p, tile) : tile;

                if (isSplitTeam && index == 1) {
                  children.add(Column(mainAxisSize: MainAxisSize.min, children: [
                    playerWidget,
                    if (showScoring && isScoreMode && hasScoreA)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'SIDE A: $teamALabel',
                            style: AppTypography.label.copyWith(color: Color(config.teamAColor), fontWeight: AppTypography.weightExtraBold, fontSize: 10),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Row(children: [
                        Expanded(child: SizedBox.shrink()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm), 
                          child: Text(
                            'VS', 
                            style: TextStyle(
                              fontSize: AppTypography.sizeCaption, 
                              fontWeight: AppTypography.weightExtraBold, 
                              color: (isDark ? AppColors.pureWhite : AppColors.dark900).withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox.shrink()),
                      ]),
                    ),
                  ]));
                } else if (isSplitTeam && index == 3 && showScoring && isScoreMode && hasScoreB) {
                   children.add(Column(mainAxisSize: MainAxisSize.min, children: [
                     playerWidget,
                     Padding(
                       padding: const EdgeInsets.only(top: AppSpacing.sm),
                       child: Align(
                         alignment: Alignment.centerRight,
                         child: Text(
                           'SIDE B: $teamBLabel',
                           style: AppTypography.label.copyWith(color: Color(config.teamBColor), fontWeight: AppTypography.weightExtraBold, fontSize: 10),
                         ),
                       ),
                     ),
                   ]));
                } else {
                  children.add(Column(mainAxisSize: MainAxisSize.min, children: [
                    playerWidget,
                    if (index != group.players.length - 1)
                      SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                  ]));
                }
              }
            }
            return children;
          }(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin && group.players.length < 4) emptySlotBuilder?.call(group) ?? const SizedBox.shrink(),
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showScoring && isScoreMode && groupResult != null && !isMatchPlay)
                  Text(
                    isScramble 
                        ? 'Team Total: ${groupResult.label}'
                        : 'Group Total (Best $bestX): ${groupResult.label}',
                    style: AppTypography.label.copyWith(
                      color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      fontWeight: AppTypography.weightExtraBold,
                      fontSize: 12,
                    ),
                  ),
                const Spacer(),
                if (isFourball)
                  Text(rules?.isMatchPlay == true ? 'Match Play (Rel)' : 'Fourball (Pairs)', style: AppTypography.label.copyWith(color: isDark ? AppColors.dark100 : AppColors.dark900, fontWeight: AppTypography.weightBold, fontSize: 12, letterSpacing: -0.2))
                else if (isScramble)
                  BoxyArtIndicator.phc(label: 'Team: ${displayTotalHandicap.toInt()}', hasHorizontalMargin: false)
                else
                  BoxyArtIndicator.phc(label: 'Total: ${displayTotalHandicap.toInt()}', hasHorizontalMargin: false),
              ],
            ),
          ),
        ],
      ),
    );
  }



  String _formatTime(BuildContext context, DateTime time) {
    return DateFormat.Hm().format(time);
  }

  Widget _wrapWithDraggable(
    BuildContext context,
    TeeGroupParticipant p,
    Widget child,
  ) {
    // Standardized Container that preserves layout footprint (2px border space)
    Widget decoratedChild = AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        borderRadius: AppShapes.md,
        border: Border.all(
          color: Colors.transparent, // Default transparent
          width: AppShapes.borderMedium,
        ),
      ),
      child: child,
    );

    // If locked, return just the decorated container to keep layout stable
    if (isLocked) return decoratedChild;


    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) =>
          details.data['player'] != p,
      onAcceptWithDetails: (details) {
        final sourcePlayer = details.data['player'] as TeeGroupParticipant;
        final sourceGroup = details.data['group'] as TeeGroup?;
        onMove?.call(sourcePlayer, sourceGroup, group, p);
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;

        return LongPressDraggable<Map<String, dynamic>>(
          data: {'player': p, 'group': group},
          delay: AppAnimations.slow,
          feedback: Material(
            elevation: 8,
            borderRadius: AppShapes.x2l,
            child: GroupingPlayerAvatar(
              player: p,
              member: p.isGuest
                  ? memberMap[p.registrationMemberId]?.copyWith(avatarUrl: null)
                  : memberMap[p.registrationMemberId],
              size: AppShapes.iconHero,
              groupIndex: group.index,
              totalGroups: totalGroups,
              history: history,
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: decoratedChild),
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            decoration: BoxDecoration(
              borderRadius: AppShapes.md,
              border: Border.all(
                color: isOver
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: AppShapes.borderMedium,
              ),
              color: isOver
                  ? Theme.of(context).primaryColor.withValues(alpha: AppColors.opacitySubtle)
                  : Colors.transparent,
            ),
            child: child,
          ),
        );
      },
    );
  }

}


