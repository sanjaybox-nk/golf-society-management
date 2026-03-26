import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/features/events/logic/event_analysis_engine.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart'; // MarkerSelection
import '../domain/models/processed_event_data.dart';
import 'package:collection/collection.dart';

class EventScoringProcessor {
  static ProcessedEventData process({
    required String eventId,
    required GolfEvent event,
    required Competition comp,
    required List<Scorecard> liveScorecards,
    required List<Member> members,
    required MarkerSelection markerSelection,
    String? currentUserId,
  }) {
    final rules = comp.rules;
    final teeOverrides = markerSelection.teeOverrides;
    final manualCuts = event.manualCuts;

    // 1. Process Individual Scores
    final List<ProcessedPlayerScore> individualScores = [];
    final memberMap = {for (var m in members) m.id: m};

    final allPlayerIds = {
      ...event.registrations.map((r) => r.memberId),
      ...event.registrations.where((r) => r.guestName != null).map((r) => '${r.memberId}_guest'),
      ...event.results.map((r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? '').toString()),
      ...liveScorecards.map((s) => s.entryId),
      if (currentUserId != null) currentUserId,
    }..remove('');

    for (var effectivePid in allPlayerIds) {
      final isGuestSuffix = effectivePid.endsWith('_guest');
      final basePid = isGuestSuffix ? effectivePid.replaceFirst('_guest', '') : effectivePid;
      
      final reg = event.registrations.firstWhereOrNull((r) => r.memberId == basePid) ??
                  event.registrations.firstWhereOrNull((r) => r.memberId == effectivePid);
      
      final isGuest = isGuestSuffix || (reg?.isGuest ?? false);

      // Resolve Tee
      final courseConfig = ScoringCalculator.resolvePlayerCourseConfig(
        memberId: basePid, 
        event: event, 
        membersList: members, 
        manualTeeName: teeOverrides[effectivePid],
      );

      // [NEW] Filter: Only include confirmed players OR players who actually have scores (Live/Seeded)
      // Harden: Check both effectivePid and basePid mapping for flexibility
      final liveCard = liveScorecards.firstWhereOrNull((s) => s.entryId == effectivePid) ?? 
                       liveScorecards.firstWhereOrNull((s) => s.entryId == basePid);
      
      // Seeded lookup priority: ID match -> Name match against Registration -> Name match against Member profile
      final seededResult = event.results.firstWhereOrNull((r) => (r['memberId'] ?? r['userId'] ?? r['playerId']) == effectivePid) ?? 
                           event.results.firstWhereOrNull((r) => (r['memberId'] ?? r['userId'] ?? r['playerId']) == basePid) ??
                           event.results.firstWhereOrNull((r) => r['playerName'] == (isGuest ? reg?.guestName : reg?.memberName)) ??
                           event.results.firstWhereOrNull((r) => r['playerName'] == memberMap[basePid]?.displayName);
      
      final bool hasScores = (liveCard != null && liveCard.holeScores.any((h) => h != null)) || (seededResult != null);
      
      // Guests MUST have score data to appear on the leaderboard (per user request)
      if (isGuest && !hasScores) continue;

      // Members stay if they have a registration OR scores OR a live scorecard OR they are the current user (Dev/Test)
      final bool isMe = currentUserId != null && (effectivePid == currentUserId || basePid == currentUserId);
      if (!isGuest && reg == null && !hasScores && liveCard == null && !isMe) continue;

      // Resolve Handicap Index
      double index = 18.0;
      if (isGuest) {
        index = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
      } else {
        index = memberMap[basePid]?.handicap ?? 18.0;
      }

      // Calculate PHC (WHS Baseline -> Playing)
      final courseHandicap = HandicapCalculator.calculateCourseHandicap(
        handicapIndex: index,
        courseConfig: courseConfig,
      );
      final phc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: index, 
        rules: rules, 
        courseConfig: courseConfig,
        societyCut: manualCuts[basePid] ?? 0.0,
      );

      // Merge Scores (Live > Seeded)
      // Note: liveCard and seededResult are already resolved above for filtering
      
      List<int?> holeScores = List.generate(18, (_) => null);
      if (liveCard != null && liveCard.holeScores.any((s) => s != null)) {
         holeScores = List.from(liveCard.holeScores);
      } else if (seededResult != null && seededResult['holeScores'] != null) {
         holeScores = (seededResult['holeScores'] as List).cast<int?>();
      }

      final result = ScoringCalculator.calculate(
        holeScores: holeScores, 
        holes: courseConfig.holes, 
        playingHandicap: phc.toDouble(), 
        format: rules.format,
        maxScoreConfig: rules.maxScoreConfig,
      );

      final String resolvedName = isGuest 
          ? (reg?.guestName ?? seededResult?['playerName'] as String? ?? 'Guest')
          : (reg?.memberName ?? memberMap[basePid]?.displayName ?? seededResult?['playerName'] as String? ?? (effectivePid.length > 5 ? effectivePid : 'Member'));

      individualScores.add(ProcessedPlayerScore(
        playerId: effectivePid,
        playerName: resolvedName,
        isGuest: isGuest,
        handicapIndex: index,
        courseHandicap: courseHandicap,
        playingHandicap: phc,
        appliedSocietyCut: manualCuts[basePid] ?? 0.0,
        teeName: courseConfig.name,
        holeScores: holeScores,
        result: result,
        tieBreakLabel: calculateTieBreakLabel(result),
        thruLabel: (result.holesPlayed > 0 && result.holesPlayed < 18)
            ? 'Thru ${result.holesPlayed}'
            : null,
        scoringStatus: _resolveScoringStatus(liveCard),
      ));
    }

