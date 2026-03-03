import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/events/data/events_repository.dart';
import 'package:golf_society/services/storage_service.dart';

class FeedItemEditorScreen extends ConsumerStatefulWidget {
  final String eventId;
  final EventFeedItem? existingItem;

  const FeedItemEditorScreen({super.key, required this.eventId, this.existingItem});

  @override
  ConsumerState<FeedItemEditorScreen> createState() => _FeedItemEditorScreenState();
}

class _FeedItemEditorScreenState extends ConsumerState<FeedItemEditorScreen> {
  late FeedItemType _selectedType;
  final _titleController = TextEditingController();
  final _flashContentController = TextEditingController();
  late QuillController _quillController;
  
  bool _isPinned = false;
  bool _isPublished = false;
  String? _imageUrl;
  File? _selectedImageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existingItem?.type ?? FeedItemType.newsletter;
    _isPinned = widget.existingItem?.isPinned ?? false;
    _isPublished = widget.existingItem?.isPublished ?? false;
    _imageUrl = widget.existingItem?.imageUrl;
    _titleController.text = widget.existingItem?.title ?? '';

    if (_selectedType == FeedItemType.flash) {
      _flashContentController.text = widget.existingItem?.content ?? '';
    }
    
    _initQuill();
  }

  void _initQuill() {
    if (widget.existingItem != null && widget.existingItem!.type == FeedItemType.newsletter && widget.existingItem!.content.isNotEmpty) {
      try {
        _quillController = QuillController(
          document: Document.fromJson(jsonDecode(widget.existingItem!.content)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = QuillController.basic();
      }
    } else {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _flashContentController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
        _imageUrl = null; // Clear existing if uploading new
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    String content = '';

    if (_selectedType == FeedItemType.flash) {
      content = _flashContentController.text.trim();
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flash updates must contain a message.')));
        return;
      }
    } else if (_selectedType == FeedItemType.newsletter) {
      content = jsonEncode(_quillController.document.toDelta().toJson());
      if (_quillController.document.isEmpty() && title.isEmpty && _selectedImageFile == null && _imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Newsletter cannot be completely empty.')));
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final event = await ref.read(eventsRepositoryProvider).getEvent(widget.eventId);
      if (event == null) throw Exception('Event not found');

      String? finalImageUrl = _imageUrl;
      if (_selectedImageFile != null) {
         final storage = ref.read(storageServiceProvider);
         final path = 'events/${event.id}/feed/${DateTime.now().millisecondsSinceEpoch}.jpg';
         finalImageUrl = await storage.uploadImage(path: path, file: _selectedImageFile!);
      }

      final newItem = EventFeedItem(
        id: widget.existingItem?.id ?? const Uuid().v4(),
        type: _selectedType,
        title: title,
        content: content,
        imageUrl: finalImageUrl,
        isPinned: _isPinned,
        isPublished: _isPublished,
        sortOrder: widget.existingItem?.sortOrder ?? event.feedItems.length,
        createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
      );

      final List<EventFeedItem> updatedItems = List.from(event.feedItems);
      if (widget.existingItem != null) {
        final index = updatedItems.indexWhere((i) => i.id == widget.existingItem!.id);
        if (index != -1) updatedItems[index] = newItem;
      } else {
        updatedItems.insert(0, newItem);
      }

      // Automatically re-sort indices when saving
      for (int i = 0; i < updatedItems.length; i++) {
        updatedItems[i] = updatedItems[i].copyWith(sortOrder: i);
      }

      final updatedEvent = event.copyWith(feedItems: updatedItems);
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isPublished ? 'Post Published' : 'Draft Saved')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving post: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeadlessScaffold(
      title: widget.existingItem == null ? 'Create Post' : 'Edit Post',
      subtitle: _selectedType.name.toUpperCase(),
      useScaffold: true,
      showBack: true,
      onBack: () => context.pop(),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else ...[
          TextButton(
            onPressed: () {
               setState(() => _isPublished = false);
               _save();
            },
            child: const Text('Save Draft', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          BoxyArtButton(
            title: 'Publish',
            onTap: () {
               setState(() => _isPublished = true);
               _save();
            },
          ),
          const SizedBox(width: 16),
        ],
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Post Type Selector
              const BoxyArtSectionTitle(title: 'Post Type'),
              BoxyArtCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeToggle(
                        title: 'Flash Update',
                        icon: Icons.warning_amber_rounded,
                        type: FeedItemType.flash,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeToggle(
                        title: 'Newsletter',
                        icon: Icons.article_rounded,
                        type: FeedItemType.newsletter,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Visibility Controls
              const BoxyArtSectionTitle(title: 'Placement'),
              BoxyArtCard(
                child: SwitchListTile(
                  title: const Text('Pin to Top', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('This post will always remain at the top of the feed.', style: TextStyle(fontSize: 12)),
                  value: _isPinned,
                  onChanged: (val) => setState(() => _isPinned = val),
                  activeTrackColor: Colors.blue.withValues(alpha: 0.5),
                  activeThumbColor: Colors.blue,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 32),

              const BoxyArtSectionTitle(title: 'Content'),
              if (_selectedType == FeedItemType.flash)
                _buildFlashEditor()
              else
                _buildNewsletterEditor(),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle({required String title, required IconData icon, required FeedItemType type, required Color color}) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashEditor() {
    return BoxyArtCard(
      child: BoxyArtInputField(
        label: 'Message',
        controller: _flashContentController,
        maxLines: 3,
        hint: 'e.g. Frost delay, tee times pushed 30 mins',
      ),
    );
  }

  Widget _buildNewsletterEditor() {
    return Column(
      children: [
        BoxyArtCard(
          child: Column(
            children: [
              BoxyArtInputField(
                label: 'Headline / Title',
                controller: _titleController,
                hint: 'e.g. Pre-Game Instructions',
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Header Image (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              if (_selectedImageFile != null || _imageUrl != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedImageFile != null 
                        ? Image.file(_selectedImageFile!, width: double.infinity, height: 160, fit: BoxFit.cover)
                        : Image.network(_imageUrl!, width: double.infinity, height: 160, fit: BoxFit.cover),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      onPressed: () => setState(() { _selectedImageFile = null; _imageUrl = null; }),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, color: Colors.grey, size: 32),
                        SizedBox(height: 8),
                        Text('Tap to add image', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              QuillSimpleToolbar(
                controller: _quillController,
                config: const QuillSimpleToolbarConfig(
                  showFontFamily: false,
                  showFontSize: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: false,
                  showAlignmentButtons: false,
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: const QuillEditorConfig(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
