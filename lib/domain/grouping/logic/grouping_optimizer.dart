import 'dart:math';
import '../tee_group.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../../../features/events/domain/registration_logic.dart';

class GroupingOptimizer {
  static void optimize(List<TeeGroup> groups, List<GolfEvent> history, bool prioritizeBuggyPairing, String strategy) {
    // 1. Calculate historical pairing counts
    final pairingHistory = <String, Map<String, int>>{};

    for (var oldEvent in history) {
      final oldGroupingSerialized = oldEvent.grouping['groups'] as List?;
      if (oldGroupingSerialized == null) continue;
      
      for (var gData in oldGroupingSerialized) {
        final players = (gData['players'] as List)
            .map((p) => TeeGroupParticipant.fromJson(p))
            .toList();
            
        for (int i = 0; i < players.length; i++) {
          for (int j = i + 1; j < players.length; j++) {
            final idA = players[i].registrationMemberId;
            final idB = players[j].registrationMemberId;
            pairingHistory.putIfAbsent(idA, () => {})[idB] = (pairingHistory[idA]![idB] ?? 0) + 1;
            pairingHistory.putIfAbsent(idB, () => {})[idA] = (pairingHistory[idB]![idA] ?? 0) + 1;
          }
        }
      }
    }

    // 2. Iterative Random Swapping (Greedy Optimizer)
    final rand = Random();
    for (int i = 0; i < 500; i++) {
        final g1 = groups[rand.nextInt(groups.length)];
        final g2 = groups[rand.nextInt(groups.length)];
        if (g1 == g2) continue;

        final p1Idx = _findMovableIndex(g1);
        final p2Idx = _findMovableIndex(g2);
        if (p1Idx == -1 || p2Idx == -1) continue;

        final p1 = g1.players[p1Idx];
        final p2 = g2.players[p2Idx];

        double currentCost = _calculateCost(g1, g2, p1, p2, pairingHistory, groups.length, false, prioritizeBuggyPairing, strategy);
        double swapCost = _calculateCost(g1, g2, p1, p2, pairingHistory, groups.length, true, prioritizeBuggyPairing, strategy);

        if (swapCost < currentCost) {
          g1.players[p1Idx] = p2;
          g2.players[p2Idx] = p1;
        }
    }
  }

  static int _findMovableIndex(TeeGroup group) {
    final guestMemberIdsInGroup = group.players.where((p) => p.isGuest).map((p) => p.registrationMemberId).toSet();
    final movableIndices = <int>[];
    for (int i = 0; i < group.players.length; i++) {
      final p = group.players[i];
      if (!p.isGuest && !guestMemberIdsInGroup.contains(p.registrationMemberId)) {
        movableIndices.add(i);
      }
    }
    if (movableIndices.isEmpty) return -1;
    return movableIndices[Random().nextInt(movableIndices.length)];
  }

  static double _calculateCost(
    TeeGroup g1, 
    TeeGroup g2, 
    TeeGroupParticipant p1, 
    TeeGroupParticipant p2, 
    Map<String, Map<String, int>> history,
    int totalGroups,
    bool isSwapped,
    bool prioritizeBuggyPairing,
    String strategy,
  ) {
    final List<TeeGroupParticipant> g1Players = List.from(g1.players);
    final List<TeeGroupParticipant> g2Players = List.from(g2.players);

    if (isSwapped) {
      final p1Idx = g1Players.indexOf(p1);
      final p2Idx = g2Players.indexOf(p2);
      g1Players[p1Idx] = p2;
      g2Players[p2Idx] = p1;
    }

    double cost = 0.0;
    
    cost += _varietyPenalty(g1Players, history);
    cost += _varietyPenalty(g2Players, history);

    cost += _calculatePositionPenalty(g1Players, g1.index, totalGroups, []); 
    
    if (strategy == 'balanced') {
       double hc1 = g1Players.fold(0.0, (s, p) => s + p.playingHandicap);
       double hc2 = g2Players.fold(0.0, (s, p) => s + p.playingHandicap);
       cost += (hc1 - hc2).abs() * 0.5;
    } else if (strategy == 'progressive') {
        double avg1 = g1Players.fold(0.0, (s, p) => s + p.playingHandicap) / g1Players.length;
        double avg2 = g2Players.fold(0.0, (s, p) => s + p.playingHandicap) / g2Players.length;
        
        if (g1.index < g2.index && avg1 > avg2) cost += 1000.0;
        if (g2.index < g1.index && avg2 > avg1) cost += 1000.0;
        
        cost += _calculateVariance(g1Players);
        cost += _calculateVariance(g2Players);
    } else if (strategy == 'similar') {
        cost += _calculateVariance(g1Players) * 2.0;
        cost += _calculateVariance(g2Players) * 2.0;
    }

    int buggies1 = g1Players.where((p) => p.buggyStatus == RegistrationStatus.confirmed).length;
    int buggies2 = g2Players.where((p) => p.buggyStatus == RegistrationStatus.confirmed).length;
    
    if (buggies1 % 2 != 0) cost += 300.0;
    if (buggies2 % 2 != 0) cost += 300.0;

    int walkers1 = g1Players.length - buggies1;
    int walkers2 = g2Players.length - buggies2;
    if (walkers1 == 1 && g1Players.length > 2) cost += 500.0;
    if (walkers2 == 1 && g2Players.length > 2) cost += 500.0;
    
    if (g1Players.length == 4 && buggies1 == 4) cost -= 50.0;
    if (g1Players.length == 4 && buggies1 == 0) cost -= 20.0;
    if (g1Players.length == 4 && buggies1 == 2) cost -= 20.0;

    return cost;
  }

