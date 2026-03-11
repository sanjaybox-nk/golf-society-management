import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
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
    final id = item.isGuest ? '${item.registration.memberId}_guest' : item.registration.memberId;

    // Resolve PHC for parity
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: BoxyArtScorecardTile(
        playerName: item.name,
        isConfirmed: isConfirmed,
        leading: BoxyArtNumberBadge(number: index, size: AppShapes.iconXl, isFilled: false),
        status: _buildMetadataRow(status, scorecard, baseHcp.toInt(), phc),
        score: _formatScore(scorecard, comp),
        trailingActions: _buildLockAction(ref, scorecard, item.name, status, isConfirmed),
        onTap: () => _showScorecardModal(context, ref, item, id, scorecard, comp),
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, WidgetRef ref, int index, TeamScoreGroup team, Competition? comp) {
    final names = team.players.map((p) => p.name).toList();
    final ids = team.players.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList();
    
    // For teams, we usually look for a scorecard with the teamId or use the first player's card as proxy if not Scramble
    // For simplicity in Admin List, we fetch the first available card to show status
    Scorecard? scorecard;
    for (final id in ids) {
      scorecard = scorecards.firstWhereOrNull((s) => s.entryId == id);
      if (scorecard != null) break;
    }
    
    // If Scramble, look for 'team_X' card
    if (scorecard == null && comp?.rules.format == CompetitionFormat.scramble) {
      scorecard = scorecards.firstWhereOrNull((s) => s.entryId == 'team_${team.index}');
    }

    final status = scorecard?.status ?? ScorecardStatus.draft;
    final isConfirmed = status == ScorecardStatus.reviewed || status == ScorecardStatus.finalScore;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: BoxyArtScorecardTile(
        playerName: names.first,
        secondaryPlayerName: names.length > 1 ? names[1] : null,
        avatarNames: names,
        isConfirmed: isConfirmed,
        leading: BoxyArtNumberBadge(number: index, size: AppShapes.iconXl, isFilled: false),
        status: _buildMetadataRow(status, scorecard, null, null), // TODO: Team PHC if needed
        score: _formatScore(scorecard, comp),
        trailingActions: _buildLockAction(ref, scorecard, names.join(' / '), status, isConfirmed),
        onTap: () {
           // For team tap, we show the first player's modal which handles team view
           final item = RegistrationLogic.getSortedItems(event, includeWithdrawn: true)
               .firstWhereOrNull((i) => i.name == names.first);
           if (item != null) {
              _showScorecardModal(context, ref, item, ids.first, scorecard, comp);
           }
        },
      ),
    );
  }

  Widget _buildMetadataRow(ScorecardStatus status, Scorecard? card, int? hcp, int? phc) {
    final isDraft = status == ScorecardStatus.draft;
    final isConfirmed = status == ScorecardStatus.reviewed || status == ScorecardStatus.finalScore;
    
    final label = isConfirmed ? 'CONFIRMED' : (status == ScorecardStatus.submitted ? 'PENDING' : 'OPEN');
    final color = isConfirmed ? StatusColors.positive : (status == ScorecardStatus.submitted ? StatusColors.warning : StatusColors.neutral);

    final holesPlayed = card?.holeScores.where((s) => s != null).length ?? 0;
    final showThru = !isConfirmed && holesPlayed > 0 && holesPlayed < 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BoxyArtPill.status(label: label, color: color),
            if (showThru) ...[
              const SizedBox(width: AppSpacing.sm),
              _buildProMaxLabel('THRU $holesPlayed', AppColors.lime500),
            ],
          ],
        ),
        if (hcp != null && phc != null)
           Padding(
             padding: const EdgeInsets.only(top: 6),
             child: Row(
               children: [
                 _buildProMaxLabel('HC: $hcp', AppColors.dark150),
                 const SizedBox(width: AppSpacing.sm),
                 _buildProMaxLabel('PHC: $phc', AppColors.lime500),
               ],
             ),
           ),
        if (!isDraft && card?.submittedAt != null) ...[
          const SizedBox(height: 6),
          _buildProMaxLabel('SUBMITTED ${DateFormat('HH:mm').format(card!.submittedAt!)}', AppColors.dark60),
        ],
      ],
    );
  }

  Widget _buildProMaxLabel(String text, Color color) {
    return Text(
      text,
      style: AppTypography.label.copyWith(
        fontSize: AppTypography.sizeCaption,
        color: color,
        fontWeight: AppTypography.weightBlack,
        letterSpacing: 2.0,
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
      debugPrint('❌ Scorecard Status Error: $e');
    }
  }

  // _resolvePlayerCourseConfig removed as we now use ScoringCalculator

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
