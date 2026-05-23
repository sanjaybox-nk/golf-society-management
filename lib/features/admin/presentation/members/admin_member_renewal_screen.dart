
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'controllers/renewal_controller.dart';
import 'widgets/renewal_widgets.dart';

class AdminMemberRenewalScreen extends ConsumerStatefulWidget {
  const AdminMemberRenewalScreen({super.key});

  @override
  ConsumerState<AdminMemberRenewalScreen> createState() => _AdminMemberRenewalScreenState();
}

class _AdminMemberRenewalScreenState extends ConsumerState<AdminMemberRenewalScreen> {
  RenewalFilter _currentFilter = RenewalFilter.pending;
  String _searchQuery = '';

  void _showRenewalSettings(BuildContext context) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Renewal Settings',
      child: const RenewalSettingsContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(selectedMemberIdsProvider);
    final displayMembers = ref.watch(renewalFilteredMembersProvider((filter: _currentFilter, search: _searchQuery)));
    final membersAsync = ref.watch(allMembersProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Renewal Hub',
      subtitle: 'Manage season renewals',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      pinnedBottom: selectedIds.isNotEmpty
          ? BoxyArtButton(
              title: 'Process ${selectedIds.length} Renewals',
              icon: Icons.done_all_rounded,
              fullWidth: true,
              backgroundColor: AppColors.actionMidnight,
              onTap: () => _handleProcessRenewals(context, ref),
            )
          : null,
      pinnedBottomPadding: 110,
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.timer_outlined,
          tooltip: 'Renewal Settings',
          onPressed: () => _showRenewalSettings(context),
        ),
      ],
      slivers: [
        SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
                child: BoxyArtTabBar<RenewalFilter>(
                  selectedValue: _currentFilter,
                  onTabSelected: (filter) => setState(() => _currentFilter = filter),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  tabs: const [
                    ModernFilterTab(label: 'Pending', value: RenewalFilter.pending),
                    ModernFilterTab(label: 'Renewing', value: RenewalFilter.renewing),
                    ModernFilterTab(label: 'Paid', value: RenewalFilter.paid),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, 
                  0, 
                  AppSpacing.xl, 
                  spacing?.cardToLabel ?? AppSpacing.cardToLabel
                ),
                child: BoxyArtSearchInput(
                  label: 'Search members',
                  hintText: 'Search roster...',
                  initialValue: _searchQuery,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),
            if (displayMembers.isEmpty && !membersAsync.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: BoxyArtEmptyCard(
                    title: 'No Members Found',
                    message: 'No society members match the current filter or search criteria.',
                    icon: Icons.people_outline_rounded,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => MemberRenewalTile(member: displayMembers[index]),
                    childCount: displayMembers.length,
                  ),
                ),
              ),
            if (membersAsync.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ],
    );
  }

  Future<void> _handleProcessRenewals(BuildContext context, WidgetRef ref) async {
    final members = ref.read(allMembersProvider).asData?.value ?? [];
    final selectedIds = ref.read(selectedMemberIdsProvider);

    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Process Renewals?',
      message: 'This will finalize the membership status for ${selectedIds.length} members. Continue?',
      actions: [
        BoxyArtButton(
          title: 'Cancel',
          isPrimary: false,
          isGhost: true,
          isSmall: true,
          onTap: () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
        BoxyArtButton(
          title: 'Confirm',
          isPrimary: true,
          isSmall: true,
          onTap: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    );

    if (confirm == true) {
      await ref.read(renewalControllerProvider.notifier).processRenewals(
        members: members,
        selectedIds: selectedIds,
        onComplete: () async {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Renewals processed successfully!')),
            );
          }
        },
      );
    }
  }
}
