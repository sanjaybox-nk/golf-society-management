import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';

/// Static config for one sign-off responsibility. Live state is derived by the view.
class SignOffTask {
  final String entryId;
  final String playerName;
  final bool isPlayerRole;
  final String? markerName;

  const SignOffTask({
    required this.entryId,
    required this.playerName,
    required this.isPlayerRole,
    this.markerName,
  });
}

class ScoringVerificationView extends ConsumerWidget {
  final GolfEvent event;
  final List<SignOffTask> tasks;
  final Future<void> Function(String entryId, bool isPlayerRole) onSignOff;

  const ScoringVerificationView({
    super.key,
    required this.event,
    required this.tasks,
    required this.onSignOff,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCards = ref.watch(scorecardsListProvider(event.id)).asData?.value ?? [];

    final myTasks = tasks.where((t) => t.isPlayerRole).toList();
    final markerTasks = tasks.where((t) => !t.isPlayerRole).toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (myTasks.isNotEmpty) ...[
            _SectionLabel(label: 'MY CARD'),
            const SizedBox(height: AppSpacing.sm),
            ...myTasks.map((t) {
              final card = allCards.firstWhereOrNull((s) => s.entryId == t.entryId);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _TaskCard(
                  task: t,
                  card: card,
                  onSignOff: onSignOff,
                ),
              );
            }),
          ],
          if (markerTasks.isNotEmpty) ...[
            if (myTasks.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            _SectionLabel(label: 'CARDS I\'M MARKING'),
            const SizedBox(height: AppSpacing.sm),
            ...markerTasks.map((t) {
              final card = allCards.firstWhereOrNull((s) => s.entryId == t.entryId);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _TaskCard(
                  task: t,
                  card: card,
                  onSignOff: onSignOff,
                ),
              );
            }),
          ],
          const SizedBox(height: AppSpacing.section),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task card — score grid + sign-off
// ---------------------------------------------------------------------------

class _TaskCard extends StatelessWidget {
  final SignOffTask task;
  final Scorecard? card;
  final Future<void> Function(String entryId, bool isPlayerRole) onSignOff;

  const _TaskCard({required this.task, required this.card, required this.onSignOff});

  bool get _hasConflict => card?.conflictedHoles.isNotEmpty ?? false;

  bool get _isSigned => task.isPlayerRole
      ? (card?.verifiedByPlayer ?? false)
      : (card?.verifiedByMarker ?? false);

  List<int> get _conflictedHoles => card?.conflictedHoles ?? [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shapes = theme.extension<AppShapeTokens>();
    final hasConflict = _hasConflict;
    final isSigned = _isSigned;
    final canAct = !isSigned && !hasConflict && card != null;
    final counterpartSigned = task.isPlayerRole
        ? (card?.verifiedByMarker ?? false)
        : (card?.verifiedByPlayer ?? false);
    final conflicts = _conflictedHoles;

    // Scores to compare
    final myScores = task.isPlayerRole
        ? (card?.holeScores ?? [])
        : (card?.playerVerifierScores ?? []);
    final theirScores = task.isPlayerRole
        ? (card?.playerVerifierScores ?? [])
        : (card?.holeScores ?? []);
    final myLabel = task.isPlayerRole ? 'YOU' : 'RECORDED';
    final theirLabel = task.isPlayerRole ? 'MARKER' : 'PLAYER';
    final hasMarkerScores = theirScores.any((s) => s != null && s > 0);

    final borderColor = isSigned
        ? AppColors.lime500.withValues(alpha: 0.4)
        : hasConflict
            ? AppColors.coral500.withValues(alpha: 0.4)
            : (isDark ? AppColors.dark700 : AppColors.dark200);

    final bgColor = isSigned
        ? AppColors.lime500.withValues(alpha: 0.04)
        : (isDark ? AppColors.dark800 : AppColors.dark50);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: shapes?.card,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.standard, AppSpacing.standard, AppSpacing.standard, AppSpacing.sm),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: isSigned
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.lime500, size: 20, key: ValueKey('signed'))
                      : hasConflict
                          ? const Icon(Icons.warning_amber_rounded,
                              color: AppColors.coral500, size: 20, key: ValueKey('conflict'))
                          : Icon(Icons.radio_button_unchecked_rounded,
                              color: AppColors.dark300, size: 20, key: const ValueKey('pending')),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.playerName,
                        style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSigned
                            ? 'Signed off'
                            : hasConflict
                                ? 'Score conflict on hole${conflicts.length > 1 ? 's' : ''} ${conflicts.join(', ')} — resolve before signing'
                                : task.isPlayerRole
                                    ? 'Review your scores against your marker\'s recording'
                                    : 'Review your recording against the player\'s scores',
                        style: AppTypography.micro.copyWith(
                          color: hasConflict
                              ? AppColors.coral500
                              : isSigned
                                  ? AppColors.lime500
                                  : AppColors.dark400,
                        ),
                      ),
                      if (!isSigned && task.markerName != null || !isSigned && !task.isPlayerRole) ...[
                        const SizedBox(height: 3),
                        _CounterpartStatus(
                          isPlayerRole: task.isPlayerRole,
                          counterpartName: task.isPlayerRole ? task.markerName : task.playerName,
                          counterpartSigned: counterpartSigned,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Score comparison grid ─────────────────────────────────────────
          if (card != null && hasMarkerScores) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.standard),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.standard),
              child: _ScoreGrid(
                myScores: myScores,
                theirScores: theirScores,
                myLabel: myLabel,
                theirLabel: theirLabel,
                conflictedHoles: conflicts.toSet(),
                isSigned: isSigned,
              ),
            ),
          ] else if (card != null && !hasMarkerScores) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.standard),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.standard, AppSpacing.md, AppSpacing.standard, AppSpacing.md),
              child: Text(
                'Marker scores not yet recorded',
                style: AppTypography.micro.copyWith(color: AppColors.dark400),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // ── Sign Off button ───────────────────────────────────────────────
          if (!isSigned) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.standard, 0, AppSpacing.standard, AppSpacing.standard),
              child: BoxyArtButton(
                title: hasConflict
                    ? 'Resolve Conflict First'
                    : counterpartSigned
                        ? 'Sign Off — Both Agree'
                        : 'Sign Off',
                isPrimary: canAct && counterpartSigned,
                isGhost: !canAct,
                backgroundColor: canAct && counterpartSigned ? AppColors.lime500 : null,
                textColor: canAct && counterpartSigned ? AppColors.dark900 : null,
                fullWidth: true,
                onTap: canAct ? () => onSignOff(task.entryId, task.isPlayerRole) : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score comparison grid — Front 9 + Back 9
// ---------------------------------------------------------------------------

class _ScoreGrid extends StatelessWidget {
  final List<int?> myScores;
  final List<int?> theirScores;
  final String myLabel;
  final String theirLabel;
  final Set<int> conflictedHoles;
  final bool isSigned;

  const _ScoreGrid({
    required this.myScores,
    required this.theirScores,
    required this.myLabel,
    required this.theirLabel,
    required this.conflictedHoles,
    required this.isSigned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHalf(context, 1, 9),
        const SizedBox(height: AppSpacing.sm),
        _buildHalf(context, 10, 18),
      ],
    );
  }

  Widget _buildHalf(BuildContext context, int start, int end) {
    return Column(
      children: [
        _GridRow(
          label: 'HOLE',
          cells: List.generate(end - start + 1, (i) => '${start + i}'),
          isHeader: true,
          conflictedHoles: const {},
          startHole: start,
        ),
        const SizedBox(height: 2),
        _GridRow(
          label: myLabel,
          cells: List.generate(end - start + 1, (i) {
            final score = myScores.elementAtOrNull(start - 1 + i);
            return score != null ? '$score' : '—';
          }),
          conflictedHoles: conflictedHoles,
          startHole: start,
          isMyRow: true,
          isSigned: isSigned,
        ),
        const SizedBox(height: 2),
        _GridRow(
          label: theirLabel,
          cells: List.generate(end - start + 1, (i) {
            final score = theirScores.elementAtOrNull(start - 1 + i);
            return score != null ? '$score' : '—';
          }),
          conflictedHoles: conflictedHoles,
          startHole: start,
          isSigned: isSigned,
        ),
      ],
    );
  }
}

