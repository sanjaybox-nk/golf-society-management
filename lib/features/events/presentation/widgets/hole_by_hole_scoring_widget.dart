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
import 'package:golf_society/features/events/logic/event_scoring_controller.dart';
import 'package:golf_society/features/events/presentation/widgets/submission_progress_bar.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import '../state/marker_selection_provider.dart';
import '../tabs/event_tabs_state.dart';

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
    final currentUserId = ref.watch(effectiveUserProvider).id;
    final activeMarkerId = widget.targetScorecard?.markerId ?? widget.targetScorecard?.submittedByUserId;
    
    // [NEW] Marker Lock logic: If it's a team/multiple entry card, only the active marker (or admin) can edit.
    final bool isNotMarker = activeMarkerId != null && activeMarkerId != 'system' && activeMarkerId != currentUserId;
    final bool isReadOnly = !widget.isAdmin && (widget.event.isScoringLocked == true || widget.event.status == EventStatus.completed || isNotMarker);

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
                          child: Row(
                            children: [
                              if (!_isMatchView)
                                _buildTab(
                                  context, 
                                  'Player', 
                                  null, 
                                  widget.selectedTab == MarkerTab.player, 
                                  () => widget.onTabChanged(MarkerTab.player),
                                  isDisabled: widget.isSelfMarking, 
                                  activeColor: theme.colorScheme.primary,
                                ),
                              
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

                              if (!_isMatchView)
                                _buildTab(
                                  context, 
                                  'Me', 
                                  null, 
                                  widget.selectedTab == MarkerTab.verifier, 
                                  () => widget.onTabChanged(MarkerTab.verifier),
                                  activeColor: theme.colorScheme.primary,
                                ),

                              if (!_isMatchView)
                                _buildTab(
                                  context, 
                                  'Verify', 
                                  null, 
                                  widget.selectedTab == MarkerTab.verify, 
                                  () => widget.onTabChanged(MarkerTab.verify),
                                  activeColor: AppColors.lime500,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                        
                    // Row 3: Mini Keypad + Navigation
                    if (widget.selectedTab == MarkerTab.verify)
                      _buildVerifyView(context, currentHoleNum, par)
                    else if (_isMatchView && matchResult != null)
                      _buildMatchDualRow(context, currentHoleNum, par, isReadOnly)
                    else
                      _buildStandardScoringRow(context, currentHoleNum, currentScore, par, isReadOnly),
                    if (comp?.rules.format == CompetitionFormat.scramble && widget.selectedTab == MarkerTab.player)
                      _buildDriveAttributionPicker(comp!.rules),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyView(BuildContext context, int currentHoleNum, int par) {
    final theme = Theme.of(context);
    final scoringData = ref.watch(eventScoringControllerProvider(widget.event.id));
    
    return Column(
      children: [
        if (scoringData.totalParticipants > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: SubmissionProgressBar(
              total: scoringData.totalParticipants,
              submitted: scoringData.submittedCount,
              inProgress: scoringData.inProgressCount,
            ),
          ),
        
        // Verification Handshake
        _buildVerificationGrid(context, scoringData),
        const SizedBox(height: AppSpacing.xl),
        
        Row(
          children: [
            Expanded(
              child: _buildVerificationHandshake(
                context, 
                'Player', 
                _activeScorecard?.verifiedByPlayer ?? false, 
                _activeScorecard?.verifiedByMarker ?? false,
                isPlayer: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildVerificationHandshake(
                context, 
                'Marker', 
                _activeScorecard?.verifiedByMarker ?? false,
                _activeScorecard?.verifiedByPlayer ?? false,
                isPlayer: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        
        // Hole Stories List
        if (_activeScorecard != null && _activeScorecard!.holeTags.values.any((t) => t.isNotEmpty)) ...[
          const BoxyArtSectionTitle(title: 'Round Story Breakdown'),
          const SizedBox(height: AppSpacing.md),
          ..._activeScorecard!.holeTags.entries
              .where((e) => e.value.isNotEmpty)
              .map((e) => _buildHoleStoryTile(context, e.key, e.value)),
        ],
      ],
    );
  }

  Widget _buildHoleStoryTile(BuildContext context, int holeNum, List<String> tags) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark800 : AppColors.dark50,
        borderRadius: AppShapes.md,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$holeNum',
              style: AppTypography.micro.copyWith(color: theme.primaryColor, fontWeight: AppTypography.weightBlack),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs,
              children: tags.map((t) => _buildMiniTag(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String tag) {
    String label = tag;
    Color color = AppColors.dark400;
    
    if (tag == 'PICK_UP') { label = 'PICKED UP'; color = AppColors.coral500; }
    else if (tag == 'NOT_PLAYED') { label = 'NR'; color = AppColors.dark600; }
    else if (tag == 'GIMME') { label = 'GIMME'; color = AppColors.lime500; }
    else if (tag.startsWith('PENALTY_')) { label = 'PENALTY'; color = AppColors.amber500; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.nano.copyWith(color: color, fontWeight: AppTypography.weightBold),
      ),
    );
  }

  Widget _buildVerificationHandshake(BuildContext context, String label, bool isSigned, bool otherSigned, {required bool isPlayer}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(effectiveUserProvider);
    final bool canSign = isPlayer ? (widget.targetEntryId == currentUser.id) : (widget.verifierScorecard?.markerId == currentUser.id || widget.isAdmin);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSigned ? AppColors.lime500.withValues(alpha: 0.05) : (isDark ? AppColors.dark800 : AppColors.dark50),
        borderRadius: AppShapes.lg,
        border: Border.all(
          color: isSigned ? AppColors.lime500 : (isDark ? AppColors.dark700 : AppColors.dark150),
          width: isSigned ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: isSigned ? AppColors.lime500 : AppColors.textSecondary,
              fontWeight: AppTypography.weightBlack,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSigned)
             const Icon(Icons.check_circle_rounded, color: AppColors.lime500, size: 24)
          else
             BoxyArtButton(
               title: 'Sign Off',
               isSmall: true,
               isPrimary: true,
               onTap: canSign ? () => _handleSignOff(isPlayer) : null,
             ),
        ],
      ),
    );
  }

  Future<void> _handleSignOff(bool isPlayer) async {
    final card = _activeScorecard;
    if (card == null) return;
    
    final updatedCard = isPlayer 
        ? card.copyWith(verifiedByPlayer: true, playerVerifiedAt: DateTime.now())
        : card.copyWith(verifiedByMarker: true, markerVerifiedAt: DateTime.now());
    
    await ref.read(scorecardRepositoryProvider).updateScorecard(updatedCard);
    setState(() => _activeScorecard = updatedCard);
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
          padding: const EdgeInsets.symmetric(vertical: 8), // [FIX] Prevent vertical overflow
            decoration: BoxDecoration(
              color: isActive ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(ref.read(themeControllerProvider).buttonRadius), // [FIX] Standard design token
              border: Border.all(
                color: isActive 
                    ? Colors.transparent 
                    : (isDark ? AppColors.dark700 : AppColors.dark100),
                width: 1,
              ),
            ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$label${score != null ? ': $score' : ''}',
                style: AppTypography.button.copyWith(
                  color: (hasConflict) 
                      ? AppColors.coral500 
                      : (isActive 
                          ? activeTextColor 
                          : (isDisabled ? AppColors.dark200 : Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh))),
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


  void _setScore(int holeNum, int score, {bool isVerifier = false, bool isReadOnly = false}) {
    if (isReadOnly) return;
    
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
      
      // Invalidate signatures on change
      if (isVerifier) {
        if (_localVerifierCard != null) {
          _localVerifierCard = _localVerifierCard!.copyWith(
            verifiedByPlayer: false,
            verifiedByMarker: false,
          );
        }
      } else {
        if (_activeScorecard != null) {
          _activeScorecard = _activeScorecard!.copyWith(
            verifiedByPlayer: false,
            verifiedByMarker: false,
          );
        }
      }
    });
    _persistScores(isVerifier: isVerifier);
  }

  Widget _buildDriveAttributionPicker(CompetitionRules rules) {
    final currentUser = ref.watch(effectiveUserProvider);
    final groupData = widget.event.grouping['groups'] as List?;
    final myGroup = groupData?.firstWhereOrNull((g) => (g['players'] as List).any((p) => p['registrationMemberId'] == currentUser.id));
    if (myGroup == null) return const SizedBox.shrink();
    
    final players = myGroup['players'] as List;
    final teamSize = rules.teamSize;
    int playerIdx = players.indexWhere((p) => p['registrationMemberId'] == currentUser.id);
    int teamIdx = playerIdx ~/ teamSize;
    final teamPlayers = players.skip(teamIdx * teamSize).take(teamSize).toList();
    
    final currentHoleNum = _currentHoleIndex + 1;
    final selectedPlayerId = _shotAttributions[currentHoleNum - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(
          'CHOSEN DRIVE',
          style: AppTypography.micro.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: AppTypography.weightBlack,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: teamPlayers.map((p) {
            final id = p['registrationMemberId'];
            final isSelected = selectedPlayerId == id;
            return _buildDrivePill(
              label: p['name'].toString().split(' ').first,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _shotAttributions[currentHoleNum - 1] = id;
                });
                _persistScores();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDrivePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lime500.withValues(alpha: AppColors.opacityLow) : Colors.transparent,
          borderRadius: AppShapes.pill,
          border: Border.all(
            color: isSelected ? AppColors.lime500 : AppColors.dark400,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.micro.copyWith(
            fontWeight: isSelected ? AppTypography.weightBlack : AppTypography.weightBold,
            color: isSelected ? AppColors.lime500 : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStandardScoringRow(BuildContext context, int currentHoleNum, int currentScore, int par, bool isReadOnly) {
    final theme = Theme.of(context);
    final isVerifier = widget.selectedTab == MarkerTab.verifier;
    final card = isVerifier ? _localVerifierCard : _activeScorecard;
    final tags = card?.holeTags[currentHoleNum] ?? [];
    
    final bool isPickedUp = tags.contains('PICK_UP');
    final bool isNotPlayed = tags.contains('NOT_PLAYED');
    final bool isGimme = tags.contains('GIMME');
    final int penaltyCount = tags.where((t) => t.startsWith('PENALTY_')).length;

    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: BoxyArtButton(
                  title: 'Prev',
                  isGhost: true,
                  isSmall: true,
                  onTap: _currentHoleIndex <= 0 ? null : () => setState(() => _currentHoleIndex--),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMiniCircleButton(
                  context, 
                  Icons.remove, 
                  () => _setScore(currentHoleNum, currentScore - 1, isVerifier: isVerifier, isReadOnly: isReadOnly),
                  isDisabled: isReadOnly || currentScore <= 1 || isPickedUp || isNotPlayed,
                ),
                Container(
                  width: 60, // [FIX] Increased for labels
                  alignment: Alignment.center,
                  child: Text(
                    isNotPlayed ? '—' : (isPickedUp ? 'X' : '$currentScore'),
                    style: AppTypography.displayPage.copyWith(
                      color: isNotPlayed || isPickedUp ? AppColors.coral500 : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildMiniCircleButton(
                  context, 
                  Icons.add, 
                  () => _setScore(currentHoleNum, currentScore + 1, isVerifier: isVerifier, isReadOnly: isReadOnly),
                  isDisabled: isReadOnly || isPickedUp || isNotPlayed,
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: BoxyArtButton(
                  title: 'Next',
                  isPrimary: true,
                  isSmall: true,
                  onTap: currentHoleNum >= 18 ? null : () => setState(() => _currentHoleIndex++),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        // Simplified Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreModifierButton(
              label: 'PICK UP',
              isActive: isPickedUp,
              onTap: () => _toggleTag(currentHoleNum, 'PICK_UP', isVerifier),
              isDisabled: isReadOnly,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildScoreModifierButton(
              label: 'NR',
              isActive: isNotPlayed,
              onTap: () => _toggleTag(currentHoleNum, 'NOT_PLAYED', isVerifier),
              isDisabled: isReadOnly,
            ),
            const SizedBox(width: AppSpacing.xl),
            _buildTagDetailsToggle(currentHoleNum, tags, isReadOnly, isVerifier),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreModifierButton({required String label, required bool isActive, required VoidCallback onTap, bool isDisabled = false}) {
    return BoxyArtButton(
      title: label,
      isSmall: true,
      isGhost: !isActive,
      backgroundColor: isActive ? AppColors.coral500 : null,
      onTap: isDisabled ? null : onTap,
    );
  }

  Widget _buildTagDetailsToggle(int holeNum, List<String> tags, bool isReadOnly, bool isVerifier) {
    final hasTags = tags.any((t) => t == 'GIMME' || t.startsWith('PENALTY_'));
    return GestureDetector(
      onTap: isReadOnly ? null : () => _showHoleDetailsPicker(holeNum, isVerifier),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasTags ? AppColors.amber500.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: hasTags ? AppColors.amber500 : AppColors.dark700.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_motion_rounded, size: 16, color: hasTags ? AppColors.amber500 : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'STORY',
              style: AppTypography.micro.copyWith(
                color: hasTags ? AppColors.amber500 : AppColors.textSecondary,
                fontWeight: AppTypography.weightBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHoleDetailsPicker(int holeNum, bool isVerifier) {
    final card = isVerifier ? _localVerifierCard : _activeScorecard;
    if (card == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final tags = card.holeTags[holeNum] ?? [];
          final bool isGimme = tags.contains('GIMME');
          final int penaltyCount = tags.where((t) => t.startsWith('PENALTY_')).length;

          return BoxyArtCard(
            margin: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BoxyArtSectionTitle(title: 'Hole Story'),
                const SizedBox(height: AppSpacing.md),
                _buildTagPill(
                  label: 'GIMME',
                  icon: Icons.check_circle_outline_rounded,
                  isActive: isGimme,
                  activeColor: AppColors.lime500,
                  onTap: () {
                    _toggleTag(holeNum, 'GIMME', isVerifier);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTagPill(
                  label: 'PENALTY${penaltyCount > 0 ? ' ($penaltyCount)' : ''}',
                  icon: Icons.warning_amber_rounded,
                  isActive: penaltyCount > 0,
                  activeColor: AppColors.amber500,
                  onTap: () {
                    _addPenaltyTag(holeNum, isVerifier);
                    setModalState(() {});
                  },
                  onLongPress: () {
                    _clearPenaltyTags(holeNum, isVerifier);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                BoxyArtButton(
                  title: 'Done',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTagPill({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      onLongPress: isDisabled ? null : onLongPress,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: AppColors.opacityLow) : Colors.transparent,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: isActive ? activeColor : (isDark ? AppColors.dark700 : AppColors.dark200),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? activeColor : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.micro.copyWith(
                color: isActive ? activeColor : AppColors.textSecondary,
                fontWeight: isActive ? AppTypography.weightBlack : AppTypography.weightBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTag(int holeNum, String tag, bool isVerifier) async {
    final card = isVerifier ? _localVerifierCard : _activeScorecard;
    if (card == null) return;
    
    final currentTags = List<String>.from(card.holeTags[holeNum] ?? []);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      // Mutual Exclusivity: NR and PickUp
      if (tag == 'PICK_UP') currentTags.remove('NOT_PLAYED');
      if (tag == 'NOT_PLAYED') currentTags.remove('PICK_UP');
      currentTags.add(tag);
    }
    
    final newTags = Map<int, List<String>>.from(card.holeTags);
    newTags[holeNum] = currentTags;
    
    final updatedCard = card.copyWith(
      holeTags: newTags,
      // If we pick up, we also invalidate the signature as discussed
      verifiedByPlayer: false,
      verifiedByMarker: false,
      updatedAt: DateTime.now(),
    );
    
    await ref.read(scorecardRepositoryProvider).updateScorecard(updatedCard);
    setState(() {
       if (isVerifier) _localVerifierCard = updatedCard;
       else _activeScorecard = updatedCard;
    });
  }

  Future<void> _addPenaltyTag(int holeNum, bool isVerifier) async {
    final card = isVerifier ? _localVerifierCard : _activeScorecard;
    if (card == null) return;
    
    final currentTags = List<String>.from(card.holeTags[holeNum] ?? []);
    // Just add another penalty tag with a unique timestamp or index
    currentTags.add('PENALTY_${DateTime.now().millisecondsSinceEpoch}');
    
    final newTags = Map<int, List<String>>.from(card.holeTags);
    newTags[holeNum] = currentTags;
    
    final updatedCard = card.copyWith(
      holeTags: newTags,
      verifiedByPlayer: false,
      verifiedByMarker: false,
      updatedAt: DateTime.now(),
    );
    
    await ref.read(scorecardRepositoryProvider).updateScorecard(updatedCard);
    setState(() {
       if (isVerifier) _localVerifierCard = updatedCard;
       else _activeScorecard = updatedCard;
    });
  }

  Future<void> _clearPenaltyTags(int holeNum, bool isVerifier) async {
    final card = isVerifier ? _localVerifierCard : _activeScorecard;
    if (card == null) return;
    
    final currentTags = List<String>.from(card.holeTags[holeNum] ?? []);
    currentTags.removeWhere((t) => t.startsWith('PENALTY_'));
    
    final newTags = Map<int, List<String>>.from(card.holeTags);
    newTags[holeNum] = currentTags;
    
    final updatedCard = card.copyWith(
      holeTags: newTags,
      verifiedByPlayer: false,
      verifiedByMarker: false,
      updatedAt: DateTime.now(),
    );
    
    await ref.read(scorecardRepositoryProvider).updateScorecard(updatedCard);
    setState(() {
       if (isVerifier) _localVerifierCard = updatedCard;
       else _activeScorecard = updatedCard;
    });
  }

  Widget _buildMatchDualRow(BuildContext context, int currentHoleNum, int par, bool isReadOnly) {
    final playerAScore = _localScores[currentHoleNum] ?? par;
    final playerBScore = _verifierScores[currentHoleNum] ?? par;

    return Column(
      children: [
        _buildDualParticipantRow(
          context, 
          'Player', 
          playerAScore, 
          (s) => _setScore(currentHoleNum, s, isVerifier: false, isReadOnly: isReadOnly),
          isReadOnly,
          isPrimary: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDualParticipantRow(
          context, 
          'Me', 
          playerBScore, 
          (s) => _setScore(currentHoleNum, s, isVerifier: true, isReadOnly: isReadOnly),
          isReadOnly,
          isPrimary: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BoxyArtButton(
              title: 'Prev Hole',
              isGhost: true,
              isSmall: true,
              onTap: _currentHoleIndex <= 0 ? null : () => setState(() => _currentHoleIndex--),
            ),
            BoxyArtButton(
              title: 'Next Hole',
              isPrimary: true,
              isSmall: true,
              onTap: currentHoleNum >= 18 ? null : () => setState(() => _currentHoleIndex++),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDualParticipantRow(BuildContext context, String label, int score, Function(int) onChanged, bool isReadOnly, {bool isPrimary = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppShapes.md,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.micro.copyWith(
                color: isPrimary ? theme.colorScheme.primary : AppColors.textSecondary,
                fontWeight: AppTypography.weightBlack,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniCircleButton(
                context, 
                Icons.remove, 
                () => onChanged(score - 1),
                isDisabled: isReadOnly || score <= 1,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: AppTypography.displaySection.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              _buildMiniCircleButton(
                context, 
                Icons.add, 
                () => onChanged(score + 1),
                isDisabled: isReadOnly,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationGrid(BuildContext context, ProcessedEventData scoringData) {
    final theme = Theme.of(context);
    
    // Find Player's own card
    final allCards = ref.watch(scorecardsListProvider(widget.event.id)).value ?? [];
    final playerOwnCard = allCards.firstWhereOrNull((s) => s.entryId == widget.targetEntryId && s.markerId == widget.targetEntryId);
    
    // Marker's card for player (the one we are currently marking)
    final markerCard = _activeScorecard;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('COMPARISON GUIDE', style: AppTypography.nano.copyWith(fontWeight: AppTypography.weightBlack, letterSpacing: 1.0)),
                Text('PLAYER VS MARKER', style: AppTypography.nano.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVerifyRow(context, 'HOLE', List.generate(18, (i) => '${i + 1}'), isHeader: true),
                _buildVerifyRow(context, 'PAR', widget.event.courseConfig.holes.map((h) => h.par.toString()).toList(), isDimmed: true),
                const Divider(height: 1),
                _buildVerifyRow(context, 'PLAYER', List.generate(18, (i) => playerOwnCard?.holeScores[i]?.toString() ?? '-')),
                _buildVerifyRow(
                  context, 
                  'MARKER', 
                  List.generate(18, (i) => markerCard?.holeScores[i]?.toString() ?? '-'),
                  comparisonList: List.generate(18, (i) => playerOwnCard?.holeScores[i]?.toString() ?? '-'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyRow(BuildContext context, String label, List<String> values, {bool isHeader = false, bool isDimmed = false, List<String>? comparisonList}) {
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Text(
            label,
            style: AppTypography.nano.copyWith(
              color: isHeader ? AppColors.dark400 : (isDimmed ? AppColors.dark300 : null),
              fontWeight: AppTypography.weightBlack,
            ),
          ),
        ),
        for (int i = 0; i < values.length; i++)
          (() {
            final val = values[i];
            final compare = comparisonList != null ? comparisonList[i] : null;
            final bool isMismatch = compare != null && val != '-' && compare != '-' && val != compare;
            
            return Container(
              width: 32,
              height: 28,
              alignment: Alignment.center,
              decoration: isMismatch ? BoxDecoration(
                color: AppColors.coral500.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.coral500, width: 0.5),
              ) : null,
              child: Text(
                val,
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  fontWeight: isMismatch ? AppTypography.weightBlack : (isHeader ? AppTypography.weightBold : AppTypography.weightRegular),
                  color: isMismatch ? AppColors.coral500 : (isDimmed ? AppColors.dark300 : null),
                ),
              ),
            );
          })(),
      ],
    );
  }
}
