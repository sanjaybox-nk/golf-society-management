import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/member_group_config.dart';

class MemberGroupHelper {
  MemberGroupHelper._();

  static String? assignGroupId(Member member, MemberGroupConfig? config) {
    if (config == null || config.groups.isEmpty) return null;

    switch (config.splitType) {
      case GroupSplitType.handicap:
        final threshold = config.handicapThreshold ?? 12.0;
        final isFirst = config.voluntaryFirstGroupMemberIds.contains(member.id) ||
            member.handicap <= threshold;
        return isFirst ? config.groups.first.id : config.groups.last.id;

      case GroupSplitType.gender:
        final gender = member.gender?.toLowerCase() ?? '';
        for (final group in config.groups) {
          if (group.id.toLowerCase() == gender ||
              group.name.toLowerCase() == gender) {
            return group.id;
          }
        }
        return null;

      case GroupSplitType.custom:
        for (final group in config.groups) {
          if (group.manualMemberIds.contains(member.id)) return group.id;
        }
        return null;
    }
  }

  static MemberGroup? groupForMember(Member member, MemberGroupConfig? config) {
    final id = assignGroupId(member, config);
    if (id == null || config == null) return null;
    try {
      return config.groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  static bool memberBelongsToGroup(
    String memberId,
    String groupId,
    MemberGroupConfig config,
    List<Member> members,
  ) {
    final member = members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) return false;
    return assignGroupId(member, config) == groupId;
  }
}
