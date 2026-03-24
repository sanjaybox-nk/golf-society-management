import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/domain/models/handicap_system.dart';

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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).primaryColor;
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    
    // Determine status display label
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active) 
        ? "Active" 
        : status.displayName;
    
    final bool canEdit = isAdmin && isEditing;

    final society = ref.watch(themeControllerProvider);
    final system = society.handicapSystem;

    return BoxyArtCard(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
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
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(AppShapes.rPill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, size: 10, color: Colors.white),
                            SizedBox(width: 4),
                            Text('EDIT', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (joinedDate != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Since ${joinedDate!.year}',
                      style: AppTypography.micro.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                      ),
                    ),
                  ],
                ],
              ),

              // 2. Vertical Divider
              Container(
                width: 1,
                height: 104,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySubtle),
              ),

              // 3. Right Section: Information Stack
              Expanded(
                child: SizedBox(
                  height: 104, // Matches identity block
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3a. Top half: Name, Status, Roles
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Member Name
                          Text(
                            toTitleCase('$firstName $lastName'),
                            style: AppTypography.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Status Indicator Row (with green pipe)
                          PopupMenuButton<MemberStatus>(
                            enabled: isAdmin && isEditing,
                            color: theme.colorScheme.surfaceContainer,
                            elevation: 4,
                            offset: const Offset(0, 24),
                            shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
                            itemBuilder: (context) => MemberStatus.values
                                .where((s) => s != MemberStatus.active)
                                .map((s) => PopupMenuItem(
                                        value: s,
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                                        child: Text(
                                          s == MemberStatus.member ? "Active" : s.displayName,
                                          style: AppTypography.body.copyWith(
                                            fontWeight: s == status ? AppTypography.weightHeavy : AppTypography.weightStrong,
                                            color: s == status 
                                                ? primary 
                                                : (s.color == StatusColors.neutral ? textColor : s.color),
                                          ),
                                        ),
                                    ))
                                .toList(),
                            onSelected: onStatusChanged,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 3,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: status == MemberStatus.active 
                                        ? theme.primaryColor 
                                        : AppColors.amber500,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  statusLabel,
                                  style: AppTypography.label.copyWith(
                                    color: status == MemberStatus.active 
                                        ? theme.primaryColor 
                                        : AppColors.amber500,
                                    fontWeight: AppTypography.weightStrong,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Role Pills
                          if (societyRole?.isNotEmpty == true || (isAdmin && role != null && role != MemberRole.member))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: 4,
                                children: [
                                  if (societyRole?.isNotEmpty == true)
                                    GestureDetector(
                                      onTap: isAdmin && isEditing ? onSocietyRoleTap : null,
                                      child: BoxyArtPill(
                                        label: societyRole!,
                                        color: Color(config.iconBadgeFillColor),
                                        textColor: Color(config.iconBadgeIconColor),
                                        hasHorizontalMargin: false,
                                      ),
                                    ),
                                  if (isAdmin && role != null && role != MemberRole.member)
                                    GestureDetector(
                                      onTap: isAdmin && isEditing ? onRoleTap : null,
                                      child: BoxyArtPill(
                                        label: toTitleCase(role!.displayName),
                                        color: StatusColors.neutral,
                                        hasHorizontalMargin: false,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 4. Admin Action Menu (Top Right)
          if (onActionTap != null)
            Positioned(
              top: -AppSpacing.sm,
              right: -AppSpacing.sm,
              child: IconButton(
                onPressed: onActionTap,
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityMedium),
                ),
              ),
            ),
          
          // 5. Fee Pill (Bottom Right)
          if (isAdmin)
             Positioned(
              bottom: 0,
              right: 0,
              child: BoxyArtFeePill(
                isPaid: hasPaid,
                onToggle: () => onFeeToggle?.call(!hasPaid),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({required BuildContext context, required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
