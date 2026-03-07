import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../widgets/event_leaderboard.dart';
import '../widgets/scorecard_modal.dart';
import '../events_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../widgets/course_info_card.dart';
import '../widgets/hole_by_hole_scoring_widget.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';
// REDACTED: unused imports
// REDACTED: unused imports
import 'package:golf_society/services/persistence_service.dart';
// REDACTED: unused math import
import '../../../matchplay/presentation/widgets/matches_list_widget.dart';
import '../../../matchplay/presentation/widgets/matches_bracket_widget.dart';
import '../../../matchplay/presentation/widgets/match_group_standings_widget.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import '../../../matchplay/domain/match_definition.dart';

import 'event_stats_tab.dart';
import 'event_user_registration_tab.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart'; // [NEW] Added for Match Play row in My Score tab
import '../state/marker_selection_provider.dart';





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

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const HeadlessScaffold(
            title: 'Not Found',
            showBack: true,
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyState(
                  title: 'Event Not Found',
                  message: 'The requested event could not be located.',
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ],
          );
        }
        
        var effectiveEvent = event;
        
        final bool isPublished = effectiveEvent.isGroupingPublished;
        final groupsData = effectiveEvent.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        return HeadlessScaffold(
          title: event.title,
          subtitle: 'Field Hub',
          showBack: true,
          onBack: () => context.go('/events'),
          actions: const [],
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: _FieldHubToggle(),
              ),
            ),
            if (ref.watch(eventFieldTabProvider) == 0) ...[
              // Registrations View
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: membersAsync.when(
                    data: (members) => EventRegistrationUserTab.buildStaticContent(context, ref, event, members),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => BoxyArtEmptyState(
                      title: 'Loading Error',
                      message: 'Error loading member registrations: $error',
                      icon: Icons.error_outline_rounded,
                      isCompact: true,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Pairings View
              if (!isPublished)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: BoxyArtEmptyState(
                    title: 'Grouping Not Published',
                    message: 'The Admin will publish the tee sheet soon. Contact your society secretary if you believe this is an error.',
                    icon: Icons.unarchive_rounded,
                  ),
                )
              else 
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.pageBottom),
                   sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                         (context, index) {
                             final group = groups[index];
                             final members = membersAsync.value ?? [];
                             final memberMap = {for (var m in members) m.id: m};
                            final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
                            final comp = compAsync.value;
                            
                            return Padding(
                               padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                               child: GroupingCard(
                                  group: group,
                                  memberMap: memberMap,
                                  history: history,
                                  totalGroups: groups.length,
                                  rules: comp?.rules.copyWith(
                                    format: comp.rules.format,
                                    mode: comp.rules.mode,
                                    handicapAllowance: comp.rules.handicapAllowance,
                                    teamBestXCount: comp.rules.teamBestXCount,
                                    aggregation: comp.rules.aggregation,
                                  ),
                                  courseConfig: event.courseConfig,
                                  isAdmin: false,
                                  scorecardMap: scorecardsAsync.asData?.value != null 
                                      ? {for (var s in scorecardsAsync.asData!.value) s.entryId: s}
                                      : null,
                               ),
                            );
                         },
                         childCount: groups.length,
                      ),
                   ),
                ),
            ],
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Loading...',
        slivers: [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (err, stack) => HeadlessScaffold(
        title: 'Error',
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: BoxyArtEmptyState(
              title: 'Unexpected Error',
              message: err.toString(),
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldHubToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventFieldTabProvider);

    return ModernUnderlinedFilterBar<int>(
      selectedValue: selectedTab,
      isExpanded: true,
      onTabSelected: (val) => ref.read(eventFieldTabProvider.notifier).set(val),
      tabs: const [
        ModernFilterTab(label: 'Entries', value: 0),
        ModernFilterTab(label: 'Groupings', value: 1),
      ],
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
  Map<int, int>? _optimisticScores; // [Optimistic UI]
  bool _optimisticIsVerifier = false;
  
  // TRACK SELECTED TAB (Lifted State from HoleByHole)
  MarkerTab _selectedMarkerTab = MarkerTab.player;

  void _onScoresChanged(Map<int, int> scores, bool isVerifier) {
    setState(() {
      _optimisticScores = scores;
      _optimisticIsVerifier = isVerifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));
    return eventsAsync.when(
      data: (events) {
        final baseEvent = events.firstWhereOrNull((e) => e.id == widget.eventId);
        if (baseEvent == null) {
          return const HeadlessScaffold(
            title: 'Not Found',
            showBack: true,
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyState(
                  title: 'Event Not Found',
                  message: 'The requested event could not be located.',
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ],
          );
        }
        
        var event = baseEvent;


        
        return compAsync.when(
          data: (comp) {
            final rules = comp?.rules ?? const CompetitionRules();
            
            final effectiveRules = rules;

            // Force Gross Scoring check

            final currentFormat = effectiveRules.format;
            final currentMode = effectiveRules.effectiveMode;
            
            final isStableford = currentFormat == CompetitionFormat.stableford;
            final results = event.results;
            
            final int coursePar = event.courseConfig.par ?? 72;
            
            final List<LeaderboardEntry> leaderboardEntries = [];
            
            if (currentMode == CompetitionMode.singles) {
              leaderboardEntries.addAll(results.map((r) {
                // Gross Scoring Check
                final score = isStableford 
                    ? (r['points'] as int? ?? 0)
                    : (r['netTotal'] as int? ?? 0);
                
                final entryId = (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString();
                final bool isGuest = event.registrations.any((reg) => reg.memberId == entryId && reg.isGuest);

                String? scoreLabel = r['displayValue']?.toString();
                if (currentFormat == CompetitionFormat.matchPlay) {
                  scoreLabel = score > 0 ? '+$score' : (score < 0 ? '$score' : 'AS');
                } else if (!isStableford) {
                  final netToPar = score - coursePar;
                  scoreLabel = netToPar == 0 ? 'E' : (netToPar > 0 ? '+$netToPar' : '$netToPar');
                }

                return LeaderboardEntry(
                  entryId: entryId,
                  playerName: r['playerName'] ?? 'Unknown',
                  score: score,
                  scoreLabel: scoreLabel,
                  handicap: (r['handicap'] as num?)?.toInt() ?? 0,
                  playingHandicap: (r['playingHandicap'] as num?)?.toInt(),
                  isGuest: isGuest,
                );
              }));
            } else {
              // Grouped Mode (Pairs/Teams) - Lab Mode heuristic grouping
              final groupSize = currentMode == CompetitionMode.pairs ? 2 : 4;
              for (int i = 0; i < results.length; i += groupSize) {
                final groupResults = <Map<String, dynamic>>[];
                for (int j = 0; j < groupSize && (i + j) < results.length; j++) {
                  groupResults.add(results[i + j]);
                }

                if (groupResults.isEmpty) break;
                
                final mainR = groupResults.first;
                final names = groupResults.map((r) => r['playerName']?.toString() ?? 'Unknown').toList();
                final ids = groupResults.map((r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString()).toList();
                
                final score = isStableford 
                    ? (mainR['points'] as int? ?? 0)
                    : (mainR['netTotal'] as int? ?? 0);

                final entryId = ids.join('_');
                final bool isGuest = groupResults.any((r) {
                  final rid = (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString();
                  return event.registrations.any((reg) => reg.memberId == rid && reg.isGuest);
                });

                String? scoreLabel = mainR['displayValue']?.toString();
                if (currentFormat == CompetitionFormat.matchPlay) {
                  scoreLabel = score > 0 ? '+$score' : (score < 0 ? '$score' : 'AS');
                } else if (!isStableford) {
                  final netToPar = score - coursePar;
                  scoreLabel = netToPar == 0 ? 'E' : (netToPar > 0 ? '+$netToPar' : '$netToPar');
                }

                leaderboardEntries.add(LeaderboardEntry(
                  entryId: entryId,
                  playerName: names.first,
                  secondaryPlayerName: names.length > 1 ? names[1] : null,
                  teamMemberNames: names,
                  teamMemberIds: ids,
                  score: score,
                  scoreLabel: scoreLabel,
                  handicap: (mainR['handicap'] as num?)?.toInt() ?? 0,
                  playingHandicap: (mainR['playingHandicap'] as num?)?.toInt(),
                  isGuest: isGuest,
                  mode: currentMode,
                  holeScores: mainR['holeScores'] != null ? List<int?>.from(mainR['holeScores']) : null,
                ));
              }
            }

            // If no results, show the original mock or empty?
            // For now, if results are empty, we keep the empty state or show a placeholder.


            // --- NEW: Calculate Badge Info for Header ---
            final int selectedTabIndex = ref.watch(eventDetailsTabProvider);
            final currentUser = ref.watch(effectiveUserProvider);
            final markerSelection = ref.watch(markerSelectionProvider);
            final bool isSelfMarking = markerSelection.isSelfMarking;
            final String? targetEntryId = markerSelection.targetEntryId;
            final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);

            final allScorecards = ref.watch(scorecardsListProvider(widget.eventId)).asData?.value ?? [];
            final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
            
            String? headerBadgeText;
            Color? headerBadgeColor;
            VoidCallback? headerOnBadgeTap;
            
            // Only show badge in "My Score" tab (index 0)
            if (selectedTabIndex == 0) {
                final effectiveStatus = event.status;
                final bool isLocked = event.isScoringLocked == true;
                final bool isCompleted = effectiveStatus == EventStatus.completed;
                
                final now = DateTime.now();
                final isSameDayOrPast = now.year == event.date.year && 
                                         now.month == event.date.month && 
                                         now.day == event.date.day || 
                                         now.isAfter(event.date);

                final bool isScoringActive = !isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));

                // Simple check for completeness (needs full score list for accuracy, but this is a close approximation for the header)
                // For a robust implementation, this logic is usually identical to what was inside _buildMyScoreView.
                final bool isCardFull = userScorecard?.holeScores.length == 18 && userScorecard!.holeScores.every((s) => s != null && s > 0);

                if (isLocked) {
                  headerBadgeText = "FINAL SCORE";
                  headerBadgeColor = AppColors.lime600;
                } else if (isCompleted) {
                  headerBadgeText = "FINISHED";
                  headerBadgeColor = AppColors.lime600;
                } else if (!isScoringActive) {
                  headerBadgeText = "NOT ACTIVE";
                  headerBadgeColor = AppColors.dark300;
                } else if (userScorecard != null) {
                  if (userScorecard.status == ScorecardStatus.draft && isCardFull) {
                    headerBadgeText = "SUBMIT";
                    headerBadgeColor = AppColors.amber500; 
                    headerOnBadgeTap = () => _submitScorecard(userScorecard.id);
                  } else {
                    if (userScorecard.status == ScorecardStatus.submitted) {
                      headerBadgeText = "SUBMITTED";
                      headerOnBadgeTap = () => _confirmUnsubmit(userScorecard.id);
                    } else if (userScorecard.status == ScorecardStatus.reviewed || 
                               userScorecard.status == ScorecardStatus.finalScore) {
                      headerBadgeText = "CONFIRMED";
                    } else {
                      headerBadgeText = "SCORING";
                    }
                    headerBadgeColor = _getStatusColor(userScorecard.status);
                  }
                } else {
                  headerBadgeText = "ACTIVE";
                  headerBadgeColor = AppColors.lime400;
                }
            }
            // ------------------------------------------

            return HeadlessScaffold(
              title: event.title,
              subtitle: 'Live Hub',
              contentPadding: const EdgeInsets.only(top: 120, left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.xl),
              showBack: true,
              onBack: () => context.go('/events'),
              actions: [
                if (headerBadgeText != null) 
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: GestureDetector(
                        onTap: headerOnBadgeTap,
                        child: AnimatedContainer(
                          duration: AppAnimations.fast,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: headerOnBadgeTap != null ? headerBadgeColor : headerBadgeColor?.withValues(alpha: AppColors.opacityLow),
                            borderRadius: AppShapes.md,
                            border: Border.all(color: headerBadgeColor!.withValues(alpha: AppColors.opacityMuted)),
                            boxShadow: headerOnBadgeTap != null ? [
                              BoxShadow(
                                color: headerBadgeColor.withValues(alpha: AppColors.opacityMuted),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (headerOnBadgeTap != null)
                                const Padding(
                                  padding: EdgeInsets.only(right: AppSpacing.xs),
                                  child: Icon(Icons.check_circle_outline, size: AppShapes.iconXs, color: AppColors.pureWhite),
                                ),
                              Text(
                                headerBadgeText,
                                style: TextStyle(
                                  fontSize: AppTypography.sizeCaption,
                                  color: headerOnBadgeTap != null ? AppColors.pureWhite : headerBadgeColor,
                                  fontWeight: AppTypography.weightBlack,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: _LiveHubToggle(event: event),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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

  Widget _buildTabContent(GolfEvent event, Competition? comp, List<LeaderboardEntry> mockEntries, CompetitionRules effectiveRules) {
    final config = ref.watch(themeControllerProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final markerSelection = ref.watch(markerSelectionProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    
    final currentFormat = comp?.rules.format ?? CompetitionFormat.stableford;
    final isStableford = currentFormat == CompetitionFormat.stableford;

    final now = DateTime.now();
    final isSameDayOrPast = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);
    
    final effectiveStatus = event.status;

    final bool isLocked = event.isScoringLocked == true;
    final bool isCompleted = effectiveStatus == EventStatus.completed;
    // [FIX] Allow Force Active override removed (Lab only)
    final bool isScoringActive = !isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));
    final bool shouldShowCard = isSameDayOrPast || isCompleted || isLocked;

    final Map<String, int> playerHoleLimits = {};

    switch (ref.watch(eventDetailsTabProvider)) {
      case 0: { // My Score
        final markerSelection = ref.watch(markerSelectionProvider);
        final bool isSelfMarking = markerSelection.isSelfMarking;
        final String? targetEntryId = markerSelection.targetEntryId;
        
        final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
         
        // [FIX] Use list lookup instead of single provider to ensure consistency with loaded data
        final allScorecards = ref.watch(scorecardsListProvider(widget.eventId)).asData?.value ?? [];
        final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
        final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);


        List<int>? fallbackScores;

        // [FIX] Always look up seeded data so we can fill gaps in partial scorecards
        // Try exact match first, then try partial match for fourball composite IDs
        var seededResultForSelf = event.results.firstWhere(
          (r) => r['playerId'] == effectiveEntryId,
          orElse: () => {},
        );
        // [FIX] If exact match fails, try finding results where the playerId contains the effectiveEntryId
        if (seededResultForSelf.isEmpty) {
          seededResultForSelf = event.results.firstWhere(
            (r) => (r['playerId'] as String?)?.contains(effectiveEntryId) == true ||
                   effectiveEntryId.contains(r['playerId'] as String? ?? '___'),
            orElse: () => {},
          );
        }
        debugPrint('seededResult found: ${seededResultForSelf.isNotEmpty}, playerId: ${seededResultForSelf['playerId']}');
        if (seededResultForSelf.isNotEmpty && seededResultForSelf['holeScores'] != null) {
          fallbackScores = List<int>.from(seededResultForSelf['holeScores']);

          debugPrint('fallbackScores: ${fallbackScores.length} holes loaded');
        }

        // Per-hole merge: live scorecard > seeded data (fills scattered nulls)
        List<int?> rawDisplayScores;
        if (userScorecard != null && userScorecard.holeScores.any((s) => s != null)) {
          // Merge live + seeded per-hole
          rawDisplayScores = List.generate(18, (i) {
            final live = i < userScorecard.holeScores.length ? userScorecard.holeScores[i] : null;
            final seed = (fallbackScores != null && i < fallbackScores.length) ? fallbackScores[i] : null;
            return live ?? seed;
          });
        } else {
          rawDisplayScores = fallbackScores?.cast<int?>() ?? [];
        }

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


        // Calculate playing handicap (Hoisted)
        // Dynamic HC Source:
        // - Self Marking: Current User
        // - Marking Other (Player Tab): Target User
        // - Marking Other (Verifier Tab): Current User (My HC)
        double baseHcp = currentUser.handicap;

        // [FIX] Handicap Display Refinement
        // Show target handicap ONLY if marking another AND on the PLAYER tab.
        // Otherwise (Self Marking or MY SCORE tab), show current user's handicap.
        final bool shouldShowTargetHcp = !isSelfMarking && _selectedMarkerTab == MarkerTab.player && targetEntryId != null;

        if (shouldShowTargetHcp) {
           // Fetch members to lookup dynamic handicap
           final allMembersAsync = ref.watch(allMembersProvider);
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
              final targetMember = allMembersAsync.value!.firstWhereOrNull((m) => m.id == targetEntryId);
              if (targetMember != null) {
                baseHcp = targetMember.handicap;
              } else {
                // Fallback: Look up in grouping participants (contains handicap for all competitors)
                final groupsData = event.grouping['groups'] as List?;
                if (groupsData != null) {
                   for (var g in groupsData) {
                      final players = g['players'] as List?;
                      final found = players?.firstWhereOrNull((p) => p['registrationMemberId'] == targetEntryId);
                      if (found != null) {
                         baseHcp = (found['handicapIndex'] as num?)?.toDouble() ?? 28.0;
                         break;
                      }
                   }
                }
              }
           }
        }
        
        // [TEAM SCORER AWARENESS]
        // If in a team game (Scramble/Pairs), check if a teammate is scoring
        Scorecard? partnerCard;
        String? partnerName;
        bool hasScoreConflict = false;
        
        // [FIX] Skip conflict check for fourball/pairs — partners legitimately have different scores
        final isFourballOrPairs = effectiveRules.subtype == CompetitionSubtype.fourball || 
                                  effectiveRules.mode == CompetitionMode.pairs ||
                                  effectiveRules.subtype == CompetitionSubtype.foursomes;

        // [FIX] Suppress conflict detection if game is closed/completed or inactive
        final bool shouldCheckConflict = isScoringActive && !isLocked;
        if (shouldCheckConflict && effectiveRules.effectiveMode != CompetitionMode.singles && isSelfMarking && !isFourballOrPairs) {
           final groupsData = event.grouping['groups'] as List?;
           if (groupsData != null) {
              // Find my group and team
              for (var g in groupsData) {
                 final players = (g['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList();
                 final myIndex = players.indexWhere((p) => (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) == effectiveEntryId);
                 
                 if (myIndex != -1) {
                    // Identify Team Members
                    final teamSize = effectiveRules.teamSize; // Default 4 if null
                    // If teamSize is 2 (Pairs), indices 0-1 are Team A, 2-3 are Team B
                    // If teamSize is 3/4 (Scramble), whole group (upto teamSize) is one team usually
                    
                    int teamStartIndex = (myIndex ~/ teamSize) * teamSize;
                    int teamEndIndex = teamStartIndex + teamSize;
                    if (teamEndIndex > players.length) teamEndIndex = players.length;
                    
                    final teamMembers = players.sublist(teamStartIndex, teamEndIndex);
                    
                    // Check their scorecards
                    for (var member in teamMembers) {
                       final memberId = member.isGuest ? '${member.registrationMemberId}_guest' : member.registrationMemberId;
                       if (memberId == effectiveEntryId) continue; // Skip myself
                       
                       final pCard = allScorecards.firstWhereOrNull((s) => s.entryId == memberId);
                       if (pCard != null && pCard.holeScores.any((s) => s != null)) {
                          // Found a teammate with scores
                          // Conflict Check: Do I also have scores?
                          if (userScorecard != null && userScorecard.holeScores.any((s) => s != null)) {
                             // potential conflict or just parallel scoring
                             // Check for specific hole mismatch
                             for (int i=0; i<18; i++) {
                                final myScore = userScorecard.holeScores.elementAtOrNull(i);
                                final theirScore = pCard.holeScores.elementAtOrNull(i);
                                if (myScore != null && theirScore != null && myScore != theirScore) {
                                   hasScoreConflict = true;
                                   partnerName = member.name; // Blame the first one found
                                   partnerCard = pCard;
                                   break;
                                }
                             }
                          } else {
                             // I have no scores (or empty), so they are the active scorer
                             if (partnerCard == null || (pCard.holeScores.where((s) => s != null).length > partnerCard.holeScores.where((s) => s != null).length)) {
                                partnerCard = pCard;
                                partnerName = member.name;
                             }
                          }
                       }
                       if (hasScoreConflict) break;
                    }
                    break; // Found my group
                 }
              }
           }
        }
        

        // [FIX] Use Single Source of Truth for PHC (stored in grouping)
        // This ensures the scorecard matches the Group/Leaderboard views and handles guest suffixes correctly.
        final int playingHcpValue = HandicapCalculator.getStoredPhc(event.grouping, effectiveEntryId);

        return _buildMyScoreView(
          context: context,
          event: event,
          comp: comp,
          config: config,
          isScoringActive: isScoringActive,
          shouldShowCard: shouldShowCard,
          displayScores: displayScores,
          playingHcpValue: playingHcpValue,
          baseHcp: baseHcp,
          limit: limit,
          isStableford: isStableford,
          userScorecard: userScorecard,
          myCard: myCard,
          partnerCard: partnerCard,
          partnerName: partnerName,
          hasScoreConflict: hasScoreConflict,
          targetEntryId: targetEntryId,
        );
      }
      case 1: { // Group Scores
        return _buildGroupScoresTab(event, effectiveRules, playerHoleLimits, markerSelection.teeOverrides);
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
              membersList: membersAsync.value ?? [],
              holeLimit: playerHoleLimits[entry.entryId],
              teeOverrides: markerSelection.teeOverrides,
            ),
          ),
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(AppSpacing.x3l),
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


  Widget _buildGroupScoresTab(GolfEvent event, CompetitionRules rules, Map<String, int> playerHoleLimits, Map<String, String> teeOverrides) {
    final membersAsync = ref.watch(allMembersProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
    
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
            padding: EdgeInsets.all(AppSpacing.x3l),
            child: Text('Grouping is not yet available.', style: TextStyle(color: AppColors.textSecondary)),
          ));
        }

        // Create a map of scores for quick lookup
// removed unused holes

        // [LAB MODE]
        final isTeamMode = rules.effectiveMode != CompetitionMode.singles;
        final teamSize = rules.teamSize;

        final Map<String, String> scoreMap = {};
        final Map<String, int> teamPhcMap = {}; // [NEW] Track Team PHCs
        final Map<String, bool> winnerMap = {};
        final Map<String, String> betterBallMap = {}; // [NEW] Track per-team BB aggregate
        
        for (var group in groups) {
           // Partition group into teams if necessary
           final List<List<TeeGroupParticipant>> teams = [];
           if (isTeamMode) {
              for (int i = 0; i < group.players.length; i += teamSize) {
                 teams.add(group.players.skip(i).take(teamSize).toList());
              }
           } else {
              for (var p in group.players) { teams.add([p]); }
           }

           for (var team in teams) {
              if (team.isEmpty) continue;
              
              // 1. Calculate Team PHC (Fallback for Scramble/Team modes)
              int teamPhc = 0;
              final isTeamModeForHcp = rules.effectiveMode != CompetitionMode.singles;
              if (isTeamModeForHcp) {
                 final List<double> indices = [];
                 for (var p in team) {
                    final member = membersAsync.value?.firstWhereOrNull((m) => m.id == p.registrationMemberId);
                    indices.add(member?.handicap ?? p.handicapIndex);
                 }
                 teamPhc = HandicapCalculator.calculateTeamHandicap(
                    individualIndices: indices, 
                    rules: rules, 
                    courseConfig: event.courseConfig,
                 );
              }

              // 2. Resolve Better Ball Score for Fourball/Pairs
              String displayScore = '-';
              final isFourball = rules.subtype == CompetitionSubtype.fourball;
              
              if (isFourball) {
                // Collect cards for all team members
                final List<Scorecard> teamCards = [];
                for (var p in team) {
                  final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                  final card = scorecards.firstWhereOrNull((s) => s.entryId == playerId);
                  if (card != null && card.holeScores.any((s) => s != null)) {
                    teamCards.add(card);
                  }
                }

                // final rawHoles = event.courseConfig['holes'] as List? ?? [];
                // final List<Map<String, dynamic>> holesData = rawHoles.map((h) => Map<String, dynamic>.from(h)).toList();

                // --- A) Calculate INDIVIDUAL scores per player ---
                for (var p in team) {
                  final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                  final card = scorecards.firstWhereOrNull((s) => s.entryId == playerId);
                  // 1. Resolve robust Course Config for this player
                  final manualTee = teeOverrides[playerId];
                  final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                    memberId: playerId, 
                    event: event, 
                    membersList: membersAsync.value ?? [], 
                    manualTeeName: manualTee,
                  );
                  final member = membersAsync.value?.firstWhereOrNull((m) => m.id == p.registrationMemberId);
                  final phc = teamPhcMap[playerId] ?? HandicapCalculator.calculatePlayingHandicap(
                    handicapIndex: member?.handicap ?? p.handicapIndex,
                    rules: rules,
                    courseConfig: playerTeeConfig,
                  );
                  teamPhcMap[playerId] = phc;

                  // [NEW] Authoritative Fallback for Fourball
                  final seededResult = event.results.firstWhere(
                    (r) => r['playerId'] == playerId,
                    orElse: () => {},
                  );
                  List<int?> scoresToUse = [];
                  if (card != null && card.holeScores.any((s) => s != null)) {
                    final limit = playerHoleLimits[playerId];
                    List<int?> liveScores = card.holeScores;
                    if (limit != null) {
                      liveScores = card.holeScores.take(limit).toList();
                    }
                    scoresToUse = List.generate(18, (i) {
                       final live = i < liveScores.length ? liveScores[i] : null;
                       final seed = (seededResult['holeScores'] != null && i < seededResult['holeScores'].length) ? seededResult['holeScores'][i] : null;
                       return live ?? seed;
                    });
                  } else if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
                    scoresToUse = (seededResult['holeScores'] as List).cast<int?>();
                  }

                  if (scoresToUse.isNotEmpty && scoresToUse.any((s) => s != null)) {
                    final result = ScoringCalculator.calculate(
                      holeScores: scoresToUse,
                      holes: playerTeeConfig.holes,
                      playingHandicap: phc.toDouble(),
                      format: rules.format,
                      maxScoreConfig: rules.maxScoreConfig,
                    );
                    scoreMap[playerId] = result.label;
                  } else {
                    scoreMap[playerId] = '-';
                  }
                }

                // --- B) Calculate BETTER-BALL aggregate per PAIR (A=first 2, B=rest) ---
                // Split team cards into pairs based on group player order
                final groupIdx = groups.indexOf(group);
                final groupPlayers = group.players;
                
                for (int pairIdx = 0; pairIdx < 2; pairIdx++) {
                  final pairStart = pairIdx * 2;
                  final pairEnd = (pairStart + 2).clamp(0, groupPlayers.length);
                  if (pairStart >= groupPlayers.length) continue;
                  
                  final pairPlayers = groupPlayers.sublist(pairStart, pairEnd);
                  int bbTotal = 0;
                  bool hasAny = false;

                  // Pre-resolve merged scores for the pair
                  final Map<String, List<int?>> pairMergedScores = {};
                  for (var p in pairPlayers) {
                    final pid = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                    final card = scorecards.firstWhereOrNull((s) => s.entryId == pid);
                    final seededResult = event.results.firstWhere(
                      (r) => r['playerId'] == pid,
                      orElse: () => {},
                    );
                    
                    List<int?> liveScores = card?.holeScores ?? [];
                    final limit = playerHoleLimits[pid];
                    if (limit != null && liveScores.isNotEmpty) {
                      liveScores = liveScores.take(limit).toList();
                    }

                    pairMergedScores[pid] = List.generate(18, (i) {
                       final live = i < liveScores.length ? liveScores[i] : null;
                       final seed = (seededResult['holeScores'] != null && i < seededResult['holeScores'].length) ? seededResult['holeScores'][i] : null;
                       return live ?? seed;
                    });
                  }

                  for (int h = 0; h < 18; h++) {
                    int bestPoints = -1;
                    int bestNetToPar = 999;

                    for (var p in pairPlayers) {
                        final pid = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                        final scoresToUse = pairMergedScores[pid]!;
                        final score = scoresToUse.length > h ? scoresToUse[h] : null;
                        if (score == null) continue;
                        hasAny = true;
                        
                        final phc = teamPhcMap[pid] ?? 0;
                        
                        // Use player-specific course config for holes/si/par
                        final manualTee = teeOverrides[pid];
                        final ptc = ScoringCalculator.resolvePlayerCourseConfig(
                          memberId: pid, 
                          event: event, 
                          membersList: membersAsync.value ?? [], 
                          manualTeeName: manualTee,
                        );
                        final playerHoles = ptc.holes;
                        final si = playerHoles.length > h ? playerHoles[h].si : 18;
                        final par = playerHoles.length > h ? playerHoles[h].par : 4;
                        final freeShots = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);

                        if (rules.format == CompetitionFormat.stableford) {
                          final net = score - freeShots;
                          final pts = (par - net + 2).clamp(0, 10);
                          if (pts > bestPoints) bestPoints = pts;
                        } else {
                          final netToPar = (score - freeShots) - par;
                          if (netToPar < bestNetToPar) bestNetToPar = netToPar;
                        }
                    }
                    if (rules.format == CompetitionFormat.stableford) {
                       if (bestPoints >= 0) bbTotal += bestPoints;
                    } else {
                       if (bestNetToPar != 999) bbTotal += bestNetToPar;
                    }
                  }
                  
                  if (hasAny) {
                    final bbKey = 'g${groupIdx}_${pairIdx == 0 ? "a" : "b"}';
                    if (rules.format == CompetitionFormat.stableford) {
                      betterBallMap[bbKey] = bbTotal.toString();
                    } else {
                      betterBallMap[bbKey] = bbTotal == 0 ? 'E' : (bbTotal > 0 ? '+$bbTotal' : bbTotal.toString());
                    }
                  }
                }
              } else {
                // Non-Fourball (Singles / Scamble)
                Scorecard? teamCard;
                for (var p in team) {
                  final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                  final card = scorecards.firstWhereOrNull((s) => s.entryId == playerId);
                  if (card != null && card.holeScores.isNotEmpty) {
                    teamCard = card;
                    break;
                  }
                }

                // [NEW] Authoritative Fallback: Resolve seeded scores for this team/player
                final String firstPlayerId = team.first.isGuest ? '${team.first.registrationMemberId}_guest' : team.first.registrationMemberId;
                List<int>? seededScores;
                final seededResult = event.results.firstWhere(
                  (r) => r['playerId'] == firstPlayerId,
                   orElse: () => {},
                );
                if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
                   seededScores = List<int>.from(seededResult['holeScores']);
                }

                List<int?> scoresToUse = [];

                if (teamCard != null && teamCard.holeScores.isNotEmpty) {
                    final limit = playerHoleLimits[teamCard.entryId];
                    List<int?> liveScores = teamCard.holeScores;
                    if (limit != null) {
                      liveScores = teamCard.holeScores.take(limit).toList();
                    }

                    // Merge live and seeded data
                    scoresToUse = List.generate(18, (i) {
                       final live = i < liveScores.length ? liveScores[i] : null;
                       final seed = (seededScores != null && i < seededScores.length) ? seededScores[i] : null;
                       return live ?? seed;
                    });
                } else if (seededScores != null) {
                    // Pull directly from seeded results if no live scorecard exists
                    scoresToUse = seededScores.cast<int?>();
                }

                if (scoresToUse.isNotEmpty) {
                    final targetMemberId = team.first.isGuest ? '${team.first.registrationMemberId}_guest' : team.first.registrationMemberId;
                    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                      memberId: team.first.registrationMemberId, 
                      event: event, 
                      membersList: membersAsync.value ?? [], 
                      manualTeeName: teeOverrides[targetMemberId],
                    );

                     int effectivePhc = isTeamMode ? teamPhc : HandicapCalculator.calculatePlayingHandicap(
                       handicapIndex: membersAsync.value?.firstWhereOrNull((m) => m.id == team.first.registrationMemberId)?.handicap ?? team.first.handicapIndex,
                       rules: rules,
                       courseConfig: playerTeeConfig,
                     );

                    if (isGross) {
                      effectivePhc = 0;
                    }

                    final result = ScoringCalculator.calculate(
                      holeScores: scoresToUse, 
                      holes: playerTeeConfig.holes, 
                      playingHandicap: effectivePhc.toDouble(), 
                      format: rules.format,
                      maxScoreConfig: rules.maxScoreConfig,
                    );

                    displayScore = result.label;
                }

              }

              // 5. Apply to all team members (skip fourball — handled above with individual scores)
              if (!isFourball) {
                for (var p in team) {
                  final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                  scoreMap[playerId] = displayScore;
                  
                  // Only apply a shared "Team PHC" for Scramble/Teams mode.
                  // Pairs (Fourball/Foursomes) ALWAYS use individual PHCs/Indices in the tiles.
                  if (rules.mode == CompetitionMode.teams && rules.subtype != CompetitionSubtype.fourball && rules.subtype != CompetitionSubtype.foursomes) {
                    teamPhcMap[playerId] = teamPhc;
                  }
                }
              }
           }
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), // Consistent label spacing
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
                  winnerMap: winnerMap,
                  phcMap: teamPhcMap,
                  matchPlayMode: rules.format == CompetitionFormat.matchPlay || rules.subtype == CompetitionSubtype.fourball,
                  betterBallMap: betterBallMap,
                  groupIndex: index,
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(AppSpacing.x3l),
        child: CircularProgressIndicator(),
      )),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMyScoreView({
    required BuildContext context,
    required GolfEvent event,
    required Competition? comp,
    required SocietyConfig config,
    required bool isScoringActive,
    required bool shouldShowCard,
    required List<int?> displayScores,
    required int playingHcpValue,
    required double baseHcp,
    required int? limit,
    required bool isStableford,
    required Scorecard? userScorecard,
    required Scorecard? myCard,
    required Scorecard? partnerCard,
    required String? partnerName,
    required bool hasScoreConflict,
    required String? targetEntryId,
  }) {
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final currentUser = ref.watch(effectiveUserProvider);
    
    // [FIX] Harden targetId resolution against null currentUser or empty data
    final String targetId = (isSelfMarking || targetEntryId == null) 
        ? currentUser.id
        : targetEntryId;
    
    debugPrint(' [_buildMyScoreView] targetId resolved: $targetId');
    
    final allScorecards = ref.watch(scorecardsListProvider(event.id)).asData?.value ?? [];
    final targetCard = allScorecards.firstWhereOrNull((s) => s.entryId == targetId);
    debugPrint(' [_buildMyScoreView] targetCard found: ${targetCard != null}');
    
    // [NEW] Lift data resolution out of the widget tree to prevent IIFE related crashes
    final members = ref.watch(allMembersProvider).value ?? [];
    final manualTee = markerSelection.teeOverrides[targetId];
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: targetId, 
      event: event, 
      membersList: members, 
      manualTeeName: manualTee,
    );
    
    // Resolve the display name for the tee
    final memberProfile = members.firstWhereOrNull((m) => m.id == targetId);
    final String playerTeeName = manualTee ?? (
      (memberProfile?.gender?.toLowerCase() == 'female')
        ? (event.selectedFemaleTeeName ?? 'Red')
        : (event.selectedTeeName ?? 'Yellow')
    );

    // [FIX] Always look up seeded data as a baseline layer, even when a live scorecard exists.
    // This ensures scattered null holes in partial scorecards get filled.
    List<int>? seededScores;
    // Try exact match first, then try partial match for fourball composite IDs
    var seededResult = event.results.firstWhere(
       (r) => r['playerId'] == targetId,
       orElse: () => {},
    );
    // [FIX] If exact match fails, try finding results where the playerId contains the targetId  
    if (seededResult.isEmpty) {
       seededResult = event.results.firstWhere(
         (r) => (r['playerId'] as String?)?.contains(targetId) == true ||
                targetId.contains(r['playerId'] as String? ?? '___'),
         orElse: () => {},
       );
    }
    if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
       seededScores = List<int>.from(seededResult['holeScores']);
    }

    // Determine what to show on the Grid (CourseInfoCard)
    List<int?> gridScores = [];
    if (isSelfMarking) {
       gridScores = displayScores;
    } else {
       if (_selectedMarkerTab == MarkerTab.player) {
         // [FIX] 3-layer merge: live scorecard > seeded data > marker verifier
         final liveScores = targetCard?.holeScores ?? [];
         final myVerifier = myCard?.playerVerifierScores ?? [];
         
         gridScores = List.generate(18, (i) {
           final live = i < liveScores.length ? liveScores[i] : null;
           final seed = (seededScores != null && i < seededScores.length) ? seededScores[i] : null;
           final mine = i < myVerifier.length ? myVerifier[i] : null;
           return live ?? seed ?? mine;
         });
       } else {
         // Verifier tab: my verification > live scorecard > seeded data
         final myVerifier = myCard?.playerVerifierScores ?? [];
         final liveScores = targetCard?.holeScores ?? [];
         
         gridScores = List.generate(18, (i) {
           final v = i < myVerifier.length ? myVerifier[i] : null;
           final live = i < liveScores.length ? liveScores[i] : null;
           final seed = (seededScores != null && i < seededScores.length) ? seededScores[i] : null;
           return v ?? live ?? seed;
         });
       }
    }

    // Apply Optimistic Updates to Grid
    if (_optimisticScores != null && _optimisticIsVerifier == (_selectedMarkerTab == MarkerTab.verifier)) {
      gridScores = List.generate(18, (i) {
        return _optimisticScores![i + 1] ?? (i < gridScores.length ? gridScores[i] : null);
      });
    }

    // [FEATURE] Compute Match Play Tokens row if event is Match Play
    List<String>? matchTokens;
    final matchDataAsync = ref.watch(currentMatchControllerProvider(event.id));
    final matchData = matchDataAsync.asData?.value;
    
    if (matchData != null) {
      final currentMatch = matchData.match;
      final matchResult = matchData.result;
      
      final cleanId = targetId.replaceFirst('_guest', '');
      final isTeam1 = currentMatch.team1Ids.contains(targetId) || currentMatch.team1Ids.contains(cleanId);
      
      matchTokens = List.generate(18, (i) {
         if (i >= matchResult.holeResults.length) return '';
         final r = matchResult.holeResults[i];
         if (r == 0) return 'H';
         if (r == 1) return isTeam1 ? 'W' : 'L';
         return isTeam1 ? 'L' : 'W';
      });
    }

    final isVerifierView = !isSelfMarking && _selectedMarkerTab == MarkerTab.verifier;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Marker Toggle (Left)
              GestureDetector(
                onTap: () => _showMarkerSelectionSheet(event, isScoringActive),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelfMarking ? Icons.person : Icons.supervisor_account, 
                        size: AppShapes.iconXs, 
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
                          fontSize: AppTypography.sizeLabel,
                          fontWeight: AppTypography.weightBold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.arrow_drop_down, size: AppShapes.iconSm, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              // 2. Handicap Info (Right)
              Row(
                children: [
                  Text(
                    'HC: ${_formatHcp(baseHcp)}', 
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: AppTypography.weightBlack,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: AppSpacing.xs, 
                    height: AppSpacing.xs, 
                    decoration: BoxDecoration(
                      color: AppColors.dark300, 
                      shape: BoxShape.circle
                    )
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'PHC: $playingHcpValue', 
                    style: AppTypography.caption.copyWith(
                      color: AppColors.lime500,
                      fontWeight: AppTypography.weightBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Status Badge / Conflict Banner moved above

        if (partnerCard != null && !hasScoreConflict)
           Padding(
             padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
             child: Container(
               padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.teamA.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.md,
                  border: Border.all(color: AppColors.teamA.withValues(alpha: AppColors.opacityMuted)),
                ),
               child: Row(
                 children: [
                   const Icon(Icons.info_outline, color: AppColors.teamA),
                   const SizedBox(width: AppSpacing.md),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Partner Scoring Active',
                           style: TextStyle(
                             fontSize: AppTypography.sizeLabel,
                             fontWeight: AppTypography.weightBold,
                             color: AppColors.teamA,
                           ),
                         ),
                         Text(
                           '${partnerName ?? 'Teammate'} is keeping score.',
                           style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.teamA),
                         ),
                       ],
                     ),
                   ),
                   TextButton(
                     onPressed: () => _copyScoresFromPartner(partnerCard),
                     style: TextButton.styleFrom(
                       visualDensity: VisualDensity.compact,
                       foregroundColor: AppColors.teamA,
                       textStyle: const TextStyle(fontWeight: AppTypography.weightBold),
                     ),
                     child: const Text('SYNC TO ME'),
                   ),
                 ],
               ),
             ),
           ),

         if (hasScoreConflict)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.md,
                  border: Border.all(color: AppColors.amber500.withValues(alpha: AppColors.opacityHalf)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Score Conflict Detected',
                            style: TextStyle(
                              fontSize: AppTypography.sizeLabel,
                              fontWeight: AppTypography.weightBold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          Text(
                            'You and ${partnerName ?? 'Partner'} have different scores.',
                            style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.amber500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

        if (shouldShowCard) ...[
          CourseInfoCard(
            courseConfig: playerTeeConfig,
            selectedTeeName: playerTeeName,
            distanceUnit: config.distanceUnit,
            isStableford: isStableford,
            playerHandicap: playingHcpValue,
            scores: gridScores,
            headerColor: isVerifierView ? AppColors.amber500.withValues(alpha: AppColors.opacityMuted) : null,
            format: comp?.rules.format ?? CompetitionFormat.stableford, 
            maxScoreConfig: comp?.rules.maxScoreConfig,
            holeLimit: limit,
            matchPlayResults: matchTokens, 
          ),
          
          const SizedBox(height: AppSpacing.lg),

          HoleByHoleScoringWidget(
            event: event,
            targetScorecard: userScorecard,
            verifierScorecard: myCard,
            targetEntryId: targetId,
            isSelfMarking: isSelfMarking,
            selectedTab: _selectedMarkerTab, // Lifted State
            onTabChanged: (tab) {
              setState(() {
                 _selectedMarkerTab = tab;
                 _optimisticScores = null; // Clear stale optimistic data on tab switch
              });
            },
            onScoresChanged: _onScoresChanged,
          ),
        ],
        
        const SizedBox(height: AppSpacing.x2l),
        
        if (!shouldShowCard)
           _buildInactiveBanner(event),
      ],
    );
  }

  Widget _buildInactiveBanner(GolfEvent event) {
    return BoxyArtCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          children: [
            const Icon(Icons.lock_clock_outlined, size: AppShapes.iconHero, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'GAME NOT ACTIVE',
              style: TextStyle(fontSize: AppTypography.sizeLargeBody, fontWeight: AppTypography.weightBold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Scoring will open on ${DateFormat('EEEE, d MMMM').format(event.date)}.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                fontWeight: AppTypography.weightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Color _getStatusColor(ScorecardStatus status) {
    switch (status) {
      case ScorecardStatus.draft:
        return AppColors.dark300;
      case ScorecardStatus.submitted:
        return AppColors.amber500;
      case ScorecardStatus.reviewed:
      case ScorecardStatus.finalScore:
        return AppColors.lime500;
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
    // final statusOverride = ref.read(eventStatusOverrideProvider);
    // final forceActiveOverride = ref.read(scoringForceActiveOverrideProvider);
    // final isTesting = statusOverride != null || forceActiveOverride != null;

    // [Refinement] Allow sheet to open even if game is complete (for Read-Only review)
    // if (!isScoringActive && !isTesting) {
    //   return;
    // }

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
    if (groupMembers.isEmpty) {
       // Do nothing - user sees only "Myself"
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: false, 
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final markerSelection = ref.watch(markerSelectionProvider);
            final bool isSelfMarking = markerSelection.isSelfMarking;
            final String? targetEntryId = markerSelection.targetEntryId;

            // Get available tees
            final tees = event.courseConfig.tees;

            return Container(
              padding: const EdgeInsets.only(bottom: AppSpacing.x2l), 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Handle
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: AppSpacing.x4l, 
                      height: AppSpacing.xs, 
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMuted),
                        borderRadius: AppShapes.grabber
                      )
                    ),
                    const SizedBox(height: AppSpacing.x2l),
                    Text(
                      'Marker & Tee Selection',
                      style: AppTypography.displayHeading.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: AppTypography.weightBlack,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(Icons.person_search_outlined, size: AppShapes.iconSm, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'SELECT PLAYER TO MARK',
                            style: AppTypography.label.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: AppTypography.weightBlack,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Option 1: Myself
                    buildSelectionRow(
                      context, 
                      ref,
                      isSelected: isSelfMarking,
                      name: 'Myself (Me)',
                      entryId: currentUser.id,
                      tees: tees,
                      overrides: markerSelection.teeOverrides,
                      onSelect: () {
                        ref.read(markerSelectionProvider.notifier).selectSelf();
                        // Instead of immediate setState, let the Notifier propagate
                        setState(() { _selectedMarkerTab = MarkerTab.verifier; });
                      },
                      defaultTeeName: event.selectedTeeName ?? 'White',
                    ),
                    
                    // Option 2: Group Members
                    ...groupPlayersRaw.where((p) {
                       final pid = p['id'] ?? p['registrationMemberId'];
                       final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                       return id != currentUser.id;
                    }).map((p) {
                       final pid = p['id'] ?? p['registrationMemberId'];
                       final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                       final name = p['name'] ?? 'Unknown';
                       final isSelected = !isSelfMarking && targetEntryId == id;
                        
                       return buildSelectionRow(
                         context,
                         ref,
                         isSelected: isSelected,
                         name: name,
                         entryId: id ?? '',
                         tees: tees,
                         overrides: markerSelection.teeOverrides,
                         onSelect: () {
                           if (id != null) {
                             ref.read(markerSelectionProvider.notifier).selectTarget(id);
                           }
                         },
                         defaultTeeName: event.selectedTeeName ?? 'White',
                       );
                    }),

                    const SizedBox(height: AppSpacing.x3l),
                    
                    // Tip logic
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityLow),
                          borderRadius: AppShapes.md,
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityMedium)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline, size: AppShapes.iconSm, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Tee overrides update the scorecard immediately for that player.',
                                style: AppTypography.caption.copyWith(
                                  fontSize: AppTypography.sizeCaption, 
                                  fontWeight: AppTypography.weightBlack, 
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
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
             const SnackBar(content: Text('Scorecard Submitted Successfully!'), backgroundColor: AppColors.lime500),
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
  Future<void> _copyScoresFromPartner(Scorecard partnerCard) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sync Scores?'),
        content: const Text(
          'This will copy all scores from your partner to your scorecard. Any existing scores on your card will be overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sync'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(scorecardRepositoryProvider);
        final currentUser = ref.read(effectiveUserProvider);
        
        // precise target depends on if self-marking or not, but usually this button appears on "My Score" tab implying my card
        // We need to find MY card.
        final myCard = ref.read(scorecardsListProvider(widget.eventId)).asData?.value
            .firstWhereOrNull((s) => s.entryId == currentUser.id);

        if (myCard == null) {
           // Create new card with partner's scores
           final newCard = Scorecard(
              id: '', 
              competitionId: widget.eventId,
              roundId: 'round_1',
              entryId: currentUser.id,
              submittedByUserId: currentUser.id,
              holeScores: List.from(partnerCard.holeScores),
              status: ScorecardStatus.draft,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
           );
           await repo.addScorecard(newCard);
        } else {
           // Update existing
           final updated = myCard.copyWith(
              holeScores: List.from(partnerCard.holeScores),
              updatedAt: DateTime.now(),
           );
           await repo.updateScorecard(updated);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scores synced successfully!'), backgroundColor: AppColors.lime500),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error syncing scores: $e')),
          );
        }
      }
    }
  }

  // Resolution logic removed. Using ScoringCalculator.resolvePlayerCourseConfig instead.

  Widget buildSelectionRow(
    BuildContext context, 
    WidgetRef ref, {
    required bool isSelected,
    required String name,
    required String entryId,
    required List<dynamic> tees,
    required Map<String, String> overrides,
    required VoidCallback onSelect,
    required String defaultTeeName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left Col (Player)
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: onSelect,
                  borderRadius: AppShapes.md,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppSpacing.xl,
                          height: AppSpacing.xl,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onSurface 
                                  : AppColors.dark400,
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: isSelected 
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              fontSize: AppTypography.sizeBodySmall,
                              fontWeight: isSelected ? AppTypography.weightBlack : AppTypography.weightSemibold,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onSurface 
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Right Col (Tee Dropdown)
              Expanded(
                flex: 1,
                child: buildTeeDropdown(context, ref, entryId, tees, overrides, defaultTeeName),
              ),
            ],
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
        ],
      ),
    );
  }

  Widget buildTeeDropdown(BuildContext context, WidgetRef ref, String entryId, List<dynamic> tees, Map<String, String> overrides, String defaultTeeName) {
     final String? persistedTee = overrides[entryId];
     
     // The current selection could be null (Auto) or a specific tee name.
     // If the persisted tee matches the default tee, map it to null (Auto)
     // because the default tee is intentionally excluded from the manual list.
     String? currentTeeValue = persistedTee;
     if (currentTeeValue != null && currentTeeValue.toLowerCase().trim() == defaultTeeName.toLowerCase().trim()) {
       currentTeeValue = null;
     }
     
     return Container(
       height: 36,
       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
       decoration: BoxDecoration(
         color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacityMuted),
         borderRadius: AppShapes.sm,
         border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityMedium)),
       ),
       child: DropdownButtonHideUnderline(
         child: DropdownButton<String?>(
           value: currentTeeValue,
           isExpanded: true,
           icon: const Icon(Icons.arrow_drop_down, size: AppShapes.iconMd),
           onChanged: (String? newValue) {
             if (newValue == null) {
               ref.read(markerSelectionProvider.notifier).clearManualTee(entryId);
             } else {
               ref.read(markerSelectionProvider.notifier).setManualTee(entryId, newValue);
             }
           },
           items: [
             // "Auto" (Default) Option
             DropdownMenuItem<String?>(
               value: null,
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Container(
                     width: AppSpacing.sm, height: AppSpacing.sm,
                     decoration: BoxDecoration(
                       color: _parseTeeColor(defaultTeeName),
                       shape: BoxShape.circle,
                     ),
                   ),
                   const SizedBox(width: AppSpacing.sm),
                   Expanded(
                     child: Text(
                       defaultTeeName,
                       overflow: TextOverflow.ellipsis,
                       style: AppTypography.caption.copyWith(
                         fontSize: AppTypography.sizeLabelStrong, 
                         fontWeight: AppTypography.weightBlack,
                         color: Theme.of(context).colorScheme.onSurface,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             // List of available tees
             ...tees.where((t) {
               final name = t['name']?.toString() ?? 'Tee';
               return name.toLowerCase().trim() != defaultTeeName.toLowerCase().trim();
             }).map((t) {
               final name = t['name']?.toString() ?? 'Tee';
               return DropdownMenuItem<String?>(
                 value: name,
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Container(
                       width: AppSpacing.sm, height: AppSpacing.sm,
                       decoration: BoxDecoration(
                         color: _parseTeeColor(name),
                         shape: BoxShape.circle,
                       ),
                     ),
                     const SizedBox(width: AppSpacing.sm),
                     Expanded(
                       child: Text(
                         name,
                         overflow: TextOverflow.ellipsis,
                         style: AppTypography.caption.copyWith(
                           fontSize: AppTypography.sizeLabelStrong, 
                           fontWeight: AppTypography.weightBlack,
                           color: Theme.of(context).colorScheme.onSurface,
                         ),
                       ),
                     ),
                   ],
                 ),
               );
             }),
           ],
         ),
       ),
     );
  }

  Color _parseTeeColor(String teeName) {
    final name = teeName.toLowerCase();
    if (name.contains('white')) return AppColors.pureWhite;
    if (name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('red')) return const Color(0xFFFF4D4D);
    if (name.contains('blue')) return const Color(0xFF1E90FF);
    if (name.contains('black')) return const Color(0xFF2F2F2F);
    if (name.contains('green')) return const Color(0xFF2ECC71);
    if (name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('silver')) return const Color(0xFFC0C0C0);
    if (name.contains('orange')) return AppColors.amber500;
    if (name.contains('purple')) return AppColors.teamB;
    return AppColors.dark600;
  }
} // End of _EventScoresUserTabState

class EventStatsUserTab extends ConsumerWidget {
  final String eventId;
  const EventStatsUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const Scaffold(body: Center(child: Text('Event not found')));
        }
        return HeadlessScaffold(
          title: event.title,
          subtitleWidget: Text(
            'Advanced Stats',
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.weightBlack,
            ),
          ),
          showBack: true,
          onBack: () => context.go('/events'),
          actions: const [],
          slivers: [
            SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) => scorecardsAsync.when(
                  data: (scorecards) => Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.pageBottom),
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

    final tabs = <ModernFilterTab<int>>[
      const ModernFilterTab(label: 'My Score', value: 0),
      const ModernFilterTab(label: 'Group', value: 1),
      const ModernFilterTab(label: 'Leaderboard', value: 2),
    ];

    if (event.matches.isNotEmpty) {
      tabs.add(const ModernFilterTab(label: 'Matches', value: 4));
    }
    if (event.matches.any((m) => m.bracketId != null)) {
      tabs.add(const ModernFilterTab(label: 'Bracket', value: 5));
    }

    return ModernUnderlinedFilterBar<int>(
      selectedValue: selectedTab,
      isExpanded: true,
      onTabSelected: (val) => ref.read(eventDetailsTabProvider.notifier).set(val),
      tabs: tabs,
    );
  }
}
