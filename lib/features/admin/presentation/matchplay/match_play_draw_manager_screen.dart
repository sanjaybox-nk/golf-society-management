import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../../../utils/string_utils.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart';
import '../../../matchplay/presentation/tournament_wizard_provider.dart';
import '../../../matchplay/domain/match_play_tournament.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/match_play_calculator.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart' as mp_state;
import '../../../matchplay/logic/match_play_entrant_service.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/models/golf_event.dart';
import '../../../../domain/models/competition.dart';
import '../../../../domain/models/member.dart';
import '../../../../features/matchplay/data/match_play_repository.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/models/society_config.dart';
import '../../../../domain/models/event_registration.dart';
import '../../../../features/competitions/presentation/widgets/competition_shared_widgets.dart';
import '../../../matchplay/domain/match_play_reminder_service.dart';
import '../../../notifications/domain/notification_broadcast_service.dart';

class MatchPlayDrawManagerScreen extends ConsumerStatefulWidget {
  final String? eventId;

  const MatchPlayDrawManagerScreen({super.key, this.eventId});

  @override
  ConsumerState<MatchPlayDrawManagerScreen> createState() => _MatchPlayDrawManagerScreenState();
}

class _MatchPlayDrawManagerScreenState extends ConsumerState<MatchPlayDrawManagerScreen> {
  bool _initialized = false;
  String? _lastSyncedEventId;
  String? _lastSyncedTournamentJson; // Tracks data-level changes for re-sync
  int _selectedTab = 0; 
  bool _readyToLoad = false;
  
  // Swap Selection State
  String? _swapSourceMatchId;
  int? _swapSourceTeamIndex;

