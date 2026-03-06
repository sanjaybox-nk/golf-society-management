import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:golf_society/design_system/design_system.dart';

class RichNoteController {
  final TextEditingController titleController;
  final QuillController quillController;
  String? imageUrl;

  RichNoteController({String? title, String? content, this.imageUrl})
      : titleController = TextEditingController(text: title),
        quillController = QuillController(
          document: content != null && content.isNotEmpty
              ? Document.fromJson(jsonDecode(content))
              : Document(),
          selection: const TextSelection.collapsed(offset: 0),
        );

  void dispose() {
    titleController.dispose();
    quillController.dispose();
  }
}

class BoxyArtRichNoteEditor extends StatefulWidget {
  final RichNoteController controller;
  final VoidCallback? onRemove;
  final String? titleHint;
  final bool showRemoveHeader;

  const BoxyArtRichNoteEditor({
    super.key,
    required this.controller,
    this.onRemove,
    this.titleHint = 'Subject...',
    this.showRemoveHeader = true,
  });

  @override
  State<BoxyArtRichNoteEditor> createState() => _BoxyArtRichNoteEditorState();
}

class _BoxyArtRichNoteEditorState extends State<BoxyArtRichNoteEditor> {
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => widget.controller.imageUrl = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: BoxyArtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title + Photo + Close
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller.titleController,
                    decoration: InputDecoration(
                      hintText: widget.titleHint,
                      hintStyle: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                BoxyArtGlassIconButton(
                  icon: Icons.add_a_photo_rounded,
                  iconSize: 18,
                  onPressed: _pickImage,
                  tooltip: 'Add Photo',
                ),
                if (widget.showRemoveHeader && widget.onRemove != null) ...[
                  const SizedBox(width: 8),
                  BoxyArtGlassIconButton(
                    icon: Icons.close_rounded,
                    iconSize: 18,
                    onPressed: widget.onRemove,
                    tooltip: 'Remove Note',
                  ),
                ],
              ],
            ),
            const Divider(),
            
            // Image Stack
            if (widget.controller.imageUrl != null) ...[
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.controller.imageUrl!.startsWith('http') 
                      ? Image.network(
                          widget.controller.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        )
                      : Image.file(
                          File(widget.controller.imageUrl!),
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BoxyArtGlassIconButton(
                      icon: Icons.close_rounded,
                      iconSize: 16,
                      onPressed: () => setState(() => widget.controller.imageUrl = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
            ],

            // Content Section
            const SizedBox(height: 12),
            const Text(
              'CONTENT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            BoxyArtRichEditor(
              controller: widget.controller.quillController,
              placeholder: 'Message content...',
              minHeight: 180,
            ),
          ],
        ),
      ),
    );
  }
}
