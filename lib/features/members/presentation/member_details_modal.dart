```
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // [NEW]
import '../../../../core/services/storage_service.dart'; // [NEW]
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/constants/country_codes.dart';
import '../../../../models/member.dart';
import 'members_provider.dart';

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
  String? _avatarUrl; // [NEW]
  bool _isUploading = false; // [NEW]

  @override
  void initState() {
    super.initState();
    _initControllers();
    _avatarUrl = widget.member.avatarUrl; // [NEW]
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
        setState(() => _isUploading = true);
        
        final url = await storage.uploadAvatar(
          memberId: widget.member.id, 
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
    return Container(
      color: const Color(0xFFF0F2F5),
      child: SafeArea(
        child: Column(
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
                  if (_isEditing)
                    TextButton(
                      onPressed: _save,
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.black, // Boxy Art yellow/black theme usually uses black for actions or primary color
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => setState(() => _isEditing = true),
                    ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Header Card
                    BoxyArtMemberHeaderCard(
                      firstName: _isEditing ? _firstController.text : widget.member.firstName, // Use Controller text for potential live update if we added listeners
                      lastName: _isEditing ? _lastController.text : widget.member.lastName,
                      nickname: _isEditing ? _nicknameController.text : widget.member.nickname,
                      status: widget.member.status,
                      hasPaid: widget.member.hasPaid,
                      avatarUrl: _avatarUrl, // [UPDATED]
                      handicapController: TextEditingController(text: widget.member.handicap.toStringAsFixed(1)),
                      whsController: TextEditingController(text: widget.member.whsNumber ?? ''),
                      isEditing: _isEditing,
                      isAdmin: false,
                      onCameraTap: _isEditing ? _pickImage : null, // [NEW]
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Personal Details
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'First Name',
                              controller: _firstController,
                              readOnly: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BoxyArtFormField(
                              label: 'Last Name',
                              controller: _lastController,
                              readOnly: false,
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
                        label: 'Email',
                        controller: _emailController,
                        readOnly: false,
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
                              label: 'Phone',
                              controller: _phoneController,
                              readOnly: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        label: 'Address',
                        controller: _addressController,
                        readOnly: false,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      BoxyArtFormField(
                        label: 'Bio',
                        controller: _bioController,
                        readOnly: false,
                        maxLines: 4,
                      ),
                    ] else ...[
                      // View Mode
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
                      if (widget.member.bio != null && widget.member.bio!.isNotEmpty) ...[
                         Divider(height: 1, indent: 36, color: Colors.grey.shade300),
                         ProfileInfoRow(
                           icon: Icons.info_outline,
                           label: 'BIO',
                           value: widget.member.bio!,
                         ),
                      ],
                    ],
                    
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
}
