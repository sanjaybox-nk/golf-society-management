import 'package:flutter/material.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/shared_ui/modern_cards.dart';

class MemberStatsRow extends StatelessWidget {
  final int starts;
  final int wins;
  final int top5;
  final double avgPts;
  final int bestPts;
  final int? rank;

  const MemberStatsRow({
    super.key,
    required this.starts,
    required this.wins,
    required this.top5,
    required this.avgPts,
    required this.bestPts,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: ModernCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        borderRadius: 24,
        child: Row(
          children: [
            if (wins > 0) ...[
              Expanded(child: _StatItem(label: 'WINS', value: '$wins', isHighlight: true)),
              _Divider(),
            ],
            Expanded(child: _StatItem(label: 'TOP 5', value: '$top5')),
            _Divider(),
            Expanded(child: _StatItem(label: 'AVG PTS', value: avgPts.toStringAsFixed(1))),
            _Divider(),
            Expanded(child: _StatItem(label: 'BEST', value: '$bestPts')),
            _Divider(),
            Expanded(child: _StatItem(label: 'RANK', value: rank != null ? '#$rank' : '-')),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _StatItem({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: isHighlight ? const Color(0xFFFFD700) : Theme.of(context).colorScheme.onSurface, // Gold for wins
            shadows: isHighlight ? [
              Shadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: Offset(0, 2))
            ] : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }
}
