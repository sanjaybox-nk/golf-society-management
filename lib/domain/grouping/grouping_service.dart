import 'dart:math';
import 'package:golf_society/domain/models/member.dart';
import '../../features/events/domain/registration_logic.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../scoring/handicap_calculator.dart';
import 'tee_group.dart';
import 'logic/grouping_optimizer.dart';

export 'tee_group.dart';

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
    CompetitionRules? rules, // New
    bool useWhs = true, // New
    bool prioritizeBuggyPairing = false,
    String strategy = 'balanced',
  }) {
    // 1. Get golfers who fit within the capacity (Confirmed or Reserved)
    int takenSlotsCount = 0;
    final List<RegistrationItem> golfers = [];
    final capacity = event.maxParticipants ?? 999;
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);

    // Helper to calculate P-HC
    final hcConfig = _HandicapContext(
      rules: rules,
      courseConfig: event.courseConfig,
      useWhs: useWhs,
      manualCuts: event.manualCuts,
    );

    for (int i = 0; i < participants.length; i++) {
        final item = participants[i];
        if (!item.registration.attendingGolf) continue;

        final status = RegistrationLogic.calculateStatus(
            isGuest: item.isGuest,
            isConfirmed: item.isConfirmed,
            hasPaid: item.hasPaid,
            capacity: capacity,
            confirmedCount: takenSlotsCount, // Check against current pool size
            isEventClosed: isClosed,
            statusOverride: item.statusOverride,
        );

        if (status == RegistrationStatus.confirmed) {
            golfers.add(item);
            takenSlotsCount++; // Only increment for confirmed players
            
            // Safety break: If we've reached capacity, stop including more players 
            if (takenSlotsCount >= capacity) {
                // Continue loop to handle potential overrides or status shifts, 
                // but golfers list is effectively capped for the field.
            }
        }
    }
    
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
        final confirmedBuggyCount = participants.where((i) => 
          i.buggyStatusOverride == 'confirmed' || (i.isConfirmed && i.needsBuggy)).length;


        if (guest != null) {
          slots.add(_TeeSlot(players: [
            _toParticipant(host, memberHandicaps, buggyQueue, buggyCapacity, confirmedBuggyCount, hcConfig),
            _toParticipant(guest, memberHandicaps, buggyQueue, buggyCapacity, confirmedBuggyCount, hcConfig),
          ]));
        } else {
          slots.add(_TeeSlot(players: [_toParticipant(host, memberHandicaps, buggyQueue, buggyCapacity, confirmedBuggyCount, hcConfig)]));
        }
        processedMemberIds.add(host.registration.memberId);
      } else {
        // Guests are handled with hosts, but if a guest is alone (unlikely in current model)
        if (!processedMemberIds.contains(golfer.registration.memberId)) {
           final availableBuggies = event.availableBuggies ?? 0;
           final buggyCapacity = availableBuggies * 2;
           final buggyQueue = participants.where((i) => i.needsBuggy).toList();
           final confirmedBuggyCount = participants.where((i) => 
             i.buggyStatusOverride == 'confirmed' || (i.isConfirmed && i.needsBuggy)).length;
             
           slots.add(_TeeSlot(players: [_toParticipant(golfer, memberHandicaps, buggyQueue, buggyCapacity, confirmedBuggyCount, hcConfig)]));
           processedMemberIds.add(golfer.registration.memberId);
        }
      }
    }
    
    // [NEW] Foursomes Balanced Pairing
    // If Foursomes and strategy is balanced, we pair up the "singles" (High + Low)
    final isFoursomes = rules?.subtype == CompetitionSubtype.foursomes;
    if (isFoursomes && strategy == 'balanced') {
      final singles = slots.where((s) => s.players.length == 1).toList();
      if (singles.length >= 2) {
        // Remove individual singles from Main Slots
        slots.removeWhere((s) => s.players.length == 1);
        
        // Sort singles by handicap (Low to High)
        singles.sort((a, b) => a.averageHandicap.compareTo(b.averageHandicap));
        
        // Pair them (1st + Last, 2nd + Second Last)
        final int half = (singles.length / 2).floor();
        for (int i = 0; i < half; i++) {
          final low = singles[i];
          final high = singles[singles.length - 1 - i];
          slots.add(_TeeSlot(players: [...low.players, ...high.players]));
        }
        
        // Handle odd one out if necessary (though Foursomes implies even numbers)
        if (singles.length % 2 != 0) {
          slots.add(singles[half]); // The middle one stays single (to be grouped later)
        }
      }
    }

    // 3. Determine Group Sizes (x 4-balls, y 3-balls)
    final totalPlayers = golfers.length;
    int num4Balls = 0;
    int num3Balls = 0;
    
    // [FIX] Scramble 3-Man Override
    // If Scramble & TeamSize=3, we force ALL groups to be max 3 players (3-balls)
    final is3ManScramble = rules?.format == CompetitionFormat.scramble && rules?.teamSize == 3;
    
    if (is3ManScramble) {
       // Force 3-balls
       // e.g. 10 players -> 3, 3, 3, 1 (Wait... 1 is not valid)
       // Standard logic: N = 3 groups.
       num3Balls = (totalPlayers / 3).ceil(); 
       num4Balls = 0;
       // Note: This might leave the last group with 1 or 2 players if not divisible by 3.
       // Refinement: If 10 players, we want 3 groups: 4, 3, 3? NO, strict 3-man means we can't have 4.
       // So 3, 3, 3, 1 is the only math way. 
       // Admin will have to deal with the remainder manually.
    } else {
      // Standard Logic to distribute N into groups of 3 and 4
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
    // Sort slots based on strategy
    if (strategy == 'balanced') {
      // Sort by size (pairs first) to ensure they fit in 4-balls or 3-balls easily
      slots.sort((a, b) => b.players.length.compareTo(a.players.length));
    } else if (strategy == 'progressive' || strategy == 'similar') {
      // Sort by Handicap (Low to High)
      slots.sort((a, b) => a.averageHandicap.compareTo(b.averageHandicap));
    } else if (strategy == 'random') {
      // Shuffle
      slots.shuffle(Random());
    } else {
        // Fallback default
        slots.sort((a, b) => b.players.length.compareTo(a.players.length));
    }

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
    // Optimization: Variety & Handicap Optimization (Refinement Pass)
    GroupingOptimizer.optimize(groups, previousEventsInSeason, prioritizeBuggyPairing, strategy);

    return groups;
  }

  static int getTeeTimeVariety(String memberId, int groupIndex, int totalGroups, List<GolfEvent> history) {
    return GroupingOptimizer.getTeeTimeVariety(memberId, groupIndex, totalGroups, history);
  }

  static TeeGroupParticipant _toParticipant(
    RegistrationItem item, 
    Map<String, double> memberHandicaps,
    List<RegistrationItem> buggyQueue,
    int buggyCapacity,
    int confirmedBuggyCount,
    _HandicapContext? hcConfig,
  ) {
    double rawHandicap = 0.0;
    if (item.isGuest) {
      rawHandicap = double.tryParse(item.registration.guestHandicap ?? '') ?? 28.0;
    } else {
      rawHandicap = memberHandicaps[item.registration.memberId] ?? 28.0;
    }

    double finalHandicap = rawHandicap;
    if (hcConfig != null && hcConfig.rules != null) {
       final memberId = item.registration.memberId;
       final societyCut = hcConfig.manualCuts[memberId] ?? 0.0;
       
       final playing = HandicapCalculator.calculatePlayingHandicap(
         handicapIndex: rawHandicap, 
         rules: hcConfig.rules!, 
         courseConfig: hcConfig.courseConfig,
         useWhs: hcConfig.useWhs,
         societyCut: societyCut,
       );
       finalHandicap = playing.toDouble();
    }

    final buggyIndex = item.needsBuggy ? buggyQueue.indexOf(item) : -1;
    final buggyStatus = RegistrationLogic.calculateBuggyStatus(
      needsBuggy: item.needsBuggy, 
      isConfirmed: item.isConfirmed, 
      buggyIndexInQueue: buggyIndex, 
      buggyCapacity: buggyCapacity,
      confirmedBuggyCount: confirmedBuggyCount,
      buggyStatusOverride: item.isGuest 
          ? item.registration.guestBuggyStatusOverride 
          : item.registration.buggyStatusOverride,
    );
    
    return TeeGroupParticipant(
      registrationMemberId: item.registration.memberId,
      name: item.name,
      isGuest: item.isGuest,
      handicapIndex: rawHandicap,
      playingHandicap: finalHandicap,
      needsBuggy: item.needsBuggy,
      buggyStatus: buggyStatus,
      status: item.statusOverride != null && item.statusOverride == 'withdrawn' 
          ? RegistrationStatus.withdrawn 
          : RegistrationStatus.confirmed,
    );
  }

  /// Recalculates all snapshotted playing handicaps in a grouping based on current event conditions.
  static Map<String, dynamic> recalculateGroupHandicaps({
    required GolfEvent event,
    required List<Member> members,
    CompetitionRules? rules,
    bool useWhs = true,
  }) {
    final groupsData = event.grouping['groups'] as List?;
    if (groupsData == null) return event.grouping;

    final memberMap = {for (var m in members) m.id: m};
    final List<TeeGroup> groups = groupsData.map((g) => TeeGroup.fromJson(g as Map<String, dynamic>)).toList();

    for (var group in groups) {
      for (int i = 0; i < group.players.length; i++) {
        final p = group.players[i];
        final memberId = p.registrationMemberId;
        final member = memberMap[memberId];
        
        double rawHandicap = p.handicapIndex; 
        if (member != null && !p.isGuest) {
          rawHandicap = member.handicap;
        }

        final societyCut = event.manualCuts[memberId] ?? 0.0;
        final playing = HandicapCalculator.calculatePlayingHandicap(
           handicapIndex: rawHandicap, 
           rules: rules ?? const CompetitionRules(), 
           courseConfig: event.courseConfig,
           useWhs: useWhs,
           societyCut: societyCut,
        );

        group.players[i] = p.copyWith(
          handicapIndex: rawHandicap,
          playingHandicap: playing.toDouble(),
        );
      }
    }

    return {
      ...event.grouping,
      'groups': groups.map((g) => g.toJson()).toList(),
    };
  }
}

class _HandicapContext {
  final CompetitionRules? rules;
  final Map<String, dynamic> courseConfig;
  final bool useWhs;
  final Map<String, double> manualCuts;
  _HandicapContext({this.rules, required this.courseConfig, required this.useWhs, required this.manualCuts});
}

class _TeeSlot {
  final List<TeeGroupParticipant> players;
  _TeeSlot({required this.players});

  double get averageHandicap {
    if (players.isEmpty) return 0.0;
    return players.fold(0.0, (s, p) => s + p.playingHandicap) / players.length;
  }
}
