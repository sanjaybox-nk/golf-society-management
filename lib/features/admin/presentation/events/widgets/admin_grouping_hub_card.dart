import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';

class AdminGroupingHubCard extends ConsumerWidget {
  final GolfEvent event;
  final VoidCallback onGenerate;
  final List<TeeGroupParticipant> unassignedPlayers;
  final Map<String, Member> memberMap;
  final bool hasCapacity;
  final VoidCallback? onAddToGroups;

  const AdminGroupingHubCard({
    super.key,
    required this.event,
    required this.onGenerate,
    this.unassignedPlayers = const [],
    this.memberMap = const {},
    this.hasCapacity = false,
    this.onAddToGroups,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false);
    final localGroups = ref.watch(groupingLocalGroupsProvider);
    final bool hasGroups = localGroups != null && localGroups.isNotEmpty;
    final bool hasUnassigned = unassignedPlayers.isNotEmpty;
    final int count = unassignedPlayers.length;

    return BoxyArtFormColumn(
      children: [
        BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Late registrants not in any group
              if (hasUnassigned && !isLocked) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.standard,
                    vertical: AppSpacing.atomic,
                  ),
                  child: Row(
                    children: [
                      BoxyArtIconBadge(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.amber500,
                        size: 36,
                        iconSize: 18,
                      ),
                      const SizedBox(width: AppSpacing.standard),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$count ${count == 1 ? 'player' : 'players'} not yet grouped',
                              style: AppTypography.body.copyWith(fontWeight: AppTypography.weightStrong),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Registered after last generation.',
                              style: AppTypography.micro.copyWith(
                                color: AppColors.dark400,
                                fontWeight: AppTypography.weightMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ...unassignedPlayers.map((p) {
                  final member = memberMap[p.registrationMemberId];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BoxyArtDivider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.standard,
                          vertical: AppSpacing.atomic,
                        ),
                        child: Row(
                          children: [
                            BoxyArtAvatar(
                              url: member?.avatarUrl,
                              initials: member != null
                                  ? '${member.firstName[0]}${member.lastName[0]}'
                                  : (p.name.isNotEmpty ? p.name[0] : '?'),
                              radius: 18,
                              isCircle: true,
                            ),
                            const SizedBox(width: AppSpacing.standard),
                            Expanded(
                              child: Text(
                                p.name,
                                style: AppTypography.body.copyWith(fontWeight: AppTypography.weightStrong),
                              ),
                            ),
                            Text(
                              'HC: ${p.handicapIndex.toStringAsFixed(1)}',
                              style: AppTypography.label.copyWith(color: AppColors.dark400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],

              // Registration not yet closed
              if (!event.isRegistrationClosed && event.showRegistrationButton && !event.occursToday) ...[
                if (hasUnassigned && !isLocked) const BoxyArtDivider(),
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'Registration not completed',
                      style: TextStyle(
                        color: AppColors.dark400,
                        fontStyle: FontStyle.italic,
                        fontWeight: AppTypography.weightSemibold,
                      ),
                    ),
                  ),
                ),
              ]

              // Action buttons
              else if (!event.isGroupingPublished && !isLocked) ...[
                if (hasUnassigned) const BoxyArtDivider(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      if (hasUnassigned) ...[
                        if (hasCapacity && onAddToGroups != null) ...[
                          BoxyArtButton(
                            title: 'Add to Existing Groups',
                            icon: Icons.group_add_rounded,
                            isTinted: true,
                            fullWidth: true,
                            onTap: onAddToGroups,
                          ),
                          const SizedBox(height: AppSpacing.atomic),
                          BoxyArtButton(
                            title: 'Regenerate Groups',
                            icon: Icons.refresh_rounded,
                            isSecondary: true,
                            fullWidth: true,
                            onTap: onGenerate,
                          ),
                        ] else ...[
                          BoxyArtButton(
                            title: 'Rebuild Groups',
                            icon: Icons.refresh_rounded,
                            isTinted: true,
                            fullWidth: true,
                            onTap: onGenerate,
                          ),
                        ],
                      ] else ...[
                        BoxyArtButton(
                          title: hasGroups ? 'Regenerate Groups' : 'Generate Groups',
                          icon: hasGroups ? Icons.refresh_rounded : Icons.auto_awesome_rounded,
                          isTinted: true,
                          fullWidth: true,
                          onTap: onGenerate,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

            ],
          ),
        ),
      ],
    );
  }
}
