import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../../members/presentation/members_provider.dart';
import '../../../../competitions/presentation/competitions_provider.dart';

class AdminVerifyTab extends ConsumerWidget {
  final GolfEvent event;
  final AsyncValue<List<Scorecard>> scorecardsAsync;
  final bool isStableford;
  final Future<void> Function(
    String entryId,
    String markerEntryId,
    String playerName,
    String markerName,
  ) onUnlockCard;

  const AdminVerifyTab({
    super.key,
    required this.event,
    required this.scorecardsAsync,
    required this.isStableford,
    required this.onUnlockCard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.read(allMembersProvider).value ?? [];
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return scorecardsAsync.when(
      data: (rawScorecards) {
        final seen = <String>{};
        final scorecards = (List<Scorecard>.from(rawScorecards)
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
            .where((s) => seen.add(s.entryId))
            .toList();

        final scorecardMap = {for (final s in scorecards) s.entryId: s};

        final groups = (event.grouping['groups'] as List? ?? [])
            .map((g) => TeeGroup.fromJson(g))
            .toList();

        final needsReassignment = scorecards.where((s) => s.markerReassignmentOpen).toList();

        final allApproved = scorecards.isNotEmpty &&
            scorecards.every((s) => s.status == ScorecardStatus.approved);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Marker reassignment (priority) ────────────────────────────
            if (needsReassignment.isNotEmpty) ...[
              const BoxyArtSectionTitle(title: 'Marker Reassignment Required', isPeeking: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  for (int i = 0; i < needsReassignment.length; i++) ...[
                    if (i > 0) const BoxyArtDivider(),
                    Builder(builder: (ctx) {
                      final s = needsReassignment[i];
                      final reg = event.registrations.firstWhereOrNull(
                          (r) => r.memberId == s.entryId || '${r.memberId}_guest' == s.entryId);
                      final markerReg = event.registrations.firstWhereOrNull(
                          (r) => r.memberId == s.markerId || '${r.memberId}_guest' == s.markerId);
                      return BoxyArtNavTile(
                        title: reg?.memberName ?? s.entryId,
                        subtitle: 'Needs new marker — ${markerReg?.memberName ?? 'previous marker'} left the round',
                        icon: Icons.person_search_rounded,
                        badgeColor: AppColors.amber500,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: ctx,
                            builder: (_) => BoxyArtConfirmDialog(
                              title: 'Reassign Marker?',
                              message: 'This will open marker reassignment for ${reg?.memberName ?? s.entryId}.',
                              confirmLabel: 'Open Marker Sheet',
                              cancelLabel: 'Cancel',
                            ),
                          );
                          if (confirmed == true) {
                            await ref.read(scorecardRepositoryProvider).updateScorecard(
                              s.copyWith(markerReassignmentOpen: false),
                            );
                          }
                        },
                      );
                    }),
                  ],
                ]),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // ── All cards approved ────────────────────────────────────────
            if (allApproved) ...[
              const BoxyArtEmptyCard(
                title: 'All Cards Approved',
                message: 'Every scorecard has been reviewed and confirmed. The event is ready to close.',
                icon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // ── Group-ordered single list ─────────────────────────────────
            for (int gi = 0; gi < groups.length; gi++) ...() {
              final seenKeys = <String>{};
              final uniquePlayers = groups[gi].players
                  .where((p) => seenKeys.add('${p.registrationMemberId}_${p.isGuest}'))
                  .toList();

              return [
              BoxyArtSectionTitle(
                title: 'Group ${gi + 1}',
                isPeeking: true,
                trailing: BoxyArtPill(
                  label: _formatTeeTime(groups[gi].teeTime),
                  icon: Icons.access_time_filled_rounded,
                  isAction: true,
                  hasHorizontalMargin: false,
                ),
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  for (int pi = 0; pi < uniquePlayers.length; pi++) ...[
                    if (pi > 0) const BoxyArtDivider(),
                    Builder(builder: (ctx) {
                      final p = uniquePlayers[pi];
                      final entryId = p.isGuest
                          ? '${p.registrationMemberId}_guest'
                          : p.registrationMemberId;
                      final s = scorecardMap[entryId];
                      final editorPlayerId = s?.entryId ?? entryId;
                      final displayName = p.name.isNotEmpty
                          ? p.name
                          : (event.registrations.firstWhereOrNull(
                                  (r) => r.memberId == p.registrationMemberId)
                              ?.memberName ?? entryId);

                      if (s == null) {
                        return AdminVerifyTile(
                          title: displayName,
                          subtitle: 'No scorecard yet',
                          markerLine: '',
                          badgeColor: AppColors.dark300,
                          iconColor: AppColors.dark400,
                          icon: Icons.help_outline_rounded,
                          onTap: () {},
                        );
                      }

                      final props = _playerStatusProps(s, members);
                      final hcLabel = (s.handicapIndex ?? 0) > 0
                          ? 'HC ${(s.handicapIndex ?? 0).toStringAsFixed(1)} · '
                          : '';

                      final markerName = _markerLine(s).replaceFirst('Marker: ', '');
                      return AdminVerifyTile(
                        title: displayName,
                        subtitle: '$hcLabel${props.subtext}',
                        markerLine: _markerLine(s),
                        badgeColor: props.badgeColor,
                        iconColor: props.iconColor,
                        icon: props.icon,
                        isDQ: s.scoringStatus == ScoringStatus.dq,
                        hasConflicts: s.conflictedHoles.isNotEmpty && s.status != ScorecardStatus.approved,
                        penalty: s.committeeAdjustment,
                        isStableford: isStableford,
                        hasAmendments: s.holeAuditLog.isNotEmpty,
                        isGuest: p.isGuest,
                        isCaptain: p.isCaptain,
                        onTap: () => context.push(
                            '/admin/events/manage/${Uri.encodeComponent(event.id)}/scores/$editorPlayerId'),
                        onUnlock: s.status == ScorecardStatus.approved
                            ? () => onUnlockCard(entryId, s.markerId ?? '', displayName, markerName)
                            : null,
                      );
                    }),
                  ],
                ]),
              ),
              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
              ];
            }(),

            const SizedBox(height: AppSpacing.hero),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  String _markerLine(Scorecard s) {
    if (s.markerId == null || s.markerId!.isEmpty) return 'No marker assigned';
    final isGuestMarker = s.markerId!.endsWith('_guest');
    final reg = event.registrations.firstWhereOrNull(
      (r) => r.memberId == s.markerId || '${r.memberId}_guest' == s.markerId,
    );
    if (reg == null) return 'Marker: ${s.markerId!}';
    final name = isGuestMarker ? (reg.guestName ?? reg.memberName) : reg.memberName;
    return 'Marker: $name';
  }

  String _formatTeeTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  ({Color badgeColor, Color iconColor, IconData icon, String subtext}) _playerStatusProps(
      Scorecard s, List<Member> members) {
    if (s.status == ScorecardStatus.approved) {
      final approver = members.firstWhereOrNull((m) => m.id == s.approvedBy);
      final approverName = approver?.firstName ?? 'Admin';
      final hadConflicts = s.conflictedHoles.isNotEmpty;
      final hadAmendments = s.holeAuditLog.isNotEmpty;
      final String subtext;
      if (hadConflicts) {
        subtext = 'Approved · conflicts accepted · $approverName';
      } else if (hadAmendments) {
        subtext = 'Verified · ${s.holeAuditLog.length} amendment${s.holeAuditLog.length > 1 ? 's' : ''} · $approverName';
      } else {
        subtext = 'Verified · $approverName';
      }
      return (badgeColor: AppColors.lime500, iconColor: AppColors.lime500, icon: Icons.verified_rounded, subtext: subtext);
    }

    if (s.conflictedHoles.isNotEmpty) {
      return (
        badgeColor: AppColors.coral500,
        iconColor: AppColors.coral500,
        icon: Icons.warning_rounded,
        subtext: 'Conflict on hole${s.conflictedHoles.length > 1 ? 's' : ''} ${s.conflictedHoles.join(', ')}',
      );
    }

    if (s.status == ScorecardStatus.finalScore || s.status == ScorecardStatus.reviewed) {
      return (
        badgeColor: AppColors.lime500,
        iconColor: AppColors.amber500,
        icon: Icons.task_alt_rounded,
        subtext: s.holeAuditLog.isNotEmpty ? 'Ready for Committee verification · ${s.holeAuditLog.length} amended' : 'Ready for Committee verification',
      );
    }

    if (s.scoringStatus == ScoringStatus.wd) return (badgeColor: AppColors.amber500, iconColor: AppColors.amber500, icon: Icons.exit_to_app_rounded, subtext: 'Withdrawn');
    if (s.scoringStatus == ScoringStatus.nr) return (badgeColor: AppColors.amber500, iconColor: AppColors.amber500, icon: Icons.remove_circle_outline_rounded, subtext: 'No return');
    if (s.scoringStatus == ScoringStatus.dq) return (badgeColor: AppColors.amber500, iconColor: AppColors.amber500, icon: Icons.block_rounded, subtext: 'Disqualified');

    if (s.verifiedByMarker && !s.verifiedByPlayer) return (badgeColor: AppColors.amber500, iconColor: AppColors.amber500, icon: Icons.hourglass_top_rounded, subtext: 'Awaiting player sign-off');
    if (s.verifiedByPlayer && !s.verifiedByMarker) return (badgeColor: AppColors.amber500, iconColor: AppColors.amber500, icon: Icons.hourglass_top_rounded, subtext: 'Awaiting marker sign-off');

    if (s.status == ScorecardStatus.draft) {
      final allFilled = s.holeScores.length == 18 && s.holeScores.every((h) => h != null && h > 0);
      if (allFilled) return (badgeColor: AppColors.amber500, iconColor: AppColors.amber500, icon: Icons.pending_actions_rounded, subtext: 'Round complete — validating');
      return (badgeColor: AppColors.dark300, iconColor: AppColors.dark400, icon: Icons.golf_course_rounded, subtext: 'Still playing');
    }

    if (s.status == ScorecardStatus.submitted) return (badgeColor: AppColors.dark300, iconColor: AppColors.dark400, icon: Icons.schedule_rounded, subtext: 'Submitted — awaiting sign-off');

    return (badgeColor: AppColors.dark300, iconColor: AppColors.dark400, icon: Icons.schedule_rounded, subtext: 'In progress');
  }
}

// ── Verify Tile ───────────────────────────────────────────────────────────────

class AdminVerifyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String markerLine;
  final Color badgeColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onUnlock;
  final bool isDQ;
  final bool hasConflicts;
  final int penalty;
  final bool isStableford;
  final bool hasAmendments;
  final bool isGuest;
  final bool isCaptain;

  const AdminVerifyTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.markerLine,
    required this.badgeColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
    this.onUnlock,
    this.isDQ = false,
    this.hasConflicts = false,
    this.penalty = 0,
    this.isStableford = false,
    this.hasAmendments = false,
    this.isGuest = false,
    this.isCaptain = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.lg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            BoxyArtIconBadge(icon: icon, color: badgeColor, iconColor: iconColor, size: 44, iconSize: 20),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title.toUpperCase(),
                          style: AppTypography.labelStrong.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: AppTypography.weightBold,
                            fontSize: AppTypography.sizeLabel,
                            letterSpacing: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCaptain) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const BoxyArtCaptainBadge(),
                      ],
                      if (isGuest) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const BoxyArtGuestBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.caption.copyWith(color: isDark ? AppColors.dark200 : AppColors.dark400)),
                  Text(markerLine, style: AppTypography.caption.copyWith(color: AppColors.dark300, fontSize: 11)),
                  if (isDQ || hasConflicts || penalty != 0 || hasAmendments) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        if (isDQ) BoxyArtPill(label: 'DQ', color: AppColors.coral500, isLegend: true, hasHorizontalMargin: false),
                        if (hasConflicts) BoxyArtPill(label: 'Conflict', color: AppColors.coral500, isLegend: true, hasHorizontalMargin: false),
                        if (penalty != 0) BoxyArtPill(
                          label: isStableford ? '−$penalty pt${penalty != 1 ? 's' : ''}' : '+$penalty str${penalty != 1 ? 'okes' : 'oke'}',
                          color: AppColors.amber500, isLegend: true, hasHorizontalMargin: false,
                        ),
                        if (hasAmendments) BoxyArtPill(label: 'Amended', color: AppColors.amber500, isLegend: true, hasHorizontalMargin: false),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (onUnlock != null)
              GestureDetector(
                onTap: onUnlock,
                child: BoxyArtIconBadge(
                  icon: Icons.lock_rounded,
                  color: AppColors.dark500,
                  size: 28,
                  iconSize: 13,
                  useCircle: true,
                ),
              )
            else
              Icon(Icons.arrow_forward_ios_rounded, color: isDark ? AppColors.dark400 : AppColors.dark200, size: AppShapes.iconXs),
          ],
        ),
      ),
    );
  }
}
