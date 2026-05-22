import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
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
    final config = ref.watch(themeControllerProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final radius = config.cardRadius;

    return BoxyArtCard(
      borderRadius: radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BoxyArtFormField(
                  label: toTitleCase(widget.titleHint!),
                  controller: _titleController,
                  hintText: 'Enter title here...',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.only(top: 26), // Align with input field when label is present
                child: Row(
                  children: [
                    BoxyArtGlassIconButton(
                      icon: Icons.add_a_photo_rounded,
                      iconSize: 20,
                      onPressed: _pickImage,
                      tooltip: 'Add Photo',
                      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    BoxyArtGlassIconButton(
                      icon: Icons.delete_outline,
                      iconSize: 20,
                      onPressed: widget.onRemove,
                      tooltip: 'Remove Note',
                      iconColor: AppColors.coral500,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_imageUrl != null) ...[
            SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
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
          
          SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
          Text(
            'NOTE CONTENT',
            style: AppTypography.labelStrong.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark500,
            ),
          ),
          SizedBox(height: spacing?.labelToCard ?? AppSpacing.labelToCard),
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
