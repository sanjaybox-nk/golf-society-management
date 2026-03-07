import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'distribution_list_provider.dart';
import 'package:golf_society/domain/models/distribution_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

class ComposeNotificationScreen extends ConsumerStatefulWidget {
  final bool isTabbed;
  const ComposeNotificationScreen({super.key, this.isTabbed = false});

  @override
  ConsumerState<ComposeNotificationScreen> createState() => _ComposeNotificationScreenState();
}

class _ComposeNotificationScreenState extends ConsumerState<ComposeNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Targeting
  String _targetType = 'All Members'; // 'All Members', 'Groups', 'Individual'
  DistributionList? _selectedCustomList;
  Member? _selectedMember; // For Individual targets
  
  // Message
  final _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  String _category = 'Urgent';
  
  final List<String> _targetOptions = ['All Members', 'Groups', 'Individual'];
  final List<String> _categories = ['Urgent', 'Event', 'News', 'Committee Business'];

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
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
    int recipientCount = 0;
    final members = ref.read(allMembersProvider).value ?? [];
    
    if (_targetType == 'All Members') {
      recipientCount = members.length;
    } else if (_targetType == 'Groups') {
      if (_selectedCustomList != null) {
          recipientCount = _selectedCustomList!.memberIds.length;
      } else {
          // Dummy for fixed groups
          recipientCount = 10; 
      }
    } else {
      recipientCount = 1;
    }

    showBoxyArtDialog(
      context: context,
      title: 'Confirm Send',
      message: 'You are about to message $recipientCount people. Confirm?',
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();
        
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();
        
        // 1. Identify Recipients
        List<String> recipientIds = [];
        String targetDesc = '';

        if (_targetType == 'All Members') {
          recipientIds = members.map((m) => m.id).toList();
          targetDesc = 'All Members';
        } else if (_targetType == 'Groups') {
          if (_selectedCustomList != null) {
             recipientIds = _selectedCustomList!.memberIds;
             targetDesc = _selectedCustomList!.name;
          }
        } else if (_targetType == 'Individual') {
           if (_selectedMember != null) {
             recipientIds = [_selectedMember!.id];
             targetDesc = '${_selectedMember!.firstName} ${_selectedMember!.lastName}';
           }
        }

        if (recipientIds.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No recipients found.')));
           return;
        }

        try {
          // 2. Create Campaign Doc (The "Blast" Record)
          final campaignRef = firestore.collection('campaigns').doc();
          final timestamp = FieldValue.serverTimestamp();
          final messageContent = jsonEncode(_quillController.document.toDelta().toJson());
          
          final campaignData = {
              'id': campaignRef.id,
              'title': _titleController.text,
              'message': messageContent,
              'category': _category,
              'targetType': _targetType,
              'targetDescription': targetDesc,
              'recipientCount': recipientIds.length,
              'timestamp': timestamp,
              'sentByUserId': 'admin_console', // Placeholder until Auth
          };
          batch.set(campaignRef, campaignData);

          // 3. Fan-out: Create Notification Doc for each user
          for (final userId in recipientIds) {
             final notifRef = firestore.collection('notifications').doc();
             batch.set(notifRef, {
                 'id': notifRef.id,
                 'recipientId': userId,
                 'campaignId': campaignRef.id, // Link back to campaign
                 'title': _titleController.text,
                 'message': messageContent,
                 'category': _category,
                 'timestamp': timestamp,
                 'isRead': false,
             });
          }

          // 4. Commit (Simple batch for now, assuming <500 recipients)
          // If >500, we would need to chunk this loop.
          await batch.commit();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sent to ${recipientIds.length} members successfully!')),
            );
            
            if (widget.isTabbed) {
              _resetForm();
            } else {
              context.pop();
            }
          }
        } catch (e) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error sending: $e')),
                );
            }
        }
      },
    );
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _quillController.document = quill.Document();
      _targetType = 'All Members';
      _selectedCustomList = null;
      _selectedMember = null;
      _category = 'Urgent';
    });
  }
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final totalRecipients = membersAsync.value?.length ?? 0;

    final content = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Target Audience'),
          const SizedBox(height: AppSpacing.md),
          _buildTargetSelector(totalRecipients),
          const SizedBox(height: AppSpacing.x3l),
          
          const BoxyArtSectionTitle(title: 'Message Content'),
          const SizedBox(height: AppSpacing.md),
          _buildMessageForm(),
          const SizedBox(height: AppSpacing.x4l),
          
          BoxyArtButton(
            title: 'Send Notification',
            onTap: _handleSend,
            fullWidth: true,
          ),
          const SizedBox(height: 150),
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
      title: 'Compose',
      subtitle: 'Push Notification',
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


  Widget _buildTargetSelector(int totalCount) {
    final customListsAsync = ref.watch(distributionListProvider);
    final customLists = customListsAsync.value ?? [];
    final members = ref.watch(allMembersProvider).value ?? [];
    final theme = Theme.of(context);

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Design 3.1 Segmented Control
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: AppColors.opacityHalf),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(color: theme.dividerColor.withValues(alpha: AppColors.opacitySubtle)),
            ),
            child: Row(
              children: _targetOptions.map((opt) {
                final isSelected = _targetType == opt;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _targetType = opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.lime500 : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.lime500.withValues(alpha: AppColors.opacityMedium),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Text(
                        opt,
                        textAlign: TextAlign.center,
                        style: AppTypography.label.copyWith(
                          fontSize: AppTypography.sizeLabel,
                          fontWeight: isSelected ? AppTypography.weightBlack : AppTypography.weightSemibold,
                          color: isSelected ? AppColors.actionText : theme.textTheme.bodyMedium?.color?.withValues(alpha: AppColors.opacityHalf),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          if (_targetType == 'All Members') 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lime500.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.md,
                border: Border.all(color: AppColors.lime500.withValues(alpha: AppColors.opacityLow)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.people_rounded, size: AppShapes.iconSm, color: AppColors.lime500),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Reach: approx. $totalCount members',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.lime500,
                      fontWeight: AppTypography.weightExtraBold,
                    ),
                  ),
                ],
              ),
            ),
            
          if (_targetType == 'Groups')
            if (customLists.isEmpty)
            Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: AppColors.opacitySubtle),
                    borderRadius: AppShapes.lg,
                    border: Border.all(color: theme.dividerColor.withValues(alpha: AppColors.opacityLow)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.group_off_rounded, size: AppShapes.iconXl, color: theme.dividerColor.withValues(alpha: AppColors.opacityMuted)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No audience groups found',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.dark300),
                      ),
                    ],
                  ),
               )
            else
              BoxyArtDropdownField<DistributionList>(
                label: 'Target Group',
                value: _selectedCustomList,
                hint: 'Select Audience Group',
                items: customLists.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                onChanged: (v) => setState(() => _selectedCustomList = v),
              ),
            
          if (_targetType == 'Individual')
             Autocomplete<Member>(
                  displayStringForOption: (m) => '${m.firstName} ${m.lastName}',
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') return const Iterable<Member>.empty();
                    return members.where((m) => '${m.firstName} ${m.lastName}'.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (Member s) => setState(() => _selectedMember = s),
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return BoxyArtInputField(
                      label: 'Search Member',
                      hint: 'Start typing name...',
                      controller: controller,
                      focusNode: focusNode,
                      prefixIcon: const Icon(Icons.person_search_rounded, size: AppShapes.iconMd),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMessageForm() {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             children: [
               Expanded(
                 child: BoxyArtInputField(
                   label: 'Subject',
                   hint: 'Subject...',
                   controller: _titleController,
                 ),
               ),
               const SizedBox(width: AppSpacing.sm),
               IconButton(
                 icon: const Icon(Icons.add_a_photo_rounded, color: AppColors.lime500),
                 onPressed: () {
                   // In a real app, this would use image_picker and insert into Quill
                 },
               ),
               IconButton(
                 icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                 onPressed: _resetForm,
               ),
             ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const BoxyArtSectionTitle(title: 'CONTENT'),
          const SizedBox(height: AppSpacing.md),
          BoxyArtRichEditor(
            controller: _quillController,
            placeholder: 'Message content...',
          ),
          const SizedBox(height: AppSpacing.xl),
          BoxyArtDropdownField<String>(
            label: 'Category',
            value: _category,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
        ],
      ),
    );
  }
}
