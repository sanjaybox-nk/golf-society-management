import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../models/golf_event.dart';
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

  const AdminScorecardList({
    super.key,
    required this.event,
    required this.scorecards,
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
              final double baseHcp = reg.isGuest 
                ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                : 18.0; 
              
              final phc = HandicapCalculator.calculatePlayingHandicap(
                handicapIndex: baseHcp,
                rules: comp?.rules ?? const CompetitionRules(),
                courseConfig: event.courseConfig,
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
                isAdmin: true,
              );
            },
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // Position Index
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Text('$index', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                    final double baseHcp = reg.isGuest 
                      ? (double.tryParse(reg.guestHandicap ?? '18.0') ?? 18.0)
                      : 18.0; 
                    
                    final phc = HandicapCalculator.calculatePlayingHandicap(
                      handicapIndex: baseHcp,
                      rules: comp?.rules ?? const CompetitionRules(),
                      courseConfig: event.courseConfig,
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
                const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
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
