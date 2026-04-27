import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_play_calculator.dart';
import '../../domain/match_progression_logic.dart';
import '../../domain/golf_event_match_extensions.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/models/scorecard.dart';
import '../../../../domain/models/golf_event.dart';
import 'matches_bracket_widget.dart';

class MatchPlayActiveRoundNotifier extends Notifier<MatchRoundType> {
  @override MatchRoundType build() => MatchRoundType.roundOf16;
  void set(MatchRoundType round) => state = round;
}
final matchPlayActiveRoundProvider = NotifierProvider<MatchPlayActiveRoundNotifier, MatchRoundType>(MatchPlayActiveRoundNotifier.new);

class MatchPlayViewModeNotifier extends Notifier<MatchPlayViewMode> {
  @override MatchPlayViewMode build() => MatchPlayViewMode.list;
  void toggle() => state = state == MatchPlayViewMode.list ? MatchPlayViewMode.tree : MatchPlayViewMode.list;
  void set(MatchPlayViewMode mode) => state = mode;
}
final matchPlayViewModeProvider = NotifierProvider<MatchPlayViewModeNotifier, MatchPlayViewMode>(MatchPlayViewModeNotifier.new);

enum MatchPlayViewMode { list, tree }

class MatchPlayBracketHub extends ConsumerWidget {
  final String eventId;

