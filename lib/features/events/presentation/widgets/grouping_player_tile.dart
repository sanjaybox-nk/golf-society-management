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
  final String? matchSide; // [NEW] Side A or B for Match Play
  final int? phcOverride;
  final bool hasGuestInGroup; // [NEW] Member who brought a guest
  final bool isEventClosed; // [NEW] surfaced only once admin has confirmed cards and closed the game

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
    this.hasGuestInGroup = false,
    this.isEventClosed = false,
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

    final theme = Theme.of(context);

    // Score Text Formatting (v4.0 standardized)
    final bool isScramble = rules?.format == CompetitionFormat.scramble;
    final bool isDq = scoringStatus == ScoringStatus.dq;
    final bool hasScore = isScoreMode && (scoreDisplay != null && scoreDisplay != '-') && !isScramble && !isDq;

    final teeColor = AppColors.getTeeColor(player.teeName, courseConfig?.tees);

    return BoxyArtMemberRow(
      name: player.name,
      secondaryName: (player.isGuest && member != null) ? 'Guest of ${member!.displayName}' : null,
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
      scoreColor: isDq ? AppColors.coral500 : null,
      tieBreakLabel: isEventClosed ? tieBreakLabel : null,
      teeName: player.teeName,
      teeColor: teeColor,
      onTeeTap: isAdmin ? () => onAction?.call('tee', player, group) : null,
      onTap: onTap,
      isSelected: isSelected,
      useCard: useCard,
      showTee: !isScoreMode,
      showVerticalDivider: true,
      showChevron: false,
      accentColor: null,
      leading: isAdmin 
        ? PopupMenuButton<String>(
            onSelected: (val) => onAction?.call(val, player, group),
            color: theme.brightness == Brightness.dark ? AppColors.dark700 : AppColors.pureWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 8,
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'move',
                child: Row(
                  children: [
                    Icon(Icons.drive_file_move_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Move to Group...'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tee',
                child: Row(
                  children: [
                    Icon(Icons.flag_circle_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Change Tee...'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Remove from Group'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'captain',
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Toggle Captain'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'withdraw',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, size: AppShapes.iconSm, color: AppColors.coral500),
                    const SizedBox(width: AppSpacing.md),
                    const Text('Withdraw Member', style: TextStyle(color: AppColors.coral500)),
                  ],
                ),
              ),
            ],
            child: _buildAvatarStack(context, isScoreMode, varietyColor, hasGuestInGroup),
          )
        : null, // BoxyArtMemberRow handles standard avatar if leading is null
    );
  }

  Widget _buildAvatarStack(BuildContext context, bool isScoreMode, Color? varietyColor, bool hasGuestInGroup) {
    return BoxyArtAvatar(
      url: member?.avatarUrl,
      initials: extractInitials(player.name),
      radius: 38,
      isCircle: true,
      borderColor: Colors.transparent,
      borderWidth: 0,
    );
  }
}


