import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_shadows.dart';
import '../theme/app_theme.dart';
import '../theme/status_colors.dart';
import '../theme/contrast_helper.dart'; // [NEW]
import '../theme/theme_controller.dart';
import '../../models/member.dart';
import 'badges.dart';

/// A card with a soft diffused shadow and high rounded corners.
class BoxyArtFloatingCard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;

  const BoxyArtFloatingCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.width = double.infinity,
    this.height,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate themed background
    final primary = Theme.of(context).primaryColor;
    final baseColor = Theme.of(context).cardColor;
    
    // Apply tint based on config
    final tintedColor = Color.alphaBlend(
      primary.withValues(alpha: config.cardTintIntensity * (isDark ? 0.15 : 0.05)),
      baseColor,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: tintedColor,
        gradient: config.useCardGradient 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tintedColor,
                  isDark ? tintedColor.withValues(alpha: 0.8) : tintedColor.withValues(alpha: 0.95),
                ],
              ) 
            : null,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ] : AppShadows.softScale,
        border: border ?? Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A standard card for settings items.
class BoxyArtSettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const BoxyArtSettingsCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxShadowDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: AppShadows.inputSoft,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

// Helper to use BoxShadow with BoxDecoration since ShapeDecoration is more restrictive
class BoxShadowDecoration extends BoxDecoration {
  const BoxShadowDecoration({
    super.color,
    super.gradient,
    super.borderRadius,
    super.boxShadow,
  });
}

/// The Main Member Header Card used in Detail Views.
class BoxyArtMemberHeaderCard extends ConsumerWidget {
  final String firstName;
  final String lastName;
  final String? nickname;
  final MemberStatus status;
  final bool hasPaid;
  final String? avatarUrl;
  final TextEditingController? handicapController;
  final TextEditingController? whsController;
  final FocusNode? handicapFocusNode;
  final FocusNode? whsFocusNode;
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
    this.whsController,
    this.handicapFocusNode,
    this.whsFocusNode,
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
    // Determine status display label
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active) 
        ? "Active" 
        : status.displayName;
    
    final bool canEdit = isAdmin && isEditing;

    // Force White Layout (Consistent with MemberTile)
    const textColor = Colors.black87;
    const subTextColor = Colors.black54;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                        child: avatarUrl == null
                            ? Text(
                                (firstName.isNotEmpty ? firstName[0] : '') +
                                (lastName.isNotEmpty ? lastName[0] : ''),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              )
                            : null,
                      ),
                      if (onCameraTap != null) // Allow any member to upload their profile picture
                        GestureDetector(
                          onTap: onCameraTap,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: ContrastHelper.getContrastingText(Theme.of(context).primaryColor),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 20),
              // Name / Stats Section (Top Right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      firstName.isEmpty && lastName.isEmpty ? 'New Member' : '$firstName $lastName',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // HC / iGolf Stats Row (Under Name)
                    if (isEditing)
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HC', 
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subTextColor)
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: TextFormField(
                                    controller: handicapController,
                                    focusNode: handicapFocusNode,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    readOnly: !isAdmin,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isAdmin ? Colors.black : Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'iGolf No', 
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subTextColor)
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: TextFormField(
                                    controller: whsController,
                                    focusNode: whsFocusNode,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HC',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: subTextColor),
                              ),
                              Text(
                                handicapController?.text ?? '-',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Container(width: 1, height: 20, color: Colors.black12),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'iGolf No',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: subTextColor),
                              ),
                              Text(
                                whsController?.text ?? '-',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
                              ),
                            ],
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Status Pill (Interactive for Admin)
              if (canEdit && isAdmin)
                PopupMenuButton<MemberStatus>(
                  onSelected: onStatusChanged,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  offset: const Offset(0, 48),
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
                                      ? Theme.of(context).primaryColor 
                                      : (s.color == StatusColors.neutral ? Colors.black87 : s.color),
                                ),
                              ),
                          ))
                      .toList(),
                  child: BoxyArtStatusPill(
                    text: statusLabel,
                    baseColor: status.color,
                    backgroundColorOverride: Colors.white.withValues(alpha: 0.6),
                  ),
                )
              else
                BoxyArtStatusPill(
                  text: statusLabel,
                  baseColor: status.color,
                  backgroundColorOverride: Colors.white.withValues(alpha: 0.6),
                ),
              
              const SizedBox(width: 4),

              // 2. Fee Pill (Interactive for Admin)
              if (isAdmin) 
                IgnorePointer(
                  ignoring: !canEdit,
                  child: BoxyArtFeePill(
                    isPaid: hasPaid,
                    onToggle: () => onFeeToggle?.call(!hasPaid),
                  ),
                ),

              const SizedBox(width: 4),

              // 3. Member Role Badge (System Role) - Moved here
                  if (isAdmin && ((role != null && role != MemberRole.member) || onRoleTap != null))
                     GestureDetector(
                       onTap: canEdit ? onRoleTap : null,
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.transparent,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                         ),
                         child: Text(
                           _getRoleLabel(role ?? MemberRole.viewer).toUpperCase(),
                           style: TextStyle(
                             color: Theme.of(context).primaryColor,
                             fontSize: 10,
                             fontWeight: FontWeight.bold,
                             letterSpacing: 0.5,
                           ),
                         ),
                       ),
                     ),

              const Spacer(),

              // 4. Society Role (President etc) - Moved to Bottom Right
              if (onSocietyRoleTap != null && canEdit)
                GestureDetector(
                  onTap: onSocietyRoleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (societyRole?.isNotEmpty == true ? societyRole! : 'No Title').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
              else if (societyRole?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    societyRole!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  ],
);
}

  String _getRoleLabel(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Admin';
      case MemberRole.restrictedAdmin: return 'Restricted';
      case MemberRole.viewer: return 'Viewer';
      case MemberRole.member: return 'Member';
    }
  }
}
