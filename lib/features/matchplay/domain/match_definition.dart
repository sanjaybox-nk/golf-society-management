enum MatchType { singles, fourball, foursomes, scramble }

enum MatchRoundType { group, roundOf32, roundOf16, quarterFinal, semiFinal, finalRound }

class MatchDefinition {
  final String id;
  final MatchType type;
  final List<String> team1Ids; // Player IDs for Side A
  final List<String> team2Ids; // Player IDs for Side B
  final Map<String, int> strokesReceived; // Map<PlayerID, Strokes> relative to scratch/lowest
  final int? strokesGiven; // Total strokes given/received in this match
  final double? adjustment; // Any handicap adjustment applied
  final String? groupId; // Optional link to TeeGroup
  final bool isBye; // If true, one team gets a walkover

  // Bracket / Season Data
  final MatchRoundType round;
  final String? bracketId; // ID of the tournament/bracket
  final String? nextMatchId; // ID of the match winner advances to
  final int? bracketOrder; // Visual ordering index

  // Override Labels (optional)
  final String? team1Name; // e.g., "Team Europe" or "Names calculated"
  final String? team2Name;
  final MatchResult? manualResult; // Administrative override

  const MatchDefinition({
    required this.id,
    required this.type,
    required this.team1Ids,
    required this.team2Ids,
    this.strokesReceived = const {},
    this.strokesGiven,
    this.adjustment,
    this.groupId,
    this.isBye = false,
    this.round = MatchRoundType.group,
    this.bracketId,
    this.nextMatchId,
    this.bracketOrder,
    this.team1Name,
    this.team2Name,
    this.manualResult,
  });

  // Convenience getters for single matches
  String? get playerAId => team1Ids.isNotEmpty ? team1Ids.first : null;
  String? get playerBId => team2Ids.isNotEmpty ? team2Ids.first : null;
  String get playerAName => team1Name ?? 'Player A';
  String get playerBName => team2Name ?? 'Player B';

