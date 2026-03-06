import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:golf_society/services/storage_service.dart';


class BrandingSettingsScreen extends ConsumerWidget {
  const BrandingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return HeadlessScaffold(
      title: 'Branding',
      subtitle: 'Customize colors and identity',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'Society Identity', ),
              const SizedBox(height: 12),
              BoxyArtCard(
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
              
              const BoxyArtSectionTitle(title: 'Style Preference', ),
              const SizedBox(height: 12),
              BoxyArtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose a structural tone for your society. This adjusts corner rounding and depth.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    _StyleSelector(
                      currentStyle: config.brandingStyle,
                      onStyleChanged: (v) => controller.setBrandingStyle(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const BoxyArtSectionTitle(title: 'App Identity Colors', ),
              const SizedBox(height: 12),
              BoxyArtCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Primary Accent',
                            color: Color(config.primaryColor),
                            onTap: () => _pickColor(context, 'Primary', Color(config.primaryColor), (c) => controller.setPrimaryColor(c)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Action Color',
                            color: Color(config.secondaryColor),
                            onTap: () => _pickColor(context, 'Action', Color(config.secondaryColor), (c) => controller.setSecondaryColor(c)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CompactColorPicker(
                      label: 'Page Background (Light Mode)',
                      color: Color(config.backgroundColor),
                      onTap: () => _pickColor(context, 'Background', Color(config.backgroundColor), (c) => controller.setBackgroundColor(c)),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _ColorPalette(
                      selectedColor: Color(config.primaryColor),
                      customColors: config.customColors,
                      onColorSelected: (c) => controller.setPrimaryColor(c),
                      onAddCustomColor: (c) => controller.addCustomColor(c),
                      onUpdateCustomColor: (index, c) => controller.updateCustomColor(index, c),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const BoxyArtSectionTitle(title: 'Live Preview', ),
              const SizedBox(height: 12),
              _buildPreviewCard(config.primaryColor, config.secondaryColor, config.themeMode, config.brandingStyle),
              const SizedBox(height: 32),
              const SizedBox(height: 32),

              const BoxyArtSectionTitle(title: 'App Appearance', ),
              const SizedBox(height: 12),
              BoxyArtCard(
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
    );
  }

  Future<void> _pickColor(BuildContext context, String title, Color current, Function(Color) onPicked) async {
    final result = await showColorPickerDialog(
      context,
      current,
      title: Text('$title Color', style: Theme.of(context).textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 12,
      wheelDiameter: 180,
      enableOpacity: false,
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
    );
    onPicked(result);
  }

  Widget _buildPreviewCard(int primaryInt, int secondaryInt, String themeMode, String style) {
    final primary = Color(primaryInt);
    final secondary = Color(secondaryInt);
    final bool isDark = themeMode == 'dark' || (themeMode == 'system' &&  WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    double radius;
    switch (style) {
      case 'classic': radius = 8.0; break;
      case 'modern':  radius = 28.0; break;
      default:        radius = 18.0; break;
    }

    return BoxyArtCard(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: textColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: style == 'modern' ? 30 : 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: primary.withValues(alpha: 0.2), radius: 24, child: Icon(Icons.person, color: primary)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('John Doe', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor, letterSpacing: -0.5)),
                    Text('Handicap: 14.2', style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
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
                  backgroundColor: secondary,
                  foregroundColor: ContrastHelper.getContrastingText(secondary),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Action Button', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CompactColorPicker({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleSelector extends StatelessWidget {
  final String currentStyle;
  final ValueChanged<String> onStyleChanged;

  const _StyleSelector({
    required this.currentStyle,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _StyleItem(label: 'Classic', value: 'classic', groupValue: currentStyle, onTap: onStyleChanged)),
          Expanded(child: _StyleItem(label: 'Boxy', value: 'boxy', groupValue: currentStyle, onTap: onStyleChanged)),
          Expanded(child: _StyleItem(label: 'Modern', value: 'modern', groupValue: currentStyle, onTap: onStyleChanged)),
        ],
      ),
    );
  }
}

class _StyleItem extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onTap;

  const _StyleItem({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? primary : Theme.of(context).textTheme.bodySmall?.color,
          ),
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
            // ignore: deprecated_member_use
            Radio<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
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
