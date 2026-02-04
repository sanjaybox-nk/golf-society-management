import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../models/member.dart';
import 'members_provider.dart';
import 'member_details_modal.dart';
import 'widgets/member_tile.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
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
    final searchQuery = ref.watch(memberSearchQueryProvider).toLowerCase();
    final currentFilter = ref.watch(userMemberFilterProvider); // Using user filter provider
    final isFocused = _searchFocusNode.hasFocus;

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: const BoxyArtAppBar(
          title: 'Members',
          isLarge: true,
          showLeading: false, // As per previous request to remove menu icon
        ),
        body: membersAsync.when(
          data: (members) {
            final filtered = members.where((m) {
              final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
              final matchesSearch = name.contains(searchQuery);
              
              if (!matchesSearch) return false;

              // Filter logic adapted for User view
              if (currentFilter == AdminMemberFilter.current) {
                return m.status == MemberStatus.member || 
                       m.status == MemberStatus.active;
              } else if (currentFilter == AdminMemberFilter.committee) {
                return m.societyRole != null && m.societyRole!.isNotEmpty;
              } else {
                // "Other" - everything not active/member
                return m.status != MemberStatus.member && 
                       m.status != MemberStatus.active;
              }
            }).toList();

            final sortedMembers = [...filtered]..sort((a, b) => a.lastName.compareTo(b.lastName));

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: sortedMembers.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  String sectionTitle = 'Current Members';
                  if (currentFilter == AdminMemberFilter.other) {
                    sectionTitle = 'Other Members';
                  } else if (currentFilter == AdminMemberFilter.committee) {
                    sectionTitle = 'Committee Members';
                  }
                  
                  return BoxyArtSectionTitle(
                    title: sectionTitle,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  );
                }
                if (index == 1) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: BoxyArtSearchBar(
                            focusNode: _searchFocusNode,
                            hintText: 'Search members...',
                            onChanged: (value) {
                              ref.read(memberSearchQueryProvider.notifier).update(value);
                            },
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: isFocused ? 0 : 12,
                          child: const SizedBox(),
                        ),
                          // Compact Toggle Switch (Identical to Admin)
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
                                      onTap: () => ref.read(userMemberFilterProvider.notifier).update(AdminMemberFilter.current),
                                    ),
                                    _buildToggleOption(
                                      context: context,
                                      label: 'O',
                                      isSelected: currentFilter == AdminMemberFilter.other,
                                      onTap: () => ref.read(userMemberFilterProvider.notifier).update(AdminMemberFilter.other),
                                    ),
                                    _buildToggleOption(
                                      context: context,
                                      label: '★',
                                      isSelected: currentFilter == AdminMemberFilter.committee,
                                      onTap: () => ref.read(userMemberFilterProvider.notifier).update(AdminMemberFilter.committee),
                                      isIcon: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // No Add Button here for User view
                      ],
                    ),
                  );
                }

                if (sortedMembers.isEmpty && index == 2) {
                   return const _EmptyMembers();
                }
                
                if (index - 2 < sortedMembers.length) {
                  final m = sortedMembers[index - 2];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // Added vertical padding for spacing
                    child: MemberTile(
                      member: m,
                      onTap: () => MemberDetailsModal.show(context, m),
                      // No onLongPress or Dismissible for standard users
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
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

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No members found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
