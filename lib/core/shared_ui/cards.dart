import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_shadows.dart';
import '../theme/app_theme.dart';
import '../theme/status_colors.dart';
import '../theme/theme_controller.dart';
import '../../models/member.dart';
import '../../models/handicap_system.dart';
import 'badges.dart';
import 'modern_cards.dart';

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
    // Determine status display label
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active) 
        ? "Active" 
        : status.displayName;
    
    final bool canEdit = isAdmin && isEditing;

    // Force White Layout (Consistent with MemberTile)
    const textColor = Colors.black87;
    const subTextColor = Colors.black54;

    final society = ref.watch(themeControllerProvider);
    final system = society.handicapSystem;

    return ModernCard(
      padding: const EdgeInsets.all(20),
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
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
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
                      ),
                      if (onCameraTap != null) // Allow any member to upload their profile picture
                        GestureDetector(
                          onTap: onCameraTap,
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
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
                        color: Colors.black.withValues(alpha: 0.4),
                        letterSpacing: 0.5,
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
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.7,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // HC / Handicap ID Stats Row (Under Name)
                    if (isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HANDICAP', 
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: subTextColor, letterSpacing: 0.8)
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isAdmin ? Colors.black : Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  system.idLabel, 
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: subTextColor, letterSpacing: 0.8)
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HANDICAP',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: subTextColor, letterSpacing: 0.8),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  handicapController?.text ?? '-',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  system.idLabel,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: subTextColor, letterSpacing: 0.8),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  handicapIdController?.text ?? '-',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
                                ),
                              ],
                            ),
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
                    backgroundColorOverride: Colors.grey.shade50,
                  ),
                )
              else
                BoxyArtStatusPill(
                  text: statusLabel,
                  baseColor: status.color,
                  backgroundColorOverride: Colors.grey.shade50,
                ),
              
              const SizedBox(width: 8),
              
              // 2. Member Role Badge (System Role)
              if (isAdmin && ((role != null && role != MemberRole.member) || onRoleTap != null))
                GestureDetector(
                  onTap: canEdit ? onRoleTap : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Text(
                      _getRoleLabel(role ?? MemberRole.viewer).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              // 3. Fee Pill (Interactive for Admin)
              if (isAdmin) 
                IgnorePointer(
                  ignoring: !canEdit,
                  child: BoxyArtFeePill(
                    isPaid: hasPaid,
                    onToggle: () => onFeeToggle?.call(!hasPaid),
                  ),
                ),

              const SizedBox(width: 8),

              // 4. Society Role (President etc)
              if (onSocietyRoleTap != null && canEdit)
                GestureDetector(
                  onTap: onSocietyRoleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                )
              else if (societyRole?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    societyRole!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
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
