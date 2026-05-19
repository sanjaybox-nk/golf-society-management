import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/domain/models/member.dart';
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
  final String? secondaryMetricLabel; 
  final String? secondaryMetricValue;
  final int? eventCount;
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
    this.eventCount,
    this.isAdminContext = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser.role.hasAdminAccess;
    final canSeeFees = isAdmin && showFeeStatus;
    
    return BoxyArtMemberRow(
      name: member.displayName,
      initials: (member.firstName.isNotEmpty ? member.firstName[0] : '') + (member.lastName.isNotEmpty ? member.lastName[0] : ''),
      avatarUrl: member.avatarUrl,
      handicapIndex: member.handicap,
      // Design 4.x: Society roles (Captain, etc.) now integrated into secondary metadata
      secondaryName: member.societyRole?.isNotEmpty == true ? member.societyRole : null,
      onTap: onTap ?? () => context.pushNamed(
        isAdminContext ? 'admin-member-detail' : 'member-detail', 
        pathParameters: {'id': member.id},
      ),
      isSelected: false,
      useCard: true,
      showChevron: true,
      showVerticalDivider: true,
      isFoundingMember: member.isFoundingMember,
      
      // Leading Slot: Preserving roster-specific metrics (Since / Events)
      leading: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BoxyArtAvatar(
              url: member.avatarUrl,
              initials: (member.firstName.isNotEmpty ? member.firstName[0] : '') + (member.lastName.isNotEmpty ? member.lastName[0] : ''),
              radius: 32,
              isCircle: true,
              borderColor: Colors.transparent, 
              borderWidth: 0,
            ),
            if (member.joinedDate != null) ...[
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  'Since ${member.joinedDate!.year}',
                  style: AppTypography.caption.copyWith(
                    color: theme.brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark800,
                    fontSize: 9, 
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4), 
            FittedBox(
              child: Text(
                '${secondaryMetricLabel ?? 'Events'} ${secondaryMetricValue ?? eventCount ?? '0'}',
                style: AppTypography.micro.copyWith(
                  color: theme.brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark800, 
                  fontSize: 10, 
                  fontWeight: AppTypography.weightRegular,
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Footer Slot: Admin Status Pills (Moved here to free up horizontal space for name)
      footer: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          if (isAdminContext && member.status != MemberStatus.active && member.status != MemberStatus.member)
            if (member.status != MemberStatus.expired || isAdminContext)
              Padding(
                padding: EdgeInsets.only(left: canSeeFees ? 8 : 0),
                child: BoxyArtIndicator(
                  label: member.status.displayName,
                  dotColor: member.status.color,
                  hasHorizontalMargin: false,
                ),
              ),
        ],
      ),

      // Trailing Slot: Optional custom trailing widgets
      trailing: trailing,
    );
  }
}
