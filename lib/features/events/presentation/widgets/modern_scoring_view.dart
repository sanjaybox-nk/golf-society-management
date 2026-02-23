import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../models/competition.dart';
import '../../../../models/golf_event.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../../core/shared_ui/modern_cards.dart';

class ModernScoringView extends StatelessWidget {
  final GolfEvent event;
  final Map<int, int> scores;
  final int currentHole;
  final List<dynamic> holes;
  final int playerPhc;
  final String markingName; // [NEW] Clear identification
  final MatchResult? matchResult;
  final bool isTeam1;
  final ValueChanged<int> onHoleChanged;
  final Function(int hole, int score) onSetScore;
  final VoidCallback onShowFullCard;
  final CompetitionFormat format;
  final MaxScoreConfig? maxScoreConfig;
  final CompetitionRules? rules;

  const ModernScoringView({
    super.key,
    required this.event,
    required this.scores,
    required this.currentHole,
    required this.holes,
    required this.playerPhc,
    required this.markingName,
    this.matchResult,
    required this.onHoleChanged,
    required this.onSetScore,
    required this.onShowFullCard,
    this.format = CompetitionFormat.stableford,
    this.maxScoreConfig,
    this.rules,
    this.isTeam1 = true,
  });

  @override
  Widget build(BuildContext context) {
    final holeData = holes.length >= currentHole ? holes[currentHole - 1] : null;
    final par = (holeData?['par'] as num?)?.toInt() ?? 4;
    final si = (holeData?['si'] as num?)?.toInt();
    final score = scores[currentHole] ?? par;
    final cap = _calculateCap(par, si);

    return Column(
      children: [
        // Hole Ribbon
        _buildHoleRibbon(context),
        
        const SizedBox(height: 12),

        // Marking Info Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'MARKING: ${markingName.toUpperCase()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
              letterSpacing: 1.0,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Hero Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHeroCard(context, par, si, score, cap),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Keypad
        _buildKeypad(context, par, score, cap),
      ],
    );
  }

  Widget _buildHoleRibbon(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final holeNum = index + 1;
          final isSelected = holeNum == currentHole;
          final hasScore = scores.containsKey(holeNum);

          return GestureDetector(
            onTap: () => onHoleChanged(holeNum),
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.2),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$holeNum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (hasScore && !isSelected)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, int par, int? si, int score, int? cap) {
    // 1. Calculate Stableford Points
    int pts = 0;
    if (si != null) {
      final strokesReceived = (playerPhc / 18).floor() + (playerPhc % 18 >= si ? 1 : 0);
      final netScore = score - strokesReceived;
      pts = (par - netScore + 2).clamp(0, 8);
    }

    // 2. Determine Match Hole Status
    String matchHoleStatus = '-';
    Color matchColor = Colors.grey;
    if (matchResult != null && matchResult!.holeResults.length >= currentHole) {
      final res = matchResult!.holeResults[currentHole - 1];
      if (res == 1) {
        matchHoleStatus = isTeam1 ? 'WIN' : 'LOSS';
        matchColor = isTeam1 ? Colors.green : Colors.red;
      } else if (res == -1) {
        matchHoleStatus = isTeam1 ? 'LOSS' : 'WIN';
        matchColor = isTeam1 ? Colors.red : Colors.green;
      } else if (res == 0) {
        matchHoleStatus = 'HALVE';
        matchColor = Colors.blue;
      }
    }

    return BoxyArtFloatingCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // [NEW] Hole Map Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.file(
                  File('/Users/sanjaypatel/.gemini/antigravity/brain/4808b1a2-a9a6-47fe-8085-5aa51827339d/tactical_golf_hole_map_1771762989431.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Glass Overlay for legibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'HOLE $currentHole',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[600],
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Par $par${si != null ? ' • SI $si' : ''}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  // Large Score Display with subtle glow
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Text(
                      cap != null && score >= cap ? 'MAX' : '$score',
                      style: TextStyle(
                        fontSize: cap != null && score >= cap ? 48 : 84,
                        fontWeight: FontWeight.w900,
                        color: cap != null && score >= cap ? Colors.red : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge(context, 'STABLEFORD', '$pts pts', pts > 0 ? Colors.orange : Colors.grey),
                      if (matchResult != null) ...[
                        const SizedBox(width: 12),
                        _buildBadge(context, 'MATCH', matchHoleStatus, matchColor),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(BuildContext context, int par, int currentScore, int? cap) {
    // We'll show buttons for Par-1, Par, Par+1, Par+2, and 7+
    final options = [par - 1, par, par + 1, par + 2];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ...options.map((val) {
                final isSelected = val == currentScore;
                final isOverCap = cap != null && val > cap;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildKeypadButton(context, '$val', val, isSelected, isDisabled: isOverCap),
                  ),
                );
              }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildKeypadButton(
                    context, 
                    cap != null ? 'MAX' : '7+', 
                    cap ?? (currentScore > par + 2 ? currentScore : 7), 
                    (cap != null && currentScore >= cap) || (cap == null && currentScore >= 7 && !options.contains(currentScore))
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
             children: [
               Expanded(
                 child: OutlinedButton(
                   onPressed: currentScore > 1 ? () => onSetScore(currentHole, currentScore - 1) : null,
                   style: OutlinedButton.styleFrom(
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   child: const Icon(Icons.remove),
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(
                 flex: 2,
                 child: ElevatedButton(
                   onPressed: currentHole < 18 ? () => onHoleChanged(currentHole + 1) : onShowFullCard,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Theme.of(context).primaryColor,
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   child: Text(
                     currentHole < 18 ? 'NEXT HOLE' : 'FINISH CARD', 
                     style: const TextStyle(fontWeight: FontWeight.bold)
                   ),
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: OutlinedButton(
                   onPressed: (cap == null || currentScore < cap) ? () => onSetScore(currentHole, currentScore + 1) : null,
                   style: OutlinedButton.styleFrom(
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   child: const Icon(Icons.add),
                 ),
               ),
             ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(BuildContext context, String label, int value, bool isSelected, {bool isDisabled = false}) {
    return GestureDetector(
      onTap: isDisabled ? null : () => onSetScore(currentHole, value),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  int? _calculateCap(int par, int? si) {
    if (format != CompetitionFormat.maxScore || maxScoreConfig == null) return null;
    
    switch (maxScoreConfig!.type) {
      case MaxScoreType.fixed:
        return maxScoreConfig!.value;
      case MaxScoreType.parPlusX:
        return par + maxScoreConfig!.value;
      case MaxScoreType.netDoubleBogey:
        if (si == null) return par + 2 + 2;
        final freeShots = (playerPhc ~/ 18) + (si <= (playerPhc % 18) ? 1 : 0);
        return par + 2 + freeShots;
    }
  }
}
