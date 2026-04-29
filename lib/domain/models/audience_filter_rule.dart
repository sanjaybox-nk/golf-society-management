import 'package:freezed_annotation/freezed_annotation.dart';

part 'audience_filter_rule.freezed.dart';
part 'audience_filter_rule.g.dart';

enum AudienceProperty {
  @JsonValue('membershipStatus')
  membershipStatus,
  @JsonValue('handicapIndex')
  handicapIndex,
  @JsonValue('debtBalance')
  debtBalance,
  @JsonValue('registrationStatus')
  registrationStatus,
}

enum FilterOperator {
  @JsonValue('equals')
  equals,
  @JsonValue('notEquals')
  notEquals,
  @JsonValue('greaterThan')
  greaterThan,
  @JsonValue('lessThan')
  lessThan,
  @JsonValue('contains')
  contains,
}

@freezed
abstract class AudienceFilterRule with _$AudienceFilterRule {
  const factory AudienceFilterRule({
    required AudienceProperty property,
    required FilterOperator operator,
    required String value,
  }) = _AudienceFilterRule;

  factory AudienceFilterRule.fromJson(Map<String, dynamic> json) => _$AudienceFilterRuleFromJson(json);
}
