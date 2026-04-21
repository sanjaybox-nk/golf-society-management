import 'package:golf_society/design_system/design_system.dart';

/// A wrapper for Column that automatically adds AppSpacing.lg (16px) between children.
/// This enforces the global vertical rhythm for forms across both Admin and Member suites.
class BoxyArtFormColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const BoxyArtFormColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final themeSpacing = Theme.of(context).extension<AppSpacingTokens>();
    final double gap = spacing ?? themeSpacing?.fieldToField ?? AppSpacing.lg;
    final List<Widget> spacedChildren = [];
    
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: gap));
      }
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

/// A standardized row for Cancel/Save buttons with proper spacing and styling.
class BoxyArtFormActionRow extends StatelessWidget {
  final String saveLabel;
  final String cancelLabel;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;
  final bool isValid;

  const BoxyArtFormActionRow({
    super.key,
    this.saveLabel = 'Save',
    this.cancelLabel = 'Cancel',
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BoxyArtButton(
            title: cancelLabel,
            isSecondary: true,
            onTap: onCancel,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: BoxyArtButton(
            title: saveLabel,
            isLoading: isSaving,
            onTap: isValid ? onSave : null,
          ),
        ),
      ],
    );
  }
}
