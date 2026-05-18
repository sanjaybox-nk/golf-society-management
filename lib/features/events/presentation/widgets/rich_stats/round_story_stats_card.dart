import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/scorecard.dart';

class RoundStoryStatsCard extends StatelessWidget {
  final List<Scorecard> scorecards;

  const RoundStoryStatsCard({super.key, required this.scorecards});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final theme = Theme.of(context);

    int totalGimmes = 0;
    int totalPickUps = 0;
    int total1Stroke = 0;
    int total2Stroke = 0;

    for (final card in scorecards) {
      for (final tags in card.holeTags.values) {
        for (final tag in tags) {
          if (tag == 'GIMME') totalGimmes++;
          if (tag == 'PICK_UP') totalPickUps++;
          if (tag.startsWith('PENALTY_1_') ||
              (tag.startsWith('PENALTY_') &&
                  !tag.startsWith('PENALTY_1_') &&
                  !tag.startsWith('PENALTY_2_'))) { total1Stroke++; }
          if (tag.startsWith('PENALTY_2_')) total2Stroke++;
        }
      }
    }

    final totalPenaltyStrokes = total1Stroke + (total2Stroke * 2);

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2×2 grid
          Row(
            children: [
              _buildTile(context, theme, shapes, spacing,
                  Icons.check_circle_outline_rounded, 'GIMMES', '$totalGimmes'),
              SizedBox(width: spacing?.fieldToField ?? AppSpacing.atomic),
              _buildTile(context, theme, shapes, spacing,
                  Icons.upload_rounded, 'PICK UPS', '$totalPickUps'),
            ],
          ),
          SizedBox(height: spacing?.fieldToField ?? AppSpacing.atomic),
          Row(
            children: [
              _buildTile(context, theme, shapes, spacing,
                  Icons.warning_amber_rounded, '+1 STROKE', '$total1Stroke'),
              SizedBox(width: spacing?.fieldToField ?? AppSpacing.atomic),
              _buildTile(context, theme, shapes, spacing,
                  Icons.warning_rounded, '+2 STROKES', '$total2Stroke'),
            ],
          ),

          SizedBox(height: spacing?.fieldToField ?? AppSpacing.atomic),

          // Total — full width summary row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.atomic,
              horizontal: AppSpacing.atomic,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityLow),
              borderRadius: shapes?.button,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityMuted),
              ),
            ),
            child: Row(
              children: [
                BoxyArtIconBadge(
                  icon: Icons.add_circle_outline_rounded,
                  isTinted: true,
                ),
                SizedBox(width: spacing?.cardToLabel ?? AppSpacing.atomic),
                Expanded(
                  child: Text(
                    'TOTAL PENALTY STROKES',
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: AppTypography.lsLabel,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '$totalPenaltyStrokes',
                  style: AppTypography.headline.copyWith(
                    fontWeight: AppTypography.weightBlack,
                    color: theme.colorScheme.onSurface,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    ThemeData theme,
    AppShapeTokens? shapes,
    AppSpacingTokens? spacing,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.atomic),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: shapes?.button,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityLow),
          ),
        ),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: icon,
              isTinted: true,
            ),
            SizedBox(width: spacing?.cardToLabel ?? AppSpacing.atomic),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.micro.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                    fontWeight: AppTypography.weightBold,
                    letterSpacing: AppTypography.lsLabel,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.headline.copyWith(
                    fontWeight: AppTypography.weightBlack,
                    color: theme.colorScheme.onSurface,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
