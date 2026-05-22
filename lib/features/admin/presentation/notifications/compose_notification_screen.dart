import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'distribution_list_provider.dart';
import 'package:golf_society/domain/models/distribution_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:golf_society/services/storage_service.dart';
import 'package:golf_society/domain/models/campaign.dart';
import 'smart_audience_evaluator.dart';

class NotificationSectionController {
  final TextEditingController titleController;
  late final quill.QuillController quillController;
  String? imageUrl;

  NotificationSectionController({String? title, String? content, this.imageUrl})
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

class ComposeNotificationScreen extends ConsumerStatefulWidget {
  final bool isTabbed;
  final String? eventId;
  final String? type;
  final String? campaignId;
  final String? feedItemId;
  const ComposeNotificationScreen({
    super.key, 
    this.isTabbed = false, 
    this.eventId, 
    this.type,
    this.campaignId,
    this.feedItemId,
  });

  @override
  ConsumerState<ComposeNotificationScreen> createState() => _ComposeNotificationScreenState();
}

class _ComposeNotificationScreenState extends ConsumerState<ComposeNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Targeting
  DistributionList? _selectedAudience; // Null = All Members (System Default)
  String? _selectedEventId;
  
  // Message
  final List<NotificationSectionController> _sections = [];
  String _category = 'Announcement';
  final List<String> _categories = ['Announcement', 'Note', 'Urgent Alert', 'Event Update', 'Social'];
  bool _isSending = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.eventId;
    
    // Default to 'News' if creating from the Newsletter Studio
    if (widget.type == 'newsletter') {
      _category = 'Note';
    }

