import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../../../domain/grouping/grouping_service.dart';


class GroupingPlayerAvatar extends StatelessWidget {
  final TeeGroupParticipant player;
  final Member? member;
  final double size;
  final int? groupIndex;
  final int? totalGroups;
  final List<GolfEvent>? history;

  const GroupingPlayerAvatar({
    super.key,
    required this.player,
    this.member,
    this.size = 40,
    this.groupIndex,
    this.totalGroups,
    this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BoxyArtAvatar(
          url: (member?.avatarUrl != null && !player.isGuest) ? member!.avatarUrl : null,
          initials: extractInitials(player.name),
          radius: size / 2,
        ),
        if (player.isCaptain && !player.isGuest)
          const Positioned(top: 0, left: 0, child: BoxyArtCaptainBadge()),
        if (player.isGuest)
          const Positioned(bottom: 0, right: 0, child: BoxyArtGuestBadge()),
      ],
    );
  }
}

