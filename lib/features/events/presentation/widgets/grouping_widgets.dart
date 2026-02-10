import 'package:flutter/material.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/utils/handicap_calculator.dart'; // Ensure imported
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/member.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/competition.dart';
import '../../../../models/scorecard.dart';
import '../../../../core/utils/tie_breaker_logic.dart';
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
                    fontWeight: FontWeight.bold,
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
  });

  final String? matchSide;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Recalculate PHC if rules are available (to respect caps and allowances)
    int displayPhc = player.playingHandicap.round();
    if (rules != null) {
      displayPhc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: player.handicapIndex,
        rules: rules!,
        courseConfig: courseConfig ?? {}, 
        useWhs: useWhs,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
          ? Border.all(color: primaryColor, width: 2) 
          : (matchSide != null 
              ? Border.all(color: matchSide == 'A' ? Colors.orange.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.5), width: 1.5)
              : null),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: isScoreMode 
            ? null 
            : (!isAdmin 
                ? GroupingPlayerAvatar(
                    player: player, 
                    member: member, 
                    groupIndex: group.index, 
                    totalGroups: totalGroups, 
                    history: history,
                  )
                : PopupMenuButton<String>(
                    onSelected: (val) => onAction?.call(val, player, group),
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 4,
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    ),
                  )),
        title: Row(
          children: [
            Expanded(
              child: Text(
                player.name, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isWinner && isScoreMode)
               const Padding(
                 padding: EdgeInsets.only(left: 6.0),
                 child: Icon(Icons.emoji_events, size: 16, color: Colors.orange),
               ),
          ],
        ),
        subtitle: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text('HC: ${player.handicapIndex.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('PHC: $displayPhc', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold)),
              if (matchSide != null) ...[
                const SizedBox(width: 4),
                Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                const SizedBox(width: 4),
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
        ),
        trailing: isScoreMode 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scoreDisplay ?? '-',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Guest/Role Marker
                  SizedBox(
                    width: 28,
                    child: Center(
                      child: _buildRoleIcon(),
                    ),
                  ),
                  
                  // Buggy Marker/Toggle
                  SizedBox(
                    width: 28,
                    child: Tooltip(
                      message: player.needsBuggy ? 'Buggy: ${player.buggyStatus.name.toUpperCase()}' : 'No Buggy',
                      child: Center(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: _buildBuggyIcon(player.needsBuggy ? player.buggyStatus : RegistrationStatus.none, size: 18),
                          onPressed: isAdmin ? () => onAction?.call('buggy', player, group) : null,
                        ),
                      ),
                    ),
                  ),

                  // Captain Marker/Toggle
                  SizedBox(
                    width: 28, 
                    child: Tooltip(
                      message: player.isCaptain ? 'Captain' : 'No Captain Role',
                      child: Center(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            player.isCaptain ? Icons.shield : Icons.shield_outlined, 
                            color: player.isCaptain ? Colors.orange : Colors.grey.shade200, 
                            size: 18
                          ),
                          onPressed: isAdmin ? () => onAction?.call('captain', player, group) : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRoleIcon() {
    if (player.isGuest) {
      return const Text(
        'G',
        style: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.w900, 
          color: Colors.orange
        ),
      );
    }
    
    // If member has confirmed guest in this group (passed via hasGuest prop)
    if (hasGuest) {
      return const Icon(
        Icons.person_add,
        color: Colors.deepPurple,
        size: 18,
      );
    }
    
    return const SizedBox.shrink();
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
    final int bestX = rules?.teamBestXCount ?? 2;
    int groupTotal = 0;
    final Map<String, bool> winnerMap = {};

    if (isScoreMode && scoreMap != null) {
      final List<MapEntry<String, int>> playerScores = [];
      
      int parseScore(String text) {
        if (text == 'E') return 0;
        final clean = text.replaceAll('+', '').trim();
        return int.tryParse(clean) ?? (isStableford ? 0 : 999);
      }

      for (var p in group.players) {
        final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final scoreText = scoreMap![id];
        if (scoreText != null && scoreText != '-') {
          final score = parseScore(scoreText);
          playerScores.add(MapEntry(id, score));
        }
      }

      if (playerScores.isNotEmpty) {
        // Find individual winners in group
        // If Stableford: Higher is better. If Strokeplay/MaxScore: Lower is better.
        if (isStableford) {
          playerScores.sort((a, b) => b.value.compareTo(a.value));
        } else {
          // Strokeplay/MaxScore/etc: Lower is better
          playerScores.sort((a, b) => a.value.compareTo(b.value));
        }
        
        final bestScore = playerScores.first.value;
        final tiedIds = playerScores.where((e) => e.value == bestScore).map((e) => e.key).toList();

        if (tiedIds.length == 1) {
          winnerMap[tiedIds.first] = true;
        } else if (tiedIds.length > 1 && scorecardMap != null) {
          // Formal Tie Break Logic
          final holeData = courseConfig?['holes'] as List?;
          if (holeData != null && holeData.length >= 18) {
            final pars = holeData.map((h) => (h['par'] as num?)?.toInt() ?? 4).toList();
            final sis = holeData.map((h) => (h['si'] as num?)?.toInt() ?? 18).toList();

            String? currentWinnerId = tiedIds.first;
            
            for (int j = 1; j < tiedIds.length; j++) {
              final nextId = tiedIds[j];
              final cardA = scorecardMap![currentWinnerId!];
              final cardB = scorecardMap![nextId];
              
              if (cardA != null && cardB != null) {
                // Get PHC for countback (TieBreakerLogic uses roundedPHC)
                final participantA = group.players.firstWhere((p) => (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) == currentWinnerId);
                final participantB = group.players.firstWhere((p) => (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) == nextId);

                // Re-calculate accurate PHC based on current rules
                final phcA = HandicapCalculator.calculatePlayingHandicap(
                  handicapIndex: participantA.handicapIndex, 
                  rules: rules!, 
                  courseConfig: courseConfig!,
                  useWhs: useWhs,
                ).toDouble();
                
                final phcB = HandicapCalculator.calculatePlayingHandicap(
                  handicapIndex: participantB.handicapIndex, 
                  rules: rules!, 
                  courseConfig: courseConfig!,
                  useWhs: useWhs,
                ).toDouble();

                final result = TieBreakerLogic.resolveTie(
                  holeScoresA: cardA.holeScores.whereType<int>().toList(), 
                  holeScoresB: cardB.holeScores.whereType<int>().toList(), 
                  pars: pars, 
                  sis: sis, 
                  handicapA: phcA, 
                  handicapB: phcB,
                  isStableford: isStableford,
                );

                if (result == -1) {
                  currentWinnerId = nextId; // B is better
                } else if (result == 0) {
                  // Still tied - multiple winners for now in this specific case
                  currentWinnerId = null; // Mark as contested or multiple
                  break;
                }
              }
            }
            
            if (currentWinnerId != null) {
               winnerMap[currentWinnerId] = true;
            } else {
               // Fallback: Show all tied participants if logic results in 0 (extreme rarity)
               for (var tid in tiedIds) {
                 winnerMap[tid] = true;
               }
            }
          } else {
            // Fallback: Simple tie display
            for (var tid in tiedIds) {
              winnerMap[tid] = true;
            }
          }
        }

        // Calculate Team Total (Best X)
        // Note: For Strokeplay, "Best" means lower. For Stableford, "Best" means higher.
        // The sort above already puts the "Best" scores at the beginning.
        final count = playerScores.length < bestX ? playerScores.length : bestX;
        for (int i = 0; i < count; i++) {
          groupTotal += playerScores[i].value;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BoxyArtFloatingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Group ${group.index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatTime(context, group.teeTime),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...group.players.map((p) {
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
                isWinner: winnerMap[id] ?? false,
                matchSide: matchSide,
              );

              if (isAdmin && !isLocked) {
                return _wrapWithDraggable(context, p, tile);
              }
              return tile;
            }),
            if (isAdmin && group.players.length < 4) 
               emptySlotBuilder?.call(group) ?? const SizedBox.shrink(),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isScoreMode)
                   Text(
                    'Group Total (Best $bestX): ${!isStableford && groupTotal == 0 ? "E" : (!isStableford && groupTotal > 0 ? "+$groupTotal" : groupTotal)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w900,
                    ),
                  )
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
