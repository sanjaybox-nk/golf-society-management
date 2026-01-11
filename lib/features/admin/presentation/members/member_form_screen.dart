import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:image_picker/image_picker.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../../models/member.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/constants/country_codes.dart';
import 'dart:io';

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
    if (!_formKey.currentState!.validate()) return;

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
        role: widget.member?.role ?? MemberRole.member,
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

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      resizeToAvoidBottomInset: true,
      appBar: BoxyArtAppBar(
        title: isNewMember ? 'New Member' : (_isEditMode ? 'Edit Member' : 'Member Details'),
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isEditMode
                ? TextButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                : IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.edit_outlined, size: 20, color: Colors.black),
                    ),
                    onPressed: () => setState(() => _isEditMode = true),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // Requested 100px bottom padding
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
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPersonalInfo() {
    if (!_isEditMode) {
      // View Mode
      return Column(
        children: [
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
          if (_bioController.text.isNotEmpty) ...[
             Divider(height: 1, indent: 36, color: Colors.grey.shade300),
             ProfileInfoRow(
               icon: Icons.info_outline,
               label: 'BIO',
               value: _bioController.text,
             ),
          ],
        ],
      );
    }

    // Edit Mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: BoxyArtFormField(
                label: 'First Name',
                controller: _firstController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BoxyArtFormField(
                label: 'Last Name',
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
          label: 'Email',
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
                label: 'Telephone',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        BoxyArtFormField(
          label: 'Address',
          controller: _addressController,
          prefixIcon: Icons.location_on,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        BoxyArtFormField(
          label: 'Short Bio',
          controller: _bioController,
          maxLines: 3,
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploading) return;

    final storage = ref.read(storageServiceProvider);
    
    // 1. Pick Image
    final File? file = await storage.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploading = true);

    try {
      // 2. Upload to Storage
      // If new member, we might need a temporary ID or wait until save?
      // For now, let's use a UUID or the existing ID if editing.
      final String memberId = widget.member?.id ?? 
          'temp_${DateTime.now().millisecondsSinceEpoch}';
      
      final String? url = await storage.uploadAvatar(
        memberId: memberId,
        file: file,
      );

      if (url != null) {
        setState(() => _avatarUrl = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'))
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }


  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

