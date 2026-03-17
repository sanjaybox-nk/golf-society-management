import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/course_config.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/match_play_calculator.dart';

class GroupingPlayerAvatar extends StatelessWidget {
  final TeeGroupParticipant player;
  final Member? member;
  final double size;
  final int? groupIndex;
  final int? totalGroups;
  final List<GolfEvent>? history;

  const GroupingPlayerAvatar({
    super.key,
    required this.player,
    this.member,
    this.size = 40,
    this.groupIndex,
    this.totalGroups,
    this.history,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool hasProfilePic = member?.avatarUrl != null && !player.isGuest;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: player.isCaptain
          ? AppColors.amber500
          : (isDark ? AppColors.dark600 : AppColors.dark60),
      backgroundImage: hasProfilePic
          ? NetworkImage(member!.avatarUrl!)
          : null,
      child: !hasProfilePic
          ? Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: player.isCaptain 
                    ? AppColors.pureWhite 
                    : (isDark ? AppColors.dark100 : AppColors.dark900),
                fontWeight: AppTypography.weightBlack,
                fontSize: size * 0.4,
              ),
            )
          : null,
    );
  }
}

class GroupingPlayerTile extends ConsumerWidget {
  final TeeGroupParticipant player;
  final TeeGroup group;
  final Member? member;
  final List<GolfEvent> history;
  final int totalGroups;
  final CompetitionRules? rules;
  final CourseConfig? courseConfig;
  final bool useWhs;
  final bool isAdmin;
  final Function(String action, TeeGroupParticipant p, TeeGroup g)? onAction;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool hasGuest;
  final bool isScoreMode;
  final String? scoreDisplay;
  final bool isWinner;
  final String? tieBreakLabel;
  final String? thruLabel;
  final double? handicapIndex;
  final ScoringStatus scoringStatus;
  final bool hasSocietyCut;

  const GroupingPlayerTile({
    super.key,
    required this.player,
    required this.group,
    this.member,
    required this.history,
    required this.totalGroups,
    this.rules,
    this.courseConfig,
    this.useWhs = true,
    this.isAdmin = false,
    this.onAction,
    this.onTap,
    this.isSelected = false,
    this.hasGuest = false,
    this.isScoreMode = false,
    this.scoreDisplay,
    this.isWinner = false,
    this.matchSide, // 'A' or 'B'
    this.phcOverride, // [NEW] Explicit override for team games
    this.tieBreakLabel,
    this.thruLabel,
    this.handicapIndex,
    this.scoringStatus = ScoringStatus.ok,
    this.hasSocietyCut = false,
  });

  final String? matchSide;
  final int? phcOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Single Source of Truth: PHC comes from stored grouping data.
    final int displayPhc = phcOverride ?? player.playingHandicap.round();

    // Calculate Variety Color for card accent bar
    Color? varietyColor;
    if (!player.isGuest) {
      final matches = GroupingService.getTeeTimeVariety(
        player.registrationMemberId,
        group.index,
        totalGroups,
        history,
      );
      if (matches == 0) {
        varietyColor = AppColors.lime600;
      } else if (matches == 1) {
        varietyColor = AppColors.amber500;
      } else {
        varietyColor = AppColors.coral500;
      }
    }

    // 1. Build Leading (Avatar + Context Menu if Admin)
    final Widget avatar = GroupingPlayerAvatar(
      player: player,
      member: member,
      groupIndex: group.index,
      totalGroups: totalGroups,
      history: history,
      size: 36,
    );

