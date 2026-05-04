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
import '../domain/registration_logic.dart';
import '../../matchplay/domain/match_play_calculator.dart';
import '../../matchplay/domain/match_definition.dart';
import '../../matchplay/domain/golf_event_match_extensions.dart';

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

    // 27. [NEW] Synchronize "Playing" set with RegistrationLogic (FCFS + Capacity Aware)
    final playingItems = RegistrationLogic.getPlayingParticipants(event);
    final playingIds = playingItems.map((item) {
      return item.isGuest ? '${item.registration.memberId}_guest' : item.registration.memberId;
    }).toSet();

    // 1. Process Individual Scores
    final List<ProcessedPlayerScore> individualScores = [];
    final currentUser = currentUserId != null ? members.firstWhereOrNull((m) => m.id == currentUserId) : null;
    final memberMap = {for (var m in members) m.id: m};
    
    // Ensure current user is in the map if they have a special profile (e.g. Viewing As)
    if (currentUserId != null && !memberMap.containsKey(currentUserId)) {
       // We don't have the full profile in 'members', but we might have it from the effectiveUserProvider
       // Since this is a static method, we rely on the caller passing the right 'members' list.
       // However, to be safe, we can check if any of our registrations/scorecards match.
    }

    final allPlayerIds = {
      ...event.registrations.map((r) => r.memberId),
      ...event.registrations.where((r) => r.guestName != null).map((r) => '${r.memberId}_guest'),
      ...event.results.map((r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? '').toString()),
      ...liveScorecards.map((s) => s.entryId),
      if (currentUserId case String id) id,
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
      
      // [NEW] Master Filter: Include everyone in the "Playing" set, OR in the grouping, OR who has a scorecard
      final bool isMe = currentUserId != null && (effectivePid == currentUserId || basePid == currentUserId);
      final bool isInGroups = event.grouping['groups'] != null && 
                             (event.grouping['groups'] as List).any((g) => 
                               (g['players'] as List).any((p) => p['registrationMemberId'] == basePid || p['registrationMemberId'] == effectivePid)
                             );
      final bool isPlaying = playingIds.contains(effectivePid);
      
      if (!isPlaying && !isInGroups && !hasScores && !isMe) continue;
      
      // Guests MUST have score data to appear on the leaderboard (per user request)
      if (isGuest && !hasScores) continue;

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
      if (liveCard != null) {
         final pScores = liveCard.holeScores;
         final vScores = liveCard.playerVerifierScores;
         for (int i = 0; i < 18; i++) {
            // Use player score if available, otherwise marker's verifier score
            holeScores[i] = pScores.elementAtOrNull(i) ?? vScores.elementAtOrNull(i);
         }
      } 
      
      // If still empty, check seeded results
      if (holeScores.every((s) => s == null) && seededResult != null && seededResult['holeScores'] != null) {
         holeScores = (seededResult['holeScores'] as List).cast<int?>();
      }

      // 122. [NEW] Scramble Logic: If it's a team scramble, use the team PHC and scorecard
      final isScramble = rules.format == CompetitionFormat.scramble;
      final bool isTeamGame = isScramble || rules.subtype == CompetitionSubtype.texas || rules.subtype == CompetitionSubtype.florida;
      
      double effectivePhc = phc.toDouble();
      if (isTeamGame) {
        // Find the group this player belongs to
        final groupData = (event.grouping['groups'] as List?)?.firstWhereOrNull((g) => 
          (g['players'] as List).any((p) => p['registrationMemberId'] == basePid || p['registrationMemberId'] == effectivePid)
        );
        if (groupData != null) {
          final group = TeeGroup.fromJson(groupData);
          final List<double> indices = group.players.map((p) => p.handicapIndex).toList();
          effectivePhc = HandicapCalculator.calculateTeamHandicap(
            individualIndices: indices, 
            rules: rules, 
            courseConfig: courseConfig,
          ).toDouble();
        }
      }

      final result = ScoringCalculator.calculate(
        holeScores: holeScores, 
        holes: courseConfig.holes, 
        playingHandicap: effectivePhc, 
        format: rules.format,
        maxScoreConfig: rules.maxScoreConfig,
      );

      final String resolvedName = isGuest 
          ? (reg?.guestName ?? seededResult?['playerName'] as String? ?? 'Guest')
          : (reg?.memberName ?? memberMap[basePid]?.displayName ?? seededResult?['playerName'] as String? ?? (effectivePid.length > 5 ? effectivePid : 'Member'));

      int lastHoleIndex = 0;
      for (int i = 0; i < 18; i++) {
        if (holeScores[i] != null) lastHoleIndex = i + 1;
      }

      individualScores.add(ProcessedPlayerScore(
        playerId: effectivePid,
        playerName: resolvedName,
        isGuest: isGuest,
        handicapIndex: index,
        courseHandicap: courseHandicap,
        playingHandicap: phc,
        appliedSocietyCut: manualCuts[basePid] ?? 0.0,
        teeName: courseConfig.selectedTeeName ?? 'Default',
        teeColor: courseConfig.selectedTeeColor,
        holeScores: holeScores,
        result: result,
        tieBreakLabel: calculateTieBreakLabel(result, null),
        thruLabel: null, // Calculated in next pass
        scoringStatus: _resolveScoringStatus(liveCard),
        maxHolePlayed: lastHoleIndex,
      ));
    }

    // 1.1 [NEW] Calculate Group-wide Thru Sync
    final Map<int, int> groupMaxThru = {};
    final groupsData = event.grouping['groups'] as List?;
    final List<dynamic> rawGroups = groupsData ?? [];

    for (int gIdx = 0; gIdx < rawGroups.length; gIdx++) {
      final gPlayers = (rawGroups[gIdx]['players'] as List);
      int maxThru = 0;
      for (var p in gPlayers) {
        final pid = p['registrationMemberId'] as String;
        final isG = p['isGuest'] as bool? ?? false;
        final effectiveId = isG ? '${pid}_guest' : pid;
        final score = individualScores.firstWhereOrNull((s) => s.playerId == effectiveId);
        if (score != null && score.maxHolePlayed > maxThru) {
          maxThru = score.maxHolePlayed;
        }
      }
      groupMaxThru[gIdx] = maxThru;
    }

    // 1.2 [NEW] Apply Synced Thru Labels
    final List<ProcessedPlayerScore> syncedIndividualScores = individualScores.map((s) {
      // Find group index for this player
      int? myGroupIdx;
      for (int i = 0; i < rawGroups.length; i++) {
        final gPlayers = (rawGroups[i]['players'] as List);
        if (gPlayers.any((p) => p['registrationMemberId'] == s.playerId || '${p['registrationMemberId']}_guest' == s.playerId)) {
          myGroupIdx = i;
          break;
        }
      }

      final thruCount = myGroupIdx != null ? (groupMaxThru[myGroupIdx] ?? 0) : s.maxHolePlayed;

      return s.copyWith(
        thruLabel: (thruCount > 0)
            ? (thruCount < 18 ? 'Thru $thruCount' : 'F')
            : null,
      );
    }).toList();

    // 1.5 [NEW] Refine tie-break labels for ALL individual scores (v4.x consistency)
    final Map<int, List<List<int>>> scoreToMetricsMap = {};
    for (var p in individualScores) {
      if (p.scoringStatus == ScoringStatus.ok && p.result.holesPlayed > 0) {
        scoreToMetricsMap[p.result.score] ??= [];
        scoreToMetricsMap[p.result.score]!.add(_calculateTieBreakMetrics(p.result));
      }
    }

    final List<ProcessedPlayerScore> refinedIndividualScores = syncedIndividualScores.map((p) {
      return p.copyWith(
        tieBreakLabel: calculateTieBreakLabel(p.result, scoreToMetricsMap[p.result.score]),
      );
    }).toList();

    // 2. [NEW] Pre-calculate Match Play results
    final Map<String, MatchResult> playerMatchResults = {};
    final bool isFourball = comp.rules.subtype == CompetitionSubtype.fourball || 
                       event.matches.any((m) => m.type == MatchType.fourball);
    final bool isMatchPlayEvent = rules.isMatchPlay || event.matches.isNotEmpty;

    if (isMatchPlayEvent) {
      // 2a. Process Explicit Matches
      for (final match in event.matches) {
        final result = MatchPlayCalculator.calculate(
          match: match,
          scorecards: liveScorecards,
          courseConfig: event.courseConfig,
          holesToPlay: 18,
        );
        for (final id in [...match.team1Ids, ...match.team2Ids]) {
          playerMatchResults[id] = result;
        }
      }

      // 2b. Virtual Match Detection (for groups without explicit match definitions)
      if (groupsData != null) {
        for (int groupIdx = 0; groupIdx < groupsData.length; groupIdx++) {
           final group = TeeGroup.fromJson(groupsData[groupIdx]);
           
           // If any player in the group doesn't have a result yet, try virtual match
           final needsVirtualMatch = group.players.any((p) {
             final pid = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
             return !playerMatchResults.containsKey(pid);
           });

           if (needsVirtualMatch) {
              if (isFourball && group.players.length >= 4) {
                final t1Ids = group.players.take(2).map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList();
                final t2Ids = group.players.skip(2).take(2).map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList();
                final res = MatchPlayCalculator.calculate(
                  match: MatchDefinition(id: 'v_$groupIdx', type: MatchType.fourball, team1Ids: t1Ids, team2Ids: t2Ids),
                  scorecards: liveScorecards,
                  courseConfig: event.courseConfig,
                  holesToPlay: 18,
                );
                for (final id in [...t1Ids, ...t2Ids]) {
                   playerMatchResults[id] = res;
                }
              } else if (group.players.length >= 2) {
                // Singles matches for pairs
                for (int i = 0; i < group.players.length; i += 2) {
                  if (i + 1 < group.players.length) {
                    final p1Id = group.players[i].isGuest ? '${group.players[i].registrationMemberId}_guest' : group.players[i].registrationMemberId;
                    final p2Id = group.players[i+1].isGuest ? '${group.players[i+1].registrationMemberId}_guest' : group.players[i+1].registrationMemberId;
                    final res = MatchPlayCalculator.calculate(
                      match: MatchDefinition(id: 'id_v_${groupIdx}_$i', type: MatchType.singles, team1Ids: [p1Id], team2Ids: [p2Id]),
                      scorecards: liveScorecards,
                      courseConfig: event.courseConfig,
                      holesToPlay: 18,
                    );
                    playerMatchResults[p1Id] = res;
                    playerMatchResults[p2Id] = res;
                  }
                }
              }
           }
        }
      }
    }

    // 3. Process Leaderboard
    final List<ProcessedLeaderboardEntry> leaderboard = [];
    final currentFormat = rules.format;
    final isTeamComp = rules.effectiveMode != CompetitionMode.singles;

    if (!isTeamComp) {
      final sortedIndividual = List<ProcessedPlayerScore>.from(refinedIndividualScores);
      final isStableford = currentFormat == CompetitionFormat.stableford;
      
      sortedIndividual.sort((a, b) {
        // 1. Status Check (WD/DQ/NR at bottom)
        if (a.scoringStatus != b.scoringStatus) {
           final aOk = a.scoringStatus == ScoringStatus.ok;
           return aOk ? -1 : 1;
        }

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
        
        // [NEW] Strict Leaderboard Filter: Even if "isMe" allowed them into individualScores,
        // they should only appear on the leaderboard if they are actually participating.
        final bool isParticipating = playingIds.contains(p.playerId) || 
                                    (event.grouping['groups'] as List?)?.any((g) => 
                                      (g['players'] as List).any((pl) => pl['registrationMemberId'] == p.playerId || '${pl['registrationMemberId']}_guest' == p.playerId)
                                    ) == true ||
                                    p.result.holesPlayed > 0 ||
                                    (liveScorecards.any((s) => s.entryId == p.playerId && s.holeScores.any((h) => h != null)));

        if (!isParticipating) continue;

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

        final matchResult = playerMatchResults[p.playerId];
        final String? matchStatusLabel;
        final int? matchLead;

        if (matchResult != null) {
          final isT1 = event.matches.any((m) => m.team1Ids.contains(p.playerId));
          matchLead = isT1 ? matchResult.score : -matchResult.score;
          final absLead = matchLead.abs();
          final remaining = 18 - matchResult.holesPlayed;

          if (absLead > remaining) {
            final prefix = matchLead > 0 ? 'WIN' : 'LOSS';
            matchStatusLabel = remaining > 0 ? '$prefix $absLead & $remaining' : '$prefix $absLead UP';
          } else if (matchLead > 0) {
            matchStatusLabel = '$absLead UP';
          } else if (matchLead < 0) {
            matchStatusLabel = '$absLead DN';
          } else {
            matchStatusLabel = remaining == 0 ? 'HALVED' : 'AS';
          }
        } else {
          matchStatusLabel = null;
          matchLead = null;
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
          tieBreakLabel: p.tieBreakLabel,
          thruLabel: p.thruLabel,
          scoringStatus: _resolveScoringStatus(liveScorecards.firstWhereOrNull((s) => s.entryId == p.playerId)),
          matchStatus: matchStatusLabel,
          matchScore: matchLead,
          isMatch: matchResult != null,
          teeName: p.teeName,
          teeColor: p.teeColor,
          absoluteScore: p.result.absoluteScore,
          absoluteScoreLabel: p.result.absoluteScoreLabel,
        ));
      }
    } else {
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

            final String teamLeaderId = playerIds.firstOrNull ?? '';
            final teamMatchResult = playerMatchResults[teamLeaderId];
            final String? teamMatchStatusLabel;
            final int? teamMatchLead;

            if (teamMatchResult != null) {
              final isT1 = event.matches.any((m) => m.team1Ids.contains(teamLeaderId));
              teamMatchLead = isT1 ? teamMatchResult.score : -teamMatchResult.score;
              final absLead = teamMatchLead.abs();
              final remaining = 18 - teamMatchResult.holesPlayed;

              if (absLead > remaining) {
                final prefix = teamMatchLead > 0 ? 'WIN' : 'LOSS';
                teamMatchStatusLabel = remaining > 0 ? '$prefix $absLead & $remaining' : '$prefix $absLead UP';
              } else if (teamMatchLead > 0) {
                teamMatchStatusLabel = '$absLead UP';
              } else if (teamMatchLead < 0) {
                teamMatchStatusLabel = '$absLead DN';
              } else {
                teamMatchStatusLabel = remaining == 0 ? 'HALVED' : 'AS';
              }
            } else {
              teamMatchStatusLabel = null;
              teamMatchLead = null;
            }

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
              tieBreakLabel: calculateTieBreakLabel(finalResult, null), // TODO: Group tie-break comparison if needed
              position: 0,
              tieBreakMetrics: _calculateTieBreakMetrics(finalResult),
              scoringStatus: teamStatus,
              matchStatus: teamMatchStatusLabel,
              matchScore: teamMatchLead,
              isMatch: teamMatchResult != null,
              absoluteScore: finalResult.absoluteScore,
              absoluteScoreLabel: finalResult.absoluteScoreLabel,
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
    final List<TeeGroup> groups = groupsData != null 
        ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
        : [];
    
    final List<ProcessedGroupResult> groupRankings = [];
    final bool isFourballRule = rules.subtype == CompetitionSubtype.fourball;
    final isPairs = rules.mode == CompetitionMode.pairs;
    final isScramblePairs = rules.format == CompetitionFormat.scramble && rules.teamSize == 2;
    final isSplitTeam = isFourballRule || isPairs || isScramblePairs;

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

          int? sideAScore;
          int? sideBScore;
          String? sideALabel;
          String? sideBLabel;

          if (isSplitTeam && groupIndividualResults.length >= 2) {
             // Side A (Players 0-1)
             final sideAResults = groupIndividualResults.take(2).toList();
             final sideARes = isScramblePairs 
                ? sideAResults.first // Scramble pairs already have 1 result usually, but safeguard
                : ScoringCalculator.calculateBestBall(individualResults: sideAResults, holes: event.courseConfig.holes, format: rules.format);
             
             sideAScore = sideARes.score;
             sideALabel = sideARes.label;

             // Side B (Players 2-3)
             if (groupIndividualResults.length >= 4) {
                final sideBResults = groupIndividualResults.skip(2).take(2).toList();
                final sideBRes = isScramblePairs
                   ? sideBResults.first
                   : ScoringCalculator.calculateBestBall(individualResults: sideBResults, holes: event.courseConfig.holes, format: rules.format);
                
                sideBScore = sideBRes.score;
                sideBLabel = sideBRes.label;
             }
          }

          groupRankings.add(ProcessedGroupResult(
            groupIndex: group.index,
            label: groupResult.label,
            totalScore: groupResult.totalScore,
            tieBreakMetrics: groupResult.tieBreakMetrics,
            sideAScore: sideAScore,
            sideBScore: sideBScore,
            sideALabel: sideALabel,
            sideBLabel: sideBLabel,
          ));
        }
    }

    // 4. [NEW] Sort Group Rankings (Podium)
    final isStableford = rules.format == CompetitionFormat.stableford;
    groupRankings.sort((a, b) {
      final scoreCompare = isStableford 
          ? b.totalScore.compareTo(a.totalScore)
          : a.totalScore.compareTo(b.totalScore);
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

    // 5. Global Stats
    final eventStats = EventAnalysisEngine.calculateFinalStats(
      scorecards: liveScorecards, 
      event: event, 
      competition: comp,
      isStableford: rules.format == CompetitionFormat.stableford,
    );
    

    // 6. Calculate Submission Progress
    int totalParticipants = 0;
    int submittedCount = 0;
    int inProgressCount = 0;

    for (final score in refinedIndividualScores) {
      totalParticipants++;
      final card = liveScorecards.firstWhereOrNull((s) => s.entryId == score.playerId);
      if (card != null) {
        if (card.status == ScorecardStatus.submitted || card.status == ScorecardStatus.finalScore) {
          submittedCount++;
        } else if (card.status == ScorecardStatus.draft && score.result.holesPlayed > 0) {
          inProgressCount++;
        }
      }
    }

    return ProcessedEventData(
      eventId: eventId,
      individualScores: refinedIndividualScores,
      leaderboard: leaderboard,
      groupRankings: groupRankings,
      eventStats: eventStats,
      holePars: event.courseConfig.holes.map((h) => h.par).toList(),
      lastComputedAt: DateTime.now(),
      totalParticipants: totalParticipants,
      submittedCount: submittedCount,
      inProgressCount: inProgressCount,
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

  static String? calculateTieBreakLabel(ScoringResult result, List<List<int>>? otherMetrics) {
    if (otherMetrics == null || otherMetrics.length <= 1) return null;

    // Standard countback: B9, B6, B3, B1
    final metrics = _calculateTieBreakMetrics(result);
    final mNames = ['B9', 'B6', 'B3', 'B1'];

    // Find first metric that differs from ANY other player with the same score
    for (int i = 0; i < metrics.length; i++) {
      final val = metrics[i];
      final anyDiff = otherMetrics.any((other) => i < other.length && other[i] != val);
      if (anyDiff) {
        return '${mNames[i]}: $val';
      }
    }
    
    // If absolutely everything is tied, show B9 as fallback
    return 'B9: ${metrics[0]}';
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

  /// [NEW] Final system-level submission trigger.
  /// Transitions a scorecard to [ScorecardStatus.finalScore] if both parties have verified
  /// and there are no score discrepancies between the player's recorded scores 
  /// and the marker's recorded scores for that player.
  static Scorecard validateAndFinalizeHandshake({
    required Scorecard targetScorecard,
    required Scorecard? verifierScorecard,
  }) {
    if (verifierScorecard == null) return targetScorecard;

    // 1. Conflict detection: Compare player's holeScores with marker's playerVerifierScores
    final bool isConflictFree = const ListEquality().equals(
      targetScorecard.holeScores, 
      verifierScorecard.playerVerifierScores
    );

    if (!isConflictFree) return targetScorecard;

    // 2. Transition to finalScore if both parties have signed off
    if (targetScorecard.verifiedByPlayer && targetScorecard.verifiedByMarker) {
      return targetScorecard.copyWith(
        status: ScorecardStatus.finalScore,
        updatedAt: DateTime.now(),
      );
    }
    
    return targetScorecard;
  }
}

