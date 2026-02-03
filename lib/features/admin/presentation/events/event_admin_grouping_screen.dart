import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/shared_ui/shared_ui.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/event_registration.dart';
import '../../../../models/member.dart';
import '../../../events/domain/registration_logic.dart';
import '../../providers/admin_ui_providers.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../models/society_config.dart'; // Added
import '../../../../models/competition.dart'; // Added
import '../../../competitions/presentation/competitions_provider.dart'; // Added

class EventAdminGroupingScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAdminGroupingScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminGroupingScreen> createState() => _EventAdminGroupingScreenState();
}

enum GroupingExitAction { discard, save, stay }

class _EventAdminGroupingScreenState extends ConsumerState<EventAdminGroupingScreen> {
  List<TeeGroup>? _localGroups;
  bool? _isLocked;
  bool _isDirty = false;
  bool _showGenerationOptions = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateDirty(bool dirty) {
    if (_isDirty != dirty) {
      setState(() {
        _isDirty = dirty;
      });
      // Sync with global provider for shell navigation protection
      ref.read(groupingDirtyProvider.notifier).setDirty(dirty);
      
      // Update shared data providers whenever dirty (to ensure shell has latest for saving)
      if (dirty) {
        ref.read(groupingLocalGroupsProvider.notifier).setGroups(_localGroups);
        ref.read(groupingIsLockedProvider.notifier).setLocked(_isLocked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final allEventsAsync = ref.watch(adminEventsProvider); // For variety logic
    final membersAsync = ref.watch(allMembersProvider);
    final societyConfig = ref.watch(themeControllerProvider); // Corrected
    final competitionsAsync = ref.watch(competitionsListProvider(null)); // Added

    return eventsAsync.when(
      data: (events) {
        final members = membersAsync.value ?? [];
        final handicapMap = {for (var m in members) m.id: m.handicap};
        final memberMap = {for (var m in members) m.id: m};
        
        final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        final allEvents = allEventsAsync.value ?? [];
        final history = allEvents.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
        
        // Handicap & Rules Context
        final config = societyConfig;
        final comps = competitionsAsync.value ?? [];
        final comp = comps.where((c) => c.id == event.id).firstOrNull; // EventID = CompID
        
        // Initialize local groups if not already done
        if (_localGroups == null && event.grouping.containsKey('groups')) {
            _localGroups = (event.grouping['groups'] as List)
                .map((g) => TeeGroup.fromJson(g))
                .toList();
        }
        
        _isLocked ??= event.grouping['locked'] ?? false;
        
        // Calculate Unassigned Players (Confirmed squad but not in groups)
        final unassignedSquad = <TeeGroupParticipant>[];
        if (_localGroups != null) {
          int rollingCount = 0;
          final capacity = event.maxParticipants ?? 999;
          final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
          
          final assignedPlayerIds = _localGroups!
              .expand((g) => g.players)
              .map((p) => '${p.registrationMemberId}|${p.isGuest}')
              .toSet();

          for (final item in RegistrationLogic.getSortedItems(event)) {
             final status = RegistrationLogic.calculateStatus(
                isGuest: item.isGuest,
                isConfirmed: item.isConfirmed,
                hasPaid: item.hasPaid,
                capacity: capacity,
                confirmedCount: rollingCount,
                isEventClosed: isClosed,
                statusOverride: item.statusOverride,
             );

             if (status == RegistrationStatus.confirmed) {
               rollingCount++;
               final playerId = '${item.registration.memberId}|${item.isGuest}';
               if (!assignedPlayerIds.contains(playerId)) {
                 // Map to participant
                 final double handicap;
                 if (item.isGuest) {
                    handicap = double.tryParse(item.registration.guestHandicap ?? '') ?? 28.0;
                 } else {
                    handicap = handicapMap[item.registration.memberId] ?? 28.0;
                 }
                 
                 unassignedSquad.add(TeeGroupParticipant(
                   registrationMemberId: item.registration.memberId,
                   name: item.name,
                   isGuest: item.isGuest,
                   handicap: handicap,
                   needsBuggy: item.needsBuggy,
                   buggyStatus: RegistrationStatus.confirmed, 
                 ));
               }
             }
          }
        }

        return PopScope(
          canPop: !_isDirty,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final action = await _showExitConfirmation();
            if (action == GroupingExitAction.save && context.mounted) {
              await _saveGrouping(event);
              if (context.mounted) Navigator.of(context).pop();
            } else if (action == GroupingExitAction.discard && context.mounted) {
              _updateDirty(false);
              Navigator.of(context).pop();
            }
          },
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                Column(
                  children: [
                    if (unassignedSquad.isNotEmpty) _buildSquadPool(unassignedSquad, memberMap, history),
                    BoxyArtAppBar(
                      title: 'Grouping',
                      centerTitle: true,
                      isLarge: true,
                      leadingWidth: 70,
                      leading: Center(
                        child: TextButton(
                          onPressed: () async {
                            final nav = Navigator.of(context);
                            final handled = await nav.maybePop();
                            if (!handled && context.mounted) {
                              context.go('/admin/events');
                            }
                          },
                          child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Opacity(
                            opacity: event.isRegistrationClosed ? 1.0 : 0.5,
                            child: const Icon(Icons.autorenew, color: Colors.white),
                          ),
                          tooltip: event.isRegistrationClosed ? 'Regenerate' : 'Registration still open',
                          onPressed: event.isRegistrationClosed
                              ? () {
                                  if (_isLocked == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Groupings locked. Unlock to regenerate.')));
                                    return;
                                  }
                                  final members = membersAsync.value ?? [];
                                  final handicapMap = {for (var m in members) m.id: m.handicap};
                                  _showRegenerationOptions(event, allEventsAsync.value ?? [], handicapMap);
                                }
                              : null,
                        ),
                        IconButton(
                          icon: Opacity(
                            opacity: event.isRegistrationClosed ? 1.0 : 0.5,
                            child: Icon(
                              _isLocked == true ? Icons.lock : Icons.lock_open, 
                              color: _isLocked == true ? Colors.white : Colors.white70
                            ),
                          ),
                          tooltip: event.isRegistrationClosed 
                              ? (_isLocked == true ? 'Unlock Grouping' : 'Lock Grouping')
                              : 'Registration still open',
                          onPressed: event.isRegistrationClosed
                              ? () {
                                  if (_localGroups == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generate groups first!')));
                                    return;
                                  }
                                  setState(() {
                                    _isLocked = !(_isLocked ?? false);
                                  });
                                  _updateDirty(true);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isLocked == true ? 'Grouping Locked (Save to persist)' : 'Grouping Unlocked')));
                                }
                              : null,
                        ),
                        IconButton(
                          icon: Opacity(
                            opacity: event.isRegistrationClosed ? 1.0 : 0.5,
                            child: Icon(
                              Icons.save, 
                              color: _isDirty ? Colors.amber : Colors.white,
                            ),
                          ),
                          tooltip: event.isRegistrationClosed ? 'Save Grouping' : 'Registration still open',
                          onPressed: event.isRegistrationClosed ? () => _saveGrouping(event) : null,
                        ),
                      ],
                    ),
                    Expanded(
                      child: _localGroups == null 
                        ? _buildEmptyState(event, allEventsAsync.value ?? [], handicapMap)
                        : _buildGroupingList(event, memberMap, history),
                    ),
                  ],
                ),
                if (_localGroups != null) 
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildPublishBar(event),
                  ),
                if (_showGenerationOptions)
                  _buildGenerationOverlay(context, event, allEvents, handicapMap, config, comp?.rules),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEmptyState(GolfEvent event, List<GolfEvent> allEvents, Map<String, double> handicapMap) {
    final isClosed = event.isRegistrationClosed;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.grid_view_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No grouping generated yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Opacity(
            opacity: isClosed ? 1.0 : 0.5,
            child: BoxyArtButton(
              title: isClosed ? 'Auto-Generate Grouping' : 'Event still open',
              onTap: isClosed ? () => _showRegenerationOptions(event, allEvents, handicapMap) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquadPool(List<TeeGroupParticipant> squad, Map<String, Member> memberMap, List<GolfEvent> history) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.group_add, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'SQUAD POOL (${squad.length})',
                  style: const TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.blueGrey,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: squad.length,
              itemBuilder: (context, idx) {
                final p = squad[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: LongPressDraggable<Map<String, dynamic>>(
                    data: {'player': p, 'group': null}, 
                    delay: const Duration(milliseconds: 100),
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(24),
                      child: _buildAvatar(p, memberMap),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAvatar(p, memberMap),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              p.name.split(' ').first, 
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                            if (p.isGuest) ...[
                              const SizedBox(width: 2),
                              const Text('G', style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.bold)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildGroupingList(GolfEvent event, Map<String, Member> memberMap, List<GolfEvent> history) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _localGroups!.length,
      itemBuilder: (context, index) {
        final group = _localGroups![index];
        return _buildGroupCard(group, memberMap, history);
      },
    );
  }

  Widget _buildGroupCard(TeeGroup group, Map<String, Member> memberMap, List<GolfEvent> history) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BoxyArtFloatingCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group ${group.index + 1} - ${TimeOfDay.fromDateTime(group.teeTime).format(context)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'HC: ${group.totalHandicap.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(),
          ...group.players.map((p) => _buildPlayerTile(p, group, memberMap, history)),
          if (group.players.length < 4) _buildEmptySlot(group, memberMap),
        ],
      ),
    ),
  );
}

  Widget _buildEmptySlot(TeeGroup group, Map<String, Member> memberMap) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => _isLocked != true && (details.data['group'] != group || group.players.length < 4),
      onAcceptWithDetails: (details) {
        final sourcePlayer = details.data['player'] as TeeGroupParticipant;
        final sourceGroup = details.data['group'] as TeeGroup?;
        _handleMove(sourcePlayer, sourceGroup, group, null);
      },
      onMove: (details) {
        // Auto-scroll logic
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.globalToLocal(details.offset);
          _checkAutoScroll(position.dy, box.size.height);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOver ? Theme.of(context).primaryColor : Colors.grey.shade200,
              style: isOver ? BorderStyle.solid : BorderStyle.none,
              width: 2,
            ),
            color: isOver ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.grey.shade50,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text('EMPTY SLOT', style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ],
          ),
        );
      },
    );
  }


  Widget _buildBuggyIcon(RegistrationStatus status, {double size = 14}) {
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

  Widget _buildAvatar(TeeGroupParticipant p, Map<String, Member> memberMap, {
    double size = 40,
    int? groupIndex,
    int? totalGroups,
    List<GolfEvent>? history,
  }) {
    final member = memberMap[p.registrationMemberId];
    final bool hasProfilePic = member?.avatarUrl != null && !p.isGuest;

    Color borderColor = Colors.transparent;
    String varietyTooltip = 'Fresh slot variety';

    if (groupIndex != null && totalGroups != null && history != null && !p.isGuest) {
        final matches = GroupingService.getTeeTimeVariety(p.registrationMemberId, groupIndex, totalGroups, history);
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
          backgroundColor: p.isCaptain ? Colors.orange : Colors.grey.shade200,
          backgroundImage: hasProfilePic ? NetworkImage(member!.avatarUrl!) : null,
          child: !hasProfilePic
              ? Text(
                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: p.isCaptain ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.4,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPlayerTile(TeeGroupParticipant p, TeeGroup group, Map<String, Member> memberMap, List<GolfEvent> history) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => _isLocked != true && details.data['player'] != p,
      onAcceptWithDetails: (details) {
        final sourcePlayer = details.data['player'] as TeeGroupParticipant;
        final sourceGroup = details.data['group'] as TeeGroup?;
        _handleMove(sourcePlayer, sourceGroup, group, p);
      },
      onMove: (details) {
        // Auto-scroll logic
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.globalToLocal(details.offset);
          _checkAutoScroll(position.dy, box.size.height);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        
        return LongPressDraggable<Map<String, dynamic>>(
          data: {'player': p, 'group': group},
          delay: const Duration(milliseconds: 500),
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(24),
            child: _buildAvatar(p, memberMap, size: 48, groupIndex: group.index, totalGroups: _localGroups!.length, history: history),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildTileContent(p, group, memberMap, history),
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
            child: _buildTileContent(p, group, memberMap, history),
          ),
        );
      },
    );
  }

  Widget _buildTileContent(TeeGroupParticipant p, TeeGroup group, Map<String, Member> memberMap, List<GolfEvent> history, {bool isFeedback = false}) {
    return ListTile(
      contentPadding: isFeedback ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 8),
      leading: isFeedback ? _buildAvatar(p, memberMap, size: 40, groupIndex: group.index, totalGroups: _localGroups!.length, history: history) 
      : PopupMenuButton<String>(
        onSelected: (val) => _handlePlayerAction(val, p, group),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'move', child: Row(children: [Icon(Icons.drive_file_move_outlined, size: 18), SizedBox(width: 8), Text('Move to Group...')])),
          const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.person_remove_outlined, size: 18), SizedBox(width: 8), Text('Remove from Group')])),
          const PopupMenuItem(
            value: 'withdraw', 
            child: Row(children: [Icon(Icons.exit_to_app, size: 18, color: Colors.red), SizedBox(width: 8), Text('Withdraw Member', style: TextStyle(color: Colors.red))]),
          ),
        ],
        child: _buildAvatar(p, memberMap, size: 40, groupIndex: group.index, totalGroups: _localGroups!.length, history: history),
      ),
      title: Text(
        p.name, 
        style: const TextStyle(fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('HC: ${p.handicap.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
      trailing: isFeedback ? null : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Guest Indicator
          if (p.isGuest)
            const SizedBox(
              width: 32,
              child: Tooltip(
                message: 'Guest',
                child: Center(
                  child: Text(
                    'G', 
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.orange, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Buggy Toggle
          IconButton(
            constraints: const BoxConstraints(maxWidth: 32),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: _buildBuggyIcon(p.buggyStatus, size: 18),
            tooltip: 'Toggle Buggy',
            onPressed: () => _handlePlayerAction('buggy', p, group),
          ),
          
          // Captain Toggle
          IconButton(
            constraints: const BoxConstraints(maxWidth: 32),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              p.isCaptain ? Icons.shield : Icons.shield_outlined,
              color: p.isCaptain ? Colors.orange : Colors.grey.shade300,
              size: 18,
            ),
            tooltip: 'Toggle Captain',
            onPressed: () => _handlePlayerAction('captain', p, group),
          ),
        ],
      ),
    );
  }

  void _handleMove(TeeGroupParticipant sourceP, TeeGroup? sourceG, TeeGroup targetG, TeeGroupParticipant? targetP) {
    setState(() {
      // 1. Internal Move (within same group)
      if (sourceG == targetG) {
        if (targetP != null && sourceP != targetP) {
          final sIdx = sourceG!.players.indexOf(sourceP);
          final tIdx = targetG.players.indexOf(targetP);
          if (sIdx != -1 && tIdx != -1) {
            targetG.players[sIdx] = targetP;
            targetG.players[tIdx] = sourceP;
          }
        }
        _updateDirty(true);
        return;
      }

      // 2. External Move (different group or from pool)
      if (sourceG != null) {
        sourceG.players.remove(sourceP);
      }
      
      if (targetP != null) {
        final tIdx = targetG.players.indexOf(targetP);
        if (sourceG != null) {
          // SWAP: Move targetP to sourceG, sourceP to targetG
          targetG.players.removeAt(tIdx);
          targetG.players.insert(tIdx, sourceP);
          sourceG.players.add(targetP);
        } else {
          // ADD from pool to specific spot
          targetG.players.insert(tIdx, sourceP);
        }
      } else {
        // ADD to empty slot
        if (targetG.players.length < 4) {
          targetG.players.add(sourceP);
        }
      }
      
      // 3. Size Enforcement (Safety cap at 4)
      if (targetG.players.length > 4) {
        final excess = targetG.players.removeLast();
        if (sourceG != null) {
          sourceG.players.add(excess);
        }
      }

      // 4. Captaincy Enforcement (One per group)
      final groupCaptains = targetG.players.where((pl) => pl.isCaptain).toList();
      if (groupCaptains.length > 1) {
        // If we just moved a captain into a group that already had one,
        // untoggle the one who was just moved.
        sourceP.isCaptain = false;
      }

      _updateDirty(true);
    });
  }

  void _checkAutoScroll(double dy, double height) {
    const double threshold = 100.0;
    const double scrollSpeed = 15.0;

    if (dy < threshold) {
      _scrollController.animateTo(
        (_scrollController.offset - scrollSpeed).clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 50),
        curve: Curves.linear,
      );
    } else if (dy > height - threshold) {
      _scrollController.animateTo(
        (_scrollController.offset + scrollSpeed).clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 50),
        curve: Curves.linear,
      );
    }
  }

  void _handlePlayerAction(String action, TeeGroupParticipant p, TeeGroup currentGroup) {
    if (action == 'captain') {
      setState(() {
        for (var player in currentGroup.players) {
          player.isCaptain = (player == p);
        }
        _updateDirty(true);
      });
    } else if (action == 'remove') {
      setState(() {
        currentGroup.players.remove(p);
        _updateDirty(true);
      });
    } else if (action == 'withdraw') {
      _confirmWithdraw(p, currentGroup);
    } else if (action == 'buggy') {
      setState(() {
        if (!p.needsBuggy) {
          p.needsBuggy = true;
          p.buggyStatus = RegistrationStatus.reserved;
        } else if (p.buggyStatus == RegistrationStatus.reserved) {
          p.buggyStatus = RegistrationStatus.confirmed;
        } else if (p.buggyStatus == RegistrationStatus.confirmed) {
          p.buggyStatus = RegistrationStatus.waitlist;
        } else {
          p.needsBuggy = false;
          p.buggyStatus = RegistrationStatus.none;
        }
        _updateDirty(true);
      });
    } else if (action == 'move') {
      _showMoveDialog(p, currentGroup);
    }
  }

  Future<void> _confirmWithdraw(TeeGroupParticipant p, TeeGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Member?'),
        content: Text('This will remove ${p.name} from the groupings and set their status to "Withdrawn" in the registrations list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Withdraw', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final eventsAsync = ref.read(upcomingEventsProvider);
      final event = eventsAsync.value?.firstWhere((e) => e.id == widget.eventId);
      if (event == null) return;

      final reg = event.registrations.where((r) => r.memberId == p.registrationMemberId).firstOrNull;
      if (reg == null) return;

      // Update status to withdrawn
      final updatedReg = reg.copyWith(
        statusOverride: 'withdrawn',
        isConfirmed: false,
      );

      final newList = List<EventRegistration>.from(event.registrations);
      final idx = newList.indexWhere((r) => r.memberId == updatedReg.memberId);
      if (idx >= 0) {
        newList[idx] = updatedReg;
        await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(registrations: newList));
        
        setState(() {
          group.players.remove(p);
          _updateDirty(true);
        });
      }
    }
  }

  Widget _buildPublishBar(GolfEvent event) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: BoxyArtButton(
          title: event.isGroupingPublished ? 'Unpublish' : 'Publish to Members',
          onTap: () => _togglePublish(event),
          isSecondary: event.isGroupingPublished,
          fullWidth: true,
        ),
      ),
    );
  }

  Widget _buildGenerationOverlay(
    BuildContext context, 
    GolfEvent event, 
    List<GolfEvent> allEvents, 
    Map<String, double> handicapMap,
    SocietyConfig config,
    CompetitionRules? rules,
  ) {
    // Initial values
    String selectedStrategy = ref.read(themeControllerProvider).groupingStrategy;
    bool pairBuggies = false;

    return Stack(
      children: [
        // Barrier
        GestureDetector(
          onTap: () => setState(() => _showGenerationOptions = false),
          child: Container(
            color: Colors.black54,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: StatefulBuilder(
              builder: (context, setOverlayState) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate Groups', 
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 8),
                        const Text('Configure how players are sorted into groups.', style: TextStyle(color: Colors.grey)),
                        
                        const SizedBox(height: 24),
                        const Text('STRATEGY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        
                        BoxyArtFloatingCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _buildRadioOption(context, 'balanced', 'Balanced Teams', 'Balances total handicap.', selectedStrategy, (val) => setOverlayState(() => selectedStrategy = val)),
                              const Divider(height: 1),
                              _buildRadioOption(context, 'progressive', 'Progressive', 'Low handicap first.', selectedStrategy, (val) => setOverlayState(() => selectedStrategy = val)),
                              const Divider(height: 1),
                              _buildRadioOption(context, 'similar', 'Similar Ability', 'Group by skill level.', selectedStrategy, (val) => setOverlayState(() => selectedStrategy = val)),
                              const Divider(height: 1),
                              _buildRadioOption(context, 'random', 'Random', 'Mix everything up.', selectedStrategy, (val) => setOverlayState(() => selectedStrategy = val)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text('PREFERENCES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        
                        SwitchListTile(
                          title: const Text('Pair Buggy Users', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Prioritize putting buggy users together.'),
                          contentPadding: EdgeInsets.zero,
                          value: pairBuggies,
                          onChanged: (val) => setOverlayState(() => pairBuggies = val),
                        ),

                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: BoxyArtButton(
                                title: 'Cancel',
                                isGhost: true,
                                onTap: () => setState(() => _showGenerationOptions = false),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: BoxyArtButton(
                                title: 'Generate',
                                onTap: () {
                                  setState(() => _showGenerationOptions = false);
                                  _handleAutoGenerate(
                                    event, 
                                    allEvents, 
                                    handicapMap, 
                                    prioritizeBuggyPairing: pairBuggies,
                                    strategyOverride: selectedStrategy,
                                    config: config,
                                    rules: rules,
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showRegenerationOptions(GolfEvent event, List<GolfEvent> allEvents, Map<String, double> handicapMap) {
    setState(() {
      _showGenerationOptions = true;
    });
  }

  Widget _buildRadioOption(BuildContext context, String value, String title, String subtitle, String groupValue, ValueChanged<String> onChanged) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      groupValue: groupValue,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      activeColor: Theme.of(context).primaryColor,
      dense: true,
    );
  }

  void _handleAutoGenerate(
    GolfEvent event, 
    List<GolfEvent> allEvents, 
    Map<String, double> handicapMap, {
    bool prioritizeBuggyPairing = false, 
    String? strategyOverride,
    required SocietyConfig config,
    CompetitionRules? rules,
  }) {
    final participants = RegistrationLogic.getSortedItems(event);
    final previousInSeason = allEvents.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
    final strategy = strategyOverride ?? config.groupingStrategy;

    setState(() {
      _localGroups = GroupingService.generateInitialGrouping(
        event: event, 
        participants: participants, 
        previousEventsInSeason: previousInSeason,
        memberHandicaps: handicapMap,
        prioritizeBuggyPairing: prioritizeBuggyPairing,
        strategy: strategy,
        rules: rules,
        useWhs: config.useWhsHandicaps,
      );
    });
    _updateDirty(true);
  }

  void _showMoveDialog(TeeGroupParticipant p, TeeGroup currentGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move ${p.name} to Group'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _localGroups!.length,
            itemBuilder: (context, index) {
              final g = _localGroups![index];
              if (g == currentGroup) return const SizedBox.shrink();
              return ListTile(
                title: Text('Group ${g.index + 1} (${g.players.length} players)'),
                onTap: () {
                  _handleMove(p, currentGroup, g, null);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<GroupingExitAction> _showExitConfirmation() async {
    if (!mounted) return GroupingExitAction.discard;
    
    final result = await showDialog<GroupingExitAction>(
      context: context,
      builder: (dialogContext) => BoxyArtDialog(
        title: 'Unsaved Changes',
        message: 'You have unsaved groupings. Do you want to save them before exiting?',
        confirmText: 'Save',
        cancelText: 'Discard',
        onConfirm: () => Navigator.of(dialogContext).pop(GroupingExitAction.save),
        onCancel: () => Navigator.of(dialogContext).pop(GroupingExitAction.discard),
        actions: [
          BoxyArtButton(
            title: 'Discard',
            onTap: () => Navigator.of(dialogContext).pop(GroupingExitAction.discard),
            isGhost: true,
          ),
          BoxyArtButton(
            title: 'Save',
            onTap: () => Navigator.of(dialogContext).pop(GroupingExitAction.save),
            isPrimary: true,
          ),
        ],
      ),
    );
    return result ?? GroupingExitAction.stay;
  }

  Future<void> _saveGrouping(GolfEvent event) async {
    if (_localGroups == null) return;
    
    try {
      final updatedEvent = event.copyWith(
        grouping: {
          'groups': _localGroups!.map((g) => g.toJson()).toList(),
          'updatedAt': DateTime.now().toIso8601String(),
          'locked': _isLocked ?? false,
        },
      );
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
      _updateDirty(false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grouping saved successfully')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  Future<void> _togglePublish(GolfEvent event) async {
    if (!event.isRegistrationClosed && !event.isGroupingPublished) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Still Open'),
          content: const Text('Registration for this event is still open. Publishing the grouping now might lead to confusion if more members join or withdraw. Proceed anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Publish Anyway')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    try {
      final updatedEvent = event.copyWith(isGroupingPublished: !event.isGroupingPublished);
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(updatedEvent.isGroupingPublished ? 'Published!' : 'Unpublished')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
