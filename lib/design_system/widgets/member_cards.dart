import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';
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
                              boxShadow: AppShadows.softScale,
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
                      style: AppTypography.microSmall.copyWith(
                        color: subColor,
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
                      '$firstName $lastName'.toUpperCase(),
                      style: AppTypography.displaySubPage.copyWith(
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                                  'Handicap'.toUpperCase(),
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
                                  system.idLabel.toUpperCase(),
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
                            'HANDICAP',
                            style: AppTypography.microSmall.copyWith(
                              color: isDark ? AppColors.dark200 : AppColors.dark300,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            handicapController?.text ?? '-',
                            style: AppTypography.displayLargeBody.copyWith(
                              fontSize: AppTypography.sizeBody,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // iGolf Group
                          Text(
                            system.idLabel.toUpperCase(),
                            style: AppTypography.microSmall.copyWith(
                              color: isDark ? AppColors.dark200 : AppColors.dark300,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            handicapIdController?.text ?? '-',
                            style: AppTypography.displayLargeBody.copyWith(
                              fontSize: AppTypography.sizeBody,
                              color: textColor,
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
          
          // Row 3: Bottom Row (Status, Fee, Member Badge -> ... -> Society Role)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 1. Status Pill (Interactive for Admin)
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
                  child: BoxyArtPill(
                    label: statusLabel,
                    color: status.color,
                  ),
                )
              else
                BoxyArtPill(
                  label: statusLabel,
                  color: status.color,
                ),
              
              // 2. Member Role Badge (System Role)
              if (isAdmin && ((role != null && role != MemberRole.member) || onRoleTap != null))
                GestureDetector(
                  onTap: canEdit ? onRoleTap : null,
                  child: BoxyArtPill(
                    label: (role?.displayName ?? 'Member').toUpperCase(),
                    color: StatusColors.neutral,
                  ),
                ),

              // 3. Fee Pill (Interactive for Admin)
              if (isAdmin) 
                IgnorePointer(
                  ignoring: !canEdit,
                  child: BoxyArtFeePill(
                    isPaid: hasPaid,
                    onToggle: () => onFeeToggle?.call(!hasPaid),
                  ),
                ),

              // 4. Society Role (President etc) - Standardized with Tokens
              if (onSocietyRoleTap != null && canEdit)
                GestureDetector(
                  onTap: onSocietyRoleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: AppShapes.pill,
                      boxShadow: AppShadows.softScale,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (societyRole?.isNotEmpty == true ? societyRole! : 'NO TITLE').toUpperCase(),
                          style: AppTypography.microSmall.copyWith(
                            color: AppColors.actionText,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.keyboard_arrow_down, size: AppShapes.iconXs, color: AppColors.actionText),
                      ],
                    ),
                  ),
                )
              else if (societyRole?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: AppShapes.pill,
                  ),
                  child: Text(
                    societyRole!.toUpperCase(),
                    style: AppTypography.microSmall.copyWith(
                      color: AppColors.actionText,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A card for member entries in a list.
class ModernMemberCard extends StatelessWidget {
  final String name;
  final int position;
  final String status;
  final Color statusColor;
  final List<Widget> actionIcons;
  final VoidCallback? onTap;

  const ModernMemberCard({
    super.key,
    required this.name,
    required this.position,
    required this.status,
    required this.statusColor,
    required this.actionIcons,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.dark60 : AppColors.dark950;

    return BoxyArtCard(
      onTap: onTap,
      backgroundColor: cardBg,
      borderRadius: AppShapes.rLg,
      child: Row(
        children: [
          // Position badge
          Container(
            width: AppSpacing.x3l,
            height: AppSpacing.x3l,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: AppColors.opacityLow),
              borderRadius: AppShapes.sm,
            ),
            child: Center(
              child: Text(
                '$position',
                style: AppTypography.labelStrong.copyWith(
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.button.copyWith(
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: AppTypography.microSmall.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actionIcons,
          ),
        ],
      ),
    );
  }
}
