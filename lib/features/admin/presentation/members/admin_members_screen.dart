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
        titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
        subtitle: currentFilter.type == AdminMemberFilter.role && currentFilter.role != null
            ? 'Assign ${currentFilter.role!.displayName}'
            : 'Society Roster',
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
                      ModernFilterTab(label: 'Active ($activeCount)', value: AdminMemberFilter.current),
                      ModernFilterTab(label: 'Committee ($committeeCount)', value: AdminMemberFilter.committee),
                      ModernFilterTab(label: 'Other ($otherCount)', value: AdminMemberFilter.other),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const BoxyArtSectionTitle(
                  title: 'Society roster',
                  isPeeking: true,
                ),

                // Standardized Search Input
                // Design 4.1 Search Bar (Image 2)
                BoxyArtSearchInput(
                  label: 'Search Members',
                  hintText: 'Search roster...',
                  initialValue: searchQuery,
                  onChanged: (v) => ref.read(adminMemberSearchQueryProvider.notifier).update(v),
                ),
                const SizedBox(height: AppSpacing.x2l),

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
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.x5l),
                          child: Text('No matching members'),
                        ),
                      );
                    }

                    final sortedMembers = [...filtered];
                    sortedMembers.sort((a, b) => a.lastName.compareTo(b.lastName));

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
                const SizedBox(height: 100),
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


