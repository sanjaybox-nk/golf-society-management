
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A labeled date picker field wrapper.
class BoxyArtDatePickerField extends ConsumerWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool readOnly;
  final Color? labelColor;
  final Color? textColor;
  final Color? iconColor;
  final IconData icon;

  const BoxyArtDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.readOnly = false,
    this.labelColor,
    this.textColor,
    this.iconColor,
    this.icon = Icons.calendar_today_rounded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
    final radius = config.inputRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.labelToCard),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold,
              color: labelColor ?? theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
        InkWell(
          onTap: readOnly ? null : onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, 
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                width: config.borderWidth,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTypography.body.copyWith(
                      color: textColor ?? theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeBody,
                      fontWeight: AppTypography.weightMedium,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: AppShapes.iconMd,
                  color: iconColor ?? theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
