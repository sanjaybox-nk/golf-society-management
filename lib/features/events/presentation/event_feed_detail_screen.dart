import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';

class EventFeedDetailScreen extends ConsumerWidget {
  final EventFeedItem item;

  const EventFeedDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<EventNote> sections = [];
    
    if (item.type == FeedItemType.newsletter) {
      try {
        final decoded = jsonDecode(item.content);
        if (decoded is List) {
          sections.addAll(decoded.map((n) => EventNote.fromJson(n as Map<String, dynamic>)));
        } else {
          sections.add(EventNote(
            title: item.title,
            content: item.content,
            imageUrl: item.imageUrl,
          ));
        }
      } catch (e) {
        sections.add(EventNote(
          title: item.title,
          content: item.content,
          imageUrl: item.imageUrl,
        ));
      }
    } else {
      sections.add(EventNote(
        title: item.title,
        content: item.content,
        imageUrl: item.imageUrl,
      ));
    }

    return HeadlessScaffold(
      title: item.type == FeedItemType.flash ? 'Flash Update' : 'Newsletter',
      subtitle: item.title ?? 'Full Story',
      useScaffold: true,
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (item.type == FeedItemType.flash)
                _buildFlashDetail(item)
              else
                ...sections.map((section) => _buildSection(context, section)),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashDetail(EventFeedItem item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Text(
                'FLASH UPDATE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.orange.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            item.content,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, EventNote section) {
    QuillController? quillController;
    try {
      if (section.content.isNotEmpty) {
        quillController = QuillController(
          document: Document.fromJson(jsonDecode(section.content)),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null && section.title!.isNotEmpty) ...[
            Text(
              section.title!,
              style: AppTypography.displayHeading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
          ],
          if (section.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                section.imageUrl!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (quillController != null)
            QuillEditor.basic(
              controller: quillController,
              config: const QuillEditorConfig(
                padding: EdgeInsets.zero,
                autoFocus: false,
                expands: false,
              ),
            ),
        ],
      ),
    );
  }
}
