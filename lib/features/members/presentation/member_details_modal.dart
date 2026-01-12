import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // [NEW]
import '../../../../core/services/storage_service.dart'; // [NEW]
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/shared_ui/cards.dart';
import '../../../../core/shared_ui/inputs.dart';
import '../../../../core/shared_ui/floating_action_bar.dart';
import '../../../../core/constants/country_codes.dart';
import '../../../../models/member.dart';
import 'members_provider.dart';
import 'profile_provider.dart'; // [NEW]

class MemberDetailsModal extends ConsumerStatefulWidget {
  final Member member;

  const MemberDetailsModal({super.key, required this.member});

  static void show(BuildContext context, Member member) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: MemberDetailsModal(member: member),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<MemberDetailsModal> createState() => _MemberDetailsModalState();
}

class _MemberDetailsModalState extends ConsumerState<MemberDetailsModal> {
  bool _isEditing = false;
  late TextEditingController _firstController;
  late TextEditingController _lastController;
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryCodeController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  String? _avatarUrl; // [NEW]

  @override
  void initState() {
    super.initState();
    _initControllers();
    
    // [FIX] Sanitize URL to remove corrupted timestamp params from previous bug
    String? url = widget.member.avatarUrl;
    if (url != null) {
      if (url.contains('?t=')) {
        url = url.split('?t=')[0];
      } else if (url.contains('&t=')) {
        url = url.split('&t=')[0];
      }
    }
    _avatarUrl = url;
  }

  void _initControllers() {
    final m = widget.member;
    _firstController = TextEditingController(text: m.firstName);
    _lastController = TextEditingController(text: m.lastName);
    _nicknameController = TextEditingController(text: m.nickname ?? '');
    _emailController = TextEditingController(text: m.email);
    _addressController = TextEditingController(text: m.address ?? '');
    _bioController = TextEditingController(text: m.bio ?? '');

    String phone = m.phone ?? '';
    String code = '+44';
     if (phone.startsWith('+')) {
      for (final country in countryList) {
        if (phone.startsWith(country['code']!)) {
          code = country['code']!;
          phone = phone.substring(code.length);
          break;
        }
      }
    }
    _countryCodeController = TextEditingController(text: code);
    _phoneController = TextEditingController(text: phone);
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

      try {
        final repo = ref.read(membersRepositoryProvider);
        final m = widget.member;
        
        // Reconstruct phone
        final phone = '${_countryCodeController.text}${_phoneController.text.trim()}';

        final updatedMember = m.copyWith(
            firstName: _firstController.text.trim(),
            lastName: _lastController.text.trim(),
            nickname: _nicknameController.text.trim(),
            email: _emailController.text.trim(),
            phone: phone,
            address: _addressController.text.trim(),
            bio: _bioController.text.trim(),
            avatarUrl: _avatarUrl,
        );

        await repo.updateMember(updatedMember);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
  }

  Future<void> _pickImage() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final file = await storage.pickImage(source: ImageSource.gallery);
      
      if (file != null) {
        
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading image...'), duration: Duration(seconds: 1)),
          );
        }


        final url = await storage.uploadAvatar(
          memberId: widget.member.id, 
          file: file
        );

