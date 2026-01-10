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
    };
