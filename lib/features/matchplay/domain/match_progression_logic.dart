import '../domain/match_definition.dart';
import '../domain/match_play_calculator.dart';
import '../domain/match_standings_calculator.dart';
import '../../../../models/scorecard.dart';

class MatchProgressionLogic {
  
  static List<MatchDefinition> promoteFromGroups({
    required List<MatchDefinition> allMatches,
    required List<Scorecard> scorecards,
    required Map<String, dynamic> courseConfig,
    required MatchRoundType targetRound,
    required int qualifiersPerGroup,
  }) {
    final updatedMatches = List<MatchDefinition>.from(allMatches);
    
    // 1. Get Group Standings
    final groupMatches = allMatches.where((m) => m.round == MatchRoundType.group).toList();
    final Map<String, List<MatchDefinition>> groups = {};
    for (var m in groupMatches) {
      final gid = m.groupId ?? 'default';
      groups.putIfAbsent(gid, () => []).add(m);
    }

    final List<String> qualifiedIds = [];
    
    // Sort groups by ID to ensure consistent order (Group 1, Group 2...)
    final sortedGroupIds = groups.keys.toList()..sort();
    
    for (var gid in sortedGroupIds) {
      final matches = groups[gid]!;
      final standings = MatchStandingsCalculator.calculateStandings(
        matches: matches,
        scorecards: scorecards,
        courseConfig: courseConfig,
      );
      
      // Take Top X
      final qualifiers = standings.take(qualifiersPerGroup).map((s) => s.playerId).toList();
      qualifiedIds.addAll(qualifiers);
    }

    // 2. Clear then populate the Target Round matches
    final targetMatches = allMatches.where((m) => m.round == targetRound).toList();
    targetMatches.sort((a, b) => (a.bracketOrder ?? 0).compareTo(b.bracketOrder ?? 0));

    // Simple mapping: Q1 vs Q2, Q3 vs Q4...
    // Advanced: Winner G1 vs Runner-up G2 etc (requires more complex seeding map)
    for (int i = 0; i < targetMatches.length; i++) {
        final p1Idx = i * 2;
        final p2Idx = i * 2 + 1;
        
        final p1 = p1Idx < qualifiedIds.length ? [qualifiedIds[p1Idx]] : <String>[];
        final p2 = p2Idx < qualifiedIds.length ? [qualifiedIds[p2Idx]] : <String>[];
        
        final targetMatch = targetMatches[i];
        final updatedTarget = targetMatch.copyWith(
          team1Ids: p1,
          team2Ids: p2,
        );
        
        final idx = updatedMatches.indexWhere((m) => m.id == targetMatch.id);
        if (idx != -1) {
          updatedMatches[idx] = updatedTarget;
        }
    }

    return updatedMatches;
  }
  static List<MatchDefinition> promoteWinners({
    required List<MatchDefinition> allMatches,
    required List<Scorecard> scorecards,
    required Map<String, dynamic> courseConfig,
  }) {
    final updatedMatches = List<MatchDefinition>.from(allMatches);
    
    // Group matches by round
    final Map<MatchRoundType, List<MatchDefinition>> rounds = {};
    for (var m in allMatches) {
      rounds.putIfAbsent(m.round, () => []).add(m);
    }

    // Determine the next round to populate
    // Logic: Look for the first round that has placeholders (empty team IDs) 
    // but whose predecessor round is fully completed.
    
    // For now, let's focus on a standard progression:
    // Quarterfinal -> Semifinal -> Final
    
    _advanceRound(
      currentRound: MatchRoundType.quarterFinal,
      nextRound: MatchRoundType.semiFinal,
      updatedMatches: updatedMatches,
      allMatches: allMatches,
      scorecards: scorecards,
      courseConfig: courseConfig,
    );

    _advanceRound(
      currentRound: MatchRoundType.semiFinal,
      nextRound: MatchRoundType.finalRound,
      updatedMatches: updatedMatches,
      allMatches: allMatches,
      scorecards: scorecards,
      courseConfig: courseConfig,
    );

    return updatedMatches;
  }

  static void _advanceRound({
    required MatchRoundType currentRound,
    required MatchRoundType nextRound,
    required List<MatchDefinition> updatedMatches,
    required List<MatchDefinition> allMatches,
    required List<Scorecard> scorecards,
    required Map<String, dynamic> courseConfig,
  }) {
    final currentMatches = allMatches.where((m) => m.round == currentRound).toList();
    final nextMatches = allMatches.where((m) => m.round == nextRound).toList();
    
    if (currentMatches.isEmpty || nextMatches.isEmpty) return;
    
    // Sort by bracket order to ensure correct pairing
    currentMatches.sort((a, b) => (a.bracketOrder ?? 0).compareTo(b.bracketOrder ?? 0));
    nextMatches.sort((a, b) => (a.bracketOrder ?? 0).compareTo(b.bracketOrder ?? 0));

    for (int i = 0; i < nextMatches.length; i++) {
        final matchAIdx = i * 2;
        final matchBIdx = i * 2 + 1;
        
        if (matchAIdx >= currentMatches.length || matchBIdx >= currentMatches.length) continue;
        
        final m1 = currentMatches[matchAIdx];
        final m2 = currentMatches[matchBIdx];
        
        final r1 = MatchPlayCalculator.calculate(
          match: m1,
          scorecards: scorecards,
          courseConfig: courseConfig,
          holesToPlay: 18,
        );
        
        final r2 = MatchPlayCalculator.calculate(
          match: m2,
          scorecards: scorecards,
          courseConfig: courseConfig,
          holesToPlay: 18,
        );
        
        // Only promote if both matches are finished (Byes are auto-finalized)
        if (r1.isFinal && r2.isFinal) {
           final winner1Id = r1.winningTeamIndex == 0 ? m1.team1Ids.firstOrNull : m1.team2Ids.firstOrNull;
           final winner2Id = r2.winningTeamIndex == 0 ? m2.team1Ids.firstOrNull : m2.team2Ids.firstOrNull;
           
           if (winner1Id != null && winner2Id != null) {
              // Update the next match with these winners
              final targetMatch = nextMatches[i];
              final updatedTarget = targetMatch.copyWith(
                team1Ids: [winner1Id],
                team2Ids: [winner2Id],
              );
              
              // Find and replace in updatedMatches
              final idx = updatedMatches.indexWhere((m) => m.id == targetMatch.id);
              if (idx != -1) {
                updatedMatches[idx] = updatedTarget;
              }
           }
        }
    }
  }
}