        if (mounted) {
          setState(() {
            _avatarUrl = url;
          });
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  // Role Assignment Logic
  bool _canAssignRoles() {
    final currentUser = ref.watch(currentUserProvider);
    return currentUser.role == MemberRole.superAdmin;
  }

  void _showRolePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F2F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Role',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...MemberRole.values.map((role) => _buildRoleOption(role)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(MemberRole role) {
    final isSelected = widget.member.role == role;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) _confirmRoleChange(role);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.purple, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple.shade50 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(role),
                color: isSelected ? Colors.purple : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRoleDisplayName(role),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.purple.shade900 : Colors.black,
                    ),
                  ),
                  Text(
                    _getRoleDescription(role),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  void _confirmRoleChange(MemberRole newRole) {
    showBoxyArtDialog(
      context: context,
      title: 'Change Role?',
      message: 'Are you sure you want to make ${widget.member.firstName} a ${_getRoleDisplayName(newRole)}?',
      confirmText: 'Confirm',
      onConfirm: () async {
        Navigator.pop(context); // Close dialog
        await _updateRole(newRole);
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  Future<void> _updateRole(MemberRole newRole) async {
    try {
      final repo = ref.read(membersRepositoryProvider);
      final updatedMember = widget.member.copyWith(role: newRole);
      await repo.updateMember(updatedMember);
      if (mounted) {
         setState(() {
           Navigator.pop(context); // Close details to refresh?
         });
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role updated successfully')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Admin';
      case MemberRole.restrictedAdmin: return 'Restricted Admin';
      case MemberRole.viewer: return 'Viewer';
      case MemberRole.member: return 'Standard Member';
    }
  }

  String _getRoleDescription(MemberRole role) {
     switch (role) {
      case MemberRole.superAdmin: return 'Full access to all system features.';
      case MemberRole.admin: return 'Manage members, events, and results.';
      case MemberRole.restrictedAdmin: return 'Limited management rights.';
      case MemberRole.viewer: return 'Read-only access to all data.';
      case MemberRole.member: return 'Standard app access.';
    }
  }

  IconData _getRoleIcon(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return Icons.admin_panel_settings;
      case MemberRole.admin: return Icons.security;
      case MemberRole.restrictedAdmin: return Icons.build_circle_outlined;
      case MemberRole.viewer: return Icons.visibility_outlined;
      case MemberRole.member: return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditing) {
          _showExitConfirmation();
        }
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header with close button
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Member Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Edit Action
                      if (!_isEditing)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => setState(() => _isEditing = true),
                        ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24).copyWith(bottom: 120), // Increased bottom padding
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Member Header Card
                        BoxyArtMemberHeaderCard(
                          firstName: _isEditing ? _firstController.text : widget.member.firstName,
                          lastName: _isEditing ? _lastController.text : widget.member.lastName,
                          nickname: _isEditing ? _nicknameController.text : widget.member.nickname,
                          status: widget.member.status,
                          hasPaid: widget.member.hasPaid,
                          avatarUrl: _avatarUrl,
                          handicapController: TextEditingController(text: widget.member.handicap.toStringAsFixed(1)),
                          whsController: TextEditingController(text: widget.member.whsNumber ?? ''),
                          isEditing: _isEditing,
                          isAdmin: false,
                          onCameraTap: _isEditing ? _pickImage : null,
                          role: widget.member.role,
                          onRoleTap: _canAssignRoles() ? _showRolePicker : null,
                          societyRole: widget.member.societyRole,
                          joinedDate: widget.member.joinedDate,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Personal Details
                        if (_isEditing) ...[
                          BoxyArtFormField(
                            label: 'Bio',
                            controller: _bioController,
                            readOnly: false,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: BoxyArtFormField(
                                  label: 'First Name *',
                                  controller: _firstController,
                                  readOnly: false,
                                  validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: BoxyArtFormField(
                                  label: 'Last Name *',
                                  controller: _lastController,
                                  readOnly: false,
                                  validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          BoxyArtFormField(
                            label: 'Nickname',
                            controller: _nicknameController,
                            readOnly: false,
                          ),
                          const SizedBox(height: 16),
                          BoxyArtFormField(
                            label: 'Email *',
                            controller: _emailController,
                            readOnly: false,
                            validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: BoxyArtFormField(
                                  label: 'Code',
                                  controller: _countryCodeController,
                                  readOnly: false, 
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BoxyArtFormField(
                                  label: 'Phone *',
                                  controller: _phoneController,
                                  readOnly: false,
                                  validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          BoxyArtFormField(
                            label: 'Address *',
                            controller: _addressController,
                            readOnly: false,
                            maxLines: 2,
                            validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                          ),

                        ] else ...[
                          // View Mode
                          if (widget.member.bio != null && widget.member.bio!.isNotEmpty) ...[
                             ProfileInfoRow(
                               icon: Icons.info_outline,
                               label: 'BIO',
                               value: widget.member.bio!,
                             ),
                             Divider(height: 1, indent: 36, color: Colors.grey.shade300),
                          ],
                          if (widget.member.nickname != null && widget.member.nickname!.isNotEmpty) ...[
                             ProfileInfoRow(
                               icon: Icons.person_outline,
                               label: 'NICKNAME',
                               value: widget.member.nickname!,
                             ),
                             Divider(height: 1, indent: 36, color: Colors.grey.shade300),
                          ],
                          ProfileInfoRow(
                            icon: Icons.email_outlined,
                            label: 'EMAIL',
                            value: widget.member.email.isEmpty ? 'Not provided' : widget.member.email,
                          ),
                          Divider(height: 1, indent: 36, color: Colors.grey.shade300),
                          ProfileInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'PHONE',
                            value: widget.member.phone?.isEmpty ?? true ? 'Not provided' : widget.member.phone!,
                          ),
                          Divider(height: 1, indent: 36, color: Colors.grey.shade300),
                          ProfileInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'ADDRESS',
                            value: widget.member.address?.isEmpty ?? true ? 'Not provided' : widget.member.address!,
                          ),
                          Divider(height: 1, indent: 36, color: Colors.grey.shade300),
                          ProfileInfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'MEMBER SINCE',
                            value: widget.member.joinedDate != null 
                              ? '${widget.member.joinedDate!.day.toString().padLeft(2, '0')}/${widget.member.joinedDate!.month.toString().padLeft(2, '0')}/${widget.member.joinedDate!.year}' 
                              : 'Unknown',
                          ),
                        ],
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating Action Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Visibility(
                visible: _isEditing,
                child: _buildBottomBar(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showExitConfirmation() {
    showBoxyArtDialog(
      context: context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to leave?',
      actions: [
        BoxyArtButton(
          title: 'Keep Editing',
          onTap: () => Navigator.of(context).pop(),
          isPrimary: true,
        ),
        BoxyArtButton(
          title: 'Discard',
          onTap: () {
            Navigator.of(context).pop(); // Close dialog
            setState(() {
              _isEditing = false;
              _initControllers(); // Reset changes
            });
            Navigator.of(context).pop(); // Close modal
          },
          isGhost: true,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BoxyArtFloatingActionBar(
      onCancel: _showExitConfirmation,
      onSave: _save,
    );
  }
}
