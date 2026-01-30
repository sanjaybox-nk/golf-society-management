// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventRegistration _$EventRegistrationFromJson(Map<String, dynamic> json) =>
    _EventRegistration(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      isGuest: json['isGuest'] as bool? ?? false,
      attendingGolf: json['attendingGolf'] as bool? ?? true,
      attendingBreakfast: json['attendingBreakfast'] as bool? ?? false,
      attendingLunch: json['attendingLunch'] as bool? ?? false,
      attendingDinner: json['attendingDinner'] as bool? ?? false,
      hasPaid: json['hasPaid'] as bool? ?? false,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      needsBuggy: json['needsBuggy'] as bool? ?? false,
      dietaryRequirements: json['dietaryRequirements'] as String?,
      specialNeeds: json['specialNeeds'] as String?,
      guestName: json['guestName'] as String?,
      guestHandicap: json['guestHandicap'] as String?,
      guestAttendingBreakfast:
          json['guestAttendingBreakfast'] as bool? ?? false,
      guestAttendingLunch: json['guestAttendingLunch'] as bool? ?? false,
      guestAttendingDinner: json['guestAttendingDinner'] as bool? ?? false,
      guestNeedsBuggy: json['guestNeedsBuggy'] as bool? ?? false,
      isCaptain: json['isCaptain'] as bool? ?? false,
      registeredAt: const OptionalTimestampConverter().fromJson(
        json['registeredAt'],
      ),
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      guestIsConfirmed: json['guestIsConfirmed'] as bool? ?? false,
      statusOverride: json['statusOverride'] as String?,
      buggyStatusOverride: json['buggyStatusOverride'] as String?,
      guestBuggyStatusOverride: json['guestBuggyStatusOverride'] as String?,
      history:
          (json['history'] as List<dynamic>?)
              ?.map(
                (e) =>
                    RegistrationHistoryItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventRegistrationToJson(_EventRegistration instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'isGuest': instance.isGuest,
      'attendingGolf': instance.attendingGolf,
      'attendingBreakfast': instance.attendingBreakfast,
      'attendingLunch': instance.attendingLunch,
      'attendingDinner': instance.attendingDinner,
      'hasPaid': instance.hasPaid,
      'cost': instance.cost,
      'needsBuggy': instance.needsBuggy,
      'dietaryRequirements': instance.dietaryRequirements,
      'specialNeeds': instance.specialNeeds,
      'guestName': instance.guestName,
      'guestHandicap': instance.guestHandicap,
      'guestAttendingBreakfast': instance.guestAttendingBreakfast,
      'guestAttendingLunch': instance.guestAttendingLunch,
      'guestAttendingDinner': instance.guestAttendingDinner,
      'guestNeedsBuggy': instance.guestNeedsBuggy,
      'isCaptain': instance.isCaptain,
      'registeredAt': const OptionalTimestampConverter().toJson(
        instance.registeredAt,
      ),
      'isConfirmed': instance.isConfirmed,
      'guestIsConfirmed': instance.guestIsConfirmed,
      'statusOverride': instance.statusOverride,
      'buggyStatusOverride': instance.buggyStatusOverride,
      'guestBuggyStatusOverride': instance.guestBuggyStatusOverride,
      'history': instance.history?.map((e) => e.toJson()).toList(),
    };

_RegistrationHistoryItem _$RegistrationHistoryItemFromJson(
  Map<String, dynamic> json,
) => _RegistrationHistoryItem(
  timestamp: DateTime.parse(json['timestamp'] as String),
  action: json['action'] as String,
  description: json['description'] as String,
  actor: json['actor'] as String?,
);

Map<String, dynamic> _$RegistrationHistoryItemToJson(
  _RegistrationHistoryItem instance,
) => <String, dynamic>{
  'timestamp': instance.timestamp.toIso8601String(),
  'action': instance.action,
  'description': instance.description,
  'actor': instance.actor,
};
