
import 'package:flutter/material.dart';
import '../../domain/match_definition.dart';

class MatchStatusHeader extends StatelessWidget {
  final MatchResult result;
  final String? team1Name; // Optional override
  final String? team2Name; // Optional override

  const MatchStatusHeader({
    super.key,
    required this.result,
    this.team1Name,
    this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    if (result.holesPlayed == 0) return const SizedBox.shrink();

    // Determine color based on status
    Color statusColor = Colors.grey;
    if (result.status.contains('UP') || result.status.contains('&')) {
       // Someone is winning - use accent color (e.g. Blue or Red) unless we know who is "Me"
       // For simple neutral view:
       statusColor = Colors.blueAccent; 
    } else if (result.status == 'A/S') {
       statusColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.handshake, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'MATCH STATUS: ',
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey[700],
              letterSpacing: 1.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              result.status,
              style: const TextStyle(
                fontSize: 12,
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
