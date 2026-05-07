// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuestProfile _$GuestProfileFromJson(Map<String, dynamic> json) =>
    _GuestProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      handicap: (json['handicap'] as num?)?.toDouble() ?? 28.0,
      firstPlayedAt: const OptionalTimestampConverter().fromJson(
        json['firstPlayedAt'],
      ),
      lastPlayedAt: const OptionalTimestampConverter().fromJson(
        json['lastPlayedAt'],
      ),
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GuestProfileToJson(_GuestProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'handicap': instance.handicap,
      'firstPlayedAt': const OptionalTimestampConverter().toJson(
        instance.firstPlayedAt,
      ),
      'lastPlayedAt': const OptionalTimestampConverter().toJson(
        instance.lastPlayedAt,
      ),
      'eventCount': instance.eventCount,
    };
