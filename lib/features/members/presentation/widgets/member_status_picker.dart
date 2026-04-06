import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';

class MemberStatusPicker extends StatelessWidget {
  final MemberStatus currentStatus;
  final ValueChanged<MemberStatus> onStatusSelected;

  const MemberStatusPicker({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  static void show(BuildContext context, MemberStatus currentStatus, ValueChanged<MemberStatus> onStatusSelected) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Update Member Status',
      initialChildSize: 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusPickerOption(context, MemberStatus.member, currentStatus, onStatusSelected),
          _buildStatusPickerOption(context, MemberStatus.pending, currentStatus, onStatusSelected),
          _buildStatusPickerOption(context, MemberStatus.suspended, currentStatus, onStatusSelected),
          _buildStatusPickerOption(context, MemberStatus.expired, currentStatus, onStatusSelected),
          _buildStatusPickerOption(context, MemberStatus.left, currentStatus, onStatusSelected),
          _buildStatusPickerOption(context, MemberStatus.archived, currentStatus, onStatusSelected),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  static Widget _buildStatusPickerOption(
    BuildContext context, 
    MemberStatus status, 
    MemberStatus currentStatus, 
    ValueChanged<MemberStatus> onStatusSelected
  ) {
    final isSelected = currentStatus == status;
    final theme = Theme.of(context);
    
    // Normalize "member" vs "active" for display
    String label = status.displayName;
    if (status == MemberStatus.member || status == MemberStatus.active) {
      label = 'Active';
    }

    return GestureDetector(
      onTap: () {
        onStatusSelected(status);
        Navigator.pop(context);
      },
      child: BoxyArtCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.standard),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard,
          vertical: AppSpacing.md,
        ),
        border: isSelected 
            ? Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1.5) 
            : Border.all(color: AppColors.dark300.withOpacity(0.1), width: 1.0),
        backgroundColor: isSelected 
            ? theme.primaryColor.withOpacity(0.05) 
            : (theme.brightness == Brightness.dark ? AppColors.dark700 : AppColors.pureWhite),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: _getStatusIcon(status),
              color: isSelected ? theme.primaryColor : AppColors.dark150,
              iconColor: isSelected ? theme.primaryColor : (theme.brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark600),
              isTinted: true,
              size: 44,
              iconSize: AppShapes.iconMedium,
            ),
            const SizedBox(width: AppSpacing.standard),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelStrong.copyWith(
                      color: theme.brightness == Brightness.dark ? AppColors.dark60 : AppColors.dark900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getStatusDescription(status),
                    style: AppTypography.label.copyWith(
                      color: theme.brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark400,
                      fontWeight: AppTypography.weightRegular,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) 
              Icon(Icons.check_circle_rounded, color: theme.primaryColor, size: AppShapes.iconLg),
          ],
        ),
      ),
    );
  }

  static String _getStatusDescription(MemberStatus status) {
    switch (status) {
      case MemberStatus.member:
      case MemberStatus.active:
        return 'Standard membership state with full access.';
      case MemberStatus.pending:
        return 'Newly added or awaiting manual verification.';
      case MemberStatus.suspended:
        return 'Membership temporarily disabled for administrative reasons.';
      case MemberStatus.expired:
        return 'Subscription has ended. Requires renewal.';
      case MemberStatus.left:
        return 'Voluntarily resigned from the society.';
      case MemberStatus.archived:
        return 'Historical record for inactive or removed members.';
      default:
        return '';
    }
  }

  static IconData _getStatusIcon(MemberStatus status) {
    switch (status) {
      case MemberStatus.member:
      case MemberStatus.active:
        return Icons.verified_user_rounded;
      case MemberStatus.pending:
        return Icons.assignment_late_rounded;
      case MemberStatus.suspended:
        return Icons.block_rounded;
      case MemberStatus.expired:
        return Icons.timer_off_rounded;
      case MemberStatus.left:
        return Icons.logout_rounded;
      case MemberStatus.archived:
        return Icons.inventory_2_rounded;
      default:
        return Icons.info_outline;
    }
  }
}