  @override
  void initState() {
    super.initState();
    if (widget.eventId == null) {
      _initialized = true;
    }
    // Defer all Firestore subscriptions until after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _readyToLoad = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Frame 1: Return a lightweight placeholder.
    if (widget.eventId != null && !_readyToLoad) {
      return const _LoadingShell();
    }

    final state = ref.watch(tournamentWizardProvider);
    final notifier = ref.read(tournamentWizardProvider.notifier);
    final config = ref.watch(themeControllerProvider);

    // [Design 4.x Standard] Reactive Initialization & Update Reconciliation.
    // We strictly wait for ALL core providers to resolve. Because this screen is persistent (stable keys),
    // we use _lastSyncedTournamentJson to detect if the source data in Firestore has changed while the 
    // screen was in the background, ensuring saved dates and entrants flow back in.
    if (widget.eventId != null) {
      final eventAsync = ref.watch(eventProvider(widget.eventId!));
      final compAsync = ref.watch(competitionDetailProvider(widget.eventId!));
      final membersAsync = ref.watch(allMembersProvider);
      final tournamentAsync = ref.watch(matchPlayTournamentProvider(widget.eventId!));

      if (eventAsync.hasValue && compAsync.hasValue && membersAsync.hasValue && tournamentAsync.hasValue) {
        final tournament = tournamentAsync.value;
        final tournamentJson = tournament?.toJson().toString();

        if (!_initialized || _lastSyncedEventId != widget.eventId || _lastSyncedTournamentJson != tournamentJson) {
           final members = membersAsync.value!;
           if (members.isNotEmpty) {
             _syncFromEvent(eventAsync.value!, compAsync.value!, members, notifier, tournament);
             _initialized = true;
             _lastSyncedEventId = widget.eventId;
             _lastSyncedTournamentJson = tournamentJson;
           }
        }
      }
    }

    return HeadlessScaffold(
      title: 'Match Play Hub',
      subtitle: state.name.isNotEmpty ? state.name : 'Tournament Manager',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      actions: [
        BoxyArtGlassIconButton(
          onPressed: notifier.generateDraft,
          icon: Icons.refresh_rounded,
          tooltip: 'Re-roll Draft',
          iconSize: AppShapes.iconMd,
        ),
        if (state.isPublished)
          BoxyArtGlassIconButton(
            onPressed: () async {
              await ref.read(matchPlayReminderServiceProvider).syncReminders(tournamentId: widget.eventId);
              if (mounted) {
                BoxyArtDialog.show(
                  context: context,
                  title: 'Reminders Processed',
                  message: 'A scan of the current tournament matches was performed. Any matches due in 5 days have been notified.',
                  confirmText: 'DONE',
                );
              }
            },
            icon: Icons.notifications_active_rounded,
            tooltip: 'Send 5-Day Reminders',
            iconSize: AppShapes.iconMd,
          ),
      ],
      slivers: [
        // Tab Switcher - Using ModernUnderlinedFilterBar for Standard Identity
        SliverToBoxAdapter(
          child: ModernUnderlinedFilterBar<int>(
            selectedValue: _selectedTab,
            isExpanded: true,
            onTabSelected: (val) => setState(() => _selectedTab = val),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            tabs: const [
              ModernFilterTab(label: 'Entries', value: 0),
              ModernFilterTab(label: 'The Draw', value: 1),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Content Area 
        if (_selectedTab == 0)
          _buildSetupTabSliver(state, notifier, theme, config)
        else
          _buildDraftTabSliver(state, notifier, theme, config),

        // Process Footer
        SliverToBoxAdapter(
          child: _buildFooter(ref, state, notifier, theme, context),
        ),
      ],
    );
  }

  /// Refactored Setup Tab Content as a Sliver
  Widget _buildSetupTabSliver(TournamentWizardState state, TournamentWizardNotifier notifier, ThemeData theme, SocietyConfig config) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const BoxyArtSectionTitle(
            title: 'Current Game Setup',
            isPeeking: false, // Standardized 16pt gap from tabs
          ),
          if (widget.eventId != null)
            CompetitionRulesCard(
              eventId: widget.eventId!,
              title: '', // Removed double label; handled by peeking title above
              competition: ref.watch(competitionDetailProvider(widget.eventId!)).value!,
            ),
          
          const BoxyArtSectionTitle(
             title: 'Round Deadlines',
             followsCard: true, // Uses cardToLabel (16.0) gap
          ),
          _DeadlinesSection(state: state, notifier: notifier, config: config),

          const BoxyArtSectionTitle(
            title: 'Draw Entrants',
            followsCard: true, // Uses cardToLabel (16.0) gap
          ),
          ...state.entrants.map((e) {
            // Lookup member for handicap data
            final member = (ref.watch(allMembersProvider).value ?? [])
                .firstWhereOrNull((m) => m.id == e.playerIds.firstOrNull);
            
            return _EntrantListItem(
              entrant: e, 
              member: member,
              handicapIndex: member?.handicap,
              onRemove: () => notifier.removeEntrant(e.id),
              theme: theme,
              config: config,
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: BoxyArtButton(
              title: 'Add Member',
              icon: Icons.add_circle_outline_rounded,
              isSmall: true,
              isPrimary: false,
              isSecondary: true, // Ghost style consistent with 4.x
              onTap: () => _EntrantsStep._addManual(context, state, notifier, ref, widget.eventId ?? ''),
            ),
          ),
          const SizedBox(height: AppSpacing.hero),
        ]),
      ),
    );
  }

