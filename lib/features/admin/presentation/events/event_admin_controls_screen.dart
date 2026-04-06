import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import '../../../events/logic/event_analysis_engine.dart';
import '../../../admin/providers/admin_ui_providers.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';

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
          if (key == 'showRegistrationButton') return val == event.showRegistrationButton;
          return false;
        });

        return HeadlessScaffold(
          title: 'Control Tower',
          subtitle: event.title,

          showBack: true,
          onBack: () => context.goNamed('admin-events'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Status Overview Header
                  _buildStatusHeader(event, scorecardsAsync, spacing),

                  // 2. Player Visibility Section
                  const BoxyArtSectionTitle(title: 'Player visibility'),
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        BoxyArtSwitchTile(
                          icon: Icons.app_registration_rounded,
                          label: 'Show Registration Button',
                          subtitle: 'Make the event visible and joinable on the member home screen.',
                          value: _optimisticToggles['showRegistrationButton'] ?? (event.showRegistrationButton == true),
                          onChanged: (val) {
                            setState(() => _optimisticToggles['showRegistrationButton'] = val);
                            ref.read(eventsRepositoryProvider).updateEvent(
                              event.copyWith(showRegistrationButton: val),
                            );
                          },
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

                  // 3. Workbench Safety Section
                  const BoxyArtSectionTitle(title: 'Workbench safety'),
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        BoxyArtSwitchTile(
                          icon: Icons.lock_person_outlined,
                          label: 'Lock Grouping',
                          subtitle: 'Prevent accidental changes to the tee sheet while editing.',
                          value: ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false),
                          onChanged: (val) => _handleLockToggle(event, val),
                        ),
                        const BoxyArtDivider(),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              BoxyArtButton(
                                title: 'Recalculate Stats',
                                fullWidth: true,
                                isPrimary: true,
                                onTap: () => _recalculateStats(event, scorecardsAsync),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Status:',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: AppTypography.weightBold,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  BoxyArtPill.status(
                                    label: event.finalizedStats.isNotEmpty ? 'Ready' : 'Never finalized',
                                    color: event.finalizedStats.isNotEmpty ? Theme.of(context).primaryColor : AppColors.amber500,
                                    isAction: true,
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ]),
              ),
            ),

            // 3. Administrative Hub
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const BoxyArtSectionTitle(title: 'Event configuration'),

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
                          title: 'Broadcasts & Updates',
                          subtitle: 'Post live updates to the feed',
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
                  const BoxyArtSectionTitle(title: 'Event termination'),
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
                  SizedBox(height: AppSpacing.hero), // Bottom padding for shell
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Event?'),
        content: const Text('This will lock all scorecards, finalize the results, and mark the event as completed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Close', style: TextStyle(color: AppColors.coral500))),
        ],
      ),
    );

    if (confirmed == true) {
      final stats = await _recalculateStats(event, scorecardsAsync);
      await ref.read(eventsRepositoryProvider).updateEvent(
        event.copyWith(
          status: EventStatus.completed,
          isScoringLocked: true,
          finalizedStats: stats ?? {},
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event Closed & Stats Finalized')),
        );
      }
    }
  }

  Future<void> _handleLockToggle(GolfEvent event, bool val) async {
    if (!val) {
      // Unlocking is always fine
      ref.read(groupingIsLockedProvider.notifier).setLocked(false);
      return;
    }

    // Checking for unassigned players
    final members = ref.read(allMembersProvider).value ?? [];
    final societyConfig = ref.read(themeControllerProvider);
    final comp = ref.read(competitionDetailProvider(event.id)).value;
    
    final groupsData = event.grouping['groups'] as List?;
    final groups = groupsData?.map((g) => TeeGroup.fromJson(g)).toList() ?? [];
    
    final pool = GroupingService.getUnassignedPlayers(
      event: event, 
      groups: groups, 
      memberHandicaps: {for (var m in members) m.id: m.handicap}, 
      rules: comp?.rules,
      useWhs: societyConfig.useWhsHandicaps, 
      manualCuts: event.manualCuts,
    );

    if (pool.isNotEmpty) {
      final names = pool.map((p) => p.name).join(', ');
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => BoxyArtDialog(
          title: 'Unassigned Players Found',
          message: 'The following confirmed players are not in any group: $names. \n\nWould you like to auto-fill them into vacancies before locking?',
          confirmText: 'Auto-fill & lock',
          cancelText: 'Just lock',
          onConfirm: () => Navigator.pop(context, true),
          onCancel: () => Navigator.pop(context, false),
        ),
      );

      if (confirmed == null) return; // Action cancelled

      if (confirmed) {
        // Auto-fill and lock
        final updatedGroups = GroupingService.autoFillVacancies(
          groups: groups, 
          pool: pool,
        );
        
        await ref.read(eventsRepositoryProvider).updateEvent(
          event.copyWith(
            grouping: {
              ...event.grouping,
              'groups': updatedGroups.map((g) => g.toJson()).toList(),
              'locked': true,
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
        ref.read(groupingIsLockedProvider.notifier).setLocked(true);
        ref.read(groupingLocalGroupsProvider.notifier).setGroups(updatedGroups);
        return;
      }
    }

    // Just lock
    ref.read(groupingIsLockedProvider.notifier).setLocked(true);
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        grouping: {
          ...event.grouping,
          'locked': true,
        },
      ),
    );
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


  Widget _buildStatusHeader(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync, AppSpacingTokens? spacing) {
    final Set<String> uniqueGolferIds = {};
    for (final r in event.registrations) {
      if (r.attendingGolf && r.isConfirmed) {
        uniqueGolferIds.add(r.memberId);
      }
      if (r.attendingGolf && r.isGuest && r.guestIsConfirmed) {
        uniqueGolferIds.add('guest-${r.guestName}');
      }
    }
    final int totalGolfers = uniqueGolferIds.length;
    
    final submittedCount = scorecardsAsync.when(
      data: (scorecards) => scorecards.where((s) => 
        s.status == ScorecardStatus.submitted || s.status == ScorecardStatus.finalScore
      ).length,
      loading: () => 0,
      error: (err, st) => 0,
    );

    final now = DateTime.now();
    final bool isToday = now.year == event.date.year && 
                        now.month == event.date.month && 
                        now.day == event.date.day;
    final bool isPast = event.date.isBefore(now) && !isToday;
    
    final bool isClosed = event.status == EventStatus.completed || event.isScoringLocked == true;
    final bool isLive = (isToday || event.status == EventStatus.inPlay) && !isClosed;
    
    String status;
    Color statusColor;
    
    if (isClosed) {
      status = 'Closed';
      statusColor = Theme.of(context).colorScheme.error;
    } else if (isLive) {
      status = 'Live';
      statusColor = Theme.of(context).colorScheme.primary;
    } else if (isPast) {
      status = 'Past';
      statusColor = AppColors.amber500;
    } else {
      status = 'Upcoming';
      statusColor = AppColors.teamA;
    }

    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard('Status', status, statusColor, spacing),
        ),
        SizedBox(width: spacing?.labelToCard ?? AppSpacing.standard),
        Expanded(
          child: _buildBadgeCard(
            'Submitted', 
            '$submittedCount / $totalGolfers', 
            AppColors.teamA,
            spacing,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String label, String value, Color color, AppSpacingTokens? spacing) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            label, 
            style: const TextStyle(
              fontSize: 11, 
              fontWeight: AppTypography.weightBlack, 
              color: AppColors.textSecondary, 
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: spacing?.labelToCard ?? AppSpacing.labelToCard),
          Text(
            value, 
            style: AppTypography.displaySection.copyWith(
              color: color,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
