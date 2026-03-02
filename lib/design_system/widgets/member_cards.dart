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
    final subColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    final inputFill = isDark ? AppColors.dark600 : AppColors.dark50;
    final inputBorder = isDark ? AppColors.dark500 : AppColors.dark200;

    final society = ref.watch(themeControllerProvider);
    final system = society.handicapSystem;

    return BoxyArtCard(
      padding: const EdgeInsets.all(24),
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
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            width: 2,
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
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
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
                              boxShadow: [
                                BoxShadow(
                                 color: Colors.black.withValues(alpha: 0.2),
                                 blurRadius: 5,
                                 offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (joinedDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Since ${joinedDate!.year}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 24),
              // Name / Stats Section (Top Right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      '$firstName $lastName'.toUpperCase(),
                      style: AppTypography.displayHeading.copyWith(
                        fontSize: 22,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // HC / Handicap ID Stats Row (Under Name)
                    if (isEditing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: Text(
                                  'Handicap'.toUpperCase(),
                                  style: AppTypography.label.copyWith(
                                    fontSize: 10,
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
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isAdmin ? textColor : subColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: Text(
                                  system.idLabel.toUpperCase(),
                                  style: AppTypography.label.copyWith(
                                    fontSize: 10,
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
                                    hintStyle: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.dark200 : AppColors.dark300,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            handicapController?.text ?? '-',
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // iGolf Group
                          Text(
                            system.idLabel.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.dark200 : AppColors.dark300,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            handicapIdController?.text ?? '-',
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
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
          
          const SizedBox(height: 24),
          
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
                                  fontSize: 14,
                                  fontWeight: s == status ? FontWeight.bold : FontWeight.w600,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: AppShapes.pill,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (societyRole?.isNotEmpty == true ? societyRole! : 'NO TITLE').toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.actionText,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 12, color: AppColors.actionText),
                      ],
                    ),
                  ),
                )
              else if (societyRole?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: AppShapes.pill,
                  ),
                  child: Text(
                    societyRole!.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.actionText,
                      letterSpacing: 1.0,
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: AppShapes.sm,
            ),
            child: Center(
              child: Text(
                '$position',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 13,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
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
