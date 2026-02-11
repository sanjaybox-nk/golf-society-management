import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/models/member.dart';
import 'distribution_list_provider.dart';
import 'package:golf_society/models/distribution_list.dart';
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
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BoxyArtSectionTitle(title: 'Target Audience', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              _buildTargetSelector(totalRecipients),
              const SizedBox(height: 32),
              
              const BoxyArtSectionTitle(title: 'Message Content', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              _buildMessageForm(),
              const SizedBox(height: 32),
              
              const BoxyArtSectionTitle(title: 'Interaction', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              _buildDeepLinkSelector(),
              const SizedBox(height: 48),
              
              BoxyArtButton(
                title: 'Send Notification',
                onTap: _handleSend,
                fullWidth: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTargetSelector(int totalCount) {
    final customListsAsync = ref.watch(distributionListProvider);
    final customLists = customListsAsync.value ?? [];
    final members = ref.watch(allMembersProvider).value ?? [];
    final theme = Theme.of(context);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14),
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
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        opt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          
          if (_targetType == 'All Members') 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.people_rounded, size: 16, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Reach: approx. $totalCount members',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
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
                     const Text(
                       'No audience groups found',
                       style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                     ),
                   ],
                 ),
              )
            else
              DropdownButtonFormField<DistributionList>(
              initialValue: _selectedCustomList,
                hint: const Text('Select Audience Group'),
                decoration: InputDecoration(
                  labelText: 'Target Group',
                  labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: theme.dividerColor.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Search Member',
                        labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                        hintText: 'Start typing name...',
                        prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
                        filled: true,
                        fillColor: theme.dividerColor.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMessageForm() {
    final theme = Theme.of(context);
    return ModernCard(
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Subject',
              labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              hintText: 'Short summary...',
              hintStyle: TextStyle(color: theme.dividerColor.withValues(alpha: 0.3)),
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          TextField(
            controller: _bodyController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Message Body',
              labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              hintText: 'Compose your message details...',
              hintStyle: TextStyle(color: theme.dividerColor.withValues(alpha: 0.3)),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: theme.dividerColor.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepLinkSelector() {
    final theme = Theme.of(context);
    return ModernCard(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _deepLinkAction,
            decoration: InputDecoration(
              labelText: 'Action on Tap',
              labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: theme.dividerColor.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: _deepLinkOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) => setState(() => _deepLinkAction = v!),
          ),
          if (_deepLinkAction == 'Event Details') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedEventId,
              hint: const Text('Select Upcoming Event'),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.dividerColor.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
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
