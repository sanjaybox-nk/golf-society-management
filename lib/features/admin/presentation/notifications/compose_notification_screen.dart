import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/theme/app_theme.dart';
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
      onCancel: () => Navigator.pop(context),
      onConfirm: () async {
        Navigator.pop(context);
        
        // Write to Firestore using the repository
        try {
          // Note: Using 'current_user_id' as recipient for testing purposes
          // In a real app, we would loop through 'members' and create a doc for each
          await FirebaseFirestore.instance.collection('notifications').add({
              'recipientId': 'current_user_id', // Target for our test user
              'title': _titleController.text,
              'message': _bodyController.text,
              'category': _category,
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
              'actionUrl': _deepLinkAction,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification sent successfully!')),
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

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Step 1: Who is this for?'),
            const SizedBox(height: 12),
            _buildTargetSelector(totalRecipients),
            const SizedBox(height: 32),
            _buildSectionHeader('Step 2: The Message'),
            const SizedBox(height: 12),
            _buildMessageForm(),
            const SizedBox(height: 32),
            _buildSectionHeader('Step 3: Deep Link'),
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
    );

    if (widget.isTabbed) {
      return Scaffold(
        appBar: const BoxyArtAppBar(title: 'Compose Notification', showBack: true),
        body: content,
      );
    }

    return Scaffold(
      appBar: const BoxyArtAppBar(title: 'Compose Notification', showBack: true),
      body: content,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTargetSelector(int totalCount) {
    final customListsAsync = ref.watch(distributionListProvider);
    final customLists = customListsAsync.value ?? [];
    final members = ref.watch(allMembersProvider).value ?? [];

    return BoxyArtFloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _targetOptions.map((opt) {
                final isSelected = _targetType == opt;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _targetType = opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        opt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.black : Colors.black54,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Approx. $totalCount recipients',
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            
          if (_targetType == 'Groups')
            if (customLists.isEmpty)
              Container(
                 padding: const EdgeInsets.all(16),
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: Colors.grey.shade100,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.shade300),
                 ),
                 child: const Center(
                   child: Text(
                     'No groups found. Create one in Audience Manager.',
                     style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                   ),
                 ),
              )
            else
              DropdownButtonFormField<DistributionList>(
                value: _selectedCustomList,
                hint: const Text('Select Audience Group'),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                items: customLists.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedCustomList = v;
                  });
                },
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
                    return BoxyArtFormField(
                      label: 'Target Member',
                      controller: controller,
                      focusNode: focusNode,
                      hintText: 'Search by name...',
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMessageForm() {
    return BoxyArtFloatingCard(
      child: Column(
        children: [
          BoxyArtFormField(
            label: 'Title',
            controller: _titleController,
            hintText: 'e.g. Course Closed',
            validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          BoxyArtFormField(
            label: 'Body',
            controller: _bodyController,
            hintText: 'Enter your message details...',
            maxLines: 4,
            validator: (v) => v?.trim().isEmpty == true ? 'Body is required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepLinkSelector() {
    return BoxyArtFloatingCard(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _deepLinkAction,
            decoration: const InputDecoration(
              labelText: 'Open Screen on Tap',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            items: _deepLinkOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) => setState(() => _deepLinkAction = v!),
          ),
          if (_deepLinkAction == 'Event Details') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedEventId,
              hint: const Text('Select Upcoming Event'),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
