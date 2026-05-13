import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:golf_society/services/storage_service.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'widgets/member_stats_row.dart';

import 'package:golf_society/constants/country_codes.dart';
import 'package:golf_society/domain/models/member.dart';
import 'members_provider.dart';
import 'profile_provider.dart';
import 'widgets/member_role_picker.dart';
import 'widgets/member_status_picker.dart';
import 'widgets/society_role_picker.dart';
import 'widgets/personal_details_form.dart';
import 'widgets/handicap_trend_chart.dart';
import 'package:golf_society/domain/models/handicap_system.dart';

class MemberDetailsModal extends ConsumerStatefulWidget {
  final Member? member; // Null = New Member
  final bool isNewMember;
  final bool isAdminContext;
  final bool isModal;

  const MemberDetailsModal({
    super.key, 
    this.member, 
    this.isNewMember = false, 
    this.isAdminContext = false,
    this.isModal = true,
  });

  static void show(BuildContext context, Member? member, {bool isAdmin = false, bool isNewMember = false, bool isAdminContext = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use branch navigator so the global bottom nav bar stays visible behind the sheet.
      useRootNavigator: false,
      useSafeArea: false, // Background should cover notch
      backgroundColor: Colors.transparent, // Design 4.x Standard
      elevation: 0,
      builder: (context) => MemberDetailsModal(
        member: member,
        isAdminContext: isAdminContext,
        isNewMember: isNewMember,
      ),
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
  DateTime? _membershipEndDate; // [NEW]
  bool _isSaving = false;
  late bool _allowSocialEventsOnly; // [NEW]
  late bool _isFoundingMember; // [NEW]

  // Removed ref.watch wrapper methods to prevent StateError during async build phases.
  String? _gender; // [NEW]

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isNewMember;
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
    _membershipEndDate = m?.membershipEndDate; // [NEW]
    _allowSocialEventsOnly = m?.allowSocialEventsOnly ?? false; // [NEW]
    _isFoundingMember = m?.isFoundingMember ?? false; // [NEW]
    _gender = m?.gender; // [NEW]

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
          backgroundColor: AppColors.coral500, // Standardized alert color
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(membersRepositoryProvider);
      
      final hcp = double.tryParse(_handicapController.text) ?? 54.0;
      final phone = '${_countryCodeController.text}${_phoneController.text.trim()}';

      // Use copyWith to preserve all existing fields (renewalStatus, handicapHistory,
      // accountCredit, nudgeCount, etc.) — only update what the form edited.
      final existing = widget.member ?? const Member(
        id: '',
        firstName: '',
        lastName: '',
        email: '',
      );
      final memberData = existing.copyWith(
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
        membershipEndDate: _membershipEndDate,
        gender: _gender,
        allowSocialEventsOnly: _allowSocialEventsOnly,
        isFoundingMember: _isFoundingMember,
      );

      if (widget.isNewMember) {
        await repo.addMember(memberData);
      } else {
        await repo.updateMember(memberData);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.coral500,
          ),
        );
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

  void _showRolePicker() {
    MemberRolePicker.show(
      context, 
      _role, 
      (newRole) => setState(() => _role = newRole),
    );
  }

  void _showStatusPicker() {
    MemberStatusPicker.show(
      context, 
      _status, 
      (newStatus) => setState(() => _status = newStatus),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Cache variables here to satisfy Riverpod's strict ref.watch lifecycle rules
    final currentUser = ref.watch(effectiveUserProvider);
    final isAdmin = currentUser.role == MemberRole.admin || currentUser.role == MemberRole.superAdmin;
    final canAssignRoles = currentUser.role == MemberRole.superAdmin;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    
    String title = widget.isNewMember ? 'New Member' : (_isEditing ? 'Edit Member' : 'Member Detail');

    final baseContent = HeadlessScaffold(
      isModal: widget.isModal,
      title: title,
      showBack: !_isEditing,
      showAdminShortcut: false, 
      // Removed redundant bottomNavigationBar to resolve "double bottom nav" issue
      // Modals should rely on the background shell or explicit close actions.
      leading: _isEditing 
        ? Center(
            child: BoxyArtGlassIconButton(
              icon: Icons.close_rounded,
              iconSize: 24,
              onPressed: _showExitConfirmation,
            ),
          )
        : null, // Default back button logic handles view mode
      pinnedBottom: null,

      // Trailing Actions (Edit)
      actions: [
        // Edit Button (Right) - Admin Context or Self-service
        if (!_isEditing && (widget.isAdminContext || (widget.member?.id == currentUser.id)))
          BoxyArtGlassIconButton(
            icon: Icons.edit_outlined,
            onPressed: () => setState(() => _isEditing = true),
          )
        else
          const SizedBox(width: AppSpacing.x3l),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
            child: BoxyArtFormColumn(
                spacing: 0,
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
                      isEditing: _isEditing,
                      isAdmin: isAdmin,
                      onCameraTap: _isEditing ? _pickImage : null,
                      onFeeToggle: (v) => setState(() {
                        _hasPaid = v;
                        // Renewal Trigger: Auto-promote Expired/Grace members to Member status when fees are paid
                        if (_hasPaid && (_status == MemberStatus.expired || _status == MemberStatus.gracePeriod)) {
                          _status = MemberStatus.member;
                        }
                      }),
                      onStatusChanged: isAdmin ? (_) => _showStatusPicker() : null,
                      role: _role,
                      onRoleTap: canAssignRoles ? _showRolePicker : null,
                      societyRole: _societyRole,
                      onSocietyRoleTap: isAdmin ? _showSocietyRolePicker : null,
                      joinedDate: _joinedDate,
                      showFeeIndicator: false, // Moved to Renewal Hub list
                      isAdminContext: widget.isAdminContext,
                      isFoundingMember: _isFoundingMember,
                    ),
                  ),

                  if (!widget.isNewMember) ...[
                    SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
                    // 2. Performance Section
                    const BoxyArtSectionTitle(
                      title: 'Member Performance',
                      isPeeking: true,
                      horizontalPadding: 0,
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final memberId = widget.member?.id;
                        if (memberId == null) return const SizedBox.shrink();
                        
                        return ref.watch(memberPerformanceProvider(memberId)).when(
                          loading: () => const BoxyArtLoadingCard(
                            useCard: false,
                            isCompact: true,
                            title: 'Fetching performance...',
                          ),
                          error: (err, stack) => BoxyArtEmptyState(
                            title: 'Status Error',
                            message: err.toString(),
                            icon: Icons.error_outline_rounded,
                            isCompact: true,
                          ),
                          data: (stats) => MemberStatsRow(
                            starts: stats.starts,
                            wins: stats.wins,
                            top5: stats.top5,
                            avgPts: stats.avgPts,
                            bestPts: stats.bestPts,
                            rank: stats.rank,
                          ),
                        );
                      },
                    ),

                    // 3. Details Section
                    Consumer(
                      builder: (context, ref, _) {
                        final society = ref.watch(themeControllerProvider);
                        final system = society.handicapSystem;
                        return BoxyArtFormColumn(
                          spacing: 0,
                          children: [
                            const BoxyArtSectionTitle(
                              title: 'Membership Details',
                              followsCard: true,
                              horizontalPadding: 0,
                            ),
                            BoxyArtCard(
                              child: BoxyArtFormColumn(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _isEditing
                                          ? BoxyArtInputField(
                                              label: 'Handicap',
                                              controller: _handicapController,
                                              focusNode: _handicapFocusNode,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            )
                                          : _buildValueDisplay(context, 'HC', _handicapController.text),
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                        child: _isEditing
                                          ? BoxyArtInputField(
                                              label: system.idLabel.toUpperCase(),
                                              controller: _handicapIdController,
                                              focusNode: _handicapIdFocusNode,
                                              hint: system.hintText,
                                            )
                                          : _buildValueDisplay(
                                              context, 
                                              system.idLabel.toUpperCase(), 
                                              _handicapIdController.text
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (widget.member?.handicapHistory.isNotEmpty ?? false) ...[
                                    const BoxyArtDivider(verticalPadding: AppSpacing.lg),
                                    BoxyArtHandicapTrend(history: widget.member!.handicapHistory),
                                  ],
                                  if (_isEditing && isAdmin)
                                    BoxyArtDatePickerField(
                                      label: 'Membership Valid Till',
                                      value: _membershipEndDate != null 
                                          ? '${_membershipEndDate!.day.toString().padLeft(2, '0')}/${_membershipEndDate!.month.toString().padLeft(2, '0')}/${_membershipEndDate!.year}' 
                                          : 'Tap to select date',
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _membershipEndDate ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (date != null) setState(() => _membershipEndDate = date);
                                      },
                                    )
                                  else
                                    _buildValueDisplay(
                                      context, 
                                      'Membership Valid Till', 
                                      _membershipEndDate != null 
                                          ? '${_membershipEndDate!.day.toString().padLeft(2, '0')}/${_membershipEndDate!.month.toString().padLeft(2, '0')}/${_membershipEndDate!.year}' 
                                          : '-'
                                    ),
                                ],
                              ),
                            ),

                            // Admin Controls Section
                            if (isAdmin) ...[
                              const BoxyArtSectionTitle(
                                title: 'Administrative Controls',
                                followsCard: true,
                              ),
                              BoxyArtCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: BoxyArtFormColumn(
                                        spacing: spacing?.labelToCard ?? AppSpacing.xs,
                                        children: [
                                          Text(
                                            'Allow Social Events Only'.toUpperCase(),
                                            style: AppTypography.micro.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              letterSpacing: AppTypography.lsLabel,
                                            ),
                                          ),
                                          Text(
                                            'Permits attendance at social events while suspended.',
                                            style: AppTypography.caption.copyWith(
                                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _allowSocialEventsOnly,
                                      activeTrackColor: Theme.of(context).primaryColor,
                                      activeThumbColor: AppColors.pureWhite,
                                      onChanged: _isEditing ? (val) => setState(() => _allowSocialEventsOnly = val) : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              BoxyArtCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: BoxyArtFormColumn(
                                        spacing: spacing?.labelToCard ?? AppSpacing.xs,
                                        children: [
                                          Text(
                                            'Founding Member Status'.toUpperCase(),
                                            style: AppTypography.micro.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              letterSpacing: AppTypography.lsLabel,
                                            ),
                                          ),
                                          Text(
                                            'Grants honorary "Founding Member" recognition badge.',
                                            style: AppTypography.caption.copyWith(
                                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _isFoundingMember,
                                      activeTrackColor: AppColors.lime500,
                                      activeThumbColor: AppColors.pureWhite,
                                      onChanged: _isEditing ? (val) => setState(() => _isFoundingMember = val) : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],

                  // Title handles its own padding
                  const BoxyArtSectionTitle(
                    title: 'Personal Details',
                    followsCard: true,
                  ),
                  BoxyArtCard(
                    child: PersonalDetailsForm(
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
                      gender: _gender, // [NEW]
                      onGenderChanged: (val) => setState(() => _gender = val), // [NEW]
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
                  ),

                  const SizedBox(height: AppSpacing.section),

                  if (isAdmin && widget.member != null && widget.member!.id != currentUser.id)
                    BoxyArtButton(
                      title: 'View As This Member',
                      isPrimary: false,
                      isSecondary: true,
                      fullWidth: true,
                      icon: Icons.visibility_outlined,
                      onTap: () {
                        ref.read(impersonationProvider.notifier).set(widget.member);
                        Navigator.of(context).pop();
                        context.go('/home');
                      },
                    ),

                  if (_isEditing)
                    BoxyArtCard(
                      child: BoxyArtFormActionRow(
                        onSave: _save,
                        onCancel: _showExitConfirmation,
                        isSaving: _isSaving,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.pageBottom),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditing) {
          _showExitConfirmation();
        }
      },
      child: baseContent,
    );
  }

  Widget _buildValueDisplay(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return BoxyArtFormColumn(
      spacing: spacing?.labelToCard ?? AppSpacing.xs,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.micro.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
            letterSpacing: AppTypography.lsLabel,
          ),
        ),
        Text(
          value.isEmpty ? '-' : value,
          style: AppTypography.micro.copyWith(
            fontSize: 15,
            color: theme.brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark600,
            fontWeight: AppTypography.weightSemibold,
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => BoxyArtDialog(
        title: 'Discard Changes?',
        message: 'You have unsaved changes. Are you sure you want to leave?',
        actions: [
          BoxyArtButton(
            title: 'Keep Editing',
            isSecondary: true,
            onTap: () => Navigator.of(dialogContext).pop(),
          ),
          BoxyArtButton(
            title: 'Discard',
            onTap: () {
               Navigator.of(dialogContext).pop(); // Close dialog
               if (widget.isNewMember) {
                 Navigator.of(context).pop(); // Exit screen
               } else {
                 setState(() {
                   _isEditing = false;
                   _initControllers(); // Reset to original values
                 });
               }
            },
          ),
        ],
      ),
    );
  }

  void _showSocietyRolePicker() {
    SocietyRolePicker.show(
      context, 
      _societyRole, 
      (newRole) => setState(() => _societyRole = newRole),
    );
  }
}

