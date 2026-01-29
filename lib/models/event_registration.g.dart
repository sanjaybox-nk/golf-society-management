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
      attendingDinner: json['attendingDinner'] as bool? ?? false,
      hasPaid: json['hasPaid'] as bool? ?? false,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      needsBuggy: json['needsBuggy'] as bool? ?? false,
      dietaryRequirements: json['dietaryRequirements'] as String?,
      specialNeeds: json['specialNeeds'] as String?,
      guestName: json['guestName'] as String?,
      guestHandicap: json['guestHandicap'] as String?,
      guestAttendingDinner: json['guestAttendingDinner'] as bool? ?? false,
      guestNeedsBuggy: json['guestNeedsBuggy'] as bool? ?? false,
      isCaptain: json['isCaptain'] as bool? ?? false,
      registeredAt: const OptionalTimestampConverter().fromJson(
        json['registeredAt'],
      ),
      statusOverride: json['statusOverride'] as String?,
      buggyStatusOverride: json['buggyStatusOverride'] as String?,
      guestBuggyStatusOverride: json['guestBuggyStatusOverride'] as String?,
    );

Map<String, dynamic> _$EventRegistrationToJson(_EventRegistration instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'isGuest': instance.isGuest,
      'attendingGolf': instance.attendingGolf,
      'attendingDinner': instance.attendingDinner,
      'hasPaid': instance.hasPaid,
      'cost': instance.cost,
      'needsBuggy': instance.needsBuggy,
      'dietaryRequirements': instance.dietaryRequirements,
      'specialNeeds': instance.specialNeeds,
      'guestName': instance.guestName,
      'guestHandicap': instance.guestHandicap,
      'guestAttendingDinner': instance.guestAttendingDinner,
      'guestNeedsBuggy': instance.guestNeedsBuggy,
      'isCaptain': instance.isCaptain,
      'registeredAt': const OptionalTimestampConverter().toJson(
        instance.registeredAt,
      ),
      'statusOverride': instance.statusOverride,
      'buggyStatusOverride': instance.buggyStatusOverride,
      'guestBuggyStatusOverride': instance.guestBuggyStatusOverride,
    };
