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
  final bool isStableford;
  final String? matchSide;
  final int? phcOverride;

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
    this.matchSide,
    this.phcOverride,
    this.tieBreakLabel,
    this.thruLabel,
    this.handicapIndex,
    this.scoringStatus = ScoringStatus.ok,
    this.hasSocietyCut = false,
    this.isStableford = true,
    this.hasGuestInGroup = false,
  });

  final bool hasGuestInGroup; // [NEW] Member who brought a guest

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

    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.lg;
    final double cardHeight = vPadding * 4.8; // Increased to 4.8 to prevent vertical overflow with guest info/pills

    // Score Text Formatting (v4.0 standardized)
    final bool hasScore = isScoreMode && (scoreDisplay != null && scoreDisplay != '-');
    final String rawScore = hasScore ? scoreDisplay! : '';

    return InkWell(
      onTap: onTap,
      borderRadius: theme.extension<AppShapeTokens>()?.card ?? AppShapes.lg,
      child: BoxyArtCard(
        // showShadow removed to honor design control
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // 1. Avatar Section (Standardized 72x72)
            Container(
              width: 72,
              constraints: BoxConstraints(minHeight: cardHeight),
              child: isAdmin 
                ? PopupMenuButton<String>(
                    onSelected: (val) => onAction?.call(val, player, group),
                    color: theme.brightness == Brightness.dark ? AppColors.dark700 : AppColors.pureWhite,
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
                    child: _buildAvatarStack(context, isScoreMode, varietyColor, hasGuestInGroup),
                  )
                : _buildAvatarStack(context, isScoreMode, varietyColor, hasGuestInGroup),
            ),

          // 2. Vertical Divider (Scalable)
          Container(
            width: 1,
            height: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: hPadding),
            color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
          ),

          // 3. Right Section: Content
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: cardHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start, // Align with top of divider
                children: [
                  // Section 1: Name
                  Text(
                    toTitleCase(player.name),
                    style: AppTypography.memberName.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (player.isGuest && member != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 3),
                      child: Text(
                        'Guest of ${member!.displayName}',
                        style: AppTypography.label.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  const SizedBox(height: AppSpacing.xs), // Tight spacing under name

                  // Section 2: Handicap Pills (No Icons)
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      BoxyArtPill.hc(
                        label: (handicapIndex ?? player.handicapIndex).toStringAsFixed(1),
                        hasHorizontalMargin: false,
                      ),
                      BoxyArtPill.phc(
                        context: context,
                        label: '$displayPhc',
                        hasHorizontalMargin: false,
                      ),
                      if (hasSocietyCut)
                        BoxyArtPill(
                          label: 'CUT',
                          color: AppColors.coral500,
                          hasHorizontalMargin: true,
                          fontSize: 10,
                          fontWeight: AppTypography.weightBold,
                        ),
                    ],
                  ),

                  const Spacer(),
                  // Section 3: Performance Metrics (Bottom-Right)
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alignment changed to separate left and right
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // Left Side: Thru & Tie-break info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (thruLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                thruLabel!,
                                style: AppTypography.helper.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (thruLabel != null && hasScore && tieBreakLabel != null)
                            const SizedBox(width: AppSpacing.sm),
                          if (hasScore && tieBreakLabel != null)
                            Text(
                              tieBreakLabel!,
                              style: AppTypography.label.copyWith(
                                fontSize: 10,
                                fontWeight: AppTypography.weightBold,
                                color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                                letterSpacing: 0.2,
                              ),
                            ),
                        ],
                      ),

                      // Right Side: Score
                      if (hasScore) ...[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: rawScore,
                                style: AppTypography.displayHeading.copyWith(
                                  fontSize: 26,
                                  fontWeight: AppTypography.weightBlack,
                                  color: theme.colorScheme.primary,
                                  height: 1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (isStableford)
                                TextSpan(
                                  text: ' pts',
                                  style: AppTypography.label.copyWith(
                                    fontSize: 12,
                                    fontWeight: AppTypography.weightMedium,
                                    color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityMedium),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isSelected) 
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 24),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAvatarStack(BuildContext context, bool isScoreMode, Color? varietyColor, bool hasGuestInGroup) {
    
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        BoxyArtAvatar(
          url: member?.avatarUrl,
          initials: player.name,
          radius: 36, // Restored to original size per user request
          isCircle: true,
          borderColor: varietyColor,
          borderWidth: varietyColor != null ? 3.5 : null,
        ),
        // Host Badge Overlay (Bottom Left)
        if (hasGuestInGroup)
          Positioned(
            bottom: -2,
            left: -2,
            child: BoxyArtIconBadge(
              icon: Icons.person_add_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
              iconSize: 14,
              useCircle: true,
            ),
          ),
        // Captain Badge Overlay (Bottom)
        if (player.isCaptain && !player.isGuest)
          Positioned(
            bottom: -4,
            right: -4,
            child: BoxyArtIconBadge(
              icon: Icons.shield_rounded,
              color: AppColors.amber500,
              size: 24,
              iconSize: 14,
              useCircle: true,
            ),
          ),
        // Guest Icon Overlay (Bottom Left)
        if (player.isGuest)
          Positioned(
            bottom: -2,
            left: -2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.amber500,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  color: AppColors.dark900,
                  fontSize: 12,
                  fontWeight: AppTypography.weightExtraBold,
                ),
              ),
            ),
          ),
      ],
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



    // [NEW] Relative PHC Map for Match Play formats
    final Map<String, int> relativePhcMap = phcMap != null
        ? Map.from(phcMap!)
        : {};


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

          }
        } else if (!isSplitTeam) {
          // Standard Scramble (One Team)
          // Score is shared, so just take the first one found

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

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    // --- PRE-CALCULATE TIES FOR DISPLAY ---
    final Map<String, String?> playerScoresForTies = {};
    final Map<String, int> scoreFreq = {};
    for (var p in group.players) {
      final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
      final score = scoreMap?[id];
      if (score != null && score != '-') {
        playerScoresForTies[id] = score;
        scoreFreq[score] = (scoreFreq[score] ?? 0) + 1;
      }
    }

    // --- PRE-CALCULATE GROUP SCORING ---
    // Reuse existing isStableford and bestX defined above
    int groupTotalCount = 0;
    if (showScoring && isScoreMode && scoreMap != null) {
      final List<int> groupScores = [];
      for (var p in group.players) {
        final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final s = scoreMap![id];
        if (s != null && s != '-') {
          final val = int.tryParse(s);
          if (val != null) groupScores.add(val);
        }
      }
      if (groupScores.isNotEmpty) {
        if (bestX < groupScores.length) {
          groupScores.sort((a, b) => b.compareTo(a));
          groupTotalCount = groupScores.take(bestX).fold(0, (sum, val) => sum + val);
        } else {
          groupTotalCount = groupScores.fold(0, (sum, val) => sum + val);
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: (spacing?.cardToLabel ?? AppSpacing.lg) * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GROUP ${group.index + 1}',
                  style: AppTypography.displaySection.copyWith(
                    color: isDark ? AppColors.pureWhite : AppColors.dark900,
                    fontWeight: AppTypography.weightExtraBold,
                    fontSize: 18, // Slightly smaller than standard displaySection for cards
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
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

              // Calculate Tie-Break Differentiator (Only if tied)
              String? relevantTieBreak;
              if (showScoring && isScoreMode) {
                final score = playerScoresForTies[id];
                if (score != null && (scoreFreq[score] ?? 0) > 1) {
                  // Find all players with this same score in THIS group
                  final tiedIds = playerScoresForTies.entries
                      .where((e) => e.value == score)
                      .map((e) => e.key)
                      .toList();
                  
                  if (tiedIds.length > 1) {
                    final labels = tiedIds.map((tid) => tieBreakMap?[tid] ?? '').toList();
                    final segmentsList = labels.map((l) => l.split(RegExp(r'[,•]')).map((s) => s.trim()).toList()).toList();
                    
                    int diffIndex = 0;
                    int maxSegs = segmentsList.isEmpty ? 0 : segmentsList[0].length;
                    
                    for (int i = 0; i < maxSegs; i++) {
                      final currentVals = segmentsList.map((list) => i < list.length ? list[i] : '').toSet();
                      if (currentVals.length > 1) {
                        diffIndex = i;
                        break;
                      }
                    }
                    
                    final mySegments = (tieBreakMap?[id] ?? '').split(RegExp(r'[,•]')).map((s) => s.trim()).toList();
                    if (diffIndex < mySegments.length) {
                      relevantTieBreak = mySegments[diffIndex];
                    }
                  }
                }
              }

              final ScoringStatus status = statusMap?[id] ?? ScoringStatus.ok;

              // Check if this player is a member who HAS a guest in this group
              final bool hasGuestInGroup = !p.isGuest && group.players.any((other) => 
                  other.isGuest && other.registrationMemberId == p.registrationMemberId);

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
                isScoreMode: isScoreMode,
                scoreDisplay: showScoring ? scoreForTile : null,
                isWinner: showScoring ? (internalWinnerMap[id] ?? false) : false,
                tieBreakLabel: relevantTieBreak,
                thruLabel: showScoring ? (thruMap?[id]) : null,
                handicapIndex: hcMap?[id],
                scoringStatus: status,
                onTap: () => onTapParticipant?.call(p, group),
                hasSocietyCut: p.hasSocietyCut,
                hasGuestInGroup: hasGuestInGroup,
              );

              final isLast = index == group.players.length - 1;
              final playerWidget = isAdmin
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
                  if (!isLast) SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
                ],
              );
            }),

            if (isAdmin && group.players.length < 4)
              emptySlotBuilder?.call(group) ?? const SizedBox.shrink(),
            
            // Sub-Card Spacing
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
            
            // Footer (Group Total & PHC)
            Padding(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showScoring && isScoreMode && groupTotalCount > 0)
                    Text(
                      isScramble
                          ? 'Team Score: $groupTotalCount${isStableford ? ' pts' : ''}'
                          : 'Group (Best $bestX): $groupTotalCount${isStableford ? ' pts' : ''}',
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: AppTypography.weightExtraBold,
                        fontSize: 12,
                        letterSpacing: -0.2,
                      ),
                    ),
                  const Spacer(),
                  if (isFourball)
                    Text(
                      rules?.format == CompetitionFormat.matchPlay
                          ? 'Match Play (Rel)'
                          : 'Fourball (Pairs)',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.dark100 : AppColors.dark900,
                        fontWeight: AppTypography.weightBold,
                        fontSize: 12,
                        letterSpacing: -0.2,
                      ),
                    )
                  else if (isScramble)
                    BoxyArtPill.phc(context: context, label: 'Team: ${displayTotalHandicap.toInt()}', hasHorizontalMargin: false)
                  else
                    BoxyArtPill.phc(context: context, label: 'Total: ${displayTotalHandicap.toInt()}', hasHorizontalMargin: false),
                ],
              ),
            ),
          ],
        ),
      );
    }



  String _formatTime(BuildContext context, DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
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
              member: memberMap[p.registrationMemberId],
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

class PodiumEntry {
  final String name;
  final String score;
  final int rank;
  final int groupIndex; // [NEW] Link to actual group
  final String? tieBreakLabel;

  PodiumEntry({
    required this.name,
    required this.score,
    required this.rank,
    required this.groupIndex,
    this.tieBreakLabel,
  });
}

class GroupingPodiumHeader extends ConsumerWidget {
  final List<PodiumEntry> entries;
  final Function(int groupIndex)? onTap; // [NEW] Callback for scrolling

  const GroupingPodiumHeader({
    super.key,
    required this.entries,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.standard),
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

    Color rankColor = isDark ? AppColors.dark400 : AppColors.dark300;
    if (entry.rank == 1) rankColor = AppColors.amber500;
    if (entry.rank == 2) rankColor = isDark ? AppColors.dark200 : AppColors.dark600;
    if (entry.rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

    return GestureDetector(
      onTap: () => onTap?.call(entry.groupIndex),
      child: BoxyArtCard(
        padding: EdgeInsets.zero,
        showShadow: false,
        border: Border.all(
          color: isFirst 
              ? AppColors.amber500.withValues(alpha: 0.3) 
              : (isDark ? AppColors.dark500 : AppColors.lightBorder), 
          width: AppShapes.borderThin,
        ),
        backgroundColor: isDark ? AppColors.dark150 : AppColors.pureWhite,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Ranking Accent (Left)
              Container(
                width: 1.5,
                margin: const EdgeInsets.symmetric(vertical: 0),
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppShapes.rMd),
                    bottomLeft: Radius.circular(AppShapes.rMd),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // 2. Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg), // Increased from md
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '#${entry.rank}',
                            style: AppTypography.label.copyWith(
                              color: rankColor,
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: AppTypography.weightBlack,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs), // Standardize gap
                      Text(
                        toTitleCase(entry.name),
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          fontWeight: AppTypography.weightExtraBold,
                          fontSize: 13,
                          color: isDark ? AppColors.dark150 : AppColors.dark400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.md), // Added space between name and score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (entry.tieBreakLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                entry.tieBreakLabel!,
                                style: AppTypography.label.copyWith(
                                  fontSize: 10,
                                  fontWeight: AppTypography.weightBold,
                                  color: isDark ? AppColors.dark400 : AppColors.dark500,
                                ),
                              ),
                            ),
                          Text(
                            entry.score,
                            style: AppTypography.displaySection.copyWith(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 22,
                              height: 1.1,
                              fontWeight: AppTypography.weightExtraBold,
                              letterSpacing: -0.5,
                              color: isDark ? AppColors.pureWhite : AppColors.dark900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
