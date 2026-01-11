import 'package:flutter/material.dart';
import '../../models/member.dart';

import '../theme/app_theme.dart';
import '../theme/app_shadows.dart';

// --- ELEMENT 1: Clean App Bar ---

class BoxyArtAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final bool showBack;

  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  const BoxyArtAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onProfilePressed,
    this.showBack = false,
    this.bottom,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _CircularIconBtn(
          icon: showBack ? Icons.arrow_back : Icons.menu,
          onTap: showBack ? () => Navigator.maybePop(context) : onMenuPressed,
        ),
      ),
      actions: actions ?? [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _CircularIconBtn(
            icon: Icons.person_outline,
            onTap: onProfilePressed,
          ),
        ),
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class _CircularIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircularIconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.floatingAlt,
          // border: Border.all(color: Colors.grey.shade200), // Shadow replaces border
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}


// --- ELEMENT 2: Floating Bottom Search ---

class FloatingBottomSearch extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const FloatingBottomSearch({super.key, this.onSearchTap, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Button (Left)
          Expanded(
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _ThemedCircleIcon(Icons.search),
                   SizedBox(width: 8),
                   Text("Search", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
          
          // Divider
          Container(width: 1, height: 24, color: Colors.white24),

          // Filter Button (Right)
          Expanded(
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _ThemedCircleIcon(Icons.tune), // Filter icon
                   SizedBox(width: 8),
                   Text("Filter", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemedCircleIcon extends StatelessWidget {
  final IconData icon;
  const _ThemedCircleIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black, size: 14),
    );
  }
}

// --- ELEMENT 3: BoxyArt Input Decoration & Fields ---

class BoxyArtFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines;
  final bool readOnly;

  const BoxyArtFormField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4), // Reduced spacing to 4 (8 inclusive of label padding)
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold, // Bold labels
              color: Colors.black, // Darker labels
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5), // Light grey background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 20 : 100),
            ),
            shadows: AppShadows.inputSoft,
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black54, size: 20) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class BoxyArtDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const BoxyArtDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5),
            shape: const StadiumBorder(),
            shadows: AppShadows.inputSoft,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              initialValue: value,
              items: items,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class BoxyArtDatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const BoxyArtDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: const StadiumBorder(),
              shadows: AppShadows.inputSoft,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.black54, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BoxyArtSwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BoxyArtSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: const StadiumBorder(),
        shadows: AppShadows.inputSoft,
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryYellow,
          activeTrackColor: AppTheme.primaryYellow.withValues(alpha: 0.2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

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
            color: Colors.white,
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

class BoxyArtMemberHeaderCard extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    // Determine status display label and color
    final String statusLabel = (status == MemberStatus.member || status == MemberStatus.active) 
        ? "Active" 
        : status.displayName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxShadowDecoration(
        color: Colors.white,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFF7D354)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.inputSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section A: Identity (Top Half)
          Row(
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
                  if (onCameraTap != null)
                    GestureDetector(
                      onTap: onCameraTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              // Name only in Top Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName.isEmpty && lastName.isEmpty ? 'New Member' : '$firstName $lastName',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (nickname != null && nickname!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          nickname!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Row 2: Golf Stats
          // Row 2: Golf Stats
          if (isEditing)
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: handicapController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    readOnly: !isAdmin,
                    decoration: InputDecoration(
                      labelText: 'HCP Index',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      isDense: true,
                      filled: true,
                      fillColor: isAdmin ? Colors.white : Colors.grey.shade100.withValues(alpha: 0.5),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isAdmin ? Colors.black : Colors.black54),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: whsController,
                    decoration: const InputDecoration(
                      labelText: 'WHS Number',
                      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                        'HCP INDEX',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        handicapController?.text ?? '-',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.black12,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHS NUMBER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        whsController?.text ?? '-',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Row 3: Admin Controls
          // Row 3: Admin Controls
          if (isAdmin)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status Dropdown
                PopupMenuButton<MemberStatus>(
                  onSelected: onStatusChanged,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  position: PopupMenuPosition.under,
                  itemBuilder: (context) => MemberStatus.values
                      .where((s) => s != MemberStatus.active && s != MemberStatus.inactive)
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text(
                              s == MemberStatus.member ? "Active" : s.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: s.color,
                              ),
                            ),
                          ))
                      .toList(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: status.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: status.color),
                    ],
                  ),
                ),
                const Spacer(),
                // Fee Pill
                BoxyArtFeePill(
                  isPaid: hasPaid,
                  onToggle: () => onFeeToggle?.call(!hasPaid),
                ),
              ],
            )
          else
            // Member View: Static Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Static Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ShapeDecoration(
                    color: status.color.withValues(alpha: 0.1),
                    shape: StadiumBorder(
                      side: BorderSide(color: status.color.withValues(alpha: 0.3), width: 1),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: status.color,
                    ),
                  ),
                ),
                const Spacer(),
                // Static Fee Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    color: hasPaid ? Colors.green.shade100 : Colors.orange.shade100,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: hasPaid ? Colors.green.shade300 : Colors.orange.shade300, 
                        width: 1.5
                      ),
                    ),
                  ),
                  child: Text(
                     hasPaid ? 'Fee Paid' : 'Fee Due',
                    style: TextStyle(
                      color: hasPaid ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
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

class BoxyArtFeePill extends StatefulWidget {
  final bool isPaid;
  final VoidCallback onToggle;

  const BoxyArtFeePill({
    super.key,
    required this.isPaid,
    required this.onToggle,
  });

  @override
  State<BoxyArtFeePill> createState() => _BoxyArtFeePillState();
}

class _BoxyArtFeePillState extends State<BoxyArtFeePill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isPaid ? Colors.green.shade100 : Colors.orange.shade100;
    final textColor = widget.isPaid ? const Color(0xFF1B5E20) : const Color(0xFFE65100);
    final borderColor = widget.isPaid ? Colors.green.shade300 : Colors.orange.shade300;
    final label = widget.isPaid ? 'Fee Paid' : 'Fee Due';

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onToggle();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: bgColor,
            shape: StadiumBorder(
              side: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
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

// --- ELEMENT 4: BoxyArt Search Bar (Refined) ---

class BoxyArtSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const BoxyArtSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: const StadiumBorder(),
        shadows: AppShadows.inputSoft,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}

// --- ELEMENT 4: Floating Filter Bar (Segmented) ---

class FloatingFilterBar<T> extends StatelessWidget {
  final T selectedValue;
  final List<FloatingFilterOption<T>> options;
  final ValueChanged<T> onChanged;

  const FloatingFilterBar({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Find index of selected value for animation alignment
    final selectedIndex = options.indexWhere((o) => o.value == selectedValue);
    final count = options.length;
    
    // Calculate alignment for AnimatedAlign (-1.0 to 1.0)
    // For 2 items: 0 -> -1.0, 1 -> 1.0
    // formula: (index / (count - 1)) * 2 - 1
    final alignmentX = count > 1 ? (selectedIndex / (count - 1)) * 2 - 1 : 0.0;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: 220,
        height: 50,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: const StadiumBorder(),
          shadows: AppShadows.softScale,
        ),
        child: Stack(
          children: [
            // Layer 1: Active Indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment(alignmentX.toDouble(), 0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: (220 / count) - 8,
                  height: 42,
                  decoration: const ShapeDecoration(
                    color: AppTheme.primaryYellow,
                    shape: StadiumBorder(),
                  ),
                ),
              ),
            ),
            
            // Layer 2: Text Buttons
            Row(
              children: options.map((option) {
                final isSelected = option.value == selectedValue;
                return Expanded(
                  child: InkWell(
                    onTap: () => onChanged(option.value),
                    borderRadius: BorderRadius.circular(25),
                    child: Center(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.black54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingFilterOption<T> {
  final String label;
  final T value;

  FloatingFilterOption({required this.label, required this.value});
}


// --- ELEMENT 5: Badges & Chips ---

class StatusChip extends StatelessWidget {
  final String label;
  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({super.key, required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryYellow,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}


// --- PREVIOUSLY CREATED WIDGETS ---

/// A card with a soft diffused shadow and high rounded corners.
class BoxyArtFloatingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double? height;

  const BoxyArtFloatingCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.width = double.infinity,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
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
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A chat bubble styled according to the BoxyArt theme.
class BoxyArtChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? time;

  const BoxyArtChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryYellow : AppTheme.surfaceGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                time!,
                style: TextStyle(
                  color: isMe ? Colors.black54 : Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- ELEMENT 5: Profile Info Row ---

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
