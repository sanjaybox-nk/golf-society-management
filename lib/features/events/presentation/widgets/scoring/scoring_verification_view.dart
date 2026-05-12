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
  final bool isPlayerRole; // true = signing as the player, false = signing as marker
  final String? markerName; // only relevant when isPlayerRole = true

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
    // Live stream — rebuilds whenever Firestore updates
    final allCards = ref.watch(scorecardsListProvider(event.id)).asData?.value ?? [];

    final myTasks = tasks.where((t) => t.isPlayerRole).toList();
    final markerTasks = tasks.where((t) => !t.isPlayerRole).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (myTasks.isNotEmpty) ...[
          _SectionLabel(label: 'MY CARD'),
          const SizedBox(height: AppSpacing.sm),
          ...myTasks.map((t) {
            final card = allCards.firstWhereOrNull((s) => s.entryId == t.entryId);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TaskRow(
                task: t,
                card: card,
                onSignOff: onSignOff,
              ),
            );
          }),
        ],
        if (markerTasks.isNotEmpty) ...[
          if (myTasks.isNotEmpty) const SizedBox(height: AppSpacing.standard),
          _SectionLabel(label: 'CARDS I\'M MARKING'),
          const SizedBox(height: AppSpacing.sm),
          ...markerTasks.map((t) {
            final card = allCards.firstWhereOrNull((s) => s.entryId == t.entryId);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TaskRow(
                task: t,
                card: card,
                onSignOff: onSignOff,
              ),
            );
          }),
        ],
      ],
    );
  }
}

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

class _TaskRow extends StatelessWidget {
  final SignOffTask task;
  final Scorecard? card;
  final Future<void> Function(String entryId, bool isPlayerRole) onSignOff;

  const _TaskRow({
    required this.task,
    required this.card,
    required this.onSignOff,
  });

  bool get _hasConflict {
    if (card == null) return false;
    for (int i = 0; i < 18; i++) {
      final p = card!.holeScores.elementAtOrNull(i);
      final m = card!.playerVerifierScores.elementAtOrNull(i);
      if (p != null && m != null && p != m) return true;
    }
    return false;
  }

  bool get _isSigned => task.isPlayerRole
      ? (card?.verifiedByPlayer ?? false)
      : (card?.verifiedByMarker ?? false);

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

    return AnimatedContainer(
      duration: AppAnimations.fast,
      padding: const EdgeInsets.all(AppSpacing.standard),
      decoration: BoxDecoration(
        color: isSigned
            ? AppColors.lime500.withValues(alpha: 0.06)
            : (isDark ? AppColors.dark800 : AppColors.dark50),
        borderRadius: shapes?.card,
        border: Border.all(
          color: isSigned
              ? AppColors.lime500.withValues(alpha: 0.4)
              : hasConflict
                  ? AppColors.coral500.withValues(alpha: 0.4)
                  : (isDark ? AppColors.dark700 : AppColors.dark200),
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: AppAnimations.fast,
            child: isSigned
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.lime500, size: 22, key: ValueKey('signed'))
                : hasConflict
                    ? const Icon(Icons.warning_amber_rounded,
                        color: AppColors.coral500, size: 22, key: ValueKey('conflict'))
                    : Icon(Icons.radio_button_unchecked_rounded,
                        color: AppColors.dark300, size: 22, key: const ValueKey('pending')),
          ),
          const SizedBox(width: AppSpacing.md),
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
                  hasConflict
                      ? 'Conflicts — resolve on scorecard first'
                      : isSigned
                          ? 'Signed off'
                          : card == null
                              ? 'No scorecard yet'
                              : task.isPlayerRole
                                  ? 'Confirm your marker\'s scores'
                                  : 'Confirm scores you recorded',
                  style: AppTypography.micro.copyWith(
                    color: hasConflict
                        ? AppColors.coral500
                        : isSigned
                            ? AppColors.lime500
                            : AppColors.dark400,
                  ),
                ),
                // Counterpart sign-off status — shown on both player and marker tasks
                if (!isSigned) ...[
                  const SizedBox(height: 4),
                  _CounterpartStatus(
                    isPlayerRole: task.isPlayerRole,
                    counterpartName: task.isPlayerRole ? task.markerName : task.playerName,
                    counterpartSigned: task.isPlayerRole
                        ? (card?.verifiedByMarker ?? false)
                        : (card?.verifiedByPlayer ?? false),
                  ),
                ],
              ],
            ),
          ),
          if (!isSigned)
            BoxyArtButton(
              title: 'Sign Off',
              isSmall: true,
              isPrimary: canAct,
              isGhost: !canAct,
              backgroundColor: canAct && counterpartSigned ? AppColors.lime500 : null,
              textColor: canAct && counterpartSigned ? AppColors.dark900 : null,
              onTap: canAct ? () => onSignOff(task.entryId, task.isPlayerRole) : null,
            ),
        ],
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