class _GridRow extends StatelessWidget {
  final String label;
  final List<String> cells;
  final bool isHeader;
  final bool isMyRow;
  final bool isSigned;
  final Set<int> conflictedHoles;
  final int startHole;

  const _GridRow({
    required this.label,
    required this.cells,
    required this.conflictedHoles,
    required this.startHole,
    this.isHeader = false,
    this.isMyRow = false,
    this.isSigned = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: AppTypography.micro.copyWith(
              fontSize: 9,
              fontWeight: AppTypography.weightBold,
              color: AppColors.dark400,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...List.generate(cells.length, (i) {
          final hole = startHole + i;
          final hasConflict = !isHeader && conflictedHoles.contains(hole);

          Color cellBg = Colors.transparent;
          Color textColor = isHeader
              ? AppColors.dark400
              : (isDark ? AppColors.pureWhite : AppColors.dark900);

          if (hasConflict && !isSigned) {
            cellBg = AppColors.coral500.withValues(alpha: 0.12);
            textColor = AppColors.coral500;
          } else if (isSigned && !isHeader) {
            textColor = AppColors.dark400;
          }

          return Expanded(
            child: Container(
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: cellBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  cells[i],
                  style: AppTypography.micro.copyWith(
                    fontSize: isHeader ? 9 : 11,
                    fontWeight: isHeader
                        ? AppTypography.weightRegular
                        : AppTypography.weightBold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.micro.copyWith(
        color: AppColors.dark400,
        fontWeight: AppTypography.weightBold,
        letterSpacing: AppTypography.lsLabel,
      ),
    );
  }
}

class _CounterpartStatus extends StatelessWidget {
  final bool isPlayerRole;
  final String? counterpartName;
  final bool counterpartSigned;

  const _CounterpartStatus({
    required this.isPlayerRole,
    required this.counterpartName,
    required this.counterpartSigned,
  });

  @override
  Widget build(BuildContext context) {
    if (counterpartName == null) return const SizedBox.shrink();
    final icon = counterpartSigned ? Icons.check_circle_rounded : Icons.schedule_rounded;
    final iconColor = counterpartSigned ? AppColors.lime500 : AppColors.dark300;
    final label = counterpartSigned
        ? '$counterpartName has signed off'
        : 'Waiting for $counterpartName to sign';

    return Row(
      children: [
        Icon(icon, size: 11, color: iconColor),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.micro.copyWith(
              fontSize: 10,
              color: AppColors.dark400,
              fontWeight: AppTypography.weightRegular,
            ),
          ),
        ),
      ],
    );
  }
}
