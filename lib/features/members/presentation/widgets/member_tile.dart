import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/notifications/domain/notification_broadcast_service.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../profile_provider.dart';
import '../members_provider.dart';
import 'member_status_picker.dart';

class MemberTile extends ConsumerWidget {
  final Member member;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool showFeeStatus;
  final String? secondaryMetricLabel; 
  final String? secondaryMetricValue;
  final bool isAdminContext;
  final bool isEventPaymentContext;
  final VoidCallback? onFeeToggle;

  const MemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.showFeeStatus = false,
    this.isEventPaymentContext = false,
    this.onFeeToggle,
    this.secondaryMetricLabel,
    this.secondaryMetricValue,
    this.isAdminContext = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
    
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser.role == MemberRole.admin || currentUser.role == MemberRole.superAdmin;
    final canSeeFees = isAdmin && showFeeStatus;

    return BoxyArtCard(
      onTap: onTap ?? () => context.pushNamed(
        isAdminContext ? 'admin-member-detail' : 'member-detail', 
        pathParameters: {'id': member.id},
      ),
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left Section: Avatar & Since
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BoxyArtAvatar(
                      url: member.avatarUrl,
                      initials: '${member.firstName.isNotEmpty ? member.firstName[0] : ''}${member.lastName.isNotEmpty ? member.lastName[0] : ''}',
                      radius: 40,
                      isCircle: true,
                    ),
                    if (member.joinedDate != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Since ${member.joinedDate!.year}',
                        style: AppTypography.micro.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                        ),
                      ),
                    ],
                  ],
                ),

                // 2. Vertical Divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
                ),

                // 3. Right Section: Information Stack
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3a. Top half: Name, Status, Roles
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Member Name
                          Text(
                            toTitleCase('${member.firstName} ${member.lastName}'),
                            style: AppTypography.memberName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Status Indicator Row (with green pipe) & Fee Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: isAdminContext ? () {
                                  MemberStatusPicker.show(context, member.status, (newStatus) {
                                    ref.read(membersRepositoryProvider).updateMember(
                                      member.copyWith(status: newStatus),
                                    );
                                  });
                                } : null,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: member.status == MemberStatus.active 
                                            ? theme.colorScheme.primary 
                                            : AppColors.amber500,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      member.status.displayName,
                                      style: AppTypography.label.copyWith(
                                        color: member.status == MemberStatus.active 
                                            ? theme.colorScheme.primary 
                                            : AppColors.amber500,
                                        fontWeight: AppTypography.weightStrong,
                                      ),
                                    ),
                                    if (isAdminContext) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: (member.status == MemberStatus.active 
                                            ? theme.colorScheme.primary 
                                            : AppColors.amber500).withValues(alpha: 0.7),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (canSeeFees)
                                BoxyArtFeePill(
                                  isPaid: member.hasPaid,
                                  onToggle: onFeeToggle ?? () {
                                    final repo = ref.read(membersRepositoryProvider);
                                    repo.updateMember(member.copyWith(hasPaid: !member.hasPaid));
                                  },
                                ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Role Pills
                          if (member.societyRole?.isNotEmpty == true || (isAdminContext && member.role != MemberRole.member))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: 4,
                                children: [
                                  if (member.societyRole?.isNotEmpty == true)
                                    BoxyArtPill.committee(
                                      label: member.societyRole!,
                                    ),
                                  if (isAdminContext && member.role != MemberRole.member)
                                    BoxyArtPill(
                                      label: member.role.displayName,
                                      color: StatusColors.neutral,
                                      hasHorizontalMargin: false,
                                    ),
                                  if (member.renewalStatus != MemberRenewalStatus.none && isAdmin)
                                    BoxyArtPill(
                                      label: 'RENEWAL REQUESTED',
                                      color: StatusColors.warning,
                                      hasHorizontalMargin: false,
                                    ),
                                  
                                  // Nudge Status / Action
                                  if (config.isRenewalActive && 
                                      member.renewalStatus == MemberRenewalStatus.none && 
                                      member.status != MemberStatus.suspended &&
                                      isAdminContext)
                                    member.lastNudgedAt != null && 
                                    DateTime.now().difference(member.lastNudgedAt!).inHours < 24
                                    ? const BoxyArtPill(
                                        label: 'NUDGED',
                                        color: StatusColors.neutral,
                                        hasHorizontalMargin: false,
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          final repo = ref.read(membersRepositoryProvider);
                                          final messenger = ref.read(renewalNudgeServiceProvider);
                                          
                                          await repo.nudgeMember(member.id);
                                          await messenger.sendRenewalNudge(member: member);
                                          
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Nudge sent successfully!'))
                                            );
                                          }
                                        },
                                        child: BoxyArtPill(
                                          label: 'NUDGE',
                                          color: theme.colorScheme.primary,
                                          icon: Icons.notifications_active_outlined,
                                          hasHorizontalMargin: false,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const Spacer(),

                      // 3b. Bottom half: Stats Row
                      Padding(
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            BoxyArtPill.hc(
                              label: member.handicap.toStringAsFixed(1),
                              hasHorizontalMargin: false,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              width: 1,
                              height: 10,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${secondaryMetricLabel ?? 'Events'} ',
                                      style: AppTypography.label.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    secondaryMetricValue ?? '0',
                                    style: AppTypography.label.copyWith(
                                      fontWeight: AppTypography.weightHeavy,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Admin Action Button (Top Right)
          if (isAdmin && isAdminContext)
            Positioned(
              top: -AppSpacing.sm,
              right: -AppSpacing.sm,
              child: Icon(
                Icons.more_horiz_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
              ),
            ),

        ],
      ),
    );
  }

}
