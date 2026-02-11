import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      data: (event) => Scaffold(
        appBar: BoxyArtAppBar(
          title: 'Edit Scorecard',
          subtitle: _getDisplayName(event, playerId),
          centerTitle: true,
          showBack: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              compAsync.when(
                data: (comp) {
                  final isStableford = comp?.rules.format == CompetitionFormat.stableford;
                  
                  // Calculate PHC for this player
                  final reg = event.registrations.firstWhere(
                    (r) => (r.isGuest ? '${r.memberId}_guest' : r.memberId) == playerId,
                    orElse: () => throw 'Registration not found',
                  );
                  
                  final double baseHcp = reg.isGuest 
                    ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                    : 18.0; // In a real app we'd fetch the member's actual handicap here
                    
                  final int phc = HandicapCalculator.calculatePlayingHandicap(
                    handicapIndex: baseHcp,
                    rules: comp?.rules ?? const CompetitionRules(),
                    courseConfig: event.courseConfig,
                  );

                  return Column(
                    children: [
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
              const SizedBox(height: 48),
            ],
          ),
        ),
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
}
