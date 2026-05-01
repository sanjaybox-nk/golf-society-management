import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/widgets/member_tile.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'members_provider.dart';

class MembersScreen extends ConsumerStatefulWidget {
  final bool isAdminContext;
  const MembersScreen({super.key, this.isAdminContext = false});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    final currentFilter = widget.isAdminContext
        ? ref.watch(adminMemberFilterProvider)
        : ref.watch(userMemberFilterProvider);
    
    final searchQuery = (widget.isAdminContext 
        ? ref.watch(adminMemberSearchQueryProvider)
        : ref.watch(memberSearchQueryProvider)).toLowerCase();
        
    final membersAsync = ref.watch(allMembersProvider);
    final memberStatsAsync = ref.watch(memberStatsProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Members',
      subtitle: widget.isAdminContext && currentFilter.type == AdminMemberFilter.role && currentFilter.role != null
          ? 'Assign ${currentFilter.role!.displayName}'
          : (widget.isAdminContext ? 'Society Roster' : 'Members Roster'),
      topPill: widget.isAdminContext ? BoxyArtPill.committee(label: 'ADMIN') : null,
      slivers: [
        // Filter Bar
        SliverToBoxAdapter(
          child: widget.isAdminContext && currentFilter.type == AdminMemberFilter.role
              ? const SizedBox.shrink()
              : ModernUnderlinedFilterBar<AdminMemberFilter>(
                  selectedValue: currentFilter.type,
                  tabs: [
                    ModernFilterTab(label: 'Active', value: AdminMemberFilter.current, icon: Icons.person_rounded),
                    ModernFilterTab(label: 'Committee', value: AdminMemberFilter.committee, icon: Icons.verified_user_rounded),
                    ModernFilterTab(label: 'Other', value: AdminMemberFilter.other, icon: Icons.more_vert_rounded),
                  ],
                  onTabSelected: (filter) {
                    if (widget.isAdminContext) {
                      ref.read(adminMemberFilterProvider.notifier).update(filter);
                    } else {
                      ref.read(userMemberFilterProvider.notifier).update(filter);
                    }
                  },
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
                  isExpanded: false,
                ),
        ),

        // Body Content (Unified Async Handling)
        ...membersAsync.when(
          data: (members) {
            // Calculate filtered list ONCE
            final filtered = members.where((m) {
              final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
              final matchesSearch = name.contains(searchQuery);
              if (!matchesSearch) return false;
              if (widget.isAdminContext && searchQuery.isNotEmpty) return true;
              if (currentFilter.type == AdminMemberFilter.current) {
                return m.status == MemberStatus.member || m.status == MemberStatus.active;
              } else if (currentFilter.type == AdminMemberFilter.committee) {
                return m.societyRole != null && m.societyRole!.isNotEmpty;
              } else if (currentFilter.type == AdminMemberFilter.other) {
                return m.status != MemberStatus.member && m.status != MemberStatus.active;
              } else if (widget.isAdminContext && currentFilter.type == AdminMemberFilter.role) {
                return m.role == currentFilter.role;
              }
              return true;
            }).toList();

            final sortedMembers = [...filtered]..sort((a, b) => a.lastName.compareTo(b.lastName));
            final isUserAdmin = ref.watch(currentUserProvider).role == MemberRole.admin || 
                                ref.watch(currentUserProvider).role == MemberRole.superAdmin;

            return [
              // Search & Count Header
              SliverToBoxAdapter(
                child: BoxyArtSectionTitle(
                  title: 'Search Members',
                  count: filtered.length,
                  isPeeking: false,
                  horizontalPadding: AppSpacing.xl,
                ),
              ),

              // Search Input
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: BoxyArtSearchInput(
                    hintText: 'Search by name...',
                    initialValue: searchQuery,
                    onChanged: (val) {
                      if (widget.isAdminContext) {
                        ref.read(adminMemberSearchQueryProvider.notifier).update(val);
                      } else {
                        ref.read(memberSearchQueryProvider.notifier).update(val);
                      }
                    },
                  ),
                ),
              ),

              // Members List
              SliverPadding(
                padding: EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: (currentFilter.type == AdminMemberFilter.other) ? 0 : (spacing?.cardToCard ?? AppSpacing.cardToCard),
                ),
                sliver: filtered.isEmpty 
                  ? const SliverToBoxAdapter(child: _EmptyMembers())
                  : (currentFilter.type == AdminMemberFilter.other)
                    ? _buildGroupedList(sortedMembers, memberStatsAsync, isUserAdmin, currentFilter, spacing)
                    : _buildFlatList(sortedMembers, memberStatsAsync, isUserAdmin, currentFilter, spacing),
              ),
            ];
          },
          loading: () => [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: BoxyArtLoadingCard(title: 'Searching roster...', isCompact: true),
              ),
            ),
          ],
          error: (err, stack) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: BoxyArtEmptyCard(
                  title: 'Roster Unavailable', 
                  message: 'Error fetching members: $err', 
                  icon: Icons.error_outline_rounded
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupedList(
    List<Member> sortedMembers, 
    AsyncValue<Map<String, int>> memberStatsAsync, 
    bool isUserAdmin, 
    AdminMemberFilterState currentFilter,
    AppSpacingTokens? spacing,
  ) {
    final grouped = <MemberStatus, List<Member>>{};
    for (final m in sortedMembers) {
      grouped.putIfAbsent(m.status, () => []).add(m);
    }

    const statusPriority = {
      MemberStatus.expired: 0,
      MemberStatus.suspended: 1,
      MemberStatus.pending: 2,
      MemberStatus.left: 3,
      MemberStatus.archived: 4,
    };

    final sortedStatuses = grouped.keys.toList()
      ..sort((a, b) => (statusPriority[a] ?? 99).compareTo(statusPriority[b] ?? 99));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final status = sortedStatuses[i];
          final groupMembers = grouped[status]!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxyArtSectionTitle(
                title: status.displayName,
                count: groupMembers.length,
                isPeeking: false, // Ensures we use tabToContent (16px) or cardToLabel (16px)
                followsCard: i > 0,
                horizontalPadding: 0, // Since parent SliverPadding already handles horizontal
              ),
              ...groupMembers.asMap().entries.map((entry) {
                final m = entry.value;
                final isLastGroupMember = entry.key == groupMembers.length - 1;
                final eventCount = memberStatsAsync.value?[m.id] ?? 0;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLastGroupMember ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                  child: _buildMemberItem(context, ref, m, widget.isAdminContext, isUserAdmin, currentFilter, eventCount),
                );
              }),
            ],
          );
        },
        childCount: sortedStatuses.length,
      ),
    );
  }

  Widget _buildFlatList(
    List<Member> sortedMembers, 
    AsyncValue<Map<String, int>> memberStatsAsync, 
    bool isUserAdmin, 
    AdminMemberFilterState currentFilter,
    AppSpacingTokens? spacing,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final m = sortedMembers[index];
          final isLast = index == sortedMembers.length - 1;
          final eventCount = memberStatsAsync.value?[m.id] ?? 0;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
            child: _buildMemberItem(context, ref, m, widget.isAdminContext, isUserAdmin, currentFilter, eventCount),
          );
        },
        childCount: sortedMembers.length,
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context, 
    WidgetRef ref, 
    Member m, 
    bool isAdminContext, 
    bool isUserAdmin,
    AdminMemberFilterState currentFilter,
    int eventCount,
  ) {
    final isAlreadyInRole = m.role == currentFilter.role;

    return Dismissible(
      key: Key('member_${m.id}'),
      direction: isAdminContext ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.coral500,
          borderRadius: BorderRadius.circular(AppShapes.rMd),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite),
      ),
      confirmDismiss: (direction) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => BoxyArtDialog(
            title: 'Delete Member?',
            message: 'Delete ${m.firstName} ${m.lastName}?',
            confirmText: 'Delete',
            isDangerous: true,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (_) {
        ref.read(membersRepositoryProvider).deleteMember(m.id);
      },
      child: MemberTile(
        member: m,
        isAdminContext: isAdminContext,
        showFeeStatus: isAdminContext,
        eventCount: eventCount,
        trailing: isAdminContext && currentFilter.type == AdminMemberFilter.role && !isAlreadyInRole
            ? BoxyArtButton(
                title: 'Assign',
                isSmall: true,
                onTap: () async {
                  await ref.read(membersRepositoryProvider).updateMember(m.copyWith(role: currentFilter.role!));
                },
              )
            : null,
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
