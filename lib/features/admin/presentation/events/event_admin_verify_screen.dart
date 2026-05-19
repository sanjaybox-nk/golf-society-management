import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/domain/models/platform_content.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../home/presentation/home_providers.dart';
import '../../../settings/data/platform_content_repository.dart';
import 'widgets/admin_verify_tab.dart';

class EventAdminVerifyScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAdminVerifyScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminVerifyScreen> createState() => _EventAdminVerifyScreenState();
}

class _EventAdminVerifyScreenState extends ConsumerState<EventAdminVerifyScreen> {
  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        return HeadlessScaffold(
          title: 'Verify Scorecards',
          subtitle: event.title,
          topPill: BoxyArtPill.committee(label: 'ADMIN'),
          showBack: true,
          onBack: () => context.goNamed('admin-event-scores', pathParameters: {'id': widget.eventId}),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: _buildStatusCard(context, ref, event, scorecardsAsync),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: AdminVerifyTab(
                  event: event,
                  scorecardsAsync: scorecardsAsync,
                  isStableford: compAsync.value?.rules.format == CompetitionFormat.stableford,
                  onUnlockCard: (entryId, markerEntryId, playerName, markerName) =>
                      _confirmUnlock(context, ref, event, entryId, markerEntryId, playerName, markerName),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Verify',
        slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (e, s) => HeadlessScaffold(
        title: 'Error',
        slivers: [SliverFillRemaining(child: Center(child: Text('Error: $e')))],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, WidgetRef ref, GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) {
    final scorecards = scorecardsAsync.value ?? [];
    final int verifiedCount = scorecards.where((s) => s.status == ScorecardStatus.approved).length;
    final int conflictCount = scorecards.where((s) =>
        s.status != ScorecardStatus.approved && s.conflictedHoles.isNotEmpty).length;
    final int readyCount = scorecards.where((s) =>
        s.status != ScorecardStatus.approved &&
        (s.status == ScorecardStatus.finalScore || s.status == ScorecardStatus.reviewed)).length;
    final int fieldCount = scorecards.length - verifiedCount - conflictCount - readyCount;

    final bool isLocked = event.isScoringLocked;
    final bool isPublished = event.isStatsReleased;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _VerifyMetric(label: 'Field', value: '$fieldCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _VerifyMetric(label: 'Conflicts', value: '$conflictCount', isAlert: conflictCount > 0)),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _VerifyMetric(label: 'To Verify', value: '$readyCount')),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _VerifyMetric(label: 'Verified', value: '$verifiedCount', highlight: true)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          _ActionRow(
            label: isPublished ? 'Unpublish' : 'Publish',
            description: isPublished
                ? 'Hide standings from members'
                : 'Make final standings visible to all members',
            onTap: () => _togglePublish(ref, event),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionRow(
            label: isLocked ? 'Unlock' : 'Lock',
            description: isLocked
                ? 'Re-open scores for editing'
                : 'Finalise all scorecards — no further changes allowed',
            onTap: () => _toggleLock(ref, event),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionRow(
            label: 'Remind',
            description: 'Notify members who have not yet submitted their scorecard',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminders sent to players with incomplete scorecards.')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePublish(WidgetRef ref, GolfEvent event) async {
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(isStatsReleased: !event.isStatsReleased),
    );
  }

  Future<void> _toggleLock(WidgetRef ref, GolfEvent event) async {
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(isScoringLocked: !event.isScoringLocked),
    );
  }

  Future<void> _confirmUnlock(
    BuildContext context,
    WidgetRef ref,
    GolfEvent event,
    String entryId,
    String markerEntryId,
    String playerName,
    String markerName,
  ) async {
    await BoxyArtBottomSheet.show(
      context: context,
      title: 'Unlock Scorecard',
      child: _UnlockConfirmSheet(
        playerName: playerName,
        markerName: markerName,
        onConfirm: () async {
          Navigator.of(context).pop();
          await _unlockCard(ref, event.id, entryId, markerEntryId, playerName, markerName);
        },
      ),
    );
  }

  Future<void> _unlockCard(
    WidgetRef ref,
    String eventId,
    String entryId,
    String markerEntryId,
    String playerName,
    String markerName,
  ) async {
    final repo = ref.read(scorecardRepositoryProvider);
    final scorecards = ref.read(scorecardsListProvider(eventId)).value ?? [];
    final playerCard = scorecards.firstWhereOrNull((s) => s.entryId == entryId);
    final markerCard = scorecards.firstWhereOrNull((s) => s.entryId == markerEntryId);
    if (playerCard != null) {
      await repo.updateScorecard(playerCard.copyWith(
        status: ScorecardStatus.draft,
        verifiedByPlayer: false,
        verifiedByMarker: false,
        updatedAt: DateTime.now(),
      ));
    }
    if (markerCard != null) {
      await repo.updateScorecard(markerCard.copyWith(
        status: ScorecardStatus.draft,
        verifiedByPlayer: false,
        verifiedByMarker: false,
        updatedAt: DateTime.now(),
      ));
    }
    _sendUnlockNotifications(ref, eventId, entryId, markerEntryId, playerName, markerName);
  }

  void _sendUnlockNotifications(
    WidgetRef ref,
    String eventId,
    String entryId,
    String markerEntryId,
    String playerName,
    String markerName,
  ) {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final content = ref.read(platformContentProvider).value ?? const PlatformContent();
      final now = DateTime.now();
      repo.sendNotification(AppNotification(
        id: '',
        recipientId: entryId.replaceAll('_guest', ''),
        title: 'Scorecard Unlocked',
        message: content.scorecardUnlockedPlayer,
        timestamp: now,
        category: 'Scoring',
        eventId: eventId,
      ));
      final markerMemberId = markerEntryId.replaceAll('_guest', '');
      if (markerMemberId != entryId.replaceAll('_guest', '')) {
        repo.sendNotification(AppNotification(
          id: '',
          recipientId: markerMemberId,
          title: 'Scorecard Unlocked',
          message: content.resolve(content.scorecardUnlockedMarker, {'playerName': playerName}),
          timestamp: now,
          category: 'Scoring',
          eventId: eventId,
        ));
      }
    } catch (_) {}
  }
}

// ── Unlock confirm sheet ───────────────────────────────────────────────────────

class _UnlockConfirmSheet extends StatefulWidget {
  final String playerName;
  final String markerName;
  final Future<void> Function() onConfirm;

  const _UnlockConfirmSheet({
    required this.playerName,
    required this.markerName,
    required this.onConfirm,
  });

  @override
  State<_UnlockConfirmSheet> createState() => _UnlockConfirmSheetState();
}

class _UnlockConfirmSheetState extends State<_UnlockConfirmSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.playerName.split(' ').first;
    final hasMarker = widget.markerName.isNotEmpty;
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BoxyArtStatusBanner(
            color: AppColors.amber500,
            icon: Icons.lock_open_rounded,
            message: hasMarker
                ? 'This will reset verification for $firstName and their marker (${widget.markerName}). Both will need to re-verify before the card can be approved again.'
                : 'This will reset verification for $firstName. They will need to re-verify before the card can be approved again.',
            hasBottomMargin: false,
          ),
          const SizedBox(height: AppSpacing.standard),
          BoxyArtButton(
            title: _loading ? 'Unlocking…' : 'Unlock ${widget.playerName}',
            icon: Icons.lock_open_rounded,
            isPrimary: true,
            fullWidth: true,
            onTap: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    await widget.onConfirm();
                  },
          ),
        ],
      ),
    );
  }
}

// ── Verify metric ──────────────────────────────────────────────────────────────

class _VerifyMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool isAlert;

  const _VerifyMetric({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color valueColor = isAlert && value != '0'
        ? AppColors.coral500
        : highlight && value != '0'
            ? AppColors.lime500
            : (isDark ? AppColors.pureWhite : AppColors.dark900);
    final Color labelColor = isAlert && value != '0'
        ? AppColors.coral500
        : highlight && value != '0'
            ? AppColors.lime500
            : AppColors.dark400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: labelColor,
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.displaySection.copyWith(
              color: valueColor,
              fontWeight: AppTypography.weightBold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ActionRow({
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final primary = Theme.of(context).colorScheme.primary;
    final radius = shapes?.button ?? BorderRadius.circular(8);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 160,
          child: Material(
            color: primary.withValues(alpha: AppColors.opacityLow),
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              highlightColor: primary.withValues(alpha: AppColors.opacitySubtle),
              splashColor: primary.withValues(alpha: AppColors.opacitySubtle),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightBold,
                      color: primary,
                      letterSpacing: AppTypography.lsLabel,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.standard),
        Expanded(
          child: Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.dark200 : AppColors.dark400,
            ),
          ),
        ),
      ],
    );
  }
}
