import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/competition.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../events/presentation/widgets/course_info_card.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'widgets/admin_scorecard_keypad.dart';

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
    final scorecardAsync = ref.watch(scorecardByEntryIdProvider((competitionId: eventId, entryId: playerId)));
    final config = ref.watch(themeControllerProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final membersAsync = ref.watch(allMembersProvider);
    final members = membersAsync.value ?? [];
    
    final currentHole = ref.watch(adminEditorHoleProvider);

    return eventAsync.when(
      data: (event) => HeadlessScaffold(
        title: 'Manage Scorecard',
        subtitle: _getDisplayName(event, playerId),
        showBack: true,
        useScaffold: false, // Nested in EventAdminShell
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
            sliver: SliverToBoxAdapter(
              child: compAsync.when(
                data: (comp) {
                  final isStableford = comp?.rules.format == CompetitionFormat.stableford;
                  
                  // Calculate PHC for this player
                  final reg = event.registrations.firstWhere(
                    (r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == playerId,
                    orElse: () => event.registrations.firstWhereOrNull((r) => r.memberId == playerId) ?? 
                                  EventRegistration(memberId: playerId, memberName: 'Unknown Player', attendingGolf: true),
                  );
                  
                  final double baseHcp = reg.isGuest 
                    ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                    : (reg.handicap ?? 18.0); 
                    
                  final playerTeeConfig = _resolvePlayerCourseConfig(reg.memberId, event, members);
                  final playerTeeName = (members.firstWhereOrNull((m) => m.id == reg.memberId)?.gender?.toLowerCase() == 'female')
                      ? (event.selectedFemaleTeeName ?? 'Red')
                      : (event.selectedTeeName ?? 'Yellow');

                  final int phc = HandicapCalculator.calculatePlayingHandicap(
                    handicapIndex: baseHcp,
                    rules: comp?.rules ?? CompetitionRules(),
                    courseConfig: playerTeeConfig,
                  );

                  return Column(
                    children: [
                      // Player Info Row
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          children: [
                            BoxyArtPill.hc(label: _formatHcp(baseHcp)),
                            const SizedBox(width: 8),
                            BoxyArtPill.phc(label: '$phc'),
                            const Spacer(),
                            // Tee pill matching design
                            BoxyArtPill.tee(label: playerTeeName, teeColor: _getTeeColor(playerTeeName)),
                          ],
                        ),
                      ),
                      
                      // Scorecard Grid
                      CourseInfoCard(
                        courseConfig: playerTeeConfig,
                        selectedTeeName: playerTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        playerHandicap: phc,
                        scores: scorecardAsync?.holeScores ?? [],
                        format: comp?.rules.format ?? CompetitionFormat.stableford,
                        maxScoreConfig: comp?.rules.maxScoreConfig,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Admin Keypad
                      AdminScorecardKeypad(
                        currentHole: currentHole,
                        scores: _getHoleScores(scorecardAsync),
                        onHoleChanged: (h) => ref.read(adminEditorHoleProvider.notifier).state = h,
                        onSetScore: (h, score) => _persistScore(context, ref, h, score, scorecardAsync, event),
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
        SnackBar(content: Text('Error saving score: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getDisplayName(GolfEvent event, String id) {
    try {
      final reg = event.registrations.firstWhere(
        (r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == id,
      );
      return reg.displayName;
    } catch (_) {
      return 'Unknown Player';
    }
  }

  String _formatHcp(double hcp) {
    return hcp.truncateToDouble() == hcp ? hcp.toInt().toString() : hcp.toStringAsFixed(1);
  }

  Color _getTeeColor(String teeName) {
    final name = teeName.toLowerCase();
    if (name.contains('white')) return Colors.grey.shade400;
    if (name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('red')) return const Color(0xFFFF4D4D);
    if (name.contains('blue')) return const Color(0xFF1E90FF);
    if (name.contains('black')) return const Color(0xFF2F2F2F);
    return Colors.grey;
  }

  Map<String, dynamic> _resolvePlayerCourseConfig(String memberId, GolfEvent event, List<Member> membersList) {
    final tees = event.courseConfig['tees'] as List?;
    if (tees == null || tees.isEmpty) return event.courseConfig;

    final member = membersList.firstWhereOrNull((m) => m.id == memberId);
    final gender = member?.gender?.toLowerCase() ?? 'male';
    
    Map<String, dynamic>? selectedTee;
    if (gender == 'female') {
       if (event.selectedFemaleTeeName != null) {
         selectedTee = (tees.firstWhereOrNull((t) => 
           (t['name'] ?? '').toString().toLowerCase() == event.selectedFemaleTeeName!.toLowerCase()
         ) as Map<String, dynamic>?);
       }
    }
    
    selectedTee ??= (tees.firstWhereOrNull((t) => 
       (t['name'] ?? '').toString().toLowerCase() == (event.selectedTeeName ?? 'white').toLowerCase()
    ) as Map<String, dynamic>?);

    selectedTee ??= (tees.first as Map<String, dynamic>);

    return {
       ...event.courseConfig,
       'par': selectedTee['par'] ?? selectedTee['holePars']?.fold(0, (a, b) => (a as int) + (b as int)) ?? 72,
       'rating': selectedTee['rating'] ?? 72.0,
       'slope': selectedTee['slope'] ?? 113,
       'holes': List.generate(18, (i) => {
          'hole': i + 1,
          'par': (selectedTee!['holePars'] as List?)?.elementAt(i) ?? 4,
          'si': (selectedTee['holeSIs'] as List?)?.elementAt(i) ?? 18,
       }),
    };
  }
}
