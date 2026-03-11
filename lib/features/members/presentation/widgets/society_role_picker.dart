import 'package:golf_society/design_system/design_system.dart';

class SocietyRolePicker extends StatelessWidget {
  final String? currentRole;
  final ValueChanged<String> onRoleSelected;

  const SocietyRolePicker({
    super.key,
    required this.currentRole,
    required this.onRoleSelected,
  });

  static void show(BuildContext context, String? currentRole, ValueChanged<String> onRoleSelected) {
    final defaultRoles = ['President', 'Captain', 'Vice Captain', 'Secretary', 'Treasurer'];
    
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Select Society Position',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...defaultRoles.map((r) => _buildSocietyRoleOption(context, r, currentRole, onRoleSelected)),
          const SizedBox(height: AppSpacing.sm),
          
          // Custom Role Action Tile
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _showCustomRoleDialog(context, onRoleSelected);
            },
            child: BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityLow),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded, color: Theme.of(context).primaryColor, size: AppShapes.iconMd),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Text(
                    'Create Custom Role',
                    style: TextStyle(
                      fontWeight: AppTypography.weightBlack,
                      fontSize: AppTypography.sizeBody,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is now primarily used via its static show method
    return const SizedBox.shrink();
  }

  static Widget _buildSocietyRoleOption(
    BuildContext context, 
    String role, 
    String? currentRole, 
    ValueChanged<String> onRoleSelected
  ) {
    final isSelected = currentRole == role;
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () {
          onRoleSelected(role);
          Navigator.pop(context);
        },
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: 16,
          border: isSelected ? Border.fromBorderSide(BorderSide(color: primary, width: AppShapes.borderMedium)) : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  role,
                  style: TextStyle(
                    fontWeight: AppTypography.weightBlack,
                    fontSize: AppTypography.sizeBody,
                    letterSpacing: -0.3,
                    color: isSelected ? primary : null,
                  ),
                ),
              ),
              if (isSelected) 
                Icon(Icons.check_circle_rounded, color: primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  static void _showCustomRoleDialog(BuildContext context, ValueChanged<String> onRoleSelected) {
    final controller = TextEditingController();
    showBoxyArtDialog(
      context: context,
      title: 'New Role',
      content: BoxyArtFormField(
        label: 'Role Title',
        hintText: 'e.g. Tour Manager',
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: AppTypography.weightBold)),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              onRoleSelected(controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: Text('Save', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: AppTypography.weightBold)),
        ),
      ],
    );
  }
}
