import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../models/golf_event.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/competition.dart';
import '../../../../models/event_registration.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../widgets/rich_stats_widgets.dart';
import '../../../../core/utils/handicap_calculator.dart';
import '../../../debug/presentation/state/debug_providers.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../logic/event_analysis_engine.dart';

// Providers moved from user_placeholders if they were local or needed here
// Use richStatsModeProvider from debug_providers.dart

class EventStatsTab extends ConsumerWidget {
  final GolfEvent event;
  final Competition? comp;
  final List<Scorecard> liveScorecards;
  final bool isAdmin;
  final Map<String, int> playerHoleLimits;

  const EventStatsTab({
    super.key,
    required this.event,
    this.comp,
    required this.liveScorecards,
    this.isAdmin = false,
    this.playerHoleLimits = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Scorecard> scorecards = liveScorecards;

    final effectiveUser = ref.watch(effectiveUserProvider);
    final currentUserId = effectiveUser.id;
    
    // [Lab Mode/Admin Restriction]
    // Admins always see Society Stats (mode 0) and cannot toggle
    final statsMode = isAdmin ? 0 : ref.watch(richStatsModeProvider);
    final formatOverride = ref.watch(gameFormatOverrideProvider);
    final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
    final isStableford = currentFormat == CompetitionFormat.stableford;

    final myScorecard = scorecards.where((s) => s.entryId.replaceFirst('_guest', '') == currentUserId).firstOrNull;

    // Use finalized stats if available
    final hasFinalizedStats = event.finalizedStats.isNotEmpty;

    final showStatsOverride = ref.watch(isStatsReleasedOverrideProvider) == true;
    final statsReleased = event.isStatsReleased == true || showStatsOverride || isAdmin;

    // Check if scoring has even started
    final bool hasAnyData = scorecards.isNotEmpty || hasFinalizedStats;
    
    if (!hasAnyData || (!isAdmin && !statsReleased)) {
      return const BoxyArtFloatingCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('Stats will be available after scoring starts.', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    final holes = event.courseConfig['holes'] as List? ?? [];
    final totalPlayers = scorecards.length;

    // --- Stats Calculation (Same logic as before, just in build for now) ---
    Map<int, double> holeAverages = {};
    int fieldEagles = 0;
    int fieldBirdies = 0;
    int fieldPars = 0;
    int fieldBogeys = 0;
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

    final fs = hasFinalizedStats 
        ? event.finalizedStats 
        : EventAnalysisEngine.calculateFinalStats(
            scorecards: scorecards,
            event: event,
            competition: comp,
            isStableford: isStableford,
          );

    if (fs.isNotEmpty) {
      final dist = fs['scoringDistribution'] as Map?;
      fieldEagles = dist?['EAGLE'] ?? 0;
      fieldBirdies = dist?['BIRDIE'] ?? 0;
      fieldPars = dist?['PAR'] ?? 0;
      fieldBogeys = dist?['BOGEY'] ?? 0;
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
          final playerId = award['playerId'];
          final reg = event.registrations.firstWhere((r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == playerId, orElse: () => EventRegistration(memberId: '', memberName: 'Unknown', attendingGolf: true));
          final name = reg.isGuest ? (reg.guestName ?? 'Guest') : reg.memberName;
          if (type == 'HOT_STREAK') { hotStreakPlayer = name; maxStreak = 1; }
          else if (type == 'BOUNCE_BACK') { bounceBackPlayer = name; maxBounceBacks = 1; }
          else if (type == 'TOP_FINISHER') { finisherPlayer = name; }
          else if (type == 'BLOB_KING' || type == 'DISASTER_MASTER') { blobKingPlayer = name; maxBlobs = 1; }
          else if (type == 'CONSISTENT') { grinderPlayer = name; maxParsPlayer = 1; }
          else if (type == 'SNIPER') { sniperPlayer = name; maxBirdsPlayer = 1; }
          else if (type == 'ROLLERCOASTER') { rollercoasterPlayer = name; maxVariance = 5.0; }
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

    // Standout Awards & Banter logic (Same as before)
    double totalVariance = 0;
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
        if (!isAdmin) ...[
          _buildStatsToggle(context, ref, ref.watch(richStatsModeProvider)),
          const SizedBox(height: 16),
        ],
        if (statsMode == 0) ...[
          const BoxyArtSectionTitle(title: 'SOCIETY HERO RECAP'),
          if (eclecticRound.any((s) => s != null))
            FieldEclecticCard(eclecticScores: eclecticRound, holes: holes),
          const SizedBox(height: 8),
          BoxyArtFloatingCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSmallStat('EAGLES', fieldEagles.toString(), Colors.purple),
                  _buildSmallStat('BIRDIES', fieldBirdies.toString(), Colors.blue),
                  _buildSmallStat('PARS', fieldPars.toString(), Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'FIELD COMPETITIVENESS'),
          ScoringTypeDistributionChart(counts: {
            'EAGLE': fieldEagles, 'BIRDIE': fieldBirdies, 'PAR': fieldPars, 'BOGEY': fieldBogeys, 'BLOB': fieldBlobs,
          }),
          if (isStableford) ...[
            const SizedBox(height: 12),
            StablefordDistributionChart(bucketCounts: stablefordBuckets),
          ],
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'PERFORMANCE TRENDS'),
          SplitPerformanceCard(front9Avg: front9AvgVal, back9Avg: back9AvgVal, isStableford: isStableford),
          const SizedBox(height: 12),
          ParTypeBreakdown(parTypeAverages: parTypeAverages),
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'COURSE ANALYSIS'),
          DifficultyHeatmap(holeAverages: holeAverages, holes: holes),
          const SizedBox(height: 12),
          HoleDifficultyChart(holeAverages: holeAverages, holes: holes),
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'HALL OF FAME'),
          if (maxStreak > 0)
            AchievementTile(title: 'HOT STREAK', playerName: hotStreakPlayer, value: '$maxStreak holes Par or better', icon: Icons.local_fire_department, color: Colors.orange),
          const SizedBox(height: 8),
          if (maxBounceBacks > 0)
            AchievementTile(title: 'BOUNCE BACK', playerName: bounceBackPlayer, value: '$maxBounceBacks recoveries today', icon: Icons.trending_up, color: Colors.blue),
          const SizedBox(height: 8),
          if (finisherPlayer != 'None')
            AchievementTile(title: 'TOP FINISHER', playerName: finisherPlayer, value: isStableford ? 'Rallied for $bestFinishScore points on final 3 holes' : 'Total $bestFinishScore on final 3 holes', icon: Icons.flag, color: Colors.purple),
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'BANTER & BRAGGING RIGHTS'),
          if (maxBlobs > 0)
            AchievementTile(title: 'THE BLOB KING', playerName: blobKingPlayer, value: isStableford ? '$maxBlobs holes with zero points 💀' : '$maxBlobs holes with Triple Bogey+ 💀', icon: Icons.sentiment_very_dissatisfied, color: Colors.red),
          const SizedBox(height: 8),
          if (maxParsPlayer > 0)
            AchievementTile(title: 'THE GRINDER', playerName: grinderPlayer, value: 'Most consistent with $maxParsPlayer pars', icon: Icons.shield, color: Colors.green),
          const SizedBox(height: 8),
          if (maxBirdsPlayer > 0)
            AchievementTile(title: 'THE SNIPER', playerName: sniperPlayer, value: 'Picked off $maxBirdsPlayer birdies', icon: Icons.gps_fixed, color: Colors.blueGrey),
          const SizedBox(height: 8),
          if (maxVariance > 3.0)
            AchievementTile(title: 'THE ROLLERCOASTER', playerName: rollercoasterPlayer, value: 'Wildest round of the day 🎢', icon: Icons.attractions, color: Colors.pink),
          const SizedBox(height: 32),
          SocietyRecapSummaryCard(totalPlayers: totalPlayers, totalHolesPlayed: totalPlayers * holes.length, topHoleName: toughestName, topHoleDiff: maxDiff),
        ] else ...[
          if (myScorecard == null)
            const BoxyArtFloatingCard(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('No personal scorecard found for this event.', style: TextStyle(color: Colors.grey))),
              ),
            )
          else
            _buildPersonalRecap(
              context: context, 
              myScorecard: myScorecard, 
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

  Widget _buildSmallStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPersonalRecap({
    required BuildContext context, 
    required Scorecard myScorecard, 
    required Map<int, double> fieldHoleAvgs, 
    required Map<int, double> fieldParTypeAvgs, 
    required Map<String, dynamic> courseConfig, 
    required CompetitionRules? rules,
    required double fieldAvgVariance,
    required double fieldAvgNet,
    required double fieldAvgBounceBackRate,
    required int fieldToughestHoleIdx,
    required Map<String, String> awardWinners,
    required List<EventRegistration> registrations,
  }) {
    final holes = courseConfig['holes'] as List? ?? [];
    final reg = registrations.firstWhere(
      (r) => r.memberId == myScorecard.entryId.replaceFirst('_guest', ''),
      orElse: () => EventRegistration(memberId: '', memberName: 'Unknown', attendingGolf: true),
    );
    final myName = myScorecard.entryId.endsWith('_guest') ? (reg.guestName ?? 'Guest') : reg.memberName;

    Map<int, double> myParTypeSums = {3: 0, 4: 0, 5: 0};
    Map<int, int> myParTypeCounts = {3: 0, 4: 0, 5: 0};
    List<double> myDiffs = [];
    int myHardestIdx = 0;
    double myMaxDiff = -999;
    int myBounceBacks = 0;
    int myOpportunities = 0;

    for (int i = 0; i < 18; i++) {
        final score = myScorecard.holeScores.length > i ? myScorecard.holeScores[i] : null;
        if (score != null) {
            final par = holes.length > i ? (holes[i]['par'] as int? ?? 4) : 4;
            final diff = (score - par).toDouble();
            myParTypeSums[par] = (myParTypeSums[par] ?? 0) + diff;
            myParTypeCounts[par] = (myParTypeCounts[par] ?? 0) + 1;
            myDiffs.add(diff);
            if (diff > myMaxDiff) { myMaxDiff = diff; myHardestIdx = i; }
            if (i > 0) {
              final prevScore = myScorecard.holeScores.length > i-1 ? myScorecard.holeScores[i-1] : null;
              if (prevScore != null) {
                final prevPar = holes.length > i-1 ? (holes[i-1]['par'] as int? ?? 4) : 4;
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
    final grossScore = myScorecard.holeScores.whereType<int>().fold(0, (a, b) => a + b);
    final diff = HandicapCalculator.calculateDifferential(grossScore: grossScore, courseConfig: courseConfig);

    List<String> myAwards = [];
    awardWinners.forEach((title, winner) { if (winner == myName) myAwards.add(title); });

    final fieldHardestHoleDiff = fieldHoleAvgs[fieldToughestHoleIdx] != null ? fieldHoleAvgs[fieldToughestHoleIdx]! - (holes[fieldToughestHoleIdx]['par'] as int? ?? 4).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'PERSONAL PERFORMANCE'),
        if (myAwards.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text('AWARD EARNED!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(myAwards.join(' & '), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        PersonalBenchmarkingCard(myAverages: myParTypeAverages, fieldAverages: fieldParTypeAvgs),
        const SizedBox(height: 12),
        NetComparisonCard(myNet: myScorecard.netTotal ?? grossScore, fieldAvgNet: fieldAvgNet),
        const SizedBox(height: 12),
        ConsistencyStatCard(myVariance: myVariance, fieldAvgVariance: fieldAvgVariance),
        const SizedBox(height: 12),
        BounceBackStatCard(myRate: myBounceBackRate, fieldRate: fieldAvgBounceBackRate),
        const SizedBox(height: 12),
        HoleNemesisComparison(myHardestHoleIdx: myHardestIdx, myHardestHoleDiff: myMaxDiff, fieldHardestHoleIdx: fieldToughestHoleIdx, fieldHardestHoleDiff: fieldHardestHoleDiff),
        const SizedBox(height: 12),
        HoleComparisonHeatmap(myScorecard: myScorecard, fieldAverages: fieldHoleAvgs, holes: holes),
        const SizedBox(height: 12),
        AchievementTile(title: 'HANDICAP IMPACT', playerName: 'Round Rating', value: 'Net Differential: ${diff.toStringAsFixed(1)}', icon: Icons.analytics, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }

  Widget _buildStatsToggle(BuildContext context, WidgetRef ref, int statsMode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.inputSoft,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              context, 
              label: 'SOCIETY', 
              icon: Icons.groups_outlined,
              isSelected: statsMode == 0, 
              onTap: () => ref.read(richStatsModeProvider.notifier).set(0),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              context, 
              label: 'PERSONAL', 
              icon: Icons.person_outline,
              isSelected: statsMode == 1, 
              onTap: () => ref.read(richStatsModeProvider.notifier).set(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.black : Colors.grey,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
