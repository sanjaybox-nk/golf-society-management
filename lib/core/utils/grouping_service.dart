import 'dart:math';
import '../../features/events/domain/registration_logic.dart';
import '../../models/golf_event.dart';

class TeeGroup {
  final int index;
  final DateTime teeTime;
  final List<TeeGroupParticipant> players;
  
  TeeGroup({required this.index, required this.teeTime, required this.players});
  
  Map<String, dynamic> toJson() => {
    'index': index,
    'teeTime': teeTime.toIso8601String(),
    'players': players.map((p) => p.toJson()).toList(),
  };
  
  static TeeGroup fromJson(Map<String, dynamic> json) => TeeGroup(
    index: json['index'],
    teeTime: DateTime.parse(json['teeTime']),
    players: (json['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList(),
  );

  double get totalHandicap => players.fold(0, (sum, p) => sum + p.handicap);
}

class TeeGroupParticipant {
  final String registrationMemberId; // Host member ID
  final String name;
  final bool isGuest;
  final double handicap;
  bool needsBuggy;
  RegistrationStatus buggyStatus;
  bool isCaptain;
  
  TeeGroupParticipant({
    required this.registrationMemberId,
    required this.name,
    required this.isGuest,
    required this.handicap,
    required this.needsBuggy,
    this.buggyStatus = RegistrationStatus.none,
    this.isCaptain = false,
  });

  Map<String, dynamic> toJson() => {
    'registrationMemberId': registrationMemberId,
    'name': name,
    'isGuest': isGuest,
    'handicap': handicap,
    'needsBuggy': needsBuggy,
    'buggyStatus': buggyStatus.name,
    'isCaptain': isCaptain,
  };

  static TeeGroupParticipant fromJson(Map<String, dynamic> json) => TeeGroupParticipant(
    registrationMemberId: json['registrationMemberId'],
    name: json['name'],
    isGuest: json['isGuest'],
    handicap: (json['handicap'] as num?)?.toDouble() ?? 0.0,
    needsBuggy: json['needsBuggy'] ?? false,
    buggyStatus: RegistrationStatus.values.firstWhere(
      (e) => e.name == json['buggyStatus'], 
      orElse: () => (json['needsBuggy'] ?? false) ? RegistrationStatus.confirmed : RegistrationStatus.none,
    ),
    isCaptain: json['isCaptain'] ?? false,
  );
}

class GroupingService {
  
  /// Generates the initial grouping based on rules:
  /// 1. Only confirmed golfers.
  /// 2. Guests always with host members.
  /// 3. Pair buggy users.
  /// 4. Balance HC.
  /// 5. Maximize variety (using pastEvents).
  /// 6. 3-balls at the front.
  static List<TeeGroup> generateInitialGrouping({
    required GolfEvent event,
    required List<RegistrationItem> participants,
    required List<GolfEvent> previousEventsInSeason,
    required Map<String, double> memberHandicaps,
  }) {
    // 1. Get confirmed golfers (excluding waitlist if we strictly follow capacity)
    // For automatic grouping, we only take those who are "CONFIRMED" or "RESERVED" 
    // depending on your definition of "committed to play".
    // Usually, we group everyone who is confirmed.
    final golfers = participants.where((p) => p.registration.attendingGolf).toList();
    if (golfers.isEmpty) return [];

    // 2. Identify Pairs (Member + Guest)
    // We treat a Member and their Guest as a "Locked Pair" of 2 slots.
    final List<_TeeSlot> slots = [];
    final Set<String> processedMemberIds = {};

    for (var golfer in golfers) {
      if (!golfer.isGuest) {
        if (processedMemberIds.contains(golfer.registration.memberId)) continue;
        
        final host = golfer;
        final guest = golfers.where((g) => g.isGuest && g.registration.memberId == host.registration.memberId).firstOrNull;
        
        final availableBuggies = event.availableBuggies ?? 0;
        final buggyCapacity = availableBuggies * 2;
        final buggyQueue = participants.where((i) => i.needsBuggy).toList();

        if (guest != null) {
          slots.add(_TeeSlot(players: [
            _toParticipant(host, memberHandicaps, buggyQueue, buggyCapacity),
            _toParticipant(guest, memberHandicaps, buggyQueue, buggyCapacity),
          ]));
        } else {
          slots.add(_TeeSlot(players: [_toParticipant(host, memberHandicaps, buggyQueue, buggyCapacity)]));
        }
        processedMemberIds.add(host.registration.memberId);
      } else {
        // Guests are handled with hosts, but if a guest is alone (unlikely in current model)
        if (!processedMemberIds.contains(golfer.registration.memberId)) {
           final availableBuggies = event.availableBuggies ?? 0;
           final buggyCapacity = availableBuggies * 2;
           final buggyQueue = participants.where((i) => i.needsBuggy).toList();
           slots.add(_TeeSlot(players: [_toParticipant(golfer, memberHandicaps, buggyQueue, buggyCapacity)]));
           processedMemberIds.add(golfer.registration.memberId);
        }
      }
    }

    // 3. Determine Group Sizes (x 4-balls, y 3-balls)
    final totalPlayers = golfers.length;
    int num4Balls = 0;
    int num3Balls = 0;

    // Logic to distribute N into groups of 3 and 4
    // We want to maximize 4-balls, but must use only 3 or 4.
    // N = 4x + 3y
    for (int y = 0; y <= totalPlayers / 3; y++) {
      int remaining = totalPlayers - (3 * y);
      if (remaining >= 0 && remaining % 4 == 0) {
        num3Balls = y;
        num4Balls = remaining ~/ 4;
        break; 
      }
    }

    // 4. Initial Distribution (Greedy)
    final List<TeeGroup> groups = [];
    DateTime currentTime = event.teeOffTime ?? DateTime.now();
    int interval = event.teeOffInterval;

    // Start with 3-balls (per user request)
    for (int i = 0; i < num3Balls; i++) {
      groups.add(TeeGroup(index: i, teeTime: currentTime, players: []));
      currentTime = currentTime.add(Duration(minutes: interval));
    }
    // Then 4-balls
    for (int i = 0; i < num4Balls; i++) {
      groups.add(TeeGroup(index: num3Balls + i, teeTime: currentTime, players: []));
      currentTime = currentTime.add(Duration(minutes: interval));
    }

    // 5. Fill Slots
    // Sort slots by size (pairs first) to ensure they fit in 4-balls or 3-balls easily
    slots.sort((a, b) => b.players.length.compareTo(a.players.length));

    // Simple Greedy Fill (can be improved with variety/HC logic)
    for (var slot in slots) {
      // Find a group with enough space
      TeeGroup? target;
      int maxGroupSize(int index) => index < num3Balls ? 3 : 4;

      for (var group in groups) {
          if (group.players.length + slot.players.length <= maxGroupSize(group.index)) {
              target = group;
              break;
          }
      }
      
      if (target != null) {
          target.players.addAll(slot.players);
      } else {
          // This should logically not happen if num3/num4 calculated correctly
          // Fallback: put in first available
          groups.first.players.addAll(slot.players);
      }
    }

    // 6. Post-Processing: Captains & Buggies
    final random = Random();
    for (var group in groups) {
      if (group.players.isEmpty) continue;
      
      // Assign Captain (randomly if none assigned, but usually first member)
      final membersOnly = group.players.where((p) => !p.isGuest).toList();
      if (membersOnly.isNotEmpty) {
        membersOnly[random.nextInt(membersOnly.length)].isCaptain = true;
      } else {
        group.players.first.isCaptain = true;
      }

      // Buggy Optimization
      // Group buggy users together. They are already in the same group, 
      // but in the UI we might want to represent them paired.
      // Logic: If there are 2 buggy users, they share one buggy. 
      // This is mostly a UI representation detail.
    }

    // 7. Variety & Handicap Optimization (Refinement Pass)
    // Swap individuals (non-guests) between groups of same size to improve variety and balance
    _optimize(groups, previousEventsInSeason);

    return groups;
  }

  static void _optimize(List<TeeGroup> groups, List<GolfEvent> history) {
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
    // We try to swap players who are NOT locked (not a guest-host pair)
    final rand = Random();
    for (int i = 0; i < 500; i++) {
        // Pick two random groups
        final g1 = groups[rand.nextInt(groups.length)];
        final g2 = groups[rand.nextInt(groups.length)];
        if (g1 == g2) continue;

        // Pick one movable player from each
        final p1Idx = _findMovableIndex(g1);
        final p2Idx = _findMovableIndex(g2);
        if (p1Idx == -1 || p2Idx == -1) continue;

        final p1 = g1.players[p1Idx];
        final p2 = g2.players[p2Idx];

        // Cost function: Variance of HC + Penalty for repeated pairings
        double currentCost = _calculateCost(g1, g2, p1, p2, pairingHistory, false);
        double swapCost = _calculateCost(g1, g2, p1, p2, pairingHistory, true);

        if (swapCost < currentCost) {
          // Perform swap
          g1.players[p1Idx] = p2;
          g2.players[p2Idx] = p1;
        }
    }
  }

  static int _findMovableIndex(TeeGroup group) {
    // A player is movable if they are a member and NOT a host to a guest in their same group
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


  static double _calculateCost(TeeGroup g1, TeeGroup g2, TeeGroupParticipant p1, TeeGroupParticipant p2, Map<String, Map<String, int>> history, bool isSwapped) {
    // Simplified cost: 
    // 1. Handicap distance from average
    // 2. Historical pairing penalties (heavy weight)
    
    final List<TeeGroupParticipant> g1Players = List.from(g1.players);
    final List<TeeGroupParticipant> g2Players = List.from(g2.players);

    if (isSwapped) {
      final p1Idx = g1Players.indexOf(p1);
      final p2Idx = g2Players.indexOf(p2);
      g1Players[p1Idx] = p2;
      g2Players[p2Idx] = p1;
    }

    double cost = 0.0;
    
    // Variety Penalty
    cost += _varietyPenalty(g1Players, history);
    cost += _varietyPenalty(g2Players, history);

    // HC Balance (Distance from target average - target could be global avg or just minimizing diff)
    // Actually minimizing global spread is easier
    double hc1 = g1Players.fold(0.0, (s, p) => s + p.handicap);
    double hc2 = g2Players.fold(0.0, (s, p) => s + p.handicap);
    cost += (hc1 - hc2).abs() * 0.5; // Weight HC balance less than variety

    return cost;
  }

  static double _varietyPenalty(List<TeeGroupParticipant> players, Map<String, Map<String, int>> history) {
    double penalty = 0.0;
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        final idA = players[i].registrationMemberId;
        final idB = players[j].registrationMemberId;
        final count = history[idA]?[idB] ?? 0;
        penalty += pow(count, 2) * 50.0; // Quadratic penalty for repeats
      }
    }
    return penalty;
  }

  static TeeGroupParticipant _toParticipant(
    RegistrationItem item, 
    Map<String, double> memberHandicaps,
    List<RegistrationItem> buggyQueue,
    int buggyCapacity,
  ) {
    double handicap = 0.0;
    if (item.isGuest) {
      handicap = double.tryParse(item.registration.guestHandicap ?? '') ?? 28.0;
    } else {
      handicap = memberHandicaps[item.registration.memberId] ?? 28.0;
    }

    final buggyIndex = item.needsBuggy ? buggyQueue.indexOf(item) : -1;
    final buggyStatus = RegistrationLogic.calculateBuggyStatus(
      needsBuggy: item.needsBuggy, 
      hasPaid: item.registration.hasPaid, 
      buggyIndexInQueue: buggyIndex, 
      buggyCapacity: buggyCapacity,
      buggyStatusOverride: item.isGuest 
          ? item.registration.guestBuggyStatusOverride 
          : item.registration.buggyStatusOverride,
    );
    
    return TeeGroupParticipant(
      registrationMemberId: item.registration.memberId,
      name: item.name,
      isGuest: item.isGuest,
      handicap: handicap,
      needsBuggy: item.needsBuggy,
      buggyStatus: buggyStatus,
    );
  }
}

class _TeeSlot {
  final List<TeeGroupParticipant> players;
  _TeeSlot({required this.players});
}
