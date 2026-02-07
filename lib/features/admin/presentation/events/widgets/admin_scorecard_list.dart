import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../models/golf_event.dart';
import '../../../../../models/scorecard.dart';
import '../../../../../models/event_registration.dart';

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
      children: golfers.map((reg) {
        final scorecard = _getScorecard(reg);
        final isSubmitted = scorecard?.status == ScorecardStatus.submitted || 
                            scorecard?.status == ScorecardStatus.finalScore;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BoxyArtFloatingCard(
            onTap: () {
               // TODO: Navigate to Score Entry or open modal
               // For now, we'll just show a snackbar
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Editing score for ${reg.displayName} coming soon')),
               );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      reg.displayName.isNotEmpty ? reg.displayName[0] : '?',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reg.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (reg.isGuest)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('GUEST', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  if (scorecard != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${scorecard.points} pts',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          scorecard.grossTotal != null ? '${scorecard.grossTotal} Gross' : '-',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                  const SizedBox(width: 12),
                  _buildStatusPill(context, isSubmitted),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSubmitted ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isSubmitted ? 'DONE' : 'PENDING',
        style: TextStyle(
          color: isSubmitted ? Colors.green : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
