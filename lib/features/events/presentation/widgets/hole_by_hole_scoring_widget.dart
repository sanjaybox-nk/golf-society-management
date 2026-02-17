import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../models/competition.dart';
import '../../../../core/utils/handicap_calculator.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/shared_ui/modern_cards.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/scorecard.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../members/presentation/members_provider.dart';
import 'hole_score_card.dart';
import '../../../debug/presentation/state/debug_providers.dart';
import '../../../matchplay/presentation/widgets/match_status_header.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart';
// events_provider.dart removed as it was unused
enum MarkerTab { player, verifier }

class HoleByHoleScoringWidget extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Scorecard? targetScorecard;
  final Scorecard? verifierScorecard;
  final String? targetEntryId; // [NEW] Required for card creation
  final bool isSelfMarking;
  final bool isAdmin; // [NEW] Allows bypassing global event locks
  final MarkerTab selectedTab;
  final ValueChanged<MarkerTab>? onTabChanged;

  const HoleByHoleScoringWidget({
    super.key,
    required this.event,
    this.targetScorecard,
    this.verifierScorecard,
    this.targetEntryId,
    this.isSelfMarking = true,
    this.isAdmin = false,
    this.selectedTab = MarkerTab.player,
    this.onTabChanged,
  });

  @override
  ConsumerState<HoleByHoleScoringWidget> createState() => _HoleByHoleScoringWidgetState();
}

class _HoleByHoleScoringWidgetState extends ConsumerState<HoleByHoleScoringWidget> {
  late PageController _pageController;
  final Map<int, int> _localScores = {}; // Official (Target)
  final Map<int, int> _verifierScores = {}; // Verifier (My Record)
  int _currentPage = 0;
  // Internal state removed in favor of widget.selectedTab

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Initialize local scores (Official)
    if (widget.targetScorecard != null) {
      for (int i = 0; i < widget.targetScorecard!.holeScores.length; i++) {
        final score = widget.targetScorecard!.holeScores[i];
        if (score != null) {
          _localScores[i + 1] = score;
        }
      }
    }

