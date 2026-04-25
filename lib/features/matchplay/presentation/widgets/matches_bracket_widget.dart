import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_play_calculator.dart';
import '../../domain/match_progression_logic.dart';
import '../../domain/golf_event_match_extensions.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'match_play_standings_view.dart';

class BracketStageNotifier extends Notifier<String> {
  @override
  String build() => 'knockout';
  set stage(String val) => state = val;
}
final _bracketStageProvider = NotifierProvider<BracketStageNotifier, String>(BracketStageNotifier.new);

class MatchesBracketWidget extends ConsumerWidget {
  final String eventId;

  const MatchesBracketWidget({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventAsync.when(
      data: (event) {
        final matches = event.matches;
        final tournamentType = event.grouping['tournamentType'] as String? ?? 'knockout';
        final isDivisionsMode = tournamentType == 'divisionsPlusKnockout';

        if (matches.isEmpty && !isDivisionsMode) {
          return const Center(child: Text('No matches found for bracket view.'));
        }

        return scorecardsAsync.when(
          data: (scorecards) {
            final isAdmin = ref.watch(currentUserProvider).role == MemberRole.admin || ref.watch(currentUserProvider).role == MemberRole.superAdmin;
            final currentStage = ref.watch(_bracketStageProvider);
            
            Widget body;
            if (isDivisionsMode && currentStage == 'divisions') {
               // Group matches by division (stored in MatchDefinition.groupId or similar)
               final Map<String, List<MatchDefinition>> divisionMatches = {};
               for (var m in matches.where((m) => m.round == MatchRoundType.group)) {
                 final divId = m.groupId ?? 'A';
                 divisionMatches.putIfAbsent(divId, () => []).add(m);
               }
               
               body = ListView(
                 padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                 children: divisionMatches.keys.map((divId) => MatchPlayStandingsView(
                   divisionName: divId,
                   matches: divisionMatches[divId]!,
                   scorecards: scorecards,
                   event: event,
                 )).toList(),
               );
            } else {
              // Group matches by round for bracket
              final Map<MatchRoundType, List<MatchDefinition>> rounds = {};
              for (var m in matches.where((m) => m.round != MatchRoundType.group)) {
                rounds.putIfAbsent(m.round, () => []).add(m);
              }
              final sortedRounds = rounds.keys.toList()..sort((a, b) => a.index.compareTo(b.index));

              body = InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.1,
                maxScale: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x3l),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedRounds.map((roundType) {
                      final roundMatches = rounds[roundType]!;
                      roundMatches.sort((a, b) => (a.bracketOrder ?? 0).compareTo(b.bracketOrder ?? 0));
                      
                      return _RoundColumn(
                        roundName: _getRoundName(roundType),
                        matches: roundMatches,
                        scorecards: scorecards,
                        event: event,
                      );
                    }).toList(),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                Column(
                  children: [
                    if (isDivisionsMode) _buildStageSelector(ref),
                    Expanded(child: body),
                  ],
                ),
                if (isAdmin) _buildAdminControls(ref, event, scorecards, matches),
              ],
            );
          },
          loading: () => const BoxyArtLoadingCard(useCard: false),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const BoxyArtLoadingCard(useCard: false),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  String _getRoundName(MatchRoundType type) {
    switch (type) {
      case MatchRoundType.group: return 'Groups';
      case MatchRoundType.roundOf32: return 'Round of 32';
      case MatchRoundType.roundOf16: return 'Round of 16';
      case MatchRoundType.quarterFinal: return 'Quarter-Finals';
      case MatchRoundType.semiFinal: return 'Semi-Finals';
      case MatchRoundType.finalRound: return 'Final';
    }
  }

  Widget _buildStageSelector(WidgetRef ref) {
    final current = ref.watch(_bracketStageProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StageTab(
            label: 'DIVISIONS', 
            active: current == 'divisions', 
            onTap: () => ref.read(_bracketStageProvider.notifier).stage = 'divisions'
          ),
          const SizedBox(width: AppSpacing.lg),
          _StageTab(
            label: 'BRACKET', 
            active: current == 'knockout', 
            onTap: () => ref.read(_bracketStageProvider.notifier).stage = 'knockout'
          ),
        ],
      ),
    );
  }

  Widget _buildAdminControls(WidgetRef ref, GolfEvent event, List<Scorecard> scorecards, List<MatchDefinition> matches) {
    final hasGroupMatches = matches.any((m) => m.round == MatchRoundType.group);
    return Positioned(
      top: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'promote_winners',
            onPressed: () => _promoteWinners(ref, event, scorecards),
            label: const Text('Promote Winners'),
            icon: const Icon(Icons.arrow_forward),
            backgroundColor: AppColors.amber500,
          ),
          if (hasGroupMatches) ...[
            const SizedBox(height: AppSpacing.md),
            FloatingActionButton.extended(
              heroTag: 'qualify_groups',
              onPressed: () => _qualifyFromGroups(ref, event, scorecards),
              label: const Text('Qualify from Groups'),
              icon: const Icon(Icons.star),
              backgroundColor: AppColors.actionMidnight,
            ),
          ],
        ],
      ),
    );
  }
}

