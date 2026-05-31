import 'dart:math';
import '../domain/match_definition.dart';
import '../domain/match_play_tournament.dart';
import '../../../domain/models/competition.dart';
import '../../../domain/models/course_config.dart';
import '../../../domain/scoring/handicap_calculator.dart';
import '../../../domain/models/member.dart';
import 'package:uuid/uuid.dart';

class MatchPlayDrawService {
  static const _uuid = Uuid();

  /// Generates a complete knockout draw with byes if necessary.
  /// When [teamAssignments] is provided (memberId → 'A'|'B'), every first-round
  /// match is guaranteed to be Team A vs Team B — no same-team pairings.
  static List<MatchDefinition> generateKnockoutDraw({
    required List<MatchPlayEntrant> entrants,
    required SeedingType seedingType,
    required MatchRoundType startRound,
    Map<String, String> teamAssignments = const {},
  }) {
    List<MatchPlayEntrant?> slots;

    if (teamAssignments.isNotEmpty) {
      // Split into per-team pools keyed by first player ID
      final teamA = entrants.where((e) {
        final id = e.playerIds.firstOrNull;
        return id != null && teamAssignments[id] == 'A';
      }).toList();
      final teamB = entrants.where((e) {
        final id = e.playerIds.firstOrNull;
        return id != null && teamAssignments[id] == 'B';
      }).toList();

      int comparator(MatchPlayEntrant a, MatchPlayEntrant b) {
        if (a.seed != null && b.seed != null) return a.seed!.compareTo(b.seed!);
        if (a.seed != null) return -1;
        if (b.seed != null) return 1;
        return (b.qualifyingScore ?? 0).compareTo(a.qualifyingScore ?? 0);
      }

      if (seedingType == SeedingType.random) {
        teamA.shuffle();
        teamB.shuffle();
      } else {
        teamA.sort(comparator);
        teamB.sort(comparator);
      }

      // Interleave: slot[2i] = A[i], slot[2i+1] = B[i]
      // so each match pair is guaranteed A vs B.
      final int pairCount = max(teamA.length, teamB.length);
      int fieldSize = 2;
      while (fieldSize < pairCount * 2) { fieldSize *= 2; }

      slots = List<MatchPlayEntrant?>.filled(fieldSize, null);
      for (int i = 0; i < pairCount; i++) {
        slots[i * 2]     = i < teamA.length ? teamA[i] : null;
        slots[i * 2 + 1] = i < teamB.length ? teamB[i] : null;
      }
    } else {
      // Standard single-pool draw
      final sortedEntrants = List<MatchPlayEntrant>.from(entrants);
      if (seedingType == SeedingType.random) {
        sortedEntrants.shuffle();
      } else {
        sortedEntrants.sort((a, b) {
          if (a.seed != null && b.seed != null) return a.seed!.compareTo(b.seed!);
          if (a.seed != null) return -1;
          if (b.seed != null) return 1;
          return (b.qualifyingScore ?? 0).compareTo(a.qualifyingScore ?? 0);
        });
      }

      final entrantCount = sortedEntrants.length;
      int fieldSize = 2;
      while (fieldSize < entrantCount) { fieldSize *= 2; }

      slots = List<MatchPlayEntrant?>.filled(fieldSize, null);
      for (int i = 0; i < entrantCount; i++) {
        slots[i] = sortedEntrants[i];
      }
    }

    // Build matches from interleaved slots
    final List<MatchDefinition> matches = [];
    final int matchCount = slots.length ~/ 2;

    for (int i = 0; i < matchCount; i++) {
      final e1 = slots[i * 2];
      final e2 = slots[i * 2 + 1];

      matches.add(MatchDefinition(
        id: _uuid.v4(),
        type: MatchType.singles,
        team1Ids: e1?.playerIds ?? [],
        team2Ids: e2?.playerIds ?? [],
        team1Name: e1?.name,
        team2Name: e2?.name,
        round: startRound,
        bracketOrder: i,
        isBye: e1 == null || e2 == null,
      ));
    }

    _buildFutureRounds(matches, startRound, slots.length);

    return matches;
  }

