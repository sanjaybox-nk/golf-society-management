import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../matchplay/presentation/widgets/match_status_header.dart';
import '../../../matchplay/presentation/state/match_play_providers.dart';
import '../hero_scoring_screen.dart';
import '../state/marker_selection_provider.dart';
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
  final ValueChanged<MarkerTab> onTabChanged; 
  final Function(Map<int, int> scores, bool isVerifier)? onScoresChanged; // [NEW] For immediate grid sync

  const HoleByHoleScoringWidget({
    super.key,
    required this.event,
    this.targetScorecard,
    this.verifierScorecard,
    this.targetEntryId,
    this.isSelfMarking = true,
    this.isAdmin = false,
    required this.selectedTab, // Lifted State
    required this.onTabChanged, // Lifted State
    this.onScoresChanged,
  });

  @override
  ConsumerState<HoleByHoleScoringWidget> createState() => _HoleByHoleScoringWidgetState();
}

class _HoleByHoleScoringWidgetState extends ConsumerState<HoleByHoleScoringWidget> {
  late PageController _pageController;
  final Map<int, int> _localScores = {}; // Official (Target)
  final Map<int, int> _verifierScores = {}; // Verifier (My Record)
  final Map<int, String?> _shotAttributions = {}; // [NEW] Hole index -> Member ID
  String? _activeEntryId; // [NEW] Track which partner is being edited
  Scorecard? _activeScorecard; // [NEW] Local cache if switching
  Scorecard? _localVerifierCard; // [NEW] Local cache for verifier card to prevent duplicates
  final int _currentHoleIndex = 0; // [NEW] Track current hole across swiping/ribbon

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _activeEntryId = widget.targetEntryId ?? widget.targetScorecard?.entryId;
    _activeScorecard = widget.targetScorecard;
    _localVerifierCard = widget.verifierScorecard;
    
    // Initialize local scores (Official)
    _syncScoresFromCard(_activeScorecard);