  static double _calculatePositionPenalty(List<TeeGroupParticipant> players, int groupIndex, int totalGroups, List<GolfEvent> history) {
    if (totalGroups <= 1) return 0.0;
    final currentSegment = _getSegment(groupIndex, totalGroups);
    double penalty = 0.0;
    
    for (var p in players) {
      if (p.isGuest) continue;
      
      final historyMatches = _countSegmentMatches(p.registrationMemberId, currentSegment, history, limit: 3);
      if (historyMatches > 0) {
        penalty += pow(historyMatches, 2) * 800.0; 
      }
    }
    return penalty;
  }

  static int _getSegment(int index, int total) {
    if (total <= 1) return 0;
    final normalized = index / (total - 1);
    if (normalized < 0.33) return 0;
    if (normalized < 0.66) return 1;
    return 2;
  }

  static int _countSegmentMatches(String memberId, int currentSegment, List<GolfEvent> history, {int limit = 3}) {
    int matches = 0;
    int eventsChecked = 0;
    for (int i = history.length - 1; i >= 0 && eventsChecked < limit; i--) {
       final oldEvent = history[i];
       final groupsData = oldEvent.grouping['groups'] as List?;
       if (groupsData == null) continue;
       eventsChecked++;
       for (int gIdx = 0; gIdx < groupsData.length; gIdx++) {
         final ps = groupsData[gIdx]['players'] as List;
         final found = ps.any((p) => p['registrationMemberId'] == memberId && p['isGuest'] == false);
         if (found) {
           if (_getSegment(gIdx, groupsData.length) == currentSegment) {
             matches++;
           }
           break;
         }
       }
    }
    return matches;
  }

  static double _varietyPenalty(List<TeeGroupParticipant> players, Map<String, Map<String, int>> history) {
    double penalty = 0.0;
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        final idA = players[i].registrationMemberId;
        final idB = players[j].registrationMemberId;
        final count = history[idA]?[idB] ?? 0;
        penalty += pow(count, 2) * 50.0;
      }
    }
    return penalty;
  }

  static double _calculateVariance(List<TeeGroupParticipant> players) {
    if (players.isEmpty) return 0.0;
    final avg = players.fold(0.0, (s, p) => s + p.playingHandicap) / players.length;
    final sumSquaredDiff = players.fold(0.0, (s, p) => s + pow(p.playingHandicap - avg, 2));
    return sumSquaredDiff / players.length;
  }

  /// Calculates the variety status for a player in a specific group.
  /// Returns 0 (Grey), 1 (Amber), 2 (Red)
  static int getTeeTimeVariety(String memberId, int groupIndex, int totalGroups, List<GolfEvent> history) {
    if (totalGroups <= 1) return 0;
    final currentSegment = _getSegment(groupIndex, totalGroups);
    final matches = _countSegmentMatches(memberId, currentSegment, history, limit: 3);
    return matches.clamp(0, 3);
  }
}
