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

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(adminNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              const SizedBox(height: 24),
              // Search & Filters
              BoxyArtCard(
                child: Column(
                  children: [
                    BoxyArtInputField(
                      label: 'Search History',
                      hint: 'Search by title or message...',
                      onChanged: (v) => setState(() => _searchQuery = v),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                            Text(
                              'Group By:', 
                              style: AppTypography.label.copyWith(
                                color: isDark ? AppColors.dark150 : AppColors.dark400,
                              ),
                            ),
                          const SizedBox(width: 12),
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
                                  const SizedBox(width: 8),
                                  _GroupChip(
                                    label: 'Category',
                                    isSelected: _groupBy == 'Category',
                                    onTap: () => setState(() => _groupBy = 'Category'),
                                  ),
                                  const SizedBox(width: 8),
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
              const SizedBox(height: 24),

              notificationsAsync.when(
                data: (notifications) {
                  final filtered = notifications.where((n) {
                    final term = _searchQuery.toLowerCase();
                    return n.title.toLowerCase().contains(term) || 
                           n.message.toLowerCase().contains(term);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, size: 48, color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications found',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return _buildGroupedList(filtered);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 130),
            ]),
          ),
        ),
      ],
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
            const SizedBox(height: 8),
            ...groupItems.map((c) => _HistoryCard(campaign: c)),
            const SizedBox(height: 24),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
      padding: const EdgeInsets.only(bottom: 12),
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
                    fontSize: 11,
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lime500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    campaign.category.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      fontSize: 9,
                      color: isDark ? AppColors.lime500 : AppColors.lime700,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    campaign.title, 
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w800),
                  )
                ),
                if (campaign.recipientCount > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.people_alt_rounded, size: 14, color: isDark ? AppColors.dark300 : AppColors.dark400),
                  const SizedBox(width: 4),
                  Text(
                    '${campaign.recipientCount}', 
                    style: AppTypography.label.copyWith(
                      fontSize: 12,
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _getPlainTextMessage(campaign.message), 
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.dark150 : AppColors.dark400,
                fontSize: 13,
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

  String _getPlainTextMessage(String message) {
    try {
      final List<dynamic> deltaJson = jsonDecode(message);
      final document = quill.Document.fromJson(deltaJson);
      return document.toPlainText().trim();
    } catch (_) {
      return message;
    }
  }
  
  void _showCampaignDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Prepare Quill Controller for the dialog
    quill.QuillController? quillController;
    try {
      final List<dynamic> deltaJson = jsonDecode(campaign.message);
      quillController = quill.QuillController(
        document: quill.Document.fromJson(deltaJson),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    } catch (_) {
      // Not JSON, handle as plain text
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
          const SizedBox(height: 12),
          _DetailRow(label: 'Category', value: campaign.category),
          _DetailRow(label: 'Date', value: parseDate(campaign.timestamp)),
          const SizedBox(height: 24),
          Text(
            'MESSAGE CONTENT', 
            style: AppTypography.label.copyWith(
              fontSize: 10, 
              color: isDark ? AppColors.dark300 : AppColors.dark400,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
               color: isDark ? AppColors.dark600 : Colors.grey.shade50,
               borderRadius: BorderRadius.circular(20),
               border: Border.all(color: isDark ? AppColors.dark500 : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title, 
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
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
                    campaign.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.dark150 : AppColors.dark500,
                      height: 1.6,
                    ),
                  ),
              ],
            ),
          ),
          if (campaign.actionUrl != null) ...[
             const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
