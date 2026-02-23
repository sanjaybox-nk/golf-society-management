import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../models/golf_event.dart';
import '../../../../../models/member.dart';
import '../../../../../models/scorecard.dart';
import '../../../../../models/event_registration.dart';
import '../../../../competitions/presentation/competitions_provider.dart';
import '../../../../../core/utils/handicap_calculator.dart';
import '../../../../../models/competition.dart';
import '../../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../../events/presentation/widgets/scorecard_modal.dart';

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
    
    // Filter down to only those playing golf
    final golfers = event.registrations.where((r) => 
      r.attendingGolf && (r.isConfirmed || r.guestIsConfirmed)
    ).toList();
    
    // Sort: Submitted first, then by name
    golfers.sort((a, b) {
      final aHasScore = _getScorecard(a) != null;
      final bHasScore = _getScorecard(b) != null;
      if (aHasScore != bHasScore) return bHasScore ? 1 : -1;
      return a.displayName.compareTo(b.displayName);
    });

    if (golfers.isEmpty) {
      return const BoxyArtFloatingCard(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No confirmed golfers found for this event.'),
          ),
        ),
      );
    }

    return Column(
      children: golfers.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final reg = entry.value;
        final scorecard = _getScorecard(reg);
        final isSubmitted = scorecard?.status == ScorecardStatus.submitted || 
                            scorecard?.status == ScorecardStatus.finalScore;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BoxyArtFloatingCard(
            onTap: () {
              final id = reg.isGuest ? '${reg.memberId}_guest' : reg.memberId;
              final comp = compAsync.value;
              final member = membersList.firstWhereOrNull((m) => m.id == reg.memberId);
              final double baseHcp = reg.isGuest 
                ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                : (member?.handicap ?? 18.0); 
              
              final playerTeeConfig = _resolvePlayerCourseConfig(id, event, membersList);
              final baseRating = (event.courseConfig['rating'] as num?)?.toDouble() ?? 72.0;

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
                  playerName: reg.displayName,
                  handicap: baseHcp.toInt(),
                  playingHandicap: phc,
                  score: scorecard?.points ?? 0,
                  isGuest: reg.isGuest,
                ), 
                scorecards: scorecards, 
                event: event, 
                comp: comp,
                membersList: membersList,
                isAdmin: true,
              );
            },
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // Position Index
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text('$index', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                ),
                const SizedBox(width: 8),

                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    reg.displayName.isNotEmpty ? reg.displayName[0] : '?',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reg.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: -0.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        reg.isGuest ? 'Guest' : 'Member',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusPill(context, isSubmitted),
                    ],
                  ),
                ),

                // Scores
                if (scorecard != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${scorecard.points}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 18, 
                            color: Theme.of(context).primaryColor,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          'PTS',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 7, color: Colors.grey, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),

                // Handicap column
                compAsync.when(
                  data: (comp) {
                    final member = membersList.firstWhereOrNull((m) => m.id == reg.memberId);
                    final double baseHcp = reg.isGuest 
                      ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                      : (member?.handicap ?? 18.0); 
                    
                    final id = reg.isGuest ? '${reg.memberId}_guest' : reg.memberId;
                    final playerTeeConfig = _resolvePlayerCourseConfig(id, event, membersList);
                    final baseRating = (event.courseConfig['rating'] as num?)?.toDouble() ?? 72.0;

                    final phc = HandicapCalculator.calculatePlayingHandicap(
                      handicapIndex: baseHcp,
                      rules: comp?.rules ?? const CompetitionRules(),
                      courseConfig: playerTeeConfig,
                      baseRating: baseRating,
                    );
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$phc',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '(${baseHcp.toStringAsFixed(1)})',
                          style: TextStyle(fontSize: 8, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),

                const SizedBox(width: 8),

                // Controls
                if (scorecard != null)
                  IconButton(
                    icon: Icon(
                      isSubmitted ? Icons.lock_rounded : Icons.lock_open_rounded, 
                      color: isSubmitted ? Colors.red.withValues(alpha: 0.7) : Colors.green, 
                      size: 20
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      try {
                        final newStatus = isSubmitted ? ScorecardStatus.draft : ScorecardStatus.submitted;
                        await ref.read(scorecardRepositoryProvider).updateScorecardStatus(
                          scorecard.id,
                          newStatus,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Scorecard for ${reg.displayName} marked as ${newStatus == ScorecardStatus.draft ? "Open" : "Submitted"}.')),
                          );
                        }
                      } catch (e) {
                        debugPrint('❌ Scorecard Status Update Error: $e');
                        if (context.mounted) {
                          final errorMsg = 'Error updating status (ID: ${scorecard.id}): $e';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMsg),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 10),
                              action: SnackBarAction(
                                label: 'COPY',
                                textColor: Colors.white,
                                onPressed: () {
                                  // Simplified copy if needed, but usually just for reading
                                },
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).primaryColor.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Scorecard? _getScorecard(EventRegistration reg) {
    // Handle Guest Logic: Guest ID is typically "memberId_guest" for legacy reasons or we match by name?
    // In seeding, we used "memberId_guest" for guests.
    final expectedId = reg.isGuest ? '${reg.memberId}_guest' : reg.memberId;
    
    // Find matching scorecard
    try {
      return scorecards.firstWhere((s) => s.entryId == expectedId);
    } catch (_) {
      return null;
    }
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
       selectedTee ??= (tees.firstWhereOrNull((t) => 
         (t['name'] ?? '').toString().toLowerCase().contains('red') || 
         (t['name'] ?? '').toString().toLowerCase().contains('lady') ||
         (t['name'] ?? '').toString().toLowerCase().contains('female')
       ) as Map<String, dynamic>?);
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

  Widget _buildStatusPill(BuildContext context, bool isSubmitted) {
    Color color = isSubmitted ? Colors.green : Colors.orange;
    String text = isSubmitted ? 'DONE' : 'PENDING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