    if (widget.campaignId != null || widget.feedItemId != null) {
      _loadExistingData();
    } else {
      // Initialize with one section if new
      _sections.add(NotificationSectionController());
    }
  }

  Future<void> _loadExistingData() async {
    setState(() => _isSending = true);
    try {
      final firestore = FirebaseFirestore.instance;
      List<EventNote> notes = [];
      String? title;
      String? category;
      String? targetType;

      if (widget.campaignId != null) {
        final doc = await firestore.collection('campaigns').doc(widget.campaignId).get();
        if (doc.exists) {
          final campaign = Campaign.fromJson(doc.data()!..['id'] = doc.id);
          notes = campaign.notes;
          title = campaign.title;
          category = campaign.category;
          targetType = campaign.targetType;
        }
      } else if (widget.feedItemId != null && widget.eventId != null) {
        final event = await ref.read(eventsRepositoryProvider).getEvent(widget.eventId!);
        if (event != null) {
          final item = event.feedItems.firstWhereOrNull((i) => i.id == widget.feedItemId);
          if (item != null) {
            title = item.title;
            category = 'Note';
            try {
              final decoded = jsonDecode(item.content);
              if (decoded is List) {
                notes = decoded.map((n) => EventNote.fromJson(n as Map<String, dynamic>)).toList();
              }
            } catch (e) {
              // Fallback
              notes = [EventNote(title: item.title ?? '', content: item.content, imageUrl: item.imageUrl)];
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          if (category != null) _category = category;
          if (targetType != null) {
            // Map legacy targetType to _selectedAudience if possible
            if (targetType == 'All Members') {
              _selectedAudience = null;
            }
          }
          
          _sections.clear();
          if (notes.isEmpty) {
            _sections.add(NotificationSectionController(title: title));
          } else {
            for (final note in notes) {
              _sections.add(NotificationSectionController(
                title: note.title,
                content: note.content,
                imageUrl: note.imageUrl,
              ));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    for (final section in _sections) {
      section.dispose();
    }
    super.dispose();
  }

  void _handleSend() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    // Logic to calculate count based on target
    final members = ref.read(allMembersProvider).value ?? [];
    final events = ref.read(eventsProvider).value ?? [];
    
    List<String> recipientIds = [];
    String targetDesc = '';

    if (_selectedEventId != null) {
      final selectedEvent = ref.read(adminEventsProvider).value?.firstWhereOrNull((e) => e.id == _selectedEventId);
      if (selectedEvent != null) {
        recipientIds = selectedEvent.registrations.map((r) => r.memberId).toSet().toList();
        targetDesc = 'Event Registrants (${selectedEvent.title})';
      }
    } else {
      if (_selectedAudience == null) {
        recipientIds = members.map((m) => m.id).toList();
        targetDesc = 'All Members';
      } else if (_selectedAudience!.isDynamic) {
        recipientIds = SmartAudienceEvaluator.evaluate(
          members: members,
          rules: _selectedAudience!.filterCriteria,
          events: events,
        );
        targetDesc = 'Smart List: ${_selectedAudience!.name}';
      } else {
        recipientIds = _selectedAudience!.memberIds;
        targetDesc = 'Group: ${_selectedAudience!.name}';
      }
    }

    final recipientCount = recipientIds.length;

    showBoxyArtDialog(
      context: context,
      title: 'Confirm Send',
      message: 'You are about to message $recipientCount people ($targetDesc). Confirm?',
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();
        
        setState(() => _isSending = true);
        
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();
        
        // Use the recipientIds and targetDesc we already calculated

        if (recipientIds.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No recipients found.')));
           setState(() => _isSending = false);
           return;
        }

        try {
          // update or create
          final campaignRef = widget.campaignId != null 
              ? firestore.collection('campaigns').doc(widget.campaignId)
              : firestore.collection('campaigns').doc();
          
          final List<EventNote> notes = _sections.map((s) => EventNote(
            title: s.titleController.text,
            content: jsonEncode(s.quillController.document.toDelta().toJson()),
            imageUrl: s.imageUrl,
          )).toList();

          final campaign = Campaign(
            id: campaignRef.id,
            title: _sections.first.titleController.text.isNotEmpty 
                ? _sections.first.titleController.text 
                : 'Untitled Notification',
            category: _category,
            targetType: _selectedAudience?.name ?? 'All Members',
            recipientCount: recipientCount,
            timestamp: DateTime.now(),
            targetDescription: targetDesc,
            status: CampaignStatus.sent,
            notes: notes,
          );

          batch.set(campaignRef, campaign.toJson()..['timestamp'] = FieldValue.serverTimestamp());

          // 2.5 Handle Event Feed Update (Broadcast to Event Feed if applicable)
          if (_selectedEventId != null) {
            final event = await ref.read(eventsRepositoryProvider).getEvent(_selectedEventId!);
            if (event != null) {
              final newItem = EventFeedItem(
                id: widget.feedItemId ?? DateTime.now().millisecondsSinceEpoch.toString(),
                type: FeedItemType.newsletter,
                title: campaign.title,
                content: jsonEncode(notes.map((n) => n.toJson()).toList()),
                createdAt: DateTime.now(),
                isPublished: true,
                sortOrder: widget.feedItemId != null 
                  ? (event.feedItems.firstWhereOrNull((i) => i.id == widget.feedItemId)?.sortOrder ?? 0)
                  : (event.feedItems.isEmpty ? 0 : (event.feedItems.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1)),
              );
              
              final eventRef = firestore.collection('events').doc(_selectedEventId);
              
              final List<EventFeedItem> updatedItems = List.from(event.feedItems);
              if (widget.feedItemId != null) {
                final idx = updatedItems.indexWhere((i) => i.id == widget.feedItemId);
                if (idx != -1) updatedItems[idx] = newItem;
              } else {
                updatedItems.add(newItem);
              }

              batch.update(eventRef, {
                'feedItems': updatedItems.map((i) => i.toJson()).toList(),
              });
            }
          }

          // 3. Create individual User Notifications
          for (final recipientId in recipientIds) {
            final notificationRef = firestore.collection('members').doc(recipientId).collection('notifications').doc();
            batch.set(notificationRef, {
              'id': notificationRef.id,
              'campaignId': campaignRef.id,
              'title': campaign.title,
              'category': _category,
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
              'notes': notes.map((n) => n.toJson()).toList(),
            });
          }

          await batch.commit();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Note published successfully!')),
            );
            context.pop();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error publishing notification: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isSending = false);
        }
      },
    );
  }

  Future<void> _handleSaveDraft() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields to save a draft.')),
      );
      return;
    }

    setState(() => _isSending = true);
    
    final firestore = FirebaseFirestore.instance;

    try {
      final campaignRef = widget.campaignId != null 
          ? firestore.collection('campaigns').doc(widget.campaignId)
          : firestore.collection('campaigns').doc();
      
      final List<EventNote> notes = _sections.map((s) => EventNote(
        title: s.titleController.text,
        content: jsonEncode(s.quillController.document.toDelta().toJson()),
        imageUrl: s.imageUrl,
      )).toList();

      final campaign = Campaign(
        id: campaignRef.id,
        title: _sections.first.titleController.text.isNotEmpty 
            ? _sections.first.titleController.text 
            : 'Draft: $_category',
        category: _category,
        targetType: _selectedAudience == null ? 'All Members' : (_selectedAudience!.isDynamic ? 'Smart List' : 'Group'),
        recipientCount: 0, // Not determined for drafts
        timestamp: DateTime.now(),
        targetDescription: _selectedAudience?.name ?? 'All Members',
        status: CampaignStatus.draft,
        notes: notes,
      );

      final batch = firestore.batch();
      
      // 1. Save global campaign draft
      batch.set(campaignRef, campaign.toJson()..['timestamp'] = FieldValue.serverTimestamp());

      // 2. Sync to Event Feed as draft if event is selected
      if (_selectedEventId != null) {
        final event = await ref.read(eventsRepositoryProvider).getEvent(_selectedEventId!);
        if (event != null) {
          final newItem = EventFeedItem(
            id: widget.feedItemId ?? DateTime.now().millisecondsSinceEpoch.toString(),
            type: FeedItemType.newsletter,
            title: campaign.title,
            content: jsonEncode(notes.map((n) => n.toJson()).toList()),
            createdAt: DateTime.now(),
            isPublished: false, // It's a draft!
            sortOrder: widget.feedItemId != null 
              ? (event.feedItems.firstWhereOrNull((i) => i.id == widget.feedItemId)?.sortOrder ?? 0)
              : 0,
          );
          
          final eventRef = firestore.collection('events').doc(_selectedEventId);
          
          final List<EventFeedItem> updatedItems = List.from(event.feedItems);
          if (widget.feedItemId != null) {
            final idx = updatedItems.indexWhere((i) => i.id == widget.feedItemId);
            if (idx != -1) updatedItems[idx] = newItem;
          } else {
            updatedItems.add(newItem);
          }

          batch.update(eventRef, {
            'feedItems': updatedItems.map((i) => i.toJson()).toList(),
          });
        }
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving draft: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndUploadImage(NotificationSectionController section) async {
    final storageService = ref.read(storageServiceProvider);
    
    try {
      final imageFile = await storageService.pickImage(source: ImageSource.gallery);
      if (imageFile == null) return;

      setState(() => _isUploading = true);

      final downloadUrl = await storageService.uploadImage(
        path: 'notifications',
        file: imageFile,
      );

      setState(() {
        section.imageUrl = downloadUrl;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final events = ref.watch(eventsProvider).value ?? [];
    
    int totalRecipients = 0;
    if (_selectedEventId != null) {
      final selectedEvent = eventsAsync.value?.firstWhereOrNull((e) => e.id == _selectedEventId);
      totalRecipients = selectedEvent?.registrations.length ?? 0;
    } else {
      final members = membersAsync.value ?? [];
      if (_selectedAudience == null) {
        totalRecipients = members.length;
      } else if (_selectedAudience!.isDynamic) {
        totalRecipients = SmartAudienceEvaluator.evaluate(
          members: members, 
          rules: _selectedAudience!.filterCriteria,
          events: events,
        ).length;
      } else {
        totalRecipients = _selectedAudience!.memberIds.length;
      }
    }

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    final content = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Event', isPeeking: true),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventPicker(),
                _buildAudienceCard(totalRecipients),
              ],
            ),
          ),
          
          const BoxyArtSectionTitle(title: 'Message content'),
          ..._sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
              child: _buildMessageForm(section, index),
            );
          }),
          
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.standard),
            child: Row(
              children: [
                Expanded(
                  child: BoxyArtButton(
                    title: 'Save as draft',
                    onTap: _isSending ? null : _handleSaveDraft,
                    isGhost: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BoxyArtButton(
                    title: 'Publish',
                    onTap: _isSending ? null : _handleSend,
                    isLoading: _isSending,
                    backgroundColor: AppColors.actionMidnight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );

    if (widget.isTabbed) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: content,
      );
    }

    return HeadlessScaffold(
      title: (widget.campaignId != null || widget.feedItemId != null) ? 'Edit Note' : 'Compose',
      subtitle: (widget.campaignId != null || widget.feedItemId != null) ? 'NOTE' : 'Push Notification',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverToBoxAdapter(
            child: content,
          ),
        ),
      ],
    );
  }


  Widget _buildAudienceCard(int totalCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final audienceName = _selectedAudience?.name ?? 'All Members';
    final isSmart = _selectedAudience?.isDynamic ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        if (_selectedEventId != null) ...[
          const BoxyArtDivider(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Audience: Event Registrants',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.dark400,
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Push alerts will be sent to registrants but will also be available on event feed',
                      style: AppTypography.subtext.copyWith(
                        color: AppColors.dark400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Reach',
                style: AppTypography.label.copyWith(
                  color: AppColors.dark400,
                  fontWeight: AppTypography.weightSemibold,
                ),
              ),
              BoxyArtPill.status(
                label: '$totalCount members',
                color: AppColors.dark150,
                textColor: isDark ? AppColors.pureWhite : AppColors.dark800,
              ),
            ],
          ),
        ] else ...[
          InkWell(
            onTap: _showAudiencePicker,
            borderRadius: AppShapes.lg,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.dark800 : AppColors.dark50,
                borderRadius: AppShapes.lg,
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  BoxyArtIconBadge(
                    icon: isSmart ? Icons.auto_awesome_rounded : Icons.group_rounded,
                    isPrimary: true,
                    size: 48,
                    iconSize: 24,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUDIENCE',
                          style: AppTypography.micro.copyWith(
                            color: isDark ? AppColors.dark400 : AppColors.dark500,
                            fontWeight: AppTypography.weightBold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          audienceName,
                          style: AppTypography.labelStrong.copyWith(
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalCount',
                        style: AppTypography.displayHeading.copyWith(
                          color: AppColors.lime500,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'REACH',
                        style: AppTypography.micro.copyWith(
                          fontSize: 9,
                          fontWeight: AppTypography.weightBold,
                          color: isDark ? AppColors.dark400 : AppColors.dark500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.dark400 : AppColors.dark300,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showAudiencePicker() {
    final customLists = ref.read(distributionListProvider).value ?? [];
    final members = ref.read(allMembersProvider).value ?? [];
    final events = ref.read(eventsProvider).value ?? [];

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Select Audience',
      child: Column(
        children: [
          // System Defaults
          _buildPickerTile(
            title: 'All Members',
            subtitle: 'Broadcast to everyone in the society',
            icon: Icons.groups_rounded,
            isSelected: _selectedAudience == null,
            count: members.length,
            onTap: () {
              setState(() => _selectedAudience = null);
              Navigator.pop(context);
            },
          ),
          const BoxyArtDivider(),
          const SizedBox(height: AppSpacing.md),
          const BoxyArtSectionTitle(title: 'Saved Lists', isPeeking: true),
          if (customLists.isEmpty)
             Padding(
               padding: const EdgeInsets.all(AppSpacing.xl),
               child: Center(
                 child: Text('No saved lists found', style: AppTypography.micro),
               ),
             )
          else
            ...customLists.map((list) {
              final int count = list.isDynamic 
                  ? SmartAudienceEvaluator.evaluate(members: members, rules: list.filterCriteria, events: events).length
                  : list.memberIds.length;
                  
              return _buildPickerTile(
                title: list.name,
                subtitle: list.isDynamic ? 'Smart List (Auto-updates)' : 'Static List (${list.memberIds.length} members)',
                icon: list.isDynamic ? Icons.auto_awesome_rounded : Icons.group_rounded,
                isSelected: _selectedAudience?.id == list.id,
                count: count,
                onTap: () {
                  setState(() => _selectedAudience = list);
                  Navigator.pop(context);
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: icon,
              isPrimary: isSelected,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelStrong.copyWith(
                      color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.micro.copyWith(
                      color: isDark ? AppColors.dark400 : AppColors.dark300,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$count',
              style: AppTypography.labelStrong.copyWith(
                color: isSelected ? AppColors.lime500 : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.primaryColor, size: 20)
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageForm(NotificationSectionController section, int index) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      borderRadius: AppShapes.rMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Expanded(
                  child: BoxyArtInputField(
                    label: 'Subject',
                    hint: 'Enter subject here...',
                    controller: section.titleController,
                  ),
                ),
               const SizedBox(width: AppSpacing.md),
               Padding(
                 padding: const EdgeInsets.only(top: 26), 
                 child: Row(
                   children: [
                     BoxyArtGlassIconButton(
                       icon: Icons.add_a_photo_rounded,
                       iconSize: 20,
                       onPressed: _isUploading ? null : () => _pickAndUploadImage(section),
                       tooltip: 'Add Photo',
                     ),
                     const SizedBox(width: AppSpacing.sm),
                     if (_sections.length > 1) ...[
                       BoxyArtGlassIconButton(
                         icon: Icons.delete_outline_rounded,
                         iconSize: 20,
                         onPressed: () => setState(() => _sections.removeAt(index)),
                         tooltip: 'Remove Section',
                       ),
                       const SizedBox(width: AppSpacing.sm),
                     ],
                     BoxyArtGlassIconButton(
                       icon: Icons.refresh_rounded,
                       iconSize: 20,
                       onPressed: () => setState(() {
                         section.titleController.clear();
                         section.quillController.document = quill.Document();
                         section.imageUrl = null;
                       }),
                       tooltip: 'Reset Section',
                     ),
                   ],
                 ),
               ),
             ],
          ),
          if (section.imageUrl != null) ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(ref.read(themeControllerProvider).cardRadius),
                  child: Image.network(
                    section.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: BoxyArtGlassIconButton(
                    icon: Icons.close_rounded,
                    iconSize: 16,
                    onPressed: () => setState(() => section.imageUrl = null),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: spacing?.labelToCard ?? AppSpacing.labelToCard),
          BoxyArtRichEditor(
            controller: section.quillController,
            label: 'Content',
            placeholder: 'Message content...',
          ),
          if (index == _sections.length - 1) ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
            BoxyArtDropdownField<String>(
              label: 'Category',
              value: _category,
              items: _categories.map((c) => DropdownMenuItem(
                value: c, 
                child: Text(c, overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
          ],
          
          // Non-linear "+" insertion trigger
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: BoxyArtCircularIconBtn(
              icon: Icons.add_rounded,
              iconSize: 20,
              backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              onTap: () {
                setState(() {
                  _sections.insert(index + 1, NotificationSectionController());
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventPicker() {
    final eventsAsync = ref.watch(adminEventsProvider);
    
    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) return const SizedBox.shrink();
        
        // Sort events by date descending
        final sortedEvents = List<GolfEvent>.from(events)..sort((a, b) => b.date.compareTo(a.date));
        
        return BoxyArtDropdownField<String>(
          label: '',
          hint: 'Select event to post update',
          value: _selectedEventId,
          // width: 280, // Removed fixed width for better responsive card layout
          items: [
            const DropdownMenuItem(value: null, child: Text('No Event (Society Wide)')),
            ...sortedEvents.map((e) => DropdownMenuItem(
              value: e.id, 
              child: Text(
                '${e.title} (${e.date.day}/${e.date.month})',
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          onChanged: (v) => setState(() {
            _selectedEventId = v;
          }),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading events: $e'),
    );
  }
}
