import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/theme/theme_controller.dart';
import 'package:golf_society/core/theme/contrast_helper.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:golf_society/core/services/storage_service.dart';
import 'package:golf_society/core/theme/app_palettes.dart';

class BrandingSettingsScreen extends ConsumerWidget {
  const BrandingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final currentColor = Theme.of(context).primaryColor;
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Branding',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Customize colors and identity',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const BoxyArtSectionTitle(title: 'Society Identity', padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                    ModernCard(
                      child: Column(
                        children: [
                          ModernTextField(
                            label: 'Society Name',
                            initialValue: config.societyName,
                            onChanged: (v) => controller.setSocietyName(v),
                            icon: Icons.business_rounded,
                          ),
                          const SizedBox(height: 24),
                          _LogoPicker(
                            currentUrl: config.logoUrl,
                            onUrlChanged: (v) => controller.setLogoUrl(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const BoxyArtSectionTitle(title: 'Design Palettes', padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select a preset design palette to instantly modernize your app.',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          _PaletteSelector(
                            selectedPaletteName: config.selectedPaletteName,
                            onPaletteSelected: (name) => controller.setSelectedPaletteName(name),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    const BoxyArtSectionTitle(title: 'Live Preview', padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                    _buildPreviewCard(currentColor, config.themeMode),
                    const SizedBox(height: 32),

                    const BoxyArtSectionTitle(title: 'Primary Color', padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                    ModernCard(
                      child: _ColorPalette(
                        selectedColor: currentColor,
                        customColors: config.customColors,
                        onColorSelected: (c) => controller.setPrimaryColor(c),
                        onAddCustomColor: (c) => controller.addCustomColor(c),
                        onUpdateCustomColor: (index, c) => controller.updateCustomColor(index, c),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const BoxyArtSectionTitle(title: 'Card Appearance', padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ModernSwitchRow(
                            label: 'Use Gradient',
                            value: config.useCardGradient,
                            icon: Icons.gradient_rounded,
                            onChanged: (value) => controller.setUseCardGradient(value),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Card Tint Intensity',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(config.cardTintIntensity * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
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
                          const SizedBox(height: 24),
                          Container(
                            height: 64,
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
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: Center(
                              child: Text(
                                'Card Preview',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
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

                    const BoxyArtSectionTitle(title: 'App Appearance', padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                    ModernCard(
                      child: Column(
                        children: [
                          _ThemeModeTile(
                            title: 'System Default',
                            value: 'system',
                            groupValue: config.themeMode,
                            icon: Icons.brightness_auto_rounded,
                            onChanged: (v) => controller.setThemeMode(v!),
                          ),
                          const Divider(height: 1),
                          _ThemeModeTile(
                            title: 'Always Light',
                            value: 'light',
                            groupValue: config.themeMode,
                            icon: Icons.light_mode_rounded,
                            onChanged: (v) => controller.setThemeMode(v!),
                          ),
                          const Divider(height: 1),
                          _ThemeModeTile(
                            title: 'Always Dark',
                            value: 'dark',
                            groupValue: config.themeMode,
                            icon: Icons.dark_mode_rounded,
                            onChanged: (v) => controller.setThemeMode(v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ]),
                ),
              ),
            ],
          ),
          
          // Back Button sticky
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(Color primary, String themeMode) {
    final bool isDark = themeMode == 'dark' || (themeMode == 'system' &&  WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withValues(alpha: 0.1)),
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
                    Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor, letterSpacing: -0.3)),
                    Text('Handicap: 14.2', style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w500)),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _ThemeModeTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
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
    
    return Column(
      children: [
        // System Colors Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _ColorPalette._systemColors.map((c) => _buildColorCircle(c, isSystemColor: true)).toList(),
        ),
        
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        
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
    final result = await showColorPickerDialog(
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
    
    widget.onAddCustomColor(result);
  }
  
  Future<void> _showEditCustomColorDialog(int index, Color currentColor) async {
    final result = await showColorPickerDialog(
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
    
    widget.onUpdateCustomColor(index, result);
  }
}

class _PaletteSelector extends StatelessWidget {
  final String? selectedPaletteName;
  final ValueChanged<String?> onPaletteSelected;

  const _PaletteSelector({
    required this.selectedPaletteName,
    required this.onPaletteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            scrollDirection: Axis.horizontal,
            itemCount: AppPalette.presets.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Custom option
                final isSelected = selectedPaletteName == null;
                return _buildPaletteItem(
                  context,
                  name: 'Custom',
                  isSelected: isSelected,
                  onTap: () => onPaletteSelected(null),
                  previewColors: [Theme.of(context).primaryColor, Colors.white],
                );
              }
              
              final palette = AppPalette.presets[index - 1];
              final isSelected = selectedPaletteName == palette.name;
              return _buildPaletteItem(
                context,
                name: palette.name,
                isSelected: isSelected,
                onTap: () => onPaletteSelected(palette.name),
                previewColors: [palette.background, palette.cardBg, palette.textPrimary],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaletteItem(
    BuildContext context, {
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
    required List<Color> previewColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              color: previewColors[0],
            ),
            child: Stack(
              children: [
                if (previewColors.length > 1)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: previewColors[1],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: previewColors.length > 2
                          ? Center(
                              child: Container(
                                width: 20,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: previewColors[2].withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPicker extends ConsumerStatefulWidget {
  final String? currentUrl;
  final ValueChanged<String?> onUrlChanged;

  const _LogoPicker({
    required this.currentUrl,
    required this.onUrlChanged,
  });

  @override
  ConsumerState<_LogoPicker> createState() => _LogoPickerState();
}

class _LogoPickerState extends ConsumerState<_LogoPicker> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final storage = ref.read(storageServiceProvider);
    
    setState(() => _isUploading = true);
    
    try {
      final file = await storage.pickImage(source: ImageSource.gallery);
      if (file == null) {
        setState(() => _isUploading = false);
        return;
      }

      final url = await storage.uploadImage(
        path: 'branding',
        file: file,
      );

      widget.onUrlChanged(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Society Logo',
          style: TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                image: widget.currentUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.currentUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.currentUrl == null
                  ? Icon(Icons.golf_course_rounded, size: 36, color: Theme.of(context).dividerColor.withValues(alpha: 0.2))
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _pickAndUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: ContrastHelper.getContrastingText(Theme.of(context).primaryColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isUploading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Update Logo', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (widget.currentUrl != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => widget.onUrlChanged(null),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Remove Logo'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
