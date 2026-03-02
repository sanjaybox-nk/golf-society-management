import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'distribution_list_provider.dart';
import 'package:golf_society/domain/models/distribution_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _bodyController = TextEditingController();
  String _category = 'Urgent';
  
  // Deep Link
  String _deepLinkAction = 'None (Just Read)';
  String? _selectedEventId;

  final List<String> _targetOptions = ['All Members', 'Groups', 'Individual'];
  final List<String> _categories = ['Urgent', 'Event', 'News', 'Committee Business'];
  final List<String> _deepLinkOptions = ['None (Just Read)', 'Event Details', 'Fee Payment', 'Member Profile'];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
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
          
          final campaignData = {
              'id': campaignRef.id,
              'title': _titleController.text,
              'message': _bodyController.text,
              'category': _category,
              'targetType': _targetType,
              'targetDescription': targetDesc,
              'recipientCount': recipientIds.length,
              'timestamp': timestamp,
              'actionUrl': _deepLinkAction,
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
                 'message': _bodyController.text,
                 'category': _category,
                 'timestamp': timestamp,
                 'isRead': false,
                 'actionUrl': _deepLinkAction,
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
      _bodyController.clear();
      _targetType = 'All Members';
      _selectedCustomList = null;
      _selectedMember = null;
      _category = 'Urgent';
      _deepLinkAction = 'None (Just Read)';
      _selectedEventId = null;
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
          const SizedBox(height: AppSpacing.x3l),
          
          const BoxyArtSectionTitle(title: 'Interaction'),
          const SizedBox(height: AppSpacing.md),
          _buildDeepLinkSelector(),
          const SizedBox(height: AppSpacing.x4l),
          
          BoxyArtButton(
            title: 'Send Notification',
            onTap: _handleSend,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.x3l),
        ],
      ),
    );

    if (widget.isTabbed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
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
                            color: AppColors.lime500.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Text(
                        opt,
                        textAlign: TextAlign.center,
                        style: AppTypography.label.copyWith(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? AppColors.actionText : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lime500.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lime500.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lime500.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.people_rounded, size: 16, color: AppColors.lime500),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Reach: approx. $totalCount members',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.lime500,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            
          if (_targetType == 'Groups')
            if (customLists.isEmpty)
            Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.group_off_rounded, size: 32, color: theme.dividerColor.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
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
                      prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
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
        children: [
          BoxyArtInputField(
            label: 'Subject',
            hint: 'Short summary...',
            controller: _titleController,
          ),
          const SizedBox(height: 20),
          BoxyArtInputField(
            label: 'Message Body',
            hint: 'Compose your message details...',
            controller: _bodyController,
            maxLines: 5,
          ),
          const SizedBox(height: 20),
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

  Widget _buildDeepLinkSelector() {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          BoxyArtDropdownField<String>(
            label: 'Action on Tap',
            value: _deepLinkAction,
            items: _deepLinkOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) => setState(() => _deepLinkAction = v!),
          ),
          if (_deepLinkAction == 'Event Details') ...[
            const SizedBox(height: 20),
            BoxyArtDropdownField<String>(
              label: 'Select Event',
              value: _selectedEventId,
              hint: 'Select Upcoming Event',
              items: [
                const DropdownMenuItem(value: '1', child: Text('Monthly Medal - Augusta')),
                const DropdownMenuItem(value: '2', child: Text('Captain Day - Sunningdale')),
              ],
              onChanged: (v) => setState(() => _selectedEventId = v),
            ),
          ],
        ],
      ),
    );
  }
}