    final Widget leading = isAdmin
        ? PopupMenuButton<String>(
            onSelected: (val) => onAction?.call(val, player, group),
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark700 : AppColors.pureWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 8,
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'move',
                child: Row(
                  children: [
                    Icon(Icons.drive_file_move_outlined, size: AppShapes.iconSm),
                    SizedBox(width: AppSpacing.md),
                    Text('Move to Group...'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_outlined, size: AppShapes.iconSm),
                    SizedBox(width: AppSpacing.md),
                    Text('Remove from Group'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'captain',
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: AppShapes.iconSm),
                    SizedBox(width: AppSpacing.md),
                    Text('Toggle Captain'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'withdraw',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, size: AppShapes.iconSm, color: AppColors.coral500),
                    SizedBox(width: AppSpacing.md),
                    Text('Withdraw Member', style: TextStyle(color: AppColors.coral500)),
                  ],
                ),
              ),
            ],
            child: avatar,
          )
        : avatar;

    return BoxyArtMemberRow(
      name: player.name,
      initials: player.name,
      avatarUrl: member?.avatarUrl,
      leading: leading,
      handicapIndex: handicapIndex ?? player.handicapIndex,
      playingHandicap: displayPhc,
      score: isScoreMode 
          ? (scoringStatus != ScoringStatus.ok 
              ? scoringStatus.name.toUpperCase() 
              : (scoreDisplay ?? '-')) 
          : null,
      scoreColor: scoringStatus != ScoringStatus.ok ? AppColors.coral500 : null,
      tieBreakLabel: tieBreakLabel,
      thruLabel: thruLabel,
      isGuest: player.isGuest,
      isCaptain: player.isCaptain,
      needsBuggy: false, // [REFINED] Removed clutter from grouping view
      isWinner: isScoreMode && isWinner,
      matchSide: matchSide,
      hasSocietyCut: hasSocietyCut,
      isSelected: isSelected,
      onTap: onTap,
      useCard: true,
      showChevron: isAdmin,
      accentColor: varietyColor,
    );
  }
}

class GroupingCard extends StatelessWidget {
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
  final Map<String, String>? betterBallMap;
  final Map<String, String>? tieBreakMap;
  final Map<String, String>? thruMap;
  final Map<String, double>? hcMap;
  final Map<String, ScoringStatus>? statusMap;
  final int? groupIndex;
  final bool showScoring; // [NEW] Master toggle for hiding all scores/winners in organization views

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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Recalculate Total PHC dynamically to respect capping rules
    double displayTotalHandicap = 0;
    if (rules != null) {
      final isScramble = rules!.format == CompetitionFormat.scramble;
      final isFoursomes = rules!.subtype == CompetitionSubtype.foursomes;

      if (isScramble || isFoursomes) {
        // Use Team PHC calculation (Aggregate)
        final List<double> indices = group.players
            .map((p) => p.handicapIndex)
            .toList();
        displayTotalHandicap = HandicapCalculator.calculateTeamHandicap(
          individualIndices: indices,
          rules: rules!,
          courseConfig: courseConfig ?? const CourseConfig(),
        ).toDouble();
      } else {
        // Individual Sum (Singles, Fourball, etc.)
        for (var p in group.players) {
          final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
          final livePhc = phcMap?[id];
          displayTotalHandicap += livePhc?.toDouble() ?? p.playingHandicap;
        }
      }
    } else {
      displayTotalHandicap = group.totalHandicap.roundToDouble();
    }

    // --- Scoring Mode Logic (Winners & Team Total) ---
    final isStableford = rules?.format == CompetitionFormat.stableford;
    final isScramble = rules?.format == CompetitionFormat.scramble;
    final isFourball = rules?.subtype == CompetitionSubtype.fourball;
    final int bestX = rules?.teamBestXCount ?? 2;
    int groupTotal = 0;

    // [NEW] Relative PHC Map for Match Play formats
    final Map<String, int> relativePhcMap = phcMap != null
        ? Map.from(phcMap!)
        : {};
    String? matchStatus;
    // 1. Determine Relative PHCs (Subracting min) - ONLY for Match Play
    final isMatchPlay = rules?.format == CompetitionFormat.matchPlay;
    if (isMatchPlay && rules != null) {
      final List<String> playerIds = group.players.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList();
      final Map<String, double> playerIndices = { for (var p in group.players) (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) : p.handicapIndex };
      
      // GroupingCard already has access to courseConfig and rules
      final baseRating = courseConfig?.rating ?? 72.0;
      
      final Map<String, int> centralizedStrokes = MatchPlayCalculator.calculateRelativeStrokes(
        playerIds: playerIds,
        playerIndices: playerIndices,
        courseConfigs: { for (var id in playerIds) id : courseConfig ?? const CourseConfig() }, // Assuming same config for all in this simplified view
        rules: rules!,
        baseRating: baseRating,
      );
      
      relativePhcMap.addAll(centralizedStrokes);
    }

