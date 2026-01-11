import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_shadows.dart';

/// A standard form field with BoxyArt styling (pill shaped, soft shadow).
class BoxyArtFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines;
  final bool readOnly;
  final FocusNode? focusNode;

  const BoxyArtFormField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5), // Light grey background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 20 : 100),
            ),
            shadows: AppShadows.inputSoft,
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            focusNode: focusNode,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black54, size: 20) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

/// A standard dropdown field with BoxyArt styling.
class BoxyArtDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const BoxyArtDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5),
            shape: const StadiumBorder(),
            shadows: AppShadows.inputSoft,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              initialValue: value,
              items: items,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

/// A read-only field that triggers a date picker on tap.
class BoxyArtDatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const BoxyArtDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: const StadiumBorder(),
              shadows: AppShadows.inputSoft,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.black54, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A switch tile with BoxyArt styling.
class BoxyArtSwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BoxyArtSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: const StadiumBorder(),
        shadows: AppShadows.inputSoft,
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryYellow,
          activeTrackColor: AppTheme.primaryYellow.withValues(alpha: 0.2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

/// A standard standalone search bar.
class BoxyArtSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const BoxyArtSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: const StadiumBorder(),
        shadows: AppShadows.inputSoft,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
