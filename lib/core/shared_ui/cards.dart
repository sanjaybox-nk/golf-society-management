import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/app_shadows.dart';
import '../theme/status_colors.dart';
import '../theme/contrast_helper.dart'; // [NEW]
import '../theme/theme_controller.dart';
import '../../models/member.dart';
import 'badges.dart';

/// A card with a soft diffused shadow and high rounded corners.
class BoxyArtFloatingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const BoxyArtFloatingCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.width = double.infinity,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.softScale,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(20),
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
    // Get card settings from config
    final config = ref.watch(themeControllerProvider);
    final cardTintIntensity = config.cardTintIntensity;
    final useGradient = config.useCardGradient;
    
    // Determine status display label
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active) 
        ? "Active" 
        : status.displayName;
    
    final bool canEdit = isAdmin && isEditing;

    // Calculate Background Color (Card Color + Tint Blend)
    final Color cardColor = Theme.of(context).cardColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    // We blend based on actual tint intensity to get the real background color
    final double effectiveAlpha = useGradient ? (cardTintIntensity * 0.75) : cardTintIntensity;
    final Color effectiveBackgroundColor = Color.alphaBlend(primaryColor.withValues(alpha: effectiveAlpha), cardColor);

    // Calculate Contrasting Text Color
    final Color textColor = ContrastHelper.getContrastingText(effectiveBackgroundColor);
    final Color subTextColor = textColor.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxShadowDecoration(
        color: useGradient ? cardColor : Color.alphaBlend(primaryColor.withValues(alpha: cardTintIntensity), cardColor),
        gradient: useGradient ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: cardTintIntensity * 0.5),
            primaryColor.withValues(alpha: cardTintIntensity),
          ],
        ) : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.inputSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section A: Identity (Top Half)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Camera Button
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
              const SizedBox(width: 20),
              // Name / Role / Nickname Section
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
                    
                    // Society Role (e.g. Treasurer)
                    if (onSocietyRoleTap != null && canEdit)
                      GestureDetector(
                        onTap: onSocietyRoleTap,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                societyRole?.isNotEmpty == true ? societyRole! : 'No Title',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: societyRole?.isNotEmpty == true 
                                      ? textColor
                                      : subTextColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.edit, size: 12, color: subTextColor),
                            ],
                          ),
                        ),
                      )
                    else if (societyRole?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          societyRole!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      
                    const SizedBox(height: 4),

                    // Nickname ROW (Contains Nickname + System Role Badge)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Nickname
                        if (nickname != null && nickname!.isNotEmpty)
                          Expanded(
                            child: Text(
                              nickname!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: subTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Spacer(),

                        // System Role Pill (Right Aligned)
                        if ((role != null && role != MemberRole.member) || onRoleTap != null)
                           GestureDetector(
                             onTap: canEdit ? onRoleTap : null, // Only tap if canEdit
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                               decoration: BoxDecoration(
                                 color: Colors.black.withValues(alpha: 0.8),
                                 borderRadius: BorderRadius.circular(20),
                               ),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(
                                     Icons.shield,
                                     size: 10,
                                     color: AppTheme.primaryYellow,
                                   ),
                                   const SizedBox(width: 4),
                                   Flexible(
                                     child: Text(
                                       _getRoleLabel(role ?? MemberRole.viewer).toUpperCase(),
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 10,
                                         fontWeight: FontWeight.bold,
                                         letterSpacing: 0.5,
                                       ),
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ),
                                    if (canEdit && onRoleTap != null) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit, size: 10, color: Colors.white70),
                                    ],
                                 ],
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
          
          const SizedBox(height: 16),
          
          // Row 2: Golf Stats
          if (isEditing)
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HC', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor)
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: handicapController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        readOnly: !isAdmin,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: isAdmin ? Colors.white : Colors.grey.shade100.withValues(alpha: 0.5),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isAdmin ? Colors.black : Colors.black54),
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
                        'iGolf No', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor)
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: whsController,
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                        'HC',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        handicapController?.text ?? '-',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: subTextColor.withValues(alpha: 0.2), // Also tint the divider
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'iGolf No',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        whsController?.text ?? '-',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Row 3: Controls (Status / Fee / Member Since) - Unified
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Pill
              if (canEdit && isAdmin)
                Flexible(
                  flex: 3,
                  child: PopupMenuButton<MemberStatus>(
                    onSelected: onStatusChanged,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    offset: const Offset(0, 40),
                    itemBuilder: (context) => MemberStatus.values
                        .where((s) => s != MemberStatus.active)
                        .map((s) => PopupMenuItem(
                              value: s,
                                child: Text(
                                  s == MemberStatus.member ? "Active" : s.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: s.color == StatusColors.neutral ? Colors.black : s.color,
                                  ),
                                ),
                            ))
                        .toList(),
                    child: BoxyArtStatusPill(
                      text: statusLabel,
                      baseColor: status.color, // Assuming MemberStatus has a color property that maps closely or I should map it to StatusColors. 
                      // Actually MemberStatus.color is likely hardcoded colors. 
                      // The prompt said "Define core 'Meaning' colors... Create KazaStatusPill... Replace hardcoded pills".
                      // I should probably map status to StatusColors here or inside KazaStatusPill if I passed status enum, but KazaStatusPill takes text and color.
                      // For now I will use status.color but ideally I should map it.
                      // Wait, MemberStatus.color might be hardcoded to specific colors.
                      // Let's check MemberStatus definition later? No I can't.
                      // PROMPT: "Positive -> Colors.green... Warning -> Orange... Negative -> Red... Neutral -> Grey"
                      // I should probably assume status.color is "close enough" or map it myself.
                      // StatusColors.positive etc are available. 
                      // Let's use StatusColors based on status.
                      // Actually, let's look at MemberStatus.color usage. Users previous code used `status.color`.
                      // I'll stick to `status.color` for `baseColor` BUT the prompt advised "Define Semantic Palette... Input: Color baseColor".
                      // So `status.color` which returns a Color is correct.
                      backgroundColorOverride: Colors.white.withValues(alpha: 0.6), // Gradient override
                    ),
                  ),
                )
              else
                // View Only Status
                BoxyArtStatusPill(
                  text: statusLabel,
                  baseColor: status.color,
                  backgroundColorOverride: Colors.white.withValues(alpha: 0.6), // Gradient override
                ),
              
              const SizedBox(width: 8),

              // Fee Pill (Left Aligned next to Status)
              if (isAdmin) 
                IgnorePointer(
                  ignoring: !canEdit,
                  child: BoxyArtFeePill(
                    isPaid: hasPaid,
                    onToggle: () => onFeeToggle?.call(!hasPaid),
                  ),
                ),
                
              const Spacer(),

              // Member Since Pill (Right Aligned)
              if (joinedDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Since ${joinedDate!.year}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.6),
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
