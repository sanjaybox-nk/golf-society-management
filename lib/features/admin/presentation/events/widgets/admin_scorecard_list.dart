import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/features/events/presentation/widgets/scorecard_modal.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';

class AdminScorecardList extends ConsumerWidget {
  final GolfEvent event;
  final List<Scorecard> scorecards;
  final List<Member> membersList;

  const AdminScorecardList({
    super.key,
    required this.event,
    required this.scorecards,
    this.membersList = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compAsync = ref.watch(competitionDetailProvider(event.id));
    final comp = compAsync.value;
    final rules = comp?.rules ?? const CompetitionRules();
    
    final isTeamMode = rules.effectiveMode == CompetitionMode.teams || 
                       rules.effectiveMode == CompetitionMode.pairs;

    if (isTeamMode) {
      return _buildTeamList(context, ref, comp);
    }

    return _buildIndividualList(context, ref, comp);
  }

  Widget _buildIndividualList(BuildContext context, WidgetRef ref, Competition? comp) {
    final golfers = RegistrationLogic.getPlayingParticipants(event);
    final members = golfers.where((item) => !item.isGuest).toList();
    final guests = golfers.where((item) => item.isGuest).toList();
    
    _sortRegistrationList(members);
    _sortRegistrationList(guests);

    if (golfers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (members.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.sm),
            child: BoxyArtSectionTitle(title: 'SOCIETY MEMBERS', count: members.length),
          ),
          ...members.asMap().entries.map((entry) => _buildIndividualTile(context, ref, entry.key + 1, entry.value, comp)),
          const SizedBox(height: AppSpacing.x2l),
        ],
        if (guests.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: BoxyArtSectionTitle(title: 'GUESTS', count: guests.length),
          ),
          ...guests.asMap().entries.map((entry) => _buildIndividualTile(context, ref, members.length + entry.key + 1, entry.value, comp)),
        ],
      ],
    );
  }

  Widget _buildTeamList(BuildContext context, WidgetRef ref, Competition? comp) {
    final groupsData = event.grouping['groups'] as List? ?? [];
    final List<TeamScoreGroup> teamGroups = [];
    final rules = comp?.rules ?? const CompetitionRules();

    for (var g in groupsData) {
      final group = TeeGroup.fromJson(g);
      if (rules.effectiveMode == CompetitionMode.pairs) {
        // Split into two pairs
        final pairA = group.players.take(2).toList();
        if (pairA.isNotEmpty) teamGroups.add(TeamScoreGroup(players: pairA, index: group.index, isPair: true));
        
        final pairB = group.players.skip(2).take(2).toList();
        if (pairB.isNotEmpty) teamGroups.add(TeamScoreGroup(players: pairB, index: group.index, isPair: true));
      } else {
        // Scramble/Full Team
        teamGroups.add(TeamScoreGroup(players: group.players, index: group.index, isPair: false));
      }
    }

    if (teamGroups.isEmpty) return _buildEmptyState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.sm),
          child: BoxyArtSectionTitle(title: 'TEAMS & GROUPS'),
        ),
        ...teamGroups.asMap().entries.map((entry) => _buildTeamTile(context, ref, entry.key + 1, entry.value, comp)),
      ],
    );
  }

  Widget _buildIndividualTile(BuildContext context, WidgetRef ref, int index, RegistrationItem item, Competition? comp) {
    final scorecard = _getScorecard(item: item);
    final status = scorecard?.status ?? ScorecardStatus.draft;
    final isConfirmed = status == ScorecardStatus.reviewed || status == ScorecardStatus.finalScore;
    final isPending = status == ScorecardStatus.submitted;
    final id = item.isGuest ? '${item.registration.memberId}_guest' : item.registration.memberId;

    final member = membersList.firstWhereOrNull((m) => m.id == item.registration.memberId);
    final double baseHcp = item.isGuest 
      ? (double.tryParse(item.registration.guestHandicap ?? '18.0') ?? 18.0)
      : (member?.handicap ?? 18.0);
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: id, 
      event: event, 
      membersList: membersList,
    );
    final baseRating = event.courseConfig.rating;
    final phc = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: baseHcp,
      rules: comp?.rules ?? const CompetitionRules(),
      courseConfig: playerTeeConfig,
      baseRating: baseRating,
    );

    final holesPlayed = scorecard?.holeScores.where((s) => s != null).length ?? 0;
    final showThru = !isConfirmed && holesPlayed > 0 && holesPlayed < 18;

    final statusLabel = isConfirmed ? 'Confirmed' : (isPending ? 'Pending' : 'Open');

    // Build the score label
    String? scoreLabel;
    if (scorecard != null) {
      final pts = _formatScore(scorecard, comp);
      final format = comp?.rules.format ?? CompetitionFormat.stableford;
      scoreLabel = format == CompetitionFormat.stableford ? '$pts pts' : pts;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: BoxyArtMemberRow(
        name: item.name,
        initials: item.name,
        avatarUrl: member?.avatarUrl,
        ranking: index,
        handicapIndex: baseHcp,
        playingHandicap: phc,
        score: scoreLabel,
        scoreColor: isConfirmed ? AppColors.lime500 : null,
        thruLabel: showThru ? 'Thru $holesPlayed' : null,
        tieBreakLabel: statusLabel,
        isGuest: item.isGuest,
        useCard: true,
        showChevron: true,
        trailing: _buildLockAction(ref, scorecard, item.name, status, isConfirmed),
        onTap: () => _showScorecardModal(context, ref, item, id, scorecard, comp),
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, WidgetRef ref, int index, TeamScoreGroup team, Competition? comp) {
    final names = team.players.map((p) => p.name).toList();
    final ids = team.players.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList();
    
    Scorecard? scorecard;
    for (final id in ids) {
      scorecard = scorecards.firstWhereOrNull((s) => s.entryId == id);
      if (scorecard != null) break;
    }
    if (scorecard == null && comp?.rules.format == CompetitionFormat.scramble) {
      scorecard = scorecards.firstWhereOrNull((s) => s.entryId == 'team_${team.index}');
    }

    final status = scorecard?.status ?? ScorecardStatus.draft;
    final isConfirmed = status == ScorecardStatus.reviewed || status == ScorecardStatus.finalScore;
    final isPending = status == ScorecardStatus.submitted;

    final holesPlayed = scorecard?.holeScores.where((s) => s != null).length ?? 0;
    final showThru = !isConfirmed && holesPlayed > 0 && holesPlayed < 18;
    final statusLabel = isConfirmed ? 'Confirmed' : (isPending ? 'Pending' : 'Open');

    String? scoreLabel;
    if (scorecard != null) {
      final pts = _formatScore(scorecard, comp);
      final format = comp?.rules.format ?? CompetitionFormat.stableford;
      scoreLabel = format == CompetitionFormat.stableford ? '$pts pts' : pts;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: BoxyArtMemberRow(
        name: names.first,
        secondaryName: names.length > 1 ? names.skip(1).join(' / ') : null,
        initials: names.first,
        ranking: index,
        score: scoreLabel,
        scoreColor: isConfirmed ? AppColors.lime500 : null,
        thruLabel: showThru ? 'Thru $holesPlayed' : null,
        tieBreakLabel: statusLabel,
        useCard: true,
        showChevron: true,
        trailing: _buildLockAction(ref, scorecard, names.join(' / '), status, isConfirmed),
        onTap: () {
          final item = RegistrationLogic.getSortedItems(event, includeWithdrawn: true)
              .firstWhereOrNull((i) => i.name == names.first);
          if (item != null) {
            _showScorecardModal(context, ref, item, ids.first, scorecard, comp);
          }
        },
      ),
    );
  }


  String? _formatScore(Scorecard? card, Competition? comp) {
    if (card == null) return null;
    final format = comp?.rules.format ?? CompetitionFormat.stableford;
    
    if (format == CompetitionFormat.stableford) {
      return '${card.points}';
    }
    
    // For Stroke/Scramble formats, show relative to par if available
    // Otherwise fallback to points/gross. 
    // In this simplified Admin list view, points is often the points field
    return '${card.points}'; 
  }

  Widget? _buildLockAction(WidgetRef ref, Scorecard? card, String name, ScorecardStatus status, bool isConfirmed) {
    if (card == null) return null;
    final isPending = status == ScorecardStatus.submitted;

    return GestureDetector(
      onTap: () => _toggleScorecardStatus(ref, card, name, status),
      child: BoxyArtIconBadge(
        icon: isConfirmed ? Icons.lock_rounded : (isPending ? Icons.pending_actions_rounded : Icons.lock_open_rounded),
        color: isConfirmed ? AppColors.lime500 : (isPending ? AppColors.amber500 : AppColors.dark400),
        size: AppShapes.iconXl,
        iconSize: 16,
        showFill: false,
      ),
    );
  }

  void _sortRegistrationList(List<RegistrationItem> list) {
    list.sort((a, b) {
      final sA = _getScorecard(item: a);
      final sB = _getScorecard(item: b);
      
      int getPriority(Scorecard? s) {
        if (s == null) return 1;
        if (s.status == ScorecardStatus.draft) return 1;
        if (s.status == ScorecardStatus.submitted) return 0;
        return 2;
      }
      
      final pA = getPriority(sA);
      final pB = getPriority(sB);
      
      if (pA != pB) return pA.compareTo(pB);
      return a.name.compareTo(b.name);
    });
  }

  Widget _buildEmptyState() {
    return const BoxyArtCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.x3l),
        child: Center(child: Text('No participants found for this event.')),
      ),
    );
  }

  void _showScorecardModal(BuildContext context, WidgetRef ref, RegistrationItem item, String id, Scorecard? card, Competition? comp) {
    final member = membersList.firstWhereOrNull((m) => m.id == item.registration.memberId);
    final double baseHcp = item.isGuest 
      ? (double.tryParse(item.registration.guestHandicap ?? '18.0') ?? 18.0)
      : (member?.handicap ?? 18.0); 
    
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: id, 
      event: event, 
      membersList: membersList,
    );
    final baseRating = event.courseConfig.rating;

    final phc = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: baseHcp,
      rules: comp?.rules ?? const CompetitionRules(),
      courseConfig: playerTeeConfig,
      baseRating: baseRating,
    );

    ScorecardModal.show(
      context, 
      ref, 
      entry: LeaderboardEntry(
        entryId: id,
        playerName: item.name,
        handicap: baseHcp.toInt(),
        playingHandicap: phc,
        score: card?.points ?? 0,
        isGuest: item.isGuest,
        tieBreakLabel: card != null ? _calculateTieBreakLabel(card, comp) : null,
      ), 
      scorecards: scorecards, 
      event: event, 
      comp: comp,
      membersList: membersList,
      isAdmin: true,
    );
  }

  Future<void> _toggleScorecardStatus(WidgetRef ref, Scorecard card, String name, ScorecardStatus currentStatus) async {
    try {
      ScorecardStatus nextStatus;
      
      if (currentStatus == ScorecardStatus.draft) {
        nextStatus = ScorecardStatus.submitted;
      } else if (currentStatus == ScorecardStatus.submitted) {
        nextStatus = ScorecardStatus.reviewed;
      } else {
        nextStatus = ScorecardStatus.draft;
      }

      await ref.read(scorecardRepositoryProvider).updateScorecardStatus(card.id, nextStatus);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Scorecard Status Error: $e');
    }
  }

  // _resolvePlayerCourseConfig removed as we now use ScoringCalculator

  String? _calculateTieBreakLabel(Scorecard card, Competition? comp) {
    final rules = comp?.rules ?? const CompetitionRules();
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: card.entryId, 
      event: event, 
      membersList: membersList,
    );
    
    final phc = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: card.entryId.contains('_guest') 
          ? (double.tryParse(event.registrations.firstWhereOrNull((r) => '${r.memberId}_guest' == card.entryId)?.guestHandicap ?? '18.0') ?? 18.0)
          : (membersList.firstWhereOrNull((m) => m.id == card.entryId)?.handicap ?? 18.0),
      rules: rules,
      courseConfig: playerTeeConfig,
      baseRating: event.courseConfig.rating,
    );

    final result = ScoringCalculator.calculate(
      holeScores: card.holeScores, 
      holes: playerTeeConfig.holes, 
      playingHandicap: phc.toDouble(), 
      format: rules.format,
      maxScoreConfig: rules.maxScoreConfig,
    );
    
    // We reuse the logic from the processor for consistency
    final b9 = _getSegmentTotal(result, 9, 18);
    final b6 = _getSegmentTotal(result, 12, 18);
    final b3 = _getSegmentTotal(result, 15, 18);
    
    return 'B9: $b9 • B6: $b6 • B3: $b3';
  }

  int _getSegmentTotal(ScoringResult result, int startHole, int endHole) {
    int total = 0;
    for (int i = startHole - 1; i < endHole; i++) {
      if (i < result.holePoints.length) {
        total += result.holePoints[i] ?? 0;
      }
    }
    return total;
  }

  Scorecard? _getScorecard({RegistrationItem? item, EventRegistration? reg}) {
    if (item != null) {
      final expectedId = item.isGuest ? '${item.registration.memberId}_guest' : item.registration.memberId;
      try {
        return scorecards.firstWhere((s) => s.entryId == expectedId);
      } catch (_) {
        return null;
      }
    }
    
    if (reg != null) {
       final expectedId = reg.isGuest ? '${reg.memberId}_guest' : reg.memberId;
       try {
         return scorecards.firstWhere((s) => s.entryId == expectedId);
       } catch (_) {
         return null;
       }
    }
    return null;
  }
}

class TeamScoreGroup {
  final List<TeeGroupParticipant> players;
  final int index;
  final bool isPair;

  TeamScoreGroup({
    required this.players,
    required this.index,
    required this.isPair,
  });
}
