// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distribution_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DistributionList _$DistributionListFromJson(Map<String, dynamic> json) =>
    _DistributionList(
      id: json['id'] as String,
      name: json['name'] as String,
      memberIds: (json['memberIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isDynamic: json['isDynamic'] as bool? ?? false,
      filterCriteria:
          (json['filterCriteria'] as List<dynamic>?)
              ?.map(
                (e) => AudienceFilterRule.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DistributionListToJson(_DistributionList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'memberIds': instance.memberIds,
      'isDynamic': instance.isDynamic,
      'filterCriteria': instance.filterCriteria.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
