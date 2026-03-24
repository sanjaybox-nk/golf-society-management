import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/handicap_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../member_details_modal.dart';
import '../profile_provider.dart';

class MemberTile extends ConsumerWidget {
  final Member member;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool showFeeStatus;
  final String? secondaryMetricLabel; 
  final String? secondaryMetricValue;
  final bool isAdminContext;

  const MemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.showFeeStatus = false,
    this.secondaryMetricLabel,
    this.secondaryMetricValue,
    this.isAdminContext = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
    final primary = theme.colorScheme.primary;
    
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser.role == MemberRole.admin || currentUser.role == MemberRole.superAdmin;
    final canSeeFees = isAdmin && showFeeStatus;

    return BoxyArtCard(
      onTap: onTap ?? () => MemberDetailsModal.show(context, member, isAdminContext: isAdminContext),
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
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
                height: 104,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
              ),

              // 3. Right Section: Information Stack
              Expanded(
                child: SizedBox(
                  height: 104, // Total height to match identity block
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
                            style: AppTypography.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Status Indicator Row (with green pipe)
                          Row(
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
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Role Pills
                          if (member.societyRole?.isNotEmpty == true || (isAdmin && member.role != MemberRole.member))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: 4,
                                children: [
                                  if (member.societyRole?.isNotEmpty == true)
                                    BoxyArtPill(
                                      label: member.societyRole!,
                                      color: Color(config.iconBadgeFillColor),
                                      textColor: Color(config.iconBadgeIconColor),
                                      hasHorizontalMargin: false,
                                    ),
                                  if (isAdmin && member.role != MemberRole.member)
                                    BoxyArtPill(
                                      label: toTitleCase(member.role.name),
                                      color: StatusColors.neutral,
                                      hasHorizontalMargin: false,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const Spacer(),

                      // 3b. Bottom half: Stats Row
                      Padding(
                        padding: EdgeInsets.only(right: canSeeFees ? 85 : 0), // Leave room for Fee Paid
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
                            Flexible(
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
              ),
            ],
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

          // 5. Bottom Right: Admin Status (Fee Paid)
          if (canSeeFees)
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    member.hasPaid ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: member.hasPaid ? Color(config.iconBadgeIconColor) : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Fee Paid',
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightStrong,
                      color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.headline,
        ),
      ],
    );
  }

}
