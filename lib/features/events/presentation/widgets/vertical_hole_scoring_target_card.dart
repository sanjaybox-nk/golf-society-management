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

    // Find who this target player is officially marking (the scorecard they are marking).
    final targetMarkingCard = allCards.firstWhereOrNull((s) => s.markerId == tId && s.entryId != tId);
    final markerName = targetMarkingCard == null
        ? null
        : _getDisplayName(members, targetMarkingCard.entryId);

    final targetConflicts = scorecard?.conflictedHoles.toSet() ?? const <int>{};
    final holeTagsForIndex = scorecard?.holeTags[index + 1] ?? [];

    // Lock holes sealed by a DQ pick-up — preserves the original marker audit.
    final isTargetDq = scorecard?.scoringStatus == ScoringStatus.dq;
    final isDqSealedHole = isTargetDq && holeTagsForIndex.contains('PICK_UP') && dScore == null;
    // Marker-signed lock only applies to clean cards. If conflicts are unresolved
    // the marker must still be able to edit to reach agreement before confirming.
    final isMarkerSigned = scorecard?.verifiedByMarker == true && targetConflicts.isEmpty;
    final effectiveLock = isLocked || isDqSealedHole || isMarkerSigned;


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
      isGuest: tId.endsWith('_guest'),
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
          // Own card — write to holeScores
          final List<int?> updatedScores = List<int?>.from(scorecard.holeScores);
          if (updatedScores.length < 18) {
            updatedScores.addAll(List.generate(18 - updatedScores.length, (i) => null));
          }
          updatedScores[holeIndex] = score;
          await ref.read(scorecardRepositoryProvider).updateScorecard(scorecard.copyWith(
            holeScores: updatedScores,
            conflictedHoles: Scorecard.computeConflicts(updatedScores, scorecard.playerVerifierScores),
            updatedAt: DateTime.now(),
          ));
        } else {
          // Marking a member — write to playerVerifierScores
          final List<int?> updatedVerifierScores = List<int?>.from(scorecard.playerVerifierScores);
          if (updatedVerifierScores.length < 18) {
            updatedVerifierScores.addAll(List.generate(18 - updatedVerifierScores.length, (i) => null));
          }
          updatedVerifierScores[holeIndex] = score;
          final updatedConflicts = Scorecard.computeConflicts(scorecard.holeScores, updatedVerifierScores);
          final now = DateTime.now();
          // For guest-marked cards: auto-confirm when all 18 proxy scores are filled
          // (the guest can't tap "Confirm" themselves, so completion implies confirmation)
          final isGuestMarkedCard = scorecard.markerId?.endsWith('_guest') == true;
          final allFilled = updatedVerifierScores.length == 18 &&
              updatedVerifierScores.every((s) => s != null && s > 0);
          final autoConfirm = isGuestMarkedCard && allFilled && updatedConflicts.isEmpty;
          await ref.read(scorecardRepositoryProvider).updateScorecard(scorecard.copyWith(
            playerVerifierScores: updatedVerifierScores,
            conflictedHoles: updatedConflicts,
            // Preserve the actual marker (the guest) — don't overwrite with proxy assignee
            markerId: (scorecard.markerId?.isNotEmpty == true) ? scorecard.markerId! : currentUser.id,
            verifiedByMarker: autoConfirm ? true : scorecard.verifiedByMarker,
            markerVerifiedAt: autoConfirm ? now : scorecard.markerVerifiedAt,
            updatedAt: now,
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

  // Called when the user scrolls to hole 18. For any proxy marking card (markerId
  // ends with _guest) that hasn't been confirmed yet, auto-fills holes the user
  // didn't explicitly change with the player's own holeScores (implicit agreement),
  // then sets verifiedByMarker. Scrolling to hole 18 is the confirmation action —
  // no explicit button needed.
  Future<void> _confirmProxyRecordsOnHole18() async {
    final currentUser = ref.read(effectiveUserProvider);
    final allScorecards = ref.read(scorecardsListProvider(widget.event.id)).asData?.value ?? [];
    final markerSelection = ref.read(markerSelectionProvider);

    final targets = <String>{...markerSelection.targetEntryIds};
    final officialTarget = allScorecards.firstWhereOrNull((s) => s.markerId == currentUser.id);
    if (officialTarget != null) targets.add(officialTarget.entryId);

    bool anyConfirmed = false;
    for (final tId in targets) {
      final card = allScorecards.firstWhereOrNull((s) => s.entryId == tId);
      if (card?.markerId?.endsWith('_guest') != true) continue;
      if (card!.verifiedByMarker) continue;

      // Fill untouched holes from the player's own holeScores (implicit agreement)
      final pvs = List<int?>.from(card.playerVerifierScores);
      if (pvs.length < 18) pvs.addAll(List<int?>.filled(18 - pvs.length, null));
      for (int i = 0; i < 18; i++) {
        if (pvs[i] == null) {
          pvs[i] = i < card.holeScores.length ? card.holeScores[i] : null;
        }
      }
      if (pvs.any((s) => s == null || s == 0)) continue; // missing scores — skip

      final conflicts = Scorecard.computeConflicts(card.holeScores, pvs);
      final now = DateTime.now();
      await ref.read(scorecardRepositoryProvider).updateScorecard(card.copyWith(
        playerVerifierScores: pvs,
        conflictedHoles: conflicts,
        verifiedByMarker: conflicts.isEmpty,
        markerVerifiedAt: conflicts.isEmpty ? now : null,
        updatedAt: now,
      ));
      anyConfirmed = true;
    }

    if (anyConfirmed && mounted) {
      widget.onProxyRecordComplete?.call();
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

}
