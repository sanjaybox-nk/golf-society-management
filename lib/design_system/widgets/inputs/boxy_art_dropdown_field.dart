
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A labeled dropdown field for selecting from a list of options.
class BoxyArtDropdownField<T> extends ConsumerWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final Widget? prefixIcon;
  final double? menuMaxHeight;
  final double? width;

  const BoxyArtDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.menuMaxHeight = 400,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
    final radius = config.inputRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.labelToCard),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBold,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
        SizedBox(
          width: width,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            onChanged: onChanged,
            items: items,
            dropdownColor: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(radius),
            isExpanded: true,
            menuMaxHeight: menuMaxHeight,
            style: AppTypography.body.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: AppTypography.sizeBody,
              fontWeight: AppTypography.weightRegular,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: AppTypography.sizeBody,
              ),
              prefixIcon: prefixIcon,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: AppShapes.borderThin,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: config.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: config.borderWidth * 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, 
                vertical: 12,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
