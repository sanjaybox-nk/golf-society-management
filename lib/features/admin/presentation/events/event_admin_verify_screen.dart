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
  DateTime? _lastReminderSent;

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
          topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
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

    final bool hasPending = (fieldCount + readyCount + conflictCount) > 0;

    String? lastSentNote;
    if (_lastReminderSent != null) {
      final mins = DateTime.now().difference(_lastReminderSent!).inMinutes;
      lastSentNote = mins < 1 ? 'Just sent' : 'Last sent ${mins}m ago';
    }

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
          _RemindAction(
            hasPending: hasPending,
            lastSentNote: lastSentNote,
            onTap: hasPending ? () => _sendReminders(context, ref, event, scorecards) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _sendReminders(BuildContext context, WidgetRef ref, GolfEvent event, List<Scorecard> scorecards) async {
    final approvedIds = scorecards
        .where((s) => s.status == ScorecardStatus.approved)
        .map((s) => s.entryId)
        .toSet();

    final pendingMemberIds = event.registrations
        .where((r) => !approvedIds.contains(r.memberId) && !approvedIds.contains('${r.memberId}_guest'))
        .map((r) => r.memberId)
        .whereType<String>()
        .toList();

    if (pendingMemberIds.isEmpty) return;

    final repo = ref.read(notificationsRepositoryProvider);
    final now = DateTime.now();
    for (final memberId in pendingMemberIds) {
      try {
        repo.sendNotification(AppNotification(
          id: '',
          recipientId: memberId,
          title: 'Scorecard Reminder',
          message: 'Please submit your scorecard for ${event.title}. The committee is waiting to close the round.',
          timestamp: now,
          category: 'Scoring',
          eventId: event.id,
        ));
      } catch (_) {}
    }

    setState(() => _lastReminderSent = now);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder sent to ${pendingMemberIds.length} player${pendingMemberIds.length == 1 ? '' : 's'}.')),
      );
    }
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.micro.copyWith(
              color: AppColors.dark400,
              fontWeight: AppTypography.weightBold,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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

// ── Remind action ────────────────────────────────────────────────────────────

class _RemindAction extends StatelessWidget {
  final bool hasPending;
  final String? lastSentNote;
  final VoidCallback? onTap;

  const _RemindAction({
    required this.hasPending,
    required this.lastSentNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nudge members who have not yet submitted their scorecard',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.dark400,
          ),
        ),
        const SizedBox(height: AppSpacing.atomic),
        BoxyArtButton(
          title: 'REMIND',
          isTinted: true,
          isPrimary: false,
          fullWidth: true,
          onTap: onTap,
        ),
        if (lastSentNote != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            lastSentNote!,
            textAlign: TextAlign.center,
            style: AppTypography.micro.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
            ),
          ),
        ],
      ],
    );
  }
}


