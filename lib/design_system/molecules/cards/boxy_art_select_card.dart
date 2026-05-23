import 'package:golf_society/design_system/design_system.dart';

/// A selectable option card for pickers and bottom-sheet selectors.
/// Uses design-system tokens for all colour, shape, and spacing — responds
/// to Design Lab settings automatically.
class BoxyArtSelectCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeselect;
  final double cardGap;

  const BoxyArtSelectCard({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    required this.isSelected,
    this.onTap,
    this.onDeselect,
    this.cardGap = AppSpacing.atomic,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BoxyArtCard(
      margin: EdgeInsets.only(bottom: cardGap),
      isHighlighted: isSelected,
      onTap: isSelected && onDeselect != null ? onDeselect : onTap,
      child: Row(
        children: [
          BoxyArtIconBadge(
            icon: icon,
            isPrimary: isSelected,
            iconColor: isSelected ? AppColors.pureWhite : null,
          ),
          const SizedBox(width: AppSpacing.standard),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: AppShapes.iconLg),
        ],
      ),
    );
  }
}
