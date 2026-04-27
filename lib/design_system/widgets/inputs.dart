import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class ModernTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BoxyArtInputField(
      label: label,
      controller: initialValue != null ? TextEditingController(text: initialValue) : null,
      hint: hintText,
      onChanged: onChanged,
      prefixIcon: icon is IconData ? Icon(icon) : (icon as Widget?),
      readOnly: readOnly,
      validator: validator,
      isSeamless: isSeamless,
    );
  }
}

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
            size: 44,
            iconSize: 20,
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
                      style: AppTypography.caption.copyWith(
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

/// A standardized 3.1 settings row with a boxed icon that navigates.
class BoxyArtNavTile extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  const BoxyArtNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.lg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Boxed Icon (Standard 4.x via BoxyArtIconBadge)
            BoxyArtIconBadge(
              icon: icon,
              iconColor: iconColor,
              size: 44,
              iconSize: 22,
            ),
            const SizedBox(width: AppSpacing.lg),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.labelStrong.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: AppTypography.weightBold,
                      fontSize: AppTypography.sizeLabel,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                      fontWeight: AppTypography.weightMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward_ios_rounded, 
              color: isDark ? AppColors.dark400 : AppColors.dark200, 
              size: AppShapes.iconXs,
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

/// A premium, sliding segmented control for mutually exclusive options.
class BoxyArtSegmentedControl<T> extends ConsumerWidget {
  final T value;
  final List<BoxyOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool fullWidth;

  const BoxyArtSegmentedControl({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    final radius = config.inputRadius;

    final selectedIndex = options.indexWhere((o) => o.value == value);
    final count = options.length;
    
    // Ensure we have at least 2 options
    if (count < 2) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = fullWidth ? constraints.maxWidth : 300.0;
        final itemWidth = totalWidth / count;
        
        return Container(
          width: totalWidth,
          height: config.surfaceHeightMedium, // Design 4.x standard for segmented inputs
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark700 : AppColors.lightHeader,
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              // Sliding Indicator
              AnimatedAlign(
                duration: AppAnimations.medium,
                curve: Curves.easeInOut,
                alignment: Alignment(
                  (selectedIndex / (count - 1)) * 2 - 1,
                  0,
                ),
                child: Container(
                  width: itemWidth - 8,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(radius - 2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Option labels
              Row(
                children: options.map((option) {
                  final isSelected = option.value == value;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onChanged(option.value),
                      borderRadius: BorderRadius.circular(radius),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (option.icon != null) ...[
                              Icon(
                                option.icon,
                                size: 18,
                                color: isSelected 
                                    ? ContrastHelper.getContrastingText(theme.primaryColor)
                                    : (isDark ? AppColors.dark300 : AppColors.dark400),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              option.label,
                              style: AppTypography.label.copyWith(
                                fontSize: AppTypography.sizeLabel,
                                letterSpacing: AppTypography.lsStandard,
                                fontWeight: isSelected ? AppTypography.weightBlack : AppTypography.weightBold,
                                color: isSelected 
                                    ? ContrastHelper.getContrastingText(theme.primaryColor)
                                    : (isDark ? AppColors.dark300 : AppColors.dark400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A simple configuration object for segmented options.
class BoxyOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const BoxyOption({
    required this.value,
    required this.label,
    this.icon,
  });
}