  const MatchPlayBracketHub({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
    final activeRound = ref.watch(matchPlayActiveRoundProvider);
    final viewMode = ref.watch(matchPlayViewModeProvider);
    final theme = Theme.of(context);

    return eventAsync.when(
      data: (event) {
        final matches = event.matches;
        if (matches.isEmpty) {
          return const Center(child: BoxyArtEmptyCard(
            title: 'No Matches',
            message: 'No matches have been generated for this tournament yet.',
            icon: Icons.account_tree_outlined,
          ));
        }

        return scorecardsAsync.when(
          data: (scorecards) {
            final isAdmin = ref.watch(currentUserProvider).role == MemberRole.admin || 
                           ref.watch(currentUserProvider).role == MemberRole.superAdmin;

            // Get available rounds for carousel
            final availableRounds = matches.map((m) => m.round).toSet().toList()
              ..sort((a, b) => a.index.compareTo(b.index));

            return Stack(
              children: [
                Column(
                  children: [
                    // 1. View Mode Toggler
                    _buildViewToggle(ref, viewMode, theme),

                    // 2. Round Carousel
                    if (viewMode == MatchPlayViewMode.list)
                      _RoundCarousel(
                        rounds: availableRounds,
                        activeRound: activeRound,
                        onChanged: (r) => ref.read(matchPlayActiveRoundProvider.notifier).set(r),
                      ),

                    // 3. Main Content
                    Expanded(
                      child: viewMode == MatchPlayViewMode.list
                          ? _MatchupListView(
                              round: activeRound,
                              matches: matches.where((m) => m.round == activeRound).toList(),
                              scorecards: scorecards,
                              event: event,
                            )
                          : MatchesBracketWidget(eventId: eventId), // The Tree view
                    ),
                  ],
                ),
                if (isAdmin)
                  _AdminBracketControls(
                    ref: ref,
                    event: event,
                    scorecards: scorecards,
                    matches: matches,
                  ),
              ],
            );
          },
          loading: () => const BoxyArtLoadingCard(useCard: false),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const BoxyArtLoadingCard(useCard: false),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildViewToggle(WidgetRef ref, MatchPlayViewMode current, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppShapes.rPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleItem(
              label: 'LIST VIEW',
              active: current == MatchPlayViewMode.list,
              onTap: () => ref.read(matchPlayViewModeProvider.notifier).set(MatchPlayViewMode.list),
            ),
            _ToggleItem(
              label: 'TREE VIEW',
              active: current == MatchPlayViewMode.tree,
              onTap: () => ref.read(matchPlayViewModeProvider.notifier).set(MatchPlayViewMode.tree),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleItem({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppShapes.rPill),
          boxShadow: active ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: AppTypography.micro.copyWith(
            color: active ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _RoundCarousel extends StatelessWidget {
  final List<MatchRoundType> rounds;
  final MatchRoundType activeRound;
  final Function(MatchRoundType) onChanged;

  const _RoundCarousel({
    required this.rounds,
    required this.activeRound,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: rounds.length,
        itemBuilder: (context, index) {
          final r = rounds[index];
          final isActive = r == activeRound;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(_getRoundLabel(r)),
              selected: isActive,
              onSelected: (val) => onChanged(r),
              labelStyle: AppTypography.micro.copyWith(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
              ),
              backgroundColor: Colors.transparent,
              selectedColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.rPill)),
              side: BorderSide(
                color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  String _getRoundLabel(MatchRoundType round) {
    switch (round) {
      case MatchRoundType.group: return 'Groups';
      case MatchRoundType.roundOf32: return 'R32';
      case MatchRoundType.roundOf16: return 'R16';
      case MatchRoundType.quarterFinal: return 'Quarter-Finals';
      case MatchRoundType.semiFinal: return 'Semi-Finals';
      case MatchRoundType.finalRound: return 'The Final';
    }
  }
}

class _MatchupListView extends StatelessWidget {
  final MatchRoundType round;
  final List<MatchDefinition> matches;
  final List<Scorecard> scorecards;
  final dynamic event;

  const _MatchupListView({
    required this.round,
    required this.matches,
    required this.scorecards,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(child: BoxyArtEmptyCard(
        title: 'Empty Round',
        message: 'No matches scheduled for this round yet.',
        icon: Icons.hourglass_empty_rounded,
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final m = matches[index];
        final result = MatchPlayCalculator.calculate(
          match: m,
          scorecards: scorecards,
          courseConfig: event.courseConfig,
          holesToPlay: event.courseConfig.holes.length,
        );
        return _MatchupCard(match: m, result: result);
      },
    );
  }
}

class _MatchupCard extends ConsumerWidget {
  final MatchDefinition match;
  final MatchResult result;

  const _MatchupCard({required this.match, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final members = ref.watch(allMembersProvider).value ?? [];
    
    final p1 = match.team1Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team1Ids.first) : null;
    final p2 = match.team2Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team2Ids.first) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildPlayerRow(p1?.displayName ?? 'BYE', match.team1Ids, result.winningTeamIndex == 0, theme),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('vs', style: AppTypography.micro, textAlign: TextAlign.center),
            ),
            _buildPlayerRow(p2?.displayName ?? 'BYE', match.team2Ids, result.winningTeamIndex == 1, theme),
            const SizedBox(height: AppSpacing.md),
            BoxyArtPill.status(
              label: result.status,
              color: _getStatusColor(result.status).withValues(alpha: 0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(String name, List<String> ids, bool isWinner, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTypography.labelStrong.copyWith(
              color: isWinner ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (isWinner) Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'A/S') return AppColors.amber500;
    if (status.contains('UP') || status.contains('&')) return AppColors.teamA;
    return AppColors.textSecondary;
  }
}

class _AdminBracketControls extends StatelessWidget {
  final WidgetRef ref;
  final GolfEvent event;
  final List<Scorecard> scorecards;
  final List<MatchDefinition> matches;

  const _AdminBracketControls({
    required this.ref,
    required this.event,
    required this.scorecards,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final hasGroupMatches = matches.any((m) => m.round == MatchRoundType.group);
    
    return Positioned(
      bottom: AppSpacing.xl,
      right: AppSpacing.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'promote_winners',
            onPressed: () => _promoteWinners(context),
            label: const Text('PROMOTE WINNERS'),
            icon: const Icon(Icons.arrow_forward),
            backgroundColor: AppColors.actionMidnight,
          ),
          if (hasGroupMatches) ...[
            const SizedBox(height: AppSpacing.md),
            FloatingActionButton.extended(
              heroTag: 'qualify_groups',
              onPressed: () => _qualifyFromGroups(context),
              label: const Text('QUALIFY FROM GROUPS'),
              icon: const Icon(Icons.star),
              backgroundColor: AppColors.actionMidnight,
            ),
          ],
        ],
      ),
    );
  }

  void _promoteWinners(BuildContext context) async {
    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Promote Winners?',
      message: 'This will progress winners to the next round based on validated scores.',
      confirmText: 'PROMOTE',
    );

    if (confirmed == true) {
      final updatedMatches = MatchProgressionLogic.promoteWinners(
        allMatches: event.matches,
        scorecards: scorecards,
        courseConfig: event.courseConfig,
      );

      final updatedEvent = event.copyWith(
        grouping: {
          ...event.grouping,
          'matches': updatedMatches.map((m) => m.toJson()).toList(),
        },
      );

      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
      
      if (context.mounted) {
        BoxyArtDialog.show(
          context: context, 
          title: 'Winners Promoted!', 
          message: 'The bracket has been advanced.',
          confirmText: 'CONTINUE',
          onConfirm: () => Navigator.pop(context),
        );
      }
    }
  }

  void _qualifyFromGroups(BuildContext context) async {
     final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Qualify from Groups?',
      message: 'This will select the top qualifiers and seeding them into the knockout bracket.',
      confirmText: 'QUALIFY',
    );

    if (confirmed == true) {
      // Determine target round (e.g. Round of 16 or Quarters)
      final targetRound = event.matches.firstWhereOrNull((m) => m.round != MatchRoundType.group)?.round ?? MatchRoundType.quarterFinal;

      final updatedMatches = MatchProgressionLogic.promoteFromGroups(
        allMatches: event.matches,
        scorecards: scorecards,
        courseConfig: event.courseConfig,
        targetRound: targetRound,
        qualifiersPerGroup: 2, 
      );

      final updatedEvent = event.copyWith(
        grouping: {
          ...event.grouping,
          'matches': updatedMatches.map((m) => m.toJson()).toList(),
        },
      );

      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
      
       if (context.mounted) {
        BoxyArtDialog.show(
          context: context, 
          title: 'Qualifiers Fixed!', 
          message: 'Group stage completed. Knockout phase is now live.',
          confirmText: 'CONTINUE',
          onConfirm: () => Navigator.pop(context),
        );
      }
    }
  }
}
