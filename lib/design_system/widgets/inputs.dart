import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            hintStyle: AppTypography.body.copyWith(
              color: isDark ? AppColors.dark400 : AppColors.dark300,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
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
class BoxyArtDatePickerField extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
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
              border: config.useBorders 
                  ? Border.all(
                      color: isDark ? AppColors.dark500 : AppColors.lightBorder, 
                      width: config.borderWidth,
                    )
                  : null,
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
                  style: AppTypography.helper.copyWith(
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

/// A standardized 3.1 settings row with a boxed icon and a switch.
class BoxyArtSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final Color iconColor;
  final ValueChanged<bool> onChanged;

  const BoxyArtSwitchTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.iconColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Boxed Icon (Standard 44x44)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Switch
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
      ),
    );
  }
}

/// A standardized 3.1 settings row with a boxed icon that navigates.
class BoxyArtNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const BoxyArtNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Boxed Icon (Standard 44x44)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.label.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded, 
              color: isDark ? AppColors.dark400 : AppColors.dark200, 
              size: 14,
            ),
          ],
        ),
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
class BoxyArtDropdownField<T> extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
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
            border: config.useBorders 
                ? Border.all(
                    color: isDark ? AppColors.dark500 : AppColors.lightBorder, 
                    width: config.borderWidth,
                  )
                : null,
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
