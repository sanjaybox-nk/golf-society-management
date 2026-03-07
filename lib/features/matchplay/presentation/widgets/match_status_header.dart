import 'package:golf_society/design_system/design_system.dart';

import '../../domain/match_definition.dart';

class MatchStatusHeader extends StatelessWidget {
  final MatchDefinition? match;
  final MatchResult result;
  final String? team1Name; // Optional override
  final String? team2Name; // Optional override

  const MatchStatusHeader({
    super.key,
    this.match,
    required this.result,
    this.team1Name,
    this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    if (result.holesPlayed == 0 && match == null) return const SizedBox.shrink();

    // Calculate strokes given info
    String? strokesInfo;
    if (match != null) {
      if (match!.type == MatchType.singles && match!.team1Ids.length == 1 && match!.team2Ids.length == 1) {
        final s1 = match!.strokesReceived[match!.team1Ids.first] ?? 0;
        final s2 = match!.strokesReceived[match!.team2Ids.first] ?? 0;
        if (s1 != s2) {
          final diff = (s1 - s2).abs();
          final receiver = s1 > s2 ? (team1Name ?? 'Side A') : (team2Name ?? 'Side B');
          strokesInfo = '$receiver receives $diff strokes';
        }
      } else if (match!.type == MatchType.fourball || match!.type == MatchType.foursomes) {
        strokesInfo = 'Net handicaps applied per SI';
      }
    }

    // Determine color based on status
    Color statusColor = AppColors.textSecondary;
    if (result.status.contains('UP') || result.status.contains('&')) {
      statusColor = Colors.blueAccent;
    } else if (result.status == 'A/S') {
      statusColor = AppColors.amber500;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xl), // [FIX] Align with HoleByHoleScoringWidget padding
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: AppColors.opacityLow),
        border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: AppColors.opacityMuted))),
      ),
      child: Row(
        children: [
          // Left: Strokes Info / Subtext
          Expanded(
            child: Text(
              strokesInfo ?? 'Match Status', // Fallback label if no strokes info
              style: TextStyle(
                fontSize: AppTypography.sizeCaption,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                fontWeight: AppTypography.weightSemibold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Right: Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: AppShapes.xs,
            ),
            child: Text(
              result.status,
              style: const TextStyle(
                fontSize: AppTypography.sizeCaptionStrong,
                fontWeight: AppTypography.weightBold,
                color: AppColors.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
