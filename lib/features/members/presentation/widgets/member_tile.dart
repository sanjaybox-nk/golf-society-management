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
              // 1. Left Section: Identity (Avatar Hub)
              SizedBox(
                width: 68,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark800,
                        ),
                      ),
                    ),
                  ],
                  // Relocated Row 4 (Secondary Metric) to Left Column for balance
                  const SizedBox(height: 6),
                  FittedBox(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${secondaryMetricLabel ?? 'Events'} ',
                            style: AppTypography.micro.copyWith(
                              color: theme.brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark800,
                            ),
                          ),
                          TextSpan(
                            text: secondaryMetricValue ?? '0',
                            style: AppTypography.micro.copyWith(
                              color: theme.colorScheme.onSurface,
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
            ),

            const SizedBox(width: 16), // Whitespace divider

            // 2. Middle Section: Information (Flexible)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Row 1: Name (Aligned to top of avatar)
                  const SizedBox(height: 4),
                  Text(
                    member.displayName,
                    style: AppTypography.memberName.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Row 2: Role Pill (Now the primary sub-identity item)
                  if (member.societyRole?.isNotEmpty == true)
                    BoxyArtIndicator(
                      label: member.societyRole!,
                      dotColor: AppColors.amber500,
                      hasHorizontalMargin: false,
                    ),

                  if (member.societyRole?.isNotEmpty == true)
                    const SizedBox(height: 4),

                  BoxyArtIndicator(
                    label: 'HC: ${member.handicap.toStringAsFixed(1)}',
                    dotColor: AppColors.dark400,
                    hasHorizontalMargin: false,
                  ),
                ],
              ),
            ),

            // 3. Right Section: Status & Actions (Flexible stack)
            if (hasActionContent || (member.status != MemberStatus.active && member.status != MemberStatus.member)) ...[
              const SizedBox(width: AppSpacing.md),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 3a: Fee Pill
                  if (canSeeFees) ...[
                    BoxyArtFeePill(
                      isPaid: member.hasPaid,
                      hasHorizontalMargin: false,
                      onToggle: onFeeToggle ?? () {
                        final repo = ref.read(membersRepositoryProvider);
                        final nextPaidState = !member.hasPaid;
                        
                        // Renewal Trigger: Auto-promote Expired/Grace members to Member status when fees are marked as paid
                        final newStatus = nextPaidState && (member.status == MemberStatus.expired || member.status == MemberStatus.gracePeriod)
                            ? MemberStatus.member 
                            : member.status;

                        repo.updateMember(member.copyWith(
                          hasPaid: nextPaidState,
                          status: newStatus,
                        ));
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  // Row 3b: Status Tag (Bottom Right placement)
                  if (member.status != MemberStatus.active && member.status != MemberStatus.member)
                    // Self-Healing UI: Suppress Expiry/Grace tags if the fee has already been paid
                    if (!((member.status == MemberStatus.expired || member.status == MemberStatus.gracePeriod) && member.hasPaid))
                      if (member.status != MemberStatus.expired || isAdminContext)
                        BoxyArtIndicator(
                          label: member.status.displayName,
                          dotColor: member.status.color,
                          hasHorizontalMargin: false,
                        ),
                  
                  // Trailing Widget
                  if (trailing != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    trailing!,
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      );
    }
}
