import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/features/events/presentation/widgets/grouping_widgets.dart';

/// Horizontal scrollable pool of players who are confirmed but not yet assigned
/// to any tee group. Players can be dragged from here into a group slot.
class GroupingSquadPool extends StatelessWidget {
  const GroupingSquadPool({
    super.key,
    required this.squad,
    required this.memberMap,
  });

  final List<TeeGroupParticipant> squad;
  final Map<String, Member> memberMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacitySubtle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxyArtSectionTitle(title: 'SQUAD POOL (${squad.length})'),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              itemCount: squad.length,
              itemBuilder: (context, idx) {
                final p = squad[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: LongPressDraggable<Map<String, dynamic>>(
                    data: {'player': p, 'group': null},
                    delay: AppAnimations.fast,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: AppShapes.x2l,
                      child: GroupingPlayerAvatar(
                        player: p,
                        member: memberMap[p.registrationMemberId],
                        size: AppShapes.iconHero,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GroupingPlayerAvatar(
                          player: p,
                          member: memberMap[p.registrationMemberId],
                          size: AppShapes.iconXl,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              p.name.split(' ').first,
                              style: const TextStyle(
                                fontSize: AppTypography.sizeCaption,
                                fontWeight: AppTypography.weightMedium,
                              ),
                            ),
                            if (p.isGuest) ...[
                              const SizedBox(width: AppShapes.borderMedium),
                              const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: AppTypography.sizeMicroSmall,
                                  color: AppColors.amber500,
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
