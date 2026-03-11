import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/design_system/widgets/boxy_art_rich_note_editor.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/services/storage_service.dart';

class RichNoteController {
  final TextEditingController titleController;
  late final quill.QuillController quillController;
  String? imageUrl;

  RichNoteController({String? title, String? content, this.imageUrl})
      : titleController = TextEditingController(text: title) {
    if (content != null && content.startsWith('[{"insert"')) {
      try {
        quillController = quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(content)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        quillController = quill.QuillController.basic();
      }
    } else {
      quillController = quill.QuillController.basic();
      if (content != null && content.isNotEmpty) {
        quillController.document.insert(0, content);
      }
    }
  }

  void dispose() {
    titleController.dispose();
    quillController.dispose();
  }
}

class FeedItemEditorScreen extends ConsumerStatefulWidget {
  final String eventId;
  final EventFeedItem? existingItem;

  const FeedItemEditorScreen({super.key, required this.eventId, this.existingItem});

  @override
  ConsumerState<FeedItemEditorScreen> createState() => _FeedItemEditorScreenState();
}

class _FeedItemEditorScreenState extends ConsumerState<FeedItemEditorScreen> {
  late FeedItemType _selectedType;
  final _flashContentController = TextEditingController();
  late List<RichNoteController> _richNoteControllers;
  
  bool _isPinned = false;
  bool _isPublished = false;
  bool _isSaving = false;
  
  // Poll Controllers
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionsControllers = [];

