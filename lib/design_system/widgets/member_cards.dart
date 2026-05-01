import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

/// The Main Member Header Card used in Detail Views.
class BoxyArtMemberHeaderCard extends ConsumerWidget {
  final String firstName;
  final String lastName;
  final String? nickname;
  final MemberStatus status;
  final bool hasPaid;
  final String? avatarUrl;
  final VoidCallback? onCameraTap;
  final ValueChanged<bool>? onFeeToggle;
  final ValueChanged<MemberStatus>? onStatusChanged;
  final bool isEditing;
  final bool isAdmin;
  final MemberRole? role;
  final VoidCallback? onRoleTap;
  final String? societyRole;
  final VoidCallback? onSocietyRoleTap;
  final DateTime? joinedDate;
  final VoidCallback? onActionTap;
  final bool showFeeIndicator;
  final bool isAdminContext;
  final bool isFoundingMember;

  const BoxyArtMemberHeaderCard({
    super.key,
    required this.firstName,
    required this.lastName,
    this.nickname,
    required this.status,
    required this.hasPaid,
    this.avatarUrl,
    this.onCameraTap,
    this.onFeeToggle,
    this.onStatusChanged,
    this.isEditing = true,
    this.isAdmin = true,
    this.role,
    this.onRoleTap,
    this.societyRole,
    this.onSocietyRoleTap,
    this.joinedDate,
    this.onActionTap,
    this.showFeeIndicator = true,
    this.isAdminContext = true,
    this.isFoundingMember = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    
    // Determine status display label
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active)
        ? "Active"
        : status.displayName;
    
    return BoxyArtCard(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left Section: Avatar & Since
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        BoxyArtAvatar(
                          url: avatarUrl,
                          initials: (firstName.isNotEmpty ? firstName[0] : '') +
                                    (lastName.isNotEmpty ? lastName[0] : ''),
                          radius: 40,
                          isCircle: true,
                        ),
                        if (isFoundingMember)
                          const Positioned(
                            top: -4,
                            right: -4,
                            child: BoxyArtIconBadge(
                              icon: Icons.star_rounded,
                              color: AppColors.lime500,
                              size: 26,
                              iconSize: 16,
                              useCircle: true,
                            ),
                          ),
                      ],
                    ),
                    if (onCameraTap != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: onCameraTap,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                    if (joinedDate != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'SINCE ${joinedDate!.year}',
                        style: AppTypography.micro.copyWith(
                          color: textColor.withValues(alpha: 0.6),
                          fontWeight: AppTypography.weightBold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),

                // Unified Vertical Divider
                Container(
                  width: 1,
                  height: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
                ),

                // 2. Middle Section: Name & Chips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (nickname != null && nickname!.isNotEmpty)
                                  Text(
                                    nickname!,
                                    style: AppTypography.label.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                      height: 1.0,
                                    ),
                                  ),
                                Text(
                                  toTitleCase('$firstName $lastName'),
                                  style: AppTypography.memberName.copyWith(
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onActionTap != null)
                            BoxyArtGlassIconButton(
                              icon: Icons.more_vert_rounded,
                              onPressed: onActionTap!,
                              iconSize: 20,
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 1. Status (Expired, etc.) - Always show for admins to allow editing
                            if (isAdminContext || (status != MemberStatus.active && status != MemberStatus.member)) ...[
                              BoxyArtIndicator(
                                label: statusLabel,
                                dotColor: status.color,
                                onTap: onStatusChanged != null ? () => onStatusChanged!(status) : null,
                                hasHorizontalMargin: false,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                            ],

                            // 2. Society Role Badge (Social Secretary, etc.)
                            if (societyRole != null && societyRole!.isNotEmpty) ...[
                              BoxyArtIndicator(
                                label: societyRole!,
                                dotColor: AppColors.amber500,
                                onTap: onSocietyRoleTap,
                                hasHorizontalMargin: false,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                            ],

                            // 2.5 Founding Member Badge
                            if (isFoundingMember) ...[
                              BoxyArtIndicator(
                                label: 'FOUNDING MEMBER',
                                dotColor: AppColors.lime500,
                                icon: Icons.star_rounded,
                                hasHorizontalMargin: false,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                            ],

                            // 3. Member Role Badge (Admin, etc.) - BOTTOM ALIGNED
                            if (isAdminContext && role != null && role != MemberRole.member)
                              BoxyArtIndicator(
                                label: role!.displayName,
                                dotColor: theme.colorScheme.primary,
                                onTap: onRoleTap,
                                hasHorizontalMargin: false,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Fee/Payment Indicator
          if (showFeeIndicator)
            Positioned(
              top: -AppSpacing.xs,
              right: -AppSpacing.xs,
              child: BoxyArtFeePill(
                isPaid: hasPaid,
                onToggle: isEditing ? () => onFeeToggle?.call(!hasPaid) : null,
              ),
            ),
        ],
      ),
    );
  }
}
