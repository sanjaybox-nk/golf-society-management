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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SocietyRolePicker(
        currentRole: currentRole,
        onRoleSelected: onRoleSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultRoles = ['President', 'Captain', 'Vice Captain', 'Secretary', 'Treasurer'];
    final theme = Theme.of(context);
    final primarySize = 20.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rPill)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l, vertical: AppSpacing.x3l),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Society Position',
              style: TextStyle(
                fontSize: primarySize,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...defaultRoles.map((r) => _buildSocietyRoleOption(context, r)),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Custom Role Action Tile
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showCustomRoleDialog(context);
                      },
                      child: BoxyArtCard(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: AppColors.opacityLow),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_rounded, color: theme.primaryColor, size: AppShapes.iconMd),
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
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSocietyRoleOption(BuildContext context, String role) {
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

  void _showCustomRoleDialog(BuildContext context) {
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
