import '../../features/events/domain/registration_logic.dart';

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

  TeeGroup copyWith({
    int? index,
    DateTime? teeTime,
    List<TeeGroupParticipant>? players,
  }) => TeeGroup(
    index: index ?? this.index,
    teeTime: teeTime ?? this.teeTime,
    players: players ?? this.players,
  );
  
  static TeeGroup fromJson(Map<String, dynamic> json) => TeeGroup(
    index: json['index'],
    teeTime: DateTime.parse(json['teeTime']),
    players: (json['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList(),
  );

  double get totalHandicap => players.fold(0, (sum, p) => sum + p.playingHandicap);
}

class TeeGroupParticipant {
  final String registrationMemberId; // Host member ID
  final String name;
  final bool isGuest;
  final double handicapIndex;     // The raw index (e.g. 33.2)
  final double playingHandicap;   // The adjusted/capped value (e.g. 28.0)
  String? teeName;                // [NEW] Snapshotted/Overridden tee (Mutable for local admin overrides)
  bool needsBuggy;
  RegistrationStatus buggyStatus;
  bool isCaptain;
  RegistrationStatus status;
  
  TeeGroupParticipant({
    required this.registrationMemberId,
    required this.name,
    required this.isGuest,
    required this.handicapIndex,
    required this.playingHandicap,
    required this.needsBuggy,
    this.teeName,
    this.buggyStatus = RegistrationStatus.none,
    this.isCaptain = false,
    this.hasSocietyCut = false,
    this.status = RegistrationStatus.confirmed,
  });

  final bool hasSocietyCut;

  Map<String, dynamic> toJson() => {
    'registrationMemberId': registrationMemberId,
    'name': name,
    'isGuest': isGuest,
    'handicapIndex': handicapIndex,
    'playingHandicap': playingHandicap,
    'teeName': teeName,
    'needsBuggy': needsBuggy,
    'buggyStatus': buggyStatus.name,
    'isCaptain': isCaptain,
    'hasSocietyCut': hasSocietyCut,
    'status': status.name,
  };

  static TeeGroupParticipant fromJson(Map<String, dynamic> json) => TeeGroupParticipant(
    registrationMemberId: json['registrationMemberId'],
    name: json['name'],
    isGuest: json['isGuest'],
    handicapIndex: (json['handicapIndex'] as num?)?.toDouble() ?? (json['handicap'] as num?)?.toDouble() ?? 0.0,
    playingHandicap: (json['playingHandicap'] as num?)?.toDouble() ?? (json['handicap'] as num?)?.toDouble() ?? 0.0,
    teeName: json['teeName'] as String?,
    needsBuggy: json['needsBuggy'] ?? false,
    buggyStatus: RegistrationStatus.values.firstWhere(
      (e) => e.name == json['buggyStatus'], 
      orElse: () => (json['needsBuggy'] ?? false) ? RegistrationStatus.confirmed : RegistrationStatus.none,
    ),
    isCaptain: json['isCaptain'] ?? false,
    hasSocietyCut: json['hasSocietyCut'] ?? false,
    status: RegistrationStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => RegistrationStatus.confirmed,
    ),
  );

  TeeGroupParticipant copyWith({
    String? registrationMemberId,
    String? name,
    bool? isGuest,
    double? handicapIndex,
    double? playingHandicap,
    String? teeName,
    bool? needsBuggy,
    RegistrationStatus? buggyStatus,
    bool? isCaptain,
    bool? hasSocietyCut,
    RegistrationStatus? status,
  }) => TeeGroupParticipant(
    registrationMemberId: registrationMemberId ?? this.registrationMemberId,
    name: name ?? this.name,
    isGuest: isGuest ?? this.isGuest,
    handicapIndex: handicapIndex ?? this.handicapIndex,
    playingHandicap: playingHandicap ?? this.playingHandicap,
    teeName: teeName ?? this.teeName,
    needsBuggy: needsBuggy ?? this.needsBuggy,
    buggyStatus: buggyStatus ?? this.buggyStatus,
    isCaptain: isCaptain ?? this.isCaptain,
    hasSocietyCut: hasSocietyCut ?? this.hasSocietyCut,
    status: status ?? this.status,
  );
}
