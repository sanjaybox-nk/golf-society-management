import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/campaign.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'admin_notifications_provider.dart';

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen> {
  String _searchQuery = '';
  String _groupBy = 'Date'; // 'Date', 'Category', 'None'
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(adminNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          notificationsAsync.when(
            data: (notifications) {
              final term = _searchQuery.toLowerCase();
              final filtered = notifications.where((n) {
                final titleMatch = n.title.toLowerCase().contains(term);
                
                bool messageMatch = false;
                if (n.message != null) {
                  messageMatch = n.message!.toLowerCase().contains(term);
                } else if (n.notes.isNotEmpty) {
                  messageMatch = n.notes.any((note) => 
                    (note.title?.toLowerCase().contains(term) ?? false) || 
                    note.content.toLowerCase().contains(term)
                  );
                }

                return titleMatch || messageMatch;
              }).toList();

              // Only show search UI if we have notifications OR the user is searching
              final showSearch = notifications.isNotEmpty || _searchQuery.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSearch) ...[
                    // Search & Filters
                    BoxyArtCard(
                      child: Column(
                        children: [
                          BoxyArtInputField(
                            label: 'Search History',
                            hint: 'Search by title or message...',
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Row(
                              children: [
                                  Text(
                                    'Group By:', 
                                    style: AppTypography.label.copyWith(
                                      color: isDark ? AppColors.dark150 : AppColors.dark400,
                                    ),
                                  ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _GroupChip(
                                          label: 'Date',
                                          isSelected: _groupBy == 'Date',
                                          onTap: () => setState(() => _groupBy = 'Date'),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        _GroupChip(
                                          label: 'Category',
                                          isSelected: _groupBy == 'Category',
                                          onTap: () => setState(() => _groupBy = 'Category'),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        _GroupChip(
                                          label: 'None',
                                          isSelected: _groupBy == 'None',
                                          onTap: () => setState(() => _groupBy = 'None'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2l),
                  ],

                  if (filtered.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _searchQuery.isEmpty ? AppSpacing.xl : AppSpacing.md,
                      ),
                      child: BoxyArtEmptyCard(
                        title: _searchQuery.isEmpty ? 'No Notes Found' : 'No Results',
                        message: _searchQuery.isEmpty 
                            ? 'Your society dispatch history is empty. Send your first communication to see it here.'
                            : 'No communications matched your search for "$_searchQuery".',
                        icon: _searchQuery.isEmpty ? Icons.history_rounded : Icons.search_off_rounded,
                      ),
                    )
                  else
                    _buildGroupedList(filtered),
                ],
              );
            },
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          const SizedBox(height: 130),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<Campaign> campaigns) {
    if (_groupBy == 'None') {
      return Column(
        children: campaigns.map((c) => _HistoryCard(campaign: c)).toList(),
      );
    }

    // Group Logic
    Map<String, List<Campaign>> groups = {};
    for (var c in campaigns) {
      String key = '';
      if (_groupBy == 'Date') {
        final now = DateTime.now();
        final diff = now.difference(c.timestamp).inDays;
        if (diff == 0) {
          key = 'Today';
        } else if (diff == 1) {
          key = 'Yesterday';
        } else if (diff < 7) {
          key = 'Last 7 Days';
        } else {
          key = 'Older';
        }
      } else {
        key = c.category;
      }
      
      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(c);
    }

    final sortedKeys = groups.keys.toList(); 

    return Column(
      children: sortedKeys.map((key) {
        final groupItems = groups[key]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxyArtSectionTitle(title: key),
            ...groupItems.map((c) => _HistoryCard(campaign: c)),
            const SizedBox(height: AppSpacing.x2l),
          ],
        );
      }).toList(),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppShapes.xl,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: AppTypography.weightBold,
            fontSize: AppTypography.sizeLabel,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Campaign campaign;
  const _HistoryCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtCard(
        onTap: () => _showCampaignDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  parseDate(campaign.timestamp), 
                  style: AppTypography.label.copyWith(
                    fontSize: AppTypography.sizeCaptionStrong,
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                    borderRadius: AppShapes.sm,
                  ),
                  child: Text(
                    campaign.category.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      fontSize: AppTypography.sizeMicroSmall,
                      color: isDark ? AppColors.lime500 : AppColors.lime700,
                      letterSpacing: 0.5,
                      fontWeight: AppTypography.weightExtraBold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    campaign.title, 
                    style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightExtraBold),
                  )
                ),
                if (campaign.recipientCount > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.people_alt_rounded, size: AppShapes.iconXs, color: isDark ? AppColors.dark300 : AppColors.dark400),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${campaign.recipientCount}', 
                    style: AppTypography.label.copyWith(
                      fontSize: AppTypography.sizeLabel,
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _getPlainTextMessage(campaign), 
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.dark150 : AppColors.dark400,
                fontSize: AppTypography.sizeLabelStrong,
                height: 1.4,
              ), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getPlainTextMessage(Campaign campaign) {
    if (campaign.message != null) {
      try {
        final List<dynamic> deltaJson = jsonDecode(campaign.message!);
        final document = quill.Document.fromJson(deltaJson);
        return document.toPlainText().trim();
      } catch (_) {
        return campaign.message!;
      }
    } else if (campaign.notes.isNotEmpty) {
      // Concatenate content from all sections for a summary
      return campaign.notes.map((note) {
        try {
          final List<dynamic> deltaJson = jsonDecode(note.content);
          final document = quill.Document.fromJson(deltaJson);
          return document.toPlainText().trim();
        } catch (_) {
          return note.content;
        }
      }).join(' • ');
    }
    return '';
  }
  
  void _showCampaignDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build the content dynamically based on whether it's legacy or multi-section
    Widget content;
    if (campaign.message != null) {
      quill.QuillController? quillController;
      try {
        final List<dynamic> deltaJson = jsonDecode(campaign.message!);
        quillController = quill.QuillController(
          document: quill.Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } catch (_) {}

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.title, 
            style: AppTypography.body.copyWith(
              fontWeight: AppTypography.weightBlack,
              fontSize: AppTypography.sizeLargeBody,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (quillController != null)
            quill.QuillEditor.basic(
              controller: quillController,
              config: quill.QuillEditorConfig(
                autoFocus: false,
                expands: false,
                padding: EdgeInsets.zero,
                showCursor: false,
                enableInteractiveSelection: true,
                scrollable: false,
              ),
            )
          else
            Text(
              campaign.message!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.dark150 : AppColors.dark500,
                height: 1.6,
              ),
            ),
        ],
      );
    } else {
      // Multi-section display
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.title, 
            style: AppTypography.body.copyWith(
              fontWeight: AppTypography.weightBlack,
              fontSize: AppTypography.sizeLargeBody,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...campaign.notes.map((note) {
            quill.QuillController? noteController;
            try {
              final List<dynamic> deltaJson = jsonDecode(note.content);
              noteController = quill.QuillController(
                document: quill.Document.fromJson(deltaJson),
                selection: const TextSelection.collapsed(offset: 0),
                readOnly: true,
              );
            } catch (_) {}

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (note.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: AppShapes.lg,
                        child: Image.network(
                          note.imageUrl!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                   ],
                  if (note.title != null && note.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        note.title!,
                        style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightExtraBold),
                      ),
                    ),
                  if (noteController != null)
                    quill.QuillEditor.basic(
                      controller: noteController,
                      config: quill.QuillEditorConfig(
                        autoFocus: false,
                        expands: false,
                        padding: EdgeInsets.zero,
                        showCursor: false,
                        enableInteractiveSelection: true,
                        scrollable: false,
                      ),
                    )
                  else
                    Text(
                      note.content,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.dark150 : AppColors.dark500,
                        height: 1.6,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      );
    }

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Campaign Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Sent To', value: '${campaign.targetType} (${campaign.recipientCount} recipients)'),
          if (campaign.targetDescription != null) 
             _DetailRow(label: 'Target', value: campaign.targetDescription!),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(label: 'Category', value: campaign.category),
          _DetailRow(label: 'Date', value: parseDate(campaign.timestamp)),
          const SizedBox(height: AppSpacing.x2l),
          Text(
            'MESSAGE CONTENT', 
            style: AppTypography.label.copyWith(
              fontSize: AppTypography.sizeCaption, 
              color: isDark ? AppColors.dark300 : AppColors.dark400,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
               color: isDark ? AppColors.dark600 : AppColors.dark50,
               borderRadius: AppShapes.xl,
               border: Border.all(color: isDark ? AppColors.dark500 : AppColors.dark200),
            ),
            child: content,
          ),
          if (campaign.actionUrl != null) ...[
             const SizedBox(height: AppSpacing.xl),
             _DetailRow(label: 'Action', value: campaign.actionUrl!),
          ],
          const SizedBox(height: 48), // Bottom clearance
        ],
      ),
    );
  }
  
  String parseDate(DateTime d) {
    return DateFormat('MMM d, h:mm a').format(d);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLabelStrong, color: Theme.of(context).textTheme.bodyMedium?.color))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: AppTypography.sizeLabelStrong))),
        ],
      ),
    );
  }
}
