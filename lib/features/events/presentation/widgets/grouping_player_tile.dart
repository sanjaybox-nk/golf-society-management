import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/course_config.dart';
import '../../../../domain/grouping/grouping_service.dart';

class GroupingPlayerTile extends ConsumerWidget {
  final TeeGroupParticipant player;
  final TeeGroup group;
  final Member? member;
  final List<GolfEvent> history;
  final int totalGroups;
  final CompetitionRules? rules;
  final CourseConfig? courseConfig;
  final bool useWhs;
  final bool isAdmin;
  final Function(String action, TeeGroupParticipant p, TeeGroup g)? onAction;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool useCard;
  final bool hasGuest;
  final bool isScoreMode;
  final String? scoreDisplay;
  final bool isWinner;
  final String? tieBreakLabel;
  final String? thruLabel;
  final double? handicapIndex;
  final ScoringStatus scoringStatus;
  final bool hasSocietyCut;
  final bool isStableford;
  final String? subScoreDisplay;
  final String? matchSide; // [NEW] Side A or B for Match Play
  final int? phcOverride;
  final bool hasGuestInGroup; // [NEW] Member who brought a guest
  final bool isEventClosed; // [NEW] surfaced only once admin has confirmed cards and closed the game
  final String? teamLabel; // 'A' or 'B' for Ryder Cup / team matchplay

