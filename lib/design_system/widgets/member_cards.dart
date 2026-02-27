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
    // Determine status display label
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active) 
        ? "Active" 
        : status.displayName;
    
    final bool canEdit = isAdmin && isEditing;

    // Force White Layout (Consistent with MemberTile)
    const textColor = Colors.black87;

    final society = ref.watch(themeControllerProvider);
    final system = society.handicapSystem;

    return BoxyArtCard(
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
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
                                    fontWeight: FontWeight.w900,
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
                        color: Colors.black.withValues(alpha: 0.2),
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
                                BoxyArtSectionTitle(
                                  title: 'Handicap',
                                  padding: EdgeInsets.only(bottom: 6),
                                  isLevel2: true,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
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
                                BoxyArtSectionTitle(
                                  title: system.idLabel,
                                  padding: EdgeInsets.only(bottom: 6),
                                  isLevel2: true,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
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
                                BoxyArtSectionTitle(
                                  title: 'Handicap',
                                  isLevel2: true,
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
                                BoxyArtSectionTitle(
                                  title: system.idLabel,
                                  isLevel2: true,
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
              
              const SizedBox(width: 8),
              
              // 2. Member Role Badge (System Role)
              if (isAdmin && ((role != null && role != MemberRole.member) || onRoleTap != null))
                GestureDetector(
                  onTap: canEdit ? onRoleTap : null,
                  child: BoxyArtPill(
                    label: (role?.displayName ?? 'Member').toUpperCase(),
                    color: Colors.blueGrey,
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
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;

    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      backgroundColor: cardBg,
      borderRadius: 16,
      child: Row(
        children: [
          // Position badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
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
