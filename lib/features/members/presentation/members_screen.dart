import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'members_provider.dart';
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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final membersAsync = ref.watch(allMembersProvider);
    final searchQuery = ref.watch(memberSearchQueryProvider).toLowerCase();
    final currentFilter = ref.watch(userMemberFilterProvider);
    final memberStatsAsync = ref.watch(memberStatsProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

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
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: HeadlessScaffold(
        title: 'Members',
        subtitle: 'Members Roster',
        backgroundColor: beigeBackground,
        slivers: [
          SliverToBoxAdapter(
            child: ModernUnderlinedFilterBar<AdminMemberFilter>(
              selectedValue: currentFilter.type,
              onTabSelected: (filter) => ref.read(userMemberFilterProvider.notifier).update(filter),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              tabs: [
                ModernFilterTab(label: 'Active ($activeCount)', value: AdminMemberFilter.current),
                ModernFilterTab(label: 'Committee ($committeeCount)', value: AdminMemberFilter.committee),
                ModernFilterTab(label: 'Other ($otherCount)', value: AdminMemberFilter.other),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl, 
              0, 
              AppSpacing.xl, 
              spacing?.cardToLabel ?? AppSpacing.cardToLabel
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),

                const BoxyArtSectionTitle(
                  title: 'Search Members',
                  isPeeking: true,
                ),

                // Standardized Search Input
                // Design 4.1 Search Bar (Image 2)
                BoxyArtSearchInput(
                  hintText: 'Search names...',
                  initialValue: searchQuery,
                  onChanged: (v) => ref.read(memberSearchQueryProvider.notifier).update(v),
                ),

                // Unified spacing below search box for all tabs/states (16px)
                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
                
                // Members List
                membersAsync.when(
                  data: (members) {
                    final theme = Theme.of(context);
                    final filtered = members.where((m) {
                      final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                      final matchesSearch = name.contains(searchQuery);
                      if (!matchesSearch) return false;

                      if (currentFilter.type == AdminMemberFilter.current) {
                        return m.status == MemberStatus.member || m.status == MemberStatus.active;
                      } else if (currentFilter.type == AdminMemberFilter.committee) {
                        return m.societyRole != null && m.societyRole!.isNotEmpty;
                      } else {
                        return m.status != MemberStatus.member && m.status != MemberStatus.active;
                      }
                    }).toList();

                    if (filtered.isEmpty) {
                      return const _EmptyMembers();
                    }

                    final sortedMembers = [...filtered]..sort((a, b) => a.lastName.compareTo(b.lastName));
                    
                    if (currentFilter.type == AdminMemberFilter.other) {
                      // Group by status
                      final grouped = <MemberStatus, List<Member>>{};
                      for (final m in sortedMembers) {
                        grouped.putIfAbsent(m.status, () => []).add(m);
                      }

                      // Define display order for status groups
                      const statusPriority = {
                        MemberStatus.expired: 0,
                        MemberStatus.suspended: 1,
                        MemberStatus.pending: 2,
                        MemberStatus.left: 3,
                        MemberStatus.archived: 4,
                      };

                      final sortedStatuses = grouped.keys.toList()
                        ..sort((a, b) => (statusPriority[a] ?? 99).compareTo(statusPriority[b] ?? 99));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < sortedStatuses.length; i++) ...[
                            () {
                              final status = sortedStatuses[i];
                              final groupMembers = grouped[status]!;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BoxyArtSectionTitle(
                                    title: status.displayName,
                                    count: groupMembers.length,
                                    // Use isPeeking for the very first group to align with search box spacer
                                    isPeeking: i == 0, 
                                  ),
                                  ...groupMembers.asMap().entries.map((entry) {
                                    final m = entry.value;
                                    final isLastGroupMember = entry.key == groupMembers.length - 1;
                                    final eventCount = memberStatsAsync.value?[m.id] ?? 0;
                                    
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: isLastGroupMember ? AppSpacing.xl : (spacing?.cardToCard ?? AppSpacing.standard),
                                      ),
                                      child: MemberTile(
                                        member: m,
                                        onTap: () => context.pushNamed('member-detail', pathParameters: {'id': m.id}),
                                        secondaryMetricLabel: 'Events',
                                        secondaryMetricValue: '$eventCount',
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }(),
                          ],
                        ],
                      );
                    }

                    return Column(
                      children: sortedMembers.asMap().entries.map((entry) {
                        final m = entry.value;
                        final isLast = entry.key == sortedMembers.length - 1;
                        final eventCount = memberStatsAsync.value?[m.id] ?? 0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                          child: MemberTile(
                            member: m,
                            onTap: () => context.pushNamed('member-detail', pathParameters: {'id': m.id}),
                            secondaryMetricLabel: 'Events',
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



}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    return const BoxyArtEmptyCard(
      title: 'No Members Found',
      message: 'The roster is currently empty or no members match your search criteria.',
      icon: Icons.person_off_outlined,
    );
  }
}
