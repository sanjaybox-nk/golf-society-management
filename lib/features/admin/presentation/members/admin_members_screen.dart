import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
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
        subtitle: 'Society Roster',
        leading: Center(
          child: BoxyArtGlassIconButton(
            icon: Icons.home_rounded,
            onPressed: () => context.go('/home'),
            tooltip: 'App Home',
          ),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.x2l),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ModernUnderlinedFilterBar<AdminMemberFilter>(
                  selectedValue: currentFilter,
                  onTabSelected: (filter) => ref.read(adminMemberFilterProvider.notifier).update(filter),
                  tabs: [
                    ModernFilterTab(label: 'Active ($activeCount)', value: AdminMemberFilter.current),
                    ModernFilterTab(label: 'Committee ($committeeCount)', value: AdminMemberFilter.committee),
                    ModernFilterTab(label: 'Other ($otherCount)', value: AdminMemberFilter.other),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Search Card
                BoxyArtCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: AppShapes.iconMd),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          onChanged: (v) => ref.read(adminMemberSearchQueryProvider.notifier).update(v),
                          style: AppTypography.label.copyWith(fontSize: AppTypography.sizeButton),
                          decoration: const InputDecoration(
                            hintText: 'Search roster...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x2l),

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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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


}


Widget _buildDismissibleMember(
  BuildContext context, 
  WidgetRef ref, 
  Member member, {
  String? secondaryMetricLabel,
  String? secondaryMetricValue,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Dismissible(
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
        onTap: () => MemberDetailsModal.show(context, member),
        onLongPress: () => MemberDetailsModal.show(context, member),
        showFeeStatus: true,
        secondaryMetricLabel: secondaryMetricLabel,
        secondaryMetricValue: secondaryMetricValue,
      ),
    ),
  );
}


