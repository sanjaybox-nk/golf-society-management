import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:golf_society/design_system/design_system.dart';
import 'dart:convert';

class BoxyArtRichFormField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final double minHeight;

  const BoxyArtRichFormField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.placeholder = 'Start typing...',
    this.minHeight = 150,
  });

  @override
  State<BoxyArtRichFormField> createState() => _BoxyArtRichFormFieldState();
}

class _BoxyArtRichFormFieldState extends State<BoxyArtRichFormField> {
  late quill.QuillController _controller;

  @override
  void initState() {
    super.initState();
    
    // Handle both JSON Delta and Plain Text
    if (widget.initialValue != null && widget.initialValue!.startsWith('[{"insert"')) {
      try {
        _controller = quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(widget.initialValue!)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _controller = quill.QuillController.basic();
      }
    } else {
      _controller = quill.QuillController.basic();
      if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
        _controller.document.insert(0, widget.initialValue!);
      }
    }

    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final json = jsonEncode(_controller.document.toDelta().toJson());
    widget.onChanged(json);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: AppTypography.sizeCaptionStrong,
            fontWeight: AppTypography.weightBold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BoxyArtRichEditor(
          controller: _controller,
          placeholder: widget.placeholder,
          minHeight: widget.minHeight,
        ),
      ],
    );
  }
}
