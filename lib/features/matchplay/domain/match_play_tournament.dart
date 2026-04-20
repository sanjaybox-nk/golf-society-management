import 'match_definition.dart';

enum TournamentType { knockout, singleRound, divisionsPlusKnockout }

enum SeedingType { random, seeded }

class MatchPlayEntrant {
  final String id;
  final List<String> playerIds; // 1 for Singles, 2 for Pairs
  final String name; // Custom name for the pair/entrant
  final double? qualifyingScore; // For seeding
  final int? seed; // Fixed seed position

  const MatchPlayEntrant({
    required this.id,
    required this.playerIds,
    this.name = '',
    this.qualifyingScore,
    this.seed,
  });

  MatchPlayEntrant copyWith({
    String? id,
    List<String>? playerIds,
    String? name,
    double? qualifyingScore,
    int? seed,
  }) {
    return MatchPlayEntrant(
      id: id ?? this.id,
      playerIds: playerIds ?? this.playerIds,
      name: name ?? this.name,
      qualifyingScore: qualifyingScore ?? this.qualifyingScore,
      seed: seed ?? this.seed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'playerIds': playerIds,
    'name': name,
    'qualifyingScore': qualifyingScore,
    'seed': seed,
  };

  factory MatchPlayEntrant.fromJson(Map<String, dynamic> json) {
    return MatchPlayEntrant(
      id: json['id'] as String,
      playerIds: List<String>.from(json['playerIds'] as List),
      name: json['name'] as String? ?? '',
      qualifyingScore: (json['qualifyingScore'] as num?)?.toDouble(),
      seed: json['seed'] as int?,
    );
  }
}

class MatchPlayTournament {
  final String id;
  final String name;
  final TournamentType type;
  final SeedingType seedingType;
  final List<MatchPlayEntrant> entrants;
  final Map<String, List<String>> divisions; // DivisionID -> EntrantIDs
  final int promotionCount; // Number of promos per division
  final List<MatchDefinition> matches;
  final Map<MatchRoundType, DateTime> roundCutoffs;
  final bool isPublished;
  final DateTime createdAt;

  const MatchPlayTournament({
    required this.id,
    required this.name,
    this.type = TournamentType.knockout,
    this.seedingType = SeedingType.random,
    this.entrants = const [],
    this.divisions = const {},
    this.promotionCount = 2,
    this.matches = const [],
    this.roundCutoffs = const {},
    this.isPublished = false,
    required this.createdAt,
  });

  MatchPlayTournament copyWith({
    String? id,
    String? name,
    TournamentType? type,
    SeedingType? seedingType,
    List<MatchPlayEntrant>? entrants,
    Map<String, List<String>>? divisions,
    int? promotionCount,
    List<MatchDefinition>? matches,
    Map<MatchRoundType, DateTime>? roundCutoffs,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return MatchPlayTournament(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      seedingType: seedingType ?? this.seedingType,
      entrants: entrants ?? this.entrants,
      divisions: divisions ?? this.divisions,
      promotionCount: promotionCount ?? this.promotionCount,
      matches: matches ?? this.matches,
      roundCutoffs: roundCutoffs ?? this.roundCutoffs,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'seedingType': seedingType.index,
    'entrants': entrants.map((e) => e.toJson()).toList(),
    'divisions': divisions,
    'promotionCount': promotionCount,
    'matches': matches.map((m) => m.toJson()).toList(),
    'roundCutoffs': roundCutoffs.map((k, v) => MapEntry(k.name, v.toIso8601String())),
    'isPublished': isPublished,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MatchPlayTournament.fromJson(Map<String, dynamic> json) {
    return MatchPlayTournament(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TournamentType.values[json['type'] as int? ?? 0],
      seedingType: SeedingType.values[json['seedingType'] as int? ?? 0],
      entrants: (json['entrants'] as List? ?? [])
          .map((e) => MatchPlayEntrant.fromJson(e as Map<String, dynamic>))
          .toList(),
      divisions: (json['divisions'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, List<String>.from(v))),
      promotionCount: json['promotionCount'] as int? ?? 2,
      matches: (json['matches'] as List? ?? [])
          .map((m) => MatchDefinition.fromJson(m as Map<String, dynamic>))
          .toList(),
      roundCutoffs: (json['roundCutoffs'] as Map? ?? {}).map((k, v) => MapEntry(
        MatchRoundType.values.firstWhere((e) => e.name == k),
        DateTime.parse(v as String),
      )),
      isPublished: json['isPublished'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
