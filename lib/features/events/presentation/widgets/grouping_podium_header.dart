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

class PodiumEntry {
  final String name;
  final String score;
  final int rank;
  final int groupIndex; // [NEW] Link to actual group
  final String? tieBreakLabel;
  final String? formatLabel; // [NEW] e.g. "Best 3"

  PodiumEntry({
    required this.name,
    required this.score,
    required this.rank,
    required this.groupIndex,
    this.tieBreakLabel,
    this.formatLabel,
  });
}

class GroupingPodiumHeader extends ConsumerWidget {
  final List<PodiumEntry> entries;
  final Function(int groupIndex)? onTap; // [NEW] Callback for scrolling

  const GroupingPodiumHeader({
    super.key,
    required this.entries,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: entries.asMap().entries.map((item) {
              final idx = item.key;
              final entry = item.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: idx == 0 ? 0 : AppSpacing.sm,
                    right: idx == entries.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  child: _buildPodiumCard(context, ref, entry),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard(BuildContext context, WidgetRef ref, PodiumEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);

    Color rankColor = isDark ? AppColors.dark400 : AppColors.dark300;
    if (entry.rank == 1) rankColor = AppColors.amber500;
    if (entry.rank == 2) rankColor = isDark ? AppColors.dark200 : AppColors.dark600;
    if (entry.rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

    return GestureDetector(
      onTap: () => onTap?.call(entry.groupIndex),
      child: BoxyArtCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2l, horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '#${entry.rank}',
              style: AppTypography.label.copyWith(
                color: rankColor,
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              toTitleCase(entry.name),
              textAlign: TextAlign.center,
              style: AppTypography.displaySection.copyWith(
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
                fontSize: 20,
                fontWeight: AppTypography.weightExtraBold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    entry.score,
                    style: AppTypography.displayHeading.copyWith(
                      fontSize: 32,
                      fontWeight: AppTypography.weightBlack,
                      color: Color(config.effectivePointsColor),
                    ),
                  ),
                  if (entry.tieBreakLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        entry.tieBreakLabel!.toUpperCase(),
                        style: AppTypography.micro.copyWith(
                          color: (isDark ? AppColors.pureWhite : AppColors.dark900).withValues(alpha: 0.4),
                          fontWeight: AppTypography.weightBold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  if (entry.formatLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        entry.formatLabel!.toUpperCase(),
                        style: AppTypography.micro.copyWith(
                          fontSize: 8,
                          color: AppColors.dark300,
                          fontWeight: AppTypography.weightExtraBold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
