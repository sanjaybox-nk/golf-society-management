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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
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
      padding: const EdgeInsets.all(AppSpacing.x2l),
      decoration: BoxDecoration(
        color: AppColors.amber500.withValues(alpha: AppColors.opacitySubtle),
        borderRadius: AppShapes.x2l,
        border: Border.all(color: AppColors.amber500.withValues(alpha: AppColors.opacityLow)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: AppColors.amber500, size: AppShapes.iconLg),
              const SizedBox(width: AppSpacing.md),
              Text(
                'FLASH UPDATE',
                style: TextStyle(
                  fontWeight: AppTypography.weightBlack,
                  letterSpacing: 1.5,
                  color: AppColors.amber500.withValues(alpha: AppColors.opacityHigh),
                  fontSize: AppTypography.sizeLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            item.content,
            style: const TextStyle(
              fontSize: AppTypography.sizeLargeBody,
              height: 1.6,
              fontWeight: AppTypography.weightMedium,
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
      margin: const EdgeInsets.only(bottom: AppSpacing.x3l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null && section.title!.isNotEmpty) ...[
            Text(
              section.title!,
              style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeDisplayLocker),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (section.imageUrl != null) ...[
            ClipRRect(
              borderRadius: AppShapes.xl,
              child: Image.network(
                section.imageUrl!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
