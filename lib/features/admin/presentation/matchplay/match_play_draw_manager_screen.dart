import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../matchplay/presentation/tournament_wizard_provider.dart';
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
import 'package:uuid/uuid.dart';

class MatchPlayDrawManagerScreen extends ConsumerWidget {
  final String? eventId;

  const MatchPlayDrawManagerScreen({super.key, this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentWizardProvider);
    final notifier = ref.read(tournamentWizardProvider.notifier);

    final eventAsync = eventId != null ? ref.watch(eventProvider(eventId!)) : null;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return HeadlessScaffold(
      title: eventId != null ? 'Match Play Draw Manager' : 'New Match Play Draw',
      subtitle: eventAsync?.value?.title,
      showBack: true,
      slivers: [
        if (eventId == null)
          SliverToBoxAdapter(
            child: _buildProgressHeader(state.step),
          ),
        
        SliverFillRemaining(
          hasScrollBody: false,
          child: eventId != null 
            ? _ManagerContent(eventId: eventId!, state: state, notifier: notifier)
            : _buildCurrentStep(state, notifier),
        ),
      ],
      pinnedBottom: _buildFooter(state, notifier, context, hasEvent: eventId != null),
      pinnedBottomPadding: 0,
    );
  }

  Widget _buildProgressHeader(int step) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          _StepIndicator(index: 0, current: step, label: 'Setup'),
          _Connector(active: step > 0),
          _StepIndicator(index: 1, current: step, label: 'Entrants'),
          _Connector(active: step > 1),
          _StepIndicator(index: 2, current: step, label: 'Review'),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(TournamentWizardState state, TournamentWizardNotifier notifier) {
    switch (state.step) {
      case 0: return _SetupStep(state: state, notifier: notifier);
      case 1: return _EntrantsStep(state: state, notifier: notifier);
      case 2: return _ReviewStep(state: state, notifier: notifier);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildFooter(TournamentWizardState state, TournamentWizardNotifier notifier, BuildContext context, {bool hasEvent = false}) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.large),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (!hasEvent && state.step > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: BoxyArtButton(
                  title: 'BACK',
                  isPrimary: false,
                  isSecondary: true,
                  onTap: notifier.prevStep,
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: BoxyArtButton(
              title: (hasEvent || state.step == 2) ? 'GENERATE & SAVE DRAW' : 'CONTINUE',
              onTap: (hasEvent || state.step == 2) ? () => _finalize(notifier, context) : notifier.nextStep,
            ),
          ),
        ],
      ),
    );
  }

  void _finalize(TournamentWizardNotifier notifier, BuildContext context) {
    final tournament = notifier.finalize();
    // Logic to save tournament to repository
    Navigator.pop(context, tournament);
  }
}

class _ManagerContent extends ConsumerStatefulWidget {
  final String eventId;
  final TournamentWizardState state;
  final TournamentWizardNotifier notifier;

  const _ManagerContent({
    required this.eventId,
    required this.state,
    required this.notifier,
  });

  @override
  ConsumerState<_ManagerContent> createState() => _ManagerContentState();
}

