
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';

import '../controllers/renewal_controller.dart';

bool _isSocialMember(Member m) =>
    m.role == MemberRole.socialMember || m.status == MemberStatus.social;

class MemberRenewalTile extends ConsumerWidget {
  final Member member;

  const MemberRenewalTile({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedMemberIdsProvider);
    final upgradeIds = ref.watch(socialUpgradeIdsProvider);
    final isSelected = selectedIds.contains(member.id);
    final isSocial = _isSocialMember(member);
    final isUpgrading = upgradeIds.contains(member.id);
    final controller = ref.read(renewalControllerProvider.notifier);

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
        renewalLabel = 'Pending';
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isSocial)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: BoxyArtPill.status(
                      label: isUpgrading ? 'UPGRADING' : 'SOCIAL',
                      color: isUpgrading ? AppColors.lime500 : AppColors.guestPurple,
                      hasHorizontalMargin: false,
                    ),
                  ),
                if (member.renewalStatus == MemberRenewalStatus.renew) ...[
                  BoxyArtStatusPill(
                    isPaid: member.hasPaid,
                    paidLabel: 'Paid',
                    dueLabel: 'Renewing',
                    onToggle: () => controller.togglePaidStatus(member),
                  ),
                  if (!member.hasPaid)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: BoxyArtStatusPill(
                        isPaid: false,
                        paidLabel: '',
                        dueLabel: member.nudgeCount > 0 ? 'Nudge (${member.nudgeCount})' : 'Nudge',
                        color: AppColors.dark400,
                        customActionIcon: Icons.notifications_active_rounded,
                        onToggle: () async {
                          await controller.nudgeMember(member);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Payment reminder sent to ${member.firstName}')),
                            );
                          }
                        },
                      ),
                    ),
                  if (isSocial)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: BoxyArtStatusPill(
                        isPaid: isUpgrading,
                        paidLabel: 'Full Member',
                        dueLabel: 'Upgrade?',
                        color: AppColors.guestPurple,
                        onToggle: () => ref
                            .read(socialUpgradeIdsProvider.notifier)
                            .toggle(member.id),
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

class RenewalDatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  const RenewalDatePickerTile({
    super.key,
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

class RenewalSettingsContent extends ConsumerWidget {
  const RenewalSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Row(
                children: [
                  Expanded(
                    child: RenewalDatePickerTile(
                      label: 'Membership Expiry',
                      date: themeConfig.renewalDeadline,
                      onChanged: (date) => notifier.setRenewalDeadline(date),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: RenewalDatePickerTile(
                      label: 'Renewal Deadline',
                      date: themeConfig.renewalPaymentDeadline,
                      onChanged: (date) => notifier.setRenewalPaymentDeadline(date),
                    ),
                  ),
                ],
              ),
              if (themeConfig.enableSocialMembership) ...[
                const BoxyArtDivider(verticalPadding: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOCIAL MEMBER RENEWAL',
                            style: AppTypography.micro.copyWith(
                              fontWeight: AppTypography.weightBold,
                              letterSpacing: AppTypography.lsLabel,
                              color: AppColors.dark400,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Open renewal to social members once full members have renewed.',
                            style: AppTypography.micro.copyWith(
                              color: AppColors.dark400,
                              fontWeight: AppTypography.weightRegular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Switch.adaptive(
                      value: themeConfig.socialRenewalOpen,
                      onChanged: themeConfig.isRenewalActive
                          ? (val) => notifier.setSocialRenewalOpen(val)
                          : null,
                      activeThumbColor: AppColors.lime500,
                      activeTrackColor: AppColors.lime500.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              ],
              const BoxyArtDivider(verticalPadding: AppSpacing.xl),
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
                                  backgroundColor: AppColors.coral500,
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
  }
}
