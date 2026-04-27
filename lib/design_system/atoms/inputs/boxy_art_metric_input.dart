import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A premium, high-density input row for numerical metrics.
/// 
/// Standardized for Design 4.x administrative settings screens.
/// Features a right-aligned metric value within a themed "pocket".
class BoxyArtMetricInput extends ConsumerStatefulWidget {
  final String label;
  final String? subtitle;
  final String value;
  final String suffixText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final double pocketWidth;

  const BoxyArtMetricInput({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.suffixText,
    required this.onChanged,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.pocketWidth = 140,
  });

  @override
  ConsumerState<BoxyArtMetricInput> createState() => _BoxyArtMetricInputState();
}

class _BoxyArtMetricInputState extends ConsumerState<BoxyArtMetricInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(BoxyArtMetricInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
      // Maintain cursor position at the end
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTypography.micro.copyWith(
                  fontWeight: AppTypography.weightBold,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                  letterSpacing: 1.0,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.dark300 : AppColors.dark400,
                    fontWeight: AppTypography.weightMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),

        // Value "Pocket" Section
        Container(
          width: widget.pocketWidth,
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark600 : AppColors.lightHeader,
            borderRadius: BorderRadius.circular(config.inputRadius),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            textAlign: TextAlign.right,
            style: AppTypography.metricValue.copyWith(
              color: isDark ? AppColors.pureWhite : AppColors.dark950,
              fontSize: 22,
              fontWeight: AppTypography.weightHeavy,
            ),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              suffixText: widget.suffixText,
              suffixStyle: AppTypography.metricLabel.copyWith(
                color: isDark ? AppColors.dark400 : AppColors.dark300,
              ),
              isDense: true,
              // Thin focused indicator as per user request
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5, // Thin selected indicator
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
