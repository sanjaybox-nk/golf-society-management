import 'package:flutter/material.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/utils/handicap_calculator.dart'; // Ensure imported
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/member.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/competition.dart';
import '../../../../models/scorecard.dart';
// import '../../../../core/utils/tie_breaker_logic.dart';
import '../../domain/registration_logic.dart';
import '../../../matchplay/domain/match_definition.dart';

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
    final bool hasProfilePic = member?.avatarUrl != null && !player.isGuest;

    Color borderColor = Colors.transparent;
    String varietyTooltip = 'Fresh slot variety';

    if (groupIndex != null && totalGroups != null && history != null && !player.isGuest) {
      final matches = GroupingService.getTeeTimeVariety(player.registrationMemberId, groupIndex!, totalGroups!, history!);
      if (matches == 0) {
        borderColor = Colors.green;
        varietyTooltip = 'Good slot variety';
      } else if (matches == 1) {
        borderColor = Colors.amber;
        varietyTooltip = 'Played in this slot in 1 of last 3 events';
      } else {
        borderColor = Colors.red;
        varietyTooltip = 'Played in this slot in $matches of last 3 events';
      }
    }

    return Tooltip(
      message: varietyTooltip,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != Colors.transparent 
            ? Border.all(color: borderColor, width: 2.5) 
            : null,
        ),
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: player.isCaptain ? Colors.orange : Colors.grey.shade200,
          backgroundImage: hasProfilePic ? NetworkImage(member!.avatarUrl!) : null,
          child: !hasProfilePic
              ? Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: player.isCaptain ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.4,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class GroupingPlayerTile extends StatelessWidget {
  final TeeGroupParticipant player;
  final TeeGroup group;
  final Member? member;
  final List<GolfEvent> history;
  final int totalGroups;
  final CompetitionRules? rules;
  final Map<String, dynamic>? courseConfig;
  final bool useWhs;
  final bool isAdmin;
  final Function(String action, TeeGroupParticipant p, TeeGroup g)? onAction;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool hasGuest;
  final bool isScoreMode;
  final String? scoreDisplay;
  final bool isWinner;

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
  });

  final String? matchSide;
  final int? phcOverride;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Recalculate PHC if rules are available (to respect caps and allowances)
    int displayPhc = phcOverride ?? player.playingHandicap.round();
    if (rules != null && phcOverride == null) {
      displayPhc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: player.handicapIndex,
        rules: rules!,
        courseConfig: courseConfig ?? {}, 
        useWhs: useWhs,
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
            ? Border.all(color: primaryColor, width: 2) 
            : (matchSide != null 
                ? Border.all(color: matchSide == 'A' ? Colors.orange.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.5), width: 1.5)
                : Border.all(color: Colors.black.withValues(alpha: 0.03), width: 1)),
        ),
        child: Row(
          children: [
            if (!isScoreMode)
              (!isAdmin 
                  ? GroupingPlayerAvatar(
                      player: player, 
                      member: member, 
                      groupIndex: group.index, 
                      totalGroups: totalGroups, 
                      history: history,
                      size: 36,
                    )
                  : PopupMenuButton<String>(
                      onSelected: (val) => onAction?.call(val, player, group),
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 8,
                      offset: const Offset(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'move', child: Row(children: [Icon(Icons.drive_file_move_outlined, size: 18), SizedBox(width: 12), Text('Move to Group...')])),
                        const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.person_remove_outlined, size: 18), SizedBox(width: 12), Text('Remove from Group')])),
                        const PopupMenuItem(
                          value: 'withdraw', 
                          child: Row(children: [Icon(Icons.exit_to_app, size: 18, color: Colors.red), SizedBox(width: 12), Text('Withdraw Member', style: TextStyle(color: Colors.red))]),
                        ),
                      ],
                      child: GroupingPlayerAvatar(
                        player: player, 
                        member: member, 
                        groupIndex: group.index, 
                        totalGroups: totalGroups, 
                        history: history,
                        size: 36,
                      ),
                    )),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          player.name, 
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.4),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('HC: ${player.handicapIndex.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('PHC: $displayPhc', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w900)),
                      if (matchSide != null) ...[
                        const SizedBox(width: 6),
                        Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'SIDE $matchSide', 
                          style: TextStyle(
                            fontSize: 10, 
                            color: matchSide == 'A' ? Colors.orange : Colors.blue, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          )
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isScoreMode) 
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        scoreDisplay ?? '-',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                )
            else
                  // Guest Indicator (Consistent across all modes)
                  if (player.isGuest || (isScoreMode && player.isGuest))
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildIconContainer(
                        child: const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.orange
                          ),
                        ),
                      ),
                    ),

                  // Winner Trophy
                  if (isScoreMode && isWinner)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildIconContainer(
                        child: const Icon(Icons.emoji_events_rounded, size: 14, color: Colors.orange),
                      ),
                    ),

                  if (!isScoreMode) ...[
                    // Member's Guest Marker
                    if (hasGuest)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _buildIconContainer(
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.deepPurple,
                            size: 14,
                          ),
                        ),
                      ),
                    
                    // Buggy Marker/Toggle
                    if (player.needsBuggy || isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _buildIconContainer(
                          child: InkWell(
                            onTap: isAdmin ? () => onAction?.call('buggy', player, group) : null,
                            borderRadius: BorderRadius.circular(8),
                            child: _buildBuggyIcon(player.needsBuggy ? player.buggyStatus : RegistrationStatus.none, size: 14),
                          ),
                        ),
                      ),

                    // Captain Marker/Toggle
                    if (player.isCaptain || isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _buildIconContainer(
                          child: InkWell(
                            onTap: isAdmin ? () => onAction?.call('captain', player, group) : null,
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(
                              player.isCaptain ? Icons.shield : Icons.shield_outlined, 
                              color: player.isCaptain ? Colors.orange : Colors.grey.shade300, 
                              size: 14
                            ),
                          ),
                        ),
                      ),
                  ],
          ],
        ),
      ),
    );
  }


  Widget _buildIconContainer({required Widget child}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildBuggyIcon(RegistrationStatus status, {double size = 16}) {
    Color color;
    switch (status) {
      case RegistrationStatus.confirmed:
        color = Colors.green;
        break;
      case RegistrationStatus.reserved:
        color = Colors.orange;
        break;
      case RegistrationStatus.waitlist:
        color = Colors.red;
        break;
      default:
        color = Colors.grey.shade300;
    }
    return Icon(Icons.electric_rickshaw, color: color, size: size);
  }
}

