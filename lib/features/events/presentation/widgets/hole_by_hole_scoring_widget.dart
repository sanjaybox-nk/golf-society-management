import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/features/events/logic/event_scoring_controller.dart';
import 'package:golf_society/features/events/presentation/widgets/scoring/scoring_entry_view.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/features/events/presentation/tabs/event_tabs_state.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/matchplay/presentation/widgets/match_status_header.dart';
import 'package:golf_society/features/matchplay/presentation/state/match_play_providers.dart';

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
  bool _isMatchView = false; // [NEW] Dual scoring mode for match play

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
      final map = isVerifier ? _verifierScores : _localScores;
      final entryId = isVerifier ? userId : _activeEntryId;
      if (entryId == null) return;
    
    // Determine which card we are updating
    final cardToUpdate = isVerifier ? _localVerifierCard : _activeScorecard;
    // Calculate totals only for Main/Hole scores
    final scoresList = List<int?>.generate(18, (i) => map[i + 1]);
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
    final comp = ref.watch(competitionDetailProvider(widget.event.id)).asData?.value;
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

    final int currentHoleNum = _currentHoleIndex + 1;
    if (holes.isNotEmpty && _currentHoleIndex >= 0 && _currentHoleIndex < holes.length) {
      // par assignment removed as unused
    }

    final currentUserId = ref.watch(effectiveUserProvider).id;
    final activeMarkerId = widget.targetScorecard?.markerId ?? widget.targetScorecard?.submittedByUserId;
    
    // [NEW] Marker Lock logic: If it's a team/multiple entry card, only the active marker (or admin) can edit.
    final bool isNotMarker = activeMarkerId != null && activeMarkerId != 'system' && activeMarkerId != currentUserId;
    final bool isReadOnly = !widget.isAdmin && (widget.event.isScoringLocked == true || widget.event.status == EventStatus.completed || isNotMarker);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Row(
                      children: [
                        if (!_isMatchView && !widget.isSelfMarking) ...[
                          _buildTab(
                            context, 
                            'PLAYER', 
                            null, 
                            widget.selectedTab == MarkerTab.player, 
                            () => widget.onTabChanged(MarkerTab.player),
                            activeColor: theme.colorScheme.primary,
                          ),
                          _buildTab(
                            context, 
                            'ME', 
                            null, 
                            widget.selectedTab == MarkerTab.verifier, 
                            () => widget.onTabChanged(MarkerTab.verifier),
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                        
                        if (matchResult != null)
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.xs),
                            child: _buildTab(
                              context, 
                              'Duel', 
                              null, 
                              _isMatchView, 
                              () => setState(() => _isMatchView = !_isMatchView),
                              activeColor: AppColors.lime500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
                  
              // Row 3: Main Scoring Area or Verification
              ScoringEntryView(
                event: widget.event,
                targetEntryId: widget.targetEntryId ?? '',
                activeEntryId: _activeEntryId,
                scoringData: ref.watch(eventScoringControllerProvider(widget.event.id)),
                currentHoleIndex: _currentHoleIndex,
                localScores: _localScores,
                verifierScores: _verifierScores,
                isReadOnly: isReadOnly,
                isMatchPlay: comp?.rules.format == CompetitionFormat.matchPlay,
                isDriveAttributionEnabled: comp?.rules.format == CompetitionFormat.scramble && widget.selectedTab == MarkerTab.player,
                activeScorecard: _activeScorecard,
                localVerifierCard: _localVerifierCard,
                onHoleChanged: (holeNum) => setState(() => _currentHoleIndex = holeNum - 1),
                onScoreChanged: _setScore,
                onDriveAttributionChanged: _updateDriveAttribution,
                onScorecardUpdated: (updatedCard) {
                  ref.read(scorecardRepositoryProvider).updateScorecard(updatedCard);
                },
              ),
            ],
          ),
        ),
      ],
    );

    return BoxyArtCard(
      key: ValueKey('scoring_card_${widget.selectedTab}'),
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  void _setScore(int holeNum, int score, {required bool isVerifier}) {
    setState(() {
      if (!isVerifier) {
        _localScores[holeNum] = score;
      } else {
        _verifierScores[holeNum] = score;
      }
    });
    _persistScores(isVerifier: isVerifier);
  }

  void _updateDriveAttribution(int holeIndex, String? memberId) {
    setState(() {
      if (memberId == null) {
        _shotAttributions.remove(holeIndex);
      } else {
        _shotAttributions[holeIndex] = memberId;
      }
    });
    _persistScores();
  }


  Widget _buildTab(BuildContext context, String label, IconData? icon, bool active, VoidCallback onTap, {Color? activeColor}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: active ? (activeColor ?? theme.colorScheme.primary).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: active ? (activeColor ?? theme.colorScheme.primary) : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