  MatchDefinition copyWith({
    String? id,
    MatchType? type,
    List<String>? team1Ids,
    List<String>? team2Ids,
    Map<String, int>? strokesReceived,
    int? strokesGiven,
    double? adjustment,
    String? groupId,
    bool? isBye,
    MatchRoundType? round,
    String? bracketId,
    String? nextMatchId,
    int? bracketOrder,
    String? team1Name,
    String? team2Name,
    MatchResult? manualResult,
  }) {
    return MatchDefinition(
      id: id ?? this.id,
      type: type ?? this.type,
      team1Ids: team1Ids ?? this.team1Ids,
      team2Ids: team2Ids ?? this.team2Ids,
      strokesReceived: strokesReceived ?? this.strokesReceived,
      strokesGiven: strokesGiven ?? this.strokesGiven,
      adjustment: adjustment ?? this.adjustment,
      groupId: groupId ?? this.groupId,
      isBye: isBye ?? this.isBye,
      round: round ?? this.round,
      bracketId: bracketId ?? this.bracketId,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      bracketOrder: bracketOrder ?? this.bracketOrder,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      manualResult: manualResult ?? this.manualResult,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'team1Ids': team1Ids,
    'team2Ids': team2Ids,
    'strokesReceived': strokesReceived,
    'strokesGiven': strokesGiven,
    'adjustment': adjustment,
    'groupId': groupId,
    'isBye': isBye,
    'round': round.index,
    'bracketId': bracketId,
    'nextMatchId': nextMatchId,
    'bracketOrder': bracketOrder,
    'team1Name': team1Name,
    'team2Name': team2Name,
    'manualResult': manualResult?.toJson(),
  };

  factory MatchDefinition.fromJson(Map<String, dynamic> json) {
    MatchType type;
    final dynamic rawType = json['type'];
    if (rawType is int) {
      type = MatchType.values[rawType.clamp(0, MatchType.values.length - 1)];
    } else if (rawType is String) {
      final idx = int.tryParse(rawType);
      if (idx != null) {
        type = MatchType.values[idx.clamp(0, MatchType.values.length - 1)];
      } else {
        type = MatchType.values.firstWhere((e) => e.name == rawType, orElse: () => MatchType.singles);
      }
    } else {
      type = MatchType.singles;
    }

    MatchRoundType round;
    final dynamic rawRound = json['round'];
    if (rawRound is int) {
      round = MatchRoundType.values[rawRound.clamp(0, MatchRoundType.values.length - 1)];
    } else if (rawRound is String) {
      final idx = int.tryParse(rawRound);
      if (idx != null) {
        round = MatchRoundType.values[idx.clamp(0, MatchRoundType.values.length - 1)];
      } else {
        round = MatchRoundType.values.firstWhere((e) => e.name == rawRound, orElse: () => MatchRoundType.group);
      }
    } else {
      round = MatchRoundType.group;
    }

    return MatchDefinition(
      id: json['id'] as String,
      type: type,
      team1Ids: List<String>.from(json['team1Ids'] as List? ?? []),
      team2Ids: List<String>.from(json['team2Ids'] as List? ?? []),
      strokesReceived: Map<String, int>.from(json['strokesReceived'] ?? {}),
      strokesGiven: json['strokesGiven'] is int ? json['strokesGiven'] as int : (int.tryParse(json['strokesGiven']?.toString() ?? '')),
      adjustment: (json['adjustment'] as num?)?.toDouble(),
      groupId: json['groupId']?.toString(),
      isBye: json['isBye'] as bool? ?? false,
      round: round,
      bracketId: json['bracketId'] as String?,
      nextMatchId: json['nextMatchId'] as String?,
      bracketOrder: json['bracketOrder'] is int ? json['bracketOrder'] as int : (int.tryParse(json['bracketOrder']?.toString() ?? '')),
      team1Name: json['team1Name'] as String?,
      team2Name: json['team2Name'] as String?,
      manualResult: json['manualResult'] != null ? MatchResult.fromJson(json['manualResult'] as Map<String, dynamic>) : null,
    );
  }
}

class MatchResult {
  final String matchId;
  final int winningTeamIndex; // 0 = Team 1, 1 = Team 2, -1 = Halve/Draw, -2 = No Result
  final String status; // Display string: "3&2", "1UP", "A/S", "Walkover"
  final int score; // Positive = Team 1 UP, Negative = Team 2 UP
  final List<int> holeResults; // 1 = T1 Win, -1 = T2 Win, 0 = Halve, null = Not Played
  final int holesPlayed;
  final bool isFinal;

  const MatchResult({
    required this.matchId,
    required this.winningTeamIndex,
    required this.status,
    required this.score,
    this.holeResults = const [],
    required this.holesPlayed,
    this.isFinal = false,
  });

  MatchResult copyWith({
    String? matchId,
    int? winningTeamIndex,
    String? status,
    int? score,
    List<int>? holeResults,
    int? holesPlayed,
    bool? isFinal,
  }) {
    return MatchResult(
      matchId: matchId ?? this.matchId,
      winningTeamIndex: winningTeamIndex ?? this.winningTeamIndex,
      status: status ?? this.status,
      score: score ?? this.score,
      holeResults: holeResults ?? this.holeResults,
      holesPlayed: holesPlayed ?? this.holesPlayed,
      isFinal: isFinal ?? this.isFinal,
    );
  }

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'winningTeamIndex': winningTeamIndex,
    'status': status,
    'score': score,
    'holeResults': holeResults,
    'holesPlayed': holesPlayed,
    'isFinal': isFinal,
  };

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      matchId: json['matchId'] as String,
      winningTeamIndex: json['winningTeamIndex'] is int 
          ? json['winningTeamIndex'] as int 
          : (int.tryParse(json['winningTeamIndex']?.toString() ?? '') ?? -2),
      status: json['status'] as String? ?? 'No Result',
      score: json['score'] is int 
          ? json['score'] as int 
          : (int.tryParse(json['score']?.toString() ?? '') ?? 0),
      holeResults: List<int>.from(json['holeResults'] as List? ?? []),
      holesPlayed: json['holesPlayed'] is int 
          ? json['holesPlayed'] as int 
          : (int.tryParse(json['holesPlayed']?.toString() ?? '') ?? 0),
      isFinal: json['isFinal'] as bool? ?? false,
    );
  }
}
