part of 'vertical_hole_scoring_list.dart';

extension _TargetCardMethods on _VerticalHoleScoringListState {
  Widget _buildTargetCard(
    BuildContext context,
    Member currentUser,
    String tId,
    int index,
    List<Member> members,
    List<Scorecard> allCards,
    bool isStableford,
    bool isLocked, {
    required List<dynamic> holes,
    required CompetitionRules rules,
  }) {
    final targetStats = widget.scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == tId);
    final targetEntry = widget.scoringData?.leaderboard.firstWhereOrNull((e) => e.entryId == tId);
    final scorecard = allCards.firstWhereOrNull((s) => s.entryId == tId);

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
    final holeTagsForIndex = scorecard?.holeTags[index + 1] ?? [];

    // Lock holes sealed by a DQ pick-up — preserves the original marker audit.
    final isTargetDq = scorecard?.scoringStatus == ScoringStatus.dq;
    final isDqSealedHole = isTargetDq && holeTagsForIndex.contains('PICK_UP') && dScore == null;
    final effectiveLock = isLocked || isDqSealedHole;

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
      onChanged: effectiveLock ? (_) {} : (s) => _updateScore(tId, index, s, allCards),
      isStableford: isStableford,
      isLocked: effectiveLock,
      isMe: false,
      markerName: markerName,
      holeTags: holeTagsForIndex,
      onStoryTap: effectiveLock ? null : () => _showStorySheet(context, tId, index + 1, holes: holes, rules: rules, isStableford: isStableford),
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
    final groups = widget.event.grouping['groups'] as List? ?? [];
    for (final group in groups) {
      for (final p in (group['players'] as List? ?? [])) {
        final map = Map<String, dynamic>.from(p as Map);
        if (GuestIdHelper.resolveEffectiveId(map) == id) {
          final n = map['name'] as String?;
          if (n != null && n.isNotEmpty) return n;
        }
      }
    }
    final baseId = GuestIdHelper.stripGuestSuffix(id);
    return members.firstWhereOrNull((m) => m.id == baseId)?.displayName ?? 'Player';
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
}
