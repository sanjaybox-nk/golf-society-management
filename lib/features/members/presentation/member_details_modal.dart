import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'widgets/member_stats_row.dart';

import '../../../../core/constants/country_codes.dart';
import '../../../../models/member.dart';
import 'members_provider.dart';
import 'profile_provider.dart';
import 'widgets/member_role_picker.dart';
import 'widgets/society_role_picker.dart';
import 'widgets/personal_details_form.dart';

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
  late TextEditingController _handicapIdController;
  
  late FocusNode _firstFocusNode;
  late FocusNode _lastFocusNode;
  late FocusNode _nicknameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _phoneFocusNode;
  late FocusNode _handicapIdFocusNode;
  late FocusNode _handicapFocusNode;
  late FocusNode _addressFocusNode;
  late FocusNode _bioFocusNode;

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
    _handicapIdController = TextEditingController(text: m?.handicapId ?? '');

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

    _firstFocusNode = FocusNode();
    _lastFocusNode = FocusNode();
    _nicknameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _handicapIdFocusNode = FocusNode();
    _handicapFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _bioFocusNode = FocusNode();
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
    _handicapIdController.dispose();
    _firstFocusNode.dispose();
    _lastFocusNode.dispose();
    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _handicapIdFocusNode.dispose();
    _handicapFocusNode.dispose();
    _addressFocusNode.dispose();
    _bioFocusNode.dispose();
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
        handicapId: _handicapIdController.text.trim(),
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
    MemberRolePicker.show(
      context, 
      _role, 
      (newRole) => setState(() => _role = newRole),
    );
  }


  @override
  Widget build(BuildContext context) {
    String title = _isNewMember ? 'New Member' : (_isEditing ? 'Edit Member' : '${_firstController.text} ${_lastController.text}');

    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditing) {
          _showExitConfirmation();
        }
      },
      child: HeadlessScaffold(
        title: title,
        showBack: !_isEditing,
        showAdminShortcut: false, // Modal context, no shortcut needed
        
        // Leading Action (Back / Cancel)
        leading: _isEditing 
          ? Center(
              child: BoxyArtGlassIconButton(
                icon: Icons.close_rounded,
                onPressed: _showExitConfirmation,
                tooltip: 'Cancel',
              ),
            )
          : null, // Default back button logic handles view mode

        // Trailing Actions (Edit / Save)
        actions: [
          if (!_isEditing && _canEdit())
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: BoxyArtGlassIconButton(
                onPressed: () => setState(() => _isEditing = true),
                icon: Icons.edit_outlined,
                tooltip: 'Edit Member',
              ),
            ),
          if (_isEditing)
             Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
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
        ],
        bottomNavigationBar: _buildBottomMenu(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24).copyWith(bottom: 40),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _firstController,
                        _lastController,
                        _nicknameController,
                      ]),
                      builder: (context, _) => BoxyArtMemberHeaderCard(
                        firstName: _firstController.text,
                        lastName: _lastController.text,
                        nickname: _nicknameController.text,
                        status: _status,
                        hasPaid: _hasPaid,
                        avatarUrl: _avatarUrl,
                        handicapController: _handicapController,
                        handicapIdController: _handicapIdController,
                        handicapFocusNode: _handicapFocusNode,
                        handicapIdFocusNode: _handicapIdFocusNode,
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
                    ),

                    
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    if (!_isNewMember && widget.member != null)
                      Consumer(
                        builder: (context, ref, _) {
                           final statsAsync = ref.watch(memberPerformanceProvider(widget.member!.id));
                           return statsAsync.when(
                             data: (stats) => MemberStatsRow(
                               starts: stats.starts,
                               wins: stats.wins,
                               top5: stats.top5,
                               avgPts: stats.avgPts,
                               bestPts: stats.bestPts,
                               rank: stats.rank,
                             ),
                             loading: () => const SizedBox.shrink(), // Or skeleton
                             error: (e, s) => const SizedBox.shrink(),
                           );
                        },
                      ),

                    const SizedBox(height: 24),

                    PersonalDetailsForm(
                      isEditing: _isEditing,
                      firstController: _firstController,
                      lastController: _lastController,
                      nicknameController: _nicknameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      countryCodeController: _countryCodeController,
                      addressController: _addressController,
                      bioController: _bioController,
                      joinedDate: _joinedDate,
                      onPickDate: () async {
                         final date = await showDatePicker(
                           context: context,
                           initialDate: _joinedDate ?? DateTime.now(),
                           firstDate: DateTime(2000),
                           lastDate: DateTime.now(),
                         );
                         if (date != null) setState(() => _joinedDate = date);
                      },
                      bioFocusNode: _bioFocusNode,
                      firstFocusNode: _firstFocusNode,
                      lastFocusNode: _lastFocusNode,
                      nicknameFocusNode: _nicknameFocusNode,
                      emailFocusNode: _emailFocusNode,
                      phoneFocusNode: _phoneFocusNode,
                      addressFocusNode: _addressFocusNode,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    SocietyRolePicker.show(
      context, 
      _societyRole, 
      (newRole) => setState(() => _societyRole = newRole),
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
