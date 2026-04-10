import 'package:flutter/material.dart';
import '../../../../../design_system/design_system.dart';

class BoxyArtThemeModeTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const BoxyArtThemeModeTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.standard,
        ),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: icon,
              color: isSelected ? theme.primaryColor : theme.dividerColor.withValues(alpha: AppColors.opacitySubtle),
              isTinted: true,
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Text(
                title,
                style: AppTypography.cardTitle.copyWith(
                  color: isSelected ? theme.primaryColor : null,
                  fontWeight: isSelected ? AppTypography.weightHeavy : AppTypography.weightMedium,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
