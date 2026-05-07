import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/utils/string_utils.dart';

class VerticalHoleScoringList extends ConsumerStatefulWidget {
  final GolfEvent event;
  final ProcessedEventData? scoringData;
  final VoidCallback? onMarkerSelectionTap;
  final VoidCallback? onVerifyTap;

  const VerticalHoleScoringList({
    super.key,
    required this.event,
    this.scoringData,
    this.onMarkerSelectionTap,
    this.onVerifyTap,
  });

  @override
  ConsumerState<VerticalHoleScoringList> createState() => _VerticalHoleScoringListState();
}

class _VerticalHoleScoringListState extends ConsumerState<VerticalHoleScoringList> {
  late PageController _pageController;
  int _currentPage = 0;

  
  @override
  void initState() {
    super.initState();
    final storedHoleIndex = ref.read(markerSelectionProvider).lastViewedHoleIndex;
    _currentPage = storedHoleIndex.clamp(0, 17);
    
    _pageController = PageController(initialPage: _currentPage);
    
    // [NEW] Validate markers immediately on hub load to purge stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scoringData != null) {
        final validIds = widget.scoringData!.leaderboard.map((e) => e.entryId).toList();
        ref.read(markerSelectionProvider.notifier).validateTargets(validIds);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(effectiveUserProvider);
    final markerSelection = ref.watch(markerSelectionProvider);
    final allScorecards = ref.watch(scorecardsListProvider(widget.event.id)).asData?.value ?? [];
    
    final isGroupScorer = markerSelection.isGroupScorer;
    final groupPlayersRaw = widget.scoringData?.leaderboard.map((e) => e.entryId).toList() ?? [];
    final otherPlayersIds = groupPlayersRaw.where((id) => id != currentUser.id).toList();

    final localTargets = markerSelection.targetEntryIds;

    final List<String> targetEntryIds = isGroupScorer
        ? otherPlayersIds
        : localTargets.toList();

    final bool isSelfMarking = markerSelection.isSelfMarking;
    
    // For TEE configuration, we usually use the first target or self
    final String primaryTargetId = (isSelfMarking || targetEntryIds.isEmpty) 
        ? currentUser.id
        : targetEntryIds.first;

    final members = ref.watch(allMembersProvider).value ?? [];
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: primaryTargetId, 
      event: widget.event, 
      membersList: members,
    );
    final holes = playerTeeConfig.holes;

    if (holes.isEmpty) return const SizedBox.shrink();

    final compAsync = ref.watch(competitionDetailProvider(widget.event.id));
    final rules = compAsync.asData?.value?.rules ?? CompetitionRules();
    final isStableford = rules.format == CompetitionFormat.stableford;

    final int totalCards = (isSelfMarking ? 1 : 0) + targetEntryIds.length;
    final double cardHeight = 155.0; // Estimate per card with spacing
    final double containerHeight = 120.0 + (totalCards * cardHeight);

    final bool isLocked = widget.event.status == EventStatus.completed;

