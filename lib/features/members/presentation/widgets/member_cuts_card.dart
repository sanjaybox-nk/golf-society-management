import 'package:flutter/material.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/features/admin/logic/society_cuts_engine.dart';
import 'package:intl/intl.dart';

class MemberCutsCard extends StatelessWidget {
  final String memberId;
  final List<GolfEvent> allEvents;
  final SocietyConfig config;

  const MemberCutsCard({
    super.key,
    required this.memberId,
    required this.allEvents,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (config.societyCutMode == SocietyCutMode.off) return const SizedBox.shrink();

    final breakdown = SocietyCutsEngine.calculateActiveCut(
      memberId: memberId,
      allEvents: allEvents,
      config: config,
    );

    if (breakdown.totalCut == 0 && breakdown.sources.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOCIETY CUTS',
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'ACTIVE PERFORMANCE ADJUSTMENTS',
                    style: AppTypography.micro.copyWith(
                      color: isDark ? AppColors.dark400 : AppColors.dark300,
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.coral500.withValues(alpha: AppColors.opacityLow),
                  borderRadius: BorderRadius.circular(AppShapes.rPill),
                ),
                child: Text(
                  '-${breakdown.totalCut.toStringAsFixed(1)} pt',
                  style: AppTypography.labelStrong.copyWith(color: AppColors.coral500),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Sources Breakdown
          ...breakdown.sources.map((source) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      source.finish,
                      style: AppTypography.micro.copyWith(
                        fontWeight: AppTypography.weightBlack,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.eventName.toUpperCase(),
                          style: AppTypography.label.copyWith(
                            fontWeight: AppTypography.weightBold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(source.eventDate),
                          style: AppTypography.micro.copyWith(
                            color: isDark ? AppColors.dark400 : AppColors.dark300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '-${source.cutAmount.toStringAsFixed(1)}',
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      color: AppColors.coral500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const BoxyArtDivider(verticalPadding: AppSpacing.sm),
          
          // Validity Info
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: isDark ? AppColors.dark400 : AppColors.dark300,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _getValidityString(config),
                  style: AppTypography.micro.copyWith(
                    color: isDark ? AppColors.dark400 : AppColors.dark300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getValidityString(SocietyConfig config) {
    if (config.societyCutEventLimit == 0) {
      return 'Cut active for the remainder of the season.';
    }
    
    final type = config.societyCutCountPlayedOnly ? 'played' : 'held';
    return 'Cuts stay active for up to ${config.societyCutEventLimit} $type events.';
  }
}
