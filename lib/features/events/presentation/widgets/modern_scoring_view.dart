import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../matchplay/domain/match_definition.dart';

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
  // [NEW] Tab selection lifted from AppBar into keypad card
  final int selectedTab; // 0 = player, 1 = me/verifier
  final ValueChanged<int> onTabChanged;
  final bool isSelfMarking;
  final String? selectedTeeName;

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
    this.selectedTab = 1,
    required this.onTabChanged,
    this.isSelfMarking = true,
    this.selectedTeeName,
  });

  @override
  Widget build(BuildContext context) {
    final holeData = holes.length >= currentHole ? holes[currentHole - 1] : null;
    final par = (holeData?['par'] as num?)?.toInt() ?? 4;
    final si = (holeData?['si'] as num?)?.toInt();
    final score = scores[currentHole] ?? par;
    final cap = _calculateCap(par, si);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: double.infinity,
      height: double.infinity,
      child: Column(
      children: [
        // Hole Ribbon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: BoxyHoleSelector(
            currentHole: currentHole,
            scores: scores,
            onHoleChanged: onHoleChanged,
          ),
        ),
        
        const SizedBox(height: 12),

        // Player + Tee Pills Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              BoxyArtPill(
                label: markingName.toUpperCase(),
                color: Theme.of(context).primaryColor,
                icon: Icons.person_outline,
                textColor: Colors.black87,
              ),
              const Spacer(),
              _buildTeePill(context, selectedTeeName ?? event.selectedTeeName ?? 'White'),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Hero Card
        SizedBox(
          height: 280,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHeroCard(context, par, si, score, cap),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildKeypad(context, par, score, cap),
      ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'HOLE $currentHole',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.black.withValues(alpha: 0.6),
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
              const SizedBox(height: 10),
              // Large Score Display
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: Text(
                  cap != null && score >= cap ? 'MAX' : '$score',
                  style: TextStyle(
                    fontSize: cap != null && score >= cap ? 44 : 64,
                    fontWeight: FontWeight.w900,
                    color: cap != null && score >= cap ? Colors.red : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BoxyArtPill(label: 'STABLEFORD: $pts pts', color: pts > 0 ? Colors.orange : Colors.grey),
                  if (matchResult != null) ...[
                    const SizedBox(width: 12),
                    BoxyArtPill(label: 'MATCH: $matchHoleStatus', color: matchColor),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildKeypad(BuildContext context, int par, int currentScore, int? cap) {
    // We'll show buttons for Par-1, Par, Par+1, Par+2, and 7+
    final options = [par - 1, par, par + 1, par + 2];
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
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
          // Full-width PLAYER / ME toggle
          _buildMarkerToggle(context),
          const SizedBox(height: 12),
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
                     side: BorderSide(
                       color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                       width: 0.8,
                     ),
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
                     side: BorderSide(
                       color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                       width: 0.8,
                     ),
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

  /// Full-width PLAYER / ME segmented toggle for the keypad card.
  Widget _buildMarkerToggle(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleTab(context, 0, 'PLAYER', isDisabled: isSelfMarking),
          _buildToggleTab(context, 1, 'ME'),
        ],
      ),
    );
  }

  Widget _buildToggleTab(BuildContext context, int tab, String label, {bool isDisabled = false}) {
    final theme = Theme.of(context);
    final isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : () => onTabChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isSelected
                  ? Colors.white
                  : (isDisabled
                      ? theme.primaryColor.withValues(alpha: 0.3)
                      : theme.primaryColor),
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

  /// Builds a tee pill matching BoxyArtPill's exact style, with a coloured
  /// dot in place of the icon.
  Widget _buildTeePill(BuildContext context, String teeName) {
    final teeColor = _getTeeColor(teeName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: teeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: teeColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: teeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            teeName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTeeColor(String teeName) {
    final name = teeName.toLowerCase();
    if (name.contains('white')) return Colors.grey.shade400;
    if (name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('red')) return const Color(0xFFFF4D4D);
    if (name.contains('blue')) return const Color(0xFF1E90FF);
    if (name.contains('black')) return const Color(0xFF2F2F2F);
    if (name.contains('green')) return const Color(0xFF2ECC71);
    if (name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('silver')) return const Color(0xFFC0C0C0);
    if (name.contains('orange')) return Colors.orange;
    if (name.contains('purple')) return Colors.purple;
    return Colors.grey;
  }
}
