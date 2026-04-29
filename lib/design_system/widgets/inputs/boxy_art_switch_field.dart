
import 'package:golf_society/design_system/design_system.dart';

/// A labeled switch field for Boolean settings.
class BoxyArtSwitchField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? labelColor;
  final Color? subtitleColor;

  const BoxyArtSwitchField({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.labelColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.micro.copyWith(
                    color: labelColor ?? theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                    fontWeight: AppTypography.weightBold,
                    letterSpacing: 1.0,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.helper.copyWith(
                      color: subtitleColor ?? theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.primaryColor,
            activeTrackColor: theme.primaryColor.withValues(alpha: 0.30),
            inactiveThumbColor: isDark ? AppColors.dark300 : AppColors.pureWhite,
            inactiveTrackColor: isDark ? AppColors.dark500.withValues(alpha: AppColors.opacityHalf) : AppColors.dark150,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return theme.primaryColor;
              }
              return isDark ? AppColors.dark150 : AppColors.pureWhite;
            }),
          ),
        ],
      ),
    );
  }
}

/// Legacy alias for a switch row.
class ModernSwitchRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final dynamic icon;
  final ValueChanged<bool>? onChanged;

  const ModernSwitchRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[
              if (icon is IconData)
                Icon(icon, size: AppShapes.iconMd, color: Theme.of(context).primaryColor)
              else
                (icon as Widget),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: BoxyArtSwitchField(
                label: label,
                subtitle: subtitle,
                value: value,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
