// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audience_filter_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AudienceFilterRule _$AudienceFilterRuleFromJson(Map<String, dynamic> json) =>
    _AudienceFilterRule(
      property: $enumDecode(_$AudiencePropertyEnumMap, json['property']),
      operator: $enumDecode(_$FilterOperatorEnumMap, json['operator']),
      value: json['value'] as String,
    );

Map<String, dynamic> _$AudienceFilterRuleToJson(_AudienceFilterRule instance) =>
    <String, dynamic>{
      'property': _$AudiencePropertyEnumMap[instance.property]!,
      'operator': _$FilterOperatorEnumMap[instance.operator]!,
      'value': instance.value,
    };

const _$AudiencePropertyEnumMap = {
  AudienceProperty.membershipStatus: 'membershipStatus',
  AudienceProperty.handicapIndex: 'handicapIndex',
  AudienceProperty.debtBalance: 'debtBalance',
  AudienceProperty.registrationStatus: 'registrationStatus',
};

const _$FilterOperatorEnumMap = {
  FilterOperator.equals: 'equals',
  FilterOperator.notEquals: 'notEquals',
  FilterOperator.greaterThan: 'greaterThan',
  FilterOperator.lessThan: 'lessThan',
  FilterOperator.contains: 'contains',
};
