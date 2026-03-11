import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';

class MemberRolePicker extends StatelessWidget {
  final MemberRole currentRole;
  final ValueChanged<MemberRole> onRoleSelected;

  const MemberRolePicker({
    super.key,
    required this.currentRole,
    required this.onRoleSelected,
  });

  static void show(BuildContext context, MemberRole currentRole, ValueChanged<MemberRole> onRoleSelected) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Assign Role',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...MemberRole.values.map((role) => _buildRolePickerOption(context, role, currentRole, onRoleSelected)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is now primarily used via its static show method
    return const SizedBox.shrink();
  }

  static Widget _buildRolePickerOption(
    BuildContext context, 
    MemberRole role, 
    MemberRole currentRole, 
    ValueChanged<MemberRole> onRoleSelected
  ) {
    final isSelected = currentRole == role;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        onRoleSelected(role);
        Navigator.pop(context);
      },
      child: BoxyArtCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        border: isSelected ? Border.all(color: theme.primaryColor, width: AppShapes.borderMedium) : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor.withValues(alpha: AppColors.opacityLow) : AppColors.dark100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(role),
                color: isSelected ? theme.primaryColor : AppColors.textSecondary,
                size: AppShapes.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRoleDisplayName(role),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTypography.weightBold,
                      color: isSelected ? theme.primaryColor : Colors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  Text(
                    _getRoleDescription(role),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.dark600,
                      fontSize: AppTypography.sizeLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }


  static String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Admin';
      case MemberRole.restrictedAdmin: return 'Restricted Admin';
      case MemberRole.viewer: return 'Viewer';
      case MemberRole.member: return 'Standard Member';
    }
  }

  static String _getRoleDescription(MemberRole role) {
     switch (role) {
      case MemberRole.superAdmin: return 'Full access to all system features.';
      case MemberRole.admin: return 'Manage members, events, and results.';
      case MemberRole.restrictedAdmin: return 'Limited management rights.';
      case MemberRole.viewer: return 'Read-only access to all data.';
      case MemberRole.member: return 'Standard app access.';
    }
  }

  static IconData _getRoleIcon(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return Icons.admin_panel_settings;
      case MemberRole.admin: return Icons.security;
      case MemberRole.restrictedAdmin: return Icons.build_circle_outlined;
      case MemberRole.viewer: return Icons.visibility_outlined;
      case MemberRole.member: return Icons.person_outline;
    }
  }
}
