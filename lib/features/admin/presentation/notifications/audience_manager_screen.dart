import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/distribution_list.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audience Groups',
                        style: AppTypography.displayHeading,
                      ),
                      Text(
                        'Manage custom mailing lists',
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: AppTypography.sizeBodySmall,
                          color: isDark ? AppColors.dark150 : AppColors.dark300,
                        ),
                      ),
                    ],
                  ),
                  BoxyArtGlassIconButton(
                    icon: Icons.add_rounded,
                    onPressed: () => _showCreateListDialog(),
                    tooltip: 'New Group',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),
              
              listsAsync.when(
                data: (lists) {
                  if (lists.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.x5l),
                        child: Column(
                          children: [
                            Icon(Icons.group_work_rounded, size: AppShapes.iconHero, color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityMedium)),
                            const SizedBox(height: AppSpacing.lg),
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
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Dismissible(
                        key: Key(list.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                              color: AppColors.coral500.withValues(alpha: AppColors.opacityHigh),
                            borderRadius: AppShapes.lg,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.x2l),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite, size: AppShapes.iconLg),
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
                        child: BoxyArtCard(
                          onTap: () => _showCreateListDialog(listToEdit: list),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityLow),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.group_rounded, color: Theme.of(context).primaryColor, size: AppShapes.iconLg),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      list.name, 
                                      style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightExtraBold),
                                    ),
                                    Text(
                                      '${list.memberIds.length} members', 
                                      style: AppTypography.label.copyWith(
                                        color: isDark ? AppColors.dark200 : AppColors.dark400,
                                        fontSize: AppTypography.sizeCaptionStrong,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: isDark ? AppColors.dark300 : AppColors.dark200, size: AppShapes.iconXs),
                            ],
                          ),
                        ),
                      ),
                    )).toList(),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
              ),
              const SizedBox(height: 130),
            ]),
          ),
        ),
      ],
    );

    return content;
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
                  style: const TextStyle(fontSize: AppTypography.sizeDisplaySubPage, fontWeight: AppTypography.weightBold, letterSpacing: -0.5)
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: AppColors.opacitySubtle),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, color: Colors.black.withValues(alpha: 0.54), size: AppShapes.iconMd),
                  ),
                ),
              ],
            ),
          ),
          
          // Form Content
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
                  
                  const BoxyArtSectionTitle(title: 'Selected Members', ),
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
                              label: Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightSemibold)),
                              backgroundColor: theme.primaryColor.withValues(alpha: AppColors.opacityLow),
                              deleteIcon: Icon(Icons.close_rounded, size: AppShapes.iconSm, color: theme.primaryColor),
                              onDeleted: () => _toggleMember(m.id),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (error, stackTrace) => const SizedBox(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: AppColors.opacitySubtle),
                        borderRadius: AppShapes.lg,
                        border: Border.all(color: theme.dividerColor.withValues(alpha: AppColors.opacityLow)),
                      ),
                      child: Text(
                        'No members selected yet',
                        style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: AppTypography.sizeLabelStrong, fontWeight: AppTypography.weightMedium),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: AppSpacing.x2l),
                  const BoxyArtSectionTitle(title: 'Add Members', ),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                    child: BoxyArtInputField(
                      label: 'Search Members',
                      hint: 'Search by name or email...',
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      prefixIcon: const Icon(Icons.search_rounded, size: AppShapes.iconMd),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
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
                            padding: const EdgeInsets.all(AppSpacing.x2l),
                            child: Text('No matching members found', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: AppTypography.sizeLabelStrong)),
                          ),
                        );
                      }

                      return Column(
                        children: filtered.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: BoxyArtCard(
                            onTap: () => _toggleMember(m.id),
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: theme.dividerColor.withValues(alpha: AppColors.opacitySubtle),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_add_rounded, size: AppShapes.iconSm, color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBodySmall)),
                                      Text(m.email, style: TextStyle(fontSize: AppTypography.sizeLabel, color: theme.textTheme.bodySmall?.color, fontWeight: AppTypography.weightMedium)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: AppShapes.iconMd),
                              ],
                            ),
                          ),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                  const SizedBox(height: AppSpacing.x4l),
                ],
              ),
            ),
          ),
          
          // Footer Action
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: AppShadows.softScale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.lg),
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
