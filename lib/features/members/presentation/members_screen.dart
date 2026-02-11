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
    final currentFilter = ref.watch(userMemberFilterProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: beigeBackground,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 100),
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
                      const SizedBox(height: 24),
                      
                      // Search Card
                      ModernCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                focusNode: _searchFocusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Search members...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (val) => ref.read(memberSearchQueryProvider.notifier).update(val),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Filter Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Active', AdminMemberFilter.current),
                            _buildFilterChip('Committee', AdminMemberFilter.committee),
                            _buildFilterChip('Other', AdminMemberFilter.other),
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

                          final sortedMembers = [...filtered]..sort((a, b) => a.lastName.compareTo(b.lastName));

                          if (sortedMembers.isEmpty) {
                            return const _EmptyMembers();
                          }

                          return Column(
                            children: sortedMembers.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: MemberTile(
                                  member: m,
                                  onTap: () => MemberDetailsModal.show(context, m),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('Error: $err')),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AdminMemberFilter filter) {
    final currentFilter = ref.watch(userMemberFilterProvider);
    final isSelected = currentFilter == filter;
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => ref.read(userMemberFilterProvider.notifier).update(filter),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
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