    // Initialize verifier scores (Secondary)
    if (widget.verifierScorecard != null) {
      for (int i = 0; i < widget.verifierScorecard!.playerVerifierScores.length; i++) {
        final score = widget.verifierScorecard!.playerVerifierScores[i];
        if (score != null) {
          _verifierScores[i + 1] = score;
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateScore(int holeNum, int delta, int par, {bool isVerifier = false}) {
    setState(() {
      final map = isVerifier ? _verifierScores : _localScores;
      final currentScore = map[holeNum] ?? par;
      final newScore = (currentScore + delta).clamp(1, 15);
      map[holeNum] = newScore;
    });
    
    // Auto-save logic (debounced or immediate for now)
    _persistScores(isVerifier: isVerifier);
  }

  Future<void> _persistScores({bool isVerifier = false}) async {
    final repo = ref.read(scorecardRepositoryProvider);
    final userId = ref.read(effectiveUserProvider).id;
    
    // Determine which card we are updating
    final cardToUpdate = isVerifier ? widget.verifierScorecard : widget.targetScorecard;
    final map = isVerifier ? _verifierScores : _localScores;
    
    // If no card exists yet, we need to handle creation.
    // For Verifier (My Card), it should ideally exist.
    // For Target (Their Card), it should ideally exist.
    // If not, we create one.
    
    final scoresList = List<int?>.generate(18, (i) => map[i + 1]);
    
    // Calculate totals only for Main/Hole scores (not strictly needed for verifier logic but good to have)
    final grossTotal = scoresList.whereType<int>().fold<int>(0, (a, b) => a + b);

    // CRITICAL: If no card exists yet, only create it if we actually have some scores.
    // This prevents accidental creation of empty cards when simply navigating holes.
    if (cardToUpdate == null && map.isEmpty) return;

    if (cardToUpdate == null) {
        // This case handles brand new scorecard creation
        // If Self-Marking, cardToUpdate is null initially if not passed.
        // We need to create a new scorecard.
        // If Verifier Mode, verifierCard should exist if the event is set up correctly.
        // Allowing creation for now.
        
        final newCard = Scorecard(
          id: '', // Repo generates ID
          competitionId: widget.event.id,
          roundId: 'round_1',
          // Explicitly use targetEntryId if available, otherwise fallback to user
          entryId: isVerifier ? userId : (widget.targetEntryId ?? widget.targetScorecard?.entryId ?? userId),
          submittedByUserId: userId,
          holeScores: isVerifier ? [] : scoresList,
          playerVerifierScores: isVerifier ? scoresList : [],
          grossTotal: isVerifier ? null : grossTotal,
          status: ScorecardStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.addScorecard(newCard);
    } else {
        // Update existing card
        final updatedCard = isVerifier 
            ? cardToUpdate.copyWith(
                playerVerifierScores: scoresList, 
                updatedAt: DateTime.now()
              )
            : cardToUpdate.copyWith(
                holeScores: scoresList,
                grossTotal: grossTotal,
                updatedAt: DateTime.now()
              );
              
        await repo.updateScorecard(updatedCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final holes = widget.event.courseConfig['holes'] as List? ?? [];
    // Fixed height for tabbed view
    const double cardHeight = 220; // Increased from 190 to avoid overflow
    
    // Watch for active match status
    final matchResultAsync = ref.watch(currentMatchControllerProvider(widget.event.id));
    final matchResult = matchResultAsync.asData?.value;

    return BoxyArtFloatingCard(
      height: matchResult != null ? cardHeight + 40 : cardHeight, // Expand for match status
      padding: EdgeInsets.zero,
      child: Column(
        children: [
           // Match Status Header (if active)
           if (matchResult != null)
             MatchStatusHeader(result: matchResult),

           Expanded(
             child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: 18,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    // Swiping automatically saves the current hole's score
                    _persistScores();
                  },
                  itemBuilder: (context, index) {
                    final holeNum = index + 1;
                    int par = 4;
                    int? si;

                    if (holes.length >= holeNum) {
                      final holeData = holes[index];
                      par = (holeData['par'] as num?)?.toInt() ?? 4;
                      si = (holeData['si'] as num?)?.toInt();
                    }

                    final score = _localScores[holeNum] ?? par;

                    return _buildHoleView(holeNum, par, si, score);
                  },
                ),
                
                // Left Chevron
                if (_currentPage > 0)
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28),
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),

                // Right Chevron
                if (_currentPage < 17)
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.chevron_right, size: 28),
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoleView(int holeNum, int par, int? si, int score) {
    // Determine current mode and values
    // Check Conflict for Alert
    bool hasConflict = false;
    final markersEntryForMe = widget.verifierScorecard?.holeScores.elementAtOrNull(holeNum - 1);
    final myEntry = _verifierScores[holeNum];
    
    if (markersEntryForMe != null && markersEntryForMe > 0) {
      if (myEntry != null && myEntry != markersEntryForMe) {
        hasConflict = true;
      }
    }

    final isVerifierTab = !widget.isSelfMarking && widget.selectedTab == MarkerTab.verifier;
    final displayScore = isVerifierTab ? (_verifierScores[holeNum] ?? par) : score;

    // Determine Lock State
    final currentScorecard = isVerifierTab ? widget.verifierScorecard : widget.targetScorecard;
    final bool isStatusLocked = currentScorecard?.status == ScorecardStatus.submitted || 
                               currentScorecard?.status == ScorecardStatus.finalScore;
    
    // [MODIFIED] Lock logic
    // 1. Individually locked if status is submitted/final
    // 2. Globally locked if event is completed or scoring locked
    final lockOverride = ref.watch(isScoringLockedOverrideProvider);
    final bool isEventLocked = (widget.event.isScoringLocked == true || widget.event.status == EventStatus.completed) && lockOverride != false;
    
    // Admins bypass the global event lock to allow rectifications on unlocked cards
    final bool effectivelyLocked = widget.isAdmin ? isStatusLocked : (isStatusLocked || isEventLocked);
    
    final bool isDisabled = effectivelyLocked;

    return Column(
      children: [
        // Match TOTAL bar layout structure (Label + Controls)
        Visibility(
          visible: !widget.isSelfMarking,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 40, // Reduced height for compactness
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SCORES',
                        style: TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 2.0, 
                          color: Colors.blueGrey.shade800
                        ),
                      ),
                      Text(
                        'MARKER MODE',
                        style: TextStyle(
                          fontSize: 7, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 0.5,
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 220,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        _buildTab(
                          context, 
                          'PLAYER', 
                          score,
                          widget.selectedTab == MarkerTab.player, 
                          () => widget.onTabChanged?.call(MarkerTab.player)
                        ),
                        _buildTab(
                          context, 
                          'MY SCORE', 
                          myEntry,
                          widget.selectedTab == MarkerTab.verifier, 
                          () => widget.onTabChanged?.call(MarkerTab.verifier), 
                          hasConflict: hasConflict,
                          activeColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        Expanded(
          child: Builder(
            builder: (context) {
              int? maxHoleScore;
              
              // Resolve Max Score Config & Overrides
              final formatOverride = ref.watch(gameFormatOverrideProvider);
              final compAsync = ref.watch(competitionDetailProvider(widget.event.id));
              final comp = compAsync.asData?.value;
              final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
              
              if (currentFormat == CompetitionFormat.maxScore) {
                 final maxTypeOverride = ref.watch(maxScoreTypeOverrideProvider);
                 final maxValueOverride = ref.watch(maxScoreValueOverrideProvider);
                 MaxScoreConfig? maxConfig = comp?.rules.maxScoreConfig;
                 
                 if (maxTypeOverride != null) {
                    maxConfig = MaxScoreConfig(
                      type: maxTypeOverride,
                      value: maxValueOverride ?? (maxConfig?.value ?? 2),
                    );
                 }
                 
                 if (maxConfig != null) {
                    // Need handicap for Net Double Bogey
                    // Try to get handicap from allMembersProvider or effectiveUser
                    final membersAsync = ref.watch(allMembersProvider);
                    final targetId = widget.targetEntryId ?? widget.targetScorecard?.entryId;
                    final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == targetId);
                    
                    double handicapIndex = member?.handicap ?? 18.0;
                    
                    // For a truly accurate Net DB, we should use Playing Handicap
                    // but since this is a UI hint, we'll use a simplified version if PHC isn't immediately available
                    // or calculate it using the calculator if we have the event context
                    final phc = member != null ? HandicapCalculator.calculatePlayingHandicap(
                      handicapIndex: handicapIndex, 
                      rules: comp?.rules ?? const CompetitionRules(), 
                      courseConfig: widget.event.courseConfig,
                    ) : handicapIndex.round();

                    if (maxConfig.type == MaxScoreType.fixed) {
                      maxHoleScore = maxConfig.value;
                    } else if (maxConfig.type == MaxScoreType.parPlusX) {
                      maxHoleScore = par + maxConfig.value;
                    } else {
                      // Net Double Bogey
                      final holeStrokes = (phc ~/ 18) + (si != null && si <= (phc % 18) ? 1 : 0);
                      maxHoleScore = (par + 2 + holeStrokes).toInt();
                    }
                 }
              }

              return HoleScoreCard(
                holeNum: holeNum,
                par: par,
                si: si,
                score: displayScore,
                maxScore: maxHoleScore,
                isReadOnly: isDisabled, 
                isDisabled: isDisabled,
                hasConflict: isVerifierTab && hasConflict,
                onIncrement: () => _updateScore(holeNum, 1, par, isVerifier: isVerifierTab),
                onDecrement: () => _updateScore(holeNum, -1, par, isVerifier: isVerifierTab),
                onScoreChanged: (newScore) => _setScore(holeNum, newScore, isVerifier: isVerifierTab),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String label, int? score, bool isActive, VoidCallback onTap, {bool hasConflict = false, Color? activeColor}) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive ? AppShadows.softScale : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$label${score != null ? ': $score' : ''}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: (hasConflict && isActive) 
                      ? Colors.red 
                      : (isActive ? (activeColor ?? theme.primaryColor) : Colors.blueGrey.shade500),
                ),
              ),
              if (hasConflict) ...[
                const SizedBox(width: 4),
                Icon(Icons.error, size: 14, color: isActive ? Colors.red : Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _setScore(int holeNum, int score, {bool isVerifier = false}) {
    setState(() {
      final map = isVerifier ? _verifierScores : _localScores;
      map[holeNum] = score.clamp(1, 15);
    });
    _persistScores(isVerifier: isVerifier);
  }
}

// Helper extension
extension ElementAtOrNull<E> on Iterable<E> {
  E? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
