import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/theme/app_theme.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/models/distribution_list.dart';
import 'distribution_list_provider.dart';
import 'package:golf_society/models/member.dart';

class AudienceManagerScreen extends ConsumerStatefulWidget {
  const AudienceManagerScreen({super.key});

  @override
  ConsumerState<AudienceManagerScreen> createState() => _AudienceManagerScreenState();
}

class _AudienceManagerScreenState extends ConsumerState<AudienceManagerScreen> {
  void _showCreateListDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateListModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(distributionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const BoxyArtAppBar(title: 'Communications Hub', showBack: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              'Your Distribution Lists'.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: lists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No custom lists yet', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BoxyArtFloatingCard(
                          onTap: () {
                             // Future: Edit list
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryYellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.group, color: Colors.black),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(list.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${list.memberIds.length} members', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Create List', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class CreateListModal extends ConsumerStatefulWidget {
  const CreateListModal({super.key});

  @override
  ConsumerState<CreateListModal> createState() => _CreateListModalState();
}

class _CreateListModalState extends ConsumerState<CreateListModal> {
  final _nameController = TextEditingController();
  final Set<String> _selectedMemberIds = {};
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMember(String id) {
    setState(() {
      if (_selectedMemberIds.contains(id)) {
        _selectedMemberIds.remove(id);
      } else {
        _selectedMemberIds.add(id);
      }
    });
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a list name')));
      return;
    }
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one member')));
      return;
    }

    final newList = DistributionList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      memberIds: _selectedMemberIds.toList(),
      createdAt: DateTime.now(),
    );

    ref.read(distributionListProvider.notifier).addList(newList);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Distribution list created!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Create Distribution List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
          ),
          
          // Form Fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                BoxyArtFormField(
                  label: 'List Name',
                  controller: _nameController,
                  hintText: 'e.g. Committee 2026',
                ),
                const SizedBox(height: 20),
                BoxyArtSearchBar(
                  hintText: 'Search members to add...',
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Selection Stats & Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedMemberIds.length} members selected',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                membersAsync.when(
                  data: (members) {
                    final allSelected = _selectedMemberIds.length == members.length;
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          if (allSelected) {
                            _selectedMemberIds.clear();
                          } else {
                            _selectedMemberIds.addAll(members.map((m) => m.id));
                          }
                        });
                      },
                      child: Text(allSelected ? 'Deselect All' : 'Select All'),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Member List
          Expanded(
            child: membersAsync.when(
              data: (members) {
                final filtered = members.where((m) {
                  final name = '${m.firstName} ${m.lastName}'.toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No members found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    final isSelected = _selectedMemberIds.contains(m.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => _toggleMember(m.id),
                      title: Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(m.email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      activeColor: Colors.black,
                      checkColor: AppTheme.primaryYellow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error: $e')),
            ),
          ),
          
          // Footer Action
          Padding(
            padding: const EdgeInsets.all(24),
            child: BoxyArtButton(
              title: 'Create Distribution List',
              onTap: _save,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