  /// Refactored Draft Tab Content as a Sliver
  Widget _buildDraftTabSliver(TournamentWizardState state, TournamentWizardNotifier notifier, ThemeData theme, SocietyConfig config) {
    if (state.draftMatches.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.hero,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.hero,
          ),
          child: BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.hero),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'No Draft Yet',
                  style: AppTypography.headline.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Complete the setup and generate a draft bracket to preview matchups.',
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                BoxyArtButton(
                  title: 'GENERATE DRAW',
                  onTap: notifier.generateDraft,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final matches = state.draftMatches.where((m) => m.team1Ids.isNotEmpty || m.team2Ids.isNotEmpty).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ...matches.asMap().entries.expand((entry) {
            final index = entry.key;
            final m = entry.value;
            final isLast = index == matches.length - 1;

            return [
              BoxyArtSectionTitle(
                title: 'Match ${index + 1}',
                isPeeking: false, // Standardized tabToContent gap (16.0)
                followsCard: index > 0,
                trailing: index == 0
                    ? BoxyArtIndicator(
                        label: toTitleCase(getRoundLabel(m.round)),
                        dotColor: AppColors.dark400,
                      )
                    : null,
              ),
              _DraftMatchItem(
                match: m,
                isPublished: state.isPublished,
                eventId: widget.eventId,
                selectedMatchId: _swapSourceMatchId,
                selectedTeamIndex: _swapSourceTeamIndex,
                onPlayerTap: (teamIndex) => _onPlayerTap(m.id, teamIndex, notifier),
                onManageResult: () => _showManualResultSheet(m, notifier),
              ),
            ];
          }),
          const SizedBox(height: AppSpacing.md),
        ]),
      ),
    );
  }

  void _syncFromEvent(GolfEvent event, Competition comp, List<Member> members, TournamentWizardNotifier notifier, MatchPlayTournament? existing) {
    _initialized = true;
    _lastSyncedEventId = widget.eventId;

    final isPairs = comp.rules.mode == CompetitionMode.pairs;
    final type = comp.rules.tournamentFormat == TournamentFormat.divisions
        ? TournamentType.divisionsPlusKnockout
        : TournamentType.knockout;
    final seeding = comp.rules.seedingLogic == SeedingLogic.seeded
        ? SeedingType.seeded
        : SeedingType.random;
    final progressionMode = comp.rules.progressionMode;

    final membersMap = <String, Member>{};
    for (var m in members) {
      membersMap[m.id] = m;
    }

    // [Hardened Source of Truth Hierarchy]
    // 1. If we have an existing tournament document, use its entrants and deadlines.
    // 2. Fall back to event registrations only for brand-new draws.
    final finalEntrants = (existing != null && existing.entrants.isNotEmpty)
        ? existing.entrants
        : MatchPlayEntrantService.mapRegistrationsToEntrants(
            event: event,
            isPairs: isPairs,
            membersMap: membersMap,
          );

    final finalDeadlines = existing?.roundCutoffs ?? {};

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.initializeFromEvent(
        name: existing?.name ?? event.title,
        isPairs: isPairs,
        type: existing?.type ?? type,
        seedingType: existing?.seedingType ?? seeding,
        progressionMode: progressionMode,
        entrants: finalEntrants,
        matches: existing?.matches ?? [],
        roundCutoffs: finalDeadlines,
        notes: existing?.notes,
        isPublished: existing?.isPublished ?? false,
      );
    });
  }


  Widget _buildFooter(WidgetRef ref, TournamentWizardState state, TournamentWizardNotifier notifier, ThemeData theme, BuildContext context, {bool hasEvent = false}) {
    // [Design 4.x Standard] Persistent Footer Action.
    // The footer is now always visible once a tournament context is established, 
    // ensuring "Save Draft" and "Publish" are accessible from both the Entries and Draw tabs.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.large),
      child: (state.entrants.isNotEmpty || state.draftMatches.isNotEmpty) 
          ? Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: BoxyArtButton(
                    title: 'Save Draft',
                    isSecondary: true,
                    onTap: () => _finalize(ref, notifier, context, isPublish: false),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BoxyArtButton(
                    title: state.isPublished ? 'Update Draw' : 'Publish',
                    isPrimary: true,
                    onTap: () => _finalize(ref, notifier, context, isPublish: true),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  void _onPlayerTap(String matchId, int teamIndex, TournamentWizardNotifier notifier) {
    if (_swapSourceMatchId == null) {
      setState(() {
        _swapSourceMatchId = matchId;
        _swapSourceTeamIndex = teamIndex;
      });
      HapticFeedback.lightImpact();
    } else {
      if (_swapSourceMatchId == matchId && _swapSourceTeamIndex == teamIndex) {
        // Cancel if tapping same slot
        setState(() {
          _swapSourceMatchId = null;
          _swapSourceTeamIndex = null;
        });
      } else {
        // EXECUTE SWAP
        notifier.swapDraftEntrants(
          matchId1: _swapSourceMatchId!,
          teamIndex1: _swapSourceTeamIndex!,
          matchId2: matchId,
          teamIndex2: teamIndex,
        );
        setState(() {
          _swapSourceMatchId = null;
          _swapSourceTeamIndex = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opponents swapped locally. Remember to Save/Publish.'),
            backgroundColor: AppColors.teamA,
          ),
        );
      }
    }
  }

  void _finalize(WidgetRef ref, TournamentWizardNotifier notifier, BuildContext context, {bool isPublish = false}) async {
    if (isPublish) {
      notifier.setPublished(true);
    }
    
    final tournament = notifier.finalize(tournamentId: widget.eventId); 
    await ref.read(matchPlayRepositoryProvider).saveTournament(tournament);

    // Sync with GolfEvent if applicable
    if (widget.eventId != null) {
      final eventRepo = ref.read(eventsRepositoryProvider);
      final event = await eventRepo.getEvent(widget.eventId!);
      if (event != null) {
        final updatedGrouping = Map<String, dynamic>.from(event.grouping);
        updatedGrouping['matches'] = tournament.matches.map((m) => m.toJson()).toList();
        updatedGrouping['isPublished'] = isPublish;
        updatedGrouping['roundCutoffs'] = tournament.roundCutoffs.map((k, v) => MapEntry(k.name, v.toIso8601String()));
        
        await eventRepo.updateEvent(event.copyWith(grouping: updatedGrouping));
      }
    }

    if (isPublish) {
      await ref.read(renewalNudgeServiceProvider).notifyMatchPlayPublished(tournament: tournament);
    }
    
    if (context.mounted) {
      final confirmed = await BoxyArtDialog.show<bool>(
        context: context,
        title: isPublish ? (ref.read(tournamentWizardProvider).isPublished ? 'Draw Updated!' : 'Tournament Published!') : 'Draft Saved',
        message: isPublish 
            ? 'The bracket is now live and synchronized. Members have been notified.' 
            : 'Your draft has been saved successfully.',
        confirmText: 'CONTINUE',
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      );
    }
  }

  void _showManualResultSheet(MatchDefinition match, TournamentWizardNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ManualResultSheet(
        match: match,
        onUpdate: (result) {
          notifier.updateMatchResult(match.id, result);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _DeadlinesSection extends StatelessWidget {
  final TournamentWizardState state;
  final TournamentWizardNotifier notifier;
  final SocietyConfig config;

  const _DeadlinesSection({required this.state, required this.notifier, required this.config});

  @override
  Widget build(BuildContext context) {
    final rounds = _getRequiredRounds(state.entrants.length, state.type);
    
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      // [Design 4.x Control] Border state is managed globally via SocietyConfig inside BoxyArtCard
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROUND DEADLINES',
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant, 
              fontSize: AppTypography.sizeMicro,
              fontWeight: AppTypography.weightStrong,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...rounds.mapIndexed((index, round) => Column(
            children: [
              _RoundDeadlinePicker(
                round: round,
                currentDate: state.roundCutoffs[round],
                onChanged: (date) => notifier.setRoundCutoff(round, date),
              ),
              if (index < rounds.length - 1) 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.05), height: 1),
                ),
            ],
          )),
        ],
      ),
    );
  }

  List<MatchRoundType> _getRequiredRounds(int entrantCount, TournamentType type) {
    if (type == TournamentType.divisionsPlusKnockout) {
       return [MatchRoundType.group, MatchRoundType.roundOf16, MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
    }
    
    if (entrantCount <= 2) return [MatchRoundType.finalRound];
    if (entrantCount <= 4) return [MatchRoundType.semiFinal, MatchRoundType.finalRound];
    if (entrantCount <= 8) return [MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
    if (entrantCount <= 16) return [MatchRoundType.roundOf16, MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
    return [MatchRoundType.roundOf32, MatchRoundType.roundOf16, MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
  }
}


class _DraftMatchItem extends ConsumerWidget {
  final MatchDefinition match;
  final bool isPublished;
  final String? eventId;
  final String? selectedMatchId;
  final int? selectedTeamIndex;
  final Function(int) onPlayerTap;
  final VoidCallback onManageResult;

  const _DraftMatchItem({
    required this.match,
    required this.isPublished,
    this.eventId,
    this.selectedMatchId,
    this.selectedTeamIndex,
    required this.onPlayerTap,
    required this.onManageResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final members = ref.watch(allMembersProvider).value ?? [];
    
    final p1 = match.team1Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team1Ids.first) : null;
    final p2 = match.team2Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team2Ids.first) : null;

    // Calculate live result if published
    MatchResult? liveResult;
    if (isPublished && eventId != null) {
      final scorecards = ref.watch(scorecardsListProvider(eventId!)).value ?? [];
      final event = ref.watch(eventProvider(eventId!)).value;
      if (event != null) {
        liveResult = MatchPlayCalculator.calculate(
          match: match,
          scorecards: scorecards,
          courseConfig: event.courseConfig,
          holesToPlay: event.courseConfig.holes.length,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPublished && liveResult != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BoxyArtPill.status(
                    label: liveResult.status,
                    color: match.manualResult != null ? AppColors.amber500 : AppColors.dark400,
                    hasHorizontalMargin: false,
                  ),
                  BoxyArtButton(
                    title: 'MANAGE',
                    isSmall: true,
                    isSecondary: true,
                    onTap: onManageResult,
                  ),
                ],
              ),
            ),
          _MatchupPlayerCard(
            member: p1,
            isSelected: selectedMatchId == match.id && selectedTeamIndex == 1,
            onTap: () => onPlayerTap(1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Center(
              child: Text(
                'Vs',
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightHeavy,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          _MatchupPlayerCard(
            member: p2,
            isSelected: selectedMatchId == match.id && selectedTeamIndex == 2,
            onTap: () => onPlayerTap(2),
          ),
        ],
      ),
    );
  }
}

class _ManualResultSheet extends StatelessWidget {
  final MatchDefinition match;
  final Function(MatchResult?) onUpdate;

  const _ManualResultSheet({required this.match, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.dark700,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dark400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'ADMIN OVERRIDE',
            style: AppTypography.label.copyWith(
              color: AppColors.amber500,
              fontWeight: AppTypography.weightBlack,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Manual Result Entry',
            style: AppTypography.headline.copyWith(color: AppColors.pureWhite),
          ),
          const SizedBox(height: AppSpacing.hero),
          
          _OverrideOption(
            title: 'Award Side A Walkover',
            subtitle: 'Advances ${match.team1Name ?? "Side A"}',
            icon: Icons.emoji_events_outlined,
            onTap: () => onUpdate(MatchResult(
              matchId: match.id,
              winningTeamIndex: 0,
              status: 'WALKOVER',
              score: 18,
              holeResults: [],
              holesPlayed: 0,
              isFinal: true,
            )),
          ),
          const SizedBox(height: AppSpacing.md),
          _OverrideOption(
            title: 'Award Side B Walkover',
            subtitle: 'Advances ${match.team2Name ?? "Side B"}',
            icon: Icons.emoji_events_outlined,
            onTap: () => onUpdate(MatchResult(
              matchId: match.id,
              winningTeamIndex: 1,
              status: 'WALKOVER',
              score: 18,
              holeResults: [],
              holesPlayed: 0,
              isFinal: true,
            )),
          ),
          const SizedBox(height: AppSpacing.md),
          _OverrideOption(
            title: 'Enter Custom Result...',
            subtitle: 'Set a specific score (e.g. 3&2)',
            icon: Icons.edit_note_rounded,
            onTap: () => _showScoreDialog(context),
          ),
          
          if (match.manualResult != null) ...[
            const SizedBox(height: AppSpacing.hero),
            BoxyArtButton(
              title: 'CLEAR OVERRIDE',
              isPrimary: false,
              isSecondary: true,
              onTap: () => onUpdate(null),
              fullWidth: true,
            ),
          ],
          const SizedBox(height: AppSpacing.hero),
        ],
      ),
    );
  }

  void _showScoreDialog(BuildContext context) {
    final controller = TextEditingController();
    int winner = 1; // 1 or 2

    BoxyArtDialog.show(
      context: context,
      title: 'Custom Result',
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BoxyArtInputField(
              controller: controller,
              label: 'Result Text',
              hint: 'e.g. 2 & 1',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: BoxyArtButton(
                    title: 'Side A Wins',
                    isSmall: true,
                    isPrimary: winner == 1,
                    isSecondary: winner != 1,
                    onTap: () => setState(() => winner = 1),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: BoxyArtButton(
                    title: 'Side B Wins',
                    isSmall: true,
                    isPrimary: winner == 2,
                    isSecondary: winner != 2,
                    onTap: () => setState(() => winner = 2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      confirmText: 'SET RESULT',
      onConfirm: () {
        onUpdate(MatchResult(
          matchId: match.id,
          winningTeamIndex: winner - 1,
          status: controller.text.toUpperCase(),
          score: 1, // Placeholder
          holeResults: [],
          holesPlayed: 0,
          isFinal: true,
        ));
      },
    );
  }
}

class _OverrideOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _OverrideOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.dark400.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.pureWhite, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelStrong.copyWith(color: AppColors.pureWhite)),
                Text(subtitle, style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.dark400),
        ],
      ),
    );
  }
}

