import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/society_config.dart';
import '../../../matchplay/domain/match_play_tournament.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/presentation/tournament_wizard_provider.dart';
import '../../../members/presentation/members_provider.dart';

/// Returns a human-readable label for a match round type.
String getRoundLabel(MatchRoundType round) {
  return switch (round) {
    MatchRoundType.group       => 'Group Stage',
    MatchRoundType.roundOf32   => 'Round of 32',
    MatchRoundType.roundOf16   => 'Round of 16',
    MatchRoundType.quarterFinal => 'Quarter-Finals',
    MatchRoundType.semiFinal    => 'Semi-Finals',
    MatchRoundType.finalRound   => 'The Final',
  };
}

// ── Deadlines section ─────────────────────────────────────────────────────────

class MatchPlayDeadlinesSection extends StatelessWidget {
  const MatchPlayDeadlinesSection({
    super.key,
    required this.state,
    required this.notifier,
    required this.config,
  });

  final TournamentWizardState state;
  final TournamentWizardNotifier notifier;
  final SocietyConfig config;

  @override
  Widget build(BuildContext context) {
    final rounds = _requiredRounds(state.entrants.length, state.type);
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROUND DEADLINES',
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppTypography.sizeMicro,
              fontWeight: AppTypography.weightStrong,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...rounds.mapIndexed((index, round) => Column(
                children: [
                  _RoundDeadlinePicker(
                    round: round,
                    currentDate: state.roundCutoffs[round],
                    onChanged: (date) => notifier.setRoundCutoff(round, date),
                  ),
                  if (index < rounds.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Divider(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                        height: 1,
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }

  List<MatchRoundType> _requiredRounds(int entrantCount, TournamentType type) {
    if (type == TournamentType.divisionsPlusKnockout) {
      return [MatchRoundType.group, MatchRoundType.roundOf16, MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
    }
    if (entrantCount <= 2)  return [MatchRoundType.finalRound];
    if (entrantCount <= 4)  return [MatchRoundType.semiFinal, MatchRoundType.finalRound];
    if (entrantCount <= 8)  return [MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
    if (entrantCount <= 16) return [MatchRoundType.roundOf16, MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
    return [MatchRoundType.roundOf32, MatchRoundType.roundOf16, MatchRoundType.quarterFinal, MatchRoundType.semiFinal, MatchRoundType.finalRound];
  }
}

class _RoundDeadlinePicker extends StatelessWidget {
  const _RoundDeadlinePicker({required this.round, this.currentDate, required this.onChanged});

  final MatchRoundType round;
  final DateTime? currentDate;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    final displayDate = currentDate != null ? DateFormat('d MMM yyyy').format(currentDate!) : 'Set Deadline';
    return Row(
      children: [
        Expanded(
          child: Text(
            getRoundLabel(round),
            style: AppTypography.labelStrong.copyWith(color: Theme.of(context).colorScheme.onSurface, height: 1.2),
          ),
        ),
        BoxyArtButton(
          title: displayDate.toUpperCase(),
          icon: Icons.calendar_today_rounded,
          isSmall: true,
          isPrimary: false,
          isSecondary: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: currentDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) onChanged(picked);
          },
        ),
      ],
    );
  }
}

// ── Entrant list item ─────────────────────────────────────────────────────────

class MatchPlayEntrantListItem extends StatelessWidget {
  const MatchPlayEntrantListItem({
    super.key,
    required this.entrant,
    this.member,
    this.handicapIndex,
    required this.onRemove,
    required this.theme,
    required this.config,
  });

  final MatchPlayEntrant entrant;
  final Member? member;
  final double? handicapIndex;
  final VoidCallback onRemove;
  final ThemeData theme;
  final SocietyConfig config;

  @override
  Widget build(BuildContext context) {
    final phc = handicapIndex?.clamp(0.0, 28.0).toInt();
    final initials = member != null
        ? '${member!.firstName.isNotEmpty ? member!.firstName[0] : ''}${member!.lastName.isNotEmpty ? member!.lastName[0] : ''}'.toUpperCase()
        : (entrant.name.length >= 2 ? entrant.name.substring(0, 2).toUpperCase() : entrant.name.toUpperCase());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(entrant.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.coral500.withValues(alpha: AppColors.opacityHigh),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.x2l),
          child: const Icon(Icons.delete_outline, color: AppColors.pureWhite, size: AppShapes.iconLg),
        ),
        confirmDismiss: (_) async => showBoxyArtDialog<bool>(
          context: context,
          title: 'Remove Entrant?',
          message: 'Remove ${entrant.name} from the tournament draw?',
          confirmText: 'Remove',
          isDangerous: true,
        ),
        onDismissed: (_) => onRemove(),
        child: BoxyArtMemberRow(
          name: entrant.name,
          initials: initials,
          avatarUrl: member?.avatarUrl,
          handicapIndex: handicapIndex,
          playingHandicap: phc,
          useCard: true,
          showChevron: false,
          showVerticalDivider: true,
          accentColor: null,
          trailing: null,
        ),
      ),
    );
  }
}

// ── Manual add-entrant dialog ─────────────────────────────────────────────────

class MatchPlayEntrantsStep {
  static void addManual(
    BuildContext context,
    TournamentWizardState state,
    TournamentWizardNotifier notifier,
    WidgetRef ref,
    String eventId,
  ) {
    final members = ref.read(allMembersProvider).value ?? [];
    Member? selected;

    showBoxyArtDialog(
      context: context,
      title: 'Add Manual Entrant',
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Manually add a player who is not in the registration list.'),
            const SizedBox(height: AppSpacing.xl),
            DropdownButtonFormField<Member>(
              items: members.map((m) => DropdownMenuItem(value: m, child: Text(m.displayName))).toList(),
              onChanged: (m) => setState(() => selected = m),
              decoration: const InputDecoration(labelText: 'Select Member'),
            ),
          ],
        ),
      ),
      confirmText: 'Add',
      onConfirm: () {
        if (selected != null) {
          notifier.addEntrant(MatchPlayEntrant(
            id: const Uuid().v4(),
            name: selected!.displayName,
            playerIds: [selected!.id],
          ));
        }
      },
    );
  }
}
