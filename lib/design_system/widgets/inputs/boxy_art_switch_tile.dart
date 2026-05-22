
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A standardized 3.1 settings row with a boxed icon and a switch.
class BoxyArtSwitchTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BoxyArtSwitchTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Boxed Icon (Standard 4.x via BoxyArtIconBadge)
          BoxyArtIconBadge(
            icon: icon,
          ),
          const SizedBox(width: AppSpacing.lg),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...[
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.labelStrong.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: AppTypography.weightBold,
                      fontSize: AppTypography.sizeLabel,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.micro.copyWith(
                        color: isDark ? AppColors.dark200 : AppColors.dark400,
                        fontWeight: AppTypography.weightMedium,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.primaryColor,
            activeTrackColor: theme.primaryColor.withValues(alpha: 0.25),
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