  /// Generates all round-robin group stage matches for every division.
  ///
  /// Each match gets:
  ///   round = MatchRoundType.group
  ///   groupId = division letter ("A", "B", …)
  ///   bracketOrder = round index within the group stage (0-based), so
  ///                  the caller can link each round to a specific event.
  static List<MatchDefinition> generateGroupStageMatches({
    required Map<String, List<String>> divisions,
    required List<MatchPlayEntrant> entrants,
  }) {
    final entrantMap = {for (final e in entrants) e.id: e};
    final List<MatchDefinition> matches = [];

    for (final entry in divisions.entries) {
      final divisionId = entry.key;
      final rounds = _roundRobinSchedule(entry.value);

      for (int roundIndex = 0; roundIndex < rounds.length; roundIndex++) {
        for (final pair in rounds[roundIndex]) {
          final e1 = entrantMap[pair.$1];
          final e2 = entrantMap[pair.$2];

          matches.add(MatchDefinition(
            id: _uuid.v4(),
            type: MatchType.singles,
            team1Ids: e1?.playerIds ?? [pair.$1],
            team2Ids: e2?.playerIds ?? [pair.$2],
            team1Name: e1?.name,
            team2Name: e2?.name,
            round: MatchRoundType.group,
            groupId: divisionId,
            bracketOrder: roundIndex,
          ));
        }
      }
    }

    return matches;
  }

  /// Standard round-robin rotation algorithm (Berger tables).
  /// Returns one list of matchups per round. Odd player counts get a bye that
  /// is silently dropped — the bye player sits out that round.
  static List<List<(String, String)>> _roundRobinSchedule(List<String> playerIds) {
    final players = List<String>.from(playerIds);
    if (players.length % 2 != 0) players.add('__bye__');

    final n = players.length;
    final rounds = <List<(String, String)>>[];

    for (int round = 0; round < n - 1; round++) {
      final pairs = <(String, String)>[];
      for (int i = 0; i < n ~/ 2; i++) {
        final p1 = players[i];
        final p2 = players[n - 1 - i];
        if (p1 != '__bye__' && p2 != '__bye__') pairs.add((p1, p2));
      }
      rounds.add(pairs);

      // Rotate all positions except the first (fixed anchor)
      final last = players.removeAt(n - 1);
      players.insert(1, last);
    }

    return rounds;
  }

  /// Generates divisions for Group Stage
  static Map<String, List<String>> generateDivisions({
    required List<MatchPlayEntrant> entrants,
    required int entrantsPerDivision,
    required SeedingType seedingType,
  }) {
    final List<MatchPlayEntrant> sortedEntrants = List.from(entrants);
    if (seedingType == SeedingType.random) {
      sortedEntrants.shuffle();
    } else {
      sortedEntrants.sort((a, b) => (b.qualifyingScore ?? 0).compareTo(a.qualifyingScore ?? 0));
    }

    final Map<String, List<String>> divisions = {};
    final divisionCount = (sortedEntrants.length / entrantsPerDivision).ceil();

    for (int i = 0; i < divisionCount; i++) {
      final divisionId = String.fromCharCode(65 + i); // A, B, C...
      final List<String> divisionEntrantIds = [];
      
      // Snake distribution for seeded draws
      if (seedingType == SeedingType.seeded) {
        // ... implementation of snake distribution ...
        // For now, simple bucket
        for (int j = i; j < sortedEntrants.length; j += divisionCount) {
           divisionEntrantIds.add(sortedEntrants[j].id);
        }
      } else {
        final start = i * entrantsPerDivision;
        final end = min(start + entrantsPerDivision, sortedEntrants.length);
        divisionEntrantIds.addAll(sortedEntrants.sublist(start, end).map((e) => e.id));
      }
      
      divisions[divisionId] = divisionEntrantIds;
    }

    return divisions;
  }

  static void _buildFutureRounds(List<MatchDefinition> matches, MatchRoundType startRound, int fieldSize) {
    MatchRoundType current = startRound;
    int currentMatchCount = fieldSize ~/ 2;

    while (current != MatchRoundType.finalRound) {
       MatchRoundType next = _getNextRound(current);
       int nextMatchCount = currentMatchCount ~/ 2;
       
       for (int i = 0; i < nextMatchCount; i++) {
         matches.add(MatchDefinition(
           id: _uuid.v4(),
           type: MatchType.singles,
           team1Ids: [],
           team2Ids: [],
           round: next,
           bracketOrder: i,
         ));
       }
       
       current = next;
       currentMatchCount = nextMatchCount;
    }
  }

