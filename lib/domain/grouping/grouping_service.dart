import 'dart:math';
import 'package:golf_society/domain/models/member.dart';
import '../../features/events/domain/registration_logic.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../scoring/handicap_calculator.dart';
import 'tee_group.dart';
import 'package:golf_society/domain/models/course_config.dart';
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

    // 2. Identify Unique Participants and Pair Host/Guest
    final List<_TeeSlot> slots = [];
    final Set<String> processedUniqueIds = {}; // Format: memberId_guestName or memberId_host

    for (var golfer in golfers) {
      if (!golfer.isGuest) {
        final hostUniqueId = '${golfer.registration.memberId}_host';
        if (processedUniqueIds.contains(hostUniqueId)) continue;
        
        final host = golfer;
        processedUniqueIds.add(hostUniqueId);

        // Find ALL guests for this host
        final hostGuests = golfers.where((g) => g.isGuest && g.registration.memberId == host.registration.memberId).toList();
        final List<TeeGroupParticipant> slotParticipants = [];
        
        final availableBuggies = event.availableBuggies ?? 0;
        final buggyCapacity = availableBuggies * 2;
        final buggyQueue = participants.where((i) => i.needsBuggy).toList();
        final confirmedBuggyCount = participants.where((i) => 
          i.buggyStatusOverride == 'confirmed' || (i.isConfirmed && i.needsBuggy)).length;

        slotParticipants.add(_toParticipant(host, memberHandicaps, buggyQueue, buggyCapacity, confirmedBuggyCount, hcConfig));

        for (var guest in hostGuests) {
           final guestUniqueId = '${host.registration.memberId}_${guest.name}';
           if (!processedUniqueIds.contains(guestUniqueId)) {
              slotParticipants.add(_toParticipant(guest, memberHandicaps, buggyQueue, buggyCapacity, confirmedBuggyCount, hcConfig));
              processedUniqueIds.add(guestUniqueId);
           }
        }
        
        slots.add(_TeeSlot(players: slotParticipants));
      } else {
        // Standalone guest handling (fallback)
        final guestUniqueId = '${golfer.registration.memberId}_${golfer.name}';
        if (!processedUniqueIds.contains(guestUniqueId)) {
           final availableBuggies = event.availableBuggies ?? 0;
           final buggyCapacity = availableBuggies * 2;
           final buggyQueue = participants.where((i) => i.needsBuggy).toList();
           final confirmedBuggyCount = participants.where((i) => 
             i.buggyStatusOverride == 'confirmed' || (i.isConfirmed && i.needsBuggy)).length;
             
           slots.add(_TeeSlot(players: [_toParticipant(golfer, memberHandicaps, buggyQueue, buggyCapacity, confirmedBuggyCount, hcConfig)]));
           processedUniqueIds.add(guestUniqueId);
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

    // [PHASE 42] Auto-assign one random captain to each group
    final rand = Random();
    for (var group in groups) {
      if (group.players.isNotEmpty) {
        final captainIdx = rand.nextInt(group.players.length);
        for (int i = 0; i < group.players.length; i++) {
          group.players[i].isCaptain = (i == captainIdx);
        }
      }
    }

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
    bool hasSocietyCut = false;
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
       hasSocietyCut = societyCut != 0;
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
      hasSocietyCut: hasSocietyCut,
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
          hasSocietyCut: societyCut != 0,
        );
      }
    }

    return {
      ...event.grouping,
      'groups': groups.map((g) => g.toJson()).toList(),
    };
  }

  /// Automatically fills available slots in existing groups with players from the pool.
  /// Returns the updated list of groups.
  static List<TeeGroup> autoFillVacancies({
    required List<TeeGroup> groups,
    required List<TeeGroupParticipant> pool,
    int maxGroupSize = 4,
  }) {
    if (pool.isEmpty) return groups;
    
    final newGroups = groups.map((g) => g.copyWith(players: List<TeeGroupParticipant>.from(g.players))).toList();
    final remainingPool = List<TeeGroupParticipant>.from(pool);

    for (var group in newGroups) {
      while (group.players.length < maxGroupSize && remainingPool.isNotEmpty) {
        group.players.add(remainingPool.removeAt(0));
      }
      if (remainingPool.isEmpty) break;
    }

    return newGroups;
  }

  /// Calculates which confirmed players are missing from the given groups.
  static List<TeeGroupParticipant> getUnassignedPlayers({
    required GolfEvent event,
    required List<TeeGroup> groups,
    required Map<String, double> memberHandicaps,
    CompetitionRules? rules,
    required bool useWhs,
    required Map<String, double> manualCuts,
    CourseConfig? courseConfig,
  }) {
    final assignedIds = groups
        .expand((g) => g.players)
        .map((p) => '${p.registrationMemberId}|${p.isGuest}')
        .toSet();

    final unassigned = <TeeGroupParticipant>[];
    int rollingConfirmedCount = 0;
    final capacity = event.maxParticipants ?? 999;
    final isClosed = event.isRegistrationClosed;

    final hcConfig = _HandicapContext(
      rules: rules,
      courseConfig: courseConfig ?? event.courseConfig,
      useWhs: useWhs,
      manualCuts: manualCuts,
    );

    for (final item in RegistrationLogic.getSortedItems(event)) {
      final status = RegistrationLogic.calculateStatus(
        isGuest: item.isGuest,
        isConfirmed: item.isConfirmed,
        hasPaid: item.hasPaid,
        capacity: capacity,
        confirmedCount: rollingConfirmedCount,
        isEventClosed: isClosed,
        statusOverride: item.statusOverride,
      );

      if (status == RegistrationStatus.confirmed) {
        rollingConfirmedCount++;
        final playerId = '${item.registration.memberId}|${item.isGuest}';
        
        if (!assignedIds.contains(playerId)) {
          unassigned.add(_toParticipant(
            item, 
            memberHandicaps, 
            [], // No buggy queue needed for simple unassigned check
            0, 
            0, 
            hcConfig,
          ));
        }
      }
    }
    return unassigned;
  }

  /// Handles a withdrawal by updating registrations and backfilling grouping if locked.
  /// Returns a result containing the updated GolfEvent and any promoted player IDs.
  static WithdrawalResult handleWithdrawal({
    required GolfEvent event,
    required String memberId,
    required bool isGuest,
    required List<Member> allMembers,
    required bool useWhs,
    CompetitionRules? rules,
  }) {
    String? promotedId;
    final regs = event.registrations.where((r) => r.memberId == memberId).toList();
    if (regs.isEmpty) throw 'Member not found';
    final playerName = regs.first.memberName;
    // 1. Update Registration List
    final newList = List<EventRegistration>.from(event.registrations);
    final idx = newList.indexWhere((r) => r.memberId == memberId);
    if (idx != -1) {
      final reg = newList[idx];
      if (isGuest) {
        newList[idx] = reg.copyWith(
          guestName: null, // Effective withdrawal for simplicity in this mock
          guestIsConfirmed: false,
        );
      } else {
        newList[idx] = reg.copyWith(
          attendingGolf: false,
          statusOverride: 'withdrawn',
        );
      }
    }

    var updatedEvent = event.copyWith(registrations: newList);

    // 2. If grouping is locked, handle the group vacancy
    final bool isLocked = event.grouping['locked'] ?? false;
    if (isLocked) {
      final groupsData = event.grouping['groups'] as List?;
      if (groupsData != null) {
        var groups = groupsData.map((g) => TeeGroup.fromJson(g)).toList();
        final playerId = '$memberId|$isGuest';

        // Remove from group
        for (var group in groups) {
          group.players.removeWhere((p) => '${p.registrationMemberId}|${p.isGuest}' == playerId);
        }

        // Calculate Pool (Waitlist promotions happen implicitly via getUnassignedPlayers/RegistrationLogic)
        final pool = getUnassignedPlayers(
          event: updatedEvent, 
          groups: groups, 
          memberHandicaps: {for (var m in allMembers) m.id: m.handicap}, 
          rules: rules,
          useWhs: useWhs, 
          manualCuts: event.manualCuts,
        );

        // Auto-Fill
        final poolBefore = List<TeeGroupParticipant>.from(pool);
        groups = autoFillVacancies(groups: groups, pool: pool);
        
        // Identify if someone was promoted
        if (poolBefore.isNotEmpty && poolBefore.length > pool.length) {
            // This logic is simplified; in a production app we'd compare the lists
            promotedId = poolBefore.first.registrationMemberId;
        }

        updatedEvent = updatedEvent.copyWith(
          grouping: {
            ...updatedEvent.grouping,
            'groups': groups.map((g) => g.toJson()).toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      }
    }

    return WithdrawalResult(event: updatedEvent, promotedPlayerId: promotedId, playerName: playerName);
  }
}

class WithdrawalResult {
  final GolfEvent event;
  final String? promotedPlayerId;
  final String playerName;
  WithdrawalResult({required this.event, this.promotedPlayerId, required this.playerName});
}

class _HandicapContext {
  final CompetitionRules? rules;
  final CourseConfig courseConfig;
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
