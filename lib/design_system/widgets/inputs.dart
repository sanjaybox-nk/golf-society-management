import 'package:flutter/material.dart';
import 'package:golf_society/theme/app_colors.dart';
import 'package:golf_society/theme/app_typography.dart';
import 'package:golf_society/theme/app_shapes.dart';

/// Standard branded input field for Fairway v3.1.
class BoxyArtInputField extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.dark150 : AppColors.dark300,
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
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Legacy alias for BoxyArtInputField.
class BoxyArtFormField extends StatelessWidget {
  final String label;
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

  const BoxyArtFormField({
    super.key,
    required this.label,
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
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtInputField(
      label: label,
      hint: hintText,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon is IconData ? Icon(prefixIcon) : (prefixIcon as Widget?),
      suffixIcon: suffixIcon is IconData ? Icon(suffixIcon) : (suffixIcon as Widget?),
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      focusNode: focusNode,
      readOnly: readOnly,
    );
  }
}

/// Legacy alias for BoxyArtInputField with specific naming.
class ModernTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final dynamic icon;
  final bool readOnly;
  final FormFieldValidator<String>? validator;

  const ModernTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.icon,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtInputField(
      label: label,
      controller: initialValue != null ? TextEditingController(text: initialValue) : null,
      hint: hintText,
      onChanged: onChanged,
      prefixIcon: icon is IconData ? Icon(icon) : (icon as Widget?),
      readOnly: readOnly,
      validator: validator,
    );
  }
}

/// A labeled date picker field wrapper.
class BoxyArtDatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool readOnly;

  const BoxyArtDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.dark150 : AppColors.dark300,
            ),
          ),
        ),
        InkWell(
          onTap: readOnly ? null : onTap,
          borderRadius: BorderRadius.circular(AppShapes.rLg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark600 : AppColors.lightHeader,
              borderRadius: BorderRadius.circular(AppShapes.rLg),
              border: isDark ? null : Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.dark60 : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: isDark ? AppColors.dark200 : AppColors.dark300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A labeled switch field for Boolean settings.
class BoxyArtSwitchField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BoxyArtSwitchField({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.dark150 : const Color(0xFF404040),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.dark300 : AppColors.dark400,
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.lime500,
          activeTrackColor: AppColors.lime500.withValues(alpha: 0.2),
          inactiveThumbColor: AppColors.dark300,
          inactiveTrackColor: AppColors.dark500.withValues(alpha: 0.5),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return isDark ? AppColors.lime500 : AppColors.lime700;
            }
            return isDark ? AppColors.dark150 : AppColors.dark300;
          }),
        ),
      ],
    );
  }
}

/// A standardized branded slider for configuration controls.
class BoxyArtSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double> onChanged;

  const BoxyArtSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1.0,
    this.divisions,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.lime500;
    
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.15),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.actionText, 
          fontWeight: FontWeight.bold,
          fontSize: 12,
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

/// Legacy alias for a switch row.
class ModernSwitchRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final dynamic icon;
  final ValueChanged<bool> onChanged;

  const ModernSwitchRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[
              if (icon is IconData)
                Icon(icon, size: 20, color: AppColors.lime500)
              else
                (icon as Widget),
              const SizedBox(width: 12),
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

/// A labeled dropdown field for selecting from a list of options.
class BoxyArtDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  const BoxyArtDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.dark150 : AppColors.dark300,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark600 : AppColors.lightHeader,
            borderRadius: BorderRadius.circular(AppShapes.rLg),
            border: isDark ? null : Border.all(color: AppColors.lightBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hint != null ? Text(hint!, style: AppTypography.body.copyWith(color: isDark ? AppColors.dark400 : AppColors.dark300)) : null,
              items: items,
              onChanged: onChanged,
              dropdownColor: isDark ? AppColors.dark700 : AppColors.pureWhite,
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.dark60 : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
