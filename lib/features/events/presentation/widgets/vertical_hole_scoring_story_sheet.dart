part of 'vertical_hole_scoring_list.dart';

extension _StorySheetMethods on _VerticalHoleScoringListState {
  Future<void> _sendDqNotification(String dqEntryId, int holeNum) async {
    try {
      final groups = widget.event.grouping['groups'] as List? ?? [];
      for (final g in groups) {
        final players = (g['players'] as List? ?? []);
        final inGroup = players.any((p) => (p['registrationMemberId'] ?? p['id']) == dqEntryId);
        if (!inGroup) continue;

        final captain = players.firstWhereOrNull((p) => p['isCaptain'] == true);
        final captainId = (captain?['registrationMemberId'] ?? captain?['id']) as String?;

        final allCards = ref.read(scorecardsListProvider(widget.event.id)).asData?.value ?? [];
        final dqCard = allCards.firstWhereOrNull((s) => s.entryId == dqEntryId);
        final markerMemberId = dqCard?.markerId?.replaceAll('_guest', '');

        final dqName = (players.firstWhereOrNull((p) =>
            (p['registrationMemberId'] ?? p['id']) == dqEntryId)?['name'] as String?)
            ?? dqEntryId;

        final repo = ref.read(notificationsRepositoryProvider);
        final now = DateTime.now();

        if (captainId != null && captainId.isNotEmpty && captainId != dqEntryId) {
          await repo.sendNotification(AppNotification(
            id: '',
            recipientId: captainId,
            title: 'Player Left the Round',
            message: '$dqName has picked up on hole $holeNum and left the round. Please reassign their marker.',
            timestamp: now,
            category: 'Scoring',
            eventId: widget.event.id,
          ));
        }

        if (markerMemberId != null && markerMemberId.isNotEmpty && markerMemberId != dqEntryId) {
          await repo.sendNotification(AppNotification(
            id: '',
            recipientId: markerMemberId,
            title: 'Marker Reassignment Needed',
            message: '$dqName has left the round. A new marker will be assigned to your card.',
            timestamp: now,
            category: 'Scoring',
            eventId: widget.event.id,
          ));
        }
        break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DQ notification error: $e');
    }
  }

  void _showStorySheet(BuildContext context, String entryId, int holeNum, {
    required List<dynamic> holes,
    required CompetitionRules rules,
    required bool isStableford,
  }) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Hole Story',
      child: StatefulBuilder(
        builder: (ctx, setModalState) {
          final allCards = ref.read(scorecardsListProvider(widget.event.id)).asData?.value ?? [];
          final scorecard = allCards.firstWhereOrNull((s) => s.entryId == entryId);
          if (scorecard == null) return const SizedBox.shrink();

          final tags = List<String>.from(scorecard.holeTags[holeNum] ?? []);
          final isGimme = tags.contains('GIMME');
          final isPickUp = tags.contains('PICK_UP');
          final isNotPlayed = tags.contains('NOT_PLAYED');
          final p1Count = tags.where((t) => t.startsWith('PENALTY_1_') || (t.startsWith('PENALTY_') && !t.startsWith('PENALTY_1_') && !t.startsWith('PENALTY_2_'))).length;
          final p2Count = tags.where((t) => t.startsWith('PENALTY_2_')).length;
          final hasPenalties = p1Count > 0 || p2Count > 0;

          void persist(List<String> updatedTags, {List<int?>? updatedScores}) {
            final newTags = Map<int, List<String>>.from(scorecard.holeTags);
            newTags[holeNum] = updatedTags;
            ref.read(scorecardRepositoryProvider).updateScorecard(scorecard.copyWith(
              holeTags: newTags,
              holeScores: updatedScores ?? scorecard.holeScores,
            ));
            setModalState(() {});
          }

          int calcPickUpScore() {
            final holeIdx = holeNum - 1;
            final hole = holeIdx < holes.length ? holes[holeIdx] : null;
            if (hole == null) return 99;
            final par = hole.par as int;
            final si = hole.si as int;
            final phc = scorecard.playingHandicap ?? 0;
            final config = rules.maxScoreConfig ?? const MaxScoreConfig();
            switch (config.type) {
              case MaxScoreType.netDoubleBogey:
                final strokes = (phc / 18).floor() + (phc % 18 >= si ? 1 : 0);
                return par + 2 + strokes;
              case MaxScoreType.parPlusX:
                return par + config.value;
              case MaxScoreType.fixed:
                return config.value;
            }
          }

          Future<void> applyDq(List<String> dqTags, List<int?> dqScores, int holeIdx, String debugLabel) async {
            try {
              final updatedTagMap = Map<int, List<String>>.from(scorecard.holeTags);
              updatedTagMap[holeNum] = dqTags;
              for (int h = holeIdx + 1; h < 18; h++) {
                if (h >= dqScores.length) dqScores.add(null);
                dqScores[h] = null;
                final remainingTags = List<String>.from(updatedTagMap[h + 1] ?? []);
                if (!remainingTags.contains('PICK_UP')) remainingTags.add('PICK_UP');
                updatedTagMap[h + 1] = remainingTags;
              }
              await ref.read(scorecardRepositoryProvider).updateScorecard(
                scorecard.copyWith(
                  holeTags: updatedTagMap,
                  holeScores: dqScores,
                  scoringStatus: ScoringStatus.dq,
                  markerReassignmentOpen: true,
                ),
              );
              _sendDqNotification(entryId, holeNum);
              if (ctx.mounted) Navigator.of(ctx, rootNavigator: false).pop();
            } catch (e) {
              if (kDebugMode) debugPrint('$debugLabel DQ apply error: $e');
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxyArtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StoryButton(
                          label: 'Gimme',
                          icon: Icons.check_circle_outline_rounded,
                          isActive: isGimme,
                          onTap: () {
                            if (isGimme) {
                              tags.remove('GIMME');
                              persist(tags);
                              if (ctx.mounted) Navigator.of(ctx, rootNavigator: false).pop();
                            } else {
                              tags.add('GIMME');
                              persist(tags);
                            }
                          },
                        )),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: _StoryButton(
                          label: 'Pick Up',
                          icon: Icons.upload_rounded,
                          isActive: isPickUp,
                          onTap: () async {
                            final holeIdx = holeNum - 1;
                            final updatedScores = List<int?>.from(scorecard.holeScores);
                            while (updatedScores.length <= holeIdx) { updatedScores.add(null); }

                            if (isPickUp) {
                              tags.remove('PICK_UP');
                              if (!isStableford) updatedScores[holeIdx] = null;
                              persist(tags, updatedScores: updatedScores);
                              if (ctx.mounted) Navigator.of(ctx, rootNavigator: false).pop();
                              return;
                            }

                            final isDqMode = rules.pickUpBehaviour == PickUpBehaviour.disqualify && !isStableford;
                            if (isDqMode) {
                              final confirmed = await showDialog<bool>(
                                context: ctx,
                                builder: (_) => const BoxyArtConfirmDialog(
                                  title: 'Pick Up — Disqualification',
                                  message: 'This competition uses strict stroke play rules. Picking up on any hole disqualifies you from this round. You will not be able to enter scores for remaining holes.',
                                  confirmLabel: 'Accept DQ',
                                  cancelLabel: 'Cancel',
                                  isDestructive: true,
                                ),
                              );
                              if (confirmed != true) return;
                              tags.add('PICK_UP');
                              updatedScores[holeIdx] = null;
                              await applyDq(tags, updatedScores, holeIdx, 'PickUp');
                            } else {
                              tags.add('PICK_UP');
                              if (!isStableford) updatedScores[holeIdx] = calcPickUpScore();
                              persist(tags, updatedScores: updatedScores);
                            }
                          },
                        )),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StoryButton(
                      label: 'Not Played',
                      icon: Icons.remove_circle_outline_rounded,
                      isActive: isNotPlayed,
                      onTap: () async {
                        final holeIdx = holeNum - 1;
                        final updatedScores = List<int?>.from(scorecard.holeScores);
                        while (updatedScores.length <= holeIdx) { updatedScores.add(null); }

                        if (isNotPlayed) {
                          tags.remove('NOT_PLAYED');
                          if (!isStableford) updatedScores[holeIdx] = null;
                          persist(tags, updatedScores: updatedScores);
                          if (ctx.mounted) Navigator.of(ctx, rootNavigator: false).pop();
                          return;
                        }

                        final isDqMode = rules.pickUpBehaviour == PickUpBehaviour.disqualify && !isStableford;
                        if (isDqMode) {
                          final confirmed = await showDialog<bool>(
                            context: ctx,
                            builder: (_) => const BoxyArtConfirmDialog(
                              title: 'Not Played — Disqualification',
                              message: 'This competition uses strict stroke play rules. A hole not played disqualifies you from this round. Remaining holes will be locked.',
                              confirmLabel: 'Accept DQ',
                              cancelLabel: 'Cancel',
                              isDestructive: true,
                            ),
                          );
                          if (confirmed != true) return;
                          tags.add('NOT_PLAYED');
                          updatedScores[holeIdx] = null;
                          await applyDq(tags, updatedScores, holeIdx, 'NotPlayed');
                        } else {
                          tags.add('NOT_PLAYED');
                          if (!isStableford) updatedScores[holeIdx] = calcPickUpScore();
                          persist(tags, updatedScores: updatedScores);
                        }
                      },
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
                        Expanded(child: _StoryButton(
                          label: '+1 Stroke${p1Count > 0 ? '  ×$p1Count' : ''}',
                          icon: Icons.add_circle_outline_rounded,
                          isActive: p1Count > 0,
                          onTap: () {
                            tags.add('PENALTY_1_${DateTime.now().millisecondsSinceEpoch}');
                            persist(tags);
                          },
                          onLongPress: p1Count > 0 ? () {
                            tags.removeWhere((t) => t.startsWith('PENALTY_1_') || (t.startsWith('PENALTY_') && !t.startsWith('PENALTY_1_') && !t.startsWith('PENALTY_2_')));
                            persist(tags);
                          } : null,
                        )),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: _StoryButton(
                          label: '+2 Strokes${p2Count > 0 ? '  ×$p2Count' : ''}',
                          icon: Icons.add_circle_outline_rounded,
                          isActive: p2Count > 0,
                          onTap: () {
                            tags.add('PENALTY_2_${DateTime.now().millisecondsSinceEpoch}');
                            persist(tags);
                          },
                          onLongPress: p2Count > 0 ? () {
                            tags.removeWhere((t) => t.startsWith('PENALTY_2_'));
                            persist(tags);
                          } : null,
                        )),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