  @override
  void initState() {
    super.initState();
    
    _selectedType = widget.existingItem?.type ?? FeedItemType.newsletter;
    _isPinned = widget.existingItem?.isPinned ?? false;
    _isPublished = widget.existingItem?.isPublished ?? false;

    if (widget.existingItem?.type == FeedItemType.newsletter && widget.existingItem!.content.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.existingItem!.content);
        if (decoded is List) {
          _richNoteControllers = decoded.map((n) {
            final note = EventNote.fromJson(n as Map<String, dynamic>);
            return RichNoteController(
              title: note.title,
              content: note.content,
              imageUrl: note.imageUrl,
            );
          }).toList();
        } else {
          // Fallback for legacy single-block content
          _richNoteControllers = [
            RichNoteController(
              title: widget.existingItem?.title,
              content: widget.existingItem!.content,
              imageUrl: widget.existingItem?.imageUrl,
            )
          ];
        }
      } catch (e) {
        _richNoteControllers = [RichNoteController(content: '')];
      }
    } else {
      _richNoteControllers = [
        RichNoteController(
          title: widget.existingItem?.title,
          content: null,
          imageUrl: widget.existingItem?.imageUrl,
        )
      ];
    }

    if (_selectedType == FeedItemType.flash) {
      _flashContentController.text = widget.existingItem?.content ?? '';
    } else if (_selectedType == FeedItemType.poll) {
      _pollQuestionController.text = widget.existingItem?.title ?? '';
      final options = widget.existingItem?.pollData['options'] as List?;
      if (options != null) {
        for (var opt in options) {
          _pollOptionsControllers.add(TextEditingController(text: opt.toString()));
        }
      }
    }
    if (_pollOptionsControllers.isEmpty) {
      _pollOptionsControllers.add(TextEditingController());
      _pollOptionsControllers.add(TextEditingController());
    }
  }
    
  @override
  void dispose() {
    _flashContentController.dispose();
    for (var c in _richNoteControllers) {
      c.dispose();
    }
    super.dispose();
  }


  Future<void> _save() async {
    final mainNote = _richNoteControllers.first;
    final mainTitle = mainNote.titleController.text.trim();
    String finalContent = '';

    if (_selectedType == FeedItemType.flash) {
      finalContent = _flashContentController.text.trim();
      if (finalContent.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flash updates must contain a message.')));
        return;
      }
    } else if (_selectedType == FeedItemType.newsletter) {
      if (_richNoteControllers.every((c) => c.quillController.document.isEmpty() && c.titleController.text.isEmpty && c.imageUrl == null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Newsletter cannot be completely empty.')));
        return;
      }
    } else if (_selectedType == FeedItemType.poll) {
      if (_pollQuestionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poll question is required.')));
        return;
      }
      if (_pollOptionsControllers.where((c) => c.text.trim().isNotEmpty).length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('At least 2 options are required.')));
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final event = await ref.read(eventsRepositoryProvider).getEvent(widget.eventId);
      if (event == null) throw Exception('Event not found');

      final storage = ref.read(storageServiceProvider);
      final List<EventNote> savedNotes = [];

      for (int i = 0; i < _richNoteControllers.length; i++) {
        final ctrl = _richNoteControllers[i];
        String? noteImageUrl = ctrl.imageUrl;

        if (noteImageUrl != null && !noteImageUrl.startsWith('http')) {
          final path = 'events/${event.id}/feed/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          noteImageUrl = await storage.uploadImage(path: path, file: File(noteImageUrl));
        }

        savedNotes.add(EventNote(
          title: ctrl.titleController.text.trim(),
          content: jsonEncode(ctrl.quillController.document.toDelta().toJson()),
          imageUrl: noteImageUrl,
        ));
      }

      if (_selectedType == FeedItemType.newsletter) {
        finalContent = jsonEncode(savedNotes.map((n) => n.toJson()).toList());
      }

      final newItem = EventFeedItem(
        id: widget.existingItem?.id ?? const Uuid().v4(),
        type: _selectedType,
        title: _selectedType == FeedItemType.poll ? _pollQuestionController.text.trim() : (mainTitle.isNotEmpty ? mainTitle : null),
        content: finalContent,
        imageUrl: _selectedType == FeedItemType.poll ? null : savedNotes.first.imageUrl,
        isPinned: _isPinned,
        isPublished: _isPublished,
        sortOrder: widget.existingItem?.sortOrder ?? event.feedItems.length,
        createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
        pollData: _selectedType == FeedItemType.poll ? {
          'options': _pollOptionsControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
          'results': widget.existingItem?.pollData['results'] ?? {},
        } : {},
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPublished ? Icons.check_circle_rounded : Icons.save_rounded, 
                  color: AppColors.pureWhite, 
                  size: AppShapes.iconMd,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  _isPublished ? 'Post Published' : 'Draft Saved',
                  style: const TextStyle(fontWeight: AppTypography.weightBold, color: AppColors.pureWhite),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: AppShapes.pillShape,
            backgroundColor: _isPublished ? AppColors.lime600 : AppColors.amber500,
            duration: const Duration(seconds: 3),
          ),
        );
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
      autoPrefix: false,
      showBack: true,
      onBack: () => context.pop(),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SizedBox(width: AppSpacing.xl, height: AppSpacing.xl, child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else ...[
          BoxyArtGlassIconButton(
            icon: Icons.save_rounded,
            iconSize: 22,
            tooltip: 'Save Draft',
            onPressed: () {
               setState(() => _isPublished = false);
               _save();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: BoxyArtGlassIconButton(
              icon: Icons.publish_rounded,
              iconSize: 22,
              tooltip: 'Publish',
              onPressed: () {
                 setState(() => _isPublished = true);
                 _save();
              },
            ),
          ),
        ],
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Post Type Selector
              const BoxyArtSectionTitle(title: 'Post Type'),
              const SizedBox(height: AppTheme.sectionSpacing),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeToggle(
                        title: 'Flash Update',
                        icon: Icons.warning_amber_rounded,
                        type: FeedItemType.flash,
                        color: AppColors.amber500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildTypeToggle(
                        title: 'Newsletter',
                        icon: Icons.article_rounded,
                        type: FeedItemType.newsletter,
                        color: AppColors.teamA,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildTypeToggle(
                        title: 'Poll',
                        icon: Icons.poll_rounded,
                        type: FeedItemType.poll,
                        color: AppColors.teamB,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.cardSpacing),

              // Visibility Controls
              const BoxyArtSectionTitle(title: 'Placement'),
              const SizedBox(height: AppTheme.sectionSpacing),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: BoxyArtSwitchField(
                  label: 'Pin to Top',
                  value: _isPinned,
                  onChanged: (val) => setState(() => _isPinned = val),
                  // The subtitle corresponds to "This post will always remain at the top of the feed." 
                  // but BoxyArtSwitchField doesn't have a subtitle parameter like SwitchListTile.
                ),
              ),
              const SizedBox(height: AppTheme.cardSpacing),

              const BoxyArtSectionTitle(title: 'Content'),
              const SizedBox(height: AppTheme.sectionSpacing),
              if (_selectedType == FeedItemType.flash)
                _buildFlashEditor()
              else if (_selectedType == FeedItemType.poll)
                _buildPollEditor()
              else ...[
                ..._richNoteControllers.asMap().entries.map((entry) {
                   final index = entry.key;
                   final ctrl = entry.value;
                   return BoxyArtRichNoteEditor(
                     key: ValueKey('feed_note_$index'),
                     initialTitle: ctrl.titleController.text,
                     initialContent: jsonEncode(ctrl.quillController.document.toDelta().toJson()),
                     initialImageUrl: ctrl.imageUrl,
                     onChanged: (title, content, imageUrl) {
                       ctrl.titleController.text = title;
                       ctrl.quillController.document = quill.Document.fromJson(jsonDecode(content));
                       ctrl.imageUrl = imageUrl;
                     },
                     onRemove: _richNoteControllers.length > 1 
                        ? () => setState(() => _richNoteControllers.removeAt(index))
                        : () {},
                     titleHint: index == 0 ? 'Headline / Title' : 'Section Title (Optional)',
                   );
                }),
                const SizedBox(height: AppSpacing.sm),
                BoxyArtButton(
                  title: 'ADD SECTION',
                  onTap: () => setState(() => _richNoteControllers.add(RichNoteController(content: ''))),
                  isGhost: true,
                ),
              ],

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle({required String title, required IconData icon, required FeedItemType type, required Color color}) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: AppColors.opacityLow) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.dark400 : AppColors.lightBorder),
          ),
          borderRadius: BorderRadius.circular(AppShapes.rLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? color : (isDark ? AppColors.dark150 : AppColors.dark400),
              size: AppShapes.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: AppTypography.sizeLabelStrong,
                fontWeight: AppTypography.weightBold,
                color: isSelected ? color : (isDark ? AppColors.dark150 : AppColors.dark400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollEditor() {
    return Column(
      children: [
        BoxyArtCard(
          child: BoxyArtInputField(
            label: 'Question',
            controller: _pollQuestionController,
            hint: 'What would you like to ask?',
            maxLines: null,
          ),
        ),
        const SizedBox(height: AppTheme.cardSpacing),
        const BoxyArtSectionTitle(title: 'Options'),
        const SizedBox(height: AppTheme.sectionSpacing),
        ..._pollOptionsControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final ctrl = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: BoxyArtCard(
              child: Row(
                children: [
                  Expanded(
                    child: BoxyArtInputField(
                      label: 'Option ${index + 1}',
                      controller: ctrl,
                      hint: 'Enter option text...',
                    ),
                  ),
                  if (_pollOptionsControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                      onPressed: () => setState(() => _pollOptionsControllers.removeAt(index)),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        BoxyArtButton(
          title: 'ADD OPTION',
          onTap: () => setState(() => _pollOptionsControllers.add(TextEditingController())),
          isGhost: true,
          icon: Icons.add_rounded,
        ),
      ],
    );
  }

  Widget _buildFlashEditor() {
    return BoxyArtCard(
      child: BoxyArtInputField(
        label: 'Flash Message',
        controller: _flashContentController,
        hint: 'Enter urgent update...',
        maxLines: null,
      ),
    );
  }
}
