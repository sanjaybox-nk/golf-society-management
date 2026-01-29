import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:image_picker/image_picker.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../../models/member.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/country_codes.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  final Member? member; // Null = New Member

  const MemberFormScreen({super.key, this.member});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstController;
  late TextEditingController _lastController;
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _handicapController;
  late TextEditingController _whsController;
  late TextEditingController _phoneController;
  late TextEditingController _countryCodeController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  
  late MemberStatus _status;
  late bool _hasPaid;
  String? _avatarUrl;
  bool _isSaving = false;
  bool _isUploading = false;
  late bool _isEditMode;
  late MemberRole _role; // [NEW]
  String? _societyRole; // [NEW]
  DateTime? _joinedDate; // [NEW]

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _isEditMode = m == null;
    _firstController = TextEditingController(text: m?.firstName ?? '');
    _lastController = TextEditingController(text: m?.lastName ?? '');
    _nicknameController = TextEditingController(text: m?.nickname ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _handicapController = TextEditingController(text: m?.handicap.toString() ?? '');
    _whsController = TextEditingController(text: m?.whsNumber ?? '');
    
    String phone = m?.phone ?? '';
    String code = '+44';
    if (phone.startsWith('+')) {
      // Try to find matching country code
      // Sort by length desc to match longest code first (optimization omitted for brevity as defaults are fine)
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

    _addressController = TextEditingController(text: m?.address ?? '');
    _bioController = TextEditingController(text: m?.bio ?? '');
    _status = m?.status ?? MemberStatus.member;
    _hasPaid = m?.hasPaid ?? false;
    _role = m?.role ?? MemberRole.member; // [NEW]
    _societyRole = m?.societyRole; // [NEW]
    _joinedDate = m?.joinedDate; // [NEW]
    _avatarUrl = m?.avatarUrl;

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
    _handicapController.dispose();
    _whsController.dispose();
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

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(membersRepositoryProvider);
      
      final hcp = double.tryParse(_handicapController.text) ?? 54.0;

      final newMember = Member(
        id: widget.member?.id ?? '', // ID handled by repo for create
        firstName: _firstController.text.trim(),
        lastName: _lastController.text.trim(),
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        handicap: hcp,
        whsNumber: _whsController.text.trim(),
        phone: '${_countryCodeController.text}${_phoneController.text.trim()}',
        address: _addressController.text.trim(),
        bio: _bioController.text.trim(),
        status: _status,
        hasPaid: _hasPaid,
        avatarUrl: _avatarUrl,
        role: _role, // [UPDATED]
        societyRole: _societyRole, // [NEW]
        joinedDate: _joinedDate, // [NEW]
      );

      if (widget.member == null) {
        await repo.addMember(newMember);
      } else {
        await repo.updateMember(newMember);
      }

      if (mounted) {
        context.pop(); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final file = await storage.pickImage(source: ImageSource.gallery);
      
      if (file != null) {
        setState(() => _isUploading = true);
        
        // Handle new member case where ID is not yet assigned
        String memberId = widget.member?.id ?? 'new_${DateTime.now().millisecondsSinceEpoch}';

        final url = await storage.uploadAvatar(
          memberId: memberId, 
          file: file
        );

        if (mounted) {
          setState(() {
            _avatarUrl = url;
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
         setState(() => _isUploading = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewMember = widget.member == null;

    return PopScope(
      canPop: !_isEditMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditMode) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: BoxyArtAppBar(
        title: isNewMember ? 'New Member' : (_isEditMode ? 'Edit Member' : 'Member Details'),
        showBack: true,
        actions: [
          if (!_isEditMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => setState(() => _isEditMode = true),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 140), // Increased bottom padding for floating bar
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BoxyArtMemberHeaderCard(
                      firstName: _firstController.text,
                      lastName: _lastController.text,
                      nickname: _nicknameController.text,
                      status: _status,
                      hasPaid: _hasPaid,
                      avatarUrl: _avatarUrl,
                      handicapController: _handicapController,
                      whsController: _whsController,
                      isEditing: _isEditMode,
                      onCameraTap: _isEditMode ? _pickAndUploadImage : null,
                      onFeeToggle: (v) => setState(() => _hasPaid = v),
                      onStatusChanged: (v) => setState(() => _status = v),
                      role: _role,
                      societyRole: _societyRole,
                      onSocietyRoleTap: _showSocietyRolePicker,
                      joinedDate: _joinedDate,
                    ),
                    if (_isUploading)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildPersonalInfo(),
                  ],
                ),
              ),
            ),
            
            // Floating Action Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Visibility(
                visible: _isEditMode,
                child: _buildBottomBar(),
              ),
            ),
          ],
        ),
      ),
      ),
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
            const SizedBox(height: 24),
          ],
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
          border: isSelected ? Border.all(color: const Color(0xFF1A237E), width: 2) : null,
        ),
        child: Row(
          children: [
            Expanded(child: Text(role, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1A237E) : Colors.black))),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF1A237E)),
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
        hintText: 'e.g. Tour Manager', // Added hint text
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


  Widget _buildPersonalInfo() {
    if (!_isEditMode) {
      // View Mode
      return Column(
        children: [
          if (_bioController.text.isNotEmpty) ...[
             ProfileInfoRow(
               icon: Icons.info_outline,
               label: 'BIO',
               value: _bioController.text,
             ),
             Divider(height: 1, indent: 36, color: Colors.grey.shade300),
          ],
          if (_nicknameController.text.isNotEmpty) ...[
             ProfileInfoRow(
               icon: Icons.person_outline,
               label: 'NICKNAME',
               value: _nicknameController.text,
             ),
             Divider(height: 1, indent: 36, color: Colors.grey.shade300),
          ],
          ProfileInfoRow(
            icon: Icons.email_outlined,
            label: 'EMAIL',
            value: _emailController.text.isEmpty ? 'Not provided' : _emailController.text,
          ),
          Divider(height: 1, indent: 36, color: Colors.grey.shade300),
          ProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'PHONE',
            value: (_phoneController.text.isEmpty) 
                ? 'Not provided' 
                : '${_countryCodeController.text} ${_phoneController.text}',
          ),
          Divider(height: 1, indent: 36, color: Colors.grey.shade300),
          ProfileInfoRow(
            icon: Icons.location_on_outlined,
            label: 'ADDRESS',
            value: _addressController.text.isEmpty ? 'Not provided' : _addressController.text,
          ),
        ],
      );
    }

    // Edit Mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtFormField(
          label: 'Short Bio',
          controller: _bioController,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: BoxyArtFormField(
                label: 'First Name *',
                controller: _firstController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BoxyArtFormField(
                label: 'Last Name *',
                controller: _lastController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        BoxyArtFormField(
          label: 'Nickname',
          controller: _nicknameController,
        ),
        const SizedBox(height: 24),
        BoxyArtFormField(
          label: 'Email *',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      shadows: AppShadows.inputSoft,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Adjusted padding
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<Map<String, String>>(
                          initialValue: TextEditingValue(text: _countryCodeController.text),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<Map<String, String>>.empty();
                            }
                            return countryList.where((Map<String, String> option) {
                              return option['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                     option['code']!.contains(textEditingValue.text);
                            });
                          },
                          displayStringForOption: (Map<String, String> option) => option['code']!,
                          onSelected: (Map<String, String> selection) {
                            setState(() {
                              _countryCodeController.text = selection['code']!;
                            });
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                            // Sync the local controller with the main state controller if needed, but here we just want to display
                            // strictly speaking we should listener to changes. 
                            // For simplicity, we initialize. User types here.
                            return TextFormField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                isDense: true, 
                                hintText: '+44',
                              ),
                              style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                              keyboardType: TextInputType.visiblePassword, // Hack to show normal keyboard but mostly for numbers/text
                            );
                          },
                          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Map<String, String>> onSelected, Iterable<Map<String, String>> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 250, // Wider dropdown to show full name
                                  constraints: const BoxConstraints(maxHeight: 300),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final Map<String, String> option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Text(option['flag']!, style: const TextStyle(fontSize: 18)),
                                              const SizedBox(width: 8),
                                              Text(option['code']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(option['name']!, overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    ),
                  ),                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BoxyArtFormField(
                label: 'Telephone *',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        BoxyArtFormField(
          label: 'Address *',
          controller: _addressController,
          prefixIcon: Icons.location_on,
          maxLines: 2,
          validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
        ),
        const SizedBox(height: 24),
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
              builder: (context, child) {
                  return Theme(
                    data: AppTheme.generateTheme(
                      seedColor: Theme.of(context).primaryColor, 
                      brightness: Brightness.light,
                    ).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Theme.of(context).colorScheme.onPrimary,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
            );
            if (date != null) {
              setState(() => _joinedDate = date);
            }
          },
        ),
      ],
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
            Navigator.of(context).pop(); // Close dialog
            setState(() => _isEditMode = false);
            context.pop(); // Close screen
          },
          child: const Text('Discard', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BoxyArtFloatingActionBar(
      onCancel: _showExitConfirmation,
      onSave: _save,
      saveLabel: 'Save',
      isLoading: _isSaving,
    );
  }
}

