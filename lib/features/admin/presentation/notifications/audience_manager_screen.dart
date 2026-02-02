import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/models/distribution_list.dart';
import 'distribution_list_provider.dart';
import 'firestore_distribution_lists_repository.dart';

class AudienceManagerScreen extends ConsumerStatefulWidget {
  const AudienceManagerScreen({super.key});

  @override
  ConsumerState<AudienceManagerScreen> createState() => _AudienceManagerScreenState();
}

class _AudienceManagerScreenState extends ConsumerState<AudienceManagerScreen> {
  void _showCreateListDialog({DistributionList? listToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateListModal(listToEdit: listToEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(distributionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(
            title: 'Your Distribution Lists',
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
          ),
          Expanded(
            child: listsAsync.when(
              data: (lists) {
                if (lists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No custom lists yet', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Dismissible(
                        key: Key(list.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (direction) async {
                          return await showBoxyArtDialog<bool>(
                            context: context,
                            title: 'Delete List?',
                            message: 'Delete list "${list.name}"?',
                            onCancel: () => Navigator.of(context).pop(false),
                            onConfirm: () => Navigator.of(context).pop(true),
                            confirmText: 'Delete',
                          );
                        },
                        onDismissed: (_) {
                          ref.read(distributionListsRepositoryProvider).deleteList(list.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted ${list.name}')),
                          );
                        },
                        child: BoxyArtFloatingCard(
                          onTap: () => _showCreateListDialog(listToEdit: list),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create List', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class CreateListModal extends ConsumerStatefulWidget {
  final DistributionList? listToEdit;
  const CreateListModal({super.key, this.listToEdit});

  @override
  ConsumerState<CreateListModal> createState() => _CreateListModalState();
}

class _CreateListModalState extends ConsumerState<CreateListModal> {
  final _nameController = TextEditingController();
  final Set<String> _selectedMemberIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.listToEdit != null) {
      _nameController.text = widget.listToEdit!.name;
      _selectedMemberIds.addAll(widget.listToEdit!.memberIds);
    }
  }

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

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a list name')));
      return;
    }
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one member')));
      return;
    }

    final repo = ref.read(distributionListsRepositoryProvider);

    if (widget.listToEdit != null) {
      // Update
      final updatedList = widget.listToEdit!.copyWith(
        name: _nameController.text.trim(),
        memberIds: _selectedMemberIds.toList(),
      );
      await repo.updateList(updatedList);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List updated successfully!')),
      );
    } else {
      // Create
      final newList = DistributionList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        memberIds: _selectedMemberIds.toList(),
        createdAt: DateTime.now(),
      );
      await repo.createList(newList);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distribution list created!'), backgroundColor: Colors.green),
      );
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final isEditing = widget.listToEdit != null;
    
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
                Text(isEditing ? 'Edit Distribution List' : 'Create Distribution List', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          
          // Selected Members Chips
          if (_selectedMemberIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: membersAsync.when(
                data: (members) {
                  final selectedMembers = members.where((m) => _selectedMemberIds.contains(m.id)).toList();
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedMembers.map((m) {
                      return Chip(
                        label: Text('${m.firstName} ${m.lastName}'),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        deleteIcon: const Icon(Icons.close, size: 18, color: Colors.black54),
                        onDeleted: () => _toggleMember(m.id),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stackTrace) => const SizedBox(),
              ),
            ),
          
          // Selection Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
               '${_selectedMemberIds.length} members selected',
               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
             ),
          ),
          
          const Divider(),
          
          // Search Results
          Expanded(
            child: membersAsync.when(
              data: (members) {
                final filtered = members.where((m) {
                  final term = _searchQuery.trim();
                  if (term.isEmpty) return false;

                  final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                  final email = m.email.toLowerCase();
                  final matches = name.contains(term) || email.contains(term);
                  
                  // Only show if matching search AND NOT already selected (since they are in chips)
                  return matches && !_selectedMemberIds.contains(m.id);
                }).toList();

                if (filtered.isEmpty) {
                  if (_searchQuery.isEmpty) {
                     return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Type name or email to add members...',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No new members found matching criteria'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    return CheckboxListTile(
                      value: false, // Always false because we filter out selected ones
                      onChanged: (_) => _toggleMember(m.id),
                      title: Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(m.email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      activeColor: Colors.black,
                      checkColor: Theme.of(context).primaryColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),          
          // Footer Action
          Padding(
            padding: const EdgeInsets.all(24),
            child: BoxyArtButton(
              title: isEditing ? 'Save Changes' : 'Create Distribution List',
              onTap: _save,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
