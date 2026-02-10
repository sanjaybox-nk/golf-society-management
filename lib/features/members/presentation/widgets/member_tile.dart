import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/status_colors.dart';
import '../../../../models/member.dart';
import '../member_details_modal.dart';
import '../members_provider.dart';

class MemberTile extends ConsumerWidget {
  final Member member;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool showFeeStatus;

  const MemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.showFeeStatus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // White Card Layout
    const backgroundColor = Colors.white;
    const textColor = Colors.black87;
    const subTextColor = Colors.black54;

    return GestureDetector(
      onTap: onTap ?? () => MemberDetailsModal.show(context, member),
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Column: Avatar + Since Year
            Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                  child: member.avatarUrl == null
                      ? Text(
                          (member.firstName.isNotEmpty ? member.firstName[0] : '') +
                              (member.lastName.isNotEmpty ? member.lastName[0] : ''),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        )
                      : null,
                ),
                if (member.joinedDate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Since ${member.joinedDate!.year}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Name
                  Text(
                    '${member.firstName} ${member.lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  
                  // Committee Badge (Below Name)
                  if (member.societyRole?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                           decoration: BoxDecoration(
                             color: Theme.of(context).primaryColor,
                             borderRadius: BorderRadius.circular(6),
                           ),
                           child: Text(
                             member.societyRole!.toUpperCase(),
                             style: const TextStyle(
                               color: Colors.white,
                               fontSize: 9,
                               fontWeight: FontWeight.w900,
                               letterSpacing: 0.5,
                             ),
                           ),
                         ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  
                  // Stats
                  Text(
                    'HC: ${member.handicap.toStringAsFixed(1)} | iGolf: ${member.whsNumber?.isNotEmpty == true ? member.whsNumber : '-'}',
                    style: const TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chips Row
                  Row(
                    children: [
                      // Status Chip (Admin Menu)
                      if (showFeeStatus)
                        Theme(
                          data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: PopupMenuButton<MemberStatus>(
                            enabled: true,
                            tooltip: 'Change Status',
                            offset: const Offset(0, 30),
                            padding: EdgeInsets.zero,
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            itemBuilder: (context) => [
                              MemberStatus.active,
                              MemberStatus.inactive,
                              MemberStatus.pending,
                              MemberStatus.suspended,
                              MemberStatus.archived,
                              MemberStatus.left,
                            ].map((status) => PopupMenuItem<MemberStatus>(
                              value: status,
                              height: 40,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8, 
                                    height: 8, 
                                    decoration: BoxDecoration(
                                      color: status.color, 
                                      shape: BoxShape.circle
                                    )
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    status.displayName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )).toList(),
                            onSelected: (newStatus) {
                              if (newStatus != member.status) {
                                ref.read(membersRepositoryProvider).updateMember(
                                  member.copyWith(status: newStatus)
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: member.status.color.withValues(alpha: 0.2), 
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                member.status.displayName,
                                style: TextStyle(
                                  color: member.status.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: member.status.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            member.status.displayName,
                            style: TextStyle(
                              color: member.status.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      
                      // Fee Chip (Context Controlled)
                      if (showFeeStatus) ...[
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ref.read(membersRepositoryProvider).updateMember(
                                member.copyWith(hasPaid: !member.hasPaid)
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: member.hasPaid 
                                    ? StatusColors.positive.withValues(alpha: 0.2) // Increased contrast
                                    : StatusColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                member.hasPaid ? 'Fee Paid' : 'Fee Due',
                                style: TextStyle(
                                  color: member.hasPaid ? StatusColors.positive : StatusColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            trailing ?? const Icon(Icons.chevron_right, color: subTextColor),
          ],
        ),
      ),
    );
  }
}
