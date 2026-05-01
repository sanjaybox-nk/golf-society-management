import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
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
    return BoxyArtAvatar(
      url: (member?.avatarUrl != null && !player.isGuest) ? member!.avatarUrl : null,
      initials: extractInitials(player.name),
      radius: size / 2,
      borderColor: player.isCaptain ? AppColors.amber500 : null,
      borderWidth: player.isCaptain ? 2.0 : null,
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
  final bool useCard;
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
  final String? matchSide; // [NEW] Side A or B for Match Play
  final int? phcOverride;
  final bool hasGuestInGroup; // [NEW] Member who brought a guest
  final bool isEventClosed; // [NEW] surfaced only once admin has confirmed cards and closed the game

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
    this.useCard = true,
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
    this.isStableford = false,
    this.hasGuestInGroup = false,
    this.isEventClosed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    // Single Source of Truth: PHC comes from stored grouping data.
    final int displayPhc = phcOverride ?? player.playingHandicap.round();

    // Calculate Variety Color (Priority: Match Side > Grouping History)
    Color? varietyColor;
    if (matchSide != null && config.showMatchPlayOverlay) {
       // Match Play side coloring removed as per user preference
       varietyColor = null;
    } else if (!player.isGuest) {
      final matchesCount = GroupingService.getTeeTimeVariety(
        player.registrationMemberId,
        group.index,
        totalGroups,
        history,
      );
      if (matchesCount == 0) {
        varietyColor = AppColors.lime600;
      } else if (matchesCount == 1) {
        varietyColor = AppColors.amber500;
      } else {
        varietyColor = AppColors.coral500;
      }
    }

    final theme = Theme.of(context);

    // Score Text Formatting (v4.0 standardized)
    final bool isScramble = rules?.format == CompetitionFormat.scramble;
    final bool hasScore = isScoreMode && (scoreDisplay != null && scoreDisplay != '-') && !isScramble;

    final teeColor = AppColors.getTeeColor(player.teeName, courseConfig?.tees);

    return BoxyArtMemberRow(
      name: player.name,
      secondaryName: (player.isGuest && member != null) ? 'Guest of ${member!.displayName}' : null,
      initials: player.name,
      avatarUrl: member?.avatarUrl,
      handicapIndex: handicapIndex ?? player.handicapIndex,
      playingHandicap: displayPhc,
      isGuest: player.isGuest,
      isCaptain: player.isCaptain,
      hasMemberGuest: hasGuestInGroup,
      isWinner: isWinner,
      matchSide: config.showMatchPlayOverlay ? matchSide : null,
      varietyPillarColor: varietyColor,
      hasSocietyCut: hasSocietyCut,
      thruLabel: thruLabel,
      score: hasScore ? scoreDisplay : null,
      isStableford: isStableford,
      scoreColor: null,
      tieBreakLabel: isEventClosed ? tieBreakLabel : null,
      teeName: player.teeName,
      teeColor: teeColor,
      onTeeTap: isAdmin ? () => onAction?.call('tee', player, group) : null,
      onTap: onTap,
      isSelected: isSelected,
      useCard: useCard,
      showTee: !isScoreMode,
      showVerticalDivider: true,
      showChevron: false,
      accentColor: null,
      leading: isAdmin 
        ? PopupMenuButton<String>(
            onSelected: (val) => onAction?.call(val, player, group),
            color: theme.brightness == Brightness.dark ? AppColors.dark700 : AppColors.pureWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 8,
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'move',
                child: Row(
                  children: [
                    Icon(Icons.drive_file_move_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Move to Group...'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tee',
                child: Row(
                  children: [
                    Icon(Icons.flag_circle_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Change Tee...'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Remove from Group'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'captain',
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Toggle Captain'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'withdraw',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, size: AppShapes.iconSm, color: AppColors.coral500),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Withdraw Member', style: TextStyle(color: AppColors.coral500)),
                  ],
                ),
              ),
            ],
            child: _buildAvatarStack(context, isScoreMode, varietyColor, hasGuestInGroup),
          )
        : null, // BoxyArtMemberRow handles standard avatar if leading is null
    );
  }

  Widget _buildAvatarStack(BuildContext context, bool isScoreMode, Color? varietyColor, bool hasGuestInGroup) {
    
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        BoxyArtAvatar(
          url: member?.avatarUrl,
          initials: extractInitials(player.name),
          radius: 38, // Standardized 76px diameter for premium cards
          isCircle: true,
          borderColor: Colors.transparent, // Removed thin distinguisher borders
          borderWidth: 0,
        ),
        // Host Badge Overlay (Bottom Left)
        if (hasGuestInGroup)
          Positioned(
            bottom: 0,
            left: 0,
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
            bottom: -2,
            right: -2,
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
            bottom: 0,
            left: 0,
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
  final bool isEventClosed; // [NEW]

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
                  fontSize: AppTypography.sizeHeadline, // Increased from sizeLargeBody (18) to 22
                ),
              ),
              BoxyArtPill(
                label: _formatTime(context, group.teeTime),
                icon: Icons.access_time_filled_rounded,
                isAction: true,
                hasHorizontalMargin: false,
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
              
              return GroupingPlayerTile(
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
                scoreDisplay: isScoreMode 
                    ? (playerMatchResults[id]?.status ?? (scoreMap != null ? scoreMap![id] : null)) 
                    : null,
                isWinner: isScoreMode ? (internalWinnerMap[id] ?? false) : false,
                thruLabel: isScoreMode ? (thruMap != null ? thruMap![id] : null) : null,
                tieBreakLabel: isScoreMode ? (tieBreakMap != null ? tieBreakMap![id] : null) : null,
                handicapIndex: hcMap != null ? hcMap![id] : null,
                scoringStatus: (statusMap != null ? statusMap![id] : null) ?? ScoringStatus.ok,
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
                  scoreDisplay: isScoreMode 
                      ? (playerMatchResults[id]?.status ?? (scoreMap != null ? scoreMap![id] : null)) 
                      : null,
                  isWinner: isScoreMode ? (internalWinnerMap[id] ?? false) : false,
                  thruLabel: isScoreMode ? (thruMap != null ? thruMap![id] : null) : null,
                  tieBreakLabel: isScoreMode ? (tieBreakMap != null ? tieBreakMap![id] : null) : null,
                  handicapIndex: hcMap?[id],
                  scoringStatus: statusMap?[id] ?? ScoringStatus.ok,
                  onTap: () => onTapParticipant?.call(p, group),
                  hasSocietyCut: p.hasSocietyCut,
                  hasGuestInGroup: !p.isGuest && group.players.any((other) => other.isGuest && other.registrationMemberId == p.registrationMemberId),
                  useCard: true,
                  phcOverride: (isScramble || rules?.subtype == CompetitionSubtype.foursomes)
                      ? displayTotalHandicap.toInt()
                      : (isScoreMode ? relativePhcMap[id] : null),
                  isStableford: isStableford,
                  isEventClosed: isEventClosed,
                );

                Widget playerWidget = isAdmin ? _wrapWithDraggable(context, p, baseTile) : baseTile;

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
  final String? formatLabel; // [NEW] e.g. "Best 3"

  PodiumEntry({
    required this.name,
    required this.score,
    required this.rank,
    required this.groupIndex,
    this.tieBreakLabel,
    this.formatLabel,
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
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: entries.asMap().entries.map((item) {
              final idx = item.key;
              final entry = item.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: idx == 0 ? 0 : AppSpacing.sm,
                    right: idx == entries.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  child: _buildPodiumCard(context, ref, entry),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard(BuildContext context, WidgetRef ref, PodiumEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);

    Color rankColor = isDark ? AppColors.dark400 : AppColors.dark300;
    if (entry.rank == 1) rankColor = AppColors.amber500;
    if (entry.rank == 2) rankColor = isDark ? AppColors.dark200 : AppColors.dark600;
    if (entry.rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

    return GestureDetector(
      onTap: () => onTap?.call(entry.groupIndex),
      child: BoxyArtCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2l, horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '#${entry.rank}',
              style: AppTypography.label.copyWith(
                color: rankColor,
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              toTitleCase(entry.name),
              textAlign: TextAlign.center,
              style: AppTypography.displaySection.copyWith(
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
                fontSize: 20,
                fontWeight: AppTypography.weightExtraBold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    entry.score,
                    style: AppTypography.displayHeading.copyWith(
                      fontSize: 32,
                      fontWeight: AppTypography.weightBlack,
                      color: Color(config.effectivePointsColor),
                    ),
                  ),
                  if (entry.tieBreakLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        entry.tieBreakLabel!.toUpperCase(),
                        style: AppTypography.micro.copyWith(
                          color: (isDark ? AppColors.pureWhite : AppColors.dark900).withValues(alpha: 0.4),
                          fontWeight: AppTypography.weightBold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  if (entry.formatLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        entry.formatLabel!.toUpperCase(),
                        style: AppTypography.micro.copyWith(
                          fontSize: 8,
                          color: AppColors.dark300,
                          fontWeight: AppTypography.weightExtraBold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