  static MatchRoundType _getNextRound(MatchRoundType current) {
    switch (current) {
      case MatchRoundType.group: return MatchRoundType.roundOf32;
      case MatchRoundType.roundOf32: return MatchRoundType.roundOf16;
      case MatchRoundType.roundOf16: return MatchRoundType.quarterFinal;
      case MatchRoundType.quarterFinal: return MatchRoundType.semiFinal;
      case MatchRoundType.semiFinal: return MatchRoundType.finalRound;
      case MatchRoundType.finalRound: return MatchRoundType.finalRound;
    }
  }

  /// Propagates winners from completed matches to the next round slots
  static List<MatchDefinition> propagateWinners(List<MatchDefinition> matches) {
    final List<MatchDefinition> updatedMatches = List.from(matches);
    
    // Group matches by round
    for (final match in matches) {
      final result = match.manualResult;
      if (result == null || !result.isFinal || match.round == MatchRoundType.finalRound) continue;
      if (match.bracketOrder == null) continue;
      
      final nextRound = _getNextRound(match.round);
      if (nextRound == match.round) continue;

      // Determine target slot in next round
      final int nextBracketOrder = match.bracketOrder! ~/ 2;
      final bool isTeam1InNext = match.bracketOrder! % 2 == 0;

      final targetIdx = updatedMatches.indexWhere((m) => 
        m.round == nextRound && m.bracketOrder == nextBracketOrder
      );

      if (targetIdx != -1) {
        final targetMatch = updatedMatches[targetIdx];
        
        // Find the winner's team details from the completed match
        final bool isTeam1Winner = result.winningTeamIndex == 0;
        final List<String> winnerIds = isTeam1Winner ? match.team1Ids : match.team2Ids;
        final String? winnerName = isTeam1Winner ? match.team1Name : match.team2Name;

        updatedMatches[targetIdx] = isTeam1InNext
            ? targetMatch.copyWith(team1Ids: winnerIds, team1Name: winnerName)
            : targetMatch.copyWith(team2Ids: winnerIds, team2Name: winnerName);
      }
    }

    return updatedMatches;
  }

  /// Calculate strokes received for all matches in a tournament
  static List<MatchDefinition> calculateAllMatchStrokes({
    required List<MatchDefinition> matches,
    required CompetitionRules rules,
    required CourseConfig courseConfig,
    required Map<String, Member> membersMap,
  }) {
    return matches.map((m) => calculateMatchStrokes(
      match: m,
      rules: rules,
      courseConfig: courseConfig,
      membersMap: membersMap,
    )).toList();
  }

  /// Calculates strokes for a single match
  static MatchDefinition calculateMatchStrokes({
    required MatchDefinition match,
    required CompetitionRules rules,
    required CourseConfig courseConfig,
    required Map<String, Member> membersMap,
  }) {
    if (match.isBye || (match.team1Ids.isEmpty && match.team2Ids.isEmpty)) return match;

    final allPlayerIds = [...match.team1Ids, ...match.team2Ids];
    final Map<String, int> targetPhcs = {};
    int minPhc = 999;

    for (final id in allPlayerIds) {
      final cleanId = id.replaceFirst('_guest', '');
      final member = membersMap[cleanId];
      if (member == null) continue;

      final phc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: member.handicap,
        rules: rules.copyWith(handicapAllowance: 1.0), // Get 100% Course Hcp first
        courseConfig: courseConfig,
      );
      targetPhcs[id] = phc;
      if (phc < minPhc) minPhc = phc;
    }

    if (minPhc == 999) return match;

    // Apply Allowance rule: (PHC - MinPHC) * Allowance
    final Map<String, int> strokesReceived = {};
    for (final id in allPlayerIds) {
      final playerPhc = targetPhcs[id];
      if (playerPhc != null) {
        final diff = playerPhc - minPhc;
        if (diff > 0) {
          strokesReceived[id] = (diff * rules.handicapAllowance).round();
        }
      }
    }

    return match.copyWith(strokesReceived: strokesReceived);
  }
}