class _MatchupPlayerCard extends StatelessWidget {
  final Member? member;
  final bool isSelected;
  final VoidCallback onTap;

  const _MatchupPlayerCard({
    this.member,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return const BoxyArtMemberRow(
        name: 'BYE',
        initials: '?',
        useCard: true,
        showChevron: false,
        showVerticalDivider: false,
      );
    }

    // [Design 4.x Standard] 28-Cap PHC logic for Match Play
    final int? phc = member!.handicap?.clamp(0.0, 28.0).toInt();

    final String initials = '${member!.firstName.isNotEmpty ? member!.firstName[0] : ''}${member!.lastName.isNotEmpty ? member!.lastName[0] : ''}'.toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
             BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
             )
          ] : null,
        ),
        child: BoxyArtMemberRow(
          name: member!.displayName,
          initials: initials,
          avatarUrl: member!.avatarUrl,
          handicapIndex: member!.handicap,
          playingHandicap: phc,
          useCard: true,
          showChevron: false,
          showVerticalDivider: false,
        ),
      ),
    );
  }
}

class _RoundDeadlinePicker extends StatelessWidget {
  final MatchRoundType round;
  final DateTime? currentDate;
  final Function(DateTime) onChanged;

  const _RoundDeadlinePicker({
    required this.round,
    this.currentDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = currentDate != null 
        ? DateFormat('d MMM yyyy').format(currentDate!) 
        : 'Set Deadline';

    return Row(
        children: [
          Expanded(
            child: Text(
              getRoundLabel(round),
              style: AppTypography.labelStrong.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
            ),
          ),
          BoxyArtButton(
            title: displayDate.toUpperCase(),
            icon: Icons.calendar_today_rounded,
            isSmall: true,
            isPrimary: false,
            isSecondary: true, // Ghost style
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: currentDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) onChanged(picked);
            },
          ),
        ],
      );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

String getRoundLabel(MatchRoundType round) {
  switch (round) {
    case MatchRoundType.group: return 'Group Stage';
    case MatchRoundType.roundOf32: return 'Round of 32';
    case MatchRoundType.roundOf16: return 'Round of 16';
    case MatchRoundType.quarterFinal: return 'Quarter-Finals';
    case MatchRoundType.semiFinal: return 'Semi-Finals';
    case MatchRoundType.finalRound: return 'The Final';
    default: return 'Round';
  }
}

class _EntrantsHeader extends StatelessWidget {
  final int count;
  final VoidCallback onAddManual;
  final ThemeData theme;
  final SocietyConfig config;

