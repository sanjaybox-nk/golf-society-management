import 'package:golf_society/domain/models/course_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../../../members/presentation/profile_provider.dart';
import '../widgets/rich_stats/rich_stats.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import 'package:collection/collection.dart';
import '../../logic/event_scoring_controller.dart';
import '../../domain/models/processed_event_data.dart';
import '../events_provider.dart';
import '../widgets/scorecard_modal.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../../../../domain/grouping/tee_group.dart';

// Providers moved from user_placeholders if they were local or needed here
// Use richStatsModeProvider from debug_providers.dart

class EventStatsTab extends ConsumerWidget {
  final String eventId;
  final bool isAdmin;

  const EventStatsTab({
    super.key,
    required this.eventId,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    
    return eventAsync.when(
      data: (event) {
        final comp = compAsync.value;
        return _EventStatsContent(
          event: event,
          comp: comp,
          isAdmin: isAdmin,
        );
      },
      loading: () => HeadlessScaffold(
        title: 'Event Stats',
        subtitle: 'Loading Analysis...',
        showBack: true,
        onBack: () => context.go('/events'),
        slivers: const [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (err, stack) => HeadlessScaffold(
        title: 'Event Stats',
        subtitle: 'Analysis Error',
        showBack: true,
        onBack: () => context.go('/events'),
        slivers: [
          SliverFillRemaining(
            child: BoxyArtEmptyState(
              title: 'Could not load statistics',
              message: err.toString(),
              icon: Icons.error_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventStatsContent extends ConsumerWidget {
  final GolfEvent event;
  final Competition? comp;
  final bool isAdmin;

  const _EventStatsContent({
    required this.event,
    this.comp,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final data = ref.watch(eventScoringControllerProvider(event.id));
    final allScorecards = ref.watch(scorecardsListProvider(event.id)).asData?.value ?? [];

    final effectiveUser = ref.watch(effectiveUserProvider);
    final currentUserId = effectiveUser.id;
    
    const statsMode = 0; 
    final currentFormat = comp?.rules.format ?? CompetitionFormat.stableford;
    final isStableford = currentFormat == CompetitionFormat.stableford;

    // Use the authoritative individual score for personal recap
    final myScoreEntry = data.individualScores.firstWhereOrNull(
      (s) => s.playerId.replaceFirst('_guest', '') == currentUserId
    );

    final statsReleased = event.isStatsReleased == true || isAdmin || event.status == EventStatus.completed;
    
    // Simplified ready check
    final bool isDataReady = data.individualScores.any((p) => p.result.holesPlayed > 0) || data.eventStats.isNotEmpty;
    
    if (!isDataReady || (!isAdmin && !statsReleased)) {
      return BoxyArtCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics_outlined, size: AppShapes.iconHero, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Stats will be available after scoring starts.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.dark900),
              ),
            ],
          ),
        ),
      );
    }

    final fs = data.eventStats;
    final holes = event.courseConfig.holes;
    final totalPlayers = data.individualScores.length;

    // --- Extracted Stats from Central Brain ---
    Map<int, double> holeAverages = {};
    int fieldEagles = 0;
    int fieldBirdies = 0;
    int fieldPars = 0;
    int fieldBogeys = 0;
    int fieldDoubleBogeys = 0;
    int fieldBlobs = 0;
    List<int?> eclecticRound = List.generate(18, (_) => null);
    Map<String, int> stablefordBuckets = {'<20': 0, '20-25': 0, '26-30': 0, '31-35': 0, '36+': 0};
    double front9AvgVal = 0;
    double back9AvgVal = 0;
    Map<int, double> parTypeAverages = {};
    int maxStreak = 0;
    String hotStreakPlayer = 'None';
    int maxBounceBacks = 0;
    String bounceBackPlayer = 'None';
    int bestFinishScore = isStableford ? -1 : 999;
    String finisherPlayer = 'None';
    String blobKingPlayer = 'None';
    int maxBlobs = 0;
    String grinderPlayer = 'None';
    int maxParsPlayer = 0;
    String sniperPlayer = 'None';
    int maxBirdsPlayer = 0;
    double maxVariance = 0;
    String rollercoasterPlayer = 'None';
    double fieldAvgVar = 0;
    double fieldAvgNetScore = 0;
    double fieldAvgBB = 0;
    double maxDiff = 0;
    int toughestIdx = 0;
    String toughestName = 'Hole 1';
    
    String hotStreakId = '';
    String bounceBackId = '';
    String finisherId = '';
    String blobKingId = '';
    String grinderId = '';
    String sniperId = '';
    String rollercoasterId = '';

    if (fs.isNotEmpty) {
      final dist = fs['scoringDistribution'] as Map?;
      fieldEagles = dist?['EAGLE'] ?? 0;
      fieldBirdies = dist?['BIRDIE'] ?? 0;
      fieldPars = dist?['PAR'] ?? 0;
      fieldBogeys = dist?['BOGEY'] ?? 0;
      fieldDoubleBogeys = dist?['DBL BOGEY'] ?? 0;
      fieldBlobs = dist?['BLOB'] ?? 0;

      final trends = fs['performanceTrends'] as Map?;
      front9AvgVal = (trends?['front9Avg'] as num?)?.toDouble() ?? 0;
      back9AvgVal = (trends?['back9Avg'] as num?)?.toDouble() ?? 0;
      if (trends?['stablefordBuckets'] != null) {
        stablefordBuckets = Map<String, int>.from(trends!['stablefordBuckets']);
      }
      if (trends?['parTypeAverages'] != null) {
        parTypeAverages = Map<int, double>.from(
          (trends!['parTypeAverages'] as Map).map((k, v) => MapEntry(int.parse(k.toString()), (v as num).toDouble()))
        );
      }
      fieldAvgNetScore = (trends?['fieldAvgNetScore'] as num?)?.toDouble() ?? 0;
      fieldAvgVar = (trends?['fieldAvgVar'] as num?)?.toDouble() ?? 0;
      fieldAvgBB = (trends?['fieldAvgBB'] as num?)?.toDouble() ?? 0;

      final heatmap = fs['difficultyHeatmap'] as Map?;
      heatmap?.forEach((k, v) { holeAverages[int.parse(k)] = (v as num).toDouble(); });

      final hof = fs['hallOfFame'] as List?;
      if (hof != null) {
        for (var award in hof) {
          final type = award['type'];
          final displayVal = award['displayValue'];
          final name = award['playerName'] ?? 'Unknown';
          final pid = (award['playerId'] ?? '').toString();
          
          if (type == 'HOT_STREAK') { 
            hotStreakPlayer = name; 
            maxStreak = (displayVal as num?)?.toInt() ?? 1; 
            hotStreakId = pid;
          }
          else if (type == 'BOUNCE_BACK') { 
            bounceBackPlayer = name; 
            maxBounceBacks = (displayVal as num?)?.toInt() ?? 1; 
            bounceBackId = pid;
          }
          else if (type == 'TOP_FINISHER') { 
            finisherPlayer = name; 
            bestFinishScore = (displayVal as num?)?.toInt() ?? (isStableford ? 6 : 12);
            finisherId = pid;
          }
          else if (type == 'BLOB_KING' || type == 'DISASTER_MASTER') { 
            blobKingPlayer = name; 
            maxBlobs = (displayVal as num?)?.toInt() ?? 1; 
            blobKingId = pid;
          }
          else if (type == 'CONSISTENT') { 
            grinderPlayer = name; 
            maxParsPlayer = (displayVal as num?)?.toInt() ?? 1; 
            grinderId = pid;
          }
          else if (type == 'SNIPER') { 
            sniperPlayer = name; 
            maxBirdsPlayer = (displayVal as num?)?.toInt() ?? 1; 
            sniperId = pid;
          }
          else if (type == 'ROLLERCOASTER') { 
            rollercoasterPlayer = name; 
            maxVariance = (displayVal as num?)?.toDouble() ?? 5.0; 
            rollercoasterId = pid;
          }
        }
      }

      final insights = fs['courseInsights'] as Map?;
      toughestIdx = (insights?['toughestHole'] as num?)?.toInt() ?? 0;
      maxDiff = (insights?['toughestRel'] as num?)?.toDouble() ?? 0;
      if (insights?['eclecticRound'] != null) {
        eclecticRound = List<int?>.from(insights!['eclecticRound']);
      }
    }
    toughestName = 'Hole ${toughestIdx + 1}';

    final Map<String, String> awardWinNames = {
      'HOT STREAK': hotStreakPlayer, 
      'BOUNCE BACK': bounceBackPlayer, 
      'TOP FINISHER': finisherPlayer,
      'THE BLOB KING': blobKingPlayer, 
      'THE GRINDER': grinderPlayer, 
      'THE SNIPER': sniperPlayer,
      'THE ROLLERCOASTER': rollercoasterPlayer,
    };


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (statsMode == 0) ...[
          const BoxyArtSectionTitle(
            horizontalPadding: 0,
            title: 'Society Hero Recap',
            topPadding: 0,
          ),
          StaggeredEntrance(
            index: 0,
            child: SocietyHeroRecapCard(
              eclecticScores: eclecticRound, 
              holes: holes,
              totalPlayers: totalPlayers, 
              totalHolesPlayed: totalPlayers * holes.length, 
              topHoleName: toughestName, 
              topHoleDiff: maxDiff,
              totalBirdies: fieldBirdies,
              totalEagles: fieldEagles,
              fieldAvgNet: fieldAvgNetScore,
            ),
          ),

          // [NEW] Group Results Podium moved from scoring hub
          if (data.groupRankings.isNotEmpty && (comp?.rules.isMatchPlay != true)) ...[
          const BoxyArtSectionTitle(
            followsCard: true,
            horizontalPadding: 0,
            title: 'Top Performing Groups',
          ),
             Builder(builder: (context) {
                final List<PodiumEntry> podiumEntries = [];
                final groupsData = event.grouping['groups'] as List?;
                final List<TeeGroup> groups = groupsData != null 
                    ? groupsData.map((g) => TeeGroup.fromJson(g)).toList() 
                    : [];

                for (int i=0; i<3 && i<data.groupRankings.length; i++) {
                   final gRes = data.groupRankings[i];
                   final group = groups.firstWhereOrNull((g) => g.index == gRes.groupIndex);
                   if (group == null) continue;

                   String? tieLabel;
                   final bool isTied = (i > 0 && data.groupRankings[i].totalScore == data.groupRankings[i-1].totalScore) || 
                                       (i < data.groupRankings.length - 1 && data.groupRankings[i].totalScore == data.groupRankings[i+1].totalScore);
                   if (isTied) {
                      final metrics = gRes.tieBreakMetrics;
                      final diffIdx = metrics.indexWhere((m) => m != 0);
                      if (diffIdx != -1) {
                         final mNames = ['B9', 'B6', 'B3', 'B1'];
                         final name = diffIdx < mNames.length ? mNames[diffIdx] : 'Metric';
                         tieLabel = '$name: ${metrics[diffIdx]}';
                      }
                   }

                   final int bestX = comp?.rules.teamBestXCount ?? 2;
                   final String formatLabel = 'Best $bestX';

                   podiumEntries.add(PodiumEntry(
                     name: 'Group ${group.index + 1}',
                     score: gRes.label,
                     rank: i + 1,
                     groupIndex: group.index,
                     tieBreakLabel: tieLabel,
                     formatLabel: formatLabel,
                   ));
                }
                
                return GroupingPodiumHeader(
                  entries: podiumEntries,
                  onTap: (idx) {
                    // Navigate back to scores tab and scroll to group? 
                    // For now, just show the podium.
                  },
                );
             }),
          ],

          const BoxyArtSectionTitle(
            followsCard: true,
            horizontalPadding: 0,
            title: 'Field Competitiveness',
          ),
          StaggeredEntrance(
            index: 2,
            child: ScoringTypeDistributionChart(counts: {
              'EAGLE': fieldEagles, 'BIRDIE': fieldBirdies, 'PAR': fieldPars, 'BOGEY': fieldBogeys, 'DBL BOGEY': fieldDoubleBogeys, 'BLOB': fieldBlobs,
            }),
          ),
          if (isStableford) ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
            StaggeredEntrance(
              index: 3,
              child: StablefordDistributionChart(bucketCounts: stablefordBuckets),
            ),
          ],
          if (allScorecards.any((s) => s.holeTags.isNotEmpty)) ...[
            const BoxyArtSectionTitle(
              followsCard: true,
              horizontalPadding: 0,
              title: 'Round Story',
            ),
            StaggeredEntrance(
              index: 3,
              child: RoundStoryStatsCard(scorecards: allScorecards),
            ),
          ],
          const BoxyArtSectionTitle(
            followsCard: true,
            horizontalPadding: 0,
            title: 'Performance Trends',
          ),
          StaggeredEntrance(
            index: 4,
            child: SplitPerformanceCard(front9Avg: front9AvgVal, back9Avg: back9AvgVal, isStableford: isStableford),
          ),
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
          StaggeredEntrance(
            index: 5,
            child: ParTypeBreakdown(parTypeAverages: parTypeAverages),
          ),
          const BoxyArtSectionTitle(
            followsCard: true,
            horizontalPadding: 0,
            title: 'Course Analysis',
          ),
          StaggeredEntrance(
            index: 6,
            child: DifficultyHeatmap(holeAverages: holeAverages, holes: holes),
          ),
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
          StaggeredEntrance(
            index: 7,
            child: HoleDifficultyChart(holeAverages: holeAverages, holes: holes),
          ),
          const BoxyArtSectionTitle(
            followsCard: true,
            horizontalPadding: 0,
            title: 'Hall of Fame',
          ),
          if (maxStreak > 0)
            StaggeredEntrance(
              index: 8,
              child: AchievementTile(
                title: 'HOT STREAK', 
                playerName: hotStreakPlayer, 
                value: '$maxStreak holes Par or better', 
                icon: Icons.local_fire_department, 
                color: AppColors.amber500,
                onTap: hotStreakId.isNotEmpty ? () => _showScorecard(context, ref, hotStreakId, data) : null,
              ),
            ),
          if (maxBounceBacks > 0) ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
            StaggeredEntrance(
              index: 9,
              child: AchievementTile(
                title: 'BOUNCE BACK', 
                playerName: bounceBackPlayer, 
                value: '$maxBounceBacks recoveries today', 
                icon: Icons.trending_up, 
                color: AppColors.teamA,
                onTap: bounceBackId.isNotEmpty ? () => _showScorecard(context, ref, bounceBackId, data) : null,
              ),
            ),
          ],
          if (finisherPlayer != 'None') ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
            StaggeredEntrance(
              index: 10,
              child: AchievementTile(
                title: 'TOP FINISHER', 
                playerName: finisherPlayer, 
                value: isStableford ? 'Rallied for $bestFinishScore points on final 3 holes' : 'Total $bestFinishScore on final 3 holes', 
                icon: Icons.flag, 
                color: AppColors.teamB,
                onTap: finisherId.isNotEmpty ? () => _showScorecard(context, ref, finisherId, data) : null,
              ),
            ),
          ],
          const BoxyArtSectionTitle(
            followsCard: true,
            horizontalPadding: 0,
            title: 'Banter & Bragging Rights',
          ),
          if (maxBlobs > 0)
            StaggeredEntrance(
              index: 11,
              child: AchievementTile(
                title: 'THE BLOB KING', 
                playerName: blobKingPlayer, 
                value: isStableford ? '$maxBlobs holes with zero points 💀' : '$maxBlobs holes with Triple Bogey+ 💀', 
                icon: Icons.sentiment_very_dissatisfied, 
                color: AppColors.coral500,
                onTap: blobKingId.isNotEmpty ? () => _showScorecard(context, ref, blobKingId, data) : null,
              ),
            ),
          if (maxParsPlayer > 0) ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
            StaggeredEntrance(
              index: 12,
              child: AchievementTile(
                title: 'THE GRINDER', 
                playerName: grinderPlayer, 
                value: 'Most consistent with $maxParsPlayer pars', 
                icon: Icons.shield, 
                color: AppColors.lime500,
                onTap: grinderId.isNotEmpty ? () => _showScorecard(context, ref, grinderId, data) : null,
              ),
            ),
          ],
          if (maxBirdsPlayer > 0) ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
            StaggeredEntrance(
              index: 13,
              child: AchievementTile(
                title: 'THE SNIPER', 
                playerName: sniperPlayer, 
                value: 'Picked off $maxBirdsPlayer birdies', 
                icon: Icons.gps_fixed, 
                color: Colors.blueGrey,
                onTap: sniperId.isNotEmpty ? () => _showScorecard(context, ref, sniperId, data) : null,
              ),
            ),
          ],
          if (maxVariance > 3.0) ...[
            SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
            StaggeredEntrance(
              index: 14,
              child: AchievementTile(
                title: 'THE ROLLERCOASTER', 
                playerName: rollercoasterPlayer, 
                value: 'Wildest round of the day 🎢', 
                icon: Icons.attractions, 
                color: AppColors.coral400,
                onTap: rollercoasterId.isNotEmpty ? () => _showScorecard(context, ref, rollercoasterId, data) : null,
              ),
            ),
          ],
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
          const StaggeredEntrance(
            index: 15,
            child: SocietyQuoteCard(),
          ),
        ] else ...[
          if (myScoreEntry == null)
            const BoxyArtCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.x2l),
                child: Center(child: Text('No personal scorecard found for this event.', style: TextStyle(color: AppColors.dark900))),
              ),
            )
          else
            _buildPersonalRecap(
              context: context, 
              myScoreEntry: myScoreEntry, 
              fieldHoleAvgs: holeAverages, 
              fieldParTypeAvgs: parTypeAverages, 
              courseConfig: event.courseConfig, 
              rules: comp?.rules,
              fieldAvgVariance: fieldAvgVar,
              fieldAvgNet: fieldAvgNetScore,
              fieldAvgBounceBackRate: fieldAvgBB,
              fieldToughestHoleIdx: toughestIdx,
              awardWinners: awardWinNames,
              registrations: event.registrations,
            ),
        ],
      ],
    );
  }

  void _showScorecard(BuildContext context, WidgetRef ref, String playerId, ProcessedEventData data) {
    final ple = data.leaderboard.firstWhereOrNull((e) => e.entryId == playerId);
    if (ple == null) return;

    final pps = data.individualScores.firstWhereOrNull((s) => s.playerId == playerId);
    final membersList = ref.read(allMembersProvider).value ?? [];

    final entry = LeaderboardEntry(
      entryId: ple.entryId,
      playerName: ple.playerName,
      score: ple.score,
      scoreLabel: ple.scoreLabel,
      handicap: 0,
      handicapIndex: ple.handicapIndex ?? 0.0,
      playingHandicap: ple.individualPlayingHandicaps.isNotEmpty ? ple.individualPlayingHandicaps.first : 0,
      holesPlayed: ple.holesPlayed,
      isGuest: ple.isGuest,
      teamMemberIds: ple.teamMemberIds,
      teamMemberNames: ple.teamMemberNames,
      holeScores: ple.holeScores,
      holeNetScores: ple.holeNetScores,
      holePoints: ple.holePoints,
      hasSocietyCut: ple.hasSocietyCut,
      position: ple.position,
      thruLabel: pps?.thruLabel,
      tieBreakLabel: ple.tieBreakLabel,
    );

    ScorecardModal.show(
      context,
      ref,
      entry: entry,
      scorecards: const [], // ScorecardModal will use holeScores from entry
      event: event,
      comp: comp,
      membersList: membersList,
    );
  }

  Widget _buildPersonalRecap({
    required BuildContext context, 
    required ProcessedPlayerScore myScoreEntry, 
    required Map<int, double> fieldHoleAvgs, 
    required Map<int, double> fieldParTypeAvgs, 
    required CourseConfig courseConfig, 
    required CompetitionRules? rules,
    required double fieldAvgVariance,
    required double fieldAvgNet,
    required double fieldAvgBounceBackRate,
    required int fieldToughestHoleIdx,
    required Map<String, String> awardWinners,
    required List<EventRegistration> registrations,
  }) {
    final holes = courseConfig.holes;
    final myName = myScoreEntry.playerName;

    Map<int, double> myParTypeSums = {3: 0, 4: 0, 5: 0};
    Map<int, int> myParTypeCounts = {3: 0, 4: 0, 5: 0};
    List<double> myDiffs = [];
    int myHardestIdx = 0;
    double myMaxDiff = -999;
    int myBounceBacks = 0;
    int myOpportunities = 0;

    for (int i = 0; i < 18; i++) {
        final score = myScoreEntry.holeScores.length > i ? myScoreEntry.holeScores[i] : null;
        if (score != null) {
            final par = holes.length > i ? holes[i].par : 4;
            final diff = (score - par).toDouble();
            myParTypeSums[par] = (myParTypeSums[par] ?? 0) + diff;
            myParTypeCounts[par] = (myParTypeCounts[par] ?? 0) + 1;
            myDiffs.add(diff);
            if (diff > myMaxDiff) { myMaxDiff = diff; myHardestIdx = i; }
            if (i > 0) {
              final prevScore = myScoreEntry.holeScores.length > i-1 ? myScoreEntry.holeScores[i-1] : null;
              if (prevScore != null) {
                final prevPar = holes.length > i-1 ? holes[i-1].par : 4;
                if (prevScore > prevPar) { myOpportunities++; if (score <= par) myBounceBacks++; }
              }
            }
        }
    }
    Map<int, double> myParTypeAverages = {};
    myParTypeSums.forEach((key, value) { if (myParTypeCounts[key]! > 0) myParTypeAverages[key] = value / myParTypeCounts[key]!; });

    double myVariance = 0;
    if (myDiffs.isNotEmpty && myDiffs.length > 5) {
      double mean = myDiffs.fold<num>(0, (a, b) => a + b).toDouble() / myDiffs.length;
      myVariance = myDiffs.map((d) => math.pow(d - mean, 2)).fold<double>(0.0, (a, b) => a + b) / myDiffs.length;
    }
    final myBounceBackRate = myOpportunities > 0 ? (myBounceBacks / myOpportunities) : 0.0;
    final grossScore = myScoreEntry.result.score; // Authoritative score
    final diff = HandicapCalculator.calculateDifferential(grossScore: grossScore, courseConfig: courseConfig);

    List<String> myAwards = [];
    awardWinners.forEach((title, winner) { if (winner == myName) myAwards.add(title); });

    final fieldHardestHoleDiff = fieldHoleAvgs[fieldToughestHoleIdx] != null ? fieldHoleAvgs[fieldToughestHoleIdx]! - holes[fieldToughestHoleIdx].par.toDouble() : 0.0;

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(
          title: 'Personal Performance',
          topPadding: 0,
        ),
        if (myAwards.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppGradients.brandPrimary(context),
              borderRadius: AppShapes.lg,
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.pureWhite, size: AppShapes.iconXl),
                const SizedBox(height: AppSpacing.sm),
                const Text('AWARD EARNED!', style: TextStyle(color: AppColors.pureWhite, fontWeight: AppTypography.weightSemibold, fontSize: AppTypography.sizeLabel, letterSpacing: 1.5)),
                const SizedBox(height: AppSpacing.xs),
                Text(myAwards.join(' & '), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.pureWhite, fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLargeBody)),
              ],
            ),
          ),
          SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
        ],
        PersonalBenchmarkingCard(myAverages: myParTypeAverages, fieldAverages: fieldParTypeAvgs),
        SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
        NetComparisonCard(myNet: myScoreEntry.result.score, fieldAvgNet: fieldAvgNet),
        SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
        ConsistencyStatCard(myVariance: myVariance, fieldAvgVariance: fieldAvgVariance),
        SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
        BounceBackStatCard(myRate: myBounceBackRate, fieldRate: fieldAvgBounceBackRate),
        SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
        HoleNemesisComparison(myHardestHoleIdx: myHardestIdx, myHardestHoleDiff: myMaxDiff, fieldHardestHoleIdx: fieldToughestHoleIdx, fieldHardestHoleDiff: fieldHardestHoleDiff),
        SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
        // Simplified heatmap use
        HoleComparisonHeatmap(myHoleScores: myScoreEntry.holeScores, fieldAverages: fieldHoleAvgs, holes: holes),
        SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
        AchievementTile(title: 'HANDICAP IMPACT', playerName: 'Round Rating', value: 'Net Differential: ${diff.toStringAsFixed(1)}', icon: Icons.analytics, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }

}
