import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/guest_id_helper.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../events/presentation/widgets/course_info_card.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'widgets/admin_scorecard_keypad.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';

// Local provider for the current hole being edited
class AdminEditorHoleNotifier extends Notifier<int> {
  @override
  int build() => 1;
  @override
  set state(int value) => super.state = value;
}

final adminEditorHoleProvider = NotifierProvider.autoDispose<AdminEditorHoleNotifier, int>(AdminEditorHoleNotifier.new);

class EventAdminScorecardEditorScreen extends ConsumerWidget {
  final String eventId;
  final String playerId;

  const EventAdminScorecardEditorScreen({
    super.key,
    required this.eventId,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final scorecard = ref.watch(scorecardByEntryIdProvider((competitionId: eventId, entryId: playerId)));
    final config = ref.watch(themeControllerProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final membersAsync = ref.watch(allMembersProvider);
    final members = membersAsync.value ?? [];
    
    final currentHole = ref.watch(adminEditorHoleProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) => HeadlessScaffold(
        title: 'Scorecard Editor',
        topPill: BoxyArtPill.committee(label: 'ADMIN'),
        subtitle: _getDisplayName(event, playerId),
        showBack: true,
 // Nested in EventAdminShell
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.x5l),
            sliver: SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) {
                  final isStableford = comp?.rules.format == CompetitionFormat.stableford;
                  
                  // Calculate PHC for this player
                  final reg = event.registrations.firstWhere(
                    (r) => GuestIdHelper.buildId(r.memberId, isGuest: r.isGuest) ==playerId,
                    orElse: () => event.registrations.firstWhereOrNull((r) => r.memberId == playerId) ?? 
                                  EventRegistration(memberId: playerId, memberName: 'Unknown Player', attendingGolf: true),
                  );
                  
                  final double baseHcp = reg.isGuest 
                    ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                    : (reg.handicap ?? 18.0); 
                    
                  final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                    memberId: reg.memberId, 
                    event: event, 
                    membersList: members,
                  );
                  final playerTeeName = (members.firstWhereOrNull((m) => m.id == reg.memberId)?.gender?.toLowerCase() == 'female')
                      ? (event.selectedFemaleTeeName ?? 'Red')
                      : (event.selectedTeeName ?? 'Yellow');

                  final int phc = HandicapCalculator.calculatePlayingHandicap(
                    handicapIndex: baseHcp,
                    rules: comp?.rules ?? const CompetitionRules(),
                    courseConfig: playerTeeConfig,
                  );

                  // [NEW] Authoritative Calculation for Display
                  final scoringResult = ScoringCalculator.calculate(
                    holeScores: scorecard?.holeScores ?? List.filled(18, null),
                    holes: playerTeeConfig.holes,
                    playingHandicap: phc.toDouble(),
                    format: comp?.rules.format ?? CompetitionFormat.stableford,
                    maxScoreConfig: comp?.rules.maxScoreConfig,
                  );

                  return Column(
                    children: [
                      // Player Info Row
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                        child: Row(
                          children: [
                            BoxyArtIndicator.hc(label: _formatHcp(baseHcp)),
                            const SizedBox(width: AppSpacing.md),
                            BoxyArtIndicator.phc(context: context, label: '$phc'),
                            const Spacer(),
                            // Tee pill matching design
                            BoxyArtPill.tee(label: playerTeeName, teeColor: _getTeeColor(playerTeeName, playerTeeConfig.tees)),
                          ],
                        ),
                      ),
                      
                      // Scorecard Grid
                      CourseInfoCard(
                        courseConfig: playerTeeConfig,
                        selectedTeeName: playerTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        holeScores: scoringResult.holeScores,
                        holeNetScores: scoringResult.holeNetScores,
                        holePoints: scoringResult.holePoints,
                        format: comp?.rules.format ?? CompetitionFormat.stableford,
                        maxScoreConfig: comp?.rules.maxScoreConfig,
                      ),
                      
                      SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                      
                      // Admin Keypad - Wrapped in Card for Design 4.x
                      BoxyArtCard(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: AdminScorecardKeypad(
                          currentHole: currentHole,
                          scores: _getHoleScores(scorecard),
                          onHoleChanged: (h) => ref.read(adminEditorHoleProvider.notifier).state = h,
                          onSetScore: (h, score) => _persistScore(context, ref, h, score, scorecard, event),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
    );
  }

  Map<int, int> _getHoleScores(Scorecard? card) {
    if (card == null) return {};
    final map = <int, int>{};
    for (int i = 0; i < card.holeScores.length; i++) {
      final score = card.holeScores[i];
      if (score != null) {
        map[i + 1] = score;
      }
    }
    return map;
  }

  Future<void> _persistScore(BuildContext context, WidgetRef ref, int hole, int score, Scorecard? currentCard, GolfEvent event) async {
    try {
      final repo = ref.read(scorecardRepositoryProvider);
      final userId = ref.read(currentUserProvider).id;
      
      final List<int?> scores = List<int?>.from(currentCard?.holeScores ?? List.filled(18, null));
      scores[hole - 1] = score;
      
      final grossTotal = scores.whereType<int>().fold<int>(0, (a, b) => a + b);

      if (currentCard == null) {
        final newCard = Scorecard(
          id: '', // Repo generates ID
          competitionId: eventId,
          roundId: 'round_1',
          entryId: playerId,
          submittedByUserId: userId,
          holeScores: scores,
          playerVerifierScores: [],
          shotAttributions: {},
          grossTotal: grossTotal,
          status: ScorecardStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.addScorecard(newCard);
      } else {
        final updatedCard = currentCard.copyWith(
          holeScores: scores,
          grossTotal: grossTotal,
          updatedAt: DateTime.now(),
        );
        await repo.updateScorecard(updatedCard);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving score: $e'), backgroundColor: AppColors.coral500),
      );
    }
  }

  String _getDisplayName(GolfEvent event, String id) {
    try {
      final reg = event.registrations.firstWhere(
        (r) => GuestIdHelper.buildId(r.memberId, isGuest: r.isGuest) ==id,
      );
      return reg.displayName;
    } catch (_) {
      return 'Unknown Player';
    }
  }

  String _formatHcp(double hcp) {
    return hcp.truncateToDouble() == hcp ? hcp.toInt().toString() : hcp.toStringAsFixed(1);
  }

  Color _getTeeColor(String teeName, [List<TeeConfig>? teeConfigs]) {
    return AppColors.getTeeColor(teeName, teeConfigs);
  }

  // _resolvePlayerCourseConfig removed as we now use ScoringCalculator
}
