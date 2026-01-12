import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/theme/theme_controller.dart';
import 'package:golf_society/core/theme/app_theme.dart';
import 'package:golf_society/core/theme/contrast_helper.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class BrandingSettingsScreen extends ConsumerWidget {
  const BrandingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    
    final currentColor = Color(config.primaryColor);

    return Scaffold(
      appBar: const BoxyArtAppBar(title: 'Society Branding', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Preview Card
            const Text(
              'LIVE PREVIEW',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _buildPreviewCard(currentColor, config.themeMode),
            const SizedBox(height: 32),

            // 2. Color Palette
            const Text(
              'PRIMARY COLOR',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _ColorPalette(
              selectedColor: currentColor,
              customColors: config.customColors,
              onColorSelected: (c) => controller.setPrimaryColor(c),
              onAddCustomColor: (c) => controller.addCustomColor(c),
              onUpdateCustomColor: (index, c) => controller.updateCustomColor(index, c),
            ),
            const SizedBox(height: 32),

            // 3. Card Appearance
            const Text(
              'CARD APPEARANCE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            BoxyArtFloatingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Use Gradient',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: config.useCardGradient,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) => controller.setUseCardGradient(value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Tint Intensity Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Card Tint Intensity',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(config.cardTintIntensity * 100).round()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: config.cardTintIntensity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) => controller.setCardTintIntensity(value),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text('100%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Color patch preview
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          currentColor.withValues(alpha: config.cardTintIntensity * 0.5),
                          currentColor.withValues(alpha: config.cardTintIntensity),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        'Card Preview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ContrastHelper.getContrastingText(
                            Color.alphaBlend(
                              currentColor.withValues(alpha: config.cardTintIntensity * 0.75),
                              Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Appearance Mode
            const Text(
              'APP APPEARANCE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('System Default'),
                    value: 'system',
                    groupValue: config.themeMode,
                    activeColor: currentColor,
                    onChanged: (v) => controller.setThemeMode(v!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Always Light'),
                    value: 'light',
                    groupValue: config.themeMode,
                    activeColor: currentColor,
                    onChanged: (v) => controller.setThemeMode(v!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Always Dark'),
                    value: 'dark',
                    groupValue: config.themeMode,
                    activeColor: currentColor,
                    onChanged: (v) => controller.setThemeMode(v!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(Color primary, String themeMode) {
    // Determine brightness for preview based on setting
    final bool isDark = themeMode == 'dark' || (themeMode == 'system' &&  WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0,5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey.shade300, radius: 24, child: const Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  Text('Handicap: 14.2', style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: ContrastHelper.getContrastingText(primary),
                elevation: 4,
                shadowColor: primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPalette extends StatefulWidget {
  final Color selectedColor;
  final List<int> customColors;
  final Function(Color) onColorSelected;
  final Function(Color) onAddCustomColor;
  final Function(int, Color) onUpdateCustomColor;

  const _ColorPalette({
    required this.selectedColor,
    required this.customColors,
    required this.onColorSelected,
    required this.onAddCustomColor,
    required this.onUpdateCustomColor,
  });

  static const List<Color> _systemColors = [
    Color(0xFFF7D354), // BoxyArt Yellow
    Color(0xFF2962FF), // Royal Blue
    Color(0xFF00C853), // Emerald Green
    Color(0xFFD50000), // Cardinal Red
    Color(0xFF6200EA), // Deep Purple
    Color(0xFF455A64), // Slate Grey
    Color(0xFFC6FF00), // Neon Lime
    Color(0xFFFF6D00), // Orange
    Color(0xFF00BFA5), // Teal
    Color(0xFFFFD600), // Pure Gold
  ];

  @override
  State<_ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<_ColorPalette> {
  @override
  Widget build(BuildContext context) {
    // Convert custom color ints to Color objects
    final customColorsList = widget.customColors.map((hex) => Color(hex)).toList();
    
    return BoxyArtFloatingCard(
      child: Column(
        children: [
          // System Colors Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _ColorPalette._systemColors.map((c) => _buildColorCircle(c, isSystemColor: true)).toList(),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Custom Colors Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              // Existing custom colors
              ...List.generate(customColorsList.length, (index) {
                return _buildColorCircle(customColorsList[index], isSystemColor: false, customIndex: index);
              }),
              // Empty slots (up to 5 total)
              ...List.generate(5 - customColorsList.length, (index) {
                return _buildEmptySlot();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color, {required bool isSystemColor, int? customIndex}) {
    final isSelected = widget.selectedColor == color;
    
    return GestureDetector(
      onTap: () => widget.onColorSelected(color),
      onLongPress: !isSystemColor && customIndex != null 
          ? () => _showEditCustomColorDialog(customIndex, color)
          : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 3) : Border.all(color: Colors.grey.shade300),
          boxShadow: [
            if (isSelected) BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Center(child: Icon(Icons.check, color: ContrastHelper.getContrastingText(color), size: 28)),
            if (!isSystemColor && customIndex != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditCustomColorDialog(customIndex, color),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptySlot() {
    return GestureDetector(
      onTap: () => _showAddCustomColorDialog(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: Icon(Icons.add, color: Colors.grey.shade400, size: 24),
      ),
    );
  }
  
  Future<void> _showAddCustomColorDialog() async {
    final Color? result = await showColorPickerDialog(
      context,
      widget.selectedColor,
      title: Text('Add Color', style: Theme.of(context).textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 8,
      elevation: 4,
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: false,
      ),
      constraints: const BoxConstraints(minHeight: 480, minWidth: 320, maxWidth: 320),
    );
    
    if (result != null) {
      widget.onAddCustomColor(result);
    }
  }
  
  Future<void> _showEditCustomColorDialog(int index, Color currentColor) async {
    final Color? result = await showColorPickerDialog(
      context,
      currentColor,
      title: Text('Edit Color', style: Theme.of(context).textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 8,
      elevation: 4,
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: false,
      ),
      constraints: const BoxConstraints(minHeight: 480, minWidth: 320, maxWidth: 320),
    );
    
    if (result != null) {
      widget.onUpdateCustomColor(index, result);
    }
  }
}
