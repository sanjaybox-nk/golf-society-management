import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/distribution_list.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'firestore_distribution_lists_repository.dart';

class DistributionListModal extends ConsumerStatefulWidget {
  final DistributionList? listToEdit;
  const DistributionListModal({super.key, this.listToEdit});

  @override
  ConsumerState<DistributionListModal> createState() => _DistributionListModalState();
}

class _DistributionListModalState extends ConsumerState<DistributionListModal> {
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
      final updatedList = widget.listToEdit!.copyWith(
        name: _nameController.text.trim(),
        memberIds: _selectedMemberIds.toList(),
      );
      await repo.updateList(updatedList);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('List updated successfully!')));
    } else {
      final newList = DistributionList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        memberIds: _selectedMemberIds.toList(),
        createdAt: DateTime.now(),
      );
      await repo.createList(newList);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distribution list created!'), backgroundColor: AppColors.lime500),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rPill)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Audience' : 'New Audience', 
                  style: const TextStyle(fontSize: AppTypography.sizeDisplaySubPage, fontWeight: AppTypography.weightBold, letterSpacing: -0.5)
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: BoxyArtInputField(
                      label: 'List Name',
                      hint: 'e.g. Committee 2026',
                      controller: _nameController,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  const BoxyArtSectionTitle(title: 'Selected Members'),
                  const SizedBox(height: AppSpacing.md),
                  if (_selectedMemberIds.isNotEmpty)
                    membersAsync.when(
                      data: (members) {
                        final selectedMembers = members.where((m) => _selectedMemberIds.contains(m.id)).toList();
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedMembers.map((m) {
                            return Chip(
                              label: Text('${m.firstName} ${m.lastName}'),
                              onDeleted: () => _toggleMember(m.id),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    )
                  else
                    const Center(child: Text('No members selected yet')),
                  
                  const SizedBox(height: AppSpacing.x2l),
                  const BoxyArtSectionTitle(title: 'Add Members'),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtInputField(
                    label: 'Search Members',
                    hint: 'Search by name or email...',
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  membersAsync.when(
                    data: (members) {
                      final filtered = members.where((m) {
                        final term = _searchQuery.trim();
                        if (term.isEmpty) return false;
                        return (m.firstName + m.lastName).toLowerCase().contains(term) && !_selectedMemberIds.contains(m.id);
                      }).toList();
                      return Column(
                        children: filtered.map((m) => ListTile(
                          title: Text('${m.firstName} ${m.lastName}'),
                          subtitle: Text(m.email),
                          trailing: const Icon(Icons.add),
                          onTap: () => _toggleMember(m.id),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: BoxyArtButton(
              title: isEditing ? 'Save Changes' : 'Create Audience',
              onTap: _save,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
