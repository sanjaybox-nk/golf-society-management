
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// Standard branded input field for Fairway v3.1.
class BoxyArtInputField extends ConsumerWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final bool readOnly;
  final FocusNode? focusNode;
  final Color? labelColor;
  final Color? textColor;
  final String? subtitle;
  final bool isSeamless;
  final String? suffixText;

  const BoxyArtInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.focusNode,
    this.labelColor,
    this.textColor,
    this.subtitle,
    this.isSeamless = false,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);

    final radius = config.inputRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.labelToCard),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBold,
                color: labelColor ?? theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                letterSpacing: 1.0,
              ),
            ),
          ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.labelToCard),
            child: Text(
              subtitle!,
              style: AppTypography.helper.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          focusNode: focusNode,
          style: AppTypography.body.copyWith(
            color: textColor ?? theme.colorScheme.onSurface,
            fontSize: AppTypography.sizeBody,
            fontWeight: AppTypography.weightMedium,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: AppTypography.sizeBody,
            ),
            filled: !isSeamless,
            fillColor: theme.colorScheme.surface,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon ?? (suffixText != null 
              ? Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg, top: 14), 
                  child: Text(
                    suffixText!.toUpperCase(), 
                    style: AppTypography.micro.copyWith(
                      fontWeight: AppTypography.weightBold,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                )
              : null),
            border: isSeamless ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                width: config.borderWidth,
              ),
            ),
            enabledBorder: isSeamless ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                width: config.borderWidth,
              ),
            ),
            focusedBorder: isSeamless ? InputBorder.none : OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: config.borderWidth * 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSeamless ? 0 : AppSpacing.lg, 
              vertical: isSeamless ? 8 : 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Legacy alias for BoxyArtInputField.
class BoxyArtFormField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final dynamic prefixIcon;
  final dynamic suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final FocusNode? focusNode;
  final bool readOnly;
  final Color? labelColor;
  final Color? textColor;
  final String? subtitle;
  final String? suffixText;
  final bool isSeamless;

  const BoxyArtFormField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.focusNode,
    this.readOnly = false,
    this.labelColor,
    this.textColor,
    this.subtitle,
    this.suffixText,
    this.isSeamless = false,
  });

  @override
  State<BoxyArtFormField> createState() => _BoxyArtFormFieldState();
}

class _BoxyArtFormFieldState extends State<BoxyArtFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(BoxyArtFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.initialValue != widget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoxyArtInputField(
      label: widget.label,
      hint: widget.hintText,
      controller: _controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      prefixIcon: widget.prefixIcon is IconData ? Icon(widget.prefixIcon) : (widget.prefixIcon as Widget?),
      suffixIcon: widget.suffixIcon is IconData ? Icon(widget.suffixIcon) : (widget.suffixIcon as Widget?),
      onChanged: widget.onChanged,
      validator: widget.validator,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      labelColor: widget.labelColor,
      textColor: widget.textColor,
      subtitle: widget.subtitle,
      suffixText: widget.suffixText,
      isSeamless: widget.isSeamless,
    );
  }
}

/// Legacy alias for BoxyArtInputField with specific naming.
class ModernTextField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final dynamic icon;
  final bool readOnly;
  final FormFieldValidator<String>? validator;
  final bool isSeamless;

  const ModernTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.icon,
    this.readOnly = false,
    this.validator,
    this.isSeamless = false,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller = TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoxyArtInputField(
      label: widget.label,
      controller: _controller,
      hint: widget.hintText,
      onChanged: widget.onChanged,
      prefixIcon: widget.icon is IconData ? Icon(widget.icon) : (widget.icon as Widget?),
      readOnly: widget.readOnly,
      validator: widget.validator,
      isSeamless: widget.isSeamless,
    );
  }
}