  const _EntrantsHeader({
    required this.count,
    required this.onAddManual,
    required this.theme,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENTRANTS', style: AppTypography.labelStrong.copyWith(color: AppColors.textSecondary, fontSize: AppTypography.sizeMicro)),
            Text('$count players/pairs registered', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        BoxyArtButton(
          title: 'Add Manual',
          icon: Icons.add_circle_outline_rounded,
          isPrimary: false,
          isSecondary: true,
          isSmall: true,
          onTap: onAddManual,
        ),
      ],
    );
  }
}

class _EntrantListItem extends StatelessWidget {
  final MatchPlayEntrant entrant;
  final Member? member;
  final double? handicapIndex;
  final VoidCallback onRemove;
  final ThemeData theme;
  final SocietyConfig config;

  const _EntrantListItem({
    required this.entrant,
    this.member,
    this.handicapIndex,
    required this.onRemove,
    required this.theme,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    // [Design 4.x Standard] 28-Cap PHC logic for Match Play
    final int? phc = handicapIndex != null 
        ? handicapIndex!.clamp(0.0, 28.0).toInt() 
        : null;

    final String initials = member != null 
        ? '${member!.firstName.isNotEmpty ? member!.firstName[0] : ''}${member!.lastName.isNotEmpty ? member!.lastName[0] : ''}'.toUpperCase()
        : (entrant.name.length >= 2 ? entrant.name.substring(0, 2).toUpperCase() : entrant.name.toUpperCase());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(entrant.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.coral500.withValues(alpha: AppColors.opacityHigh),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.x2l),
          child: const Icon(Icons.delete_outline, color: AppColors.pureWhite, size: AppShapes.iconLg),
        ),
        confirmDismiss: (direction) async {
          return await showBoxyArtDialog<bool>(
            context: context,
            title: 'Remove Entrant?',
            message: 'Remove ${entrant.name} from the tournament draw?',
            confirmText: 'Remove',
            isDangerous: true,
          );
        },
        onDismissed: (_) => onRemove(),
        child: BoxyArtMemberRow(
          name: entrant.name,
          initials: initials,
          avatarUrl: member?.avatarUrl,
          handicapIndex: handicapIndex,
          playingHandicap: phc,
          useCard: true,
          showChevron: false,
          showVerticalDivider: true, 
          accentColor: null,
          trailing: null, // Action moved to slide gesture
        ),
      ),
    );
  }
}

class _EntrantsStep {
  static void _addManual(BuildContext context, TournamentWizardState state, TournamentWizardNotifier notifier, WidgetRef ref, String eventId) async {
    final members = ref.read(allMembersProvider).value ?? [];
    Member? selected;

    await showBoxyArtDialog(
      context: context,
      title: 'Add Manual Entrant',
      content: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Manually add a player who is not in the registration list.'),
            const SizedBox(height: AppSpacing.xl),
            DropdownButtonFormField<Member>(
              items: members.map((m) => DropdownMenuItem(value: m, child: Text(m.displayName))).toList(),
              onChanged: (m) => setDialogState(() => selected = m),
              decoration: const InputDecoration(labelText: 'Select Member'),
            ),
          ],
        ),
      ),
      confirmText: 'Add',
      onConfirm: () {
        if (selected != null) {
          notifier.addEntrant(MatchPlayEntrant(
            id: const Uuid().v4(),
            name: selected!.displayName,
            playerIds: [selected!.id],
          ));
        }
      },
    );
  }
}

