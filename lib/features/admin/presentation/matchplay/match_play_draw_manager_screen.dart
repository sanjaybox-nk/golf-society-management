import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../matchplay/domain/match_play_tournament.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/logic/match_play_entrant_service.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/models/golf_event.dart';
import '../../../../domain/models/competition.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/models/society_config.dart';
import '../../../../features/matchplay/data/match_play_repository.dart';
import '../../../../features/competitions/presentation/widgets/competition_shared_widgets.dart';
import '../../../matchplay/domain/match_play_reminder_service.dart';
import '../../../notifications/domain/notification_broadcast_service.dart';
import '../../../matchplay/presentation/tournament_wizard_provider.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart';
import 'match_play_draw_widgets.dart';
import 'match_play_setup_widgets.dart';

class MatchPlayDrawManagerScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final bool checkRoundProgression;

  const MatchPlayDrawManagerScreen({
    super.key, 
    this.eventId, 
    this.checkRoundProgression = false,
  });

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
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
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
              if (!context.mounted) return;
              BoxyArtDialog.show(
                context: context,
                title: 'Reminders Processed',
                message: 'A scan of the current tournament matches was performed. Any matches due in 5 days have been notified.',
                confirmText: 'DONE',
              );
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
              ModernFilterTab(label: 'Entries', value: 0, icon: Icons.people_rounded),
              ModernFilterTab(label: 'The Draw', value: 1, icon: Icons.account_tree_rounded),
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
          MatchPlayDeadlinesSection(state: state, notifier: notifier, config: config),

          const BoxyArtSectionTitle(
            title: 'Draw Entrants',
            followsCard: true, // Uses cardToLabel (16.0) gap
          ),
          ...state.entrants.map((e) {
            // Lookup member for handicap data
            final member = (ref.watch(allMembersProvider).value ?? [])
                .firstWhereOrNull((m) => m.id == e.playerIds.firstOrNull);
            
            return MatchPlayEntrantListItem(
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
              onTap: () => MatchPlayEntrantsStep.addManual(context, state, notifier, ref, widget.eventId ?? ''),
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

            return [
              BoxyArtSectionTitle(
                title: 'Match ${index + 1}',
                isPeeking: false, // Standardized tabToContent gap (16.0)
                followsCard: index > 0,
                trailing: index == 0
                    ? BoxyArtIndicator(
                        label: getRoundLabel(m.round).toUpperCase(),
                        dotColor: AppColors.dark400,
                      )
                    : null,
              ),
              MatchPlayDraftMatchItem(
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

      // [Design 4.x Progression] If we entered from a finalized event, we automatically
      // calculate the next round draft for the admin to review.
      if (widget.checkRoundProgression && existing != null && existing.matches.isNotEmpty) {
        notifier.propagateWinners(existing.matches);
        // Force the draw back to "Draft" state so the admin must explicitly Publish the next round.
        notifier.setPublished(false);
        // Switch to Draw tab automatically so admin sees the result
        setState(() => _selectedTab = 1);
      }
    });
  }


  Widget _buildFooter(WidgetRef ref, TournamentWizardState state, TournamentWizardNotifier notifier, ThemeData theme, BuildContext context) {
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
      await BoxyArtDialog.show<bool>(
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
      builder: (context) => MatchPlayManualResultSheet(
        match: match,
        onUpdate: (result) {
          notifier.updateMatchResult(match.id, result);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
