import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../models/golf_event.dart';
import '../../matchplay/presentation/state/match_play_providers.dart';
import 'widgets/modern_scoring_view.dart';
import '../../../../models/competition.dart';
import '../../competitions/presentation/competitions_provider.dart';
import '../../../../core/utils/handicap_calculator.dart';
import '../../members/presentation/members_provider.dart';
import '../../members/presentation/profile_provider.dart';
import 'widgets/hole_by_hole_scoring_widget.dart'; // For MarkerTab

class HeroScoringScreen extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Map<int, int> initialPlayerScores;
  final Map<int, int> initialVerifierScores;
  final int initialHole;
  final List<dynamic> holes;
  final Map<String, dynamic> effectivePtc;
  final MarkerTab initialTab;
  final String? activeEntryId;
  final Function(int hole, int score, bool isVerifier) onSetScore;
  final bool isSelfMarking;

  const HeroScoringScreen({
    super.key,
    required this.event,
    required this.initialPlayerScores,
    required this.initialVerifierScores,
    required this.initialHole,
    required this.holes,
    required this.effectivePtc,
    required this.initialTab,
    this.activeEntryId,
    required this.onSetScore,
    this.isSelfMarking = true,
  });

  @override
  ConsumerState<HeroScoringScreen> createState() => _HeroScoringScreenState();
}

class _HeroScoringScreenState extends ConsumerState<HeroScoringScreen> {
  late int _currentHole;
  late Map<int, int> _playerScores;
  late Map<int, int> _verifierScores;
  late MarkerTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _currentHole = widget.initialHole;
    _playerScores = Map.from(widget.initialPlayerScores);
    _verifierScores = Map.from(widget.initialVerifierScores);
    _selectedTab = widget.isSelfMarking ? MarkerTab.verifier : widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final matchResultAsync = ref.watch(currentMatchControllerProvider(widget.event.id));
    final compAsync = ref.watch(competitionDetailProvider(widget.event.id));
    final matchResult = matchResultAsync.asData?.value;
    final isVerifier = _selectedTab == MarkerTab.verifier;
    final currentScores = isVerifier ? _verifierScores : _playerScores;

    // Resolve Marking Name
    final memberId = isVerifier ? ref.watch(effectiveUserProvider).id : widget.activeEntryId;
    final member = ref.watch(allMembersProvider).asData?.value.firstWhereOrNull(
      (m) => m.id == memberId?.replaceFirst('_guest', '')
    );
    final markingName = member?.displayName ?? (isVerifier ? 'Me' : 'Player');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drawer handle indicator
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'HOLE $_currentHole',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Dismiss',
        ),
        actions: [
          _buildMarkerToggle(context),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Swipe down to dismiss
          if (details.primaryDelta! > 12) {
            Navigator.of(context).pop();
          }
        },
        onHorizontalDragEnd: (details) {
          // Detect horizontal swipes for hole navigation
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -300) {
            // Swipe Left -> Next Hole
            if (_currentHole < 18) {
              setState(() => _currentHole++);
            }
          } else if (velocity > 300) {
            // Swipe Right -> Previous Hole
            if (_currentHole > 1) {
              setState(() => _currentHole--);
            }
          }
        },
        child: SafeArea(
          child: compAsync.when(
            data: (comp) => ModernScoringView(
              event: widget.event,
              scores: currentScores,
              currentHole: _currentHole,
              holes: widget.holes,
              playerPhc: _calculatePhc(isVerifier),
              markingName: markingName,
              matchResult: matchResult?.result,
              isTeam1: matchResult?.match.team1Ids.contains(memberId) ?? true,
              format: comp?.rules.format ?? CompetitionFormat.stableford,
              maxScoreConfig: comp?.rules.maxScoreConfig,
              rules: comp?.rules,
              onHoleChanged: (h) => setState(() => _currentHole = h),
              onSetScore: (h, score) {
                setState(() {
                  if (isVerifier) {
                    _verifierScores[h] = score;
                  } else {
                    _playerScores[h] = score;
                  }
                });
                widget.onSetScore(h, score, isVerifier);
              },
              onShowFullCard: () => Navigator.of(context).pop(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(MarkerTab.player, 'PLAYER', isDisabled: widget.isSelfMarking),
          _buildToggleButton(MarkerTab.verifier, 'ME'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(MarkerTab tab, String label, {bool isDisabled = false}) {
    final isSelected = _selectedTab == tab;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _selectedTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60, // [FIX] Equal width for both buttons
        height: 32, // Match parent height
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected 
                ? Colors.white 
                : (isDisabled ? theme.primaryColor.withValues(alpha: 0.3) : theme.primaryColor),
          ),
        ),
      ),
    );
  }

  int _calculatePhc(bool isVerifier) {
    final memberId = isVerifier ? ref.read(effectiveUserProvider).id : widget.activeEntryId;
    if (memberId == null) return 0;
    
    final comp = ref.watch(competitionDetailProvider(widget.event.id)).asData?.value;
    
    // [NEW] If Match Play, show relative strokes received in the match
    if (comp?.rules.format == CompetitionFormat.matchPlay) {
       final matchData = ref.watch(currentMatchControllerProvider(widget.event.id)).asData?.value;
       if (matchData != null) {
          return matchData.match.strokesReceived[memberId] ?? 0;
       }
    }

    final member = ref.watch(allMembersProvider).asData?.value.firstWhereOrNull(
      (m) => m.id == memberId.replaceFirst('_guest', '')
    );
    final baseHc = member?.handicap ?? 0.0;
    
    if (comp == null) return baseHc.round();

    return HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: baseHc, 
      courseConfig: widget.effectivePtc,
      rules: comp.rules,
    );
  }
}
