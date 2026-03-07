import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/handicap_system.dart';
import '../member_details_modal.dart';

class MemberTile extends ConsumerWidget {
  final Member member;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool showFeeStatus;
  final String? secondaryMetricLabel; 
  final String? secondaryMetricValue;

  const MemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.showFeeStatus = false,
    this.secondaryMetricLabel,
    this.secondaryMetricValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    
    return BoxyArtCard(
      onTap: onTap ?? () => MemberDetailsModal.show(context, member),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary.withValues(alpha: AppColors.opacityLow),
                        width: AppShapes.borderMedium,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: AppShapes.pill,
                      child: member.avatarUrl != null 
                          ? Image.network(member.avatarUrl!, fit: BoxFit.cover)
                          : Container(
                              color: primary.withValues(alpha: AppColors.opacitySubtle),
                              child: Center(
                                child: Text(
                                  '${member.firstName[0]}${member.lastName[0]}',
                                  style: AppTypography.displaySection.copyWith(
                                    color: primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (member.joinedDate != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Since ${member.joinedDate!.year}',
                      style: AppTypography.caption.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: AppSpacing.xl),
              
              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      style: AppTypography.displaySubPage,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Metrics Grid
                    Consumer(
                      builder: (context, ref, child) {
                        final society = ref.watch(themeControllerProvider);
                        final system = society.handicapSystem;
                        
                        return Row(
                          children: [
                            _buildMetricColumn(
                              context,
                              'HANDICAP',
                              member.handicap.toStringAsFixed(1),
                            ),
                            const SizedBox(width: AppSpacing.x2l),
                            _buildMetricColumn(
                              context,
                              secondaryMetricLabel ?? system.idLabel, // If provided use it, else default
                              secondaryMetricValue ?? (member.handicapId ?? '-'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Status Row
          Row(
            children: [
              _buildStatusPill(
                member.status.displayName,
                member.status.color,
              ),
              if (member.societyRole?.isNotEmpty == true) ...[
                const SizedBox(width: AppSpacing.sm),
                _buildStatusPill(
                  member.societyRole!,
                  primary,
                  isOutline: true,
                ),
              ],
              const Spacer(),
              if (showFeeStatus && member.hasPaid)
                _buildStatusPill(
                  'Fee Paid',
                  StatusColors.positive,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.microSmall.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.displayLargeBody.copyWith(
            fontWeight: AppTypography.weightBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isOutline ? null : color.withValues(alpha: AppColors.opacitySubtle),
        borderRadius: AppShapes.xl,
        border: isOutline ? Border.all(color: color.withValues(alpha: AppColors.opacityMuted), width: AppShapes.borderThin) : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.micro.copyWith(
          color: color,
        ),
      ),
    );
  }
}