    // 2. Calculate Match Status (Live) - Only for Fourball Match Play
    MatchResult? matchResult;
    if (isScoreMode && scorecardMap != null && isMatchPlay) {
      final team1Ids = group.players
          .take(2)
          .map(
            (p) => p.isGuest
                ? '${p.registrationMemberId}_guest'
                : p.registrationMemberId,
          )
          .toList();
      final team2Ids = group.players
          .skip(2)
          .take(2)
          .map(
            (p) => p.isGuest
                ? '${p.registrationMemberId}_guest'
                : p.registrationMemberId,
          )
          .toList();

      if (team1Ids.isNotEmpty && team2Ids.isNotEmpty) {
        final virtualMatch = MatchDefinition(
          id: 'virtual_${group.index}',
          type: MatchType.fourball,
          team1Ids: team1Ids,
          team2Ids: team2Ids,
          strokesReceived: relativePhcMap,
        );

        final groupCards = scorecardMap!.values
            .where(
              (s) =>
                  team1Ids.contains(s.entryId) || team2Ids.contains(s.entryId),
            )
            .toList();

        if (groupCards.isNotEmpty) {
          matchResult = MatchPlayCalculator.calculate(
            match: virtualMatch,
            scorecards: groupCards,
            courseConfig: courseConfig ?? const CourseConfig(),
            holesToPlay: 18,
          );
          matchStatus = matchResult.status;
        }
      }
    }

    // Split Team Logic (e.g. 2-Man Scramble in a 4-Ball, or any Pairs competition)
    final bool isSplitTeam =
        ((isScramble && rules?.teamSize == 2) ||
            (rules?.mode == CompetitionMode.pairs) ||
            isFourball) &&
        group.players.length >= 3;

    int teamAScore = 0;
    int teamBScore = 0;
    bool hasScoreA = false;
    bool hasScoreB = false;

    final Map<String, bool> internalWinnerMap = winnerMap != null
        ? Map.from(winnerMap!)
        : {};

