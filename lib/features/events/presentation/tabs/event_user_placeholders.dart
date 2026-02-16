import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../features/debug/presentation/widgets/lab_control_panel.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/scorecard.dart';
// REDACTED: unused member import
import '../../../../core/theme/app_theme.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../widgets/event_leaderboard.dart';
import '../widgets/scorecard_modal.dart';
import '../events_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../core/theme/theme_controller.dart';
import '../widgets/course_info_card.dart';
import '../widgets/hole_by_hole_scoring_widget.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/event_registration.dart';
// REDACTED: unused imports
// REDACTED: unused imports
import '../../../../core/services/persistence_service.dart';
// REDACTED: unused math import
import '../../../matchplay/presentation/widgets/matches_list_widget.dart';
import '../../../matchplay/presentation/widgets/matches_bracket_widget.dart';
import '../../../matchplay/presentation/widgets/match_group_standings_widget.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import '../../../matchplay/domain/match_definition.dart';

import '../../../debug/presentation/state/debug_providers.dart';
import 'event_stats_tab.dart';
import 'event_stats_tab.dart';
import 'event_user_registration_tab.dart';
import '../../../../core/shared_ui/headless_scaffold.dart';

// [LAB MODE] Persistence for Marker Selection
class MarkerSelection {
  final bool isSelfMarking;
  final String? targetEntryId;
  MarkerSelection({required this.isSelfMarking, this.targetEntryId});
}

class MarkerSelectionNotifier extends Notifier<MarkerSelection> {
  static const _keySelf = 'lab_marker_self';
  static const _keyTarget = 'lab_marker_target';
  
  @override
  MarkerSelection build() {
    final prefs = ref.watch(persistenceServiceProvider);
    return MarkerSelection(
      isSelfMarking: prefs.getBool(_keySelf) ?? true,
      targetEntryId: prefs.getString(_keyTarget),
    );
  }
  
  void selectSelf() {
    state = MarkerSelection(isSelfMarking: true, targetEntryId: null);
    ref.read(persistenceServiceProvider).setBool(_keySelf, true);
    ref.read(persistenceServiceProvider).remove(_keyTarget);
  }
  
  void selectTarget(String targetId) {
    state = MarkerSelection(isSelfMarking: false, targetEntryId: targetId);
    ref.read(persistenceServiceProvider).setBool(_keySelf, false);
    ref.read(persistenceServiceProvider).setString(_keyTarget, targetId);
  }
}
final markerSelectionProvider = NotifierProvider<MarkerSelectionNotifier, MarkerSelection>(MarkerSelectionNotifier.new);

// Tab Notifier for event scoring tabs

// Actually I'll use a String key for tab index to handle more than 2
class SelectedTabNotifier extends Notifier<int> {
  final String key;
  SelectedTabNotifier(this.key);
  @override
  int build() => int.tryParse(ref.watch(persistenceServiceProvider).getString(key) ?? '0') ?? 0;
  void set(int val) {
    state = val;
    ref.read(persistenceServiceProvider).setString(key, val.toString());
  }
}

final eventDetailsTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_details_tab'));
final eventFieldTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_field_tab'));

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  const EventGroupingUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
    final statusOverride = ref.watch(eventStatusOverrideProvider);

    return eventsAsync.when(
      data: (events) {
        var event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        
        // [LAB MODE] Apply Status Override
        if (statusOverride != null) {
          event = event.copyWith(status: statusOverride);
        }
        
        final bool isPublished = event.isGroupingPublished;
        final groupsData = event.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        final isPeeking = ref.watch(impersonationProvider) != null;

        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Field Hub',
          showBack: true,
          onBack: () => context.go('/events'),
          actions: const [],
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              sliver: SliverToBoxAdapter(
                child: _FieldHubToggle(),
              ),
            ),
            if (ref.watch(eventFieldTabProvider) == 0) ...[
              // Registrations View
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: membersAsync.when(
                    data: (members) => EventRegistrationUserTab.buildStaticContent(context, ref, event, members),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const Text('Error loading member registrations'),
                  ),
                ),
              ),
            ] else ...[
              // Pairings View
              if (!isPublished)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_clock_rounded, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('Grouping not yet published', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('The Admin will publish the tee sheet soon.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else 
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                   sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                         (context, index) {
                            if (index == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: BoxyArtSectionTitle(title: 'Grouping'),
                              );
                            }
                            final group = groups[index - 1]; // Adjust index
                            // Prepare data for GroupingCard
                            final members = membersAsync.value ?? [];
                            final memberMap = {for (var m in members) m.id: m};
                            // History for variety calculation (same season, previous events)
                            final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
                            final comp = compAsync.value;
                            
                            return Padding(
                               padding: const EdgeInsets.only(bottom: 12),
                               child: GroupingCard(
                                  group: group,
                                  memberMap: memberMap,
                                  history: history,
                                  totalGroups: groups.length,
                                  rules: comp?.rules.copyWith(
                                    format: ref.watch(gameFormatOverrideProvider) ?? comp.rules.format,
                                    mode: ref.watch(gameModeOverrideProvider) ?? comp.rules.mode,
                                    handicapAllowance: ref.watch(handicapAllowanceOverrideProvider) ?? comp.rules.handicapAllowance,
                                    teamBestXCount: ref.watch(teamBestXCountOverrideProvider) ?? comp.rules.teamBestXCount,
                                    aggregation: ref.watch(aggregationMethodOverrideProvider) == 'betterBall' 
                                        ? AggregationMethod.singleBest 
                                        : (ref.watch(aggregationMethodOverrideProvider) == 'combined' ? AggregationMethod.totalSum : comp.rules.aggregation),
                                  ),
                                  courseConfig: event.courseConfig,
                                  isAdmin: false,
                                  scorecardMap: scorecardsAsync.asData?.value != null 
                                      ? {for (var s in scorecardsAsync.asData!.value) s.entryId: s}
                                      : null,
                               ),
                            );
                         },
                         childCount: groups.length + 1, // Add 1 for title
                      ),
                   ),
                ),
            ],
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _FieldHubToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventFieldTabProvider);
    final primary = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: _ToggleItem(
                label: 'Entries',
                icon: Icons.people_outline_rounded,
                isSelected: selectedTab == 0,
                onTap: () => ref.read(eventFieldTabProvider.notifier).set(0),
              ),
            ),
            Expanded(
              child: _ToggleItem(
                label: 'Groupings',
                icon: Icons.grid_view_rounded,
                isSelected: selectedTab == 1,
                onTap: () => ref.read(eventFieldTabProvider.notifier).set(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class EventScoresUserTab extends ConsumerStatefulWidget {
  final String eventId;
  const EventScoresUserTab({super.key, required this.eventId});

  @override
  ConsumerState<EventScoresUserTab> createState() => _EventScoresUserTabState();
}

class _EventScoresUserTabState extends ConsumerState<EventScoresUserTab> {
  // Local state for tabs and markers removed to use providers below
  MarkerTab _markerTab = MarkerTab.player;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));
    final formatOverride = ref.watch(gameFormatOverrideProvider);

    return eventsAsync.when(
      data: (events) {
        // [Lab Mode] Apply overrides
        final statusOverride = ref.watch(eventStatusOverrideProvider);
        var event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => throw 'Event not found');
        
        if (statusOverride != null) {
          event = event.copyWith(status: statusOverride);
        }


        final forceLockedOverride = ref.watch(isScoringLockedOverrideProvider);
        if (forceLockedOverride != null) {
          event = event.copyWith(isScoringLocked: forceLockedOverride);
        }

        final statsReleasedOverride = ref.watch(isStatsReleasedOverrideProvider);
        if (statsReleasedOverride != null) {
          event = event.copyWith(isStatsReleased: statsReleasedOverride);
        }
        
        return compAsync.when(
          data: (comp) {
            // [Lab Mode] Merged Rules with overrides
            final rules = comp?.rules ?? const CompetitionRules();
            final handicapCapOverride = ref.watch(handicapCapOverrideProvider);
            final scoringType = ref.watch(scoringTypeOverrideProvider);
            
            final effectiveRules = rules.copyWith(
              format: ref.watch(gameFormatOverrideProvider) ?? rules.format,
              mode: ref.watch(gameModeOverrideProvider) ?? rules.mode,
              handicapAllowance: ref.watch(handicapAllowanceOverrideProvider) ?? rules.handicapAllowance,
              teamBestXCount: ref.watch(teamBestXCountOverrideProvider) ?? rules.teamBestXCount,
              aggregation: ref.watch(aggregationMethodOverrideProvider) == 'betterBall' 
                  ? AggregationMethod.singleBest 
                  : (ref.watch(aggregationMethodOverrideProvider) == 'combined' ? AggregationMethod.totalSum : rules.aggregation),
              handicapCap: handicapCapOverride ?? rules.handicapCap,
            );

            // Force Gross Scoring check
            final isGross = scoringType == ScoringType.gross;

            final currentFormat = effectiveRules.format;
            final currentMode = effectiveRules.mode;
            
            final isStableford = currentFormat == CompetitionFormat.stableford;
            final results = event.results;
            
            final List<LeaderboardEntry> leaderboardEntries = [];
            
            if (currentMode == CompetitionMode.singles) {
              leaderboardEntries.addAll(results.map((r) {
                // Gross Scoring Check
                final score = isStableford 
                    ? (isGross ? (r['grossPoints'] as int? ?? 0) : (r['points'] as int? ?? 0))
                    : (isGross ? (r['grossTotal'] as int? ?? 0) : (r['netTotal'] as int? ?? 0));
                
                final entryId = (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString();
                final bool isGuest = event.registrations.any((reg) => reg.memberId == entryId && reg.isGuest);

                return LeaderboardEntry(
                  entryId: entryId,
                  playerName: r['playerName'] ?? 'Unknown',
                  score: score,
                  scoreLabel: currentFormat == CompetitionFormat.matchPlay 
                      ? (score > 0 ? '+$score' : (score < 0 ? '$score' : 'AS')) 
                      : null,
                  handicap: (r['handicap'] as num?)?.toInt() ?? 0,
                  playingHandicap: isGross ? 0 : (r['playingHandicap'] as num?)?.toInt(),
                  isGuest: isGuest,
                );
              }));
            } else {
              // Grouped Mode (Pairs/Teams) - Lab Mode heuristic grouping
              final groupSize = currentMode == CompetitionMode.pairs ? 2 : 4;
              for (int i = 0; i < results.length; i += groupSize) {
                if (i + 1 >= results.length) {
                  break;
                }
                
                final r1 = results[i];
                final r2 = results[i + 1];
                
                final score = isStableford 
                    ? (isGross ? (r1['grossPoints'] as int? ?? 0) : (r1['points'] as int? ?? 0))
                    : (isGross ? (r1['grossTotal'] as int? ?? 0) : (r1['netTotal'] as int? ?? 0));

                final entryId = (r1['memberId'] ?? 'grp_$i').toString();
                // For groups, check if any member is a guest? Or just main player?
                final bool isGuest = event.registrations.any((reg) => reg.memberId == entryId && reg.isGuest);

                leaderboardEntries.add(LeaderboardEntry(
                  entryId: entryId,
                  playerName: r1['playerName'] ?? 'Unknown',
                  secondaryPlayerName: r2['playerName'] ?? 'Unknown',
                  score: score,
                  handicap: (r1['handicap'] as num?)?.toInt() ?? 0,
                  playingHandicap: isGross ? 0 : (r1['playingHandicap'] as num?)?.toInt(),
                  isGuest: isGuest,
                ));
              }
            }

            // If no results, show the original mock or empty?
            // For now, if results are empty, we keep the empty state or show a placeholder.

            final isPeeking = ref.watch(impersonationProvider) != null;

            return HeadlessScaffold(
              title: event.title,
              subtitle: 'Live Hub',
              showBack: true,
              onBack: () => context.go('/events'),
              actions: const [],
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  sliver: SliverToBoxAdapter(
                    child: _LiveHubToggle(event: event),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildTabContent(event, comp, leaderboardEntries, effectiveRules),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final selectedTab = ref.watch(eventDetailsTabProvider);
    final isSelected = selectedTab == index;
    
    // Define icons for each tab
    IconData icon;
    switch (index) {
      case 0:
        icon = Icons.assignment_outlined;
        break;
      case 1:
        icon = Icons.groups_outlined;
        break;
      case 2:
        icon = Icons.emoji_events_outlined;
        break;
      case 3:
        icon = Icons.bar_chart;
        break;
      case 4:
        icon = Icons.grid_view_outlined; // Or something for matches
        break;
      case 5:
        icon = Icons.account_tree_outlined; 
        break;
      default:
        icon = Icons.help_outline;
    }
    
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(eventDetailsTabProvider.notifier).set(index),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(GolfEvent event, Competition? comp, List<LeaderboardEntry> mockEntries, CompetitionRules effectiveRules) {
    final config = ref.watch(themeControllerProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    
    // Respect Lab Mode override
    // [Force Reload]
    final formatOverride = ref.watch(gameFormatOverrideProvider);
    final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
    final isStableford = currentFormat == CompetitionFormat.stableford;

    final now = DateTime.now();
    final isSameDayOrPast = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final statusOverride = ref.watch(eventStatusOverrideProvider);
    final effectiveStatus = statusOverride ?? event.status;

    final bool isLocked = event.isScoringLocked == true;
    final bool isCompleted = effectiveStatus == EventStatus.completed;
    final forceActiveOverride = ref.watch(scoringForceActiveOverrideProvider);
    // [FIX] Allow Force Active override to bypass 'Completed' status for testing
    final bool isScoringActive = (forceActiveOverride == true) || (!isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked)));
    final bool shouldShowCard = isSameDayOrPast || isCompleted || isLocked;

    final simulationHoles = ref.watch(simulationHoleCountOverrideProvider);
    final Map<String, int> playerHoleLimits = {};
    // [FIX] Only apply simulation if the event is 'In Play'
    if (simulationHoles != null && effectiveStatus == EventStatus.inPlay) {
      final groupsData = event.grouping['groups'] as List?;
      if (groupsData != null) {
        final List<TeeGroup> groups = groupsData.map((g) => TeeGroup.fromJson(g)).toList();
        for (int i = 0; i < groups.length; i++) {
          final groupLimit = (simulationHoles - i).clamp(0, 18);
          for (var p in groups[i].players) {
            playerHoleLimits[p.registrationMemberId] = groupLimit;
            playerHoleLimits['${p.registrationMemberId}_guest'] = groupLimit;
          }
        }
      }
    }

    switch (ref.watch(eventDetailsTabProvider)) {
      case 0: { // My Score
        final markerSelection = ref.watch(markerSelectionProvider);
        final bool isSelfMarking = markerSelection.isSelfMarking;
        final String? targetEntryId = markerSelection.targetEntryId;
        
        final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
        var userScorecard = ref.watch(scorecardByEntryIdProvider((competitionId: widget.eventId, entryId: effectiveEntryId)));
        List<int>? fallbackScores;
        ScorecardStatus? fallbackStatus;

        if (userScorecard == null) {
          final seededResult = event.results.firstWhere(
            (r) => r['playerId'] == effectiveEntryId,
            orElse: () => {},
          );
          if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
            fallbackScores = List<int>.from(seededResult['holeScores']);
            fallbackStatus = ScorecardStatus.values.firstWhereOrNull(
              (s) => s.name == seededResult['status'],
            ) ?? ScorecardStatus.finalScore;
          }
        }

        final emptyData = ref.watch(simulateEmptyDataProvider);
        List<int?> rawDisplayScores = emptyData 
            ? [] 
            : (userScorecard != null && userScorecard.holeScores.any((s) => s != null)
                ? userScorecard.holeScores 
                : (fallbackScores ?? []));

        // APPLY SIMULATION LIMIT
        final List<int?> displayScores = [];
        final limit = playerHoleLimits[effectiveEntryId];
        if (limit != null) {
          for (int i = 0; i < rawDisplayScores.length; i++) {
            if (i < limit) {
              displayScores.add(rawDisplayScores[i]);
            } else {
              // Nullify scores beyond simulation limit to hide them on the card
              displayScores.add(null);
            }
          }
        } else {
          displayScores.addAll(rawDisplayScores);
        }

        final displayStatus = userScorecard?.status ?? (isScoringActive ? null : fallbackStatus);

        // Calculate playing handicap (Hoisted)
        // Dynamic HC Source:
        // - Self Marking: Current User
        // - Marking Other (Player Tab): Target User
        // - Marking Other (Verifier Tab): Current User (My HC)
        double baseHcp = currentUser.handicap;

        // Fetch members to lookup dynamic handicap
        final allMembersAsync = ref.watch(allMembersProvider);
        
        if (!isSelfMarking && _markerTab == MarkerTab.player && targetEntryId != null) {
           final guestSuffix = '_guest';
           if (targetEntryId.endsWith(guestSuffix)) {
              // Look up guest handicap in grouping data
              final groupsData = event.grouping['groups'] as List?;
              if (groupsData != null) {
                final hostId = targetEntryId.replaceFirst(guestSuffix, '');
                for (var g in groupsData) {
                  final players = g['players'] as List?;
                  final guest = players?.firstWhere((p) => p['registrationMemberId'] == hostId && p['isGuest'] == true, orElse: () => null);
                  if (guest != null) {
                    baseHcp = (guest['handicapIndex'] as num?)?.toDouble() ?? 28.0;
                    break;
                  }
                }
              }
           } else if (allMembersAsync.hasValue) {
              try {
                final targetMember = allMembersAsync.value!.firstWhere((m) => m.id == targetEntryId);
                baseHcp = targetMember.handicap;
              } catch (_) {
                // Member not found in list, use default/current
              }
           }
        }
        

        double cappedHcp = baseHcp;
        if (comp != null) {
          if (baseHcp > comp.rules.handicapCap) {
            cappedHcp = comp.rules.handicapCap.toDouble();
          }
          cappedHcp = cappedHcp * comp.rules.handicapAllowance;
        }
        final int playingHcpValue = cappedHcp.round();

        // Determine Badge State
        String badgeText;
        Color badgeColor;
        VoidCallback? onBadgeTap;
        
        // Calculate completion (assuming 18 holes for now)
        final bool isComplete = (displayScores.length == 18) && 
                                displayScores.every((s) => s != null && s > 0);

        if (!isScoringActive) {
          badgeText = "NOT ACTIVE";
          badgeColor = Colors.grey;
        } else if (isLocked) {
          badgeText = "FINAL SCORE";
          badgeColor = Colors.green;
        } else if (displayStatus != null) {
          if (displayStatus == ScorecardStatus.draft && isComplete) {
            badgeText = "SUBMIT";
            badgeColor = Colors.green; // Action color
            onBadgeTap = () => _submitScorecard(userScorecard!.id);
          } else {
            badgeText = displayStatus.name.toUpperCase();
            badgeColor = _getStatusColor(displayStatus);
            
            // Allow Unsubmit ONLY if Submitted (and not locked by event)
            if (!isLocked && displayStatus == ScorecardStatus.submitted) {
               onBadgeTap = () => _confirmUnsubmit(userScorecard!.id);
            }
          }
        } else {
          badgeText = "ACTIVE";
          badgeColor = Colors.blue;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Handicap Info
                  Row(
                    children: [
                      Text(
                        'HC: ${_formatHcp(baseHcp)}', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey.shade600, 
                          fontWeight: FontWeight.w600
                        )
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4, 
                        height: 4, 
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300, 
                          shape: BoxShape.circle
                        )
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PHC: $playingHcpValue', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: Theme.of(context).primaryColor, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),

                  // Marker Toggle (Replaces Status Badge)
                  Consumer(
                    builder: (context, ref, _) {
                      final markerSelection = ref.watch(markerSelectionProvider);
                      final bool isSelfMarking = markerSelection.isSelfMarking;
                      final String? targetEntryId = markerSelection.targetEntryId;
                      
                      return GestureDetector(
                        onTap: () => _showMarkerSelectionSheet(event, isScoringActive),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelfMarking ? Icons.person : Icons.supervisor_account, 
                                size: 14, 
                                color: Theme.of(context).primaryColor
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSelfMarking 
                                    ? 'Marking: SELF' 
                                    : (targetEntryId != null 
                                        ? 'Marking: ${_getDisplayName(event, targetEntryId).split(' ').first.toUpperCase()}' 
                                        : 'Marking: SELECT'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
            if (shouldShowCard) ...[
              // NEW Hole-by-Hole View (Stacked below)
              Consumer(
                builder: (context, ref, _) {
                  final currentUser = ref.watch(effectiveUserProvider);
                  final markerSelection = ref.watch(markerSelectionProvider);
                  final bool isSelfMarking = markerSelection.isSelfMarking;
                  final String? targetEntryId = markerSelection.targetEntryId;
                  final myCard = ref.watch(userScorecardProvider(widget.eventId));
                  
                  // Target Card (Official)
                  final targetId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
                  final targetCard = ref.watch(scorecardByEntryIdProvider((
                    competitionId: widget.eventId, 
                    entryId: targetId
                  )));

                  // Determine what to show on the Grid (CourseInfoCard)
                  // If Self Marking: Show My Official Card (displayScores already handles this standard flow)
                  // If Marker Mode:
                  //   - Tab 0 (Player): Show Target Card
                  //   - Tab 1 (Verifier): Show My Verifier Scores
                  
                  List<int?> gridScores = [];
                  if (isSelfMarking) {
                     gridScores = displayScores;
                  } else {
                     if (_markerTab == MarkerTab.player) {
                       if (targetCard != null && targetCard.holeScores.isNotEmpty) {
                         gridScores = targetCard.holeScores;
                       } else {
                         // Fallback: Check for seeded result for the target player
                         final targetSeed = event.results.firstWhere(
                           (r) => r['playerId'] == targetId,
                           orElse: () => {},
                         );
                         if (targetSeed.isNotEmpty && targetSeed['holeScores'] != null) {
                           gridScores = List<int>.from(targetSeed['holeScores']);
                         }
                       }
                     } else {
                       gridScores = myCard?.playerVerifierScores ?? [];
                     }
                  }

                  final isVerifierView = !isSelfMarking && _markerTab == MarkerTab.verifier;

                  // Resolve effective rules/format for card
                  final maxTypeOverride = ref.watch(maxScoreTypeOverrideProvider);
                  final maxValueOverride = ref.watch(maxScoreValueOverrideProvider);
                  final formatOverride = ref.watch(gameFormatOverrideProvider);
                  final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
                  
                  MaxScoreConfig? effectiveMaxScore = comp?.rules.maxScoreConfig;
                  if (currentFormat == CompetitionFormat.maxScore) {
                    if (maxTypeOverride != null) {
                       effectiveMaxScore = MaxScoreConfig(
                         type: maxTypeOverride,
                         value: maxValueOverride ?? (effectiveMaxScore?.value ?? 2),
                       );
                    }
                  }

                  return Column(
                    children: [
                      CourseInfoCard(
                        courseConfig: event.courseConfig,
                        selectedTeeName: event.selectedTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        playerHandicap: playingHcpValue,
                        // Show scores if scoring is active OR it's a past/completed event
                        scores: shouldShowCard ? gridScores : [],
                        // Visual Cue for Viewer: Orange Header
                        headerColor: isVerifierView ? Colors.orange.withValues(alpha: 0.3) : null,
                        format: currentFormat,
                        maxScoreConfig: effectiveMaxScore,
                        holeLimit: limit, // [FIX] Apply simulation limit
                      ),
                      
                      const SizedBox(height: 16),
            
                      // NEW Hole-by-Hole View (Stacked below)
                      HoleByHoleScoringWidget(
                        event: event,
                        targetScorecard: targetCard,
                        verifierScorecard: myCard,
                        targetEntryId: targetId, // Use the resolved targetId
                        isSelfMarking: isSelfMarking,
                        selectedTab: _markerTab,
                        onTabChanged: (tab) {
                          setState(() => _markerTab = tab);
                        },
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 24),
                        
                        // Status Badge / Submit Action (Moved to Footer)
                        Center(
                child: GestureDetector(
                  onTap: onBadgeTap,
                  child: Container(
                    width: 140, // Fixed width
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: onBadgeTap != null ? 1.0 : 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: badgeColor),
                      boxShadow: onBadgeTap != null ? [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ) 
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onBadgeTap != null)
                           const Padding(
                             padding: EdgeInsets.only(right: 8.0),
                             child: Icon(Icons.check, size: 16, color: Colors.white),
                           ),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: onBadgeTap != null ? Colors.white : badgeColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48), // Padding at bottom
            ],
            
            // Body Content (Banner or Actions)
            if (!shouldShowCard)
               _buildInactiveBanner(event),
            
            if (fallbackScores != null) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Showing seeded scores for preview purposes.',
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
          ],
        );
      }
      case 1: { // Group Scores
        return _buildGroupScoresTab(event, effectiveRules, playerHoleLimits);
      }

      case 2: { // Leaderboard
        final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
        final membersAsync = ref.watch(allMembersProvider);
        
        return scorecardsAsync.when(
          data: (scorecards) => EventLeaderboard(
            event: event,
            comp: comp,
            liveScorecards: scorecards,
            membersList: membersAsync.value ?? [],
            playerHoleLimits: playerHoleLimits,
            onPlayerTap: (entry) => ScorecardModal.show(
              context, 
              ref,
              entry: entry, 
              scorecards: scorecards, 
              event: event, 
              comp: comp, 
              holeLimit: playerHoleLimits[entry.entryId] ?? simulationHoles,
            ),
          ),
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          )),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      }
      case 3: { // Stats
        final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));

        return scorecardsAsync.when(
          data: (liveScorecards) => EventStatsTab(
            event: event,
            comp: comp,
            liveScorecards: liveScorecards,
            playerHoleLimits: playerHoleLimits,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading stats: $e')),
        );
      }
      case 4: { // Matches
        return scorecardsAsync.when(
          data: (scorecards) => Column(
            children: [
              if (event.matches.any((m) => m.round == MatchRoundType.group))
                MatchGroupStandingsWidget(event: event, scorecards: scorecards),
              MatchesListWidget(eventId: widget.eventId),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      }
      case 5: { // Bracket
        return MatchesBracketWidget(eventId: widget.eventId);
      }
      default:
        return const SizedBox.shrink();
    }
  }


  Widget _buildGroupScoresTab(GolfEvent event, CompetitionRules rules, Map<String, int> playerHoleLimits) {
    final membersAsync = ref.watch(allMembersProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
    
    // Use effective rules
    final currentFormat = rules.format;
    final isStableford = currentFormat == CompetitionFormat.stableford;
    
    // [Lab Mode]
    // [FIX] Removed inconsistent score override check to match Leaderboard
    final isGross = rules.subtype == CompetitionSubtype.grossStableford;

    return scorecardsAsync.when(
      data: (scorecards) {
        final groupsData = event.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        if (groups.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Grouping is not yet available.', style: TextStyle(color: Colors.grey)),
          ));
        }

        // Create a map of scores for quick lookup
        final scoreMap = <String, String>{};
        final holes = event.courseConfig['holes'] as List? ?? [];

        // [LAB MODE]
        final emptyData = ref.watch(simulateEmptyDataProvider);

        // Identify all players in groups to ensure we check everyone
        final allGroupPlayers = groups.expand((g) => g.players).toList();

        for (var p in allGroupPlayers) {
           final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;

           if (emptyData) {
              scoreMap[playerId] = '-';
              continue;
           }

           // 1. Try to find live scorecard
           final scorecard = scorecards.firstWhere(
              (s) => s.entryId == playerId,
              orElse: () => Scorecard(
                 id: 'temp', 
                 competitionId: event.id,  // Correct parameter
                 roundId: 'round_1', // Required param
                 submittedByUserId: 'system', // Required param
                 createdAt: DateTime.now(), // Required param
                 updatedAt: DateTime.now(), // Required param
                 entryId: playerId, 
                 holeScores: [],
                 status: ScorecardStatus.draft // Dummy
              ),
           );

            List<int?>? rawScores = scorecard.holeScores.isNotEmpty ? scorecard.holeScores : null;
            List<int?>? scoresToUse;

           // 2. Fallback to seeded results if no live scores
           if (rawScores == null || rawScores.isEmpty) {
              final seededResult = event.results.firstWhere(
                 (r) => r['playerId'] == playerId || (p.isGuest && r['playerId'] == p.registrationMemberId),
                 orElse: () => {},
              );
              if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
                 rawScores = List<int?>.from(seededResult['holeScores']);
                 // If format is Stableford, we might need pre-calculated points from result?
                 // Or recalculate them here. Seeded results usually have 'points' total too.
                 if (isStableford && seededResult['points'] != null) {
                    // If a limit is present, we must recalculate, so don't skip.
                    if (playerHoleLimits[playerId] == null) {
                       scoreMap[playerId] = seededResult['points'].toString();
                       continue; // Skip calculation
                    }
                 }
              }
           }

            if (rawScores == null || rawScores.isEmpty) {
               scoreMap[playerId] = '-';
               continue;
            }

            // APPLY SIMULATION LIMIT
            final limit = playerHoleLimits[playerId];
            if (limit != null) {
               scoresToUse = [];
               for (int i = 0; i < rawScores.length; i++) {
                 if (i < limit) scoresToUse.add(rawScores[i]);
               }
            } else {
               scoresToUse = List<int?>.from(rawScores);
            }

           // Calculate Display Value based on Format
           if (isStableford) {
              // If we have a live scorecard or re-calculated points
              if (scorecard.points != null && scorecard.holeScores.isNotEmpty && !isGross && limit == null) {
                  scoreMap[playerId] = scorecard.points.toString();
              } else {
                  // Recalculate points for fallback scores OR if Gross override is active
                  // If Gross, PHC = 0.
                  final phc = isGross ? 0 : p.playingHandicap.round();

                 int totalPoints = 0;
                 int holesPlayed = 0;
                 
                 for (int i = 0; i < scoresToUse.length; i++) {
                    final score = scoresToUse[i];
                    if (score != null && i < holes.length) {
                       final par = holes[i]['par'] as int? ?? 4;
                       final si = holes[i]['si'] as int? ?? 18;
                       
                       // Calculate shots received on this hole
                       int shots = (phc ~/ 18);
                       if (si <= (phc % 18)) {
                         shots++;
                       }
                       
                       final netScore = score - shots;
                       // Stableford: 2 points for net par
                       final points = (2 + (par - netScore)).clamp(0, 10).toInt(); 
                       totalPoints += points;
                       holesPlayed++;
                    }
                 }
                 
                 if (holesPlayed > 0) {
                    scoreMap[playerId] = totalPoints.toString();
                 } else {
                    scoreMap[playerId] = '-';
                 }
             }
           } else {
            // Strokeplay: Calculate Net/Gross Differential
            int totalGross = 0;
            int holesPlayed = 0;

            for (int i = 0; i < scoresToUse.length; i++) {
              final score = scoresToUse[i];
              if (score != null) {
                totalGross += score;
                holesPlayed++;
              }
            }
            
            if (holesPlayed == 0) {
               scoreMap[playerId] = '-';
            } else {
               // Get Player's PHC
               final reg = event.registrations.firstWhere(
                  (r) => r.memberId == (playerId.endsWith('_guest') ? playerId.replaceFirst('_guest', '') : playerId),
                  orElse: () => EventRegistration(memberId: '', memberName: 'Unknown', attendingGolf: true),
               );
               final phc = isGross ? 0 : (reg.playingHandicap ?? 0);
               
               // Get Par for holes played
               int parForPlayed = 0;
               for (int i = 0; i < holesPlayed && i < holes.length; i++) {
                 parForPlayed += (holes[i]['par'] as int? ?? 4);
               } 

               // Calculate shots received for holes played (Standard SI match)
               int shotsReceived = 0;
               if (!isGross) {
                 for (int i = 0; i < holesPlayed && i < holes.length; i++) {
                    final si = holes[i]['si'] as int? ?? 18;
                    int shots = (phc ~/ 18);
                    if (si <= (phc % 18)) {
                      shots++;
                    }
                    shotsReceived += shots;
                 }
               }

               final netScore = totalGross - shotsReceived;
               final differential = netScore - parForPlayed;
               
               if (differential == 0) {
                  scoreMap[playerId] = 'E';
               } else if (differential > 0) {
                  scoreMap[playerId] = '+$differential';
               } else {
                  scoreMap[playerId] = '$differential';
               }
            }
           }
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0), // Consistent label spacing
              child: BoxyArtSectionTitle(title: 'Group Scores'),
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final members = membersAsync.value ?? [];
                final memberMap = {for (var m in members) m.id: m};

                return GroupingCard(
                  group: group,
                  memberMap: memberMap,
                  history: const [], // Not needed for score mode
                  totalGroups: groups.length,
                  rules: rules,
                  courseConfig: event.courseConfig,
                  isAdmin: false,
                  isScoreMode: true,
                  scoreMap: scoreMap,
                  scorecardMap: {for (var s in scorecards) s.entryId: s},
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      )),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildInactiveBanner(GolfEvent event) {
    final forceActiveOverride = ref.watch(scoringForceActiveOverrideProvider);
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.lock_clock_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'GAME NOT ACTIVE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              (forceActiveOverride == true) 
                  ? 'Admin has forced scoring to be active for this event.'
                  : 'Scoring will open on ${DateFormat('EEEE, d MMMM').format(event.date)}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }



  Color _getStatusColor(ScorecardStatus status) {
    switch (status) {
      case ScorecardStatus.draft:
        return Colors.grey;
      case ScorecardStatus.submitted:
        return Colors.blue;
      case ScorecardStatus.reviewed:
        return Colors.orange;
      case ScorecardStatus.finalScore:
        return Colors.green;
    }
  }

  String _getDisplayName(GolfEvent event, String entryId) {
    // 1. Check registrations (Members)
    final reg = event.registrations.where((r) => r.memberId == entryId).firstOrNull;
    if (reg != null) {
      return reg.memberName;
    }

    // 2. Check grouping data (Guests)
    final groupsData = event.grouping['groups'] as List?;
    if (groupsData != null) {
      for (var g in groupsData) {
        final players = g['players'] as List?;
        final guest = players?.firstWhere((p) {
          final pid = p['id'] ?? p['registrationMemberId'];
          final id = p['isGuest'] == true ? '${pid}_guest' : pid;
          return id == entryId;
        }, orElse: () => null);
        if (guest != null) {
          return guest['name'] ?? 'Guest';
        }
      }
    }

    return 'OTHER';
  }

  String _formatHcp(double hcp) {
    return hcp.truncateToDouble() == hcp ? hcp.toInt().toString() : hcp.toStringAsFixed(1);
  }


  void _showMarkerSelectionSheet(GolfEvent event, bool isScoringActive) {
    // [Lab Mode] Allow sheet even if not technically active

    // [Lab Mode] Allow sheet even if not technically active if an override is providing a "Live" test state
    final statusOverride = ref.read(eventStatusOverrideProvider);
    final forceActiveOverride = ref.read(scoringForceActiveOverrideProvider);
    final isTesting = statusOverride != null || forceActiveOverride != null;

    if (!isScoringActive && !isTesting) {
      return;
    }

    final currentUser = ref.read(effectiveUserProvider);
    final groupsData = event.grouping['groups'] as List?;
    final List<dynamic> groups = groupsData ?? []; 
    
    List<String> groupMembers = [];
    List<Map<String, dynamic>> groupPlayersRaw = [];
    for (var g in groups) {
      final players = (g['players'] as List?) ?? [];
      final hasMe = players.any((p) {
        final pid = p['id'] ?? p['registrationMemberId'];
        return pid == currentUser.id;
      });
      
      if (hasMe) {
        groupPlayersRaw = List<Map<String, dynamic>>.from(players);
        break;
      }
    }

    // [Refinement] Only show members of the actual group
    // If no group is found, the list remains empty (except for "Myself")
    if (groupMembers.isEmpty) {
       // Do nothing - user sees only "Myself"
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final markerSelection = ref.watch(markerSelectionProvider);
        final bool isSelfMarking = markerSelection.isSelfMarking;
        final String? targetEntryId = markerSelection.targetEntryId;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40, 
                height: 4, 
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2)
                )
              ),
              const SizedBox(height: 24),
              Text(
                'Who are you marking?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Option 1: Myself
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                        ),
                        title: const Text('Myself'),
                        trailing: isSelfMarking ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                        onTap: () {
                          ref.read(markerSelectionProvider.notifier).selectSelf();
                          Navigator.of(context).pop();
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      // Option 2: Group Members
                      ...groupPlayersRaw.where((p) {
                         final pid = p['id'] ?? p['registrationMemberId'];
                         final id = p['isGuest'] == true ? '${pid}_guest' : pid;
                         return id != currentUser.id;
                      }).map((p) {
                         final pid = p['id'] ?? p['registrationMemberId'];
                         final id = p['isGuest'] == true ? '${pid}_guest' : pid;
                         final name = p['name'] ?? 'Unknown';
                         final isSelected = !isSelfMarking && targetEntryId == id;
                          
                          return ListTile(
                             leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(p['isGuest'] == true ? Icons.person_outline : Icons.person, color: Theme.of(context).primaryColor),
                             ),
                             title: Text(name),
                             trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                             onTap: () {
                                ref.read(markerSelectionProvider.notifier).selectTarget(id!);
                                Navigator.of(context).pop();
                             },
                          );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _submitScorecard(String scorecardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Scorecard?'),
        content: const Text(
          'Are you sure you want to submit your scorecard? You will not be able to edit it afterwards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(scorecardRepositoryProvider).updateScorecardStatus(
          scorecardId, 
          ScorecardStatus.submitted
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Scorecard Submitted Successfully!'), backgroundColor: Colors.green),
           );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _confirmUnsubmit(String scorecardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsubmit Scorecard?'),
        content: const Text(
          'This will reopen your scorecard for editing. You will need to submit it again when finished.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unsubmit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(scorecardRepositoryProvider);
        await repo.updateScorecardStatus(scorecardId, ScorecardStatus.draft); // Revert to draft (scoring)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scorecard reopened for editing.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reopening scorecard: $e')),
          );
        }
      }
    }
  }



  // Define Format Helper


}

class EventStatsUserTab extends ConsumerWidget {
  final String eventId;
  const EventStatsUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
    final isPeeking = ref.watch(impersonationProvider) != null;

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Advanced Stats',
          showBack: true,
          onBack: () => context.go('/events'),
          actions: [
            IconButton(
              icon: Icon(Icons.science, color: isPeeking ? Colors.orange : Colors.black),
              onPressed: () {
                showModalBottomSheet(
                  context: context, 
                  isScrollControlled: true,
                  builder: (context) => LabControlPanel(eventId: event.id)
                );
              },
            ),
          ],
          slivers: [
            SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) => scorecardsAsync.when(
                  data: (scorecards) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: EventStatsTab(
                      event: event,
                      comp: comp,
                      liveScorecards: scorecards,
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

// [HUB NAVIGATION] Modern Live Hub Toggle
class _LiveHubToggle extends ConsumerWidget {
  final GolfEvent event;

  const _LiveHubToggle({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventDetailsTabProvider);
    final primary = Theme.of(context).primaryColor;

    final List<({String label, int index, IconData icon})> tabs = [
      (label: 'My Score', index: 0, icon: Icons.assignment_outlined),
      (label: 'Group', index: 1, icon: Icons.groups_outlined),
      (label: 'Leaderboard', index: 2, icon: Icons.emoji_events_outlined),
    ];

    if (event.matches.isNotEmpty) {
      tabs.add((label: 'Matches', index: 4, icon: Icons.grid_view_outlined));
    }
    if (event.matches.any((m) => m.bracketId != null)) {
      tabs.add((label: 'Bracket', index: 5, icon: Icons.account_tree_outlined));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = selectedTab == tab.index;
            return Expanded(
              child: _ToggleItem(
                label: tab.label,
                icon: tab.icon,
                isSelected: isSelected,
                onTap: () => ref.read(eventDetailsTabProvider.notifier).set(tab.index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
