import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/widgets/member_tile.dart';

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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    


    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: HeadlessScaffold(
        title: 'Members',
        subtitle: currentFilter.type == AdminMemberFilter.role && currentFilter.role != null
            ? 'Assign ${currentFilter.role!.displayName}'
            : 'Society Roster',
        titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
        leading: Center(
          child: BoxyArtGlassIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
            tooltip: 'Back to Dashboard',
          ),
        ),
        actions: [
          BoxyArtGlassIconButton(
            icon: Icons.person_add_alt_1_rounded,
            tooltip: 'Add Member',
            onPressed: () => context.push('/admin/members/new'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        slivers: [
          // Tab Bar Standardized
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hide Tabs if Role Filter is active
                if (currentFilter.type != AdminMemberFilter.role) ...[
                  ModernUnderlinedFilterBar<AdminMemberFilter>(
                    selectedValue: currentFilter.type,
                    onTabSelected: (filter) => ref.read(adminMemberFilterProvider.notifier).update(filter),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    isExpanded: true,
                    tabs: [
                      const ModernFilterTab(label: 'Active', value: AdminMemberFilter.current),
                      const ModernFilterTab(label: 'Committee', value: AdminMemberFilter.committee),
                      const ModernFilterTab(label: 'Other', value: AdminMemberFilter.other),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Standardized Search Input
                // Design 4.1 Search Bar (Image 2)
                BoxyArtSearchInput(
                  label: 'Search members',
                  hintText: 'Search roster...',
                  initialValue: searchQuery,
                  onChanged: (v) => ref.read(adminMemberSearchQueryProvider.notifier).update(v),
                ),
                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),

                // Members List
                membersAsync.when(
                  data: (members) {
                    final filtered = members.where((m) {
                      final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                      final matchesSearch = name.contains(searchQuery);
                      if (!matchesSearch) return false;

                      // If search query is present, show matching members regardless of filters (Global Search)
                      if (searchQuery.isNotEmpty) return true;

                      if (currentFilter.type == AdminMemberFilter.current) {
                        return m.status == MemberStatus.member || m.status == MemberStatus.active;
                      } else if (currentFilter.type == AdminMemberFilter.committee) {
                        return m.societyRole != null && m.societyRole!.isNotEmpty;
                      } else if (currentFilter.type == AdminMemberFilter.other) {
                        return m.status != MemberStatus.member && m.status != MemberStatus.active;
                      } else if (currentFilter.type == AdminMemberFilter.role) {
                        return m.role == currentFilter.role;
                      }
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.x2l),
                        child: BoxyArtEmptyCard(
                          title: 'No Matching Members',
                          message: searchQuery.isNotEmpty 
                              ? 'No members matching "$searchQuery" found in this category.'
                              : 'This roster section is currently empty.',
                          icon: Icons.person_search_rounded,
                          actionLabel: searchQuery.isNotEmpty ? 'Clear Search' : null,
                          onAction: searchQuery.isNotEmpty 
                              ? () => ref.read(adminMemberSearchQueryProvider.notifier).update('')
                              : null,
                        ),
                      );
                    }

                    final sortedMembers = [...filtered];
                    sortedMembers.sort((a, b) => a.lastName.compareTo(b.lastName));

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
                                    isPeeking: i == 0, // 8px below search, 16px below cards
                                  ),
                                  ...groupMembers.asMap().entries.map((entry) {
                                    final m = entry.value;
                                    final eventCount = memberStatsAsync.value?[m.id] ?? 0;
                                    final isAlreadyInRole = m.role == currentFilter.role;
                                    final isLastGroupMember = entry.key == groupMembers.length - 1;

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: isLastGroupMember ? 0 : (spacing?.cardToCard ?? AppSpacing.md),
                                      ),
                                      child: _buildDismissibleMember(
                                        context, 
                                        ref, 
                                        m,
                                        secondaryMetricLabel: 'Events',
                                        secondaryMetricValue: '$eventCount',
                                        trailing: currentFilter.type == AdminMemberFilter.role && !isAlreadyInRole
                                            ? BoxyArtButton(
                                                title: 'Assign',
                                                isSmall: true,
                                                onTap: () async {
                                                  final messenger = ScaffoldMessenger.of(context);
                                                  final confirmed = await showBoxyArtDialog<bool>(
                                                    context: context,
                                                    title: 'Assign Role?',
                                                    message: 'Assign ${m.firstName} as ${currentFilter.role!.displayName}?',
                                                    confirmText: 'Assign',
                                                  );
                                                  if (confirmed == true) {
                                                    ref.read(membersRepositoryProvider).updateMember(
                                                      m.copyWith(role: currentFilter.role!),
                                                    );
                                                    messenger.showSnackBar(
                                                      SnackBar(content: Text('${m.firstName} is now ${currentFilter.role!.displayName}')),
                                                    );
                                                  }
                                                },
                                              )
                                            : isAlreadyInRole 
                                                ? BoxyArtPill(label: 'Current', color: AppColors.lime500, hasHorizontalMargin: false)
                                                : null,
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
                      children: sortedMembers.map((member) {
                        final eventCount = memberStatsAsync.value?[member.id] ?? 0;
                        final isAlreadyInRole = member.role == currentFilter.role;

                        return Padding(
                          padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.md),
                          child: _buildDismissibleMember(
                            context, 
                            ref, 
                            member,
                            secondaryMetricLabel: 'Events',
                            secondaryMetricValue: '$eventCount',
                            trailing: currentFilter.type == AdminMemberFilter.role && !isAlreadyInRole
                                ? BoxyArtButton(
                                    title: 'Assign',
                                    isSmall: true,
                                    onTap: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final confirmed = await showBoxyArtDialog<bool>(
                                        context: context,
                                        title: 'Assign Role?',
                                        message: 'Assign ${member.firstName} as ${currentFilter.role!.displayName}?',
                                        confirmText: 'Assign',
                                      );
                                      if (confirmed == true) {
                                        ref.read(membersRepositoryProvider).updateMember(
                                          member.copyWith(role: currentFilter.role!),
                                        );
                                        messenger.showSnackBar(
                                          SnackBar(content: Text('${member.firstName} is now ${currentFilter.role!.displayName}')),
                                        );
                                      }
                                    },
                                  )
                                : isAlreadyInRole 
                                    ? BoxyArtPill(label: 'Current', color: AppColors.lime500, hasHorizontalMargin: false)
                                    : null,
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
    );
  }


}


Widget _buildDismissibleMember(
  BuildContext context, 
  WidgetRef ref, 
  Member member, {
  String? secondaryMetricLabel,
  String? secondaryMetricValue,
  Widget? trailing,
}) {
  return Dismissible(
      key: Key(member.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.coral500.withValues(alpha: AppColors.opacityHigh),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.x2l),
        child: const Icon(Icons.delete_outline, color: AppColors.pureWhite, size: AppShapes.iconLg),
      ),
      confirmDismiss: (direction) async {
        return await showBoxyArtDialog<bool>(
          context: context,
          title: 'Delete Member?',
          message: 'Delete ${member.firstName} ${member.lastName}?',
          confirmText: 'Delete',
          isDangerous: true,
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
        onTap: () => context.pushNamed('admin-member-detail', pathParameters: {'id': member.id}),
        onLongPress: () => context.pushNamed('admin-member-detail', pathParameters: {'id': member.id}),
        showFeeStatus: true,
        isAdminContext: true,
        secondaryMetricLabel: secondaryMetricLabel,
        secondaryMetricValue: secondaryMetricValue,
        trailing: trailing,
    ),
  );
}


