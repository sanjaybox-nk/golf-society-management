import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
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
          // Baseline Nudge for Tab Bar
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16.0),
              child: ModernUnderlinedFilterBar<AdminMemberFilter>(
                selectedValue: currentFilter,
                onTabSelected: (filter) => ref.read(userMemberFilterProvider.notifier).update(filter),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                isExpanded: true,
                tabs: [
                  ModernFilterTab(label: 'Active ($activeCount)', value: AdminMemberFilter.current),
                  ModernFilterTab(label: 'Committee ($committeeCount)', value: AdminMemberFilter.committee),
                  ModernFilterTab(label: 'Other ($otherCount)', value: AdminMemberFilter.other),
                ],
              ),
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

                // Search Card
                BoxyArtCard(
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: AppShapes.iconMd),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          onChanged: (v) => ref.read(memberSearchQueryProvider.notifier).update(v),
                          style: AppTypography.body.copyWith(
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: AppTypography.weightSemibold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search members...',
                            hintStyle: AppTypography.body.copyWith(
                              fontSize: 18,
                              height: 1.2,
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

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
                      } else {
                        return m.status != MemberStatus.member && m.status != MemberStatus.active;
                      }
                    }).toList();

                    if (filtered.isEmpty) {
                      return const _EmptyMembers();
                    }

                    final sortedMembers = [...filtered]..sort((a, b) => a.lastName.compareTo(b.lastName));

                    return Column(
                      children: sortedMembers.asMap().entries.map((entry) {
                        final m = entry.value;
                        final isLast = entry.key == sortedMembers.length - 1;
                        final eventCount = memberStatsAsync.value?[m.id] ?? 0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                          child: MemberTile(
                            member: m,
                            onTap: () => MemberDetailsModal.show(context, m),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: AppShapes.iconMassive, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No members found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
