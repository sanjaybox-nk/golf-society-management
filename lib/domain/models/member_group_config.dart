import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_group_config.freezed.dart';
part 'member_group_config.g.dart';

enum GroupSplitType { handicap, gender, custom }

@freezed
abstract class MemberGroup with _$MemberGroup {
  const factory MemberGroup({
    required String id,
    required String name,
    @Default([]) List<String> manualMemberIds,
  }) = _MemberGroup;

  factory MemberGroup.fromJson(Map<String, dynamic> json) =>
      _$MemberGroupFromJson(json);
}

@freezed
abstract class MemberGroupConfig with _$MemberGroupConfig {
  const factory MemberGroupConfig({
    required String id,
    required String name,
    @Default(GroupSplitType.handicap) GroupSplitType splitType,
    double? handicapThreshold,
    @Default([]) List<MemberGroup> groups,
    @Default([]) List<String> voluntaryFirstGroupMemberIds,
  }) = _MemberGroupConfig;

  factory MemberGroupConfig.fromJson(Map<String, dynamic> json) =>
      _$MemberGroupConfigFromJson(json);
}
