import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/models/event_registration.dart';

import '../../../../core/shared_ui/headless_scaffold.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../events/presentation/widgets/course_info_card.dart';
import '../../../events/presentation/widgets/hole_by_hole_scoring_widget.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../models/competition.dart';
import '../../../../core/utils/handicap_calculator.dart';

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

    return eventAsync.when(
      data: (event) => HeadlessScaffold(
        title: 'Scorecard',
        subtitle: _getDisplayName(event, playerId),
        showBack: true,
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
                    
                  final int phc = HandicapCalculator.calculatePlayingHandicap(
                    handicapIndex: baseHcp,
                    rules: comp?.rules ?? const CompetitionRules(),
                    courseConfig: event.courseConfig,
                  );

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Handicap Info
                            Row(
                              children: [
                                Text(
                                  'HC: ${_formatHcp(baseHcp)}', 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: Colors.grey.shade600, 
                                    fontWeight: FontWeight.w600
                                  )
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4, 
                                  height: 4, 
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300, 
                                    shape: BoxShape.circle
                                  )
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'PHC: $phc', 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: Theme.of(context).primaryColor, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CourseInfoCard(
                        courseConfig: event.courseConfig,
                        selectedTeeName: event.selectedTeeName,
                        distanceUnit: config.distanceUnit,
                        isStableford: isStableford,
                        playerHandicap: phc,
                        scores: scorecardAsync?.holeScores ?? [],
                        format: comp?.rules.format ?? CompetitionFormat.stableford,
                        maxScoreConfig: comp?.rules.maxScoreConfig,
                      ),
                      const SizedBox(height: 24),
                      HoleByHoleScoringWidget(
                        event: event,
                        targetScorecard: scorecardAsync,
                        targetEntryId: playerId,
                        isSelfMarking: true, 
                        isAdmin: true, // Master Key for Admins
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
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
}
