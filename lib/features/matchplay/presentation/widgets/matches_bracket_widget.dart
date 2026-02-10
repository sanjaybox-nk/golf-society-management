
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_play_calculator.dart';
import '../../domain/match_progression_logic.dart';
import '../../domain/golf_event_match_extensions.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../models/member.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/scorecard.dart';

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
        if (matches.isEmpty) {
          return const Center(child: Text('No matches found for bracket view.'));
        }

        // Group matches by round
        final Map<MatchRoundType, List<MatchDefinition>> rounds = {};
        for (var m in matches) {
          rounds.putIfAbsent(m.round, () => []).add(m);
        }

        // Sort rounds chronologically (simplified for now)
        final sortedRounds = rounds.keys.toList()
          ..sort((a, b) => a.index.compareTo(b.index));

        return scorecardsAsync.when(
          data: (scorecards) {
            final isAdmin = ref.watch(currentUserProvider).role == MemberRole.admin || ref.watch(currentUserProvider).role == MemberRole.superAdmin;
            final hasGroupMatches = event.matches.any((m) => m.round == MatchRoundType.group);

            return Stack(
              children: [
                InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.1,
                  maxScale: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
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
                ),
                if (isAdmin)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton.extended(
                          heroTag: 'promote_winners',
                          onPressed: () => _promoteWinners(ref, event, scorecards),
                          label: const Text('Promote Winners'),
                          icon: const Icon(Icons.arrow_forward),
                          backgroundColor: Colors.amber,
                        ),
                        if (hasGroupMatches) ...[
                          const SizedBox(height: 12),
                          FloatingActionButton.extended(
                            heroTag: 'qualify_groups',
                            onPressed: () => _qualifyFromGroups(ref, event, scorecards),
                            label: const Text('Qualify from Groups'),
                            icon: const Icon(Icons.star),
                            backgroundColor: Colors.blueAccent,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              roundName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
          ),
          ...matches.map((m) {
            final result = MatchPlayCalculator.calculate(
              match: m,
              scorecards: scorecards,
              courseConfig: event.courseConfig,
              holesToPlay: event.courseConfig['holes']?.length ?? 18,
            );
            return _BracketMatchTile(match: m, result: result);
          }),
        ],
      ),
    );
  }
}

class _BracketMatchTile extends StatelessWidget {
  final MatchDefinition match;
  final MatchResult result;

  const _BracketMatchTile({required this.match, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPlayerRow(match.team1Name ?? (match.team1Ids.isEmpty ? 'BYE' : 'Side A'), result.winningTeamIndex == 0),
          const Divider(height: 1, color: Colors.white12),
          _buildPlayerRow(match.team2Name ?? (match.team2Ids.isEmpty ? 'BYE' : 'Side B'), result.winningTeamIndex == 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(result.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Center(
              child: Text(
                result.status,
                style: TextStyle(
                  color: _getStatusColor(result.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(String name, bool isWinner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isWinner ? Colors.white : Colors.white70,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isWinner)
            const Icon(Icons.check_circle, color: Colors.green, size: 14),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'A/S') return Colors.orange;
    if (status.contains('UP') || status.contains('&')) return Colors.blue;
    return Colors.grey;
  }
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
