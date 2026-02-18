import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/competition.dart';
import '../../../../models/member.dart';
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
    List<Member> membersList = const [],
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

    // Resolve gender-specific course config for this player
    final resolvedCourseConfig = _resolvePlayerCourseConfig(entry.entryId, event, membersList);

    // Determine if this entry is a guest
    final bool isGuest = entry.isGuest || entry.entryId.endsWith('_guest');

    // Dynamic Height Adjustment for Team/Multiple Names
    final nameCount = entry.teamMemberNames?.length ?? 1;
    final isTeamDisplay = nameCount > 1;
    
    // "Come out further" -> Increase initial height if header is tall
    final double dynamicInitialSize = isTeamDisplay ? 0.70 : 0.55;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: dynamicInitialSize,
        minChildSize: 0.45,
        maxChildSize: 0.95,
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
                    Expanded( // Constrain width to prevent overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Player Name(s) + Guest Pill
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (entry.teamMemberNames != null && entry.teamMemberNames!.isNotEmpty)
                                      ...entry.teamMemberNames!.map((name) => Padding(
                                        padding: const EdgeInsets.only(bottom: 2.0),
                                        child: Text(
                                          name.toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.1),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                    else
                                      Text(
                                        entry.playerName.toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (isGuest) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.amber.shade600, width: 1),
                                  ),
                                  child: Text(
                                    'GUEST',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            () {
                              final isTeam = entry.mode != CompetitionMode.singles;
                              final hcLabel = isTeam ? 'team hc' : 'hc';
                              final phcLabel = isTeam ? 'team phc' : 'phc';
                              return '$hcLabel: ${entry.handicap} | $phcLabel: ${entry.playingHandicap ?? "-"}';
                            }(),
                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min, // Keep minimal width
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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

                      // [NEW] Logic for Team/Pairs Display
                      List<CourseScoreRow>? additionalRows;
                      List<int?>? mainScores = actualScorecard.holeScores;

                      if (entry.teamMemberIds != null && entry.teamMemberIds!.isNotEmpty) {
                         additionalRows = [];
                         for (int i = 0; i < entry.teamMemberIds!.length; i++) {
                            final id = entry.teamMemberIds![i];
                            final name = (entry.teamMemberNames != null && i < entry.teamMemberNames!.length) 
                                ? entry.teamMemberNames![i] 
                                : 'Player ${i+1}';
                            
                            // Find card for this member
                            Scorecard? card = scorecards.firstWhereOrNull((s) => s.entryId == id);
                            
                            // Fallback for seeded data
                            if (card == null) {
                               final seeded = event.results.firstWhere(
                                 (r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString() == id,
                                 orElse: () => {},
                               );
                               if (seeded.isNotEmpty && seeded['holeScores'] != null) {
                                  card = Scorecard(
                                    id: 'temp_$id',
                                    competitionId: event.id,
                                    roundId: '1',
                                    entryId: id,
                                    submittedByUserId: 'system',
                                    status: ScorecardStatus.finalScore,
                                    holeScores: List<int?>.from(seeded['holeScores']),
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );
                               }
                            }

                            if (card != null) {
                               // [NEW] Resolve which holes this player counted in
                               final Set<int> memberCountingHoles = {};
                               if (entry.countingMemberIds != null) {
                                  entry.countingMemberIds!.forEach((holeIdx, memberId) {
                                     if (memberId == id) {
                                        memberCountingHoles.add(holeIdx);
                                     }
                                  });
                               }

                               additionalRows.add(CourseScoreRow(
                                 id: id,
                                 playerName: name,
                                 scores: card.holeScores,
                                 handicap: null, // Todo: pipe through individual PHC
                                 color: i == 0 ? Colors.blue[800] : Colors.green[800],
                                 countingHoles: memberCountingHoles,
                               ));
                            }
                         }
                      }

                      return Column(
                        children: [
                          CourseInfoCard(
                            courseConfig: resolvedCourseConfig,
                            selectedTeeName: _resolvedTeeName(entry.entryId, event, membersList),
                            distanceUnit: themeConfig.distanceUnit,
                            isStableford: isStableford,
                            playerHandicap: entry.playingHandicap,
                            scores: mainScores,
                            additionalRows: additionalRows, // [NEW] Pass rows
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

  /// Resolves the correct course config (holes/par/SI) for a player based on their gender.
  static Map<String, dynamic> _resolvePlayerCourseConfig(
    String memberId,
    GolfEvent event,
    List<Member> membersList,
  ) {
    final tees = event.courseConfig['tees'] as List?;
    if (tees == null || tees.isEmpty) return event.courseConfig;

    final member = membersList.firstWhereOrNull((m) => m.id == memberId);
    final gender = member?.gender?.toLowerCase() ?? 'male';

    Map<String, dynamic>? selectedTee;

    // 1. Try explicit gender defaults set by admin
    if (gender == 'female') {
      final ladiesTeeName = event.courseConfig['ladiesTeeName']?.toString();
      if (ladiesTeeName != null) {
        selectedTee = (tees.firstWhereOrNull((t) =>
          (t['name'] ?? '').toString().toLowerCase() == ladiesTeeName.toLowerCase()
        ) as Map<String, dynamic>?);
      }
      // Fallback: auto-detect red/lady tee
      selectedTee ??= (tees.firstWhereOrNull((t) =>
        (t['name'] ?? '').toString().toLowerCase().contains('red') ||
        (t['name'] ?? '').toString().toLowerCase().contains('lady') ||
        (t['name'] ?? '').toString().toLowerCase().contains('female')
      ) as Map<String, dynamic>?);
    } else {
      final mensTeeName = event.courseConfig['mensTeeName']?.toString();
      if (mensTeeName != null) {
        selectedTee = (tees.firstWhereOrNull((t) =>
          (t['name'] ?? '').toString().toLowerCase() == mensTeeName.toLowerCase()
        ) as Map<String, dynamic>?);
      }
    }

    // 2. Fallback: event baseline tee
    selectedTee ??= (tees.firstWhereOrNull((t) =>
      (t['name'] ?? '').toString().toLowerCase() == (event.selectedTeeName ?? 'white').toLowerCase()
    ) as Map<String, dynamic>?);

    // 3. Final fallback: first tee
    selectedTee ??= (tees.first as Map<String, dynamic>);

    return {
      ...event.courseConfig,
      'par': selectedTee['par'] ?? (selectedTee['holePars'] as List?)?.fold<int>(0, (a, b) => a + (b as int)) ?? 72,
      'rating': selectedTee['rating'] ?? 72.0,
      'slope': selectedTee['slope'] ?? 113,
      'holes': List.generate(18, (i) => {
        'hole': i + 1,
        'par': (selectedTee!['holePars'] as List?)?.elementAt(i) ?? 4,
        'si': (selectedTee['holeSIs'] as List?)?.elementAt(i) ?? 18,
        'yardage': (selectedTee['yardages'] as List?)?.elementAtOrNull(i) ?? 0,
      }),
    };
  }

  /// Returns the display name of the resolved tee for this player.
  static String? _resolvedTeeName(
    String memberId,
    GolfEvent event,
    List<Member> membersList,
  ) {
    final tees = event.courseConfig['tees'] as List?;
    if (tees == null || tees.isEmpty) return event.selectedTeeName;

    final member = membersList.firstWhereOrNull((m) => m.id == memberId);
    final gender = member?.gender?.toLowerCase() ?? 'male';

    if (gender == 'female') {
      final ladiesTeeName = event.courseConfig['ladiesTeeName']?.toString();
      if (ladiesTeeName != null) return ladiesTeeName;
      final autoTee = (tees.firstWhereOrNull((t) =>
        (t['name'] ?? '').toString().toLowerCase().contains('red') ||
        (t['name'] ?? '').toString().toLowerCase().contains('lady')
      ) as Map<String, dynamic>?);
      if (autoTee != null) return autoTee['name']?.toString();
    } else {
      final mensTeeName = event.courseConfig['mensTeeName']?.toString();
      if (mensTeeName != null) return mensTeeName;
    }

    return event.selectedTeeName;
  }
}