  const GroupingPlayerTile({
    super.key,
    required this.player,
    required this.group,
    this.member,
    required this.history,
    required this.totalGroups,
    this.rules,
    this.courseConfig,
    this.useWhs = true,
    this.isAdmin = false,
    this.onAction,
    this.onTap,
    this.isSelected = false,
    this.useCard = true,
    this.hasGuest = false,
    this.isScoreMode = false,
    this.scoreDisplay,
    this.isWinner = false,
    this.matchSide,
    this.phcOverride,
    this.tieBreakLabel,
    this.thruLabel,
    this.handicapIndex,
    this.scoringStatus = ScoringStatus.ok,
    this.hasSocietyCut = false,
    this.isStableford = false,
    this.subScoreDisplay,
    this.hasGuestInGroup = false,
    this.isEventClosed = false,
    this.teamLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    // Single Source of Truth: PHC comes from stored grouping data.
    final int displayPhc = phcOverride ?? player.playingHandicap.round();

    // Calculate Variety Color (Priority: Match Side > Grouping History)
    Color? varietyColor;
    if (matchSide != null && config.showMatchPlayOverlay) {
       // Match Play side coloring removed as per user preference
       varietyColor = null;
    } else if (!player.isGuest) {
      final matchesCount = GroupingService.getTeeTimeVariety(
        player.registrationMemberId,
        group.index,
        totalGroups,
        history,
      );
      if (matchesCount == 0) {
        varietyColor = AppColors.lime600;
      } else if (matchesCount == 1) {
        varietyColor = AppColors.amber500;
      } else {
        varietyColor = AppColors.coral500;
      }
    }

    // Score Text Formatting (v4.0 standardized)
    final bool isScramble = rules?.format == CompetitionFormat.scramble;
    final bool isDq = scoringStatus == ScoringStatus.dq;
    final bool hasScore = isScoreMode && (scoreDisplay != null && scoreDisplay != '-') && !isScramble && !isDq;

    final teeColor = AppColors.getTeeColor(player.teeName, courseConfig?.tees);

    final String? resolvedSecondaryName = teamLabel != null
        ? 'Team $teamLabel'
        : (player.isGuest && member != null ? 'Guest of ${member!.displayName}' : null);
    final Color? resolvedSecondaryColor = teamLabel == 'A'
        ? AppColors.teamA
        : teamLabel == 'B'
            ? AppColors.teamB
            : null;

    return BoxyArtMemberRow(
      name: player.name,
      secondaryName: resolvedSecondaryName,
      secondaryNameColor: resolvedSecondaryColor,
      initials: player.name,
      avatarUrl: member?.avatarUrl,
      handicapIndex: handicapIndex ?? player.handicapIndex,
      playingHandicap: displayPhc,
      isGuest: player.isGuest,
      isCaptain: player.isCaptain,
      hasMemberGuest: hasGuestInGroup,
      isWinner: isWinner,
      matchSide: config.showMatchPlayOverlay ? matchSide : null,
      varietyPillarColor: varietyColor,
      hasSocietyCut: hasSocietyCut,
      thruLabel: isDq ? thruLabel : thruLabel,
      score: isDq ? 'DQ' : (hasScore ? scoreDisplay : null),
      isStableford: isStableford,
      scoreColor: isDq
          ? AppColors.coral500
          : (hasScore && scoreDisplay != null)
              ? _matchScoreColor(scoreDisplay!)
              : null,
      subScore: subScoreDisplay,
      subScoreColor: subScoreDisplay != null ? _matchScoreColor(subScoreDisplay!) : null,
      tieBreakLabel: isEventClosed ? tieBreakLabel : null,
      teeName: player.teeName,
      teeColor: teeColor,
      onTeeTap: null,
      onTap: onTap,
      isSelected: isSelected,
      useCard: useCard,
      showTee: !isScoreMode,
      showVerticalDivider: true,
      showChevron: false,
      accentColor: null,
      leading: isAdmin
        ? GestureDetector(
            onTap: () => _showPlayerActions(context),
            child: _buildAvatarStack(context, isScoreMode, varietyColor, hasGuestInGroup),
          )
        : null,
    );
  }

  void _showPlayerActions(BuildContext context) {
    BoxyArtBottomSheet.show(
      context: context,
      title: player.name,
      child: BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BoxyArtNavTile(
              icon: Icons.drive_file_move_outlined,
              title: 'Move to Group',
              subtitle: 'Transfer player to a different tee time',
              onTap: () { Navigator.pop(context); onAction?.call('move', player, group); },
            ),
            const BoxyArtDivider(),
            BoxyArtNavTile(
              icon: Icons.person_remove_outlined,
              title: 'Remove from Group',
              subtitle: 'Return player to the unassigned pool',
              onTap: () { Navigator.pop(context); onAction?.call('remove', player, group); },
            ),
            const BoxyArtDivider(),
            BoxyArtNavTile(
              icon: Icons.shield_outlined,
              title: player.isCaptain ? 'Remove Captain' : 'Make Captain',
              subtitle: player.isCaptain
                  ? 'Remove captain status from this player'
                  : group.players.any((p) => p != player && p.isCaptain)
                      ? 'Transfer captaincy to this player'
                      : 'Assign as group captain',
              onTap: () { Navigator.pop(context); onAction?.call('captain', player, group); },
            ),
            const BoxyArtDivider(),
            BoxyArtNavTile(
              icon: Icons.exit_to_app,
              title: 'Withdraw Member',
              subtitle: 'Mark as withdrawn from this event',
              iconColor: AppColors.coral500,
              badgeColor: AppColors.coral500.withValues(alpha: AppColors.opacityLow),
              onTap: () { Navigator.pop(context); onAction?.call('withdraw', player, group); },
            ),
          ],
        ),
      ),
    );
  }

  static Color? _matchScoreColor(String status) {
    final s = status.toUpperCase();
    if (s.contains('WIN') || s.contains('WON') || s.contains(' UP')) return AppColors.lime700;
    if (s.contains('LOST') || s.contains('LOSS') || s.contains(' DN') || s.contains('HALVED') || s.contains('A/S')) return AppColors.coral500;
    return null;
  }

  Widget _buildAvatarStack(BuildContext context, bool isScoreMode, Color? varietyColor, bool hasGuestInGroup) {
    final avatar = BoxyArtAvatar(
      url: member?.avatarUrl,
      initials: extractInitials(player.name),
      radius: 38,
      isCircle: true,
    );
    if (!isAdmin || isScoreMode) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          top: -4,
          right: -4,
          child: BoxyArtIconBadge(
            icon: Icons.more_vert,
            color: Theme.of(context).primaryColor,
            size: 18,
            iconSize: 11,
            useCircle: true,
          ),
        ),
      ],
    );
  }
}


