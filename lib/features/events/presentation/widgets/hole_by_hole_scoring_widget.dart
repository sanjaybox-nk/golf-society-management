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
import 'package:golf_society/domain/models/course_config.dart';
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
  int _currentHoleIndex = 0; // [NEW] Track current hole across swiping/ribbon

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
         SnackBar(content: Text('Error saving score: $e'), backgroundColor: AppColors.coral500),
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
    final holes = resolvedPtc.holes;
    
    // Watch for active match status
    final matchResultAsync = ref.watch(currentMatchControllerProvider(widget.event.id));
    final matchResult = matchResultAsync.asData?.value;

    // Tactical Info Resolve
    final currentHoleNum = _currentHoleIndex + 1;
    int par = 4;
    int? si;
    if (holes.length >= currentHoleNum) {
      final hData = holes[_currentHoleIndex];
      par = hData.par;
      si = hData.si;
    }

    final int currentScore = (widget.selectedTab == MarkerTab.player ? _localScores : _verifierScores)[currentHoleNum] ?? par;
    final pts = ScoringCalculator.calculateHolePoints(
      grossScore: currentScore,
      par: par,
      si: si ?? 18,
      playingHandicap: HandicapCalculator.getStoredPhc(widget.event.grouping, _activeEntryId ?? '').toDouble(),
    );

    return Column(
      children: [
        // 1. Hole Selector Ribbon (Moved from Hero)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: BoxyHoleSelector(
            currentHole: currentHoleNum,
            scores: widget.selectedTab == MarkerTab.player ? _localScores : _verifierScores,
            onHoleChanged: (h) => setState(() => _currentHoleIndex = h - 1),
          ),
        ),

        GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < -10) {
              _openHeroScoring(holes, resolvedPtc);
            }
          },
          child: BoxyArtCard(
            height: matchResult != null ? 160 : 125, // Height to accommodate mini keypad
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                  // Match Status Header (if active)
                  if (matchResult != null)
                    MatchStatusHeader(
                      result: matchResult.result,
                      match: matchResult.match,
                    ),

                  // Consolidated Scoring Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        // Row 1: Player Selection + Hole Info
                        Row(
                          children: [
                            // 50/50 Split Marker Toggle
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary.withValues(alpha: AppColors.opacitySubtle),
                                  borderRadius: AppShapes.md,
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
                            const SizedBox(width: AppSpacing.md),
                            // Hole Summary
                            Expanded(
                              flex: 3,
                              child: Text(
                                'PAR $par${si != null ? ' • SI $si' : ''} • $pts PTS',
                                textAlign: TextAlign.right,
                                style: AppTypography.caption.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                                  fontWeight: AppTypography.weightBlack,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Row 2: Mini Keypad + Next Hole
                        Row(
                          children: [
                            // Keypad
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMiniCircleButton(
                                  context, 
                                  Icons.remove, 
                                  () => _setScore(currentHoleNum, currentScore - 1, isVerifier: widget.selectedTab == MarkerTab.verifier),
                                  isDisabled: currentScore <= 1,
                                ),
                                Container(
                                  width: 44,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$currentScore',
                                    style: AppTypography.displayLocker.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                _buildMiniCircleButton(
                                  context, 
                                  Icons.add, 
                                  () => _setScore(currentHoleNum, currentScore + 1, isVerifier: widget.selectedTab == MarkerTab.verifier),
                                ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Next Hole / Hero Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentHoleNum < 18) {
                                    setState(() => _currentHoleIndex++);
                                  } else {
                                    _openHeroScoring(holes, resolvedPtc);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: AppColors.pureWhite,
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
                                ),
                                child: Text(
                                  currentHoleNum < 18 ? 'NEXT HOLE' : 'FINISH CARD', 
                                  style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBlack, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // Expansion Button (Hero)
                            IconButton(
                              onPressed: () => _openHeroScoring(holes, resolvedPtc),
                              icon: const Icon(Icons.bolt, color: AppColors.amber500),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  // Drag Handle Indicator
                  Container(
                    width: AppSpacing.x3l,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMuted),
                      borderRadius: AppShapes.grabber,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildTab(BuildContext context, String label, int? score, bool isActive, VoidCallback? onTap, {bool hasConflict = false, Color? activeColor, bool isDisabled = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeBg = activeColor ?? (isDark ? AppColors.pureWhite : theme.primaryColor);
    final activeTextColor = isDark ? AppColors.dark900 : AppColors.pureWhite;

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          margin: const EdgeInsets.all(2), // Subtle inset for the pill
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: AppShapes.md, // [FIX] Consistent with card system
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: AppColors.opacityMedium),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$label${score != null ? ': $score' : ''}',
                style: AppTypography.caption.copyWith(
                  fontWeight: AppTypography.weightBlack,
                  letterSpacing: 0.5,
                  color: (hasConflict) 
                      ? AppColors.coral500 
                      : (isActive 
                          ? activeTextColor 
                          : (isDisabled ? theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium) : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHalf))),
                ),
              ),
              if (hasConflict) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.error, size: AppShapes.iconXs, color: isActive ? AppColors.coral500 : AppColors.textSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCircleButton(BuildContext context, IconData icon, VoidCallback? onTap, {bool isDisabled = false}) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled 
              ? AppColors.textSecondary.withValues(alpha: AppColors.opacitySubtle)
              : Theme.of(context).primaryColor.withValues(alpha: AppColors.opacitySubtle),
        ),
        child: Icon(
          icon, 
          size: 16, 
          color: isDisabled ? AppColors.textSecondary : Theme.of(context).primaryColor
        ),
      ),
    );
  }

  void _openHeroScoring(List<CourseHole> holes, CourseConfig ptc) {
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
        transitionDuration: AppAnimations.slow,
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
          final holeData = pConfig.holes.elementAtOrNull(holeNum - 1);
          final par = holeData?.par ?? 4;
          final si = holeData?.si ?? 18;
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
