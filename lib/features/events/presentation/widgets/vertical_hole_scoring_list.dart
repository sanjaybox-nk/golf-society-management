import 'package:flutter/foundation.dart';
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
import 'package:golf_society/utils/guest_id_helper.dart';
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/features/home/presentation/home_providers.dart';

part 'vertical_hole_scoring_card.dart';
part 'vertical_hole_scoring_story_sheet.dart';
part 'vertical_hole_scoring_target_card.dart';
part 'vertical_hole_scoring_atoms.dart';

class VerticalHoleScoringList extends ConsumerStatefulWidget {
  final GolfEvent event;
  final ProcessedEventData? scoringData;
  final VoidCallback? onMarkerSelectionTap;
  final VoidCallback? onVerifyTap;
  final ValueChanged<String>? onMarkerConfirmTap;
  final PageController? pageController;
  final ValueChanged<int>? onHoleChanged;
  final VoidCallback? onProxyRecordComplete;

  const VerticalHoleScoringList({
    super.key,
    required this.event,
    this.scoringData,
    this.onMarkerSelectionTap,
    this.onVerifyTap,
    this.onMarkerConfirmTap,
    this.pageController,
    this.onHoleChanged,
    this.onProxyRecordComplete,
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
    _pageController = widget.pageController ?? PageController(initialPage: _currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scoringData != null) {
        final validIds = widget.scoringData!.leaderboard.map((e) => e.entryId).toList();
        ref.read(markerSelectionProvider.notifier).validateTargets(validIds);
      }
      // Restore scroll position when remounting after a tab switch
      if (_pageController.hasClients && _currentPage > 0) {
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  void dispose() {
    if (widget.pageController == null) _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final currentUser = ref.watch(effectiveUserProvider);
    final markerSelection = ref.watch(markerSelectionProvider);
    final allScorecards = ref.watch(scorecardsListProvider(widget.event.id)).asData?.value ?? [];

    final List<String> targetEntryIds = markerSelection.targetEntryIds.toList();
    final bool isSelfMarking = markerSelection.isSelfMarking;

    // Always include the player the current user is officially marking (the player
    // whose scorecard has markerId == currentUser.id). This is the reverse of
    // myScorecard.markerId which is "who marks me" — we want "who I mark".
    final myScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);
    final officialTargetScorecard = allScorecards.firstWhereOrNull(
      (s) => s.markerId == currentUser.id,
    );
    final String? officialTargetEntryId = officialTargetScorecard?.entryId;
    final List<String> baseTargetIds = [
      ...targetEntryIds,
      if (officialTargetEntryId != null &&
          officialTargetEntryId != currentUser.id &&
          !targetEntryIds.contains(officialTargetEntryId))
        officialTargetEntryId,
    ];

    // Build target list: original cards first, then proxy record cards at the end.
    // A proxy card is one whose markerId ends with '_guest' — it exists to let the
    // assignee enter the guest's marking record via the normal scoring layout.
    final Set<String> proxyIds = {};
    final List<String> baseWithProxies = List<String>.from(baseTargetIds);
    for (final id in baseTargetIds) {
      if (!id.endsWith('_guest')) continue;
      final guestCard = allScorecards.firstWhereOrNull((s) => s.entryId == id);
      if (guestCard?.holeScores.any((s) => s != null && s > 0) != true) continue;
      final markedCard = allScorecards.firstWhereOrNull((s) => s.markerId == id);
      if (markedCard != null && !baseWithProxies.contains(markedCard.entryId)) {
        baseWithProxies.add(markedCard.entryId);
      }
    }
    // Detect proxy cards by checking scorecard markerId — covers both auto-added
    // proxies and cards already in targetEntryIds whose marker happens to be a guest.
    bool isProxy(String id) {
      final card = allScorecards.firstWhereOrNull((s) => s.entryId == id);
      return card?.markerId?.endsWith('_guest') == true;
    }
    // Stable sort: originals first, proxies last
    final List<String> effectiveTargetIds = [
      ...baseWithProxies.where((id) => !isProxy(id)),
      ...baseWithProxies.where((id) => isProxy(id)),
    ];
    for (final id in effectiveTargetIds) {
      if (isProxy(id)) proxyIds.add(id);
    }

    final String primaryTargetId = (isSelfMarking || effectiveTargetIds.isEmpty)
        ? currentUser.id
        : effectiveTargetIds.first;

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

    final int totalCards = (isSelfMarking ? 1 : 0) + effectiveTargetIds.length;
    final double containerHeight = 120.0 + (totalCards * 155.0);

    // Event-level lock applies to all cards — scoring is closed for everyone.
    final bool isEventLocked = widget.event.status == EventStatus.completed ||
        widget.event.isScoringLocked == true;
    // Own card: additionally locked once both parties have signed (status = finalScore/reviewed)
    // or admin has approved. A single signature alone keeps it open.
    final bool isSelfLocked = isEventLocked ||
        myScorecard?.status == ScorecardStatus.finalScore ||
        myScorecard?.status == ScorecardStatus.reviewed ||
        myScorecard?.status == ScorecardStatus.approved;
    // Target cards only inherit the event-level lock — the player's own card status
    // (even if approved) must not prevent them from marking someone else.
    final bool isLocked = isEventLocked;
    final bool isSelfDq = myScorecard?.scoringStatus == ScoringStatus.dq;


    final String? myMarkerId = markerSelection.myMarkerId ?? myScorecard?.markerId;
    final String? myMarkerName = myMarkerId == currentUser.id
        ? 'ME'
        : (myMarkerId != null ? _getDisplayName(members, myMarkerId) : null);

    return Column(
      children: [
        _buildMarkerSelector(_currentPage),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: containerHeight.clamp(240.0, 800.0),
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            onPageChanged: (page) {
              if (!mounted) return;
              setState(() => _currentPage = page);
              ref.read(markerSelectionProvider.notifier).setLastViewedHole(page);
              widget.onHoleChanged?.call(page);
              if (page == 17) _confirmProxyRecordsOnHole18();
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
                    if (isSelfMarking) ...[
                      (() {
                        final myCourseConfig = ScoringCalculator.resolvePlayerCourseConfig(
                          memberId: currentUser.id,
                          event: widget.event,
                          membersList: [...members, currentUser],
                          manualTeeName: markerSelection.teeOverrides[currentUser.id],
                          gender: currentUser.gender,
                        );
                        final myMarkerCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id && s.markerId == currentUser.id);
                        final mySeedCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id && s.markerId != currentUser.id);
                        final int? markerScore = myMarkerCard?.holeScores.elementAtOrNull(index);
                        final int? seedScore = mySeedCard?.holeScores.elementAtOrNull(index);
                        final int? displayScore = markerScore ?? seedScore ?? myStats?.holeScores.elementAtOrNull(index);
                        final myActiveCard = myMarkerCard ?? mySeedCard;
                        final myConflicts = myActiveCard?.conflictedHoles.toSet() ?? const <int>{};
                        return _PlayerScoringCard(
                          label: '',
                          name: currentUser.displayName,
                          hc: currentUser.handicap.toDouble(),
                          phc: myActiveCard?.playingHandicap ?? HandicapCalculator.calculatePlayingHandicap(
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
                          onChanged: (isSelfLocked || isSelfDq) ? (_) {} : (s) => _updateScore(currentUser.id, index, s, allScorecards),
                          isStableford: isStableford,
                          isLocked: isSelfLocked || isSelfDq,
                          isMe: true,
                          markerName: myMarkerName,
                          holeTags: myActiveCard?.holeTags[index + 1] ?? [],
                          onStoryTap: (isSelfLocked || isSelfDq) ? null : () => _showStorySheet(context, currentUser.id, index + 1, holes: holes, rules: rules, isStableford: isStableford),
                          hasConflict: myConflicts.contains(index + 1),
                        );
                      })(),
                      if (effectiveTargetIds.isNotEmpty) const SizedBox(height: AppSpacing.cardToCard),
                    ],
                    for (final tId in effectiveTargetIds) ...[
                      () {
                        final card = allScorecards.firstWhereOrNull((s) => s.entryId == tId);
                        final isGuestProxy = card?.markerId?.endsWith('_guest') == true;
                        final guestFirstName = isGuestProxy
                            ? _getDisplayName(members, card!.markerId!).split(' ').first
                            : null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGuestProxy) ...[
                              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.atomic),
                              Text(
                                '${guestFirstName!.toUpperCase()}\'S MARKING RECORD',
                                style: AppTypography.micro.copyWith(
                                  fontWeight: AppTypography.weightHeavy,
                                  letterSpacing: AppTypography.lsLabel,
                                  color: AppColors.dark400,
                                ),
                              ),
                              SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
                            ] else
                              const SizedBox(height: AppSpacing.cardToCard),
                            _buildTargetCard(context, currentUser, tId, index, members, allScorecards, isStableford, isLocked, holes: holes, rules: rules),
                          ],
                        );
                      }(),
                    ],
                    if (widget.onMarkerSelectionTap != null && !isLocked) ...[
                      const SizedBox(height: AppSpacing.standard),
                      BoxyArtButton(
                        title: 'Add / Remove Card',
                        icon: Icons.person_add_rounded,
                        isTinted: true,
                        fullWidth: true,
                        onTap: widget.onMarkerSelectionTap,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }


  Widget _buildMarkerSelector(int holeIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            'HOLE ${holeIndex + 1}',
            style: AppTypography.headline.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppColors.dark950,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
