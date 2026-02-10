import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/competition.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../debug/presentation/state/debug_providers.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import 'course_info_card.dart';

class ScorecardModal {
  static void show(
    BuildContext context, 
    WidgetRef ref, {
    required LeaderboardEntry entry,
    required List<Scorecard> scorecards,
    required GolfEvent event,
    required Competition? comp,
    int? holeLimit,
    bool isAdmin = false,
  }) {
    // 1. Try to find a live scorecard
    Scorecard? scorecard = scorecards.firstWhereOrNull((s) => s.entryId == entry.entryId);
    
    // 2. Fallback: Reconstruct from seeded results if live scorecard is missing
    if (scorecard == null) {
      final seededResult = event.results.firstWhere(
        (r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString() == entry.entryId,
        orElse: () => {},
      );
      
      if (seededResult.isNotEmpty && seededResult['holeScores'] != null) {
        // Reconstruct temporary scorecard object
        scorecard = Scorecard(
          id: 'temp_${entry.entryId}',
          competitionId: event.id,
          roundId: '1',
          entryId: entry.entryId,
          submittedByUserId: 'system',
          status: ScorecardStatus.finalScore,
          holeScores: List<int?>.from(seededResult['holeScores']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          points: seededResult['points'] is num ? (seededResult['points'] as num).toInt() : null,
          netTotal: seededResult['netTotal'] is num ? (seededResult['netTotal'] as num).toInt() : null,
        );
      }
    }

    // 3. Final Bail if truly missing
    if (scorecard == null) return;

    final actualScorecard = scorecard;
    
    // Respect Lab Mode override
    final formatOverride = ref.read(gameFormatOverrideProvider);
    final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
    final isStableford = currentFormat == CompetitionFormat.stableford;
    
    final themeConfig = ref.read(themeControllerProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.playerName.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        Text(
                          'hc: ${entry.handicap.toStringAsFixed(1)} | phc: ${entry.playingHandicap ?? "-"}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (isAdmin)
                          IconButton(
                            icon: Icon(Icons.edit_note_rounded, color: Theme.of(context).primaryColor),
                            onPressed: () {
                              Navigator.pop(context); // Close modal
                              context.push('/admin/events/manage/${event.id}/scores/${entry.entryId}');
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Builder(
                    builder: (context) {
                      // Resolve effective rules/format for modal
                      final maxTypeOverride = ref.watch(maxScoreTypeOverrideProvider);
                      final maxValueOverride = ref.watch(maxScoreValueOverrideProvider);
                      
                      MaxScoreConfig? effectiveMaxScore = comp?.rules.maxScoreConfig;
                      if (currentFormat == CompetitionFormat.maxScore) {
                        if (maxTypeOverride != null) {
                           effectiveMaxScore = MaxScoreConfig(
                             type: maxTypeOverride,
                             value: maxValueOverride ?? (effectiveMaxScore?.value ?? 2),
                           );
                        }
                      }

                      return Column(
                        children: [
                          CourseInfoCard(
                            courseConfig: event.courseConfig,
                            selectedTeeName: event.selectedTeeName,
                            distanceUnit: themeConfig.distanceUnit,
                            isStableford: isStableford,
                            playerHandicap: entry.playingHandicap,
                            scores: actualScorecard.holeScores,
                            format: currentFormat,
                            maxScoreConfig: effectiveMaxScore,
                            holeLimit: holeLimit,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
