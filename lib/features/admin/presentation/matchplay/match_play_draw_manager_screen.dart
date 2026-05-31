import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../../matchplay/domain/match_play_tournament.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/match_play_calculator.dart';
import '../../../matchplay/logic/match_play_entrant_service.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../domain/grouping/grouping_service.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/models/golf_event.dart';
import '../../../../domain/models/competition.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/models/society_config.dart';
import '../../../../features/matchplay/data/match_play_repository.dart';
import 'package:uuid/uuid.dart';
import '../../../../features/competitions/presentation/widgets/competition_shared_widgets.dart';
import '../../../matchplay/domain/match_play_reminder_service.dart';
import '../../../matchplay/presentation/tournament_wizard_provider.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart';

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
  
  // Team assignment state — memberId → 'A' or 'B'
  Map<String, String> _teamAssignments = {};

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

      if (eventAsync.hasValue && compAsync.hasValue && compAsync.value != null && membersAsync.hasValue && tournamentAsync.hasValue) {
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
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      showBack: true,
      actions: [
        BoxyArtGlassIconButton(
          onPressed: () async {
            if (state.draftMatches.isNotEmpty) {
              final confirm = await BoxyArtDialog.show<bool>(
                context: context,
                title: 'Reshuffle Draw?',
                message: 'This will regenerate the entire bracket and any manual adjustments will be lost.',
                confirmText: 'RESHUFFLE',
                cancelText: 'CANCEL',
                isDangerous: true,
                onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
                onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
              );
              if (confirm == true) notifier.generateDraft();
            } else {
              notifier.generateDraft();
            }
          },
          icon: Icons.refresh_rounded,
          tooltip: 'Re-roll Draft',
          iconSize: AppShapes.iconMd,
        ),
        if (state.isPublished &&
            widget.eventId != null &&
            ref.watch(competitionDetailProvider(widget.eventId!)).value?.rules.subtype == CompetitionSubtype.matchPlaySeason)
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
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              final comp = widget.eventId != null
                  ? ref.watch(competitionDetailProvider(widget.eventId!)).value
                  : null;
              final isTeamMode = comp?.rules.mode == CompetitionMode.teams;
              return BoxyArtTabBar<int>(
                selectedValue: _selectedTab,
                onTabSelected: (val) => setState(() => _selectedTab = val),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                tabs: [
                  const ModernFilterTab(label: 'Entries', value: 0),
                  if (isTeamMode) const ModernFilterTab(label: 'Teams', value: 1),
                  ModernFilterTab(label: 'The Draw', value: isTeamMode ? 2 : 1),
                ],
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Content Area
        Builder(
          builder: (context) {
            final comp = widget.eventId != null
                ? ref.watch(competitionDetailProvider(widget.eventId!)).value
                : null;
            final isTeamMode = comp?.rules.mode == CompetitionMode.teams;
            if (_selectedTab == 0) {
              return _buildSetupTabSliver(state, notifier, theme, config);
            } else if (isTeamMode && _selectedTab == 1) {
              return _buildTeamsTabSliver(state, comp!);
            } else {
              return _buildDraftTabSliver(state, notifier, theme, config);
            }
          },
        ),

        // Footer shown on Teams and Draw tabs, but Publish only on The Draw tab
        if (_selectedTab != 0)
          Builder(
            builder: (context) {
              final comp = widget.eventId != null
                  ? ref.watch(competitionDetailProvider(widget.eventId!)).value
                  : null;
              final isTeamMode = comp?.rules.mode == CompetitionMode.teams;
              final isDrawTab = !(isTeamMode && _selectedTab == 1);
              return SliverToBoxAdapter(
                child: _buildFooter(ref, state, notifier, theme, context, showPublish: isDrawTab),
              );
            },
          ),
      ],
    );
  }

  /// Refactored Setup Tab Content as a Sliver
  Widget _buildSetupTabSliver(TournamentWizardState state, TournamentWizardNotifier notifier, ThemeData theme, SocietyConfig config) {
    Competition? comp;
    if (widget.eventId != null) {
      comp = ref.watch(competitionDetailProvider(widget.eventId!)).value;
      if (comp == null) return _buildNoCompetitionSliver();
    }

    final isSeasonTournament = comp?.rules.subtype == CompetitionSubtype.matchPlaySeason;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const BoxyArtSectionTitle(
            title: 'Current Game Setup',
            isPeeking: false,
          ),
          if (widget.eventId != null)
            CompetitionRulesCard(
              eventId: widget.eventId!,
              title: '',
              competition: comp!,
            ),

          if (isSeasonTournament) ...[
            const BoxyArtSectionTitle(
              title: 'Round Deadlines',
              followsCard: true,
            ),
            _DeadlinesSection(state: state, notifier: notifier, config: config),
          ],

          const BoxyArtSectionTitle(
            title: 'Draw Entrants',
            followsCard: true,
          ),
          ...state.entrants.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            final member = (ref.watch(allMembersProvider).value ?? [])
                .firstWhereOrNull((m) => m.id == e.playerIds.firstOrNull);

            return _EntrantListItem(
              index: index,
              entrant: e,
              member: member,
              handicapIndex: member?.handicap,
              onRemove: () => notifier.removeEntrant(e.id),
              theme: theme,
              config: config,
            );
          }),
          const SizedBox(height: AppSpacing.md),
          BoxyArtButton(
            title: 'Add Member',
            icon: Icons.add_circle_outline_rounded,
            isTinted: true,
            fullWidth: true,
            onTap: () => _EntrantsStep._addManual(context, state, notifier, ref, widget.eventId ?? ''),
          ),
          const SizedBox(height: AppSpacing.lg),
        ]),
      ),
    );
  }

  Widget _buildNoCompetitionSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: AppSpacing.hero),
          const BoxyArtEmptyCard(
            icon: Icons.sports_golf_rounded,
            title: 'No Game Format Attached',
            message: 'Go to Edit Event Details → Competition Rules and tap Add Game Format before generating the draw.',
          ),
          const SizedBox(height: AppSpacing.lg),
          BoxyArtButton(
            title: 'Go to Edit Event',
            icon: Icons.arrow_back_rounded,
            isSecondary: true,
            fullWidth: true,
            onTap: () {
              final event = ref.read(eventProvider(widget.eventId!)).value;
              if (event != null) {
                context.pushNamed(
                  'admin-event-edit',
                  pathParameters: {'id': event.id},
                  extra: event,
                );
              } else {
                context.pop();
              }
            },
          ),
          const SizedBox(height: AppSpacing.hero),
        ]),
      ),
    );
  }

  Widget _buildTeamsTabSliver(TournamentWizardState state, Competition comp) {
    final teamAName = comp.rules.teamAName ?? 'Team A';
    final teamBName = comp.rules.teamBName ?? 'Team B';
    final members = ref.watch(allMembersProvider).value ?? [];

    final teamACount = _teamAssignments.values.where((v) => v == 'A').length;
    final teamBCount = _teamAssignments.values.where((v) => v == 'B').length;
    final unassigned = state.entrants.length - teamACount - teamBCount;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          BoxyArtSectionTitle(
            title: 'Team Assignments',
            isPeeking: false,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BoxyArtIndicator(label: '$teamACount', dotColor: AppColors.teamA),
                const SizedBox(width: AppSpacing.sm),
                BoxyArtIndicator(label: '$teamBCount', dotColor: AppColors.teamB),
                if (unassigned > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  BoxyArtIndicator(label: '$unassigned unassigned', dotColor: AppColors.dark400),
                ],
              ],
            ),
          ),
          if (state.entrants.isEmpty)
            const BoxyArtEmptyCard(
              icon: Icons.group_outlined,
              title: 'No Entrants Yet',
              message: 'Add members on the Entries tab first, then assign them to teams here.',
            )
          else
            BoxyArtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: state.entrants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final entrant = entry.value;
                  final memberId = entrant.playerIds.firstOrNull;
                  final member = members.firstWhereOrNull((m) => m.id == memberId);
                  final assignment = memberId != null ? _teamAssignments[memberId] : null;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            BoxyArtAvatar(
                              url: member?.avatarUrl,
                              initials: member != null
                                  ? '${member.firstName.isNotEmpty ? member.firstName[0] : ''}${member.lastName.isNotEmpty ? member.lastName[0] : ''}'.toUpperCase()
                                  : entrant.name.substring(0, entrant.name.length.clamp(0, 2)).toUpperCase(),
                              radius: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                member?.displayName ?? entrant.name,
                                style: AppTypography.labelStrong,
                              ),
                            ),
                            _TeamChip(
                              label: teamAName,
                              isSelected: assignment == 'A',
                              color: AppColors.teamA,
                              onTap: () {
                                if (memberId == null) return;
                                setState(() {
                                  if (assignment == 'A') {
                                    _teamAssignments.remove(memberId);
                                  } else {
                                    _teamAssignments[memberId] = 'A';
                                  }
                                });
                                ref.read(tournamentWizardProvider.notifier)
                                    .setTeamAssignments(Map.from(_teamAssignments));
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _TeamChip(
                              label: teamBName,
                              isSelected: assignment == 'B',
                              color: AppColors.teamB,
                              onTap: () {
                                if (memberId == null) return;
                                setState(() {
                                  if (assignment == 'B') {
                                    _teamAssignments.remove(memberId);
                                  } else {
                                    _teamAssignments[memberId] = 'B';
                                  }
                                });
                                ref.read(tournamentWizardProvider.notifier)
                                    .setTeamAssignments(Map.from(_teamAssignments));
                              },
                            ),
                          ],
                        ),
                      ),
                      if (index < state.entrants.length - 1)
                        const BoxyArtDivider(verticalPadding: 0),
                    ],
                  );
                }).toList(),
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

    // Per-division match indices for group stage (reset numbering per division)
    final divisionMatchCounters = <String, int>{};

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ...matches.asMap().entries.expand((entry) {
            final index = entry.key;
            final m = entry.value;
            final isGroupStage = m.round == MatchRoundType.group;

            // Round header: show when round changes
            final showRoundHeader = index == 0 || matches[index - 1].round != m.round;

            // Division sub-header: show when groupId changes within group stage
            final showDivisionHeader = isGroupStage &&
                (index == 0 ||
                    matches[index - 1].groupId != m.groupId ||
                    matches[index - 1].round != m.round);

            // Match numbering — reset per division for group stage
            int matchNumber;
            if (isGroupStage && m.groupId != null) {
              divisionMatchCounters[m.groupId!] = (divisionMatchCounters[m.groupId!] ?? 0) + 1;
              matchNumber = divisionMatchCounters[m.groupId!]!;
            } else {
              matchNumber = index + 1;
            }

            return [
              if (showDivisionHeader)
                BoxyArtSectionTitle(
                  title: 'Division ${m.groupId}',
                  isPeeking: false,
                  followsCard: index > 0,
                  trailing: Text(
                    'GROUP STAGE',
                    style: AppTypography.micro.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: AppTypography.weightStrong,
                      letterSpacing: AppTypography.lsLabel,
                    ),
                  ),
                )
              else if (showRoundHeader)
                BoxyArtSectionTitle(
                  title: getRoundLabel(m.round).toUpperCase(),
                  isPeeking: false,
                  followsCard: index > 0,
                ),
              BoxyArtSectionTitle(
                title: isGroupStage ? 'Match $matchNumber' : 'Match ${index + 1}',
                isPeeking: false,
                followsCard: true,
                trailing: BoxyArtButton(
                  title: 'Manage',
                  isSmall: true,
                  isTinted: true,
                  onTap: () => _showManualResultSheet(m, notifier),
                ),
              ),
              _DraftMatchItem(
                match: m,
                isPublished: state.isPublished,
                eventId: widget.eventId,
                selectedMatchId: _swapSourceMatchId,
                selectedTeamIndex: _swapSourceTeamIndex,
                teamAssignments: _teamAssignments,
                onPlayerTap: (teamIndex) => _onPlayerTap(m.id, teamIndex, notifier),
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

    final rawAssignments = comp.publishSettings['teamAssignments'];
    if (rawAssignments is Map) {
      _teamAssignments = Map<String, String>.from(
        rawAssignments.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }

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
        teamAssignments: _teamAssignments,
        divisions: existing?.divisions ?? {},
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


  Widget _buildFooter(WidgetRef ref, TournamentWizardState state, TournamentWizardNotifier notifier, ThemeData theme, BuildContext context, {bool showPublish = true}) {
    if (state.entrants.isEmpty && state.draftMatches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.standard, 0, AppSpacing.standard, AppSpacing.x2l),
      child: BoxyArtCard(
        child: Row(
          children: [
            Expanded(
              child: BoxyArtButton(
                title: 'Save Draft',
                isSecondary: true,
                fullWidth: true,
                onTap: () => _finalize(ref, notifier, context, isPublish: false),
              ),
            ),
            if (showPublish) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BoxyArtButton(
                  title: state.isPublished ? 'Update' : 'Send to Field',
                  isPrimary: true,
                  fullWidth: true,
                  horizontalPadding: AppSpacing.md,
                  onTap: () => _finalize(ref, notifier, context, isPublish: true),
                ),
              ),
            ],
          ],
        ),
      ),
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

    if (widget.eventId != null && _teamAssignments.isNotEmpty) {
      final comp = ref.read(competitionDetailProvider(widget.eventId!)).value;
      if (comp != null && comp.rules.mode == CompetitionMode.teams) {
        final updatedComp = comp.copyWith(
          publishSettings: {
            ...comp.publishSettings,
            'teamAssignments': Map<String, dynamic>.from(_teamAssignments),
          },
        );
        await ref.read(competitionsRepositoryProvider).updateCompetition(updatedComp);
      }
    }

    // Sync with GolfEvent if applicable
    if (widget.eventId != null) {
      final eventRepo = ref.read(eventsRepositoryProvider);
      final event = await eventRepo.getEvent(widget.eventId!);
      if (event != null) {
        final updatedGrouping = Map<String, dynamic>.from(event.grouping);
        updatedGrouping['matches'] = tournament.matches.map((m) => m.toJson()).toList();
        updatedGrouping['isPublished'] = isPublish;
        updatedGrouping['roundCutoffs'] = tournament.roundCutoffs.map((k, v) => MapEntry(k.name, v.toIso8601String()));

        // On publish, auto-generate tee groups from the draw so the field sheet
        // populates immediately — no separate "Generate from Draw" step needed.
        if (isPublish) {
          final allEvents = ref.read(adminEventsProvider).value ?? [];
          final members = ref.read(allMembersProvider).value ?? [];
          final handicapMap = {for (var m in members) m.id: m.handicap};
          final comp = ref.read(competitionDetailProvider(widget.eventId!)).value;
          final config = ref.read(themeControllerProvider);
          final participants = RegistrationLogic.getPlayingParticipants(event);

          if (participants.isNotEmpty) {
            final groups = GroupingService.generateMatchPlayGrouping(
              event: event,
              matches: tournament.matches,
              participants: participants,
              previousEventsInSeason: allEvents,
              memberHandicaps: handicapMap,
              config: config,
              rules: comp?.rules,
              useWhs: config.useWhsHandicaps,
            );
            updatedGrouping['groups'] = groups.map((g) => g.toJson()).toList();
          }
        }

        await eventRepo.updateEvent(event.copyWith(grouping: updatedGrouping));
      }
    }

    if (context.mounted) {
      await BoxyArtDialog.show<bool>(
        context: context,
        title: isPublish ? 'Draw Sent to Field' : 'Draft Saved',
        message: isPublish
            ? 'The draw has been sent to the tee sheet. Use the visibility toggle in Manage to control member access.'
            : 'Your draft has been saved successfully.',
        confirmText: 'CONTINUE',
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      );
    }
  }

  void _showManualResultSheet(MatchDefinition match, TournamentWizardNotifier notifier) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Admin Override',
      child: _ManualResultSheet(
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
  final Map<String, String> teamAssignments;
  final Function(int) onPlayerTap;

  const _DraftMatchItem({
    required this.match,
    required this.isPublished,
    this.eventId,
    this.selectedMatchId,
    this.selectedTeamIndex,
    this.teamAssignments = const {},
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final members = ref.watch(allMembersProvider).value ?? [];
    
    final p1 = match.team1Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team1Ids.first) : null;
    final p2 = match.team2Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team2Ids.first) : null;

    // Calculate live result if published
    if (isPublished && eventId != null) {
      final scorecards = ref.watch(scorecardsListProvider(eventId!)).value ?? [];
      final event = ref.watch(eventProvider(eventId!)).value;
      if (event != null) {
        MatchPlayCalculator.calculate(
          match: match,
          scorecards: scorecards,
          courseConfig: event.courseConfig,
          holesToPlay: event.courseConfig.holes.length,
        );
      }
    }

    final p1TeamId = match.team1Ids.isNotEmpty ? match.team1Ids.first : null;
    final p2TeamId = match.team2Ids.isNotEmpty ? match.team2Ids.first : null;
    final p1Team = p1TeamId != null ? teamAssignments[p1TeamId] : null;
    final p2Team = p2TeamId != null ? teamAssignments[p2TeamId] : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatchupPlayerCard(
            member: p1,
            teamLabel: p1Team,
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
            teamLabel: p2Team,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _OverrideOption(
          title: '${match.team1Name ?? "Side A"} wins — Walkover',
          subtitle: 'Opponent concedes or fails to appear',
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
          title: '${match.team2Name ?? "Side B"} wins — Walkover',
          subtitle: 'Opponent concedes or fails to appear',
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
        if (match.manualResult != null) ...[
          const SizedBox(height: AppSpacing.xl),
          BoxyArtButton(
            title: 'CLEAR OVERRIDE',
            isGhost: true,
            fullWidth: true,
            onTap: () => onUpdate(null),
          ),
        ],
      ],
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
    final theme = Theme.of(context);
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          BoxyArtIconBadge(icon: icon, isTinted: true),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelStrong.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: AppTypography.weightBold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.micro.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _MatchupPlayerCard extends StatelessWidget {
  final Member? member;
  final String? teamLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _MatchupPlayerCard({
    this.member,
    this.teamLabel,
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
    final int phc = member!.handicap.clamp(0.0, 28.0).toInt();

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
          secondaryName: teamLabel != null ? 'Team $teamLabel' : null,
          secondaryNameColor: teamLabel == 'A' ? AppColors.teamA : (teamLabel == 'B' ? AppColors.teamB : null),
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
  }
}


class _EntrantListItem extends StatelessWidget {
  final int index;
  final MatchPlayEntrant entrant;
  final Member? member;
  final double? handicapIndex;
  final VoidCallback onRemove;
  final ThemeData theme;
  final SocietyConfig config;

  const _EntrantListItem({
    required this.index,
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
    final int? phc = handicapIndex?.clamp(0.0, 28.0).toInt();

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
          rankingBadge: BoxyArtNumberBadge(
            number: index + 1,
            size: 20,
            isRanking: false,
            color: AppColors.dark500,
            textColor: AppColors.dark150,
          ),
          useCard: true,

          showChevron: false,
          showVerticalDivider: true,
          accentColor: null,
          trailing: null,
        ),
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TeamChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.micro.copyWith(
            color: isSelected ? AppColors.pureWhite : color,
            fontWeight: AppTypography.weightBold,
            letterSpacing: 0.5,
          ),
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

