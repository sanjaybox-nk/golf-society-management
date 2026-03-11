import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'dart:convert';
import 'dart:io';

class BoxyArtRichNoteEditor extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final String? initialImageUrl;
  final Function(String title, String content, String? imageUrl) onChanged;
  final VoidCallback onRemove;
  final String? titleHint;

  const BoxyArtRichNoteEditor({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.initialImageUrl,
    required this.onChanged,
    required this.onRemove,
    this.titleHint = 'Note Title',
  });

  @override
  ConsumerState<BoxyArtRichNoteEditor> createState() => _BoxyArtRichNoteEditorState();
}

class _BoxyArtRichNoteEditorState extends ConsumerState<BoxyArtRichNoteEditor> {
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _imageUrl = widget.initialImageUrl;
    
    // Initialize Quill Controller
    if (widget.initialContent != null && widget.initialContent!.startsWith('[{"insert"')) {
      try {
        _quillController = quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(widget.initialContent!)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
      if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
        _quillController.document.insert(0, widget.initialContent!);
      }
    }

    _titleController.addListener(_notifyChanged);
    _quillController.addListener(_notifyChanged);
  }

  void _notifyChanged() {
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    widget.onChanged(_titleController.text, contentJson, _imageUrl);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      setState(() => _imageUrl = picked.path);
      _notifyChanged();
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_notifyChanged);
    _quillController.removeListener(_notifyChanged);
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: BoxyArtFormField(
                  label: widget.titleHint!,
                  controller: _titleController,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              BoxyArtGlassIconButton(
                icon: Icons.add_a_photo_rounded,
                iconSize: 20,
                onPressed: _pickImage,
                tooltip: 'Add Photo',
              ),
              const SizedBox(width: AppSpacing.sm),
              BoxyArtGlassIconButton(
                icon: Icons.delete_outline,
                iconSize: 20,
                onPressed: widget.onRemove,
                tooltip: 'Remove Note',
              ),
            ],
          ),
          
          if (_imageUrl != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: AppShapes.md,
                  child: _imageUrl!.startsWith('http') 
                    ? Image.network(_imageUrl!, width: double.infinity, height: 200, fit: BoxFit.cover)
                    : Image.file(File(_imageUrl!), width: double.infinity, height: 200, fit: BoxFit.cover),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: BoxyArtGlassIconButton(
                    icon: Icons.close_rounded,
                    iconSize: 16,
                    onPressed: () {
                      setState(() => _imageUrl = null);
                      _notifyChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Note Content',
            style: TextStyle(
              fontSize: AppTypography.sizeCaptionStrong,
              fontWeight: AppTypography.weightBold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          BoxyArtRichEditor(
            controller: _quillController,
            placeholder: 'Start writing...',
            minHeight: 150,
          ),
        ],
      ),
    );
  }
}
