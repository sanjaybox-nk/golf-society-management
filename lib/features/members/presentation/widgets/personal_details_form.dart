import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/constants/country_codes.dart';

class PersonalDetailsForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (isEditing) {
      return BoxyArtFormColumn(
        children: [
          BoxyArtInputField(
            label: 'Bio',
            controller: bioController,
            focusNode: bioFocusNode,
            maxLines: 2,
            hint: 'Tell us a bit about yourself...',
          ),
          Row(
            children: [
              Expanded(
                child: BoxyArtInputField(
                  label: 'First Name',
                  controller: firstController,
                  focusNode: firstFocusNode,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: BoxyArtInputField(
                  label: 'Last Name',
                  controller: lastController,
                  focusNode: lastFocusNode,
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
                  controller: nicknameController,
                  focusNode: nicknameFocusNode,
                  hint: 'Optional',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: BoxyArtDropdownField<String>(
                  label: 'Gender',
                  value: gender,
                  hint: 'Select',
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: onGenderChanged!,
                ),
              ),
            ],
          ),
          BoxyArtInputField(
            label: 'Email',
            controller: emailController,
            focusNode: emailFocusNode,
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
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
              ),
            ],
          ),
          BoxyArtInputField(
            label: 'Address',
            controller: addressController,
            focusNode: addressFocusNode,
            maxLines: 2,
            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
          ),
          BoxyArtDatePickerField(
            label: 'Member Since',
            value: joinedDate != null 
                ? '${joinedDate!.day.toString().padLeft(2, '0')}/${joinedDate!.month.toString().padLeft(2, '0')}/${joinedDate!.year}' 
                : 'Select date',
            onTap: onPickDate,
          ),
        ],
      );
    }

    return BoxyArtFormColumn(
      spacing: AppSpacing.x2l,
      children: [
        if (bioController.text.isNotEmpty)
          _buildInfoRow(context, 'Bio', bioController.text),
        if (nicknameController.text.isNotEmpty)
          _buildInfoRow(context, 'Nickname', nicknameController.text),
        _buildInfoRow(context, 'Email', emailController.text),
        _buildInfoRow(context, 'Phone', '${countryCodeController.text} ${phoneController.text}'),
        _buildInfoRow(context, 'Address', addressController.text),
        _buildInfoRow(
          context,
          'Member Since', 
          joinedDate != null ? '${joinedDate!.day.toString().padLeft(2, '0')}/${joinedDate!.month.toString().padLeft(2, '0')}/${joinedDate!.year}' : '-'
        ),
        if (gender != null)
          _buildInfoRow(context, 'Gender', gender!),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.label.copyWith(
            color: isDark ? AppColors.dark300 : AppColors.dark400,
            fontWeight: AppTypography.weightBold,
            letterSpacing: 1.2,
            fontSize: AppTypography.sizeMicro, // 10px Standardized Meta
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value.isEmpty ? '-' : value,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.pureWhite : AppColors.dark950,
            fontWeight: AppTypography.weightBold,
            fontSize: AppTypography.sizeBody,
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCodePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.labelToCard),
            child: Text(
              'Code',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(AppColors.opacityHigh),
              ),
            ),
          ),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark600 : AppColors.pureWhite,
              borderRadius: BorderRadius.circular(Theme.of(context).extension<AppShapeTokens>()?.inputRadius ?? 12),
              border: Border.all(
                color: isDark ? AppColors.dark500 : AppColors.lightBorder, 
                width: AppShapes.borderThin,
              ),
            ),
            child: Center(
              child: Autocomplete<Map<String, String>>(
                initialValue: TextEditingValue(text: countryCodeController.text),
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text == '') return const Iterable<Map<String, String>>.empty();
                  return countryList.where((option) {
                    return option['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                           option['code']!.contains(textEditingValue.text);
                  });
                },
                displayStringForOption: (option) => option['code']!,
                onSelected: (selection) => countryCodeController.text = selection['code']!,
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 8,
                      color: Theme.of(context).cardColor,
                      borderRadius: AppShapes.lg,
                      child: Container(
                        width: 250,
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              leading: Text(option['flag'] ?? '', style: AppTypography.displayLargeBody),
                              title: Text(option['code']!, style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightBold)),
                              subtitle: Text(option['name']!, overflow: TextOverflow.ellipsis),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                fieldViewBuilder: (context, controller, focus, onSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focus,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: AppTypography.body.copyWith(
                      fontWeight: AppTypography.weightSemibold,
                      color: isDark ? AppColors.pureWhite : AppColors.dark950,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
