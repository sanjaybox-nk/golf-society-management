import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/widgets/registration_control_sheet.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import '../../../events/logic/event_analysis_engine.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../../competitions/services/leaderboard_invoker_service.dart';

class EventAdminControlsScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAdminControlsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminControlsScreen> createState() => _EventAdminControlsScreenState();
}


class _EventAdminControlsScreenState extends ConsumerState<EventAdminControlsScreen> {
  final Map<String, bool> _optimisticToggles = {};

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        // Clear optimistic toggles if they match the server state
        _optimisticToggles.removeWhere((key, val) {
          if (key == 'isStatsReleased') return val == event.isStatsReleased;
          if (key == 'isGroupingPublished') return val == event.isGroupingPublished;
          return false;
        });

        return HeadlessScaffold(
          title: 'Control Tower',
          subtitle: event.title,
          topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
          showBack: true,
          onBack: () => context.goNamed('admin-events'),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // 2. Player Visibility Section
                  const BoxyArtSectionTitle(
                    title: 'Player visibility',
                    isPeeking: true,
                  ),
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        BoxyArtNavTile(
                          icon: Icons.app_registration_rounded,
                          title: 'Registration Access',
                          subtitle: event.showRegistrationButton
                              ? 'Open to all members'
                              : event.isTargetedRegistration
                                  ? 'Targeted — ${event.targetedRegistrationIds.length} member(s)'
                                  : 'Closed',
                          onTap: () => RegistrationControlSheet.show(context, event),
                        ),
                        const BoxyArtDivider(),
                        BoxyArtSwitchTile(
                          icon: Icons.cloud_done_outlined,
                          label: 'Show Tee Times to Members',
                          subtitle: 'Publish the grouping and tee times to the member event hub.',
                          value: _optimisticToggles['isGroupingPublished'] ?? (event.isGroupingPublished == true),
                          onChanged: (val) {
                            setState(() => _optimisticToggles['isGroupingPublished'] = val);
                            ref.read(eventsRepositoryProvider).updateEvent(
                              event.copyWith(isGroupingPublished: val),
                            );
                          },
                        ),
                        const BoxyArtDivider(),
                        BoxyArtSwitchTile(
                          icon: Icons.analytics_outlined,
                          label: 'Show Live Stats to Players',
                          subtitle: 'Allow players to see calculated analytics during the event.',
                          value: _optimisticToggles['isStatsReleased'] ?? (event.isStatsReleased == true),
                          onChanged: (val) {
                            setState(() => _optimisticToggles['isStatsReleased'] = val);
                            ref.read(eventsRepositoryProvider).updateEvent(
                              event.copyWith(isStatsReleased: val),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // 3. Social Golf Access (golf events only)
                  if (event.eventType == EventType.golf) ...[
                    const BoxyArtSectionTitle(
                      title: 'Social member access',
                      isPeeking: true,
                    ),
                    _SocialGolfAccessCard(event: event),
                  ],

                  // 4. Workbench Safety Section
                  const BoxyArtSectionTitle(
                    title: 'Workbench safety',
                    isPeeking: true,
                  ),
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl,
                            vertical: spacing?.cardVerticalPadding ?? AppSpacing.xl,
                          ),
                          child: Column(
                            children: [
                              BoxyArtButton(
                                title: 'Recalculate Stats',
                                fullWidth: true,
                                isPrimary: true,
                                onTap: () => _recalculateStats(event, scorecardsAsync),
                              ),
                              SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Status:',
                                    style: AppTypography.micro.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: AppTypography.weightBold,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  BoxyArtIndicator.status(
                                    label: event.finalizedStats.isNotEmpty ? 'Ready' : 'Never finalized',
                                    color: event.finalizedStats.isNotEmpty ? Theme.of(context).primaryColor : AppColors.amber500,
                                    isAction: true,
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                  ),

                  // 4. Administrative Hub
                  const BoxyArtSectionTitle(
                    title: 'Event configuration',
                    isPeeking: true,
                  ),

                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        BoxyArtNavTile(
                          title: 'Edit Event Details',

                          subtitle: 'Change venue, date, or title',
                          icon: Icons.settings_applications_outlined,
                          onTap: () => context.pushNamed(
                            'admin-event-edit',
                            pathParameters: {'id': event.id},
                            extra: event,
                          ),
                        ),

                        const BoxyArtDivider(),
                        BoxyArtNavTile(
                          title: 'Fines & Charity',
                          subtitle: 'Record ad-hoc penalties & collections',
                          icon: Icons.gavel_rounded,
                          onTap: () => context.pushNamed(
                            'admin-event-fines',
                            pathParameters: {'id': event.id},
                          ),
                        ),

                        const BoxyArtDivider(),
                        BoxyArtNavTile(
                          title: 'Society Cuts',
                          subtitle: 'Apply manual handicap overrides',
                          icon: Icons.content_cut_rounded,
                          onTap: () => context.goNamed(
                            'admin-event-manual-cuts',
                            pathParameters: {'id': event.id},
                          ),
                        ),
                        const BoxyArtDivider(),
                        BoxyArtNavTile(
                          title: 'Match Play Draw',
                          subtitle: 'Generate and manage tournament brackets',
                          icon: Icons.account_tree_outlined,
                          onTap: () => context.pushNamed(
                            'admin-event-matchplay-draw',
                            pathParameters: {'id': event.id},
                          ),
                        ),
                        const BoxyArtDivider(),
                        BoxyArtNavTile(
                          title: 'Costs & Charges',
                          subtitle: 'Manage member/guest fees & meal options',
                          icon: Icons.payments_outlined,
                          onTap: () => context.pushNamed(
                            'admin-event-costs',
                            pathParameters: {'id': event.id},
                          ),
                        ),
                        const BoxyArtDivider(),
                        BoxyArtNavTile(
                          title: 'Prize Pool & Airdrops',
                          subtitle: 'Configure the prize table & award types',
                          icon: Icons.emoji_events_outlined,
                          onTap: () => context.pushNamed(
                            'admin-event-airdrops',
                            pathParameters: {'id': event.id},
                          ),
                        ),
                        const BoxyArtDivider(),
                        BoxyArtNavTile(
                          title: 'Event Comms',
                          subtitle: 'Manage notifications & feed items',
                          icon: Icons.campaign_rounded,
                          onTap: () => context.goNamed(
                            'admin-event-broadcast',
                            pathParameters: {'id': event.id},
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 5. Termination / Finalization
                  const BoxyArtSectionTitle(
                    title: 'Event termination',
                    isPeeking: true,
                  ),
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: BoxyArtSwitchTile(
                      icon: Icons.lock_outline,
                      label: 'Close Event & Finalize',
                      subtitle: 'Lock scorecards and finalize society statistics.',
                      value: event.status == EventStatus.completed,
                      onChanged: (val) {
                        if (val) {
                          _closeEvent(event, scorecardsAsync);
                        } else {
                          _reopenEvent(event);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.hero), // Bottom padding for shell
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Loading...', 
 
        slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (err, st) => HeadlessScaffold(
        title: 'Error', 
 
        slivers: [SliverFillRemaining(child: Center(child: Text('Error: $err')))],
      ),
    );
  }

  // --- Migrated Helper Methods ---

  Future<Map<String, dynamic>?> _recalculateStats(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) async {
    final scorecards = scorecardsAsync.value;
    if (scorecards == null || scorecards.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No scores available to calculate stats.')),
        );
      }
      return null;
    }

    final compAsync = ref.read(competitionDetailProvider(event.id));
    final competition = compAsync.value;
    if (competition == null) return null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculating stats...'), duration: Duration(seconds: 1)),
    );

    final stats = EventAnalysisEngine.calculateFinalStats(
      event: event,
      competition: competition,
      scorecards: scorecards,
    );

    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        finalizedStats: stats,
        results: (stats['results'] as List?)?.cast<Map<String, dynamic>>() ?? event.results,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stats recalculated and saved!')),
      );
    }
    return stats;
  }

  Future<void> _closeEvent(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) async {
    final scorecards = scorecardsAsync.value ?? [];
    final pending = scorecards.where((s) => s.status == ScorecardStatus.submitted).length;
    final incomplete = scorecards.where((s) => s.scoringStatus == ScoringStatus.incomplete).length;
    
    String warning = 'This will lock all scorecards, finalize the results, and mark the event as completed.';
    if (pending > 0 || incomplete > 0) {
      warning = 'WARNING: There are still $pending pending reviews and $incomplete incomplete scorecards. \n\nClosing the event will lock these in their current state.';
    }

    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Close Event?',
      message: warning,
      confirmText: 'Close & Finalize',
      isDangerous: true,
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop(true);
      },
    );

    if (confirmed == true) {
      final stats = await _recalculateStats(event, scorecardsAsync);
      
      // Update Event Status
      await ref.read(eventsRepositoryProvider).updateEvent(
        event.copyWith(
          status: EventStatus.completed,
          isScoringLocked: true,
          finalizedStats: stats ?? {},
        ),
      );

      // Trigger season standings recalculation so leaderboards update immediately
      await ref.read(leaderboardInvokerServiceProvider).recalculateAll(event.seasonId);

      // [Design 4.x Progression Check] Match Play Automation
      // If this event had a Match Play overlay, we now offer to transition to the next round draw.
      if (event.secondaryTemplateId != null) {
        final secondaryComp = ref.read(competitionDetailProvider(event.secondaryTemplateId!)).value;
        if (secondaryComp != null && secondaryComp.rules.hasMatchPlayOverlay == true) {
          if (mounted) {
            final startNextRound = await showBoxyArtDialog<bool>(
              context: context,
              title: 'Round Complete!',
              message: 'This event included a Match Play Season Overlay. Would you like to generate the draw for the next round now?',
              confirmText: 'GENERATE NEXT ROUND',
              cancelText: 'LATER',
              onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
            );

            if (startNextRound == true && mounted) {
              // Navigate to Match Play Hub for the next round setup
              context.pushNamed(
                'admin-event-matchplay-draw',
                pathParameters: {'id': event.id},
                queryParameters: {'progress': 'true'},
              );
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event Closed & Stats Finalized')),
        );
      }
    }
  }

  Future<void> _reopenEvent(GolfEvent event) async {
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        status: EventStatus.inPlay,
        isScoringLocked: false,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Reopened')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Social Golf Access Card
// ---------------------------------------------------------------------------

class _SocialGolfAccessCard extends ConsumerWidget {
  final GolfEvent event;

  const _SocialGolfAccessCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMembers = ref.watch(allMembersProvider).value ?? [];
    final socialMembers = allMembers
        .where((m) => m.role == MemberRole.socialMember)
        .toList()
        .cast<Member>();
    final overrides = event.socialGolfOverrides;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overrides.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No social members granted golf access for this event.',
                style: AppTypography.micro.copyWith(
                  color: AppColors.dark400,
                  fontWeight: AppTypography.weightRegular,
                ),
              ),
            )
          else
            Column(
              children: overrides.asMap().entries.map((entry) {
                final isLast = entry.key == overrides.length - 1;
                final member = allMembers.firstWhere(
                  (m) => m.id == entry.value,
                  orElse: () => allMembers.first,
                );
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          BoxyArtAvatar(
                            url: member.avatarUrl,
                            initials: '${member.firstName[0]}${member.lastName[0]}',
                            radius: 18,
                            isCircle: true,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              '${member.firstName} ${member.lastName}',
                              style: AppTypography.labelStrong,
                            ),
                          ),
                          BoxyArtGlassIconButton(
                            icon: Icons.remove_circle_outline_rounded,
                            iconSize: 18,
                            onPressed: () {
                              final updated = List<String>.from(overrides)
                                ..remove(entry.value);
                              ref.read(eventsRepositoryProvider).updateEvent(
                                event.copyWith(socialGolfOverrides: updated),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const BoxyArtDivider(),
                  ],
                );
              }).toList(),
            ),
          const BoxyArtDivider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BoxyArtButton(
              title: 'Grant Golf Access',
              icon: Icons.person_add_rounded,
              isTinted: true,
              fullWidth: true,
              onTap: socialMembers.isEmpty
                  ? null
                  : () => _showSocialMemberPicker(context, ref, socialMembers, overrides),
            ),
          ),
        ],
      ),
    );
  }

  void _showSocialMemberPicker(
    BuildContext context,
    WidgetRef ref,
    List<Member> socialMembers,
    List<String> overrides,
  ) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Grant Golf Access',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: socialMembers.map<Widget>((m) {
          final alreadyGranted = overrides.contains(m.id);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: BoxyArtAvatar(
              url: m.avatarUrl,
              initials: '${m.firstName[0]}${m.lastName[0]}',
              radius: 22,
              isCircle: true,
            ),
            title: Text(
              '${m.firstName} ${m.lastName}',
              style: AppTypography.labelStrong,
            ),
            trailing: alreadyGranted
                ? const Icon(Icons.check_circle_rounded, color: AppColors.lime500)
                : null,
            onTap: alreadyGranted
                ? null
                : () {
                    Navigator.pop(context);
                    final updated = [...overrides, m.id];
                    ref.read(eventsRepositoryProvider).updateEvent(
                      event.copyWith(socialGolfOverrides: updated),
                    );
                  },
          );
        }).toList(),
      ),
    );
  }
}
