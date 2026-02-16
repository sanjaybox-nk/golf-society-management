import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/member.dart';
import '../../../../models/handicap_system.dart';
import '../../../../core/shared_ui/modern_cards.dart';
import '../../../../core/theme/theme_controller.dart';
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
    final primary = theme.primaryColor;
    
    return ModernCard(
      onTap: onTap ?? () => MemberDetailsModal.show(context, member),
      padding: const EdgeInsets.all(18),
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
                        color: primary.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: member.avatarUrl != null 
                          ? Image.network(member.avatarUrl!, fit: BoxFit.cover)
                          : Container(
                              color: primary.withValues(alpha: 0.05),
                              child: Center(
                                child: Text(
                                  '${member.firstName[0]}${member.lastName[0]}',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (member.joinedDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Since ${member.joinedDate!.year}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 20),
              
              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),
                    
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
                            const SizedBox(width: 24),
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
          
          const SizedBox(height: 20),
          
          // Status Row
          Row(
            children: [
              _buildStatusPill(
                member.status.displayName,
                member.status.color,
              ),
              if (member.societyRole?.isNotEmpty == true) ...[
                const SizedBox(width: 8),
                _buildStatusPill(
                  member.societyRole!,
                  primary,
                  isOutline: true,
                ),
              ],
              const Spacer(),
              if (member.hasPaid)
                _buildStatusPill(
                  'Fee Paid',
                  const Color(0xFF27AE60),
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
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOutline ? null : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: isOutline ? Border.all(color: color.withValues(alpha: 0.3), width: 1) : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
