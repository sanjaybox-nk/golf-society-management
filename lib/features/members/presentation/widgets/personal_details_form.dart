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

  final String? gender; // [NEW]
  final ValueChanged<String?>? onGenderChanged; // [NEW]

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
    this.gender, // [NEW]
    this.onGenderChanged, // [NEW]
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
    return BoxyArtCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const BoxyArtSectionTitle(
          title: 'Personal Details',
          isLevel2: true,
          icon: Icons.account_circle_outlined,
        ),
          
          if (isEditing) ...[
            BoxyArtFormField(
              label: 'Bio',
              controller: bioController,
              focusNode: bioFocusNode,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BoxyArtFormField(
                    label: 'First Name *',
                    controller: firstController,
                    focusNode: firstFocusNode,
                    validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BoxyArtFormField(
                    label: 'Last Name *',
                    controller: lastController,
                    focusNode: lastFocusNode,
                    validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BoxyArtFormField(
                    label: 'Nickname',
                    controller: nicknameController,
                    focusNode: nicknameFocusNode,
                  ),
                ),
                // [NEW] Gender Dropdown
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 4),
                        child: Text(
                          'Gender'.toUpperCase(),
                          style: AppTypography.label.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark300,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: AppShadows.inputSoft,
                          border: Theme.of(context).brightness == Brightness.dark 
                              ? null 
                              : Border.all(color: AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wc_outlined,
                              size: 18,
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark300,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: gender,
                                  isExpanded: true,
                                  hint: Text('Select', style: AppTypography.bodySmall.copyWith(color: Colors.grey)),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male', style: AppTypography.bodySmall)),
                                    DropdownMenuItem(value: 'Female', child: Text('Female', style: AppTypography.bodySmall)),
                                  ],
                                  onChanged: onGenderChanged,
                                  dropdownColor: Theme.of(context).brightness == Brightness.dark ? AppColors.dark700 : Colors.white,
                                  style: AppTypography.body.copyWith(
                                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark60 : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BoxyArtFormField(
              label: 'Email *',
              controller: emailController,
              focusNode: emailFocusNode,
              validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 _buildCountryCodePicker(context),
                 const SizedBox(width: 12),
                 Expanded(
                   child: BoxyArtFormField(
                     label: 'Phone *',
                     controller: phoneController,
                     focusNode: phoneFocusNode,
                     validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             BoxyArtFormField(
               label: 'Address *',
               controller: addressController,
               focusNode: addressFocusNode,
               maxLines: 2,
               validator: (v) => v?.isNotEmpty != true ? 'Required' : null,
             ),
             const SizedBox(height: 16),
             BoxyArtDatePickerField(
               label: 'Member Since',
               value: joinedDate != null 
                   ? '${joinedDate!.day.toString().padLeft(2, '0')}/${joinedDate!.month.toString().padLeft(2, '0')}/${joinedDate!.year}' 
                   : 'Tap to select date',
               onTap: onPickDate,
             ),
          ] else ...[
            // View Mode
            if (nicknameController.text.isNotEmpty) ...[
               _buildInfoRow(Icons.short_text_rounded, 'NICKNAME', nicknameController.text),
               const SizedBox(height: 16),
            ],
            _buildInfoRow(Icons.email_outlined, 'EMAIL', emailController.text),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone_outlined, 'PHONE', '${countryCodeController.text}${phoneController.text}'),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on_outlined, 'ADDRESS', addressController.text),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today_outlined, 
              'MEMBER SINCE', 
              joinedDate != null ? '${joinedDate!.day.toString().padLeft(2, '0')}/${joinedDate!.month.toString().padLeft(2, '0')}/${joinedDate!.year}' : '-'
            ),
            if (gender != null) ...[
               const SizedBox(height: 16),
               _buildInfoRow(Icons.wc_outlined, 'GENDER', gender!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ModernInfoRow(
      icon: icon,
      label: label,
      value: value,
    );
  }

  Widget _buildCountryCodePicker(BuildContext context) {
    return SizedBox(
       width: 120,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                'Code'.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark300,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(100),
                boxShadow: AppShadows.inputSoft,
                border: Theme.of(context).brightness == Brightness.dark 
                    ? null 
                    : Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.public_rounded,
                    size: 18,
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark200 : AppColors.dark300,
                  ),
                  Expanded(
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
                          child: OverflowBox(
                            maxWidth: 195,
                            minWidth: 195,
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 8,
                              color: Theme.of(context).cardColor,
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
                                              style: AppTypography.displayLargeBody,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              option['code']!,
                                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                                child: Text(
                                                  option['name']!,
                                                  style: AppTypography.labelStrong.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
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
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark60 : const Color(0xFF1A1A1A),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
         ],
       ),
     );
  }
}
