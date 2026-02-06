import 'package:flutter/material.dart';
import '../theme/app_shadows.dart';

/// A standard form field with BoxyArt styling (pill shaped, soft shadow).
class BoxyArtFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int? maxLines;
  final bool readOnly;
  final FocusNode? focusNode;

  const BoxyArtFormField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.onChanged,
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
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white12 
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            shadows: AppShadows.inputSoft,
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            onChanged: onChanged,
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
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            style: TextStyle(
              fontSize: 14, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}

/// A standard dropdown field with BoxyArt styling.
class BoxyArtDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const BoxyArtDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white12 
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            shadows: AppShadows.inputSoft,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              initialValue: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              alignment: Alignment.centerLeft,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              style: TextStyle(
              fontSize: 14, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
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
              color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white12 
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
              shadows: AppShadows.inputSoft,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
              fontSize: 14, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
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
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white12 
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        shadows: AppShadows.inputSoft,
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).primaryColor,
          activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
  final FocusNode? focusNode;

  const BoxyArtSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white12 
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        shadows: AppShadows.inputSoft,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        style: TextStyle(
          fontSize: 14, 
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        ),
      ),
    );
  }
}
