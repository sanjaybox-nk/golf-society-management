import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

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
  final Function(int groupIndex)? onTap;
  final bool isStableford;

  const GroupingPodiumHeader({
    super.key,
    required this.entries,
    this.onTap,
    this.isStableford = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = AppSpacing.sm;
              final cardWidth = (constraints.maxWidth - gap * (entries.length - 1)) / entries.length;
              final widgets = <Widget>[];
              for (int i = 0; i < entries.length; i++) {
                if (i > 0) widgets.add(const SizedBox(width: gap));
                widgets.add(SizedBox(
                  width: cardWidth,
                  child: _buildPodiumCard(context, ref, entries[i]),
                ));
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets,
              );
            },
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
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.score,
                  style: AppTypography.displayHeading.copyWith(
                    fontSize: 32,
                    fontWeight: AppTypography.weightBlack,
                    color: Color(config.effectivePointsColor),
                  ),
                ),
                if (isStableford)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 2),
                    child: Text(
                      'pts',
                      style: AppTypography.micro.copyWith(
                        fontSize: 10,
                        fontWeight: AppTypography.weightBold,
                        color: Color(config.effectivePointsColor),
                      ),
                    ),
                  ),
              ],
            ),
            // Always reserve tiebreak height so BEST label stays aligned
            SizedBox(
              height: 16,
              child: entry.tieBreakLabel != null
                  ? Text(
                      entry.tieBreakLabel!.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTypography.micro.copyWith(
                        color: (isDark ? AppColors.pureWhite : AppColors.dark900)
                            .withValues(alpha: 0.4),
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: 1.0,
                      ),
                    )
                  : null,
            ),
            if (entry.formatLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
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
    );
  }
}