    final myScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);
    final String? myMarkerId = markerSelection.myMarkerId ?? myScorecard?.markerId;
    final String? myMarkerName = myMarkerId == currentUser.id 
        ? 'ME' 
        : (myMarkerId != null ? _getDisplayName(members, myMarkerId) : null);

    return Column(
      children: [
        // Marker Selection Trigger
        _buildMarkerSelector(members, targetEntryIds, isSelfMarking, _currentPage),

        const SizedBox(height: AppSpacing.xs),

        const SizedBox(height: AppSpacing.sm),

        // Paging Area
        SizedBox(
          height: containerHeight.clamp(240.0, 800.0),
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            onPageChanged: (page) {
              if (!mounted) return;
              setState(() => _currentPage = page);
              ref.read(markerSelectionProvider.notifier).setLastViewedHole(page);
            },
            itemCount: 18,
            itemBuilder: (context, index) {
              final myStats = widget.scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == currentUser.id);
              final myEntry = widget.scoringData?.leaderboard.firstWhereOrNull((e) => e.entryId == currentUser.id);
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // MY CARD
                    if (isSelfMarking) ...[
                      (() {
                        final myCourseConfig = ScoringCalculator.resolvePlayerCourseConfig(
                          memberId: currentUser.id, 
                          event: widget.event, 
                          membersList: [...members, currentUser], 
                          manualTeeName: markerSelection.teeOverrides[currentUser.id],
                          gender: currentUser.gender,
                        );

                        // FIND BEST SCORE: Marker Card (ours) > Player Card (seeded/other) > Global Stats
                        final myMarkerCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id && s.markerId == currentUser.id);
                        final mySeedCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id && s.markerId != currentUser.id);
                        
                        final int? markerScore = myMarkerCard?.holeScores.elementAtOrNull(index);
                        final int? seedScore = mySeedCard?.holeScores.elementAtOrNull(index);
                        final int? displayScore = markerScore ?? seedScore ?? myStats?.holeScores.elementAtOrNull(index);

                        final myActiveCard = myMarkerCard ?? mySeedCard;
                        final myConflicts = _computeConflictedHoles(myActiveCard);
                        return _PlayerScoringCard(
                          label: '',
                          name: currentUser.displayName,
                          hc: currentUser.handicap.toDouble(),
                          phc: HandicapCalculator.calculatePlayingHandicap(
                            handicapIndex: currentUser.handicap.toDouble(),
                            rules: widget.event.courseConfig.holes.any((h) => h.par == 0) ? const CompetitionRules() : (ref.watch(competitionDetailProvider(widget.event.id)).value?.rules ?? const CompetitionRules()),
                            courseConfig: myCourseConfig,
                            societyCut: widget.event.manualCuts[currentUser.id] ?? 0.0,
                          ),
                          teeName: myCourseConfig.selectedTeeName,
                          teeColorStr: myCourseConfig.selectedTeeColor,
                          par: myCourseConfig.holes[index].par,
                          si: myCourseConfig.holes[index].si,
                          score: displayScore,
                          hint: seedScore,
                          thru: myStats?.thruLabel,
                          points: myStats?.result.score,
                          matchStatus: myEntry?.matchStatus,
                          onChanged: isLocked ? (_) {} : (s) => _updateScore(currentUser.id, index, s, allScorecards),
                          isStableford: isStableford,
                          isLocked: isLocked,
                          isMe: true,
                          markerName: myMarkerName,
                          holeTags: myActiveCard?.holeTags[index + 1] ?? [],
                          onStoryTap: isLocked ? null : () => _showStorySheet(context, currentUser.id, index + 1),
                          hasConflict: myConflicts.contains(index + 1),
                        );
                      })(),
                      if (targetEntryIds.isNotEmpty) const SizedBox(height: AppSpacing.md),
                    ],
                    
                    for (final tId in targetEntryIds) ...[
                      _buildTargetCard(context, currentUser, tId, index, members, allScorecards, isStableford, isLocked),
                      if (tId != targetEntryIds.last) const SizedBox(height: AppSpacing.md),
                    ],

                    const SizedBox(height: AppSpacing.cardToLabel),

                    // Hole Navigation Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _NavigationArrow(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: index > 0 ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ) : null,
                          ),
                          _NavigationArrow(
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: index < 17 ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ) : null,
                          ),
                        ],
                      ),
                    ),
                    if (widget.onVerifyTap != null) ...[
                      const SizedBox(height: AppSpacing.standard),
                      BoxyArtButton(
                        title: 'Verify Score',
                        isPrimary: true,
                        fullWidth: true,
                        onTap: widget.onVerifyTap,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl), // Bottom breathing room
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarkerSelector(List<Member> members, List<String> targetEntryIds, bool isSelfMarking, int holeIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left-aligned Hole Indicator
          Text(
            'HOLE ${holeIndex + 1}',
            style: AppTypography.headline.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppColors.dark950,
              fontSize: 18,
            ),
          ),

          // Right-aligned Marker Toggle
          GestureDetector(
            onTap: widget.event.status == EventStatus.completed ? null : widget.onMarkerSelectionTap,
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.event.status == EventStatus.completed ? AppColors.dark300 : AppColors.lime500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.event.status == EventStatus.completed
                        ? 'ARCHIVED MARKERS'
                        : (isSelfMarking && targetEntryIds.isEmpty
                            ? 'MARKING: SELF' 
                            : (targetEntryIds.isNotEmpty 
                                ? (isSelfMarking 
                                    ? 'MARKING: ME + ${targetEntryIds.length}'
                                    : (targetEntryIds.length == 1 
                                        ? 'MARKING: ${toTitleCase(_getDisplayName(members, targetEntryIds.first).split(' ').first)}' 
                                        : 'MARKING: ${targetEntryIds.length} PLAYERS'))
                                : 'MARKING: SELECT')),
                    style: AppTypography.micro.copyWith(
                      color: widget.event.status == EventStatus.completed ? AppColors.dark300 : AppColors.dark400,
                      fontWeight: AppTypography.weightExtraBold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (widget.event.status != EventStatus.completed)
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.dark400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTargetCard(
    BuildContext context, 
    Member currentUser,
    String tId, 
    int index, 
    List<Member> members, 
    List<Scorecard> allCards,
    bool isStableford,
    bool isLocked,
  ) {
    final targetStats = widget.scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == tId);
    final targetEntry = widget.scoringData?.leaderboard.firstWhereOrNull((e) => e.entryId == tId);
    
    // ONE CARD MODEL: Find the primary scorecard for the player
    final scorecard = allCards.firstWhereOrNull((s) => s.entryId == tId);
    
    // Display marker's input (playerVerifierScores) if we are the marker, otherwise fallback to their own holeScores
    final int? mScore = scorecard?.playerVerifierScores.elementAtOrNull(index);
    final int? pScore = scorecard?.holeScores.elementAtOrNull(index);
    final int? dScore = mScore ?? pScore ?? targetStats?.holeScores.elementAtOrNull(index);

    final targetCourseConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: tId, 
      event: widget.event, 
      membersList: members,
      manualTeeName: ref.read(markerSelectionProvider).teeOverrides[tId],
    );

    final markerId = scorecard?.markerId;
    final markerName = markerId == currentUser.id ? 'ME' : (markerId != null ? _getDisplayName(members, markerId) : null);

    final targetConflicts = _computeConflictedHoles(scorecard);
    return _PlayerScoringCard(
      label: '',
      name: _getDisplayName(members, tId),
      hc: targetStats?.handicapIndex ?? (members.firstWhereOrNull((m) => m.id == tId)?.handicap.toDouble() ?? 18.0),
      phc: targetStats?.playingHandicap ?? (members.firstWhereOrNull((m) => m.id == tId)?.handicap.toInt() ?? 18),
      teeName: targetStats?.teeName,
      teeColorStr: targetStats?.teeColor,
      par: targetCourseConfig.holes[index].par,
      si: targetCourseConfig.holes[index].si,
      score: dScore,
      hint: pScore,
      thru: targetStats?.thruLabel,
      points: targetStats?.result.score,
      matchStatus: targetEntry?.matchStatus,
      onChanged: isLocked ? (_) {} : (s) => _updateScore(tId, index, s, allCards),
      isStableford: isStableford,
      isLocked: isLocked,
      isMe: false,
      markerName: markerName,
      holeTags: scorecard?.holeTags[index + 1] ?? [],
      onStoryTap: isLocked ? null : () => _showStorySheet(context, tId, index + 1),
      hasConflict: targetConflicts.contains(index + 1),
    );
  }

  void _updateScore(String entryId, int holeIndex, int score, List<Scorecard> allCards) async {
    final currentUser = ref.read(effectiveUserProvider);
    final scorecard = allCards.firstWhereOrNull((s) => s.entryId == entryId);

    try {
      if (scorecard != null) {
        if (entryId == currentUser.id) {
          final List<int?> updatedScores = List<int?>.from(scorecard.holeScores);
          if (updatedScores.length < 18) {
            updatedScores.addAll(List.generate(18 - updatedScores.length, (i) => null));
          }
          updatedScores[holeIndex] = score;
          await ref.read(scorecardRepositoryProvider).updateScorecard(scorecard.copyWith(
            holeScores: updatedScores,
            updatedAt: DateTime.now(),
          ));
        } else {
          final List<int?> updatedVerifierScores = List<int?>.from(scorecard.playerVerifierScores);
          if (updatedVerifierScores.length < 18) {
            updatedVerifierScores.addAll(List.generate(18 - updatedVerifierScores.length, (i) => null));
          }
          updatedVerifierScores[holeIndex] = score;
          await ref.read(scorecardRepositoryProvider).updateScorecard(scorecard.copyWith(
            playerVerifierScores: updatedVerifierScores,
            markerId: currentUser.id,
            updatedAt: DateTime.now(),
          ));
        }
        HapticFeedback.lightImpact();
      } else {
        final bool isMe = entryId == currentUser.id;
        final List<int?> initialScores = List.generate(18, (i) => i == holeIndex ? score : null);
        final newCard = Scorecard(
          id: '',
          competitionId: widget.event.id,
          roundId: widget.event.id,
          entryId: entryId,
          markerId: isMe ? entryId : currentUser.id,
          submittedByUserId: currentUser.id,
          holeScores: isMe ? initialScores : [],
          playerVerifierScores: isMe ? [] : initialScores,
          status: ScorecardStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.read(scorecardRepositoryProvider).addScorecard(newCard);
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save score — check your connection and try again.')),
        );
      }
    }
  }

  String _getDisplayName(List<Member> members, String id) {
    return members.firstWhereOrNull((m) => m.id == id)?.displayName ?? 'Player';
  }

  Set<int> _computeConflictedHoles(Scorecard? scorecard) {
    if (scorecard == null) return const {};
    final conflicts = <int>{};
    for (int i = 0; i < 18; i++) {
      final pScore = scorecard.holeScores.elementAtOrNull(i);
      final mScore = scorecard.playerVerifierScores.elementAtOrNull(i);
      if (pScore != null && mScore != null && pScore != mScore) {
        conflicts.add(i + 1);
      }
    }
    return conflicts;
  }

  void _showStorySheet(BuildContext context, String entryId, int holeNum) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Hole Story',
      initialChildSize: 0.5,
      minChildSize: 0.45,
      maxChildSize: 0.65,
      child: StatefulBuilder(
        builder: (ctx, setModalState) {
          final allCards = ref.read(scorecardsListProvider(widget.event.id)).asData?.value ?? [];
          final scorecard = allCards.firstWhereOrNull((s) => s.entryId == entryId);
          if (scorecard == null) return const SizedBox.shrink();

          final tags = List<String>.from(scorecard.holeTags[holeNum] ?? []);
          final isGimme = tags.contains('GIMME');
          final isPickUp = tags.contains('PICK_UP');
          // PENALTY_1_<ts> = 1-stroke, PENALTY_2_<ts> = 2-stroke
          // Legacy PENALTY_<ts> (no type digit) treated as 1-stroke
          final p1Count = tags.where((t) => t.startsWith('PENALTY_1_') || (t.startsWith('PENALTY_') && !t.startsWith('PENALTY_1_') && !t.startsWith('PENALTY_2_'))).length;
          final p2Count = tags.where((t) => t.startsWith('PENALTY_2_')).length;
          final hasPenalties = p1Count > 0 || p2Count > 0;

          void persist(List<String> updated) {
            final updatedTags = Map<int, List<String>>.from(scorecard.holeTags);
            updatedTags[holeNum] = updated;
            ref.read(scorecardRepositoryProvider).updateScorecard(scorecard.copyWith(holeTags: updatedTags));
            setModalState(() {});
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: BoxyArtButton(
                      title: 'Gimme',
                      icon: Icons.check_circle_outline_rounded,
                      fullWidth: true,
                      backgroundColor: isGimme ? AppColors.lime500 : null,
                      textColor: isGimme ? Colors.white : null,
                      onTap: () {
                        if (isGimme) { tags.remove('GIMME'); } else { tags.add('GIMME'); }
                        persist(tags);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: BoxyArtButton(
                      title: 'Pick Up',
                      icon: Icons.upload_rounded,
                      fullWidth: true,
                      backgroundColor: isPickUp ? AppColors.coral500 : null,
                      textColor: isPickUp ? Colors.white : null,
                      onTap: () {
                        if (isPickUp) { tags.remove('PICK_UP'); } else { tags.add('PICK_UP'); }
                        persist(tags);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.standard),
              Text(
                'PENALTY STROKES',
                style: AppTypography.label.copyWith(
                  color: AppColors.dark400,
                  fontWeight: AppTypography.weightBold,
                  letterSpacing: AppTypography.lsLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.atomic),
              Row(
                children: [
                  Expanded(
                    child: BoxyArtButton(
                      title: '+1 Stroke${p1Count > 0 ? ' (×$p1Count)' : ''}',
                      icon: Icons.add_circle_outline_rounded,
                      fullWidth: true,
                      backgroundColor: p1Count > 0 ? AppColors.amber500 : null,
                      textColor: p1Count > 0 ? Colors.white : null,
                      onTap: () {
                        tags.add('PENALTY_1_${DateTime.now().millisecondsSinceEpoch}');
                        persist(tags);
                      },
                      onLongPress: p1Count > 0 ? () {
                        tags.removeWhere((t) => t.startsWith('PENALTY_1_') || (t.startsWith('PENALTY_') && !t.startsWith('PENALTY_1_') && !t.startsWith('PENALTY_2_')));
                        persist(tags);
                      } : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: BoxyArtButton(
                      title: '+2 Strokes${p2Count > 0 ? ' (×$p2Count)' : ''}',
                      icon: Icons.add_circle_outline_rounded,
                      fullWidth: true,
                      backgroundColor: p2Count > 0 ? AppColors.amber500 : null,
                      textColor: p2Count > 0 ? Colors.white : null,
                      onTap: () {
                        tags.add('PENALTY_2_${DateTime.now().millisecondsSinceEpoch}');
                        persist(tags);
                      },
                      onLongPress: p2Count > 0 ? () {
                        tags.removeWhere((t) => t.startsWith('PENALTY_2_'));
                        persist(tags);
                      } : null,
                    ),
                  ),
                ],
              ),
              if (hasPenalties) ...[
                const SizedBox(height: AppSpacing.atomic),
                Text(
                  'Long-press to clear that type',
                  style: AppTypography.micro.copyWith(color: AppColors.dark400),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

}

class _PlayerScoringCard extends ConsumerStatefulWidget {
  final String label;
  final String name;
  final double hc;
  final int phc;
  final String? teeName;
  final String? teeColorStr;
  final int? score;
  final int? hint;
  final String? thru;
  final int? points;
  final String? matchStatus;
  final int? par;
  final int? si;
  final String? markerName;
  final bool isMe;
  final ValueChanged<int> onChanged;
  final bool isStableford;
  final bool isLocked;
  final List<String> holeTags;
  final VoidCallback? onStoryTap;
  final bool hasConflict;

  const _PlayerScoringCard({
    required this.label,
    required this.name,
    required this.hc,
    required this.phc,
    this.teeName,
    this.teeColorStr,
    this.score,
    this.hint,
    this.thru,
    this.points,
    this.matchStatus,
    this.par,
    this.si,
    this.markerName,
    this.isMe = false,
    required this.onChanged,
    this.isStableford = true,
    this.isLocked = false,
    this.holeTags = const [],
    this.onStoryTap,
    this.hasConflict = false,
  });

  @override
  ConsumerState<_PlayerScoringCard> createState() => _PlayerScoringCardState();
}

class _PlayerScoringCardState extends ConsumerState<_PlayerScoringCard> {
  static const double horizontalPadding = AppSpacing.standard;

  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.score == null || widget.score == 0 ? '' : '${widget.score}',
    );
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  @override
  void didUpdateWidget(_PlayerScoringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score && !_focusNode.hasFocus) {
      _controller.text = widget.score == null || widget.score == 0 ? '' : '${widget.score}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _getScoreColor() {
    final config = ref.watch(themeControllerProvider);
    return Color(config.effectivePointsColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shapes = theme.extension<AppShapeTokens>();
    final spacing = theme.extension<AppSpacingTokens>();
    return Container(
      padding: EdgeInsets.all(spacing?.cardVerticalPadding ?? AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark800 : theme.cardColor,
        borderRadius: shapes?.card,
        border: Border.all(
          color: isDark ? AppColors.dark700 : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: theme.extension<AppShadows>()?.softScale,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: Player Info (long-press for hole story)
            Expanded(
              child: GestureDetector(
                onLongPress: widget.isLocked ? null : widget.onStoryTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.label.isNotEmpty)
                    Text(
                      widget.label,
                      style: AppTypography.micro.copyWith(
                        color: AppColors.dark300,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  if (widget.label.isNotEmpty) const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.name,
                          style: AppTypography.memberName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      BoxyArtIndicator.hc(label: widget.hc.toStringAsFixed(1), hasHorizontalMargin: false),
                      BoxyArtIndicator.phc(context: context, label: '${widget.phc}'),
                    ],
                  ),
  
                  if (widget.isMe && widget.markerName != null) ...[
                    const Spacer(),
                    const SizedBox(height: 8),
                    Text(
                      'MARKED BY ${widget.markerName!.toUpperCase()}',
                      style: AppTypography.micro.copyWith(
                        fontSize: 10,
                        color: AppColors.dark400,
                        fontWeight: FontWeight.w100,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
                ),
              ),
            ),

          const SizedBox(width: AppSpacing.md),

          // Right Interaction Area (Box-anchored centering)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.par != null || widget.si != null || widget.teeName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.par != null)
                              Text(
                                'P${widget.par}',
                                style: AppTypography.micro.copyWith(
                                  color: AppColors.dark500,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            if (widget.par != null && widget.si != null)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('•', style: TextStyle(color: AppColors.dark200, fontSize: 10)),
                              ),
                            if (widget.si != null)
                              Text(
                                'SI ${widget.si}',
                                style: AppTypography.micro.copyWith(
                                  color: AppColors.dark500,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            if (widget.teeName != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('•', style: TextStyle(color: AppColors.dark200, fontSize: 10)),
                              ),
                              Builder(
                                builder: (context) {
                                  final teeColor = AppColors.getTeeColor(widget.teeColorStr ?? widget.teeName);
                                  final isWhite = widget.teeName?.toUpperCase().contains('WHITE') == true || 
                                                 widget.teeColorStr?.toUpperCase().contains('WHITE') == true;
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: teeColor,
                                      shape: BoxShape.circle,
                                      border: isWhite ? Border.all(color: AppColors.dark200, width: 0.5) : null,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StepperIcon(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            final s = widget.score ?? 4;
                            if (s > 1) widget.onChanged(s - 1);
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: widget.hasConflict
                                    ? AppColors.coral500.withValues(alpha: AppColors.opacityLow)
                                    : (isDark ? AppColors.dark900.withValues(alpha: AppColors.opacityHalf) : AppColors.dark50.withValues(alpha: AppColors.opacityHalf)),
                                borderRadius: shapes?.input,
                                border: Border.all(
                                  color: widget.hasConflict
                                      ? AppColors.coral500
                                      : (isDark ? AppColors.dark700 : AppColors.lightBorder),
                                  width: widget.hasConflict ? AppShapes.borderMedium : 1.0,
                                ),
                              ),
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                readOnly: widget.isLocked,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '-',
                                  filled: false,
                                  fillColor: Colors.transparent,
                                ),
                                style: AppTypography.display.copyWith(
                                  color: _getScoreColor(),
                                  fontWeight: AppTypography.weightHeavy,
                                  fontSize: 32,
                                  height: 1.0,
                                ),
                                onSubmitted: (v) {
                                  final val = int.tryParse(v);
                                  if (val != null) widget.onChanged(val);
                                },
                              ),
                            ),
                            if (widget.holeTags.isNotEmpty)
                              Positioned(
                                top: 3,
                                right: 3,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.amber500,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _StepperIcon(
                          icon: Icons.add_rounded,
                          onTap: () {
                            final s = widget.score ?? 4;
                            widget.onChanged(s + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class _StepperIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        child: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NavigationArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavigationArrow({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.transparent : AppColors.dark50,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? Colors.transparent : AppColors.dark100,
            width: 1,
          ),
          boxShadow: isDisabled ? null : [
            BoxShadow(
            color: AppColors.dark950.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDisabled ? AppColors.dark200 : AppColors.dark950,
        ),
      ),
    );
  }
}
