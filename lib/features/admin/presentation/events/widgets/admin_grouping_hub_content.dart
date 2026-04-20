import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/events/presentation/widgets/grouping_widgets.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';
import 'package:golf_society/features/notifications/domain/notification_broadcast_service.dart';
import 'package:golf_society/features/matchplay/domain/golf_event_match_extensions.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/features/events/logic/event_scoring_controller.dart';
import './admin_grouping_hub_card.dart';

class AdminGroupingHubContent extends ConsumerStatefulWidget {
  final String eventId;
  final bool isHubMode;

  const AdminGroupingHubContent({
    super.key,
    required this.eventId,
    this.isHubMode = false,
  });

  @override
  ConsumerState<AdminGroupingHubContent> createState() => _AdminGroupingHubContentState();
}

class _AdminGroupingHubContentState extends ConsumerState<AdminGroupingHubContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateDirty(bool dirty, List<TeeGroup>? groups, bool? isLocked) {
    ref.read(groupingDirtyProvider.notifier).setDirty(dirty);
    if (dirty) {
      ref.read(groupingLocalGroupsProvider.notifier).setGroups(groups);
      ref.read(groupingIsLockedProvider.notifier).setLocked(isLocked);
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
        if (competitionAsync.isLoading) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }

        final members = membersAsync.value ?? [];
        final handicapMap = {for (var m in members) m.id: m.handicap};
        final memberMap = {for (var m in members) m.id: m};
        
        final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
        
        final config = societyConfig;
        final comp = competitionAsync.value;
        
