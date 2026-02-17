import 'package:flutter/material.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/constants/country_codes.dart';
import '../../../../core/theme/app_shadows.dart';

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
    return ModernCard(
      padding: const EdgeInsets.all(24),
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
            BoxyArtFormField(
              label: 'Nickname',
              controller: nicknameController,
              focusNode: nicknameFocusNode,
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
     );
  }
}
