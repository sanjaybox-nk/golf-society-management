import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:collection/collection.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/match_play_calculator.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';

// ── Draft match card ──────────────────────────────────────────────────────────

/// Displays one match in the draft bracket, with swap-selection highlight and
/// a "Manage" button to enter manual results.
class MatchPlayDraftMatchItem extends ConsumerWidget {
  const MatchPlayDraftMatchItem({
    super.key,
    required this.match,
    required this.isPublished,
    this.eventId,
    this.selectedMatchId,
    this.selectedTeamIndex,
    required this.onPlayerTap,
    required this.onManageResult,
  });

  final MatchDefinition match;
  final bool isPublished;
  final String? eventId;
  final String? selectedMatchId;
  final int? selectedTeamIndex;
  final void Function(int teamIndex) onPlayerTap;
  final VoidCallback onManageResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final members = ref.watch(allMembersProvider).value ?? [];

    final p1 = match.team1Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team1Ids.first) : null;
    final p2 = match.team2Ids.isNotEmpty ? members.firstWhereOrNull((m) => m.id == match.team2Ids.first) : null;

    if (isPublished && eventId != null) {
      final scorecards = ref.watch(scorecardsListProvider(eventId!)).value ?? [];
      final event = ref.watch(eventProvider(eventId!)).value;
      if (event != null) {
        MatchPlayCalculator.calculate(
          match: match,
          scorecards: scorecards,
          courseConfig: event.courseConfig,
          holesToPlay: event.courseConfig.holes.length,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: BoxyArtButton(
                title: 'MANAGE',
                isSmall: true,
                isSecondary: true,
                onTap: onManageResult,
              ),
            ),
          ),
          _MatchupPlayerCard(
            member: p1,
            isSelected: selectedMatchId == match.id && selectedTeamIndex == 1,
            onTap: () => onPlayerTap(1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Center(
              child: Text(
                'Vs',
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightHeavy,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          _MatchupPlayerCard(
            member: p2,
            isSelected: selectedMatchId == match.id && selectedTeamIndex == 2,
            onTap: () => onPlayerTap(2),
          ),
        ],
      ),
    );
  }
}

class _MatchupPlayerCard extends StatelessWidget {
  const _MatchupPlayerCard({this.member, this.isSelected = false, required this.onTap});

  final Member? member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return const BoxyArtMemberRow(
        name: 'BYE',
        initials: '?',
        useCard: true,
        showChevron: false,
        showVerticalDivider: false,
      );
    }

    final phc = member!.handicap.clamp(0.0, 28.0).toInt();
    final initials =
        '${member!.firstName.isNotEmpty ? member!.firstName[0] : ''}${member!.lastName.isNotEmpty ? member!.lastName[0] : ''}'
            .toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2)]
              : null,
        ),
        child: BoxyArtMemberRow(
          name: member!.displayName,
          initials: initials,
          avatarUrl: member!.avatarUrl,
          handicapIndex: member!.handicap,
          playingHandicap: phc,
          useCard: true,
          showChevron: false,
          showVerticalDivider: false,
        ),
      ),
    );
  }
}

// ── Manual result sheet ───────────────────────────────────────────────────────

/// Bottom-sheet modal for entering or overriding a match result.
class MatchPlayManualResultSheet extends StatelessWidget {
  const MatchPlayManualResultSheet({super.key, required this.match, required this.onUpdate});

  final MatchDefinition match;
  final void Function(MatchResult?) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.dark700,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.dark400, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'ADMIN OVERRIDE',
            style: AppTypography.label.copyWith(
              color: AppColors.amber500,
              fontWeight: AppTypography.weightBlack,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Manual Result Entry', style: AppTypography.headline.copyWith(color: AppColors.pureWhite)),
          const SizedBox(height: AppSpacing.hero),
          _OverrideOption(
            title: 'Award Side A Walkover',
            subtitle: 'Advances ${match.team1Name ?? "Side A"}',
            icon: Icons.emoji_events_outlined,
            onTap: () => onUpdate(MatchResult(
              matchId: match.id, winningTeamIndex: 0, status: 'WALKOVER',
              score: 18, holeResults: [], holesPlayed: 0, isFinal: true,
            )),
          ),
          const SizedBox(height: AppSpacing.md),
          _OverrideOption(
            title: 'Award Side B Walkover',
            subtitle: 'Advances ${match.team2Name ?? "Side B"}',
            icon: Icons.emoji_events_outlined,
            onTap: () => onUpdate(MatchResult(
              matchId: match.id, winningTeamIndex: 1, status: 'WALKOVER',
              score: 18, holeResults: [], holesPlayed: 0, isFinal: true,
            )),
          ),
          const SizedBox(height: AppSpacing.md),
          _OverrideOption(
            title: 'Enter Custom Result...',
            subtitle: 'Set a specific score (e.g. 3&2)',
            icon: Icons.edit_note_rounded,
            onTap: () => _showScoreDialog(context),
          ),
          if (match.manualResult != null) ...[
            const SizedBox(height: AppSpacing.hero),
            BoxyArtButton(
              title: 'CLEAR OVERRIDE',
              isPrimary: false,
              isSecondary: true,
              onTap: () => onUpdate(null),
              fullWidth: true,
            ),
          ],
          const SizedBox(height: AppSpacing.hero),
        ],
      ),
    );
  }

  Future<void> _showScoreDialog(BuildContext context) async {
    final controller = TextEditingController();
    int winner = 1;
    try {
      await BoxyArtDialog.show(
        context: context,
        title: 'Custom Result',
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxyArtInputField(controller: controller, label: 'Result Text', hint: 'e.g. 2 & 1'),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: BoxyArtButton(title: 'Side A Wins', isSmall: true, isPrimary: winner == 1, isSecondary: winner != 1, onTap: () => setState(() => winner = 1))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: BoxyArtButton(title: 'Side B Wins', isSmall: true, isPrimary: winner == 2, isSecondary: winner != 2, onTap: () => setState(() => winner = 2))),
                ],
              ),
            ],
          ),
        ),
        confirmText: 'SET RESULT',
        onConfirm: () {
          onUpdate(MatchResult(
            matchId: match.id,
            winningTeamIndex: winner - 1,
            status: controller.text.toUpperCase(),
            score: 1,
            holeResults: [],
            holesPlayed: 0,
            isFinal: true,
          ));
        },
      );
    } finally {
      controller.dispose();
    }
  }
}

class _OverrideOption extends StatelessWidget {
  const _OverrideOption({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.dark400.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.pureWhite, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelStrong.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: AppTypography.weightBold,
                    fontSize: AppTypography.sizeLabel,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(subtitle, style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.dark400),
        ],
      ),
    );
  }
}
