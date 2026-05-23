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
    MemberStatus selectedStatus = currentStatus;

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Update Member Status',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          final spacing = Theme.of(context).extension<AppSpacingTokens>();
          final cardGap = spacing?.cardToCard ?? AppSpacing.atomic;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildStatusOption(context, MemberStatus.member, selectedStatus, (val) {
                onStatusSelected(val);
                setModalState(() => selectedStatus = val);
              }, cardGap),
              buildStatusOption(context, MemberStatus.pending, selectedStatus, (val) {
                onStatusSelected(val);
                setModalState(() => selectedStatus = val);
              }, cardGap),
              buildStatusOption(context, MemberStatus.suspended, selectedStatus, (val) {
                onStatusSelected(val);
                setModalState(() => selectedStatus = val);
              }, cardGap),
              buildStatusOption(context, MemberStatus.expired, selectedStatus, (val) {
                onStatusSelected(val);
                setModalState(() => selectedStatus = val);
              }, cardGap),
              buildStatusOption(context, MemberStatus.left, selectedStatus, (val) {
                onStatusSelected(val);
                setModalState(() => selectedStatus = val);
              }, cardGap),
              buildStatusOption(context, MemberStatus.archived, selectedStatus, (val) {
                onStatusSelected(val);
                setModalState(() => selectedStatus = val);
              }, cardGap),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  static Widget buildStatusOption(
    BuildContext context,
    MemberStatus status,
    MemberStatus currentStatus,
    ValueChanged<MemberStatus> onStatusSelected,
    double cardGap, {
    VoidCallback? onDeselect,
  }) {
    final isSelected = currentStatus == status;
    final label = (status == MemberStatus.member || status == MemberStatus.active)
        ? 'Active'
        : status.displayName;

    return BoxyArtSelectCard(
      icon: _statusIcon(status),
      label: label,
      description: _statusDescription(status),
      isSelected: isSelected,
      onTap: () => onStatusSelected(status),
      onDeselect: onDeselect,
      cardGap: cardGap,
    );
  }

  static String _statusDescription(MemberStatus status) {
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

  static IconData _statusIcon(MemberStatus status) {
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