    // 2. Process Leaderboard
    final List<ProcessedLeaderboardEntry> leaderboard = [];
    final currentFormat = rules.format;
    final isTeamComp = rules.effectiveMode != CompetitionMode.singles;

    if (!isTeamComp) {
      final sortedIndividual = List<ProcessedPlayerScore>.from(individualScores);
      final isStableford = currentFormat == CompetitionFormat.stableford;
      
      sortedIndividual.sort((a, b) {
        // 1. Status Check (WD/DQ/NR at bottom)
        final liveA = liveScorecards.firstWhereOrNull((s) => s.entryId == a.playerId);
        final liveB = liveScorecards.firstWhereOrNull((s) => s.entryId == b.playerId);
        
        final statusA = _resolveScoringStatus(liveA);
        final statusB = _resolveScoringStatus(liveB);
        
        final aOk = statusA == ScoringStatus.ok;
        final bOk = statusB == ScoringStatus.ok;
        if (aOk != bOk) return aOk ? -1 : 1;

        // 2. Score check
        final scoreCompare = isStableford 
            ? b.result.score.compareTo(a.result.score)
            : a.result.score.compareTo(b.result.score);
        
        if (scoreCompare != 0) return scoreCompare;

        // 3. Tie-break (Countback)
        final aMetrics = _calculateTieBreakMetrics(a.result);
        final bMetrics = _calculateTieBreakMetrics(b.result);
        
        for (int i = 0; i < aMetrics.length; i++) {
          final mCompare = isStableford
              ? bMetrics[i].compareTo(aMetrics[i])
              : aMetrics[i].compareTo(bMetrics[i]);
          if (mCompare != 0) return mCompare;
        }
        
        return 0;
      });

      for (int i = 0; i < sortedIndividual.length; i++) {
        final p = sortedIndividual[i];
        int pos = i + 1;
        
        // Only share position if everything matches (including tie-breaks)
        if (i > 0) {
          final prev = sortedIndividual[i - 1];
          final aMetrics = _calculateTieBreakMetrics(p.result);
          final bMetrics = _calculateTieBreakMetrics(prev.result);
          bool metricsMatch = const ListEquality().equals(aMetrics, bMetrics);
          
          if (p.result.score == prev.result.score && metricsMatch) {
            pos = leaderboard.last.position;
          }
        }

        leaderboard.add(ProcessedLeaderboardEntry(
          entryId: p.playerId,
          playerName: p.playerName,
          score: p.result.score,
          scoreLabel: p.result.label,
          holesPlayed: p.result.holesPlayed,
          isGuest: p.isGuest,
          teamMemberIds: [p.playerId],
          teamMemberNames: [p.playerName],
          individualPlayingHandicaps: [p.playingHandicap],
          holeScores: p.result.holeScores,
          holeNetScores: p.result.holeNetScores,
          holePoints: p.result.holePoints,
          hasSocietyCut: p.appliedSocietyCut != 0,
          position: pos,
          tieBreakMetrics: _calculateTieBreakMetrics(p.result),
          handicapIndex: p.handicapIndex,
          tieBreakLabel: calculateTieBreakLabel(p.result),
          scoringStatus: _resolveScoringStatus(liveScorecards.firstWhereOrNull((s) => s.entryId == p.playerId)),
        ));
      }
    } else {
      final groupsData = event.grouping['groups'] as List?;
      final List<TeeGroup> groups = groupsData != null 
          ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
          : [];

      final List<ProcessedLeaderboardEntry> teamEntries = [];
      final isFourball = rules.subtype == CompetitionSubtype.fourball;
      final isFoursomes = rules.subtype == CompetitionSubtype.foursomes;
      final teamSize = rules.teamSize;

      for (var group in groups) {
         for (int i = 0; i < group.players.length; i += teamSize) {
            final teamPlayers = group.players.skip(i).take(teamSize).toList();
            if (teamPlayers.isEmpty) continue;

            final playerIds = teamPlayers.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList();
            final names = teamPlayers.map((p) => p.name).toList();
            final teamResults = playerIds.map((id) => individualScores.firstWhereOrNull((s) => s.playerId == id)?.result).whereType<ScoringResult>().toList();

            if (teamResults.isEmpty) continue;

            ScoringResult finalResult;
            if (isFourball) {
               finalResult = ScoringCalculator.calculateBestBall(
                 individualResults: teamResults, 
                 holes: event.courseConfig.holes, 
                 format: currentFormat,
               );
            } else if (isFoursomes) {
               finalResult = teamResults.first;
            } else {
               finalResult = teamResults.first;
            }

            final teamStatus = teamPlayers.map((p) {
              final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
              final card = liveScorecards.firstWhereOrNull((s) => s.entryId == id);
              return _resolveScoringStatus(card);
            }).firstWhere((s) => s != ScoringStatus.ok, orElse: () => ScoringStatus.ok);

            teamEntries.add(ProcessedLeaderboardEntry(
              entryId: playerIds.join('_'),
              playerName: names.join(' / '),
              score: finalResult.score,
              scoreLabel: finalResult.label,
              holesPlayed: finalResult.holesPlayed,
              isGuest: teamPlayers.any((p) => p.isGuest),
              teamMemberIds: playerIds,
              teamMemberNames: names,
              individualPlayingHandicaps: teamPlayers.map((p) {
                final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
                return individualScores.firstWhereOrNull((s) => s.playerId == id)?.playingHandicap ?? 0;
              }).toList(),
              holeScores: finalResult.holeScores,
              holeNetScores: finalResult.holeNetScores,
              holePoints: finalResult.holePoints,
              individualHoleScores: teamResults.map((r) => r.holeScores).toList().cast<List<int?>>(),
              individualHoleNetScores: teamResults.map((r) => r.holeNetScores).toList().cast<List<int?>>(),
              individualHolePoints: teamResults.map((r) => r.holePoints).toList().cast<List<int?>>(),
              handicapIndex: teamPlayers.firstOrNull?.handicapIndex ?? 0.0,
              tieBreakLabel: calculateTieBreakLabel(finalResult),
              position: 0,
              tieBreakMetrics: _calculateTieBreakMetrics(finalResult),
              scoringStatus: teamStatus,
            ));
         }
      }

      final isStableford = currentFormat == CompetitionFormat.stableford;
      
      teamEntries.sort((a, b) {
        // 1. Status Check (WD/DQ/NR at bottom)
        final aOk = a.scoringStatus == ScoringStatus.ok;
        final bOk = b.scoringStatus == ScoringStatus.ok;
        if (aOk != bOk) return aOk ? -1 : 1;

        // 2. Score check
        final scoreCompare = isStableford 
            ? b.score.compareTo(a.score)
            : a.score.compareTo(b.score);
            
        if (scoreCompare != 0) return scoreCompare;

        // Tie-break
        for (int i = 0; i < a.tieBreakMetrics.length; i++) {
          final mCompare = isStableford
              ? b.tieBreakMetrics[i].compareTo(a.tieBreakMetrics[i])
              : a.tieBreakMetrics[i].compareTo(b.tieBreakMetrics[i]);
          if (mCompare != 0) return mCompare;
        }
        return 0;
      });

      for (int i = 0; i < teamEntries.length; i++) {
        int pos = i + 1;
        if (i > 0) {
           bool metricsMatch = const ListEquality().equals(teamEntries[i].tieBreakMetrics, teamEntries[i-1].tieBreakMetrics);
           if (teamEntries[i].score == teamEntries[i-1].score && metricsMatch) {
             pos = leaderboard.last.position;
           }
        }
        leaderboard.add(teamEntries[i].copyWith(position: pos));
      }
    }