class _ManagerContentState extends ConsumerState<_ManagerContent> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));
    final membersAsync = ref.watch(allMembersProvider);

    return eventAsync.when(
      data: (event) => compAsync.when(
        data: (comp) {
          if (comp == null) return const Center(child: Text('No competition rules found for this event.'));

          if (!_initialized) {
            _syncFromEvent(event, comp, membersAsync.value ?? []);
          }

          return Column(
            children: [
              _buildConfigSummary(comp.rules),
              const BoxyArtDivider(),
              Expanded(
                child: _EntrantsStep(state: widget.state, notifier: widget.notifier),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading competition: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading event: $e')),
    );
  }

  void _syncFromEvent(GolfEvent event, Competition comp, List<Member> members) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notifier.setName(event.title);
      widget.notifier.setMode(comp.rules.mode == CompetitionMode.pairs);
      
      // Map domain format to UI tournament type
      final type = comp.rules.tournamentFormat == TournamentFormat.divisions 
          ? TournamentType.divisionsPlusKnockout 
          : TournamentType.knockout;
      widget.notifier.setType(type);
      
      // Map domain seeding to UI seeding type
      final seeding = comp.rules.seedingLogic == SeedingLogic.seeded 
          ? SeedingType.seeded 
          : SeedingType.random;
      widget.notifier.setSeeding(seeding);

      final membersMap = {for (var m in members) m.id: m}.cast<String, Member>();
      final entrants = MatchPlayEntrantService.mapRegistrationsToEntrants(
        event: event,
        isPairs: comp.rules.mode == CompetitionMode.pairs,
        membersMap: membersMap,
      );
      
      widget.notifier.addEntrants(entrants);
      setState(() => _initialized = true);
    });
  }

  Widget _buildConfigSummary(CompetitionRules rules) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BoxyArtPill.status(
                label: rules.tournamentFormat.name.toUpperCase(),
                color: AppColors.lime500,
              ),
              const SizedBox(width: AppSpacing.sm),
              BoxyArtPill.status(
                label: rules.mode.name.toUpperCase(),
                color: AppColors.teamA,
              ),
              const SizedBox(width: AppSpacing.sm),
              BoxyArtPill.status(
                label: rules.seedingLogic.name.toUpperCase(),
                color: AppColors.amber500,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Entrants are automatically pulled from confirmed registrations. Adjust below if needed.',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  final TournamentWizardState state;
  final TournamentWizardNotifier notifier;

  const _SetupStep({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxyArtTextField(
            label: 'COMPETITION NAME',
            hintText: 'e.g. Summer Singles Knockout 2026',
            onChanged: notifier.setName,
          ),
          const SizedBox(height: AppSpacing.x2l),
          const _SectionLabel('TOURNAMENT FORMAT'),
          _TypeSelector(
            current: state.type,
            onChanged: notifier.setType,
          ),
          const SizedBox(height: AppSpacing.x2l),
          const _SectionLabel('COMPETITION MODE'),
          _ModeSelector(
            current: state.isPairs,
            onChanged: notifier.setMode,
          ),
          const SizedBox(height: AppSpacing.x2l),
          const _SectionLabel('SEEDING LOGIC'),
          _SeedingSelector(
            current: state.seedingType,
            onChanged: notifier.setSeeding,
          ),
        ],
      ),
    );
  }
}

class _EntrantsStep extends ConsumerWidget {
  final TournamentWizardState state;
  final TournamentWizardNotifier notifier;

  const _EntrantsStep({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.entrants.length} ENTRANTS', 
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightBold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                   IconButton(
                    onPressed: () => _showImportMenu(context, ref, state, notifier),
                    icon: const Icon(Icons.download, color: AppColors.lime500),
                    tooltip: 'Import Entrants',
                  ),
                  IconButton(
                    onPressed: () => _addManual(context, state, notifier),
                    icon: const Icon(Icons.person_add_alt_1, color: AppColors.lime500),
                    tooltip: 'Add Manually',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.entrants.length,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemBuilder: (context, index) {
              final entrant = state.entrants[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: AppShapes.lg,
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                  boxShadow: theme.extension<AppShadows>()?.softScale ?? [],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                  title: Text(
                    entrant.name, 
                    style: AppTypography.body.copyWith(
                      fontWeight: AppTypography.weightBold, 
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    entrant.playerIds.length == 1 ? 'SINGLES' : 'PAIRS',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10, 
                      letterSpacing: 1.0, 
                      color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary), 
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entrant.playerIds.length > 2)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.warning_amber_rounded, color: AppColors.amber500, size: 20),
                        ),
                      IconButton(
                        onPressed: () => notifier.removeEntrant(entrant.id),
                        icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error.withValues(alpha: 0.7), size: 20),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showImportMenu(BuildContext context, WidgetRef ref, TournamentWizardState state, TournamentWizardNotifier notifier) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.lime500),
            title: const Text('From Event Registrations'),
            onTap: () {
              Navigator.pop(context);
              _importFromEvent(context, ref, state, notifier, isLeaderboard: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard, color: AppColors.lime500),
            title: const Text('From Event Leaderboard'),
            onTap: () {
              Navigator.pop(context);
              _importFromEvent(context, ref, state, notifier, isLeaderboard: true);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _importFromEvent(BuildContext context, WidgetRef ref, TournamentWizardState state, TournamentWizardNotifier notifier, {required bool isLeaderboard}) async {
    // 1. Show Event Picker
    final events = await ref.read(eventsRepositoryProvider).getEvents();
    // Filter to past events for leaderboard, or upcoming for registrations
    final filtered = isLeaderboard 
      ? events.where((e) => e.status == EventStatus.completed).toList()
      : events.where((e) => e.status == EventStatus.published || e.status == EventStatus.inPlay).toList();

    if (context.mounted) {
      final selectedEvent = await showDialog<GolfEvent>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(isLeaderboard ? 'Select Qualifying Event' : 'Select Sign-up Event'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(filtered[i].title),
                subtitle: Text(filtered[i].courseName ?? 'No course set'),
                onTap: () => Navigator.pop(context, filtered[i]),
              ),
            ),
          ),
        ),
      );

      if (selectedEvent != null) {
        final membersMap = ref.read(allMembersProvider).value?.asMap().map((_, m) => MapEntry(m.id, m)) ?? {};
        
        List<MatchPlayEntrant> imported;
        if (isLeaderboard) {
          imported = MatchPlayEntrantService.mapLeaderboardToEntrants(
            results: selectedEvent.results.cast<Map<String, dynamic>>(),
            limit: 16, // Default to top 16
            membersMap: membersMap,
          );
        } else {
          imported = MatchPlayEntrantService.mapRegistrationsToEntrants(
            event: selectedEvent,
            isPairs: state.isPairs,
            membersMap: membersMap,
          );
        }
        
        notifier.addEntrants(imported);
      }
    }
  }

  void _addManual(BuildContext context, TournamentWizardState state, TournamentWizardNotifier notifier) {
     // Show a quick dialog or move to sub-page
     notifier.addEntrant(MatchPlayEntrant(
       id: const Uuid().v4(),
       playerIds: ['p1'], // Placeholder
       name: 'Player ${state.entrants.length + 1}',
     ));
  }
}

