import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/notifications/domain/notification_broadcast_service.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../members/presentation/members_provider.dart';

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

enum RenewalFilter { noAction, requested, paid }

class AdminMemberRenewalScreen extends ConsumerStatefulWidget {
  const AdminMemberRenewalScreen({super.key});

  @override
  ConsumerState<AdminMemberRenewalScreen> createState() => _AdminMemberRenewalScreenState();
}

class _AdminMemberRenewalScreenState extends ConsumerState<AdminMemberRenewalScreen> {
  RenewalFilter _currentFilter = RenewalFilter.noAction;
  String _searchQuery = '';

  void _showRenewalSettings(BuildContext context) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Renewal Settings',
      // Compact content — open at 50% so there's no excess whitespace below the card
      initialChildSize: 0.50,
      maxChildSize: 0.60,
      child: Consumer(
        builder: (context, ref, child) {
          final themeConfig = ref.watch(themeControllerProvider);
          final notifier = ref.read(themeControllerProvider.notifier);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Info Header
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: isDark ? AppColors.dark300 : AppColors.dark400),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Configure society-wide renewal deadlines and active status.',
                            style: AppTypography.label.copyWith(
                              color: isDark ? AppColors.dark200 : AppColors.dark500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const BoxyArtDivider(verticalPadding: AppSpacing.xl),
                    
                    // 2. Cycle Timeline
                    Text(
                      'CYCLE TIMELINE', 
                      style: AppTypography.micro.copyWith(
                        color: isDark ? AppColors.dark300 : AppColors.dark400,
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerTile(
                            label: 'Membership Expiry',
                            date: themeConfig.renewalDeadline,
                            onChanged: (date) => notifier.setRenewalDeadline(date),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _DatePickerTile(
                            label: 'Renewal Deadline',
                            date: themeConfig.renewalPaymentDeadline,
                            onChanged: (date) => notifier.setRenewalPaymentDeadline(date),
                          ),
                        ),
                      ],
                    ),
                    
                    const BoxyArtDivider(verticalPadding: AppSpacing.xl),
                    
                    // 3. Action Area (v4.x Row - Add Sponsor Style)
                    Row(
                      children: [
                        Expanded(
                          child: BoxyArtButton(
                            title: themeConfig.isRenewalActive ? 'Active' : 'Activate',
                            isSmall: false,
                            backgroundColor: AppColors.actionMidnight,
                            textColor: AppColors.pureWhite,
                            onTap: themeConfig.isRenewalActive ? null : () async {
                              final confirmed = await showBoxyArtDialog<bool>(
                                context: context,
                                title: 'Activate Renewal Cycle?',
                                message: 'This enables the "Renew Now" button for all members and begins tracking payments.',
                                actions: [
                                  BoxyArtButton(
                                    title: 'Cancel',
                                    isPrimary: false,
                                    isGhost: true,
                                    isSmall: true,
                                    onTap: () => Navigator.of(context, rootNavigator: true).pop(false),
                                  ),
                                  BoxyArtButton(
                                    title: 'Activate',
                                    isPrimary: true,
                                    isSmall: true,
                                    onTap: () => Navigator.of(context, rootNavigator: true).pop(true),
                                  ),
                                ]
                              );
                              if (confirmed == true) {
                                await notifier.setIsRenewalActive(true);
                                await notifier.setRenewalLaunchDate(DateTime.now());
                              }
                            },
                          ),
                        ),
                        if (themeConfig.isRenewalActive) ...[
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: BoxyArtButton(
                              title: 'End',
                              isSmall: false,
                              isGhost: true,
                              backgroundColor: isDark ? Colors.transparent : AppColors.dark50,
                              textColor: AppColors.dark400,
                              onTap: () async {
                                 final confirmed = await showBoxyArtDialog<bool>(
                                    context: context,
                                    title: 'End Renewal Cycle?',
                                    message: 'This will stop active renewal requests. Member statuses will remain as they are.',
                                    actions: [
                                      BoxyArtButton(
                                        title: 'Cancel',
                                        isPrimary: false,
                                        isGhost: true,
                                        isSmall: true,
                                        onTap: () => Navigator.of(context, rootNavigator: true).pop(false),
                                      ),
                                      BoxyArtButton(
                                        title: 'End',
                                        isPrimary: true,
                                        isSmall: true,
                                        backgroundColor: AppColors.coral500, // Explicit end action
                                        onTap: () => Navigator.of(context, rootNavigator: true).pop(true),
                                      ),
                                    ]
                                  );
                                  if (confirmed == true) {
                                    await notifier.setIsRenewalActive(false);
                                  }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final selectedIds = ref.watch(selectedMemberIdsProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
        title: 'Renewal Hub',
        subtitle: 'Manage season renewals',
        titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
        showBack: true,
        onBack: () => context.pop(),
        pinnedBottom: selectedIds.isNotEmpty
            ? BoxyArtButton(
                title: 'Process ${selectedIds.length} Renewals',
                icon: Icons.done_all_rounded,
                fullWidth: true,
                backgroundColor: AppColors.actionMidnight,
                onTap: () => _processRenewals(context, ref, membersAsync.asData?.value ?? []),
              )
            : null,
        pinnedBottomPadding: 110, // Lift above the global bottom nav (v4.x Shell)
        actions: [
          BoxyArtGlassIconButton(
            icon: Icons.timer_outlined,
            tooltip: 'Renewal Settings',
            onPressed: () => _showRenewalSettings(context),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
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

              // 3. Filter by search query
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                displayMembers = displayMembers.where((m) {
                  final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                  return name.contains(query);
                }).toList();
              }

              return SliverMainAxisGroup(
                slivers: [
                  // 1. Section Title (Double-Rhythm Baseline)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: BoxyArtSectionTitle(
                        title: 'Renewal management',
                        isPeeking: true,
                      ),
                    ),
                  ),

                  // 2. Tab Bar Standardized
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
                      child: ModernUnderlinedFilterBar<RenewalFilter>(
                        selectedValue: _currentFilter,
                        onTabSelected: (filter) => setState(() => _currentFilter = filter),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        isExpanded: true,
                        tabs: [
                          const ModernFilterTab(label: 'No Action', value: RenewalFilter.noAction, icon: Icons.pending_actions_rounded),
                          const ModernFilterTab(label: 'Requested', value: RenewalFilter.requested, icon: Icons.notifications_active_rounded),
                          const ModernFilterTab(label: 'Paid', value: RenewalFilter.paid, icon: Icons.check_circle_rounded),
                        ],
                      ),
                    ),
                  ),

                  // 2. Search Bar (Standardized 4.x Rhythm)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl, 
                        0, 
                        AppSpacing.xl, 
                        spacing?.cardToLabel ?? AppSpacing.cardToLabel
                      ),
                      child: BoxyArtSearchInput(
                        label: 'Search members', // Integrated 4.x label
                        hintText: 'Search roster...',
                        initialValue: _searchQuery,
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ),

                  // Member List / Empty State
                  if (displayMembers.isEmpty)
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

    Color renewalColor;
    String renewalLabel;

    switch (member.renewalStatus) {
      case MemberRenewalStatus.renew:
        renewalColor = Theme.of(context).colorScheme.primary;
        renewalLabel = 'Renewing';
        break;
      case MemberRenewalStatus.suspend:
        renewalColor = AppColors.amber500;
        renewalLabel = 'Suspending';
        break;
      case MemberRenewalStatus.leave:
        renewalColor = AppColors.coral500;
        renewalLabel = 'Leaving';
        break;
      case MemberRenewalStatus.none:
        renewalColor = AppColors.dark400;
        renewalLabel = 'No action';
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Text(
                '${member.firstName} ${member.lastName}',
                style: AppTypography.memberName.copyWith(
                  color: isSelected ? AppColors.teamA : null,
                  fontSize: 16,
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Dedicated Status Column (Matching Sponsorship Hub)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (member.renewalStatus == MemberRenewalStatus.renew) ...[
                  BoxyArtStatusPill(
                    isPaid: member.hasPaid,
                    paidLabel: 'Paid',
                    dueLabel: 'Renewing',
                    onToggle: () {
                      final newPaidStatus = !member.hasPaid;
                      ref.read(membersRepositoryProvider).updateMember(
                        member.copyWith(hasPaid: newPaidStatus),
                      );
                      if (newPaidStatus) {
                        ref.read(selectedMemberIdsProvider.notifier).remove(member.id);
                      }
                    },
                  ),
                  if (!member.hasPaid)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: BoxyArtStatusPill(
                        isPaid: false,
                        paidLabel: '', 
                        dueLabel: 'Nudge',
                        color: AppColors.dark400,
                        onToggle: () async {
                          await ref.read(renewalNudgeServiceProvider).notifyMemberOfPaymentDue(member: member);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Payment reminder sent to ${member.firstName}')),
                            );
                          }
                        },
                      ),
                    ),
                ] else
                  BoxyArtStatusPill(
                    isPaid: false,
                    paidLabel: '', 
                    dueLabel: renewalLabel,
                    color: renewalColor,
                    onToggle: null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayDate = date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'Set date';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(), 
            style: AppTypography.micro.copyWith(
              color: isDark ? AppColors.dark300 : AppColors.dark400,
              fontWeight: AppTypography.weightBold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark800 : AppColors.dark50,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(
                color: isDark ? AppColors.dark700 : AppColors.dark200,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded, 
                  size: 16, 
                  color: theme.primaryColor,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  displayDate,
                  style: AppTypography.body.copyWith(
                    fontSize: 14, 
                    fontWeight: AppTypography.weightSemibold,
                    color: date == null ? (isDark ? AppColors.dark400 : AppColors.dark300) : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