        // Use providers for state
        var localGroups = ref.watch(groupingLocalGroupsProvider);
        var isLocked = ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false);
        var selectedForSwap = ref.watch(groupingSelectedForSwapProvider);

        // Derive Matchplay Mode from Competition Rules
        final bool matchPlayMode = comp?.rules.format == CompetitionFormat.matchPlay;

        // Initialize grouping strategy and existing groups if needed
        final currentStrategy = ref.watch(groupingStrategyProvider);
        if (event.groupingStrategy != null && currentStrategy == 'random' && event.groupingStrategy != 'random') {
           Future.microtask(() => ref.read(groupingStrategyProvider.notifier).set(event.groupingStrategy!));
        } else if (event.groupingStrategy == null && currentStrategy == 'random' && config.groupingStrategy != 'random') {
           Future.microtask(() => ref.read(groupingStrategyProvider.notifier).set(config.groupingStrategy));
        }

        if (localGroups == null && event.grouping.containsKey('groups')) {
            localGroups = (event.grouping['groups'] as List)
                .map((g) => TeeGroup.fromJson(g))
                .toList();
            // Using future to avoid build-time state update
            Future.microtask(() => ref.read(groupingLocalGroupsProvider.notifier).setGroups(localGroups));
        }
        
        // Fetch Centralized Computed Data
        final scoringData = ref.watch(eventScoringControllerProvider(widget.eventId));
        final computedEntries = { for (var e in scoringData.leaderboard) e.entryId: e };
        final computedGroupResults = { for (var g in scoringData.groupRankings) g.groupIndex : g };
        
        // Calculate Unassigned Players
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                AdminGroupingHubCard(
                  event: event,
                  onGenerate: () => _handleAutoGenerate(context, ref, event, handicapMap, events),
                ),

                if (localGroups != null) ...[
                  const SizedBox(height: AppSpacing.standard),
                  _buildGroupingListLayout(
                    context, 
                    ref, 
                    event, 
                    localGroups, 
                    memberMap, 
                    history, 
                    scorecardsAsync, 
                    rules: comp?.rules, 
                    useWhs: config.useWhsHandicaps, 
                    isLocked: isLocked, 
                    matchPlayMode: matchPlayMode, 
                    selectedForSwap: selectedForSwap, 
                    computedEntries: computedEntries,
                    computedGroupResults: computedGroupResults,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
    );
  }


  void _handleAutoGenerate(BuildContext context, WidgetRef ref, GolfEvent event, Map<String, double> handicapMap, List<GolfEvent> allEvents) {
    final strategy = ref.read(groupingStrategyProvider);
    
    final participants = RegistrationLogic.getPlayingParticipants(event);
    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No confirmed participants to group')));
      return;
    }

    final newGroups = GroupingService.generateInitialGrouping(
      event: event, 
      participants: participants,
      previousEventsInSeason: allEvents,
      memberHandicaps: handicapMap,
      config: ref.read(themeControllerProvider),
      strategy: strategy,
    );

    ref.read(groupingLocalGroupsProvider.notifier).setGroups(newGroups);
    _handleSave(context, ref, event);
  }




  Future<void> _handleSave(BuildContext context, WidgetRef ref, GolfEvent event) async {
    final groups = ref.read(groupingLocalGroupsProvider);
    if (groups == null) return;

    final updatedEvent = event.copyWith(
      groupingStrategy: ref.read(groupingStrategyProvider),
      grouping: {
        ...event.grouping,
        'groups': groups.map((g) => g.toJson()).toList(),
        'locked': ref.read(groupingIsLockedProvider) ?? false,
      },
    );

    await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
    ref.read(groupingDirtyProvider.notifier).setDirty(false);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grouping saved!'), backgroundColor: AppColors.teamA));
    }
  }

  Widget _buildGroupingListLayout(BuildContext context, WidgetRef ref, GolfEvent event, List<TeeGroup> localGroups, Map<String, Member> memberMap, List<GolfEvent> history, AsyncValue<List<Scorecard>> scorecardsAsync, {CompetitionRules? rules, bool useWhs = true, required bool isLocked, required bool matchPlayMode, required TeeGroupParticipant? selectedForSwap, Map<String, ProcessedLeaderboardEntry>? computedEntries, Map<int, ProcessedGroupResult>? computedGroupResults}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: localGroups.mapIndexed((index, group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GroupingCard(
              group: group,
              memberMap: memberMap,
              history: history,
              totalGroups: localGroups.length,
              rules: rules,
              courseConfig: event.courseConfig,
              useWhs: useWhs,
              isAdmin: true,
              isLocked: isLocked,
              onMove: (sp, sg, tg, tp) => _handleMove(ref, localGroups, isLocked, sp, sg, tg, tp),
              onAction: (action, p, g) => _handlePlayerAction(ref, localGroups, action, p, g),
              onTapParticipant: (p, g) => _handleParticipantTap(ref, localGroups, isLocked, p, g),
              isSelected: (p) => p == selectedForSwap,
              matchPlayMode: matchPlayMode,
              matches: event.matches,
              groupIndex: index,
              hcMap: {for (var p in localGroups.expand((g) => g.players)) (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId): p.handicapIndex},
               scorecardMap: scorecardsAsync.asData?.value != null 
                   ? {for (var s in scorecardsAsync.asData!.value) s.entryId: s}
                   : null,
              isScoreMode: true, 
              showScoring: true, 
              computedEntries: computedEntries,
              computedGroupResults: computedGroupResults,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleMove(WidgetRef ref, List<TeeGroup> groups, bool isLocked, TeeGroupParticipant sourceP, TeeGroup? sourceG, TeeGroup targetG, TeeGroupParticipant? targetP) {
    if (isLocked) return;
    
    final newGroups = List<TeeGroup>.from(groups);
    
    if (sourceG == targetG) {
       if (targetP != null && sourceP != targetP) {
          final sIdx = sourceG?.players.indexOf(sourceP) ?? -1;
          final tIdx = targetG.players.indexOf(targetP);
          if (sIdx != -1 && tIdx != -1) {
            targetG.players[sIdx] = targetP;
            targetG.players[tIdx] = sourceP;
          }
        }
    } else {
       if (sourceG != null) sourceG.players.remove(sourceP);
       if (targetP != null) {
          final tIdx = targetG.players.indexOf(targetP);
          if (sourceG != null) {
             targetG.players.removeAt(tIdx);
             targetG.players.insert(tIdx, sourceP);
             sourceG.players.add(targetP);
          } else {
             targetG.players.insert(tIdx, sourceP);
          }
       } else if (targetG.players.length < 4) {
          targetG.players.add(sourceP);
       }
    }
    
    _updateDirty(true, newGroups, isLocked);
  }

  void _handleParticipantTap(WidgetRef ref, List<TeeGroup> groups, bool isLocked, TeeGroupParticipant p, TeeGroup g) {
    if (isLocked) return;
    final selected = ref.read(groupingSelectedForSwapProvider);
    if (selected == null) {
      ref.read(groupingSelectedForSwapProvider.notifier).set(p);
    } else if (selected == p) {
      ref.read(groupingSelectedForSwapProvider.notifier).set(null);
    } else {
      _handleMove(ref, groups, isLocked, selected, null, g, p); 
      ref.read(groupingSelectedForSwapProvider.notifier).set(null);
    }
  }

  void _handlePlayerAction(WidgetRef ref, List<TeeGroup> groups, String action, TeeGroupParticipant p, TeeGroup currentGroup) async {
    if (action == 'captain') {
       p.isCaptain = !p.isCaptain;
       _updateDirty(true, groups, null);
    } else if (action == 'withdraw') {
       final eventsAsync = ref.read(adminEventsProvider);
       final event = eventsAsync.value?.firstWhere((e) => e.id == widget.eventId);
       if (event == null) return;

       final result = GroupingService.handleWithdrawal(
         event: event,
         memberId: p.registrationMemberId,
         isGuest: p.isGuest,
         allMembers: ref.read(allMembersProvider).value ?? [],
         useWhs: ref.read(themeControllerProvider).useWhsHandicaps,
         config: ref.read(themeControllerProvider),
         previousEvents: ref.read(adminEventsProvider).value ?? [],
         rules: ref.read(competitionDetailProvider(event.id)).value?.rules,
       );

       await ref.read(eventsRepositoryProvider).updateEvent(result.event);
       
       final newGroupsData = result.event.grouping['groups'] as List?;
       if (newGroupsData != null) {
          final newGroups = newGroupsData.map((g) => TeeGroup.fromJson(g)).toList();
          ref.read(groupingLocalGroupsProvider.notifier).setGroups(newGroups);
          ref.read(groupingDirtyProvider.notifier).setDirty(false);
       }

       final notificationService = ref.read(renewalNudgeServiceProvider);
       final allMembers = ref.read(allMembersProvider).value ?? [];
       
       await notificationService.notifyCommitteeOfWithdrawal(
         event: result.event, 
         playerName: result.playerName, 
         allMembers: allMembers,
       );

       if (result.promotedPlayerId != null) {
         await notificationService.notifyPlayerOfPromotion(
           event: result.event, 
           member: allMembers.where((m) => m.id == result.promotedPlayerId).first, 
           groupIndex: 0, 
         );
       }
    }
  }
}
