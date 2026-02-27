import 'package:golf_society/design_system/design_system.dart';

import '../../domain/match_definition.dart';

class MatchStatusHeader extends StatelessWidget {
  final MatchDefinition? match;
  final MatchResult result;
  final String? team1Name; // Optional override
  final String? team2Name; // Optional override

  const MatchStatusHeader({
    super.key,
    this.match,
    required this.result,
    this.team1Name,
    this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    if (result.holesPlayed == 0 && match == null) return const SizedBox.shrink();

    // Calculate strokes given info
    String? strokesInfo;
    if (match != null) {
      if (match!.type == MatchType.singles && match!.team1Ids.length == 1 && match!.team2Ids.length == 1) {
        final s1 = match!.strokesReceived[match!.team1Ids.first] ?? 0;
        final s2 = match!.strokesReceived[match!.team2Ids.first] ?? 0;
        if (s1 != s2) {
          final diff = (s1 - s2).abs();
          final receiver = s1 > s2 ? (team1Name ?? 'Side A') : (team2Name ?? 'Side B');
          strokesInfo = '$receiver receives $diff strokes';
        }
      } else if (match!.type == MatchType.fourball || match!.type == MatchType.foursomes) {
        strokesInfo = 'Net handicaps applied per SI';
      }
    }

    // Determine color based on status
    Color statusColor = Colors.grey;
    if (result.status.contains('UP') || result.status.contains('&')) {
      statusColor = Colors.blueAccent;
    } else if (result.status == 'A/S') {
      statusColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20), // [FIX] Align with HoleByHoleScoringWidget padding
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          // Left: Strokes Info / Subtext
          Expanded(
            child: Text(
              strokesInfo ?? 'Match Status', // Fallback label if no strokes info
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Right: Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              result.status,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
