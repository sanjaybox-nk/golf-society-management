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
import '../../../../core/utils/grouping_service.dart';
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
  final ValueChanged<MarkerTab> onTabChanged; // Remove nullability to fix assignment issues

  const HoleByHoleScoringWidget({
    super.key,
    required this.event,
    this.targetScorecard,
    this.verifierScorecard,
    this.targetEntryId,
    this.isSelfMarking = true,
    this.isAdmin = false,
    this.selectedTab = MarkerTab.player,
    required this.onTabChanged,
  });

  @override
  ConsumerState<HoleByHoleScoringWidget> createState() => _HoleByHoleScoringWidgetState();
}

class _HoleByHoleScoringWidgetState extends ConsumerState<HoleByHoleScoringWidget> {
  late PageController _pageController;
  final Map<int, int> _localScores = {}; // Official (Target)
  final Map<int, int> _verifierScores = {}; // Verifier (My Record)
  final Map<int, String?> _shotAttributions = {}; // [NEW] Hole index -> Member ID
  int _currentPage = 0;
  String? _activeEntryId; // [NEW] Track which partner is being edited
  Scorecard? _activeScorecard; // [NEW] Local cache if switching
  // Internal state removed in favor of widget.selectedTab
 
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _activeEntryId = widget.targetEntryId ?? widget.targetScorecard?.entryId;
    _activeScorecard = widget.targetScorecard;
    
    // Initialize local scores (Official)
    _syncScoresFromCard(_activeScorecard);

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

  void _syncScoresFromCard(Scorecard? card) {
    _localScores.clear();
    _shotAttributions.clear();
    if (card != null) {
      for (int i = 0; i < card.holeScores.length; i++) {
        final score = card.holeScores[i];
        if (score != null) {
          _localScores[i + 1] = score;
        }
      }
      _shotAttributions.addAll(card.shotAttributions);
    }
  }

  Future<void> _switchPlayer(String newId) async {
    if (_activeEntryId == newId) return;
    
    // 1. Save current
    await _persistScores();
    
    // 2. Fetch/Switch to new card
    final scorecards = await ref.read(scorecardsListProvider(widget.event.id).future);
    final card = scorecards.firstWhereOrNull((s) => s.entryId == newId);
    
    setState(() {
      _activeEntryId = newId;
      _activeScorecard = card;
      _syncScoresFromCard(card);
    });
  }

  void _updateAttribution(int holeNum, String memberId) {
    setState(() {
      if (_shotAttributions[holeNum] == memberId) {
        _shotAttributions.remove(holeNum);
      } else {
        _shotAttributions[holeNum] = memberId;
      }
    });
    _persistScores();
  }