class GroupingCard extends StatelessWidget {
  final TeeGroup group;
  final Map<String, Member> memberMap;
  final List<GolfEvent> history;
  final int totalGroups;
  final CompetitionRules? rules;
  final Map<String, dynamic>? courseConfig;
  final bool useWhs;
  final bool isAdmin;
  final bool isLocked;
  final Function(TeeGroupParticipant p, TeeGroup g)? onPlayerDragStart;
  final Function(TeeGroupParticipant sourceP, TeeGroup? sourceG, TeeGroup targetG, TeeGroupParticipant? targetP)? onMove;
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
  });

  @override
  Widget build(BuildContext context) {
    // Recalculate Total PHC dynamically to respect capping rules
    double displayTotalHandicap = 0;
    if (rules != null) {
      for (var p in group.players) {
        displayTotalHandicap += HandicapCalculator.calculatePlayingHandicap(
          handicapIndex: p.handicapIndex,
          rules: rules!,
          courseConfig: courseConfig ?? {},
          useWhs: useWhs,
        );
      }
    } else {
      displayTotalHandicap = group.totalHandicap.roundToDouble();
    }

    // --- Scoring Mode Logic (Winners & Team Total) ---
    final isStableford = rules?.format == CompetitionFormat.stableford;
    final isScramble = rules?.format == CompetitionFormat.scramble;
    final int bestX = rules?.teamBestXCount ?? 2;
    int groupTotal = 0;
    
    // Split Team Logic (e.g. 2-Man Scramble in a 4-Ball, or any Pairs competition)
    final bool isSplitTeam = ((isScramble && rules?.teamSize == 2) || (rules?.mode == CompetitionMode.pairs)) 
        && group.players.length >= 3;
    
    int teamAScore = 0;
    int teamBScore = 0;
    bool hasScoreA = false;
    bool hasScoreB = false;

    final Map<String, bool> internalWinnerMap = winnerMap != null ? Map.from(winnerMap!) : {};

    if (isScoreMode && scoreMap != null && winnerMap == null) {
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

          // Split Team Accumulation
          if (isSplitTeam) {
            if (i < 2) { // Team A
              teamAScore = score; // In Scramble, players share score, so just take one
              hasScoreA = true;
            } else { // Team B
              teamBScore = score;
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
           
           final bestScore = playerScores.first.value;
           final tiedIds = playerScores.where((e) => e.value == bestScore).map((e) => e.key).toList();
           
           // ... (Tie break logic omitted for brevity, keeping simple tie)
           for (var tid in tiedIds) {
             internalWinnerMap[tid] = true;
           }

           // Calculate Group Total (Best X)
           final count = playerScores.length < bestX ? playerScores.length : bestX;
           for (int i = 0; i < count; i++) {
             groupTotal += playerScores[i].value;
           }
        } else if (!isSplitTeam) {
           // Standard Scramble (One Team)
           // Score is shared, so just take the first one found
           groupTotal = playerScores.isNotEmpty ? playerScores.first.value : 0;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BoxyArtFloatingCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Group ${group.index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 14, 
                          color: Colors.grey.shade600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(context, group.teeTime),
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 13
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // --- PLAYERS LIST ---
            ...group.players.asMap().entries.map((entry) {
               final index = entry.key;
               final p = entry.value;

               // Check if this player is a member who HAS a guest in this group
               final isMemberWithGuest = !p.isGuest && group.players.any((other) => other.isGuest && other.registrationMemberId == p.registrationMemberId);

              final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
              
              String? matchSide;
              if (matchPlayMode) {
                // Find which match and which side this player belongs to
                for (final match in matches) {
                  if (match.team1Ids.contains(p.registrationMemberId)) {
                    matchSide = 'A';
                    break;
                  } else if (match.team2Ids.contains(p.registrationMemberId)) {
                    matchSide = 'B';
                    break;
                  }
                }
              }

              final tile = GroupingPlayerTile(
                player: p,
                group: group,
                member: memberMap[p.registrationMemberId],
                history: history,
                totalGroups: totalGroups,
                rules: rules,
                courseConfig: courseConfig,
                useWhs: useWhs,
                isAdmin: isAdmin,
                hasGuest: isMemberWithGuest,
                onAction: onAction,
                onTap: onTapParticipant != null ? () => onTapParticipant!(p, group) : null,
                isSelected: isSelected?.call(p) ?? false,
                isScoreMode: isScoreMode,
                scoreDisplay: scoreMap?[id],
                phcOverride: phcMap?[id],
                isWinner: internalWinnerMap[id] ?? false,
                matchSide: matchSide,
              );

              final widget = isAdmin && !isLocked ? _wrapWithDraggable(context, p, tile) : tile;
              
              // [SPLIT TEAM DIVIDER]
              // If Split Team mode, add a divider after the 2nd player (index 1)
              if (isSplitTeam && index == 1) {
                return Column(
                  children: [
                    widget,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('VS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400, height: 1)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return widget;
            }),

            if (isAdmin && group.players.length < 4) 
               emptySlotBuilder?.call(group) ?? const SizedBox.shrink(),
            const Divider(height: 24, color: Colors.black12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isScoreMode)
                   _buildScoreFooter(context, isStableford, isScramble, isSplitTeam, groupTotal, bestX, teamAScore, teamBScore, hasScoreA, hasScoreB)
                else
                  const SizedBox.shrink(),
                Text(
                  'Total PHC: ${displayTotalHandicap.toInt()}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
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
  ) {
    String formatScore(int val) {
       return !isStableford && val == 0 ? "E" : (!isStableford && val > 0 ? "+$val" : val.toString());
    }

    if (isSplitTeam) {
       return Row(
         children: [
           Text('Team A: ', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
           Text(
             hasScoreA ? formatScore(scoreA) : '-',
             style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w900),
           ),
           const SizedBox(width: 12),
           Container(width: 1, height: 12, color: Colors.grey.shade300),
           const SizedBox(width: 12),
           Text('Team B: ', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
           Text(
             hasScoreB ? formatScore(scoreB) : '-',
             style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w900),
           ),
         ],
       );
    }
    
    Widget mainScore = Text(
       isScramble 
          ? 'Team Score: ${formatScore(groupTotal)}'
          : 'Group Total (Best $bestX): ${formatScore(groupTotal)}',
       style: TextStyle(
         color: Theme.of(context).primaryColor, 
         fontSize: 12, 
         fontWeight: FontWeight.w900,
       ),
    );

    // [NEW] Display Scramble Weighting Rule for transparency
    if (isScramble && (rules?.useWHSScrambleAllowance ?? false)) {
      final teamCount = group.players.where((p) => p.registrationMemberId != '').length; // Adjusted check
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
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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

  Widget _wrapWithDraggable(BuildContext context, TeeGroupParticipant p, Widget child) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => !isLocked && details.data['player'] != p,
      onAcceptWithDetails: (details) {
        final sourcePlayer = details.data['player'] as TeeGroupParticipant;
        final sourceGroup = details.data['group'] as TeeGroup?;
        onMove?.call(sourcePlayer, sourceGroup, group, p);
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        
        return LongPressDraggable<Map<String, dynamic>>(
          data: {'player': p, 'group': group},
          delay: const Duration(milliseconds: 500),
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(24),
            child: GroupingPlayerAvatar(
              player: p, 
              member: memberMap[p.registrationMemberId], 
              size: 48, 
              groupIndex: group.index, 
              totalGroups: totalGroups, 
              history: history,
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOver ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
              color: isOver ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.transparent,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
