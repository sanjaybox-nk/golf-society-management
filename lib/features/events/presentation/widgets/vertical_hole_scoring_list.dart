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

  const VerticalHoleScoringList({
    super.key,
    required this.event,
    this.scoringData,
    this.onMarkerSelectionTap,
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
    final dbTargets = allScorecards
        .where((s) => s.markerId == currentUser.id && s.entryId != currentUser.id)
        .map((s) => s.entryId)
        .toList();

    final List<String> targetEntryIds = isGroupScorer 
        ? otherPlayersIds 
        : {...localTargets, ...dbTargets}.toList();

    final bool isSelfMarking = markerSelection.isSelfMarking || 
        allScorecards.any((s) => s.entryId == currentUser.id && s.markerId == currentUser.id);
    
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
      hint: pScore, // Show the player's own input as a hint to the marker
      thru: targetStats?.thruLabel,
      points: targetStats?.result.score,
      matchStatus: targetEntry?.matchStatus,
      onChanged: isLocked ? (_) {} : (s) => _updateScore(tId, index, s, allCards),
      isStableford: isStableford,
      isLocked: isLocked,
      isMe: false,
      markerName: markerName,
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
    final m = members.firstWhereOrNull((m) => m.id == id);
    return m?.displayName ?? 'Player';
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark800 : theme.cardColor,
        borderRadius: BorderRadius.circular(AppShapes.rMd),
        border: Border.all(
          color: isDark ? AppColors.dark700 : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: Player Info
            Expanded(
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
                      BoxyArtIndicator.hc(label: widget.hc.toStringAsFixed(1)),
                      BoxyArtIndicator.phc(context: context, label: '${widget.phc}'),
                    ],
                  ),
  
                  if (widget.isMe && widget.markerName != null) ...[
                    const Spacer(),
                    const SizedBox(height: 8),
                    Text(
                      'MARKED BY ${widget.markerName!.toUpperCase()}',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.dark400,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
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
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.dark900.withOpacity(0.5) : AppColors.dark50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppShapes.rSm),
                            border: Border.all(
                              color: isDark ? AppColors.dark700 : AppColors.lightBorder,
                              width: 1.0,
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
