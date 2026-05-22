import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/theme/theme_controller.dart';
import 'package:golf_society/features/admin/application/admin_action_service.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';


enum RenewalFilter { pending, renewing, paid }

class SelectedMemberIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void remove(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    }
  }

  void clear() => state = {};
}

final selectedMemberIdsProvider = NotifierProvider<SelectedMemberIdsNotifier, Set<String>>(
  SelectedMemberIdsNotifier.new,
);

class RenewalController extends Notifier<void> {
  @override
  void build() {}

  Future<void> processRenewals({
    required List<Member> members,
    required Set<String> selectedIds,
    required Future<void> Function() onComplete,
  }) async {
    final selectedMembers = members.where((m) => selectedIds.contains(m.id)).toList();
    if (selectedMembers.isEmpty) return;

    final repository = ref.read(membersRepositoryProvider);
    
    for (final member in selectedMembers) {
      Member updatedMember = member;

      final isUpgradingToFull = _isSocialMember(member) &&
          ref.read(socialUpgradeIdsProvider).contains(member.id);

      switch (member.renewalStatus) {
        case MemberRenewalStatus.renew:
          updatedMember = member.copyWith(
            status: MemberStatus.active,
            role: isUpgradingToFull ? MemberRole.member : member.role,
            joinedDate: DateTime.now(),
            renewalStatus: MemberRenewalStatus.none,
          );
          break;
        case MemberRenewalStatus.suspend:
          updatedMember = member.copyWith(
            status: MemberStatus.suspended,
            renewalStatus: MemberRenewalStatus.none,
          );
          break;
        case MemberRenewalStatus.leave:
          updatedMember = member.copyWith(
            status: MemberStatus.left,
            renewalStatus: MemberRenewalStatus.none,
          );
          break;
        case MemberRenewalStatus.none:
          break;
      }

      await repository.updateMember(updatedMember);
    }

    ref.read(selectedMemberIdsProvider.notifier).clear();
    ref.read(socialUpgradeIdsProvider.notifier).clear();
    await onComplete();
  }

  Future<void> nudgeMember(Member member) async {
    await ref.read(adminActionServiceProvider).nudgeMember(
      member: member,
      reason: 'Membership Payment',
    );
  }

  Future<void> togglePaidStatus(Member member) async {
    final newPaidStatus = !member.hasPaid;
    await ref.read(membersRepositoryProvider).updateMember(
      member.copyWith(hasPaid: newPaidStatus),
    );
    if (newPaidStatus) {
      ref.read(selectedMemberIdsProvider.notifier).remove(member.id);
    }
  }
}

final renewalControllerProvider = NotifierProvider<RenewalController, void>(
  RenewalController.new,
);

/// Tracks which social members have the upgrade-to-full toggle on
class SocialUpgradeIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void clear() => state = {};
}

final socialUpgradeIdsProvider = NotifierProvider<SocialUpgradeIdsNotifier, Set<String>>(
  SocialUpgradeIdsNotifier.new,
);

bool _isSocialMember(Member m) =>
    m.role == MemberRole.socialMember || m.status == MemberStatus.social;

/// Provider for filtered members
final renewalFilteredMembersProvider = Provider.autoDispose.family<List<Member>, ({RenewalFilter filter, String search})>((ref, arg) {
  final membersAsync = ref.watch(allMembersProvider);
  final config = ref.watch(themeControllerProvider);
  final socialRenewalOpen = config.socialRenewalOpen;

  return membersAsync.maybeWhen(
    data: (members) {
      // 1. Tab filtering
      List<Member> displayMembers;
      switch (arg.filter) {
        case RenewalFilter.renewing:
          displayMembers = members.where((m) => m.renewalStatus == MemberRenewalStatus.renew && !m.hasPaid).toList();
          break;
        case RenewalFilter.paid:
          displayMembers = members.where((m) => m.renewalStatus == MemberRenewalStatus.renew && m.hasPaid).toList();
          break;
        case RenewalFilter.pending:
          displayMembers = members.where((m) => m.renewalStatus == MemberRenewalStatus.none).toList();
          break;
      }

      // 2. Gate social members unless socialRenewalOpen
      if (!socialRenewalOpen) {
        displayMembers = displayMembers.where((m) => !_isSocialMember(m)).toList();
      }

      // 3. Search filtering
      if (arg.search.isNotEmpty) {
        final query = arg.search.toLowerCase();
        displayMembers = displayMembers.where((m) {
          final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
          return name.contains(query);
        }).toList();
      }

      return displayMembers;
    },
    orElse: () => [],
  );
});
