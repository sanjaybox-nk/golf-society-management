// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_group_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberGroup _$MemberGroupFromJson(Map<String, dynamic> json) => _MemberGroup(
  id: json['id'] as String,
  name: json['name'] as String,
  manualMemberIds:
      (json['manualMemberIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$MemberGroupToJson(_MemberGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'manualMemberIds': instance.manualMemberIds,
    };

_MemberGroupConfig _$MemberGroupConfigFromJson(Map<String, dynamic> json) =>
    _MemberGroupConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      splitType:
          $enumDecodeNullable(_$GroupSplitTypeEnumMap, json['splitType']) ??
          GroupSplitType.handicap,
      handicapThreshold: (json['handicapThreshold'] as num?)?.toDouble(),
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map((e) => MemberGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      voluntaryFirstGroupMemberIds:
          (json['voluntaryFirstGroupMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MemberGroupConfigToJson(_MemberGroupConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'splitType': _$GroupSplitTypeEnumMap[instance.splitType]!,
      'handicapThreshold': instance.handicapThreshold,
      'groups': instance.groups.map((e) => e.toJson()).toList(),
      'voluntaryFirstGroupMemberIds': instance.voluntaryFirstGroupMemberIds,
    };

const _$GroupSplitTypeEnumMap = {
  GroupSplitType.handicap: 'handicap',
  GroupSplitType.gender: 'gender',
  GroupSplitType.custom: 'custom',
};
