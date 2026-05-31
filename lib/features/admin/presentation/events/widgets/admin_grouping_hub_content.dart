import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:golf_society/features/matchplay/domain/match_definition.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/features/events/logic/event_scoring_controller.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
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
        final bool statusLocked = event.status == EventStatus.inPlay || event.status == EventStatus.completed;
        var isLocked = (ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false)) || statusLocked;
        var selectedForSwap = ref.watch(groupingSelectedForSwapProvider);
        var selectedMatchPartner = ref.watch(groupingSelectedMatchPartnerProvider);

        // Derive Matchplay Mode from Competition Rules
        final bool isMatchPlay = comp?.rules.isMatchPlay ?? false;
        final bool isTournamentGrouping = comp?.rules.isTournamentStyleGrouping ?? false;
        // Overlay pairings: primary game may not be match play, but overlay defines matches
        final bool hasOverlayPairings = event.secondaryTemplateId != null && event.matches.isNotEmpty;
        final bool effectivePairingMode = isMatchPlay || hasOverlayPairings;

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
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.tabToContent, // Standardized gap from tabs (16.0)
            ),
            child: BoxyArtFormColumn(
              children: [
                if (!event.isRegistrationClosed && event.showRegistrationButton && !event.occursToday)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.hero),
                    child: BoxyArtEmptyCard(
                      title: 'Registration Not Completed',
                      message: 'Groupings can be generated once the registration deadline has passed.',
                      icon: Icons.lock_clock_outlined,
                    ),
                  )
                // Overlay event with no tee sheet yet — draw must be sent to field first
                else if (!isTournamentGrouping &&
                    event.secondaryTemplateId != null &&
                    localGroups == null &&
                    event.status != EventStatus.inPlay &&
                    event.status != EventStatus.completed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.hero),
                    child: Column(
                      children: [
                        const BoxyArtEmptyCard(
                          title: 'Match Play Draw Not Sent',
                          message: 'This event has a match play overlay. Send the draw to the field from the Match Play Draw hub — tee groups will populate automatically.',
                          icon: Icons.swap_horiz_rounded,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BoxyArtButton(
                          title: 'Go to Match Play Draw',
                          icon: Icons.swap_horiz_rounded,
                          isTinted: true,
                          fullWidth: true,
                          onTap: () => context.pushNamed(
                            'admin-event-matchplay-draw',
                            pathParameters: {'id': event.id},
                          ),
                        ),
                      ],
                    ),
                  )
                else if (!isTournamentGrouping && event.status != EventStatus.inPlay && event.status != EventStatus.completed)
                  AdminGroupingHubCard(
                    event: event,
                    memberMap: memberMap,
                    onGenerate: () => _handleAutoGenerate(context, ref, event, handicapMap, events),
                    unassignedPlayers: localGroups != null && localGroups.isNotEmpty
                        ? GroupingService.getUnassignedPlayers(
                            event: event,
                            groups: localGroups,
                            memberHandicaps: handicapMap,
                            rules: comp?.rules,
                            useWhs: config.useWhsHandicaps,
                            manualCuts: event.manualCuts,
                          )
                        : const [],
                    hasCapacity: localGroups != null && localGroups.any((g) => g.players.length < 4),
                    onAddToGroups: localGroups != null && localGroups.isNotEmpty
                        ? () => _handleRecalculate(context, ref, event, localGroups!)
                        : null,
                  )
                else if (isTournamentGrouping && event.matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.hero),
                    child: Column(
                      children: [
                        const BoxyArtEmptyCard(
                          title: 'No Draw Generated',
                          message: 'Generate the match play bracket first. Pairings will appear here once published.',
                          icon: Icons.account_tree_outlined,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BoxyArtButton(
                          title: 'Go to Match Play Draw',
                          icon: Icons.account_tree_outlined,
                          isTinted: true,
                          fullWidth: true,
                          onTap: () => context.pushNamed(
                            'admin-event-matchplay-draw',
                            pathParameters: {'id': event.id},
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isTournamentGrouping && event.matches.isNotEmpty && localGroups == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.hero),
                    child: Column(
                      children: [
                        const BoxyArtEmptyCard(
                          title: 'Draw Saved as Draft',
                          message: 'The draw is not yet published. Publish it from the Match Play Draw hub — the tee sheet will populate automatically.',
                          icon: Icons.account_tree_outlined,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BoxyArtButton(
                          title: 'Go to Match Play Draw',
                          icon: Icons.account_tree_outlined,
                          isTinted: true,
                          fullWidth: true,
                          onTap: () => context.pushNamed('admin-event-matchplay-draw', pathParameters: {'id': event.id}),
                        ),
                      ],
                    ),
                  ),

                // Only show the grouping list for Match Play if matches have been finalized/saved
                // This prevents "Group 1" from appearing with members before the Draw is built
                if (localGroups != null && (!isTournamentGrouping || event.matches.isNotEmpty)) ...[
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
                    matchPlayMode: effectivePairingMode,
                    selectedForSwap: selectedForSwap,
                    selectedMatchPartner: selectedMatchPartner,
                    computedEntries: computedEntries,
                    computedGroupResults: computedGroupResults,
                    teamAssignments: () {
                      final raw = comp?.publishSettings['teamAssignments'];
                      if (raw is Map && raw.isNotEmpty) {
                        return Map<String, String>.from(raw);
                      }
                      return null;
                    }(),
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


  Future<void> _handleAutoGenerate(BuildContext context, WidgetRef ref, GolfEvent event, Map<String, double> handicapMap, List<GolfEvent> allEvents) async {
    if (event.matches.isNotEmpty) {
      final confirmed = await BoxyArtDialog.show<bool>(
        context: context,
        title: 'Regenerate Groups?',
        message: 'This will re-sort tee groups from the draw. Any manual adjustments you\'ve made since the draw was pushed will be lost.',
        confirmText: 'REGENERATE',
        cancelText: 'CANCEL',
        isDangerous: true,
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      );
      if (confirmed != true) return;
    }

    final strategy = ref.read(groupingStrategyProvider);
    final comp = ref.read(competitionDetailProvider(event.id)).value;

    final participants = RegistrationLogic.getPlayingParticipants(event);
    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No confirmed participants to group')));
      return;
    }

    final List<TeeGroup> newGroups;

    if (event.matches.isNotEmpty) {
      newGroups = GroupingService.generateMatchPlayGrouping(
        event: event,
        matches: event.matches,
        participants: participants,
        previousEventsInSeason: allEvents,
        memberHandicaps: handicapMap,
        config: ref.read(themeControllerProvider),
        rules: comp?.rules,
        useWhs: ref.read(themeControllerProvider).useWhsHandicaps,
      );
    } else {
      newGroups = GroupingService.generateInitialGrouping(
        event: event,
        participants: participants,
        previousEventsInSeason: allEvents,
        memberHandicaps: handicapMap,
        config: ref.read(themeControllerProvider),
        strategy: strategy,
        rules: comp?.rules,
        useWhs: ref.read(themeControllerProvider).useWhsHandicaps,
      );
    }

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

  Widget _buildGroupingListLayout(BuildContext context, WidgetRef ref, GolfEvent event, List<TeeGroup> localGroups, Map<String, Member> memberMap, List<GolfEvent> history, AsyncValue<List<Scorecard>> scorecardsAsync, {CompetitionRules? rules, bool useWhs = true, required bool isLocked, required bool matchPlayMode, required TeeGroupParticipant? selectedForSwap, TeeGroupParticipant? selectedMatchPartner, Map<String, ProcessedLeaderboardEntry>? computedEntries, Map<int, ProcessedGroupResult>? computedGroupResults, Map<String, String>? teamAssignments}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: BoxyArtFormColumn(
        children: [
          ...localGroups.mapIndexed((index, group) {
                  return GroupingCard(
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
                    onAction: (action, p, g) => _handlePlayerAction(ref, localGroups, action, p, g, matchPlayMode: matchPlayMode, matches: event.matches),
                    onTapParticipant: (p, g) => _handleParticipantTap(ref, localGroups, isLocked, p, g, matchPlayMode: matchPlayMode, matches: event.matches),
                    isSelected: (p) => p == selectedForSwap || p == selectedMatchPartner,
                    matchPlayMode: matchPlayMode,
                    matches: event.matches,
                    groupIndex: index,
                    hcMap: {for (var p in localGroups.expand((g) => g.players)) (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId): p.handicapIndex},
                     scorecardMap: scorecardsAsync.asData?.value != null
                         ? {for (var s in scorecardsAsync.asData!.value) s.entryId: s}
                         : null,
                    isScoreMode: false,
                    showScoring: false,
                    computedEntries: computedEntries,
                    computedGroupResults: computedGroupResults,
                    teamAssignments: teamAssignments,
                  );
        }),
        ],
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

  void _handleParticipantTap(WidgetRef ref, List<TeeGroup> groups, bool isLocked, TeeGroupParticipant p, TeeGroup g, {bool matchPlayMode = false, List<MatchDefinition> matches = const []}) {
    if (isLocked) return;
    final selected = ref.read(groupingSelectedForSwapProvider);

    void clearSelection() {
      ref.read(groupingSelectedForSwapProvider.notifier).set(null);
      ref.read(groupingSelectedMatchPartnerProvider.notifier).set(null);
    }

    if (selected == null) {
      ref.read(groupingSelectedForSwapProvider.notifier).set(p);
      if (matchPlayMode) {
        final partner = _findMatchPartner(p, groups, matches);
        ref.read(groupingSelectedMatchPartnerProvider.notifier).set(partner);
      }
    } else if (selected == p || ref.read(groupingSelectedMatchPartnerProvider) == p) {
      clearSelection();
    } else {
      final sourceGroup = groups.firstWhereOrNull((group) => group.players.contains(selected));
      if (matchPlayMode) {
        final partner = ref.read(groupingSelectedMatchPartnerProvider);
        _handleMatchPairMove(ref, groups, isLocked, selected, partner, sourceGroup, g, p, matches);
      } else {
        _handleMove(ref, groups, isLocked, selected, sourceGroup, g, p);
      }
      clearSelection();
    }
  }

  TeeGroupParticipant? _findMatchPartner(TeeGroupParticipant p, List<TeeGroup> groups, List<MatchDefinition> matches) {
    final playerId = p.registrationMemberId;
    for (final match in matches) {
      String? opponentId;
      if (match.team1Ids.contains(playerId)) {
        opponentId = match.team2Ids.firstOrNull;
      } else if (match.team2Ids.contains(playerId)) {
        opponentId = match.team1Ids.firstOrNull;
      }
      if (opponentId != null) {
        for (final group in groups) {
          final opponent = group.players.firstWhereOrNull((pl) => pl.registrationMemberId == opponentId);
          if (opponent != null) return opponent;
        }
      }
    }
    return null;
  }

  void _handleMatchPairMove(WidgetRef ref, List<TeeGroup> groups, bool isLocked, TeeGroupParticipant selected, TeeGroupParticipant? partner, TeeGroup? sourceGroup, TeeGroup targetGroup, TeeGroupParticipant targetP, List<MatchDefinition> matches) {
    if (isLocked || sourceGroup == targetGroup) return;
    final targetPartner = _findMatchPartner(targetP, groups, matches);

    final newGroups = List<TeeGroup>.from(groups);

    sourceGroup?.players.remove(selected);
    if (partner != null) sourceGroup?.players.remove(partner);
    targetGroup.players.remove(targetP);
    if (targetPartner != null) targetGroup.players.remove(targetPartner);

    targetGroup.players.add(selected);
    if (partner != null) targetGroup.players.add(partner);
    if (sourceGroup != null) {
      sourceGroup.players.add(targetP);
      if (targetPartner != null) sourceGroup.players.add(targetPartner);
    }

    _updateDirty(true, newGroups, isLocked);
  }

  void _handlePlayerAction(WidgetRef ref, List<TeeGroup> groups, String action, TeeGroupParticipant p, TeeGroup currentGroup, {bool matchPlayMode = false, List<MatchDefinition> matches = const []}) async {
    if (action == 'captain') {
      for (final member in currentGroup.players) {
        member.isCaptain = false;
      }
      p.isCaptain = !p.isCaptain;
      _updateDirty(true, groups, null);
    } else if (action == 'remove') {
      setState(() {
        currentGroup.players.remove(p);
        _updateDirty(true, groups, null);
      });
    } else if (action == 'move') {
      _showMoveSheet(context, ref, groups, p, currentGroup, matchPlayMode: matchPlayMode, matches: matches);
    } else if (action == 'tee') {
       final eventsAsync = ref.read(adminEventsProvider);
       final event = eventsAsync.value?.firstWhere((e) => e.id == widget.eventId);
       if (event == null) return;

       _showTeeSelector(
         context: context, 
         ref: ref, 
         event: event, 
         memberId: p.registrationMemberId, 
         currentTeeName: p.teeName ?? 'Yellow', 
         onTeeSelected: (newTee) {
            // Update the local participant
            p.status = p.status; // dummy update to ensure groups ref remains
            // We need to update the participant in the local groups list
            final updatedGroups = List<TeeGroup>.from(groups);
            // Search for the player across groups (though we have p already)
            // Update the local participant
            p.teeName = newTee;
            _updateDirty(true, updatedGroups, null);
            
            // Also update the Registration in Firestore for consistency
            _syncTeeToRegistration(ref, event, p.registrationMemberId, p.isGuest, newTee);
         },
       );
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

  void _showMoveSheet(BuildContext context, WidgetRef ref, List<TeeGroup> groups, TeeGroupParticipant p, TeeGroup currentGroup, {bool matchPlayMode = false, List<MatchDefinition> matches = const []}) {
    final partner = matchPlayMode ? _findMatchPartner(p, groups, matches) : null;
    final slotsNeeded = partner != null ? 2 : 1;
    final sheetTitle = partner != null ? 'Move ${p.name} + Opponent' : 'Move ${p.name}';

    BoxyArtBottomSheet.show(
      context: context,
      title: sheetTitle,
      child: BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: groups.asMap().entries.where((e) => e.value != currentGroup).map((e) {
            final idx = e.key;
            final group = e.value;
            final isFull = group.players.length + slotsNeeded > 4;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (idx != groups.indexWhere((g) => g != currentGroup))
                  const BoxyArtDivider(),
                BoxyArtNavTile(
                  icon: Icons.group_rounded,
                  title: 'Group ${idx + 1}',
                  subtitle: '${group.players.length} / 4 players${isFull ? ' — Full' : ''}',
                  iconColor: isFull ? AppColors.dark400 : null,
                  onTap: isFull ? () {} : () {
                    Navigator.pop(context);
                    setState(() {
                      currentGroup.players.remove(p);
                      if (partner != null) currentGroup.players.remove(partner);
                      group.players.add(p);
                      if (partner != null) group.players.add(partner);
                      _updateDirty(true, groups, null);
                    });
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleRecalculate(BuildContext context, WidgetRef ref, GolfEvent event, List<TeeGroup> currentGroups) {
    final members = ref.read(allMembersProvider).value ?? [];
    final handicapMap = {for (var m in members) m.id: m.handicap};
    final rules = ref.read(competitionDetailProvider(event.id)).value?.rules;
    final useWhs = ref.read(themeControllerProvider).useWhsHandicaps;

    final unassigned = GroupingService.getUnassignedPlayers(
      event: event,
      groups: currentGroups,
      memberHandicaps: handicapMap,
      rules: rules,
      useWhs: useWhs,
      manualCuts: event.manualCuts,
    );

    if (unassigned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All confirmed players are already assigned.')),
      );
      return;
    }

    final updatedGroups = currentGroups
        .map((g) => g.copyWith(players: List<TeeGroupParticipant>.from(g.players)))
        .toList();
    var pool = List<TeeGroupParticipant>.from(unassigned);

    for (final group in updatedGroups) {
      while (group.players.length < 4 && pool.isNotEmpty) {
        group.players.add(pool.removeAt(0));
      }
      if (pool.isEmpty) break;
    }

    // Safety: a solo player remaining would create an invalid 1-ball group.
    // Steal one from the largest full group to make a 2-ball instead.
    if (pool.length == 1) {
      final donor = updatedGroups
          .where((g) => g.players.length >= 4)
          .fold<TeeGroup?>(null, (best, g) =>
              best == null || g.players.length > best.players.length ? g : best);
      if (donor != null) {
        pool.insert(0, donor.players.removeLast());
      }
    }

    while (pool.isNotEmpty) {
      final chunk = pool.take(4).toList();
      pool.removeRange(0, chunk.length);
      final lastTime = updatedGroups.last.teeTime;
      updatedGroups.add(TeeGroup(
        index: updatedGroups.length,
        teeTime: lastTime.add(const Duration(minutes: 10)),
        players: chunk,
      ));
    }

    _updateDirty(true, updatedGroups, null);
    _handleSave(context, ref, event);
  }

  void _syncTeeToRegistration(WidgetRef ref, GolfEvent event, String memberId, bool isGuest, String newTee) async {
    final registrations = List<EventRegistration>.from(event.registrations);
    final idx = registrations.indexWhere((r) => r.memberId == memberId);
    if (idx >= 0) {
      final reg = registrations[idx];
      final updatedReg = isGuest 
          ? reg.copyWith(guestTeeName: newTee)
          : reg.copyWith(teeName: newTee);
      
      registrations[idx] = updatedReg;
      final updatedEvent = event.copyWith(registrations: registrations);
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
    }
  }

  void _showTeeSelector({
    required BuildContext context,
    required WidgetRef ref,
    required GolfEvent event,
    required String memberId,
    required String currentTeeName,
    required Function(String) onTeeSelected,
  }) {
    final courseDetail = event.courseId != null 
        ? ref.read(courseDetailProvider(event.courseId!)).value 
        : null;
    
    final tees = courseDetail?.tees ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppShapes.sheet,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'SELECT TEE'),
            const SizedBox(height: AppSpacing.md),
            if (tees.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'NO TEES DEFINED FOR THIS COURSE. PLEASE ENSURE THE COURSE CONFIGURATION IS COMPLETE.',
                  style: TextStyle(
                    fontSize: AppTypography.sizeCaption,
                    color: AppColors.dark400,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: SingleChildScrollView(
                  child: Column(
                    children: tees.map((t) => BoxyArtCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      onTap: () {
                         onTeeSelected(t.name);
                         Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.getTeeColor(t.name, tees),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            t.name.toUpperCase(), 
                            style: const TextStyle(
                              fontWeight: AppTypography.weightBlack,
                              fontSize: AppTypography.sizeButton,
                              letterSpacing: 0.5,
                            )
                          ),
                          const Spacer(),
                          if (t.name == currentTeeName)
                            const Icon(Icons.check_circle_rounded, color: AppColors.lime500),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
