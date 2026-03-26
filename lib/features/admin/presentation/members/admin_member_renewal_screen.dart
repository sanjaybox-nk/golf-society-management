import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../members/presentation/member_details_modal.dart';

// Local notifier for tracking selection
class SelectedMemberIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void remove(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    }
  }

  void clear() => state = {};
}

final selectedMemberIdsProvider = NotifierProvider<SelectedMemberIdsNotifier, Set<String>>(
  SelectedMemberIdsNotifier.new,
);

enum RenewalFilter { requested, paid, noAction }

class AdminMemberRenewalScreen extends ConsumerStatefulWidget {
  const AdminMemberRenewalScreen({super.key});

  @override
  ConsumerState<AdminMemberRenewalScreen> createState() => _AdminMemberRenewalScreenState();
}

class _AdminMemberRenewalScreenState extends ConsumerState<AdminMemberRenewalScreen> {
  RenewalFilter _currentFilter = RenewalFilter.requested;

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final selectedIds = ref.watch(selectedMemberIdsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HeadlessScaffold(
        title: 'Renewal Hub',
        subtitle: 'Manage season renewals',
        showBack: true,
        onBack: () => context.pop(),
        slivers: [
          membersAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
            data: (members) {
              // 1. Calculate counts for tabs
              final requested = members.where((m) => m.renewalStatus == MemberRenewalStatus.renew && !m.hasPaid).toList();
              final paid = members.where((m) => m.renewalStatus == MemberRenewalStatus.renew && m.hasPaid).toList();
              final noAction = members.where((m) => m.renewalStatus == MemberRenewalStatus.none).toList();

              // 2. Select list based on current tab
              List<Member> displayMembers;
              switch (_currentFilter) {
                case RenewalFilter.requested: displayMembers = requested; break;
                case RenewalFilter.paid: displayMembers = paid; break;
                case RenewalFilter.noAction: displayMembers = noAction; break;
              }

              return SliverMainAxisGroup(
                slivers: [
                  // 1. Summary Metrics Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                      child: ModernMetricBar(
                        children: [
                          Expanded(
                            child: ModernMetricStat(
                              value: '${requested.length}',
                              label: 'REQUESTED',
                              isCompact: true,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ModernMetricStat(
                              value: '${paid.length}',
                              label: 'PAID',
                              isCompact: true,
                              color: AppColors.teamA,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ModernMetricStat(
                              value: '${noAction.length}',
                              label: 'NO ACTION',
                              isCompact: true,
                              color: AppColors.dark400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Tab Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.lg),
                      child: ModernUnderlinedFilterBar<RenewalFilter>(
                        selectedValue: _currentFilter,
                        onTabSelected: (filter) => setState(() => _currentFilter = filter),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        isExpanded: true,
                        tabs: const [
                          ModernFilterTab(label: 'Requested', value: RenewalFilter.requested),
                          ModernFilterTab(label: 'Paid', value: RenewalFilter.paid),
                          ModernFilterTab(label: 'No Action', value: RenewalFilter.noAction),
                        ],
                      ),
                    ),
                  ),

                  // Member List
                  if (displayMembers.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 48, color: AppColors.dark400.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'No members in this category',
                              style: AppTypography.body.copyWith(color: AppColors.dark400),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _MemberRenewalTile(member: displayMembers[index]),
                          childCount: displayMembers.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: selectedIds.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 100),
              child: BoxyArtButton(
                title: 'Process ${selectedIds.length} Renewals',
                icon: Icons.done_all_rounded,
                fullWidth: true,
                backgroundColor: AppColors.actionMidnight,
                onTap: () => _processRenewals(context, ref, membersAsync.value ?? []),
              ),
            )
          : null,
    );
  }

  Future<void> _processRenewals(BuildContext context, WidgetRef ref, List<Member> members) async {
    final selectedIds = ref.read(selectedMemberIdsProvider);
    final selectedMembers = members.where((m) => selectedIds.contains(m.id)).toList();

    if (selectedMembers.isEmpty) return;

    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Process Renewals?',
      message: 'This will finalize the membership status for ${selectedMembers.length} members. Continue?',
      actions: [
        BoxyArtButton(
          title: 'CANCEL',
          isPrimary: false,
          isGhost: true,
          isSmall: true,
          onTap: () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
        BoxyArtButton(
          title: 'CONFIRM',
          isPrimary: true,
          isSmall: true,
          onTap: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    );

    if (confirm != true) return;

    final repository = ref.read(membersRepositoryProvider);
    
    for (final member in selectedMembers) {
      Member updatedMember = member;

      switch (member.renewalStatus) {
        case MemberRenewalStatus.renew:
          updatedMember = member.copyWith(
            status: MemberStatus.active,
            // hasPaid: false, // REMOVED: Preserve payment status for the new season
            joinedDate: DateTime.now(),
            renewalStatus: MemberRenewalStatus.none,
          );
          break;
        case MemberRenewalStatus.suspend:
          updatedMember = member.copyWith(
            status: MemberStatus.suspended,
            renewalStatus: MemberRenewalStatus.none,
          );
          break;
        case MemberRenewalStatus.leave:
          updatedMember = member.copyWith(
            status: MemberStatus.left,
            renewalStatus: MemberRenewalStatus.none,
          );
          break;
        case MemberRenewalStatus.none:
          break;
      }

      await repository.updateMember(updatedMember);
    }

    ref.read(selectedMemberIdsProvider.notifier).clear();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renewals processed successfully!')),
      );
    }
  }
}


class _MemberRenewalTile extends ConsumerWidget {
  final Member member;

  const _MemberRenewalTile({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedMemberIdsProvider);
    final isSelected = selectedIds.contains(member.id);

    Color statusColor;
    String statusLabel;

    switch (member.renewalStatus) {
      case MemberRenewalStatus.renew:
        statusColor = Theme.of(context).colorScheme.primary;
        statusLabel = 'RENEWING';
        break;
      case MemberRenewalStatus.suspend:
        statusColor = AppColors.amber500;
        statusLabel = 'SUSPENDING';
        break;
      case MemberRenewalStatus.leave:
        statusColor = AppColors.coral500;
        statusLabel = 'LEAVING';
        break;
      case MemberRenewalStatus.none:
        statusColor = AppColors.dark400;
        statusLabel = 'NO ACTION';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtCard(
        onTap: () {
          ref.read(selectedMemberIdsProvider.notifier).toggle(member.id);
        },
        border: isSelected 
            ? Border.all(color: AppColors.teamA, width: 2)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected 
                  ? AppColors.teamA.withValues(alpha: 0.1) 
                  : AppColors.dark500.withValues(alpha: 0.1),
              backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty 
                  ? NetworkImage(member.avatarUrl!) 
                  : null,
              child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                  ? Text(
                      member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontWeight: AppTypography.weightBold, 
                        color: isSelected ? AppColors.teamA : AppColors.dark400,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${member.firstName} ${member.lastName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: AppTypography.sizeBody,
                      letterSpacing: 0.2,
                      color: isSelected ? AppColors.teamA : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: AppShapes.xs,
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: AppTypography.sizeMicro,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isSelected && member.renewalStatus != MemberRenewalStatus.none)
              BoxyArtFeePill(
                isPaid: member.hasPaid,
                onToggle: () {
                  final newPaidStatus = !member.hasPaid;
                  ref.read(membersRepositoryProvider).updateMember(
                    member.copyWith(hasPaid: newPaidStatus),
                  );

                  // [DEBUG] Log the update for verification
                  debugPrint('💰 MEMBER UPDATE: ${member.displayName} set hasPaid to $newPaidStatus');

                  // Deselect automatically if marked as paid to follow Design 4.x logical flow
                  if (newPaidStatus) {
                    ref.read(selectedMemberIdsProvider.notifier).remove(member.id);
                  }
                },
              )
            else if (!isSelected)
              Text(
                'PENDING',
                style: AppTypography.micro.copyWith(
                  color: AppColors.dark400,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
