import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';

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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
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
                    BoxyArtAvatar(
                      url: avatarUrl,
                      initials: (firstName.isNotEmpty ? firstName[0] : '') +
                                (lastName.isNotEmpty ? lastName[0] : ''),
                      radius: 40,
                      isCircle: true,
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
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'SINCE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textColor.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        joinedDate!.year.toString(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(width: AppSpacing.lg),

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
                                Text(
                                  nickname != null && nickname!.isNotEmpty
                                      ? '"$nickname"'
                                      : '',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  '${firstName.toUpperCase()} ${lastName.toUpperCase()}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
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
                      
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status, theme.colorScheme.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(config.cardRadius / 2),
                              border: Border.all(
                                color: _getStatusColor(status, theme.colorScheme.primary).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status, theme.colorScheme.primary),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _getStatusColor(status, theme.colorScheme.primary),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Role Badge
                          if (role != null && role != MemberRole.member)
                            GestureDetector(
                              onTap: onRoleTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(config.cardRadius / 2),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  role!.name.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),

                          // Society Role Badge
                          if (societyRole != null && societyRole!.isNotEmpty)
                            GestureDetector(
                              onTap: onSocietyRoleTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.amber500.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(config.cardRadius / 2),
                                  border: Border.all(
                                    color: AppColors.amber500.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  societyRole!.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.amber500,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
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

  Color _getStatusColor(MemberStatus status, Color primaryColor) {
    switch (status) {
      case MemberStatus.member:
      case MemberStatus.active:
        return primaryColor;
      case MemberStatus.pending:
      case MemberStatus.gracePeriod:
        return AppColors.amber500;
      case MemberStatus.suspended:
      case MemberStatus.expired:
        return AppColors.amber500;
      case MemberStatus.left:
      case MemberStatus.archived:
      case MemberStatus.inactive:
        return AppColors.coral500;
    }
  }
}
