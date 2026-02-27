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
    this.buggyStatus = RegistrationStatus.none,
    this.isCaptain = false,
    this.status = RegistrationStatus.confirmed,
  });

  Map<String, dynamic> toJson() => {
    'registrationMemberId': registrationMemberId,
    'name': name,
    'isGuest': isGuest,
    'handicapIndex': handicapIndex,
    'playingHandicap': playingHandicap,
    'needsBuggy': needsBuggy,
    'buggyStatus': buggyStatus.name,
    'isCaptain': isCaptain,
    'status': status.name,
  };

  static TeeGroupParticipant fromJson(Map<String, dynamic> json) => TeeGroupParticipant(
    registrationMemberId: json['registrationMemberId'],
    name: json['name'],
    isGuest: json['isGuest'],
    handicapIndex: (json['handicapIndex'] as num?)?.toDouble() ?? (json['handicap'] as num?)?.toDouble() ?? 0.0,
    playingHandicap: (json['playingHandicap'] as num?)?.toDouble() ?? (json['handicap'] as num?)?.toDouble() ?? 0.0,
    needsBuggy: json['needsBuggy'] ?? false,
    buggyStatus: RegistrationStatus.values.firstWhere(
      (e) => e.name == json['buggyStatus'], 
      orElse: () => (json['needsBuggy'] ?? false) ? RegistrationStatus.confirmed : RegistrationStatus.none,
    ),
    isCaptain: json['isCaptain'] ?? false,
    status: RegistrationStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => RegistrationStatus.confirmed,
    ),
  );
}
