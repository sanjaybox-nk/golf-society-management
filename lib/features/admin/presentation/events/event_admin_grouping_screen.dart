import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../models/golf_event.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';

class EventAdminGroupingScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAdminGroupingScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminGroupingScreen> createState() => _EventAdminGroupingScreenState();
}

class _EventAdminGroupingScreenState extends ConsumerState<EventAdminGroupingScreen> {
  List<TeeGroup>? _localGroups;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final allEventsAsync = ref.watch(adminEventsProvider); // For variety logic
    final membersAsync = ref.watch(allMembersProvider);

    return eventsAsync.when(
      data: (events) {
        final members = membersAsync.value ?? [];
        final handicapMap = {for (var m in members) m.id: m.handicap};
        
        final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        
        // Initialize local groups if not already done
        if (_localGroups == null && event.grouping.containsKey('groups')) {
            _localGroups = (event.grouping['groups'] as List)
                .map((g) => TeeGroup.fromJson(g))
                .toList();
        }

        return Material(
          child: Column(
            children: [
              BoxyArtAppBar(
                title: 'Grouping',
                showBack: true,
                onBack: () => context.go('/admin/events'),
                actions: [
                  if (_localGroups != null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Regenerate',
                      onPressed: () {
                         final members = membersAsync.value ?? [];
                         final handicapMap = {for (var m in members) m.id: m.handicap};
                         _handleAutoGenerate(event, allEventsAsync.value ?? [], handicapMap);
                      },
                    ),
                  BoxyArtCircularIconBtn(
                    icon: Icons.save,
                    onTap: () => _saveGrouping(event),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: _localGroups == null 
                  ? _buildEmptyState(event, allEventsAsync.value ?? [], handicapMap)
                  : _buildGroupingList(event),
              ),
              if (_localGroups != null) _buildPublishBar(event),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEmptyState(GolfEvent event, List<GolfEvent> allEvents, Map<String, double> handicapMap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.grid_view_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No grouping generated yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          BoxyArtButton(
            title: 'Auto-Generate Grouping',
            onTap: () => _handleAutoGenerate(event, allEvents, handicapMap),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupingList(GolfEvent event) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _localGroups!.length,
      itemBuilder: (context, index) {
        final group = _localGroups![index];
        return _buildGroupCard(group);
      },
    );
  }

  Widget _buildGroupCard(TeeGroup group) {
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
          ...group.players.map((p) => _buildPlayerTile(p, group)),
        ],
      ),
    ),
  );
}


  Widget _buildBuggyIcon(RegistrationStatus status) {
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
        color = Colors.grey;
    }
    return Icon(Icons.electric_car, color: color, size: 14);
  }
  Widget _buildPlayerTile(TeeGroupParticipant p, TeeGroup group) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: p.isCaptain ? Colors.orange : Colors.grey.shade200,
        child: Icon(
          p.isGuest ? Icons.person_outline : Icons.person,
          color: p.isCaptain ? Colors.white : Colors.black54,
          size: 20,
        ),
      ),
      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Row(
        children: [
          if (p.buggyStatus != RegistrationStatus.none) ...[
            _buildBuggyIcon(p.buggyStatus),
            const SizedBox(width: 8),
          ],
          Text('HC: ${p.handicap.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p.isCaptain)
            const Chip(
              label: Text('CAPTAIN', style: TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: Colors.orange,
              padding: EdgeInsets.zero,
            ),
          PopupMenuButton<String>(
            onSelected: (val) => _handlePlayerAction(val, p, group),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'captain', child: Text('Toggle Captain')),
              const PopupMenuItem(value: 'move', child: Text('Move to Group...')),
              PopupMenuItem(
                value: 'buggy', 
                child: Text(p.needsBuggy ? 'Change Buggy Status' : 'Add Buggy Request'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPublishBar(GolfEvent event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: BoxyArtButton(
                title: event.isGroupingPublished ? 'Unpublish' : 'Publish to Members',
                onTap: () => _togglePublish(event),
                isSecondary: event.isGroupingPublished,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAutoGenerate(GolfEvent event, List<GolfEvent> allEvents, Map<String, double> handicapMap) {
    final participants = RegistrationLogic.getSortedItems(event);
    final previousInSeason = allEvents.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();

    setState(() {
      _localGroups = GroupingService.generateInitialGrouping(
        event: event, 
        participants: participants, 
        previousEventsInSeason: previousInSeason,
        memberHandicaps: handicapMap,
      );
    });
  }

  void _handlePlayerAction(String action, TeeGroupParticipant p, TeeGroup currentGroup) {
    if (action == 'captain') {
      setState(() {
        // Clear other captains in group first
        for (var player in currentGroup.players) {
          player.isCaptain = false;
        }
        p.isCaptain = !p.isCaptain;
      });
    } else if (action == 'buggy') {
      _togglePlayerBuggy(p, currentGroup);
    } else if (action == 'move') {
      _showMoveDialog(p, currentGroup);
    }
  }

  void _togglePlayerBuggy(TeeGroupParticipant p, TeeGroup group) {
    setState(() {
      if (!p.needsBuggy) {
        // 1. Enable
        p.needsBuggy = true;
        p.buggyStatus = RegistrationStatus.reserved; // Start as reserved (unpaid or waiting)
      } else if (p.buggyStatus == RegistrationStatus.reserved) {
        // 2. Next is Confirmed
        p.buggyStatus = RegistrationStatus.confirmed;
      } else if (p.buggyStatus == RegistrationStatus.confirmed) {
        // 3. Next is Waitlist
        p.buggyStatus = RegistrationStatus.waitlist;
      } else {
        // 4. Disable
        p.needsBuggy = false;
        p.buggyStatus = RegistrationStatus.none;
      }
    });
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
                  setState(() {
                    currentGroup.players.remove(p);
                    g.players.add(p);
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveGrouping(GolfEvent event) async {
    if (_localGroups == null) return;
    
    try {
      final updatedEvent = event.copyWith(
        grouping: {
          'groups': _localGroups!.map((g) => g.toJson()).toList(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
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
