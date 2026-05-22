// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'division_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DivisionConfig _$DivisionConfigFromJson(Map<String, dynamic> json) =>
    _DivisionConfig(
      threshold: (json['threshold'] as num?)?.toDouble() ?? 12.0,
      genderSeparated: json['genderSeparated'] as bool? ?? false,
      voluntaryDiv1MemberIds:
          (json['voluntaryDiv1MemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DivisionConfigToJson(_DivisionConfig instance) =>
    <String, dynamic>{
      'threshold': instance.threshold,
      'genderSeparated': instance.genderSeparated,
      'voluntaryDiv1MemberIds': instance.voluntaryDiv1MemberIds,
    };
