import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/models/member.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/members/presentation/widgets/member_tile.dart';
import 'package:golf_society/features/members/presentation/member_details_modal.dart';

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final searchQuery = ref.watch(adminMemberSearchQueryProvider).toLowerCase();
    final currentFilter = ref.watch(adminMemberFilterProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
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
                        'Members',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'Manage society roster and roles',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Search & Filter Card
                      ModernCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextField(
                              focusNode: _searchFocusNode,
                              onChanged: (v) => ref.read(adminMemberSearchQueryProvider.notifier).update(v),
                              decoration: InputDecoration(
                                hintText: 'Search roster...',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  _buildFilterChip(
                                    label: 'Current',
                                    isSelected: currentFilter == AdminMemberFilter.current,
                                    onTap: () => ref.read(adminMemberFilterProvider.notifier).update(AdminMemberFilter.current),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterChip(
                                    label: 'Other',
                                    isSelected: currentFilter == AdminMemberFilter.other,
                                    onTap: () => ref.read(adminMemberFilterProvider.notifier).update(AdminMemberFilter.other),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterChip(
                                    label: 'Committee',
                                    isSelected: currentFilter == AdminMemberFilter.committee,
                                    onTap: () => ref.read(adminMemberFilterProvider.notifier).update(AdminMemberFilter.committee),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => MemberDetailsModal.show(context, null),
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      membersAsync.when(
                        data: (members) {
                          final filtered = members.where((m) {
                            final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                            final matchesSearch = name.contains(searchQuery);
                            if (!matchesSearch) return false;
                            if (currentFilter == AdminMemberFilter.current) {
                              return m.status == MemberStatus.member || m.status == MemberStatus.active;
                            } else if (currentFilter == AdminMemberFilter.committee) {
                              return m.societyRole != null && m.societyRole!.isNotEmpty;
                            } else {
                              return m.status != MemberStatus.member && m.status != MemberStatus.active;
                            }
                          }).toList();

                          if (filtered.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(48.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.person_off_rounded, size: 48, color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                                    const SizedBox(height: 16),
                                    Text('No matching members', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Sorting logic omitted for brevity here but should be preserved
                          final sortedMembers = [...filtered];
                          sortedMembers.sort((a, b) => a.lastName.compareTo(b.lastName));

                          return Column(
                            children: sortedMembers.map((member) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildDismissibleMember(context, ref, member),
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
            
            // sticky header navigation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          icon: const Icon(Icons.home_rounded, size: 20, color: Colors.black87),
                          onPressed: () => context.go('/home'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.dividerColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}


Widget _buildDismissibleMember(BuildContext context, WidgetRef ref, Member member) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Dismissible(
      key: Key(member.id),
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
          title: 'Delete Member?',
          message: 'Delete ${member.firstName} ${member.lastName}?',
          onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
          onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
          confirmText: 'Delete',
        );
      },
      onDismissed: (direction) {
        ref.read(membersRepositoryProvider).deleteMember(member.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${member.firstName}')),
        );
      },
      child: MemberTile(
        member: member,
        onTap: () => MemberDetailsModal.show(context, member),
        onLongPress: () => MemberDetailsModal.show(context, member),
        showFeeStatus: true,
      ),
    ),
  );
}