    if (isScoreMode && scoreMap != null) {
      final List<MapEntry<String, int>> playerScores = [];

      int parseScore(String text) {
        if (text == 'E') return 0;
        final clean = text.replaceAll('+', '').trim();
        return int.tryParse(clean) ?? (isStableford ? 0 : 999);
      }

      for (int i = 0; i < group.players.length; i++) {
        final p = group.players[i];
        final id = p.isGuest
            ? '${p.registrationMemberId}_guest'
            : p.registrationMemberId;
        final scoreText = scoreMap![id];

        if (scoreText != null && scoreText != '-') {
          final score = parseScore(scoreText);
          playerScores.add(MapEntry(id, score));

          // Split Team Accumulation (Fourball/Pairs)
          if (isSplitTeam) {
            if (i < 2) {
              // Team A
              if (isScramble) {
                teamAScore = score; // Shared score
              } else {
                teamAScore = hasScoreA ? math.max(teamAScore, score) : score;
              }
              hasScoreA = true;
            } else {
              // Team B
              if (isScramble) {
                teamBScore = score;
              } else {
                teamBScore = hasScoreB ? math.max(teamBScore, score) : score;
              }
              hasScoreB = true;
            }
          }
        }
      }

      if (playerScores.isNotEmpty) {
        if (!isScramble) {
          // Find individual winners in group (Standard Format)
          // If Stableford: Higher is better. If Strokeplay/MaxScore: Lower is better.
          if (isStableford) {
            playerScores.sort((a, b) => b.value.compareTo(a.value));
          } else {
            // Strokeplay/MaxScore/etc: Lower is better
            playerScores.sort((a, b) => a.value.compareTo(b.value));
          }

          // Only mark the first one as the winner to avoid showing multiple trophies in a group
          if (playerScores.isNotEmpty) {
            internalWinnerMap[playerScores.first.key] = true;
          }

          // Calculate Group Total (Best X)
          final count = playerScores.length < bestX
              ? playerScores.length
              : bestX;
          for (int i = 0; i < count; i++) {
            groupTotal += playerScores[i].value;
          }
        } else if (!isSplitTeam) {
          // Standard Scramble (One Team)
          // Score is shared, so just take the first one found
          groupTotal = playerScores.isNotEmpty ? playerScores.first.value : 0;
        } else {
          // Fourball/Pairs: Use better-ball of side A and B to find winner if needed
          if (hasScoreA && hasScoreB) {
            if (isStableford) {
              if (teamAScore > teamBScore) {
                for (final p in group.players.take(2)) {
                  internalWinnerMap[p.isGuest
                          ? '${p.registrationMemberId}_guest'
                          : p.registrationMemberId] =
                      true;
                }
              } else if (teamBScore > teamAScore) {
                for (final p in group.players.skip(2).take(2)) {
                  internalWinnerMap[p.isGuest
                          ? '${p.registrationMemberId}_guest'
                          : p.registrationMemberId] =
                      true;
                }
              }
            } else {
              // Stroke/Medal: Lower is better
              if (teamAScore < teamBScore) {
                for (final p in group.players.take(2)) {
                  internalWinnerMap[p.isGuest
                          ? '${p.registrationMemberId}_guest'
                          : p.registrationMemberId] =
                      true;
                }
              } else if (teamBScore < teamAScore) {
                for (final p in group.players.skip(2).take(2)) {
                  internalWinnerMap[p.isGuest
                          ? '${p.registrationMemberId}_guest'
                          : p.registrationMemberId] =
                      true;
                }
              }
            }
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GROUP ${group.index + 1}',
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.dark150 : AppColors.dark900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.actionGreen,
                    borderRadius: AppShapes.xl,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: AppShapes.iconXs,
                        color: AppColors.pureWhite,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(context, group.teeTime),
                        style: AppTypography.label.copyWith(
                          color: AppColors.pureWhite,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // --- PLAYERS LIST ---
            ...group.players.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;

              // Check if this player is a member who HAS a guest in this group

              final id = p.isGuest
                  ? '${p.registrationMemberId}_guest'
                  : p.registrationMemberId;

              String? matchSide;
              if (matchPlayMode) {
                // 1. Check for explicit Match Definition link
                for (final match in matches) {
                  if (match.team1Ids.contains(p.registrationMemberId)) {
                    matchSide = 'A';
                    break;
                  } else if (match.team2Ids.contains(p.registrationMemberId)) {
                    matchSide = 'B';
                    break;
                  }
                }
                // 2. Fallback to Group Index (0-1 = A, 2-3 = B) for Fourball match play
                if (matchSide == null && isFourball) {
                  matchSide = index < 2 ? 'A' : 'B';
                }
              }

              String? scoreForTile;
              if (matchPlayMode && matchResult != null && matchSide != null) {
                final int lead = matchSide == 'A'
                    ? matchResult.score
                    : -matchResult.score;
                final int remaining = 18 - matchResult.holesPlayed;

                if (lead > 0) {
                  if (lead > remaining) {
                    scoreForTile = remaining > 0
                        ? 'WIN $lead & $remaining'
                        : 'WIN $lead UP';
                  } else {
                    scoreForTile = '$lead UP';
                  }
                } else if (lead < 0) {
                  final dn = lead.abs();
                  if (dn > remaining) {
                    scoreForTile = remaining > 0
                        ? 'LOSS $dn & $remaining'
                        : 'LOSS $dn DN';
                  } else {
                    scoreForTile = '$dn DN';
                  }
                } else {
                  scoreForTile = remaining == 0 ? 'HALVED' : 'AS';
                }
              } else {
                scoreForTile = scoreMap?[id];
              }

              final ScoringStatus status = statusMap?[id] ?? ScoringStatus.ok;

              final baseTile = GroupingPlayerTile(
                player: p,
                group: group,
                member: memberMap[p.registrationMemberId],
                history: history,
                totalGroups: totalGroups,
                rules: rules,
                courseConfig: courseConfig,
                useWhs: useWhs,
                isAdmin: isAdmin,
                isSelected: isSelected?.call(p) ?? false,
                onAction: onAction,
                scoreDisplay: showScoring ? scoreForTile : null,
                isWinner: showScoring ? (internalWinnerMap[id] ?? false) : false,
                tieBreakLabel: showScoring ? (tieBreakMap?[id]) : null,
                thruLabel: showScoring ? (thruMap?[id]) : null,
                handicapIndex: hcMap?[id],
                scoringStatus: status,
                onTap: () => onTapParticipant?.call(p, group),
                hasSocietyCut: p.hasSocietyCut,
              );

              final isLast = index == group.players.length - 1;
              final playerWidget = isAdmin && !isLocked
                  ? _wrapWithDraggable(context, p, baseTile)
                  : baseTile;

              // [SPLIT TEAM DIVIDER]
              // If Split Team mode, add a divider after the 2nd player (index 1)
              if (isSplitTeam && index == 1) {
                return Column(
                  children: [
                    playerWidget,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md), // Increased for split team separation
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.dark400,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontSize: AppTypography.sizeCaption,
                                fontWeight: AppTypography.weightBold,
                                color: Colors.black.withValues(alpha: 0.54),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.dark400,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  playerWidget,
                  if (!isLast) const SizedBox(height: AppSpacing.md),
                ],
              );
            }),

            if (isAdmin && group.players.length < 4)
              emptySlotBuilder?.call(group) ?? const SizedBox.shrink(),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isScoreMode && showScoring)
                  Expanded(
                    child: _buildScoreFooter(
                      context,
                      isStableford,
                      isScramble,
                      isSplitTeam,
                      groupTotal,
                      bestX,
                      teamAScore,
                      teamBScore,
                      hasScoreA,
                      hasScoreB,
                      matchStatus,
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isFourball
                      ? (rules?.format == CompetitionFormat.matchPlay
                            ? 'Match Play (Rel)'
                            : 'Fourball (Pairs)')
                      : (isScramble
                            ? 'Team PHC: ${displayTotalHandicap.toInt()}'
                            : 'Total PHC: ${displayTotalHandicap.toInt()}'),
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.dark100 : AppColors.dark900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreFooter(
    BuildContext context,
    bool isStableford,
    bool isScramble,
    bool isSplitTeam,
    int groupTotal,
    int bestX,
    int scoreA,
    int scoreB,
    bool hasScoreA,
    bool hasScoreB,
    String? matchStatus,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String formatScore(int val) {
      return !isStableford && val == 0
          ? "E"
          : (!isStableford && val > 0 ? "+$val" : val.toString());
    }

    if (isSplitTeam) {
      // For fourball with betterBallMap, show BB pills in pair colors
      final isFourball = rules?.subtype == CompetitionSubtype.fourball;
      if (isFourball && betterBallMap != null && groupIndex != null) {
        final bbA = betterBallMap!['g${groupIndex}_a'];
        final bbB = betterBallMap!['g${groupIndex}_b'];
        return Row(
          children: [
            if (matchStatus != null) ...[
              Text(
                'Status: ',
                style: AppTypography.label.copyWith(
                  color: AppColors.dark700,
                ),
              ),
              Text(
                matchStatus,
                style: const TextStyle(
                  color: AppColors.lime500,
                  fontSize: AppTypography.sizeLabel,
                  fontWeight: AppTypography.weightBlack,
                  letterSpacing: 0.2,
                ),
              ),
              // Remove trailing divider if A/B scores are hidden
            ],
            if (matchStatus == null) ...[
              Text(
                'A:',
                style: AppTypography.label.copyWith(
                  color: AppColors.amber500,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber500.withValues(alpha: AppColors.opacitySubtle),
                  borderRadius: AppShapes.md,
                ),
                child: Text(
                  bbA ?? '-',
                  style: TextStyle(
                    color: AppColors.amber500,
                    fontWeight: AppTypography.weightBlack,
                    fontSize: AppTypography.sizeLabelStrong,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'B:',
                style: AppTypography.label.copyWith(
                  color: AppColors.teamA,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teamA.withValues(alpha: AppColors.opacitySubtle),
                  borderRadius: AppShapes.md,
                ),
                child: Text(
                  bbB ?? '-',
                  style: TextStyle(
                    color: AppColors.teamA,
                    fontWeight: AppTypography.weightBlack,
                    fontSize: AppTypography.sizeLabelStrong,
                  ),
                ),
              ),
            ],
          ],
        );
      }
      // Non-fourball split team (e.g. 2-man scramble)
      return Row(
        children: [
          if (matchStatus != null) ...[
            Text(
              'Status: ',
              style: TextStyle(
                color: AppColors.dark700,
                fontSize: AppTypography.sizeCaptionStrong,
                fontWeight: AppTypography.weightSemibold,
              ),
            ),
            Text(
              matchStatus,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: AppTypography.sizeLabel,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: AppShapes.borderThin,
              height: AppSpacing.md,
              color: AppColors.dark300.withValues(alpha: AppColors.opacityHalf),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (matchStatus == null) ...[
            Text(
              'A:',
              style: AppTypography.label.copyWith(
                color: AppColors.dark700,
              ),
            ),
            const SizedBox(width: AppShapes.borderMedium),
            Text(
              hasScoreA ? formatScore(scoreA) : '-',
              style: TextStyle(
                color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityHigh),
                fontSize: AppTypography.sizeCaptionStrong,
                fontWeight: AppTypography.weightBlack,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: AppShapes.borderThin,
              height: AppSpacing.md,
              color: AppColors.dark300.withValues(alpha: AppColors.opacityHalf),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'B:',
              style: AppTypography.label.copyWith(
                color: AppColors.dark700,
              ),
            ),
            const SizedBox(width: AppShapes.borderMedium),
            Text(
              hasScoreB ? formatScore(scoreB) : '-',
              style: TextStyle(
                color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityHigh),
                fontSize: AppTypography.sizeCaptionStrong,
                fontWeight: AppTypography.weightBlack,
              ),
            ),
          ],
        ],
      );
    }

    Widget mainScore = Text(
      isScramble
          ? 'Team Score: ${formatScore(groupTotal)}'
          : 'Group Total (Best $bestX): ${formatScore(groupTotal)}',
      style: AppTypography.label.copyWith(
        color: isDark ? AppColors.pureWhite : AppColors.dark900,
      ),
    );

    // [NEW] Display Scramble Weighting Rule for transparency
    if (isScramble && (rules?.useWHSScrambleAllowance ?? false)) {
      final teamCount = group.players
          .where((p) => p.registrationMemberId != '')
          .length; // Adjusted check
      String weightInfo = "";
      if (teamCount == 4) {
        weightInfo = "WHS 25/20/15/10%";
      } else if (teamCount == 3) {
        weightInfo = "WHS 30/20/10%";
      } else if (teamCount == 2) {
        weightInfo = "WHS 35/15%";
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainScore,
          if (weightInfo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                weightInfo,
                style: TextStyle(
                  color: AppColors.dark500,
                  fontSize: AppTypography.sizeCaption,
                  fontWeight: AppTypography.weightSemibold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      );
    }

    return mainScore;
  }

  String _formatTime(BuildContext context, DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  Widget _wrapWithDraggable(
    BuildContext context,
    TeeGroupParticipant p,
    Widget child,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) =>
          !isLocked && details.data['player'] != p,
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
              member: memberMap[p.registrationMemberId],
              size: AppShapes.iconHero,
              groupIndex: group.index,
              totalGroups: totalGroups,
              history: history,
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: child),
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

class PodiumEntry {
  final String name;
  final String score;
  final int rank;
  final int groupIndex; // [NEW] Link to actual group

  PodiumEntry({
    required this.name,
    required this.score,
    required this.rank,
    required this.groupIndex,
  });
}

class GroupingPodiumHeader extends StatelessWidget {
  final List<PodiumEntry> entries;
  final Function(int groupIndex)? onTap; // [NEW] Callback for scrolling

  const GroupingPodiumHeader({
    super.key,
    required this.entries,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Top Results'),
          Row(
            children: entries.asMap().entries.map((item) {
              final idx = item.key;
              final entry = item.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: idx == 0 ? 0 : 4,
                    right: idx == entries.length - 1 ? 0 : 4,
                  ),
                  child: _buildPodiumCard(context, entry),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard(BuildContext context, PodiumEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isFirst = entry.rank == 1;

    Color rankColor = AppColors.dark300;
    if (entry.rank == 1) rankColor = AppColors.amber500;
    if (entry.rank == 2) rankColor = isDark ? AppColors.dark150 : AppColors.dark500;
    if (entry.rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

    return GestureDetector(
      onTap: () => onTap?.call(entry.groupIndex),
      child: BoxyArtCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
        showShadow: false,
        border: isFirst
            ? Border.all(color: AppColors.amber500.withValues(alpha: 0.5), width: AppShapes.borderMedium)
            : Border.all(color: isDark ? AppColors.dark500 : AppColors.lightBorder, width: AppShapes.borderThin),
        backgroundColor: isDark ? AppColors.dark700 : AppColors.pureWhite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isFirst)
                  const Icon(Icons.emoji_events_rounded,
                      size: 14, color: AppColors.amber500),
                if (isFirst) const SizedBox(width: 4),
                Text(
                  '#${entry.rank}',
                  style: AppTypography.label.copyWith(
                    color: rankColor,
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: AppTypography.weightSemibold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              toTitleCase(entry.name),
              style: AppTypography.caption.copyWith(
                fontWeight: AppTypography.weightExtraBold,
                fontSize: 15,
                color: isDark ? AppColors.dark150 : AppColors.dark400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              entry.score,
              style: AppTypography.displaySection.copyWith(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                height: 1.1,
                letterSpacing: -0.5,
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
