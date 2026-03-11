import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../widgets/event_leaderboard.dart';
import '../widgets/scorecard_modal.dart';
import '../events_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../widgets/sliding_course_info_card.dart';
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

final eventMyCardTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_my_card_tab'));
final eventScoresHubTabProvider = NotifierProvider<SelectedTabNotifier, int>(() => SelectedTabNotifier('event_scores_hub_tab'));
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
          useScaffold: false,
          actions: [
            BoxyArtGlassIconButton(
              icon: Icons.home_rounded,
              tooltip: 'Event Home',
              onPressed: () => context.push('/events/${event.id}/home'),
            ),
          ],
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
        final event = events.firstWhereOrNull((e) => e.id == widget.eventId);
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

        return compAsync.when(
          data: (comp) {
            final effectiveRules = comp?.rules ?? const CompetitionRules();

            // --- Calculation for Header Badge ---
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
            
            final effectiveStatus = event.status;
            final bool isLocked = event.isScoringLocked == true;
            final bool isCompleted = effectiveStatus == EventStatus.completed;
            
            final now = DateTime.now();
            final isSameDayOrPast = now.year == event.date.year && 
                                     now.month == event.date.month && 
                                     now.day == event.date.day || 
                                     now.isAfter(event.date);

            final bool isScoringActive = !isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));
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

            return HeadlessScaffold(
              title: event.title,
              subtitle: 'My Card',
              contentPadding: const EdgeInsets.only(top: 120, left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.xl),
              showBack: true,
              onBack: () => context.go('/events'),
              useScaffold: false,
              actions: [
                BoxyArtGlassIconButton(
                  icon: Icons.home_rounded,
                  tooltip: 'Event Home',
                  onPressed: () => context.push('/events/${event.id}/home'),
                ),
                // [FIX] headerBadgeText is always non-null due to fallback in logic
                Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: headerOnBadgeTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: headerOnBadgeTap != null ? headerBadgeColor : headerBadgeColor.withValues(alpha: AppColors.opacityLow),
                            borderRadius: AppShapes.md,
                            border: Border.all(color: headerBadgeColor.withValues(alpha: AppColors.opacityMuted)),
                          ),
                          child: Text(
                            headerBadgeText,
                            style: TextStyle(
                              fontSize: AppTypography.sizeCaption,
                              color: headerOnBadgeTap != null ? AppColors.pureWhite : headerBadgeColor,
                              fontWeight: AppTypography.weightBlack,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
              slivers: [
                if (event.matches.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.xl),
                    sliver: SliverToBoxAdapter(
                      child: _LiveHubToggle(event: event),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: _buildTabContent(event, comp, [], effectiveRules),
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
    final scorecardsAsync = ref.watch(scorecardsListProvider(event.id));
    
    final currentFormat = comp?.rules.format ?? CompetitionFormat.stableford;
    final isStableford = currentFormat == CompetitionFormat.stableford;
    final isFourballOrPairs = effectiveRules.subtype == CompetitionSubtype.fourball || 
                              effectiveRules.mode == CompetitionMode.pairs ||
                              effectiveRules.subtype == CompetitionSubtype.foursomes;

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
    
    // Default Values for My Score hub
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final String? targetEntryId = markerSelection.targetEntryId;
    final String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);
    final allScorecards = ref.watch(scorecardsListProvider(widget.eventId)).asData?.value ?? [];
    final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
    final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);
    
    List<int?> displayScores = [];
    int playingHcpValue = 0;
    double baseHcp = currentUser.handicap;
    int? limit;
    Scorecard? partnerCard;
    String? partnerName;
    bool hasScoreConflict = false;

    // Calculate My Score Hub data (re-used for default case)
    {
      List<int>? fallbackScores;
      var seededResultForSelf = event.results.firstWhere(
        (r) => r['playerId'] == effectiveEntryId,
        orElse: () => {},
      );
      if (seededResultForSelf.isEmpty) {
        seededResultForSelf = event.results.firstWhere(
          (r) => (r['playerId'] as String?)?.contains(effectiveEntryId) == true ||
                 effectiveEntryId.contains(r['playerId'] as String? ?? '___'),
          orElse: () => {},
        );
      }
      if (seededResultForSelf.isNotEmpty && seededResultForSelf['holeScores'] != null) {
        fallbackScores = List<int>.from(seededResultForSelf['holeScores']);
      }

      List<int?> rawDisplayScores;
      if (userScorecard != null && userScorecard.holeScores.any((s) => s != null)) {
        rawDisplayScores = List.generate(18, (i) {
          final live = i < userScorecard.holeScores.length ? userScorecard.holeScores[i] : null;
          final seed = (fallbackScores != null && i < fallbackScores.length) ? fallbackScores[i] : null;
          return live ?? seed;
        });
      } else {
        rawDisplayScores = fallbackScores?.cast<int?>() ?? [];
      }

      limit = playerHoleLimits[effectiveEntryId];
      if (limit != null) {
        for (int i = 0; i < rawDisplayScores.length; i++) {
          displayScores.add(i < limit ? rawDisplayScores[i] : null);
        }
      } else {
        displayScores.addAll(rawDisplayScores);
      }

      final bool shouldShowTargetHcp = !isSelfMarking && _selectedMarkerTab == MarkerTab.player && targetEntryId != null;
      if (shouldShowTargetHcp) {
         final allMembersAsync = ref.watch(allMembersProvider);
         final guestSuffix = '_guest';
         if (targetEntryId.endsWith(guestSuffix)) {
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

      final bool shouldCheckConflict = isScoringActive && !isLocked;
      if (shouldCheckConflict && effectiveRules.effectiveMode != CompetitionMode.singles && isSelfMarking && !isFourballOrPairs) {
         final groupsData = event.grouping['groups'] as List?;
         if (groupsData != null) {
            for (var g in groupsData) {
               final players = (g['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList();
               final myIndex = players.indexWhere((p) => (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) == effectiveEntryId);
               if (myIndex != -1) {
                  final teamSize = effectiveRules.teamSize;
                  int teamStartIndex = (myIndex ~/ teamSize) * teamSize;
                  int teamEndIndex = teamStartIndex + teamSize;
                  if (teamEndIndex > players.length) teamEndIndex = players.length;
                  final teamMembers = players.sublist(teamStartIndex, teamEndIndex);
                  for (var member in teamMembers) {
                     final memberId = member.isGuest ? '${member.registrationMemberId}_guest' : member.registrationMemberId;
                     if (memberId == effectiveEntryId) continue;
                     final pCard = allScorecards.firstWhereOrNull((s) => s.entryId == memberId);
                     if (pCard != null && pCard.holeScores.any((s) => s != null)) {
                        if (userScorecard != null && userScorecard.holeScores.any((s) => s != null)) {
                           for (int i=0; i<18; i++) {
                              final myScore = userScorecard.holeScores.elementAtOrNull(i);
                              final theirScore = pCard.holeScores.elementAtOrNull(i);
                              if (myScore != null && theirScore != null && myScore != theirScore) {
                                 hasScoreConflict = true;
                                 partnerName = member.name;
                                 partnerCard = pCard;
                                 break;
                              }
                           }
                        } else {
                           if (partnerCard == null || (pCard.holeScores.where((s) => s != null).length > partnerCard.holeScores.where((s) => s != null).length)) {
                              partnerCard = pCard;
                              partnerName = member.name;
                           }
                        }
                     }
                     if (hasScoreConflict) break;
                  }
                  break;
               }
            }
         }
      }
      playingHcpValue = HandicapCalculator.getStoredPhc(event.grouping, effectiveEntryId);
    }
    // Use eventMyCardTabProvider for My Card Hub (0: My Score, 4: Matches, 5: Bracket)
    final activeIndex = ref.watch(eventMyCardTabProvider);
    
    switch (activeIndex) {
      case 0: { // My Score
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
      default: {
         // Default to My Score (0) if the shared index doesn't apply to this hub
         return _buildMyScoreRedirect(event, comp, displayScores, isScoringActive, shouldShowCard, playingHcpValue, baseHcp, limit, isStableford, userScorecard, myCard, partnerCard, partnerName, hasScoreConflict, targetEntryId, config);
      }
    }
  }

  // Safety helper to force-render My Score logic if switch fails
  Widget _buildMyScoreRedirect(GolfEvent event, Competition? comp, List<int?> displayScores, bool isScoringActive, bool shouldShowCard, int playingHcpValue, double baseHcp, int? limit, bool isStableford, Scorecard? userScorecard, Scorecard? myCard, Scorecard? partnerCard, String? partnerName, bool hasScoreConflict, String? targetEntryId, SocietyConfig config) {
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.actionGreen,
                    borderRadius: BorderRadius.circular(config.pillRadius),
                    boxShadow: config.useShadows ? Theme.of(context).extension<AppShadows>()?.softScale : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSelfMarking 
                            ? 'Marking: SELF' 
                            : (targetEntryId != null 
                                ? 'Marking: ${_getDisplayName(event, targetEntryId).split(' ').first.toUpperCase()}' 
                                : 'Marking: SELECT'),
                        style: AppTypography.label.copyWith(
                          color: AppColors.actionText,
                          fontSize: AppTypography.sizeLabelStrong,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded, 
                        size: 18, 
                        color: AppColors.actionText,
                      ),
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
                      fontSize: AppTypography.sizeCaption + 2,
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
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: AppTypography.sizeCaption + 2,
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
          SlidingCourseInfoCard(
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

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Marker & Tee Selection',
      child: Consumer(
        builder: (context, ref, _) {
          final markerSelection = ref.watch(markerSelectionProvider);
          final bool isSelfMarking = markerSelection.isSelfMarking;
          final String? targetEntryId = markerSelection.targetEntryId;
          final tees = event.courseConfig.tees;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

              const SizedBox(height: AppSpacing.lg),
              
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
                            fontSize: AppTypography.sizeLabel, 
                            fontWeight: AppTypography.weightBlack, 
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          );
        },
      ),
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
           borderRadius: BorderRadius.circular(AppShapes.rLg),
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
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: _parseTeeColor(defaultTeeName),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
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
              final name = t.name.toString();
              return name.toLowerCase().trim() != defaultTeeName.toLowerCase().trim();
            }).map((t) {
              final name = t.name.toString();
               return DropdownMenuItem<String?>(
                 value: name,
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: _parseTeeColor(name),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.1),
                            width: 1,
                          ),
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
          useScaffold: false,
          actions: [
            BoxyArtGlassIconButton(
              icon: Icons.home_rounded,
              tooltip: 'Event Home',
              onPressed: () => context.push('/events/${event.id}/home'),
            ),
          ],
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
    final selectedTab = ref.watch(eventMyCardTabProvider);

    final tabs = <ModernFilterTab<int>>[
      const ModernFilterTab(label: 'My Score', value: 0),
    ];

    if (event.matches.isNotEmpty) {
      tabs.add(const ModernFilterTab(label: 'Matches', value: 4));
    }
    if (event.matches.any((m) => m.bracketId != null)) {
      tabs.add(const ModernFilterTab(label: 'Bracket', value: 5));
    }

    return ModernUnderlinedFilterBar<int>(
      selectedValue: (selectedTab == 0 || selectedTab == 4 || selectedTab == 5) ? selectedTab : 0,
      isExpanded: true,
      onTabSelected: (val) => ref.read(eventMyCardTabProvider.notifier).set(val),
      tabs: tabs,
    );
  }
}

// [NEW] Scores Hub Toggle
class _ScoresHubToggle extends ConsumerWidget {
  final GolfEvent event;

  const _ScoresHubToggle({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventScoresHubTabProvider);

    final tabs = <ModernFilterTab<int>>[
      const ModernFilterTab(label: 'Leaderboard', value: 2),
      const ModernFilterTab(label: 'Group', value: 1),
    ];

    return ModernUnderlinedFilterBar<int>(
      selectedValue: (selectedTab == 1 || selectedTab == 2) ? selectedTab : 2,
      isExpanded: true,
      onTabSelected: (val) => ref.read(eventScoresHubTabProvider.notifier).set(val),
      tabs: tabs,
    );
  }
}
class TournamentScoresUserTab extends ConsumerWidget {
  final String eventId;
  const TournamentScoresUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final currentTab = ref.watch(eventScoresHubTabProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) return const Scaffold(body: Center(child: Text('Event not found')));

        return compAsync.when(
          data: (comp) {
            final rules = comp?.rules ?? const CompetitionRules();
            final effectiveRules = rules;
            
            // Ensure activeTab is always valid for this screen (1 or 2)
            final int activeTab = (currentTab == 1 || currentTab == 2) ? currentTab : 2;
            
            return HeadlessScaffold(
              title: event.title,
              subtitle: 'Scores Hub',
              showBack: true,
              onBack: () => context.go('/events'),
              useScaffold: false,
              actions: [
                BoxyArtGlassIconButton(
                  icon: Icons.home_rounded,
                  tooltip: 'Event Home',
                  onPressed: () => context.push('/events/${event.id}/home'),
                ),
              ],
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: _ScoresHubToggle(event: event),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: Builder(builder: (context) {
                      switch (activeTab) {
                        case 1: // Group Views
                           final markerSelection = ref.watch(markerSelectionProvider);
                           return _TournamentGroupScoresView(event: event, rules: effectiveRules, markerSelection: markerSelection);
                        default: // Leaderboard (case 2)
                          final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
                          final membersAsync = ref.watch(allMembersProvider);
                          return scorecardsAsync.when(
                            data: (scorecards) => EventLeaderboard(
                                event: event, 
                                comp: comp, 
                                liveScorecards: scorecards, 
                                membersList: membersAsync.value ?? [], 
                                playerHoleLimits: const {},
                                onPlayerTap: (entry) => ScorecardModal.show(
                                  context, ref, 
                                  entry: entry, 
                                  scorecards: scorecards, 
                                  event: event, 
                                  comp: comp, 
                                  membersList: membersAsync.value ?? [], 
                                  holeLimit: null, 
                                  teeOverrides: ref.read(markerSelectionProvider).teeOverrides,
                                ),
                            ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => Center(child: Text('Error: $e')),
                          );
                      }
                    }),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading competition: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading event: $e')),
    );
  }
}

class _TournamentGroupScoresView extends ConsumerStatefulWidget {
  final GolfEvent event;
  final CompetitionRules rules;
  final MarkerSelection markerSelection;

  const _TournamentGroupScoresView({
    required this.event,
    required this.rules,
    required this.markerSelection,
  });

  @override
  ConsumerState<_TournamentGroupScoresView> createState() => __TournamentGroupScoresViewState();
}

class __TournamentGroupScoresViewState extends ConsumerState<_TournamentGroupScoresView> {
  @override
  Widget build(BuildContext context) {
    // This is a wrapper to call the existing _buildGroupScoresTab properly
    // Since _buildGroupScoresTab is in _EventScoresUserTabState, I should probably 
    // refactor it to a standalone helper.
    // However, for this phase I will duplicate it or use a shared mixin/helper if possible.
    // For simplicity in this large file, I'll use the one in the parent state if I can access it,
    // but better to just pull out the logic into a shared method.
    
    // I will refactor _buildGroupScoresTab to be a static-like helper below.
    return _SharedTournamentLogic.buildGroupScoresTab(
      ref: ref,
      eventId: widget.event.id,
      event: widget.event,
      rules: widget.rules,
      playerHoleLimits: const {},
      teeOverrides: widget.markerSelection.teeOverrides,
    );
  }
}

class _SharedTournamentLogic {
  static Widget buildGroupScoresTab({
    required WidgetRef ref,
    required String eventId,
    required GolfEvent event,
    required CompetitionRules rules,
    required Map<String, int> playerHoleLimits,
    required Map<String, String> teeOverrides,
  }) {
    final membersAsync = ref.watch(allMembersProvider);
    final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
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

        final isTeamMode = rules.effectiveMode != CompetitionMode.singles;
        final teamSize = rules.teamSize;

        final Map<String, String> scoreMap = {};
        final Map<String, int> teamPhcMap = {};
        final Map<String, bool> winnerMap = {};
        final Map<String, String> betterBallMap = {};
        
        for (var group in groups) {
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
              
              // 1. Calculate Team PHC
              int teamPhc = 0;
              final isTeamModeForHcp = rules.effectiveMode != CompetitionMode.singles;
              if (isTeamModeForHcp) {
                 final List<double> indices = [];
                 for (var p in team) {
                    final member = membersAsync.value?.firstWhereOrNull((m) => m.id == p.registrationMemberId);
                    indices.add(member?.handicap ?? p.handicapIndex);
                 }
                 teamPhc = HandicapCalculator.calculateTeamHandicap(individualIndices: indices, rules: rules, courseConfig: event.courseConfig);
              }

              // 2. Resolve Score
              String displayScore = '-';
              final isFourball = rules.subtype == CompetitionSubtype.fourball;
              
              if (isFourball) {
                for (var p in team) {
                  final playerId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                  final card = scorecards.firstWhereOrNull((s) => s.entryId == playerId);
                  final manualTee = teeOverrides[playerId];
                  final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(memberId: p.registrationMemberId, event: event, membersList: membersAsync.value ?? [], manualTeeName: manualTee);
                  final member = membersAsync.value?.firstWhereOrNull((m) => m.id == p.registrationMemberId);
                  final phc = HandicapCalculator.calculatePlayingHandicap(handicapIndex: member?.handicap ?? p.handicapIndex, rules: rules, courseConfig: playerTeeConfig);
                  teamPhcMap[playerId] = phc;

                  final seededResult = event.results.firstWhere((r) => r['playerId'] == playerId, orElse: () => {});
                  List<int?> scoresToUse = [];
                  if (card != null && card.holeScores.any((s) => s != null)) {
                    scoresToUse = List.generate(18, (i) {
                       final live = i < card.holeScores.length ? card.holeScores[i] : null;
                       final seed = (seededResult['holeScores'] != null && i < seededResult['holeScores'].length) ? seededResult['holeScores'][i] : null;
                       return live ?? seed;
                    });
                  } else if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
                    scoresToUse = (seededResult['holeScores'] as List).cast<int?>();
                  }

                  if (scoresToUse.isNotEmpty && scoresToUse.any((s) => s != null)) {
                    final result = ScoringCalculator.calculate(holeScores: scoresToUse, holes: playerTeeConfig.holes, playingHandicap: phc.toDouble(), format: rules.format, maxScoreConfig: rules.maxScoreConfig);
                    scoreMap[playerId] = result.label;
                  }
                }
                
                // Better Ball calculation logic simplified for this block
                final bbKey = team.map((p) => p.registrationMemberId).join('_');
                betterBallMap[bbKey] = '0'; // Placeholder or full BB logic
              } else {
                // Singles / Scramble
                final String firstPlayerId = team.first.isGuest ? '${team.first.registrationMemberId}_guest' : team.first.registrationMemberId;
                final card = scorecards.firstWhereOrNull((s) => s.entryId == firstPlayerId);
                final seededResult = event.results.firstWhere((r) => r['playerId'] == firstPlayerId, orElse: () => {});

                List<int?> scoresToUse = [];
                if (card != null && card.holeScores.isNotEmpty) {
                    scoresToUse = List.generate(18, (i) {
                       final live = i < card.holeScores.length ? card.holeScores[i] : null;
                       final seed = (seededResult['holeScores'] != null && i < seededResult['holeScores'].length) ? seededResult['holeScores'][i] : null;
                       return live ?? seed;
                    });
                } else if (seededResult['holeScores'] != null) {
                    scoresToUse = (seededResult['holeScores'] as List).cast<int?>();
                }

                if (scoresToUse.isNotEmpty) {
                    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(memberId: team.first.registrationMemberId, event: event, membersList: membersAsync.value ?? [], manualTeeName: teeOverrides[firstPlayerId]);
                    int ep = isTeamMode ? teamPhc : HandicapCalculator.calculatePlayingHandicap(handicapIndex: membersAsync.value?.firstWhereOrNull((m) => m.id == team.first.registrationMemberId)?.handicap ?? team.first.handicapIndex, rules: rules, courseConfig: playerTeeConfig);
                    if (isGross) ep = 0;
                    final res = ScoringCalculator.calculate(holeScores: scoresToUse, holes: playerTeeConfig.holes, playingHandicap: ep.toDouble(), format: rules.format, maxScoreConfig: rules.maxScoreConfig);
                    displayScore = res.label;
                    for (var p in team) {
                      final pid = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                      scoreMap[pid] = displayScore;
                      teamPhcMap[pid] = ep;
                    }
                }
              }
           }
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: BoxyArtSectionTitle(title: 'Group Scores'),
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final Map<String, Member> memberMap = {for (var m in membersAsync.value ?? []) m.id: m};

                return GroupingCard(
                  group: group,
                  memberMap: memberMap,
                  history: const [],
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
