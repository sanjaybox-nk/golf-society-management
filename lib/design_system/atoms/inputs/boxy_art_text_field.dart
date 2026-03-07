import "package:golf_society/design_system/design_system.dart";



import 'package:flutter/services.dart';

class BoxyArtTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? errorText;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final bool autofocus;

  const BoxyArtTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.errorText,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: AppTypography.sizeBodySmall,
              fontWeight: AppTypography.weightBold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppShapes.lg,
            boxShadow: AppShadows.inputSoft,
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            maxLines: maxLines,
            minLines: minLines,
            focusNode: focusNode,
            autofocus: autofocus,
            style: const TextStyle(fontSize: AppTypography.sizeButton),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: AppColors.opacityHalf),
                fontSize: AppTypography.sizeButton,
              ),
              prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: Theme.of(context).primaryColor, size: AppShapes.iconMd) 
                : null,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: AppShapes.lg,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              errorText: errorText,
            ),
          ),
        ),
      ],
    );
  }
}
