
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A standardized branded slider for configuration controls.
class BoxyArtSlider extends ConsumerWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double> onChanged;
  final Color? color;
  final bool isNeutral;

  const BoxyArtSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.color,
    this.isNeutral = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    
    // Design 4.x: Preference for monochromatic neutral in admin contexts
    final Color primary = color ?? (isNeutral 
      ? (isDark ? AppColors.dark150 : AppColors.dark300)
      : theme.primaryColor);
      
    final Color inactiveColor = isNeutral
      ? (isDark ? AppColors.dark500 : AppColors.dark150)
      : primary.withValues(alpha: AppColors.opacityLow);
    
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: primary,
        inactiveTrackColor: inactiveColor,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        trackHeight: config.sliderTrackHeight,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: config.sliderThumbRadius),
        overlayShape: RoundSliderOverlayShape(overlayRadius: config.sliderThumbRadius * 2),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: TextStyle(
          color: isNeutral ? (isDark ? AppColors.dark900 : AppColors.pureWhite) : AppColors.actionText, 
          fontWeight: AppTypography.weightBold,
          fontSize: AppTypography.sizeLabel,
        ),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }
}
