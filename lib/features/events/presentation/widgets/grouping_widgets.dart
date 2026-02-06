import 'package:flutter/material.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/utils/handicap_calculator.dart'; // Ensure imported
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/member.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/competition.dart';
import '../../domain/registration_logic.dart';

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
        borderColor = Colors.grey.shade300;
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
  });

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
        border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: !isAdmin 
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
              ),
        title: Text(
          player.name, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text('HC: ${player.handicapIndex.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('PHC: $displayPhc', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Guest Marker
            SizedBox(
              width: 28,
              child: Tooltip(
                message: player.isGuest ? 'Guest' : 'Member',
                child: Center(
                  child: player.isGuest 
                    ? const Icon(
                        Icons.person_outline,
                        color: Colors.deepPurple,
                        size: 18,
                      )
                    : const SizedBox.shrink(),
                ),
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

    final bool hasGuest = group.players.any((p) => p.isGuest);
    final bool isWithdrawn = group.players.any((p) => p.status == RegistrationStatus.withdrawn);

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
                    const SizedBox(width: 8),
                    hasGuest && !isWithdrawn 
                      ? const Icon(
                          Icons.person_add,
                          color: Colors.deepPurple,
                          size: 20,
                        )
                      : const SizedBox.shrink(),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
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
                onAction: onAction,
                onTap: onTapParticipant != null ? () => onTapParticipant!(p, group) : null,
                isSelected: isSelected?.call(p) ?? false,
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
