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
  final TextEditingController? handicapController;
  final TextEditingController? handicapIdController;
  final FocusNode? handicapFocusNode;
  final FocusNode? handicapIdFocusNode;
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

  const BoxyArtMemberHeaderCard({
    super.key,
    required this.firstName,
    required this.lastName,
    this.nickname,
    required this.status,
    required this.hasPaid,
    this.avatarUrl,
    this.handicapController,
    this.handicapIdController,
    this.handicapFocusNode,
    this.handicapIdFocusNode,
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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).primaryColor;
    
    // Determine status display label
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active) 
        ? "Active" 
        : status.displayName;
    
    final bool canEdit = isAdmin && isEditing;

    // Determine Colors from Theme
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacityHalf);
    final inputFill = isDark ? AppColors.dark600 : AppColors.dark50;
    final inputBorder = isDark ? AppColors.dark500 : AppColors.dark200;

    final society = ref.watch(themeControllerProvider);
    final system = society.handicapSystem;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section A: Identity (Top Half)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityMedium),
                            width: AppShapes.borderMedium,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: isDark ? AppColors.dark600 : AppColors.dark50,
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                          child: avatarUrl == null
                              ? Text(
                                  (firstName.isNotEmpty ? firstName[0] : '') +
                                  (lastName.isNotEmpty ? lastName[0] : ''),
                                  style: AppTypography.displayLocker.copyWith(
                                    color: isDark ? AppColors.dark300 : AppColors.dark400,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (onCameraTap != null) // Allow any member to upload their profile picture
                        GestureDetector(
                          onTap: onCameraTap,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(AppSpacing.xs),
                              child: Icon(
                                Icons.camera_alt,
                                size: AppShapes.iconXs,
                                color: AppColors.pureWhite,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (joinedDate != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Since ${joinedDate!.year}',
                      style: AppTypography.caption.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                      ),
                    ),
                  ],
                  // [NEW] Society Role under Joined Date
                  if (societyRole?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: isAdmin && isEditing ? onSocietyRoleTap : null,
                      child: BoxyArtPill(
                        label: societyRole!,
                        color: primary,
                        textColor: AppColors.actionText,
                        icon: isAdmin && isEditing ? Icons.keyboard_arrow_down : null,
                      ),
                    ),
                  ],

                  // [NEW] System Role Badge under Society Role
                  if (isAdmin && ((role != null && role != MemberRole.member) || onRoleTap != null)) ...[
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: isAdmin && isEditing ? onRoleTap : null,
                      child: BoxyArtPill(
                        label: toTitleCase(role?.displayName ?? 'Member'),
                        color: StatusColors.neutral,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: AppSpacing.x2l),
              // Name / Stats Section (Top Right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      toTitleCase('$firstName $lastName'),
                      style: AppTypography.displaySubPage.copyWith(
                        color: textColor,
                        fontSize: 19,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // 1. Status Indicator (Relocated from bottom)
                    if (canEdit && isAdmin)
                      PopupMenuButton<MemberStatus>(
                        itemBuilder: (context) => MemberStatus.values
                            .where((s) => s != MemberStatus.active)
                            .map((s) => PopupMenuItem(
                                    value: s,
                                    child: Text(
                                      s == MemberStatus.member ? "Active" : s.displayName,
                                      style: TextStyle(
                                        fontSize: AppTypography.sizeBodySmall,
                                        fontWeight: s == status ? AppTypography.weightBold : AppTypography.weightSemibold,
                                        color: s == status 
                                            ? primary 
                                            : (s.color == StatusColors.neutral ? textColor : s.color),
                                      ),
                                    ),
                                ))
                            .toList(),
                        child: Text(
                          statusLabel,
                          style: AppTypography.displayUI.copyWith(
                            color: status.color,
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                      )
                    else
                      Text(
                        statusLabel,
                        style: AppTypography.displayUI.copyWith(
                          color: status.color,
                          fontWeight: AppTypography.weightBold,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.lg),
                    
                    // HC / Handicap ID Stats Row (Under Name)
                    if (isEditing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
                                child: Text(
                                  toTitleCase('Handicap'),
                                  style: AppTypography.micro.copyWith(
                                    color: isDark ? AppColors.dark150 : AppColors.dark300,
                                  ),
                                ),
                              ),
                              Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: inputFill,
                                  borderRadius: AppShapes.md,
                                  border: Border.all(color: inputBorder),
                                ),
                                child: TextFormField(
                                  controller: handicapController,
                                  focusNode: handicapFocusNode,
                                  textAlign: TextAlign.center,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  readOnly: !isAdmin,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isAdmin ? textColor : subColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
                                child: Text(
                                  toTitleCase(system.idLabel),
                                  style: AppTypography.micro.copyWith(
                                    color: isDark ? AppColors.dark150 : AppColors.dark300,
                                  ),
                                ),
                              ),
                              Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: inputFill,
                                  borderRadius: AppShapes.md,
                                  border: Border.all(color: inputBorder),
                                ),
                                child: TextFormField(
                                  controller: handicapIdController,
                                  focusNode: handicapIdFocusNode,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: system.hintText,
                                    hintStyle: AppTypography.micro.copyWith(color: AppColors.textSecondary),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handicap Group
                          Text(
                            toTitleCase('HANDICAP'),
                            style: AppTypography.microSmall.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            handicapController?.text ?? '-',
                            style: AppTypography.displayLargeBody.copyWith(
                              fontSize: 20,
                              color: textColor,
                              fontWeight: AppTypography.weightExtraBold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // iGolf Group
                          Text(
                            toTitleCase(system.idLabel),
                            style: AppTypography.microSmall.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            handicapIdController?.text ?? '-',
                            style: AppTypography.displayLargeBody.copyWith(
                              fontSize: 20,
                              color: textColor,
                              fontWeight: AppTypography.weightExtraBold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.x2l),
          
          // Row 3: Bottom Row (Fee Status Only)
          if (isAdmin)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IgnorePointer(
                  ignoring: !canEdit,
                  child: BoxyArtFeePill(
                    isPaid: hasPaid,
                    onToggle: () => onFeeToggle?.call(!hasPaid),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
