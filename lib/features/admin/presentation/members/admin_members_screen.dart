import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final memberStatsAsync = ref.watch(memberStatsProvider); // Watch stats
    
    // Calculate filter counts
    int activeCount = 0;
    int committeeCount = 0;
    int otherCount = 0;
    
    if (membersAsync.hasValue) {
      final members = membersAsync.value!;
      activeCount = members.where((m) => m.status == MemberStatus.member || m.status == MemberStatus.active).length;
      committeeCount = members.where((m) => m.societyRole != null && m.societyRole!.isNotEmpty).length;
      otherCount = members.where((m) => m.status != MemberStatus.member && m.status != MemberStatus.active).length;
    }

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: HeadlessScaffold(
        title: 'Members',
        subtitle: 'Manage society roster and roles',
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Search & Filter Card
                ModernCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          onChanged: (v) => ref.read(adminMemberSearchQueryProvider.notifier).update(v),
                          decoration: const InputDecoration(
                            hintText: 'Search roster...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                          ),
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
                      _buildFilterChip(
                        label: 'Active ($activeCount)',
                        filter: AdminMemberFilter.current,
                      ),
                      _buildFilterChip(
                        label: 'Committee ($committeeCount)',
                        filter: AdminMemberFilter.committee,
                      ),
                      _buildFilterChip(
                        label: 'Other ($otherCount)',
                        filter: AdminMemberFilter.other,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Members List
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
                      } else if (currentFilter == AdminMemberFilter.other) {
                        return m.status != MemberStatus.member && m.status != MemberStatus.active;
                      }
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Text('No matching members'),
                        ),
                      );
                    }

                    final sortedMembers = [...filtered];
                    sortedMembers.sort((a, b) => a.lastName.compareTo(b.lastName));

                    return Column(
                      children: sortedMembers.map((member) {
                        final eventCount = memberStatsAsync.value?[member.id] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDismissibleMember(
                            context, 
                            ref, 
                            member,
                            secondaryMetricLabel: 'EVENTS',
                            secondaryMetricValue: '$eventCount',
                          ),
                        );
                      }).toList(),
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
    );
  }

  Widget _buildFilterChip({
    required String label,
    required AdminMemberFilter filter,
  }) {
    final currentFilter = ref.watch(adminMemberFilterProvider);
    final isSelected = currentFilter == filter;
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => ref.read(adminMemberFilterProvider.notifier).update(filter),
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


Widget _buildDismissibleMember(
  BuildContext context, 
  WidgetRef ref, 
  Member member, {
  String? secondaryMetricLabel,
  String? secondaryMetricValue,
}) {
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
        secondaryMetricLabel: secondaryMetricLabel,
        secondaryMetricValue: secondaryMetricValue,
      ),
    ),
  );
}


