import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../profile_provider.dart';
import '../members_provider.dart';

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
    
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser.role == MemberRole.admin || currentUser.role == MemberRole.superAdmin;
    final canSeeFees = isAdmin && showFeeStatus;
    
    // Design 4.1: Collapsible Action Column
    // Reclaim 80px space for the middle column if no actions are present
    final hasActionContent = (isAdmin && isAdminContext) || 
                             (member.societyRole?.isNotEmpty == true) || 
                             canSeeFees;

    return BoxyArtCard(
      onTap: onTap ?? () => context.pushNamed(
        isAdminContext ? 'admin-member-detail' : 'member-detail', 
        pathParameters: {'id': member.id},
      ),
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(AppSpacing.large),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Enable vertical anchoring
          children: [
            // 1. Left Section: Identity (Avatar)
            SizedBox(
              width: 68, // Widened to allow for 64px circular avatar
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BoxyArtAvatar(
                    url: member.avatarUrl,
                    initials: '${member.firstName.isNotEmpty ? member.firstName[0] : ''}${member.lastName.isNotEmpty ? member.lastName[0] : ''}',
                    radius: 32,
                    isCircle: true,
                  ),
                  if (member.joinedDate != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      child: Text(
                        'Since ${member.joinedDate!.year}',
                        style: AppTypography.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16), // Whitespace divider

            // 2. Middle Section: Information (Flexible)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Member Name
                  Text(
                    toTitleCase('${member.firstName} ${member.lastName}'),
                    style: AppTypography.memberName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Status Indicator Row (with pipe)
                  // Design 4.1: Status by Exception - Hide for Active members to reduce visual noise
                  if (member.status != MemberStatus.active && member.status != MemberStatus.member) ...[
                    Row(
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
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Stats Row
                  Row(
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
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${secondaryMetricLabel ?? 'Events'} ',
                                style: AppTypography.micro.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                                ),
                              ),
                              TextSpan(
                                text: secondaryMetricValue ?? '0',
                                style: AppTypography.caption.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Right Section: Action/Status (Collapsible)
            if (hasActionContent) ...[
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 80, // Fixed width for action anchoring
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Top Right: Admin Icon or Role
                    if (isAdmin && isAdminContext)
                      Icon(
                        Icons.more_horiz_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                      )
                    else if (member.societyRole?.isNotEmpty == true)
                      BoxyArtPill.committee(
                        label: member.societyRole!,
                      ),
                    
                    // Bottom Right: Fee Pill (RENEWAL tag hidden by preference)
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
              ),
            ],
          ],
        ),
      ),
    );
  }

}
