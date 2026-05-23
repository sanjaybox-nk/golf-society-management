import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/member_group_config.dart';
import 'package:golf_society/domain/groups/member_group_helper.dart';
import 'package:golf_society/features/admin/data/member_group_config_repository.dart';
import 'package:golf_society/features/members/presentation/widgets/member_tile.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/guests/presentation/guests_provider.dart';
import 'members_provider.dart';
import '../../events/presentation/events_provider.dart';

final _activeMemberGroupConfigProvider = FutureProvider.autoDispose<MemberGroupConfig?>((ref) async {
  final season = ref.watch(activeSeasonProvider).value;
  if (season?.memberGroupConfigId == null) return null;
  return ref.read(memberGroupConfigRepositoryProvider).getConfig(season!.memberGroupConfigId!);
});

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
    final memberGroupConfig = ref.watch(_activeMemberGroupConfigProvider).value;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Members',
      subtitle: widget.isAdminContext && currentFilter.type == AdminMemberFilter.role && currentFilter.role != null
          ? 'Assign ${currentFilter.role!.displayName}'
          : (widget.isAdminContext ? 'Society Roster' : 'Members Roster'),
      topPill: widget.isAdminContext ? BoxyArtIndicator.committee(label: 'ADMIN') : null,
      slivers: [
        // Filter Bar
        SliverToBoxAdapter(
          child: widget.isAdminContext && currentFilter.type == AdminMemberFilter.role
              ? const SizedBox.shrink()
              : BoxyArtTabBar<AdminMemberFilter>(
                  selectedValue: currentFilter.type,
                  tabs: [
                    const ModernFilterTab(label: 'Active', value: AdminMemberFilter.current),
                    const ModernFilterTab(label: 'Committee', value: AdminMemberFilter.committee),
                    const ModernFilterTab(label: 'Other', value: AdminMemberFilter.other),
                    if (widget.isAdminContext)
                      const ModernFilterTab(label: 'Guests', value: AdminMemberFilter.guests),
                  ],
                  onTabSelected: (filter) {
                    if (widget.isAdminContext) {
                      ref.read(adminMemberFilterProvider.notifier).update(filter);
                    } else {
                      ref.read(userMemberFilterProvider.notifier).update(filter);
                    }
                  },
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
                ),
        ),

        // Guest list tab (admin only)
        if (widget.isAdminContext && currentFilter.type == AdminMemberFilter.guests)
          ..._buildGuestList(context),

        // Body Content (Unified Async Handling)
        if (currentFilter.type != AdminMemberFilter.guests)
        ...membersAsync.when(
          data: (members) {
            // Calculate filtered list ONCE
            const memberVisibleStatuses = {MemberStatus.active, MemberStatus.member, MemberStatus.social};

            final filtered = members.where((m) {
              if (!widget.isAdminContext && !memberVisibleStatuses.contains(m.status)) return false;

              final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
              final divisionLabel = memberGroupConfig != null
                  ? (MemberGroupHelper.groupForMember(m, memberGroupConfig)?.name ?? '').toLowerCase()
                  : '';
              final handicapStr = m.handicap.toStringAsFixed(1);
              final email = m.email.toLowerCase();
              final societyRole = (m.societyRole ?? '').toLowerCase();
              final statusLabel = m.status.displayName.toLowerCase();
              final roleLabel = m.role.displayName.toLowerCase();
              final matchesSearch = name.contains(searchQuery) ||
                  divisionLabel.contains(searchQuery) ||
                  handicapStr.contains(searchQuery) ||
                  email.contains(searchQuery) ||
                  societyRole.contains(searchQuery) ||
                  statusLabel.contains(searchQuery) ||
                  roleLabel.contains(searchQuery);
              if (!matchesSearch) return false;
              if (searchQuery.isNotEmpty) return true;
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
                    hintText: 'Search by name, status, role, handicap…',
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
                  top: spacing?.cardToCard ?? AppSpacing.cardToCard,
                ),
                sliver: filtered.isEmpty 
                  ? const SliverToBoxAdapter(child: _EmptyMembers())
                  : (currentFilter.type == AdminMemberFilter.other)
                    ? _buildGroupedList(sortedMembers, isUserAdmin, currentFilter, spacing, memberGroupConfig)
                    : _buildFlatList(sortedMembers, isUserAdmin, currentFilter, spacing, memberGroupConfig),
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

  List<Widget> _buildGuestList(BuildContext context) {
    final guestsAsync = ref.watch(filteredGuestsProvider);
    final query = ref.watch(guestSearchQueryProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return [
      SliverToBoxAdapter(
        child: BoxyArtSectionTitle(
          title: 'Search Guests',
          count: guestsAsync.value?.length,
          isPeeking: false,
          horizontalPadding: AppSpacing.xl,
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: BoxyArtSearchInput(
            hintText: 'Search by name or email...',
            initialValue: query,
            onChanged: (val) => ref.read(guestSearchQueryProvider.notifier).update(val),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: spacing?.cardToCard ?? AppSpacing.cardToCard,
        ),
        sliver: guestsAsync.when(
          data: (guests) => guests.isEmpty
              ? const SliverToBoxAdapter(
                  child: BoxyArtEmptyCard(
                    title: 'No Guests Yet',
                    message: 'Guests are created when a member registers a guest for an event.',
                    icon: Icons.person_add_rounded,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final g = guests[index];
                      final isLast = index == guests.length - 1;
                      final parts = g.name.trim().split(' ').where((p) => p.isNotEmpty).toList();
                      final initials = parts.length >= 2
                          ? '${parts.first[0]}${parts[1][0]}'.toUpperCase()
                          : (parts.isNotEmpty ? parts.first[0].toUpperCase() : '?');
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.cardToCard)),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final leadingWidth = constraints.maxWidth * 0.30;
                            return BoxyArtMemberRow(
                              name: g.name,
                              secondaryName: 'Guest',
                              initials: initials,
                              handicapIndex: g.handicap,
                              useCard: true,
                              showChevron: true,
                              showVerticalDivider: true,
                              onTap: () => context.pushNamed('admin-guest-detail', pathParameters: {'id': g.id}),
                              leading: SizedBox(
                                width: leadingWidth,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BoxyArtAvatar(
                                      initials: initials,
                                      radius: 32,
                                      isCircle: true,
                                      borderColor: Colors.transparent,
                                      borderWidth: 0,
                                    ),
                                    if (g.lastPlayedAt != null) ...[
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        child: Text(
                                          'Since ${g.lastPlayedAt!.year}',
                                          style: AppTypography.micro.copyWith(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? AppColors.dark200
                                                : AppColors.dark800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: guests.length,
                  ),
                ),
          loading: () => const SliverToBoxAdapter(child: BoxyArtLoadingCard(title: 'Loading guests...', isCompact: true)),
          error: (e, _) => SliverToBoxAdapter(child: BoxyArtEmptyCard(title: 'Error', message: '$e', icon: Icons.error_outline_rounded)),
        ),
      ),
    ];
  }


  Widget _buildGroupedList(
    List<Member> sortedMembers,
    bool isUserAdmin,
    AdminMemberFilterState currentFilter,
    AppSpacingTokens? spacing,
    MemberGroupConfig? memberGroupConfig,
  ) {
    final grouped = <MemberStatus, List<Member>>{};
    for (final m in sortedMembers) {
      grouped.putIfAbsent(m.status, () => []).add(m);
    }

    const statusPriority = {
      MemberStatus.social: 0,
      MemberStatus.expired: 1,
      MemberStatus.gracePeriod: 2,
      MemberStatus.suspended: 3,
      MemberStatus.pending: 4,
      MemberStatus.inactive: 5,
      MemberStatus.left: 6,
      MemberStatus.archived: 7,
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
                return Padding(
                  padding: EdgeInsets.only(bottom: isLastGroupMember ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                  child: _buildMemberItem(context, ref, m, widget.isAdminContext, isUserAdmin, currentFilter, memberGroupConfig),
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
    bool isUserAdmin,
    AdminMemberFilterState currentFilter,
    AppSpacingTokens? spacing,
    MemberGroupConfig? memberGroupConfig,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final m = sortedMembers[index];
          final isLast = index == sortedMembers.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
            child: _buildMemberItem(context, ref, m, widget.isAdminContext, isUserAdmin, currentFilter, memberGroupConfig),
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
    MemberGroupConfig? memberGroupConfig,
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
        memberGroupConfig: memberGroupConfig,
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
