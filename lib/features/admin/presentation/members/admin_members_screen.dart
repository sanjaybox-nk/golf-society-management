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
    final isFocused = _searchFocusNode.hasFocus;

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: BoxyArtAppBar(
        title: 'Manage Members',
        isLarge: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white, size: 28),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/admin/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No members found.'));
          }

          final filtered = members.where((m) {
            final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
            final matchesSearch = name.contains(searchQuery);
            
            if (!matchesSearch) return false;

            if (currentFilter == AdminMemberFilter.current) {
              return m.status == MemberStatus.member || 
                     m.status == MemberStatus.active;
            } else if (currentFilter == AdminMemberFilter.committee) {
              return m.societyRole != null && m.societyRole!.isNotEmpty;
            } else {
              // Other
              return m.status != MemberStatus.member && 
                     m.status != MemberStatus.active;
            }
          }).toList();

          // Sort
          final sortedMembers = [...filtered];
          if (currentFilter == AdminMemberFilter.other) {
            // Define sort order for Other statuses
            final statusOrder = [
              MemberStatus.pending,
              MemberStatus.suspended,
              MemberStatus.inactive,
              MemberStatus.archived,
              MemberStatus.left,
            ];
            
            sortedMembers.sort((a, b) {
              final statusCompare = statusOrder.indexOf(a.status).compareTo(statusOrder.indexOf(b.status));
              if (statusCompare != 0) return statusCompare;
              return a.lastName.compareTo(b.lastName);
            });
          } else {
            // Default sort
            sortedMembers.sort((a, b) => a.lastName.compareTo(b.lastName));
          }

          // Build List Items (including headers)
          final List<Widget> listItems = [];
          
          // 1. Top Section Title
          if (currentFilter == AdminMemberFilter.current) {
             listItems.add(const BoxyArtSectionTitle(
               title: 'Current Members',
               padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
             ));
          } else if (currentFilter == AdminMemberFilter.committee) {
             listItems.add(const BoxyArtSectionTitle(
               title: 'Committee Members',
               padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
             ));
          } else {
             // For Other, we don't need a top generic title if we have sub-headers, 
             // OR we keep it as a main header. 
             // Let's keep "Other Members" for consistency, then sub-headers.
             listItems.add(const BoxyArtSectionTitle(
               title: 'Other Members',
               padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
             ));
          }

          // 2. Search & Toggle Row
          listItems.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: BoxyArtSearchBar(
                      focusNode: _searchFocusNode,
                      hintText: 'Search members...',
                      onChanged: (value) {
                        ref.read(adminMemberSearchQueryProvider.notifier).update(value);
                      },
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: isFocused ? 0 : 12,
                    child: const SizedBox(),
                  ),
                  // Compact Toggle Switch
                  ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerLeft,
                      widthFactor: isFocused ? 0 : 1,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isFocused ? 0 : 1,
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildToggleOption(
                                context: context,
                                label: 'C',
                                isSelected: currentFilter == AdminMemberFilter.current,
                                onTap: () => ref.read(adminMemberFilterProvider.notifier).update(AdminMemberFilter.current),
                              ),
                              _buildToggleOption(
                                context: context,
                                label: 'O',
                                isSelected: currentFilter == AdminMemberFilter.other,
                                onTap: () => ref.read(adminMemberFilterProvider.notifier).update(AdminMemberFilter.other),
                              ),
                              _buildToggleOption(
                                context: context,
                                label: '★',
                                isSelected: currentFilter == AdminMemberFilter.committee,
                                onTap: () => ref.read(adminMemberFilterProvider.notifier).update(AdminMemberFilter.committee),
                                isIcon: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: isFocused ? 0 : 8,
                    child: const SizedBox(),
                  ),
                  ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerLeft,
                      widthFactor: isFocused ? 0 : 1,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isFocused ? 0 : 1,
                        child: IconButton(
                          icon: Icon(
                            Icons.person_add,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          onPressed: () => MemberDetailsModal.show(context, null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          // 3. Member List with Sub-Headers
          MemberStatus? lastStatus;
          
          for (var member in sortedMembers) {
            // Insert Sub-Header for "Other" filter only
            if (currentFilter == AdminMemberFilter.other) {
              if (member.status != lastStatus) {
                listItems.add(
                   Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      member.status.displayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.grey.shade500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  )
                );
                lastStatus = member.status;
              }
            }
            
            listItems.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildDismissibleMember(context, ref, member),
              )
            );
          }

          return DefaultTabController(
            length: 2,
            initialIndex: currentFilter == AdminMemberFilter.current ? 0 : 1,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: listItems.length,
              itemBuilder: (context, index) => listItems[index],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    ),
    );
  }

  Widget _buildToggleOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isIcon 
            ? Icon(
                Icons.star_rounded, 
                size: 20, 
                color: isSelected ? Colors.white : Colors.amber.shade600
              )
            : Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
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


