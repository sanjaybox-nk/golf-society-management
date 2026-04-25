import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/constants/country_codes.dart';

class PersonalDetailsForm extends StatefulWidget {
  final bool isEditing;
  final TextEditingController firstController;
  final TextEditingController lastController;
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController countryCodeController;
  final TextEditingController addressController;
  final TextEditingController bioController;
  final DateTime? joinedDate;
  final VoidCallback onPickDate;
  final FocusNode? bioFocusNode;
  final FocusNode? firstFocusNode;
  final FocusNode? lastFocusNode;
  final FocusNode? nicknameFocusNode;
  final FocusNode? emailFocusNode;
  final FocusNode? phoneFocusNode;
  final FocusNode? addressFocusNode;

  final String? gender;
  final ValueChanged<String?>? onGenderChanged;

  const PersonalDetailsForm({
    super.key,
    required this.isEditing,
    required this.firstController,
    required this.lastController,
    required this.nicknameController,
    required this.emailController,
    required this.phoneController,
    required this.countryCodeController,
    required this.addressController,
    required this.bioController,
    required this.joinedDate,
    required this.onPickDate,
    this.gender,
    this.onGenderChanged,
    this.bioFocusNode,
    this.firstFocusNode,
    this.lastFocusNode,
    this.nicknameFocusNode,
    this.emailFocusNode,
    this.phoneFocusNode,
    this.addressFocusNode,
  });

  @override
  State<PersonalDetailsForm> createState() => _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends State<PersonalDetailsForm> {
  final TextEditingController _modalSearchController = TextEditingController();

  @override
  void dispose() {
    _modalSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return BoxyArtFormColumn(
        children: [
          BoxyArtInputField(
            label: 'Bio',
            controller: widget.bioController,
            focusNode: widget.bioFocusNode,
            maxLines: 2,
            hint: 'Tell us a bit about yourself...',
          ),
          Row(
            children: [
              Expanded(
                child: BoxyArtInputField(
                  label: 'First Name',
                  controller: widget.firstController,
                  focusNode: widget.firstFocusNode,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: BoxyArtInputField(
                  label: 'Last Name',
                  controller: widget.lastController,
                  focusNode: widget.lastFocusNode,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: BoxyArtInputField(
                  label: 'Nickname',
                  controller: widget.nicknameController,
                  focusNode: widget.nicknameFocusNode,
                  hint: 'Optional',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: BoxyArtDropdownField<String>(
                  label: 'Gender',
                  value: widget.gender,
                  hint: 'Select',
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: widget.onGenderChanged!,
                ),
              ),
            ],
          ),
          BoxyArtInputField(
            label: 'Email',
            controller: widget.emailController,
            focusNode: widget.emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCountryCodePicker(context),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BoxyArtInputField(
                  label: 'Phone',
                  controller: widget.phoneController,
                  focusNode: widget.phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
              ),
            ],
          ),
          BoxyArtInputField(
            label: 'Address',
            controller: widget.addressController,
            focusNode: widget.addressFocusNode,
            maxLines: 2,
            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
          ),
          BoxyArtDatePickerField(
            label: 'Member Since',
            value: widget.joinedDate != null 
                ? '${widget.joinedDate!.day.toString().padLeft(2, '0')}/${widget.joinedDate!.month.toString().padLeft(2, '0')}/${widget.joinedDate!.year}' 
                : 'Select date',
            onTap: widget.onPickDate,
          ),
        ],
      );
    }

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return BoxyArtFormColumn(
      spacing: spacing?.cardToCard ?? AppSpacing.lg,
      children: [
        if (widget.bioController.text.isNotEmpty)
          _buildInfoRow(context, 'Bio', widget.bioController.text),
        if (widget.nicknameController.text.isNotEmpty)
          _buildInfoRow(context, 'Nickname', widget.nicknameController.text),
        _buildInfoRow(context, 'Email', widget.emailController.text),
        _buildInfoRow(context, 'Phone', '${widget.countryCodeController.text} ${widget.phoneController.text}'),
        _buildInfoRow(context, 'Address', widget.addressController.text),
        _buildInfoRow(
          context,
          'Member Since', 
          widget.joinedDate != null ? '${widget.joinedDate!.day.toString().padLeft(2, '0')}/${widget.joinedDate!.month.toString().padLeft(2, '0')}/${widget.joinedDate!.year}' : '-'
        ),
        if (widget.gender != null)
          _buildInfoRow(context, 'Gender', widget.gender!),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return BoxyArtFormColumn(
      spacing: spacing?.labelToCard ?? AppSpacing.xs,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.micro.copyWith(
            color: isDark ? AppColors.dark300 : AppColors.dark400,
            letterSpacing: AppTypography.lsLabel,
          ),
        ),
        Text(
          value.isEmpty ? '-' : value,
          style: AppTypography.body.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCodePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    
    return BoxyArtFormColumn(
      spacing: spacing?.labelToCard ?? AppSpacing.labelToCard,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            'CODE',
            style: AppTypography.micro.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
              fontWeight: AppTypography.weightBold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        InkWell(
          onTap: () => _showCountryCodePicker(context),
          borderRadius: BorderRadius.circular(shapes?.inputRadius ?? 12),
          child: Container(
            height: 52,
            width: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark600 : AppColors.pureWhite,
              borderRadius: BorderRadius.circular(shapes?.inputRadius ?? 12),
              border: Border.all(
                color: isDark ? AppColors.dark500 : AppColors.lightBorder, 
                width: AppShapes.borderThin,
              ),
            ),
            child: Text(
              widget.countryCodeController.text.isEmpty ? '+1' : widget.countryCodeController.text,
              style: AppTypography.body.copyWith(
                fontWeight: AppTypography.weightMedium,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryCodePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final queryText = _modalSearchController.text.toLowerCase();
          final filteredOptions = countryList.where((country) {
            return country['name']!.toLowerCase().contains(queryText) || 
                   country['code']!.contains(queryText);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark700 : AppColors.pureWhite,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.dark400 : AppColors.dark150,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Select Country Code',
                  style: AppTypography.headline.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BoxyArtInputField(
                  label: '',
                  hint: 'Search by name or code...',
                  controller: _modalSearchController,
                  onChanged: (_) => setModalState(() {}),
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredOptions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1, 
                      color: isDark ? AppColors.dark600 : AppColors.lightBorder.withValues(alpha: AppColors.opacityHalf)
                    ),
                    itemBuilder: (context, index) {
                      final country = filteredOptions[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        leading: Text(
                          country['flag'] ?? '', 
                          style: const TextStyle(fontSize: 24)
                        ),
                        title: Text(
                          country['name']!,
                          style: AppTypography.body.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: AppTypography.weightMedium,
                          ),
                        ),
                        trailing: Text(
                          country['code']!,
                          style: AppTypography.label.copyWith(
                            color: theme.primaryColor,
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        onTap: () {
                          widget.countryCodeController.text = country['code']!;
                          _modalSearchController.clear();
                          Navigator.pop(context);
                          setState(() {}); // Update local display
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl),
              ],
            ),
          );
        }
      ),
    );
  }
}