class _ReviewStep extends StatelessWidget {
  final TournamentWizardState state;
  final TournamentWizardNotifier notifier;

  const _ReviewStep({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: AppColors.lime500),
          const SizedBox(height: AppSpacing.xl),
          Text(
            state.name.isEmpty ? 'Untitled Competition' : state.name, 
            style: AppTypography.displaySubPage.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${state.type.name.toUpperCase()} • ${state.seedingType.name.toUpperCase()}',
            style: AppTypography.caption.copyWith(
              fontWeight: AppTypography.weightBold,
              letterSpacing: 1.0,
              color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: AppShapes.pill,
            ),
            child: Text(
              '${state.entrants.length} Entrants registered',
              style: AppTypography.label.copyWith(
                fontWeight: AppTypography.weightBold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label, 
        style: AppTypography.caption.copyWith(
          fontWeight: AppTypography.weightBold,
          color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final TournamentType current;
  final Function(TournamentType) onChanged;

  const _TypeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SelectableChip(label: 'Knockout', selected: current == TournamentType.knockout, onSelect: () => onChanged(TournamentType.knockout)),
        const SizedBox(width: AppSpacing.md),
        _SelectableChip(label: 'Divisions', selected: current == TournamentType.divisionsPlusKnockout, onSelect: () => onChanged(TournamentType.divisionsPlusKnockout)),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final bool current;
  final Function(bool) onChanged;

  const _ModeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SelectableChip(label: 'Singles', selected: !current, onSelect: () => onChanged(false)),
        const SizedBox(width: AppSpacing.md),
        _SelectableChip(label: 'Pairs', selected: current, onSelect: () => onChanged(true)),
      ],
    );
  }
}

class _SeedingSelector extends StatelessWidget {
  final SeedingType current;
  final Function(SeedingType) onChanged;

  const _SeedingSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SelectableChip(label: 'Random', selected: current == SeedingType.random, onSelect: () => onChanged(SeedingType.random)),
        const SizedBox(width: AppSpacing.md),
        _SelectableChip(label: 'Seeded', selected: current == SeedingType.seeded, onSelect: () => onChanged(SeedingType.seeded)),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelect;

  const _SelectableChip({required this.label, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected 
            ? AppColors.lime500 
            : (isDark ? AppColors.dark800 : theme.colorScheme.surfaceContainer),
          borderRadius: AppShapes.pill,
          border: selected 
            ? null 
            : Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          boxShadow: selected ? theme.extension<AppShadows>()?.softScale : null,
        ),
        child: Text(
          label, 
          style: AppTypography.label.copyWith(
            color: selected 
              ? AppColors.actionText 
              : theme.colorScheme.onSurface,
            fontWeight: selected ? AppTypography.weightBold : AppTypography.weightMedium,
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int index;
  final int current;
  final String label;

  const _StepIndicator({required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = index <= current;
    
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active ? AppColors.lime500 : theme.cardColor,
          child: Text(
            '${index + 1}', 
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: AppTypography.weightBold,
              color: active ? AppColors.actionText : theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: AppTypography.caption.copyWith(
            fontSize: 10, 
            fontWeight: active ? AppTypography.weightBold : AppTypography.weightMedium,
            color: active ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool active;
  const _Connector({required this.active});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 2,
        color: active ? AppColors.lime500 : theme.dividerColor.withValues(alpha: 0.1),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
