import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Audience Groups',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Manage custom mailing lists',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    listsAsync.when(
                      data: (lists) {
                        if (lists.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(48.0),
                              child: Column(
                                children: [
                                  Icon(Icons.group_work_rounded, size: 48, color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No custom groups found',
                                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: lists.map((list) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Dismissible(
                              key: Key(list.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                              ),
                              confirmDismiss: (direction) async {
                                return await showBoxyArtDialog<bool>(
                                  context: context,
                                  title: 'Delete Group?',
                                  message: 'Are you sure you want to delete "${list.name}"?',
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
                              child: ModernCard(
                                onTap: () => _showCreateListDialog(listToEdit: list),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.group_rounded, color: Theme.of(context).primaryColor, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            list.name, 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                          ),
                                          Text(
                                            '${list.memberIds.length} members', 
                                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13, fontWeight: FontWeight.w500)
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          )).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
          
          // Back Button sticky
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button sticky
          Positioned(
            bottom: 32,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _showCreateListDialog,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Group', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Audience' : 'New Audience', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.black54, size: 20),
                  ),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'List Name',
                            labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                            hintText: 'e.g. Committee 2026',
                            hintStyle: TextStyle(color: theme.dividerColor.withValues(alpha: 0.3)),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const BoxyArtSectionTitle(title: 'Selected Members', padding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  if (_selectedMemberIds.isNotEmpty)
                    membersAsync.when(
                      data: (members) {
                        final selectedMembers = members.where((m) => _selectedMemberIds.contains(m.id)).toList();
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedMembers.map((m) {
                            return Chip(
                              label: Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                              deleteIcon: Icon(Icons.close_rounded, size: 16, color: theme.primaryColor),
                              onDeleted: () => _toggleMember(m.id),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (error, stackTrace) => const SizedBox(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        'No members selected yet',
                        style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  const BoxyArtSectionTitle(title: 'Add Members', padding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  ModernCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  membersAsync.when(
                    data: (members) {
                      final filtered = members.where((m) {
                        final term = _searchQuery.trim();
                        if (term.isEmpty) return false;

                        final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                        final email = m.email.toLowerCase();
                        final matches = name.contains(term) || email.contains(term);
                        return matches && !_selectedMemberIds.contains(m.id);
                      }).toList();

                      if (filtered.isEmpty && _searchQuery.isNotEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text('No matching members found', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
                          ),
                        );
                      }

                      return Column(
                        children: filtered.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ModernCard(
                            onTap: () => _toggleMember(m.id),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.dividerColor.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_add_rounded, size: 18, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(m.email, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: 20),
                              ],
                            ),
                          ),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Footer Action
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                BoxyArtButton(
                  title: isEditing ? 'Save Changes' : 'Create Audience',
                  onTap: _save,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
