import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';

import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/features/events/logic/event_scoring_controller.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/features/events/presentation/widgets/submission_progress_bar.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';

class ScoringVerificationView extends ConsumerStatefulWidget {
  final GolfEvent event;
  final String? targetEntryId;
  final Scorecard? activeScorecard;
  final Scorecard? verifierScorecard;
  final bool isAdmin;
  final Future<void> Function(bool isPlayer) onSignOff;

  const ScoringVerificationView({
    super.key,
    required this.event,
    required this.targetEntryId,
    required this.activeScorecard,
    required this.verifierScorecard,
    required this.isAdmin,
    required this.onSignOff,
  });

  @override
  ConsumerState<ScoringVerificationView> createState() => _ScoringVerificationViewState();
}

class _ScoringVerificationViewState extends ConsumerState<ScoringVerificationView> {
  late ScrollController _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    setState(() {
      _showLeftArrow = _scrollController.offset > 10;
      _showRightArrow = _scrollController.offset < _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollToLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 160).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AppAnimations.medium,
      curve: Curves.easeInOut,
    );
  }

  void _scrollToRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 160).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AppAnimations.medium,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoringData = ref.watch(eventScoringControllerProvider(widget.event.id));
    
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (scoringData.totalParticipants > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                child: SubmissionProgressBar(
                  total: scoringData.totalParticipants,
                  submitted: scoringData.submittedCount,
                  inProgress: scoringData.inProgressCount,
                ),
              ),
            const BoxyArtSectionTitle(title: 'VERIFICATION STATUS'),
            const SizedBox(height: AppSpacing.md),
            
            // 2. Conflict Banner (if any)
            _buildConflictBanner(context),
            
            const SizedBox(height: AppSpacing.md),

            // 3. Verification Grid
            _buildVerificationGrid(context, scoringData),
            
            const SizedBox(height: AppSpacing.x2l),
            
            // 4. Handshake UI
            _buildHandshakeSection(context),

            // 5. Round Story Breakdown (if any)
            if (widget.verifierScorecard != null && widget.verifierScorecard!.holeTags.values.any((t) => t.isNotEmpty)) ...[
              const SizedBox(height: AppSpacing.x2l),
              const BoxyArtSectionTitle(title: 'ROUND STORY BREAKDOWN'),
              const SizedBox(height: AppSpacing.md),
              ...widget.verifierScorecard!.holeTags.entries
                  .where((e) => e.value.isNotEmpty)
                  .map((e) => _buildHoleStoryTile(context, e.key, e.value)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandshakeSection(BuildContext context) {
    final allCards = ref.watch(scorecardsListProvider(widget.event.id)).value ?? [];
    final playerCard = allCards.firstWhereOrNull((s) => s.entryId == widget.targetEntryId && s.markerId == widget.targetEntryId);
    final markerCard = allCards.firstWhereOrNull((s) => s.entryId == widget.targetEntryId && s.markerId != widget.targetEntryId);

    return Row(
      children: [
        Expanded(
          child: _buildVerificationHandshake(
            context,
            'PLAYER',
            playerCard != null && playerCard.verifiedByPlayer,
            true,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildVerificationHandshake(
            context,
            'MARKER',
            markerCard != null && markerCard.verifiedByMarker,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildConflictBanner(BuildContext context) {
    if (widget.activeScorecard == null || widget.verifierScorecard == null) return const SizedBox.shrink();
    
    bool hasConflict = false;
    for (int i = 0; i < 18; i++) {
      if (widget.activeScorecard!.holeScores[i] != widget.verifierScorecard!.holeScores[i]) {
        hasConflict = true;
        break;
      }
    }

    if (!hasConflict) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.coral500.withValues(alpha: 0.1),
        borderRadius: AppShapes.md,
        border: Border.all(color: AppColors.coral500.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Score discrepancies detected. Conflicts must be resolved before signing off.',
              style: AppTypography.micro.copyWith(color: AppColors.coral500, fontWeight: AppTypography.weightBold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required List<Widget> rows}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark800 : AppColors.dark50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rMd)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildVerificationGrid(BuildContext context, ProcessedEventData scoringData) {
    final allCards = ref.watch(scorecardsListProvider(widget.event.id)).value ?? [];
    final currentUser = ref.watch(effectiveUserProvider);
    final String displayId = widget.targetEntryId ?? currentUser.id;
    final members = ref.watch(allMembersProvider).value ?? [];
    final manualTee = ref.watch(markerSelectionProvider).teeOverrides[displayId];
    
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: displayId, 
      event: widget.event, 
      membersList: members, 
      manualTeeName: manualTee,
    );
    
    final memberProfile = members.firstWhereOrNull((m) => m.id == displayId);
    final double handicapIndex = memberProfile?.handicap ?? 0.0;
    
    final comp = ref.watch(competitionDetailProvider(widget.event.id)).value;
    final format = comp?.rules.format ?? CompetitionFormat.stroke;

    final int playingHcp = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: handicapIndex,
      rules: widget.event.courseConfig.holes.any((h) => h.par == 0) 
          ? const CompetitionRules() 
          : (comp?.rules ?? const CompetitionRules()),
      courseConfig: playerTeeConfig,
      societyCut: widget.event.manualCuts[displayId] ?? 0.0,
    );
    final String playerTeeName = playerTeeConfig.selectedTeeName ?? 'UNKNOWN';

    final playerSelfCard = allCards.firstWhereOrNull((s) => s.entryId == widget.targetEntryId && s.markerId == widget.targetEntryId);
    final officialMarkerCard = allCards.firstWhereOrNull((s) => s.entryId == widget.targetEntryId && s.markerId != widget.targetEntryId);

    final List<int?> playerStrokes = playerSelfCard?.holeScores ?? List.filled(18, null);
    final List<int?> markerStrokes = officialMarkerCard?.holeScores ?? List.filled(18, null);
    
    final int totalPar = playerTeeConfig.holes.map((h) => h.par).sum;

    ScoringResult? playerPoints;
    try {
      playerPoints = ScoringCalculator.calculate(
        holeScores: playerStrokes.map((e) => e ?? 0).toList(),
        holes: playerTeeConfig.holes,
        playingHandicap: playingHcp.toDouble(),
        format: format,
      );
    } catch (e) { /* Fallback */ }

    final double gridWidth = 70.0 + (18 * 40.0) + 60.0;
    final resolvedTeeColor = AppColors.getTeeColor(playerTeeName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildHeader(
          context, 
          rows: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'COMPARISON GUIDE', 
                    style: AppTypography.label.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: AppTypography.weightBold,
                      color: isDark ? AppColors.dark400 : AppColors.dark300,
                    ),
                  ),
                ),
                BoxyArtIndicator.hc(label: handicapIndex.toStringAsFixed(1)),
                const SizedBox(width: AppSpacing.sm),
                BoxyArtIndicator.phc(context: context, label: '$playingHcp'),
                const SizedBox(width: AppSpacing.sm),
                BoxyArtIndicator.tee(
                  teeColor: resolvedTeeColor,
                  label: playerTeeName.toUpperCase(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Spacer(),
                BoxyArtIndicator(
                  label: 'PAR $totalPar',
                  dotColor: AppColors.dark200,
                ),
                const SizedBox(width: AppSpacing.sm),
                BoxyArtIndicator(
                  label: 'FORMAT: ${format.name.toUpperCase()}',
                  dotColor: AppColors.dark200,
                ),
              ],
            ),
          ],
        ),
        const Divider(height: 1, color: AppColors.dark100),
        
        Stack(
          children: [
            SizedBox(
              height: 360, // Increased to accommodate SI row
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: gridWidth,
                  child: Column(
                    children: [
                      // Header Row (Hole Numbers)
                      _buildAuditRow(
                        context,
                        'HOLE',
                        List.generate(18, (i) => '${i + 1}'),
                        isHeader: true,
                        showTotals: true,
                        totalLabel: 'TOT',
                      ),
                      const Divider(height: 1, color: AppColors.dark100),

                      // PAR Row
                      _buildAuditRow(
                        context,
                        'PAR',
                        playerTeeConfig.holes.map((h) => h.par.toString()).toList(),
                        total: totalPar.toString(),
                        showTotals: true,
                      ),
                      const Divider(height: 1, color: AppColors.dark100),

                      // SI Row
                      _buildAuditRow(
                        context,
                        'SI',
                        playerTeeConfig.holes.map((h) => h.si.toString()).toList(),
                        showTotals: false,
                      ),
                      const Divider(height: 1, color: AppColors.dark100),
                      
                      // Player Row
                      _buildAuditRow(
                        context,
                        'PLAYER',
                        playerStrokes.map((s) => s?.toString() ?? '-').toList(),
                        total: playerPoints?.absoluteScore?.toString() ?? '-',
                        showTotals: true,
                      ),
                      const Divider(height: 1, color: AppColors.dark100),
                      
                      // Marker Row
                      _buildAuditRow(
                        context,
                        'MARKER',
                        markerStrokes.map((s) => s?.toString() ?? '-').toList(),
                        total: officialMarkerCard?.holeScores.nonNulls.sum.toString() ?? '-',
                        showTotals: true,
                      ),
                      const Divider(height: 1, color: AppColors.dark100),
                      
                      // Diff Row
                      _buildAuditRow(
                        context,
                        'DIFF',
                        List.generate(18, (i) {
                          if (playerStrokes[i] == null || markerStrokes[i] == null) return '-';
                          return playerStrokes[i] == markerStrokes[i] ? 'OK' : '!!';
                        }),
                        colorMapper: (val) => val == '!!' ? AppColors.coral500 : (val == 'OK' ? AppColors.lime500 : null),
                        showTotals: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Navigation Arrows
            if (_showLeftArrow)
              Positioned(
                left: AppSpacing.sm,
                top: 0,
                bottom: 0,
                child: Center(
                  child: BoxyArtGlassIconButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: _scrollToLeft,
                  ),
                ),
              ),
            if (_showRightArrow)
              Positioned(
                right: AppSpacing.sm,
                top: 0,
                bottom: 0,
                child: Center(
                  child: BoxyArtGlassIconButton(
                    icon: Icons.chevron_right_rounded,
                    onPressed: _scrollToRight,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuditRow(
    BuildContext context,
    String label,
    List<String> values, {
    bool isHeader = false,
    String? total,
    bool showTotals = false,
    String totalLabel = '',
    Color? Function(String)? colorMapper,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 48,
      color: isHeader 
          ? (isDark ? AppColors.dark800 : AppColors.dark50)
          : Colors.transparent,
      child: Row(
        children: [
          // Row Label
          Container(
            width: 70,
            padding: const EdgeInsets.only(left: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: AppTypography.nano.copyWith(
                fontWeight: AppTypography.weightBold,
                color: isHeader 
                    ? (isDark ? AppColors.dark400 : AppColors.dark300)
                    : (isDark ? AppColors.dark200 : AppColors.dark600),
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Values
          ...values.asMap().entries.map((e) {
            final val = e.value;
            final mappedColor = colorMapper?.call(val);
            
            return Container(
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isDark ? AppColors.dark700 : AppColors.dark100,
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                val,
                style: AppTypography.label.copyWith(
                  fontWeight: isHeader ? AppTypography.weightBlack : AppTypography.weightBold,
                  color: mappedColor ?? (isHeader 
                      ? (isDark ? AppColors.pureWhite : AppColors.dark900)
                      : (isDark ? AppColors.dark100 : AppColors.dark800)),
                ),
              ),
            );
          }),
          
          // Total
          if (showTotals)
            Container(
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppColors.dark900.withValues(alpha: 0.3) : AppColors.dark100.withValues(alpha: 0.3),
                border: Border(
                  left: BorderSide(
                    color: isDark ? AppColors.dark700 : AppColors.dark200,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                isHeader ? totalLabel : (total ?? '-'),
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightBlack,
                  color: isDark ? AppColors.pureWhite : AppColors.dark950,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationHandshake(BuildContext context, String label, bool isSigned, bool isPlayer) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(effectiveUserProvider);
    
    bool canSign = false;
    if (isPlayer) {
      canSign = currentUser.id == widget.targetEntryId;
    } else {
      if (widget.isAdmin) {
        canSign = true;
      } else {
        final allCards = ref.watch(scorecardsListProvider(widget.event.id)).value ?? [];
        final markerCard = allCards.firstWhereOrNull((s) => s.entryId == widget.targetEntryId && s.markerId != widget.targetEntryId);
        canSign = currentUser.id == markerCard?.markerId;
      }
    }

    bool hasConflict = false;
    if (widget.activeScorecard != null && widget.verifierScorecard != null) {
      for (int i = 0; i < 18; i++) {
        if (widget.activeScorecard!.holeScores[i] != widget.verifierScorecard!.holeScores[i]) {
          hasConflict = true;
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark800 : AppColors.dark50,
        borderRadius: AppShapes.md,
        border: Border.all(
          color: isSigned ? AppColors.lime500.withValues(alpha: 0.3) : (isDark ? AppColors.dark700 : AppColors.dark200),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.nano.copyWith(
              color: isDark ? AppColors.dark400 : AppColors.dark300,
              fontWeight: AppTypography.weightBlack,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSigned)
             const Icon(Icons.check_circle_rounded, color: AppColors.lime500, size: 24)
          else
             BoxyArtButton(
               title: 'Sign Off',
               isSmall: true,
               isPrimary: !hasConflict && canSign,
               isGhost: hasConflict || !canSign,
               onTap: (canSign && !hasConflict) ? () => widget.onSignOff(isPlayer) : null,
             ),
        ],
      ),
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
}