class _StageTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _StageTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: active ? AppColors.lime500 : AppColors.dark800,
          borderRadius: BorderRadius.circular(AppShapes.rSm),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _RoundColumn extends StatelessWidget {
  final String roundName;
  final List<MatchDefinition> matches;
  final List<Scorecard> scorecards;
  final dynamic event;

  const _RoundColumn({
    required this.roundName,
    required this.matches,
    required this.scorecards,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppShapes.borderMedium,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
            child: Text(
              roundName.toUpperCase(),
              style: const TextStyle(
                fontWeight: AppTypography.weightBlack,
                fontSize: AppTypography.sizeLabel,
                letterSpacing: 1.0,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...matches.map((m) {
            final result = MatchPlayCalculator.calculate(
              match: m,
              scorecards: scorecards,
              courseConfig: event.courseConfig,
              holesToPlay: event.courseConfig.holes.length,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
              child: _BracketMatchTile(match: m, result: result),
            );
          }),
        ],
      ),
    );
  }
}

class _BracketMatchTile extends ConsumerWidget {
  final MatchDefinition match;
  final MatchResult result;

  const _BracketMatchTile({required this.match, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark900.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppShapes.rMd),
        border: Border.all(color: AppColors.pureWhite.withValues(alpha: 0.08)),
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildPlayerRow(
            context: context,
            ref: ref,
            name: match.team1Name ?? (match.team1Ids.isEmpty ? 'BYE' : 'Side A'), 
            playerIds: match.team1Ids,
            isWinner: result.winningTeamIndex == 0,
            strokesMap: match.strokesReceived,
            matchSide: 'A',
          ),
          Divider(height: 1, color: AppColors.pureWhite.withValues(alpha: 0.08)),
          _buildPlayerRow(
            context: context,
            ref: ref,
            name: match.team2Name ?? (match.team2Ids.isEmpty ? 'BYE' : 'Side B'), 
            playerIds: match.team2Ids,
            isWinner: result.winningTeamIndex == 1,
            strokesMap: match.strokesReceived,
            matchSide: 'B',
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: _getStatusColor(result.status).withValues(alpha: AppColors.opacityLow),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppShapes.rSm)),
            ),
            child: Center(
              child: Text(
                result.status,
                style: TextStyle(
                  color: _getStatusColor(result.status),
                  fontSize: AppTypography.sizeCaption,
                  fontWeight: AppTypography.weightBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow({
    required BuildContext context,
    required WidgetRef ref,
    required String name, 
    required List<String> playerIds,
    required bool isWinner,
    required Map<String, int> strokesMap,
    required String matchSide,
  }) {
    final members = ref.watch(allMembersProvider).value ?? [];
    final firstPlayerId = playerIds.isNotEmpty ? playerIds.first : null;
    final member = firstPlayerId != null ? members.firstWhereOrNull((m) => m.id == firstPlayerId) : null;

    // Get the highest stroke count for this team/player to show as summary badge
    int maxStrokes = 0;
    for (var id in playerIds) {
      final s = strokesMap[id] ?? 0;
      if (s > maxStrokes) maxStrokes = s;
    }

    String? secondary;
    if (playerIds.length > 1) {
       final p2Id = playerIds[1];
       final p2 = members.firstWhereOrNull((m) => m.id == p2Id);
       secondary = p2?.displayName ?? 'Partner';
    }

    return BoxyArtMemberRow(
      name: name,
      secondaryName: secondary,
      initials: (name.isNotEmpty ? name[0] : '?').toUpperCase(),
      avatarUrl: member?.avatarUrl,
      handicapIndex: member?.handicap,
      playingHandicap: maxStrokes > 0 ? maxStrokes : null,
      isWinner: isWinner,
      matchSide: matchSide,
      useCard: false,
      showChevron: false,
      showVerticalDivider: true,
      accentColor: isWinner ? AppColors.lime500 : (matchSide == 'A' ? AppColors.teamA : (matchSide == 'B' ? AppColors.teamB : null)),
      varietyPillarColor: isWinner ? AppColors.lime500 : (matchSide == 'A' ? AppColors.teamA : (matchSide == 'B' ? AppColors.teamB : null)),
    );
  }
}

class _StrokeBadge extends StatelessWidget {
  final int count;
  const _StrokeBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.pureWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppShapes.rSm),
        border: Border.all(color: AppColors.pureWhite.withValues(alpha: 0.1)),
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          color: AppColors.lime500,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
  Color _getStatusColor(String status) {
    if (status == 'A/S') return AppColors.amber500;
    if (status.contains('UP') || status.contains('&')) return AppColors.teamA;
    return AppColors.textSecondary;
  }

void _promoteWinners(WidgetRef ref, GolfEvent event, List<Scorecard> scorecards) async {
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
}

void _qualifyFromGroups(WidgetRef ref, GolfEvent event, List<Scorecard> scorecards) async {
  // Determine target round (e.g. Quarter Final)
  // Logic: First knockout round with matches
  final targetRound = event.matches.firstWhereOrNull((m) => m.round != MatchRoundType.group)?.round ?? MatchRoundType.quarterFinal;

  final updatedMatches = MatchProgressionLogic.promoteFromGroups(
    allMatches: event.matches,
    scorecards: scorecards,
    courseConfig: event.courseConfig,
    targetRound: targetRound,
    qualifiersPerGroup: 2, // Default to top 2
  );

  final updatedEvent = event.copyWith(
    grouping: {
      ...event.grouping,
      'matches': updatedMatches.map((m) => m.toJson()).toList(),
    },
  );

  await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
}
