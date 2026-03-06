// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditActivity _$AuditActivityFromJson(Map<String, dynamic> json) =>
    _AuditActivity(
      id: json['id'] as String,
      message: json['message'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      relatedId: json['relatedId'] as String?,
    );

Map<String, dynamic> _$AuditActivityToJson(_AuditActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'userId': instance.userId,
      'userName': instance.userName,
      'relatedId': instance.relatedId,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.registration: 'registration',
  ActivityType.score: 'score',
  ActivityType.event: 'event',
  ActivityType.payment: 'payment',
  ActivityType.other: 'other',
};
