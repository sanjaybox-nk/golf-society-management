import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/shared_ui/shared_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/handicap_calculator.dart';
import '../../../../models/competition.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/event_registration.dart';
import '../../../../models/member.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../../models/scorecard.dart';
import '../../providers/admin_ui_providers.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../models/society_config.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../events/presentation/widgets/grouping_widgets.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart'; 

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
  
  // Swap state
  TeeGroupParticipant? _selectedForSwap;
  TeeGroup? _selectedGroupForSwap;
  
  // Match sync state
  List<MatchDefinition>? _localMatches;
  bool _matchPlayMode = false;

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
    final eventsAsync = ref.watch(adminEventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final societyConfig = ref.watch(themeControllerProvider);
    final competitionAsync = ref.watch(competitionDetailProvider(widget.eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));

    return eventsAsync.when(
      data: (events) {
        // Wait for competition rules to be loaded
        if (competitionAsync.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final members = membersAsync.value ?? [];
        final handicapMap = {for (var m in members) m.id: m.handicap};
        final memberMap = {for (var m in members) m.id: m};
        
        final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
        
        // Handicap & Rules Context
        final config = societyConfig;
        final comp = competitionAsync.value;
        
        // Initialize local groups if not already done
        if (_localGroups == null && event.grouping.containsKey('groups')) {
            _localGroups = (event.grouping['groups'] as List)
                .map((g) => TeeGroup.fromJson(g))
                .toList();
        }
        
        _isLocked ??= event.grouping['locked'] ?? false;
        
        // Initialize local matches if not already done
        _localMatches ??= event.matches;
        
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
                  final double rawHandicap;
                  if (item.isGuest) {
                     rawHandicap = double.tryParse(item.registration.guestHandicap ?? '') ?? 28.0;
                  } else {
                     rawHandicap = handicapMap[item.registration.memberId] ?? 28.0;
                  }

                  final double playingHandicap;
                  if (comp?.rules != null) {
                    playingHandicap = HandicapCalculator.calculatePlayingHandicap(
                      handicapIndex: rawHandicap,
                      rules: comp!.rules,
                      courseConfig: event.courseConfig,
                      useWhs: config.useWhsHandicaps,
                    ).toDouble();
                  } else {
                    playingHandicap = rawHandicap;
                  }
                  
                  unassignedSquad.add(TeeGroupParticipant(
                    registrationMemberId: item.registration.memberId,
                    name: item.name,
                    isGuest: item.isGuest,
                    handicapIndex: rawHandicap,
                    playingHandicap: playingHandicap,
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
          child: HeadlessScaffold(
            title: 'Manage Grouping',
            subtitle: event.title,
            showBack: true,
            onBack: () => context.go('/admin/events'),
            actions: [
              Opacity(
                opacity: event.isRegistrationClosed ? 1.0 : 0.4,
                child: BoxyArtGlassIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: (_localGroups == null || _localGroups!.isEmpty) ? 'Generate' : 'Regenerate',
                  onPressed: event.isRegistrationClosed
                      ? () {
                          if (_isLocked == true) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Groupings locked. Unlock to regenerate.')));
                            return;
                          }
                          _showRegenerationOptions(event, events, handicapMap);
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: event.isRegistrationClosed ? 1.0 : 0.4,
                child: BoxyArtGlassIconButton(
                  icon: _isLocked == true ? Icons.lock_rounded : Icons.lock_open_rounded,
                  tooltip: _isLocked == true ? 'Unlock' : 'Lock',
                  iconColor: _isLocked == true ? Colors.amber : null,
                  onPressed: event.isRegistrationClosed
                      ? () {
                          if (_localGroups == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generate groups first!')));
                            return;
                          }
                          setState(() => _isLocked = !(_isLocked ?? false));
                          _updateDirty(true);
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: event.isRegistrationClosed ? 1.0 : 0.4,
                child: BoxyArtGlassIconButton(
                  icon: Icons.save_rounded,
                  tooltip: 'Save',
                  iconColor: _isDirty ? Colors.amber : null,
                  onPressed: event.isRegistrationClosed ? () => _saveGrouping(event) : null,
                ),
              ),
              const SizedBox(width: 8),
              BoxyArtGlassIconButton(
                icon: event.isGroupingPublished ? Icons.visibility_off_rounded : Icons.send_rounded,
                tooltip: event.isGroupingPublished ? 'Unpublish' : 'Publish',
                iconColor: event.isGroupingPublished ? Colors.orange : null,
                onPressed: () => _togglePublish(event),
              ),
              if (event.secondaryTemplateId != null) ...[
                const SizedBox(width: 8),
                BoxyArtGlassIconButton(
                  icon: _matchPlayMode ? Icons.check_circle_rounded : Icons.circle_outlined,
                  tooltip: 'Match Mode',
                  iconColor: _matchPlayMode ? Colors.orange : null,
                  onPressed: () {
                    setState(() => _matchPlayMode = !_matchPlayMode);
                    if (_matchPlayMode && (_localMatches == null || _localMatches!.isEmpty)) {
                      _autoLinkMatches(event);
                    }
                  },
                ),
              ],
            ],
            slivers: [
              SliverFillRemaining(
                hasScrollBody: true,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        if (unassignedSquad.isNotEmpty) _buildSquadPool(unassignedSquad, memberMap, history),
                        Expanded(
                          child: _localGroups == null 
                            ? _buildEmptyState(event, events, handicapMap)
                            : _buildGroupingList(event, memberMap, history, scorecardsAsync, rules: comp?.rules, useWhs: config.useWhsHandicaps),
                        ),
                      ],
                    ),
                    if (_showGenerationOptions)
                      _buildGenerationOverlay(context, event, events, handicapMap, config, comp?.rules),
                  ],
                ),
              ),
            ],
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
          Icon(Icons.grid_view_rounded, size: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
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
                Icon(Icons.group_add_rounded, size: 16, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'SQUAD POOL (${squad.length})',
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w800, 
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.2,
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
                      child: GroupingPlayerAvatar(player: p, member: memberMap[p.registrationMemberId], size: 48),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GroupingPlayerAvatar(player: p, member: memberMap[p.registrationMemberId], size: 40),
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

  Widget _buildGroupingList(GolfEvent event, Map<String, Member> memberMap, List<GolfEvent> history, AsyncValue<List<Scorecard>> scorecardsAsync, {CompetitionRules? rules, bool useWhs = true}) {
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _localGroups!.removeAt(oldIndex);
          _localGroups!.insert(newIndex, item);
          
          // Re-index and update tee times if needed
          _updateGroupIndicesAndTimes(event);
          _updateDirty(true);
        });
      },
      scrollController: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _localGroups!.length,
      itemBuilder: (context, index) {
        final group = _localGroups![index];
        return GroupingCard(
          key: ValueKey('group_${group.index}_${group.teeTime.millisecondsSinceEpoch}'),
          group: group,
          memberMap: memberMap,
          history: history,
          totalGroups: _localGroups!.length,
          rules: rules,
          courseConfig: event.courseConfig,
          useWhs: useWhs,
          isAdmin: true,
          isLocked: _isLocked ?? false,
          onMove: _handleMove,
          onAction: (action, p, g) => _handlePlayerAction(action, p, g),
          onTapParticipant: _handleParticipantTap,
          isSelected: (p) => p == _selectedForSwap,
          matchPlayMode: _matchPlayMode,
          matches: _localMatches ?? [],
          scorecardMap: scorecardsAsync.asData?.value != null 
              ? {for (var s in scorecardsAsync.asData!.value) s.entryId: s}
              : null,
          emptySlotBuilder: (g) => DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) => _isLocked != true && (details.data['group'] != g || g.players.length < 4),
            onAcceptWithDetails: (details) {
              final sourcePlayer = details.data['player'] as TeeGroupParticipant;
              final sourceGroup = details.data['group'] as TeeGroup?;
              _handleMove(sourcePlayer, sourceGroup, g, null);
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
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: Theme.of(context).primaryColor.withValues(alpha: 0.4)),
                    const SizedBox(width: 8),
                    Text('EMPTY SLOT', style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _updateGroupIndicesAndTimes(GolfEvent event) {
    if (_localGroups == null) return;
    DateTime currentTime = event.teeOffTime ?? DateTime.now();
    int interval = event.teeOffInterval;

    for (int i = 0; i < _localGroups!.length; i++) {
      final oldGroup = _localGroups![i];
      _localGroups![i] = TeeGroup(
        index: i,
        teeTime: currentTime,
        players: oldGroup.players,
      );
      currentTime = currentTime.add(Duration(minutes: interval));
    }
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

      _updateDirty(true);
      
      // Sync Matches if they exist
      if (_localMatches != null && _localMatches!.isNotEmpty) {
        _syncMatchesWithSwap(sourceP, targetP);
      }
    });
  }

  void _syncMatchesWithSwap(TeeGroupParticipant p1, TeeGroupParticipant? p2) {
    if (_localMatches == null) return;
    
    final id1 = p1.registrationMemberId;
    final id2 = p2?.registrationMemberId;

    final updatedMatches = _localMatches!.map((match) {
      List<String> newT1 = List.from(match.team1Ids);
      List<String> newT2 = List.from(match.team2Ids);
      bool changed = false;

      // Swap id1 with id2 in team lists
      for (int i = 0; i < newT1.length; i++) {
        if (newT1[i] == id1) {
          if (id2 != null) {
            newT1[i] = id2;
          } else {
            newT1.removeAt(i); // Remove if swapped to empty
          }
          changed = true;
          break;
        } else if (id2 != null && newT1[i] == id2) {
          newT1[i] = id1;
          changed = true;
          break;
        }
      }

      for (int i = 0; i < newT2.length; i++) {
        if (newT2[i] == id1) {
          if (id2 != null) {
            newT2[i] = id2;
          } else {
            newT2.removeAt(i);
          }
          changed = true;
          break;
        } else if (id2 != null && newT2[i] == id2) {
          newT2[i] = id1;
          changed = true;
          break;
        }
      }

      return changed ? match.copyWith(team1Ids: newT1, team2Ids: newT2) : match;
    }).toList();

    _localMatches = updatedMatches;
  }

  void _handleParticipantTap(TeeGroupParticipant p, TeeGroup g) {
    if (_isLocked == true) return;

    setState(() {
      if (_selectedForSwap == null) {
        _selectedForSwap = p;
        _selectedGroupForSwap = g;
      } else if (_selectedForSwap == p) {
        // Deselect
        _selectedForSwap = null;
        _selectedGroupForSwap = null;
      } else {
        // Perform Swap
        _handleMove(_selectedForSwap!, _selectedGroupForSwap, g, p);
        _selectedForSwap = null;
        _selectedGroupForSwap = null;
      }
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
        p.isCaptain = !p.isCaptain;
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
      final eventsAsync = ref.read(adminEventsProvider);
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
                    child: SingleChildScrollView(
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
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
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
          'matches': _localMatches?.map((m) => m.toJson()).toList() ?? [],
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


  void _autoLinkMatches(GolfEvent event) {
    if (_localGroups == null || _localGroups!.isEmpty) return;

    setState(() {
      final newMatches = <MatchDefinition>[];
      for (final group in _localGroups!) {
        if (group.players.isEmpty) continue;

        // Standard 4-player grouping: 1&2 vs 3&4
        if (group.players.length >= 2) {
          final p1 = group.players[0];
          final p2 = group.players.length >= 2 ? group.players[1] : null;
          final p3 = group.players.length >= 3 ? group.players[2] : null;
          final p4 = group.players.length >= 4 ? group.players[3] : null;

          if (group.players.length == 2) {
            // Singles Match
            newMatches.add(MatchDefinition(
              id: 'match_${group.index}_1',
              team1Ids: [p1.registrationMemberId],
              team2Ids: [p2!.registrationMemberId],
              type: MatchType.singles,
            ));
          } else if (group.players.length >= 4) {
            // Two Singles or one Fourball? 
            // Default to two singles matches as requested for the overlay
            newMatches.add(MatchDefinition(
              id: 'match_${group.index}_1',
              team1Ids: [p1.registrationMemberId],
              team2Ids: [p3!.registrationMemberId],
              type: MatchType.singles,
            ));
            newMatches.add(MatchDefinition(
              id: 'match_${group.index}_2',
              team1Ids: [p2!.registrationMemberId],
              team2Ids: [p4!.registrationMemberId],
              type: MatchType.singles,
            ));
          }
        }
      }
      _localMatches = newMatches;
      _updateDirty(true);
    });
  }
}
