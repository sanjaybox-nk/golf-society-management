import 'package:golf_society/design_system/design_system.dart';

class SubmissionProgressBar extends StatelessWidget {
  final int total;
  final int submitted;
  final int inProgress;

  const SubmissionProgressBar({
    super.key,
    required this.total,
    required this.submitted,
    required this.inProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final double submittedPct = submitted / total;
    final double inProgressPct = inProgress / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      showShadow: true,
      customShadows: Theme.of(context).extension<AppShadows>()?.inputSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.lime500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'SUBMISSION PROGRESS',
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: isDark ? AppColors.dark150 : AppColors.dark400,
                    ),
                  ),
                ],
              ),
              Text(
                '$submitted / $total',
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightBlack,
                  fontSize: 17,
                  fontFamily: 'Plus Jakarta Sans',
                  color: AppColors.lime600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Stack(
            children: [
              // Background (Pending)
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dark200 : AppColors.dark100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // In Progress
              FractionallySizedBox(
                widthFactor: (submittedPct + inProgressPct).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.amber400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Submitted
              FractionallySizedBox(
                widthFactor: submittedPct.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.lime500,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(submittedPct * 100).round()}% COMPLETED',
                style: AppTypography.micro.copyWith(
                  fontWeight: AppTypography.weightBold,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.dark150 : AppColors.dark400,
                ),
              ),
              if (inProgress > 0)
                Text(
                  '$inProgress IN PROGRESS',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.amber500,
                    fontWeight: AppTypography.weightExtraBold,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
