import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../domain/models/processed_event_data.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/course_config.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';
import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/match_play_calculator.dart';

class _CompactBadge extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final Color color;
  const _CompactBadge({this.icon, this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 9, color: AppColors.pureWhite)
          : Text(label ?? '', style: const TextStyle(color: AppColors.pureWhite, fontSize: 8, fontWeight: FontWeight.w800)),
    );
  }
}

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
          const Positioned(top: 0, left: 0, child: _CompactBadge(icon: Icons.shield_rounded, color: AppColors.amber500)),
        if (player.isGuest)
          const Positioned(bottom: 0, right: 0, child: _CompactBadge(label: 'G', color: AppColors.guestPurple)),
      ],
    );
  }
}

