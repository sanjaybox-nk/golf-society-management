import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/member_group_config.dart';
import 'package:golf_society/domain/groups/member_group_helper.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../members_provider.dart';
import '../profile_provider.dart';

/// The primary tile for member listings in the roster.
/// Refactored to use the unified [BoxyArtMemberRow] engine for Design 4.x.
class MemberTile extends ConsumerWidget {
  final Member member;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool showFeeStatus;
  final bool isAdminContext;
  final bool isEventPaymentContext;
  final VoidCallback? onFeeToggle;
  final MemberGroupConfig? memberGroupConfig;

  const MemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.showFeeStatus = false,
    this.isEventPaymentContext = false,
    this.onFeeToggle,
    this.isAdminContext = false,
    this.memberGroupConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser.role.hasAdminAccess;
    final canSeeFees = isAdmin && showFeeStatus;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final leadingWidth = constraints.maxWidth * 0.30;
        return BoxyArtMemberRow(
      name: member.displayName,
      initials: (member.firstName.isNotEmpty ? member.firstName[0] : '') + (member.lastName.isNotEmpty ? member.lastName[0] : ''),
      avatarUrl: member.avatarUrl,
      handicapIndex: member.handicap,
      secondaryName: _secondaryLabel(member, isAdminContext),
      secondaryNameColor: isAdminContext ? _statusAlertColor(member.status) : null,
      onTap: onTap ?? () => context.pushNamed(
        isAdminContext ? 'admin-member-detail' : 'member-detail',
        pathParameters: {'id': member.id},
      ),
      isSelected: false,
      useCard: true,
      showChevron: true,
      showVerticalDivider: true,
      isFoundingMember: member.isFoundingMember,

      leading: SizedBox(
        width: leadingWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                BoxyArtAvatar(
                  url: member.avatarUrl,
                  initials: (member.firstName.isNotEmpty ? member.firstName[0] : '') + (member.lastName.isNotEmpty ? member.lastName[0] : ''),
                  radius: 32,
                  isCircle: true,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                ),
              ],
            ),
            if (member.joinedDate != null) ...[
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  'Since ${member.joinedDate!.year}',
                  style: AppTypography.micro.copyWith(
                    color: theme.brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      
      footer: (memberGroupConfig != null || canSeeFees) ? Row(
        children: [
          if (memberGroupConfig != null)
            Builder(builder: (context) {
              final group = MemberGroupHelper.groupForMember(member, memberGroupConfig);
              if (group == null) return const SizedBox.shrink();
              final isFirst = memberGroupConfig!.groups.isNotEmpty &&
                  group.id == memberGroupConfig!.groups.first.id;
              return BoxyArtIndicator(
                label: group.name,
                dotColor: isFirst ? AppColors.lime500 : AppColors.amber500,
                hasHorizontalMargin: false,
              );
            }),
          const Spacer(),
          if (canSeeFees)
            BoxyArtFeePill(
              isPaid: member.hasPaid,
              hasHorizontalMargin: false,
              onToggle: onFeeToggle ?? () {
                final repo = ref.read(membersRepositoryProvider);
                final nextPaidState = !member.hasPaid;
                final newStatus = nextPaidState && (member.status == MemberStatus.expired || member.status == MemberStatus.gracePeriod)
                    ? MemberStatus.member
                    : member.status;
                repo.updateMember(member.copyWith(
                  hasPaid: nextPaidState,
                  status: newStatus,
                ));
              },
            ),
        ],
      ) : null,

      trailing: trailing,
        );
      },
    );
  }
}

Color? _statusAlertColor(MemberStatus status) {
  switch (status) {
    case MemberStatus.expired:
    case MemberStatus.suspended:
      return AppColors.coral500;
    case MemberStatus.pending:
      return AppColors.amber500;
    default:
      return null;
  }
}

String? _secondaryLabel(Member member, bool isAdmin) {
  const activeStatuses = {MemberStatus.active, MemberStatus.member};
  final isSocial = member.role == MemberRole.socialMember || member.status == MemberStatus.social;
  final role = member.societyRole?.isNotEmpty == true ? member.societyRole! : null;
  final statusLabel = isAdmin && !activeStatuses.contains(member.status) && !isSocial
      ? member.status.displayName
      : null;

  final parts = [
    ?statusLabel,
    if (isSocial) 'Social Member',
    ?role,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}
