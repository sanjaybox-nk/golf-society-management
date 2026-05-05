import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../events/domain/registration_logic.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import '../../providers/admin_ui_providers.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/society_config.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../events/presentation/widgets/grouping_widgets.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import '../../logic/society_cuts_engine.dart';
import '../../../events/logic/event_scoring_controller.dart';
import '../../../events/domain/models/processed_event_data.dart';
import 'widgets/grouping_squad_pool.dart';
import 'widgets/grouping_generation_sheet.dart';
import 'widgets/grouping_toolbar.dart';

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

  TeeGroupParticipant? _selectedForSwap;
  TeeGroup? _selectedGroupForSwap;

  List<MatchDefinition>? _localMatches;
  bool _matchPlayMode = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateDirty(bool dirty) {
    if (_isDirty != dirty) {
      setState(() { _isDirty = dirty; });
      ref.read(groupingDirtyProvider.notifier).setDirty(dirty);
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
        if (competitionAsync.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final members = membersAsync.value ?? [];
        final handicapMap = {for (var m in members) m.id: m.handicap};
        final memberMap = {for (var m in members) m.id: m};
        final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
        final config = societyConfig;
        final comp = competitionAsync.value;

        if (_localGroups == null && event.grouping.containsKey('groups')) {
          _localGroups = (event.grouping['groups'] as List).map((g) => TeeGroup.fromJson(g)).toList();
        }
        _isLocked ??= event.grouping['locked'] ?? false;
        _localMatches ??= event.matches;

        final unassignedSquad = _computeUnassignedSquad(event, history, handicapMap, config, comp);

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
          child: Stack(
            children: [
              HeadlessScaffold(
                title: 'Grouping',
                subtitleWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: AppTypography.sizeBodySmall,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                        fontWeight: AppTypography.weightSemibold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GroupingToolbar(
                      event: event,
                      isLocked: _isLocked ?? false,
                      isDirty: _isDirty,
                      hasGroups: _localGroups?.isNotEmpty ?? false,
                      matchPlayMode: _matchPlayMode,
                      onGenerate: () => _showRegenerationOptions(),
                      onRecalculate: () => _recalculateAllPHCs(event, handicapMap, comp?.rules, config.useWhsHandicaps),
                      onToggleLock: () {
                        setState(() => _isLocked = !(_isLocked ?? false));
                        _updateDirty(true);
                      },
                      onToggleMatchMode: () {
                        setState(() => _matchPlayMode = !_matchPlayMode);
                        if (_matchPlayMode && (_localMatches == null || _localMatches!.isEmpty)) {
                          _autoLinkMatches(event);
                        }
                      },
                      onSave: () => _saveGrouping(event),
                      onPublish: () => _togglePublish(event),
                    ),
                  ],
                ),
                topPill: BoxyArtPill.committee(label: 'ADMIN'),
                showBack: true,
                onBack: () async {
                  if (_isDirty) {
                    final action = await _showExitConfirmation();
                    if (action == GroupingExitAction.save && context.mounted) {
                      await _saveGrouping(event);
                      if (context.mounted) context.go('/admin/events');
                    } else if (action == GroupingExitAction.discard && context.mounted) {
                      _updateDirty(false);
                      context.go('/admin/events');
                    }
                  } else {
                    context.go('/admin/events');
                  }
                },
                actions: const [],
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Column(
                      children: [
                        if (unassignedSquad.isNotEmpty)
                          GroupingSquadPool(squad: unassignedSquad, memberMap: memberMap),
                        Expanded(
                          child: _localGroups == null
                              ? _buildEmptyState(event, events, handicapMap)
                              : _buildGroupingList(event, memberMap, history, scorecardsAsync, rules: comp?.rules, useWhs: config.useWhsHandicaps),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showGenerationOptions)
                GroupingGenerationSheet(
                  initialStrategy: config.groupingStrategy,
                  onDismiss: () => setState(() => _showGenerationOptions = false),
                  onGenerate: (strategy, pairBuggies) {
                    setState(() => _showGenerationOptions = false);
                    _handleAutoGenerate(
                      event, events, handicapMap,
                      prioritizeBuggyPairing: pairBuggies,
                      strategyOverride: strategy,
                      config: config,
                      rules: comp?.rules,
                    );
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => HeadlessScaffold(
        title: 'Error',
        topPill: BoxyArtPill.committee(label: 'ADMIN'),
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: BoxyArtEmptyCard(
                  title: 'Unexpected Error',
                  message: err.toString(),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Unassigned squad computation ────────────────────────────────────────────

  List<TeeGroupParticipant> _computeUnassignedSquad(
    GolfEvent event,
    List<GolfEvent> history,
    Map<String, double> handicapMap,
    SocietyConfig config,
    Competition? comp,
  ) {
    if (_localGroups == null) return [];

    final unassigned = <TeeGroupParticipant>[];
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

      if (status != RegistrationStatus.confirmed) continue;
      rollingCount++;

      final playerId = '${item.registration.memberId}|${item.isGuest}';
      if (assignedPlayerIds.contains(playerId)) continue;

      final double rawHandicap = item.isGuest
          ? (double.tryParse(item.registration.guestHandicap ?? '') ?? 28.0)
          : (handicapMap[item.registration.memberId] ?? 28.0);

      final double playingHandicap;
      if (comp?.rules != null) {
        final double automatedCut = (config.societyCutMode == SocietyCutMode.global)
            ? SocietyCutsEngine.calculateActiveCut(
                memberId: item.registration.memberId,
                allEvents: history,
                config: config,
                relativeTo: event.date,
              ).totalCut
            : 0.0;
        playingHandicap = HandicapCalculator.calculatePlayingHandicap(
          handicapIndex: rawHandicap,
          rules: comp!.rules,
          courseConfig: event.courseConfig,
          useWhs: config.useWhsHandicaps,
          societyCut: (event.manualCuts[item.registration.memberId] ?? 0.0) + automatedCut,
        ).toDouble();
      } else {
        playingHandicap = rawHandicap;
      }

      unassigned.add(TeeGroupParticipant(
        registrationMemberId: item.registration.memberId,
        name: item.name,
        isGuest: item.isGuest,
        handicapIndex: rawHandicap,
        playingHandicap: playingHandicap,
        needsBuggy: item.needsBuggy,
        buggyStatus: RegistrationStatus.confirmed,
      ));
    }

    return unassigned;
  }

  // ── Build helpers ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(GolfEvent event, List<GolfEvent> allEvents, Map<String, double> handicapMap) {
    final isClosed = event.isRegistrationClosed;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: BoxyArtEmptyCard(
          title: 'No Grouping Generated',
          message: "Your squad hasn't been sorted into groups yet. Once registration is closed, you can auto-generate the tee sheet.",
          icon: Icons.grid_view_rounded,
          actionLabel: isClosed ? 'Auto-Generate Grouping' : null,
          onAction: isClosed ? () => _showRegenerationOptions() : null,
        ),
      ),
    );
  }

  Widget _buildGroupingList(
    GolfEvent event,
    Map<String, Member> memberMap,
    List<GolfEvent> history,
    AsyncValue<List<Scorecard>> scorecardsAsync, {
    CompetitionRules? rules,
    bool useWhs = true,
  }) {
    final scoringData = ref.watch(eventScoringControllerProvider(widget.eventId));
    final Map<String, ProcessedLeaderboardEntry> computedEntries = {for (var e in scoringData.leaderboard) e.entryId: e};

    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _localGroups!.removeAt(oldIndex);
          _localGroups!.insert(newIndex, item);
          _updateGroupIndicesAndTimes(event);
          _updateDirty(true);
        });
      },
      scrollController: _scrollController,
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 100),
      itemCount: _localGroups!.length,
      itemBuilder: (context, index) {
        final group = _localGroups![index];
        return Padding(
          key: ValueKey('group_${group.index}_${group.teeTime.millisecondsSinceEpoch}'),
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GroupingCard(
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
            computedEntries: computedEntries,
            computedGroupResults: {for (var g in scoringData.groupRankings) g.groupIndex: g},
            groupIndex: index,
            scorecardMap: scorecardsAsync.asData?.value != null
                ? {for (var s in scorecardsAsync.asData!.value) s.entryId: s}
                : null,
            isScoreMode: false,
            showScoring: false,
            emptySlotBuilder: (g) => DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) =>
                  _isLocked != true && (details.data['group'] != g || g.players.length < 4),
              onAcceptWithDetails: (details) {
                final sourcePlayer = details.data['player'] as TeeGroupParticipant;
                final sourceGroup = details.data['group'] as TeeGroup?;
                _handleMove(sourcePlayer, sourceGroup, g, null);
              },
              onMove: (details) {
                final RenderBox? box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  final position = box.globalToLocal(details.offset);
                  _checkAutoScroll(position.dy, box.size.height);
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isOver = candidateData.isNotEmpty;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final primary = Theme.of(context).colorScheme.primary;
                return AnimatedContainer(
                  duration: AppAnimations.fast,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: AppShapes.md,
                    border: Border.all(
                      color: isOver
                          ? primary
                          : (isDark
                              ? AppColors.pureWhite.withValues(alpha: AppColors.opacityLow)
                              : Colors.black.withValues(alpha: AppColors.opacitySubtle)),
                      style: BorderStyle.solid,
                      width: isOver ? 2 : 1,
                    ),
                    color: isOver ? primary.withValues(alpha: AppColors.opacityLow) : Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: AppShapes.iconSm,
                        color: isOver ? primary : primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'EMPTY SLOT',
                        style: AppTypography.displayMedium.copyWith(
                          color: isOver ? primary : primary.withValues(alpha: 0.4),
                          fontSize: AppTypography.sizeCaptionStrong,
                          fontWeight: AppTypography.weightExtraBold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── State mutation methods ────────────────────────────────────────────────────

  void _updateGroupIndicesAndTimes(GolfEvent event) {
    if (_localGroups == null) return;
    DateTime currentTime = event.teeOffTime ?? DateTime.now();
    final interval = event.teeOffInterval;
    for (int i = 0; i < _localGroups!.length; i++) {
      final old = _localGroups![i];
      _localGroups![i] = TeeGroup(index: i, teeTime: currentTime, players: old.players);
      currentTime = currentTime.add(Duration(minutes: interval));
    }
  }

  void _handleMove(TeeGroupParticipant sourceP, TeeGroup? sourceG, TeeGroup targetG, TeeGroupParticipant? targetP) {
    setState(() {
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
      } else {
        if (targetG.players.length < 4) targetG.players.add(sourceP);
      }

      if (targetG.players.length > 4) {
        final excess = targetG.players.removeLast();
        sourceG?.players.add(excess);
      }

      _updateDirty(true);
      if (_localMatches != null && _localMatches!.isNotEmpty) {
        _syncMatchesWithSwap(sourceP, targetP);
      }
    });
  }

  void _syncMatchesWithSwap(TeeGroupParticipant p1, TeeGroupParticipant? p2) {
    if (_localMatches == null) return;
    final id1 = p1.registrationMemberId;
    final id2 = p2?.registrationMemberId;

    _localMatches = _localMatches!.map((match) {
      List<String> newT1 = List.from(match.team1Ids);
      List<String> newT2 = List.from(match.team2Ids);
      bool changed = false;

      for (int i = 0; i < newT1.length; i++) {
        if (newT1[i] == id1) {
          if (id2 != null) { newT1[i] = id2; } else { newT1.removeAt(i); }
          changed = true; break;
        } else if (id2 != null && newT1[i] == id2) {
          newT1[i] = id1; changed = true; break;
        }
      }
      for (int i = 0; i < newT2.length; i++) {
        if (newT2[i] == id1) {
          if (id2 != null) { newT2[i] = id2; } else { newT2.removeAt(i); }
          changed = true; break;
        } else if (id2 != null && newT2[i] == id2) {
          newT2[i] = id1; changed = true; break;
        }
      }
      return changed ? match.copyWith(team1Ids: newT1, team2Ids: newT2) : match;
    }).toList();
  }

  void _handleParticipantTap(TeeGroupParticipant p, TeeGroup g) {
    if (_isLocked == true) return;
    setState(() {
      if (_selectedForSwap == null) {
        _selectedForSwap = p;
        _selectedGroupForSwap = g;
      } else if (_selectedForSwap == p) {
        _selectedForSwap = null;
        _selectedGroupForSwap = null;
      } else {
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
        duration: AppAnimations.fast, curve: Curves.linear,
      );
    } else if (dy > height - threshold) {
      _scrollController.animateTo(
        (_scrollController.offset + scrollSpeed).clamp(0, _scrollController.position.maxScrollExtent),
        duration: AppAnimations.fast, curve: Curves.linear,
      );
    }
  }

  void _handlePlayerAction(String action, TeeGroupParticipant p, TeeGroup currentGroup) {
    switch (action) {
      case 'captain':
        setState(() { p.isCaptain = !p.isCaptain; _updateDirty(true); });
      case 'remove':
        setState(() { currentGroup.players.remove(p); _updateDirty(true); });
      case 'withdraw':
        _confirmWithdraw(p, currentGroup);
      case 'buggy':
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
      case 'move':
        _showMoveDialog(p, currentGroup);
    }
  }

  Future<void> _confirmWithdraw(TeeGroupParticipant p, TeeGroup group) async {
    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Withdraw Member?',
      message: 'This will remove ${p.name} from the groupings and set their status to "Withdrawn" in the registrations list.',
      confirmText: 'Withdraw',
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    );

    if (confirmed == true && mounted) {
      final event = ref.read(adminEventsProvider).value?.firstWhere((e) => e.id == widget.eventId);
      if (event == null) return;
      final reg = event.registrations.where((r) => r.memberId == p.registrationMemberId).firstOrNull;
      if (reg == null) return;

      final updatedReg = reg.copyWith(statusOverride: 'withdrawn', isConfirmed: false);
      final newList = List<EventRegistration>.from(event.registrations);
      final idx = newList.indexWhere((r) => r.memberId == updatedReg.memberId);
      if (idx >= 0) {
        newList[idx] = updatedReg;
        await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(registrations: newList));
        setState(() { group.players.remove(p); _updateDirty(true); });
      }
    }
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
    final strategy = strategyOverride ?? config.groupingStrategy;
    setState(() {
      _localGroups = GroupingService.generateInitialGrouping(
        event: event,
        participants: participants,
        previousEventsInSeason: allEvents,
        memberHandicaps: handicapMap,
        prioritizeBuggyPairing: prioritizeBuggyPairing,
        strategy: strategy,
        config: config,
        rules: rules,
        useWhs: config.useWhsHandicaps,
      );
    });
    _updateDirty(true);
  }

  void _recalculateAllPHCs(GolfEvent event, Map<String, double> handicapMap, CompetitionRules? rules, bool useWhs) {
    if (_localGroups == null) return;
    final allEvents = ref.read(adminEventsProvider).value?.where((e) => e.date.isBefore(event.date)).toList() ?? [];
    final config = ref.read(themeControllerProvider);

    setState(() {
      _localGroups = _localGroups!.map((group) {
        final updatedPlayers = group.players.map((player) {
          final rawHandicap = player.isGuest
              ? player.handicapIndex
              : (handicapMap[player.registrationMemberId] ?? player.handicapIndex);

          final automatedCut = (config.societyCutMode == SocietyCutMode.global)
              ? SocietyCutsEngine.calculateActiveCut(
                  memberId: player.registrationMemberId,
                  allEvents: allEvents,
                  config: config,
                  relativeTo: event.date,
                ).totalCut
              : 0.0;

          final newPhc = rules != null
              ? HandicapCalculator.calculatePlayingHandicap(
                  handicapIndex: rawHandicap,
                  rules: rules,
                  courseConfig: event.courseConfig,
                  useWhs: useWhs,
                  societyCut: (event.manualCuts[player.registrationMemberId] ?? 0.0) + automatedCut,
                ).toDouble()
              : rawHandicap;

          return TeeGroupParticipant(
            registrationMemberId: player.registrationMemberId,
            name: player.name,
            isGuest: player.isGuest,
            handicapIndex: rawHandicap,
            playingHandicap: newPhc,
            needsBuggy: player.needsBuggy,
            buggyStatus: player.buggyStatus,
            isCaptain: player.isCaptain,
            status: player.status,
          );
        }).toList();
        return TeeGroup(index: group.index, teeTime: group.teeTime, players: updatedPlayers);
      }).toList();

      _updateDirty(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All PHCs recalculated from latest member profiles.')),
      );
    });
  }

  void _showRegenerationOptions() => setState(() => _showGenerationOptions = true);

  void _showMoveDialog(TeeGroupParticipant p, TeeGroup currentGroup) {
    showBoxyArtDialog(
      context: context,
      title: 'Move ${p.name} to Group',
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BoxyArtSectionTitle(title: 'SELECT TARGET GROUP', isLevel2: true),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _localGroups!.length,
                itemBuilder: (context, index) {
                  final g = _localGroups![index];
                  if (g == currentGroup) return const SizedBox.shrink();
                  return BoxyArtCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    onTap: () { _handleMove(p, currentGroup, g, null); Navigator.pop(context); },
                    child: Row(
                      children: [
                        Icon(Icons.group_rounded, color: Theme.of(context).primaryColor, size: AppShapes.iconMd),
                        const SizedBox(width: AppSpacing.md),
                        Text('Group ${g.index + 1}', style: const TextStyle(fontWeight: AppTypography.weightBold)),
                        const Spacer(),
                        Text(
                          '${g.players.length} / 4',
                          style: TextStyle(
                            fontSize: AppTypography.sizeLabel,
                            color: g.players.length >= 4 ? AppColors.coral500 : AppColors.lime500,
                            fontWeight: AppTypography.weightExtraBold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
      final confirm = await showBoxyArtDialog<bool>(
        context: context,
        title: 'Registration Still Open',
        message: 'Registration for this event is still open. Publishing the grouping now might lead to confusion if more members join or withdraw. Proceed anyway?',
        confirmText: 'Publish Anyway',
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
        onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      );
      if (confirm != true) return;
    }
    try {
      final updatedEvent = event.copyWith(isGroupingPublished: !event.isGroupingPublished);
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(updatedEvent.isGroupingPublished ? 'Published!' : 'Unpublished')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _autoLinkMatches(GolfEvent event) {
    if (_localGroups == null || _localGroups!.isEmpty) return;
    setState(() {
      final newMatches = <MatchDefinition>[];
      for (final group in _localGroups!) {
        if (group.players.length < 2) continue;
        final p1 = group.players[0];
        final p2 = group.players[1];
        final p3 = group.players.length >= 3 ? group.players[2] : null;
        final p4 = group.players.length >= 4 ? group.players[3] : null;

        if (group.players.length == 2) {
          newMatches.add(MatchDefinition(
            id: 'match_${group.index}_1',
            team1Ids: [p1.registrationMemberId],
            team2Ids: [p2.registrationMemberId],
            type: MatchType.singles,
          ));
        } else if (p3 != null && p4 != null) {
          newMatches.add(MatchDefinition(
            id: 'match_${group.index}_1',
            team1Ids: [p1.registrationMemberId],
            team2Ids: [p3.registrationMemberId],
            type: MatchType.singles,
          ));
          newMatches.add(MatchDefinition(
            id: 'match_${group.index}_2',
            team1Ids: [p2.registrationMemberId],
            team2Ids: [p4.registrationMemberId],
            type: MatchType.singles,
          ));
        }
      }
      _localMatches = newMatches;
      _updateDirty(true);
    });
  }
}