    // 3. Process Group Rankings (Podium)
    final groupsData = event.grouping['groups'] as List?;
    final List<TeeGroup> groups = groupsData != null 
        ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
        : [];
    
    final List<ProcessedGroupResult> groupRankings = [];
    for (var group in groups) {
       final groupIndividualResults = group.players.map((p) {
         final pid = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
         return individualScores.firstWhereOrNull((s) => s.playerId == pid)?.result;
       }).whereType<ScoringResult>().toList();

        if (groupIndividualResults.isNotEmpty) {
          final groupResult = ScoringCalculator.calculateGroupResult(
            individualResults: groupIndividualResults,
            rules: rules,
            bestX: rules.teamBestXCount,
          );

          groupRankings.add(ProcessedGroupResult(
            groupIndex: group.index,
            label: groupResult.label,
            totalScore: groupResult.totalScore,
            tieBreakMetrics: groupResult.tieBreakMetrics,
          ));
        }
    }

    // 4. Global Stats
    final eventStats = EventAnalysisEngine.calculateFinalStats(
      scorecards: liveScorecards, 
      event: event, 
      competition: comp,
      isStableford: rules.format == CompetitionFormat.stableford,
    );

    return ProcessedEventData(
      eventId: eventId,
      individualScores: individualScores,
      leaderboard: leaderboard,
      groupRankings: groupRankings,
      eventStats: eventStats,
      holePars: event.courseConfig.holes.map((h) => h.par).toList(),
      lastComputedAt: DateTime.now(),
    );
  }

  static ScoringStatus _resolveScoringStatus(Scorecard? card) {
    if (card == null) return ScoringStatus.ok;
    
    // Explicit manual overrides (WD, DQ, NR set by admin)
    if (card.scoringStatus != ScoringStatus.ok) return card.scoringStatus;

    // Automatic NR detection: If submitted/final but incomplete
    final isSubmitted = card.status == ScorecardStatus.submitted || card.status == ScorecardStatus.finalScore;
    final holesPlayed = card.holeScores.where((s) => s != null).length;
    
    if (isSubmitted && holesPlayed < 18) {
      return ScoringStatus.nr;
    }

    return ScoringStatus.ok;
  }

  static String? calculateTieBreakLabel(ScoringResult result) {
    // Show progressive countback for tie-break visibility
    final b9 = _getSegmentTotal(result, 9, 18);
    final b6 = _getSegmentTotal(result, 12, 18);
    final b3 = _getSegmentTotal(result, 15, 18);
    
    return 'B9: $b9 • B6: $b6 • B3: $b3';
  }

  static List<int> _calculateTieBreakMetrics(ScoringResult result) {
    // Standard countback: B9, B6, B3, B1
    return [
      _getSegmentTotal(result, 9, 18),
      _getSegmentTotal(result, 12, 18),
      _getSegmentTotal(result, 15, 18),
      _getSegmentTotal(result, 17, 18),
    ];
  }

  static int _getSegmentTotal(ScoringResult result, int start, int end) {
    if (result.holePoints.length < end) return 0;
    return result.holePoints.sublist(start, end).whereType<int>().fold<int>(0, (sum, p) => sum + p);
  }
}