  Future<void> _persistScores({bool isVerifier = false}) async {
    final repo = ref.read(scorecardRepositoryProvider);
    final userId = ref.read(effectiveUserProvider).id;
    final entryId = isVerifier ? userId : _activeEntryId;
    if (entryId == null) return;
    
    // Determine which card we are updating
    final cardToUpdate = isVerifier ? widget.verifierScorecard : _activeScorecard;
    final map = isVerifier ? _verifierScores : _localScores;
    
    final scoresList = List<int?>.generate(18, (i) => map[i + 1]);
    
    // Calculate totals only for Main/Hole scores
    final grossTotal = scoresList.whereType<int>().fold<int>(0, (a, b) => a + b);

    // CRITICAL: If no card exists yet, only create it if we actually have some scores.
    // This prevents accidental creation of empty cards when simply navigating holes.
    if (cardToUpdate == null && map.isEmpty && _shotAttributions.isEmpty) return;

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
          shotAttributions: isVerifier ? {} : Map.from(_shotAttributions),
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
                shotAttributions: Map.from(_shotAttributions),
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

            _buildPlayerPicker(),

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

  Widget _buildHoleView(int holeNum, int par, int? si, int displayScore) {
    final hasConflict = _localScores[holeNum] != null && _verifierScores[holeNum] != null && _localScores[holeNum] != _verifierScores[holeNum];
    final isVerifierTab = widget.selectedTab == MarkerTab.verifier;

    // Determine Lock State
    final currentScorecard = isVerifierTab ? widget.verifierScorecard : _activeScorecard;
    final bool isStatusLocked = currentScorecard?.status == ScorecardStatus.submitted || 
                               currentScorecard?.status == ScorecardStatus.finalScore;
    
    final lockOverride = ref.watch(isScoringLockedOverrideProvider);
    final bool isEventLocked = (widget.event.isScoringLocked == true || widget.event.status == EventStatus.completed) && lockOverride != false;
    
    final bool effectivelyLocked = widget.isAdmin ? isStatusLocked : (isStatusLocked || isEventLocked);
    final bool isDisabled = effectivelyLocked;

    return Column(
      children: [
        // Scramble Attribution Section
        _buildScrambleAttributionSection(holeNum, effectivelyLocked),

        // Match TOTAL bar layout structure (Label + Controls)
        Visibility(
          visible: !widget.isSelfMarking,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 40,
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
                      const Text(
                        'SCORES',
                        style: TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 2.0, 
                          color: Colors.blueGrey
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
                          displayScore,
                          widget.selectedTab == MarkerTab.player, 
                          () => widget.onTabChanged.call(MarkerTab.player)
                        ),
                        _buildTab(
                          context, 
                          'MY SCORE', 
                          _verifierScores[holeNum],
                          widget.selectedTab == MarkerTab.verifier, 
                          () => widget.onTabChanged.call(MarkerTab.verifier), 
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
                    final membersAsync = ref.watch(allMembersProvider);
                    final targetId = _activeEntryId;
                    final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == targetId);
                    
                    double handicapIndex = member?.handicap ?? 18.0;
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
        if (isVerifierTab && _localScores[holeNum] != null) ...[
           const SizedBox(height: 8),
           _buildConflictIndicator(holeNum),
        ],
      ],
    );
  }

  Widget _buildConflictIndicator(int holeNum) {
    final official = _localScores[holeNum];
    final verifier = _verifierScores[holeNum];
    if (official == null || verifier == null || official == verifier) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            'Conflict: Official is $official',
            style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerPicker() {
    final compAsync = ref.watch(competitionDetailProvider(widget.event.id));
    final comp = compAsync.asData?.value;
    if (comp?.rules.subtype == CompetitionSubtype.foursomes) return const SizedBox.shrink();

    final players = _getTeamPlayers();
    if (players.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          const Text(
            'SCORING FOR:',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(width: 12),
          ...players.map((p) {
            final id = p.registrationMemberId;
            final isActive = _activeEntryId == id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => _switchPlayer(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                    boxShadow: isActive ? AppShadows.softScale : null,
                  ),
                  child: Text(
                    p.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isActive ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrambleAttributionSection(int holeNum, bool isLocked) {
    final compAsync = ref.watch(competitionDetailProvider(widget.event.id));
    final comp = compAsync.asData?.value;
    if (comp?.rules.format != CompetitionFormat.scramble) return const SizedBox.shrink();
    if (comp?.rules.trackShotAttributions == false) return const SizedBox.shrink();

    final players = _getTeamPlayers();
    if (players.isEmpty) return const SizedBox.shrink();

    final currentChosen = _shotAttributions[holeNum];
    final isFlorida = comp?.rules.subtype == CompetitionSubtype.florida;
    final prevHoleChosen = holeNum > 1 ? _shotAttributions[holeNum - 1] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CHOSEN SHOT / DRIVE',
                style: TextStyle(
                  fontSize: 9, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.0, 
                  color: Colors.blueGrey.shade400
                ),
              ),
              const Spacer(),
              if (isFlorida)
               Text(
                'FLORIDA STEP-ASIDE',
                style: TextStyle(
                  fontSize: 8, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.orange.shade700
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: players.map((p) {
              final isChosen = currentChosen == p.registrationMemberId;
              final isSteppingAside = isFlorida && prevHoleChosen == p.registrationMemberId;
              
              return Expanded(
                child: GestureDetector(
                  onTap: isLocked ? null : () => _updateAttribution(holeNum, p.registrationMemberId),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isChosen 
                          ? Theme.of(context).primaryColor 
                          : (isSteppingAside ? Colors.orange.withValues(alpha: 0.1) : Colors.blueGrey.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isChosen 
                            ? Theme.of(context).primaryColor 
                            : (isSteppingAside ? Colors.orange : Colors.transparent),
                        width: 1.5,
                      ),
                      boxShadow: isChosen ? AppShadows.softScale : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          p.name.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isChosen ? Colors.white : (isSteppingAside ? Colors.orange.shade800 : Colors.blueGrey),
                          ),
                        ),
                        if (isSteppingAside)
                          const Icon(Icons.do_not_disturb_on, size: 10, color: Colors.orange),
                        if (isChosen && !isSteppingAside)
                          const Icon(Icons.check_circle, size: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<TeeGroupParticipant> _getTeamPlayers() {
     final groupingData = widget.event.grouping['groups'] as List?;
     if (groupingData == null) return [];

     final targetId = widget.targetEntryId ?? widget.targetScorecard?.entryId;
     if (targetId == null) return [];

     for (var g in groupingData) {
       final players = (g['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList();
       if (players.any((p) => p.registrationMemberId == targetId)) {
         return players;
       }
     }
     return [];
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
