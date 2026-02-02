import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // [NEW]
import '../../../../core/services/storage_service.dart'; // [NEW]
import '../../../../core/widgets/boxy_art_widgets.dart';

import '../../../../core/constants/country_codes.dart';
import '../../../../models/member.dart';
import 'members_provider.dart';
import 'profile_provider.dart'; // [NEW]
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';

class MemberDetailsModal extends ConsumerStatefulWidget {
  final Member? member; // Null = New Member

  const MemberDetailsModal({super.key, this.member});

  static void show(BuildContext context, Member? member) {
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
  late TextEditingController _handicapController;
  late TextEditingController _whsController;
  final _formKey = GlobalKey<FormState>();
  
  String? _avatarUrl;
  late MemberStatus _status;
  late bool _hasPaid;
  late MemberRole _role;
  String? _societyRole;
  DateTime? _joinedDate;
  bool _isSaving = false;
  late bool _isNewMember;

  bool _isAdmin() {
    final role = ref.watch(currentUserProvider).role;
    return role == MemberRole.admin || role == MemberRole.superAdmin;
  }

  bool _canEdit() {
    final currentUser = ref.watch(currentUserProvider);
    final isUserAdmin = currentUser.role == MemberRole.admin || currentUser.role == MemberRole.superAdmin;
    final isOwner = widget.member != null && currentUser.id == widget.member!.id;
    return isUserAdmin || isOwner || _isNewMember;
  }

  @override
  void initState() {
    super.initState();
    _isNewMember = widget.member == null;
    _isEditing = _isNewMember;
    _initControllers();
    
    // Sanitize URL
    String? url = widget.member?.avatarUrl;
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
    _firstController = TextEditingController(text: m?.firstName ?? '');
    _lastController = TextEditingController(text: m?.lastName ?? '');
    _nicknameController = TextEditingController(text: m?.nickname ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _addressController = TextEditingController(text: m?.address ?? '');
    _bioController = TextEditingController(text: m?.bio ?? '');
    _handicapController = TextEditingController(text: m?.handicap.toString() ?? '');
    _whsController = TextEditingController(text: m?.whsNumber ?? '');

    _status = m?.status ?? MemberStatus.member;
    _hasPaid = m?.hasPaid ?? false;
    _role = m?.role ?? MemberRole.member;
    _societyRole = m?.societyRole;
    _joinedDate = m?.joinedDate;

    String phone = m?.phone ?? '';
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

    // Listeners for real-time header card updates
    _firstController.addListener(() => setState(() {}));
    _lastController.addListener(() => setState(() {}));
    _nicknameController.addListener(() => setState(() {}));
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
    _handicapController.dispose();
    _whsController.dispose();
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

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(membersRepositoryProvider);
      
      final hcp = double.tryParse(_handicapController.text) ?? 54.0;
      final phone = '${_countryCodeController.text}${_phoneController.text.trim()}';

      final memberData = Member(
        id: widget.member?.id ?? '', 
        firstName: _firstController.text.trim(),
        lastName: _lastController.text.trim(),
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        handicap: hcp,
        whsNumber: _whsController.text.trim(),
        phone: phone,
        address: _addressController.text.trim(),
        bio: _bioController.text.trim(),
        status: _status,
        hasPaid: _hasPaid,
        avatarUrl: _avatarUrl,
        role: _role,
        societyRole: _societyRole,
        joinedDate: _joinedDate,
      );

      if (_isNewMember) {
        await repo.addMember(memberData);
      } else {
        await repo.updateMember(memberData);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSaving = false);
      }
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
          memberId: widget.member?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}', 
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
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F2F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Role',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...MemberRole.values.map((role) => _buildRoleOption(role)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(MemberRole role) {
    final isSelected = _role == role;
    return GestureDetector(
      onTap: () {
        setState(() => _role = role);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
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
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(role),
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    ),
                  ),
                  Text(
                    _getRoleDescription(role),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
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
    String title = 'Member Details';
    if (_isNewMember) {
      title = 'New Member';
    } else if (_isEditing) {
      title = 'Edit Member';
    }

    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditing) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        appBar: BoxyArtAppBar(
          title: title,
          isLarge: true,
          leadingWidth: 80,
          leading: TextButton(
            onPressed: () {
              if (_isEditing) {
                _showExitConfirmation();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              _isEditing ? 'Cancel' : 'Back',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            if (!_isEditing && _canEdit())
              IconButton(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edit Member',
              ),
            if (_isEditing)
               Padding(
                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: _buildBottomMenu(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(bottom: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Member Header Card
                    BoxyArtMemberHeaderCard(
                      firstName: _firstController.text,
                      lastName: _lastController.text,
                      nickname: _nicknameController.text,
                      status: _status,
                      hasPaid: _hasPaid,
                      avatarUrl: _avatarUrl,
                      handicapController: _handicapController,
                      whsController: _whsController,
                      isEditing: _isEditing,
                      isAdmin: _isAdmin(),
                      onCameraTap: _isEditing ? _pickImage : null,
                      onFeeToggle: (v) => setState(() => _hasPaid = v),
                      onStatusChanged: (v) => setState(() => _status = v),
                      role: _role,
                      onRoleTap: _canAssignRoles() ? _showRolePicker : null,
                      societyRole: _societyRole,
                      onSocietyRoleTap: _isAdmin() ? _showSocietyRolePicker : null,
                      joinedDate: _joinedDate,
                    ),

                    
                    const SizedBox(height: 16),

                    // Personal Details Card (Unified for Edit and View)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PERSONAL DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.black45,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          if (_isEditing) ...[
                            // EDIT MODE FORM
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
                                   width: 120,
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       const Padding(
                                         padding: EdgeInsets.only(left: 12, bottom: 4),
                                         child: Text(
                                           'Code',
                                           style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                                         ),
                                       ),
                                        Container(
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                            shadows: AppShadows.inputSoft,
                                          ),
                                          child: Autocomplete<Map<String, String>>(
                                            initialValue: TextEditingValue(text: _countryCodeController.text),
                                            optionsBuilder: (textEditingValue) {
                                              if (textEditingValue.text == '') return const Iterable<Map<String, String>>.empty();
                                              return countryList.where((option) {
                                                return option['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                                       option['code']!.contains(textEditingValue.text);
                                              });
                                            },
                                            displayStringForOption: (option) => option['code']!,
                                            onSelected: (selection) => setState(() => _countryCodeController.text = selection['code']!),
                                            optionsViewBuilder: (context, onSelected, options) {
                                              return Align(
                                                alignment: Alignment.topLeft,
                                                child: OverflowBox(
                                                  maxWidth: 195,
                                                  minWidth: 195,
                                                  alignment: Alignment.topLeft,
                                                  child: Material(
                                                    elevation: 8,
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: Container(
                                                      width: 195,
                                                      constraints: const BoxConstraints(maxHeight: 250),
                                                      child: ListView.builder(
                                                        padding: EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        itemCount: options.length,
                                                        itemBuilder: (context, index) {
                                                          final option = options.elementAt(index);
                                                          return InkWell(
                                                            onTap: () => onSelected(option),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    option['flag'] ?? '',
                                                                    style: const TextStyle(fontSize: 18),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Text(
                                                                    option['code']!,
                                                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Expanded(
                                                                    child: Text(
                                                                      option['name']!,
                                                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                               ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            fieldViewBuilder: (context, controller, focus, onSubmitted) {
                                              return TextFormField(
                                                controller: controller,
                                                focusNode: focus,
                                                cursorColor: Theme.of(context).primaryColor,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                                ),
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                              );
                                            },
                                          ),
                                        ),
                                     ],
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
                             const SizedBox(height: 16),
                             BoxyArtDatePickerField(
                               label: 'Member Since',
                               value: _joinedDate != null 
                                   ? '${_joinedDate!.day.toString().padLeft(2, '0')}/${_joinedDate!.month.toString().padLeft(2, '0')}/${_joinedDate!.year}' 
                                   : 'Tap to select date',
                               onTap: () async {
                                 final date = await showDatePicker(
                                   context: context,
                                   initialDate: _joinedDate ?? DateTime.now(),
                                   firstDate: DateTime(2000),
                                   lastDate: DateTime.now(),
                                 );
                                 if (date != null) setState(() => _joinedDate = date);
                               },
                             ),
                          ] else ...[
                            // VIEW MODE DETAILS (Now inside the card)
                            if (widget.member?.bio != null && widget.member!.bio!.isNotEmpty) ...[
                               Container(
                                 width: double.infinity,
                                 margin: const EdgeInsets.only(bottom: 24),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'BIO',
                                       style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400),
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       widget.member!.bio!,
                                       style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                                     ),
                                   ],
                                 ),
                               ),
                            ],
                            
                            ProfileInfoRow(
                              icon: Icons.email_outlined,
                              label: 'EMAIL',
                              value: widget.member?.email ?? '',
                            ),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                            
                            ProfileInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'PHONE',
                              value: widget.member?.phone ?? '',
                            ),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                            
                            ProfileInfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'ADDRESS',
                              value: widget.member?.address ?? '',
                            ),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                            
                            ProfileInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'MEMBER SINCE',
                              value: widget.member?.joinedDate != null 
                                ? '${widget.member!.joinedDate!.day.toString().padLeft(2, '0')}/${widget.member!.joinedDate!.month.toString().padLeft(2, '0')}/${widget.member!.joinedDate!.year}' 
                                : '-'
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep Editing', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () {
             Navigator.of(context).pop();
             if (_isNewMember) {
               Navigator.of(context).pop();
             } else {
               setState(() {
                 _isEditing = false;
                 _initControllers(); // Reset to original values
               });
             }
          },
          child: const Text('Discard', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showSocietyRolePicker() {
    final defaultRoles = ['President', 'Captain', 'Vice Captain', 'Secretary', 'Treasurer'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF0F2F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Society Position', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...defaultRoles.map((r) => _buildSocietyRoleOption(r)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showCustomRoleDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Row(children: [Icon(Icons.add), SizedBox(width: 12), Text('Create Custom Role', style: TextStyle(fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocietyRoleOption(String role) {
    final isSelected = _societyRole == role;
    return GestureDetector(
      onTap: () {
        setState(() => _societyRole = role);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
        ),
        child: Row(
          children: [
            Expanded(child: Text(role, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Theme.of(context).primaryColor : Colors.black))),
            if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  void _showCustomRoleDialog() {
    final controller = TextEditingController();
    showBoxyArtDialog(
      context: context,
      title: 'New Role',
      content: BoxyArtFormField(
        label: 'Role Title',
        hintText: 'e.g. Tour Manager',
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              setState(() => _societyRole = controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: Text('Save', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }



  Widget _buildBottomMenu() {
    final isAdmin = _isAdmin();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 0.0, left: 8.0, right: 8.0),
          child: BottomNavigationBar(
            currentIndex: 2, // Highlight "Members" tab
            onTap: (index) {
              Navigator.of(context).pop();
            },
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade600,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: isAdmin 
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month),
                    label: 'Events',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline),
                    activeIcon: Icon(Icons.people),
                    label: 'Members',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notification_add_outlined),
                    activeIcon: Icon(Icons.notification_add),
                    label: 'Comms',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month),
                    label: 'Events',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline),
                    activeIcon: Icon(Icons.people),
                    label: 'Members',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Locker',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    activeIcon: Icon(Icons.history),
                    label: 'Archive',
                  ),
                ],
          ),
        ),
      ),
    );
  }
}