    // Initialize verifier scores (Secondary)
    // Fallback: If playerVerifierScores is empty (e.g. seeded data or new card), 
    // try to show valid holeScores so the user sees *some* score instead of dashes.
    if (_localVerifierCard != null) {
      final sourceScores = _localVerifierCard!.playerVerifierScores.isNotEmpty && _localVerifierCard!.playerVerifierScores.any((s) => s != null) 
          ? _localVerifierCard!.playerVerifierScores
          : _localVerifierCard!.holeScores;

      for (int i = 0; i < sourceScores.length; i++) {
        final score = sourceScores[i];
        if (score != null) {
          _verifierScores[i + 1] = score;
        }
      }
    }
  }

  @override
  void didUpdateWidget(HoleByHoleScoringWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // [FIX] Update active Entry ID if it changed from parent
    if (widget.targetEntryId != oldWidget.targetEntryId) {
      setState(() {
        _activeEntryId = widget.targetEntryId;
      });
    }

    if (widget.targetScorecard != oldWidget.targetScorecard) {
      _activeScorecard = widget.targetScorecard;
      // Re-sync local scores if we haven't started typing yet
      if (_localScores.isEmpty) { 
         _syncScoresFromCard(_activeScorecard);
      }
    }
    if (widget.verifierScorecard != oldWidget.verifierScorecard) {
       _localVerifierCard = widget.verifierScorecard;
       
       // [Fix Async Loading] If card arrives after init, populate scores
       if (widget.verifierScorecard != null && oldWidget.verifierScorecard == null) {
           final sourceScores = widget.verifierScorecard!.playerVerifierScores.isNotEmpty && widget.verifierScorecard!.playerVerifierScores.any((s) => s != null)
              ? widget.verifierScorecard!.playerVerifierScores
              : widget.verifierScorecard!.holeScores;

           setState(() {
              for (int i = 0; i < sourceScores.length; i++) {
                final score = sourceScores[i];
                if (score != null) {
                  _verifierScores[i + 1] = score;
                }
              }
           });
       }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  int? _calculateMaxScoreCap(int holeNum, int par, int si, CompetitionRules rules) {
    if (rules.format != CompetitionFormat.maxScore || rules.maxScoreConfig == null) return null;
    
    final targetId = _activeEntryId;
    if (targetId == null) return 15; // Fallback

    final phc = HandicapCalculator.getStoredPhc(widget.event.grouping, targetId).toDouble();

    return ScoringCalculator.getMaxScoreCap(
      par: par,
      si: si,
      playingHandicap: phc,
      format: rules.format,
      maxScoreConfig: rules.maxScoreConfig,
    );
  }


  // Duplicated locally during revamp logic integration, removing second instance

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



  Future<void> _persistScores({bool isVerifier = false}) async {
    try {
      final repo = ref.read(scorecardRepositoryProvider);
      final userId = ref.read(effectiveUserProvider).id;
      final entryId = isVerifier ? userId : _activeEntryId;
      if (entryId == null) return;
    
    // Determine which card we are updating
    final cardToUpdate = isVerifier ? _localVerifierCard : _activeScorecard;
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
        
        // HOWEVER, we can generate the ID ourselves!
        // Firestore allows setting ID or auto-id.
        // Better to generate ID here so we know it.
        final generatedId = FirebaseFirestore.instance.collection('scorecards').doc().id;
        final newCardWithId = newCard.copyWith(id: generatedId);
        
        await repo.addScorecard(newCardWithId);
        
        // Update Local State IMMEDIATELY
        if (isVerifier) {
            setState(() => _localVerifierCard = newCardWithId);
        } else {
            setState(() => _activeScorecard = newCardWithId);
        }

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
        
        // Update Local State with latest values
        if (isVerifier) {
             // setState(() => _localVerifierCard = updatedCard); // Optional, helps keep timestamps fresh
        }
    }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error saving score: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // [NEW] Resolve correct holes list based on the player being marked
    final membersAsync = ref.watch(allMembersProvider);
    final members = membersAsync.asData?.value ?? [];
    final markerSelection = ref.watch(markerSelectionProvider);
    final String? manualTee = markerSelection.teeOverrides[_activeEntryId];
    
    final resolvedPtc = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: _activeEntryId ?? '', 
      event: widget.event, 
      membersList: members, 
      manualTeeName: manualTee,
    );
    final holes = resolvedPtc['holes'] as List? ?? [];
    
    // Watch for active match status
    final matchResultAsync = ref.watch(currentMatchControllerProvider(widget.event.id));
    final matchResult = matchResultAsync.asData?.value;

    // Tactical Info Resolve
    final currentHoleNum = _currentHoleIndex + 1;
    int par = 4;
    int? si;
    if (holes.length >= currentHoleNum) {
      final hData = holes[_currentHoleIndex];
      par = (hData['par'] as num?)?.toInt() ?? 4;
      si = (hData['si'] as num?)?.toInt();
    }

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -10) {
          _openHeroScoring(holes, resolvedPtc);
        }
      },
      child: BoxyArtCard(
        height: matchResult != null ? 140 : 100, // [FIXED] Reduced height for more compact layout
        padding: EdgeInsets.zero,
        child: Column(
          children: [
              // Match Status Header (if active)
              if (matchResult != null)
                MatchStatusHeader(
                  result: matchResult.result,
                  match: matchResult.match,
                ),

              // Tactical Handle Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), // [FIXED] Reduced top padding
                child: Column(
                  children: [
                    // Row 1: Centered Hole Info
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'HOLE $currentHoleNum • PAR $par${si != null ? ' • SI $si' : ''}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: 50/50 Split Actions
                    Row(
                      children: [
                        // Persistent Toggle
                        Expanded(
                          child: Container(
                            height: 36, // [FIX] Standardized height
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _buildTab(
                                  context, 
                                  'PLAYER', 
                                  null, 
                                  widget.selectedTab == MarkerTab.player, 
                                  () => widget.onTabChanged(MarkerTab.player),
                                  isDisabled: widget.isSelfMarking, 
                                ),
                                _buildTab(
                                  context, 
                                  'ME', 
                                  null, 
                                  widget.selectedTab == MarkerTab.verifier, 
                                  () => widget.onTabChanged(MarkerTab.verifier),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Enter Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _openHeroScoring(holes, resolvedPtc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 36), // [FIX] Expand to fill
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Center for better symmetry
                              children: [
                                Icon(Icons.bolt, size: 12),
                                SizedBox(width: 4),
                                Text('SCORING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              // Drag Handle Indicator
              Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildTab(BuildContext context, String label, int? score, bool isActive, VoidCallback? onTap, {bool hasConflict = false, Color? activeColor, bool isDisabled = false}) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? (activeColor ?? theme.primaryColor) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
                  letterSpacing: 0.5,
                  color: (hasConflict) 
                      ? Colors.red 
                      : (isActive 
                          ? Colors.white 
                          : (isDisabled ? Colors.grey.withValues(alpha: 0.5) : Colors.black)),
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

  void _openHeroScoring(List<dynamic> holes, Map<String, dynamic> ptc) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HeroScoringScreen(
          event: widget.event,
          initialPlayerScores: _localScores,
          initialVerifierScores: _verifierScores,
          initialHole: _currentHoleIndex + 1,
          holes: holes,
          effectivePtc: ptc,
          initialTab: widget.selectedTab,
          activeEntryId: _activeEntryId,
          isSelfMarking: widget.isSelfMarking,
          onSetScore: (h, score, isVerifier) {
            _setScore(h, score, isVerifier: isVerifier);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    ).then((_) => setState(() {}));
  }

  void _setScore(int holeNum, int score, {bool isVerifier = false}) {
    setState(() {
      final map = isVerifier ? _verifierScores : _localScores;
      
      // Determine Cap
      int? cap;
      final comp = ref.read(competitionDetailProvider(widget.event.id)).asData?.value;
      if (comp?.rules.format == CompetitionFormat.maxScore) {
          // Resolve par for this hole
          final members = ref.read(allMembersProvider).asData?.value ?? [];
          final markerSelection = ref.read(markerSelectionProvider);
          final String? manualTee = markerSelection.teeOverrides[_activeEntryId];
          
          final pConfig = ScoringCalculator.resolvePlayerCourseConfig(
            memberId: _activeEntryId ?? '', 
            event: widget.event, 
            membersList: members, 
            manualTeeName: manualTee,
          );
          final holeData = (pConfig['holes'] as List?)?.elementAtOrNull(holeNum - 1);
          final par = (holeData?['par'] as num?)?.toInt() ?? 4;
          final si = (holeData?['si'] as num?)?.toInt() ?? 18;
          cap = _calculateMaxScoreCap(holeNum, par, si, comp!.rules);
      }

      map[holeNum] = score.clamp(1, cap ?? 15);
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
