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
    
    final targetId = _activeEntryId ?? '';
    if (targetId.isEmpty) return 15; // Fallback

    final members = ref.read(allMembersProvider).asData?.value ?? [];
    final member = members.firstWhereOrNull((m) => m.id == targetId.replaceFirst('_guest', ''));
    final double handicapIndex = member?.handicap ?? 18.0;

    final markerSelection = ref.read(markerSelectionProvider);
    final String? manualTee = markerSelection.teeOverrides[targetId];
    
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: targetId, 
      event: widget.event, 
      membersList: members, 
      manualTeeName: manualTee,
    );

    final phc = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: handicapIndex, 
      rules: rules, 
      courseConfig: playerTeeConfig,
      societyCut: widget.event.manualCuts[targetId] ?? 0.0,
    ).toDouble();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

    return Column(
      children: [
        BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Hole Selector Ribbon (Now inside Card)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: BoxyHoleSelector(
                  currentHole: currentHoleNum,
                  scores: widget.selectedTab == MarkerTab.player ? _localScores : _verifierScores,
                  onHoleChanged: (h) => setState(() => _currentHoleIndex = h - 1),
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: (isDark ? AppColors.pureWhite : Colors.black).withValues(alpha: 0.05),
              ),

              // Match Status Header (if active)
              if (matchResult != null)
                MatchStatusHeader(
                  result: matchResult.result,
                  match: matchResult.match,
                ),

              // Consolidated Scoring Content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.extension<AppSpacingTokens>()?.cardHorizontalPadding ?? AppSpacing.lg,
                  vertical: theme.extension<AppSpacingTokens>()?.cardVerticalPadding ?? AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Consolidated Header: Floating Elements (No nested card)
                    Row(
                      children: [
                        Expanded(
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                  _buildTab(
                                    context, 
                                    'Player', 
                                    null, 
                                    widget.selectedTab == MarkerTab.player, 
                                    () => widget.onTabChanged(MarkerTab.player),
                                    isDisabled: widget.isSelfMarking, 
                                    activeColor: theme.colorScheme.primary,
                                  ),
                                
                                // Hole Info in middle
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  child: Center(
                                    child: Text(
                                      'Par $par${si != null ? ' • SI $si' : ''}',
                                      style: AppTypography.label.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                                        fontWeight: AppTypography.weightStrong,
                                        letterSpacing: AppTypography.lsLabel,
                                      ),
                                    ),
                                  ),
                                ),

                                _buildTab(
                                  context, 
                                  'Me', 
                                  null, 
                                  widget.selectedTab == MarkerTab.verifier, 
                                  () => widget.onTabChanged(MarkerTab.verifier),
                                  activeColor: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                        
                        // Row 3: Mini Keypad + Navigation
                        Row(
                          children: [
                            // Left Column: Previous Button
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildSubtleNavButton(
                                  context,
                                  'Prev',
                                  () => setState(() => _currentHoleIndex--),
                                  isDisabled: _currentHoleIndex <= 0,
                                ),
                              ),
                            ),
                            
                            // Center Column: Keypad
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
                                    style: AppTypography.displayPage.copyWith(
                                      color: Theme.of(context).primaryColor,
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
                            
                            // Right Column: Next Button
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _buildSubtleNavButton(
                                  context,
                                  'Next',
                                  () {
                                    if (currentHoleNum < 18) {
                                      setState(() => _currentHoleIndex++);
                                    }
                                  },
                                  isPrimary: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildSubtleNavButton(BuildContext context, String label, VoidCallback? onTap, {bool isDisabled = false, bool isPrimary = false}) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
        child: Text(
          label,
          style: AppTypography.labelStrong.copyWith(
            fontSize: 14,
            fontWeight: AppTypography.weightBold,
            color: isDisabled ? AppColors.textSecondary : theme.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
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
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 10), // [FIX] Restore button height
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(ref.read(themeControllerProvider).buttonRadius), // [FIX] Standard design token
            border: Border.all(
              color: isActive 
                  ? Colors.transparent 
                  : (isDark ? AppColors.dark500 : AppColors.dark100),
              width: 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$label${score != null ? ': $score' : ''}',
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightStrong,
                  letterSpacing: AppTypography.lsLabel,
                  color: (hasConflict) 
                      ? AppColors.coral500 
                      : (isActive 
                          ? activeTextColor 
                          : (isDisabled ? AppColors.dark200 : AppColors.dark300)),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44, // [FIX] Increased size
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent, // [FIX] Remove fill
          border: Border.all(
            color: isDisabled 
                ? AppColors.textSecondary.withValues(alpha: AppColors.opacitySubtle)
                : (isDark ? AppColors.dark400 : AppColors.dark150), // [FIX] Dark border
            width: 1.5,
          ),
        ),
        child: Icon(
          icon, 
          size: 20, // [FIX] Increased icon size
          color: isDisabled ? AppColors.textSecondary : theme.colorScheme.onSurface,
        ),
      ),
    );
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
