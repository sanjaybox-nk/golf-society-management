import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:golf_society/design_system/design_system.dart';

class BrandingHelper {
  static Future<void> pickColor(
    BuildContext context,
    String title,
    Color current,
    Function(Color) onPicked,
  ) async {
    final cleanTitle = title.endsWith('Color') ? title : '$title Color';
    Color pickedColor = current;

    final result = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _BrandingColorPickerDialog(
              title: cleanTitle,
              initialColor: pickedColor,
              onColorChanged: (newColor) {
                setDialogState(() {
                  pickedColor = newColor;
                });
              },
            );
          },
        );
      },
    );

    if (result != null) {
      onPicked(result);
    }
  }
}

class _BrandingColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;
  final Function(Color) onColorChanged;

  const _BrandingColorPickerDialog({
    required this.title,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<_BrandingColorPickerDialog> createState() => _BrandingColorPickerDialogState();
}

class _BrandingColorPickerDialogState extends State<_BrandingColorPickerDialog> {
  late Color pickedColor;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    pickedColor = widget.initialColor;
    _hexController = TextEditingController(text: _getHexCode(pickedColor));
  }

  String _getHexCode(Color color) {
    return color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        widget.title,
        style: AppTypography.displaySubPage,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              color: pickedColor,
              onColorChanged: (Color color) {
                setState(() {
                  pickedColor = color;
                  final newHex = _getHexCode(color);
                  if (_hexController.text != newHex) {
                    _hexController.text = newHex;
                  }
                });
                widget.onColorChanged(color);
              },
              width: 40,
              height: 40,
              borderRadius: 8,
              spacing: 8,
              runSpacing: 8,
              wheelDiameter: 220,
              showColorCode: false,
              enableOpacity: false,
              pickersEnabled: const {
                ColorPickerType.both: false,
                ColorPickerType.primary: true,
                ColorPickerType.accent: false,
                ColorPickerType.wheel: true,
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '#',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.dark600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      style: AppTypography.label.copyWith(
                        letterSpacing: 1,
                        fontWeight: AppTypography.weightBold,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) {
                        if (v.length == 6) {
                          try {
                            final newColor = Color(int.parse('FF$v', radix: 16));
                            setState(() {
                              pickedColor = newColor;
                            });
                            widget.onColorChanged(newColor);
                          } catch (e) {
                            // Invalid hex
                          }
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      final hex = _hexController.text;
                      Clipboard.setData(ClipboardData(text: '#$hex'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Color #$hex copied to clipboard'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a color above or enter hex code',
              style: AppTypography.helper,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('CANCEL', style: AppTypography.label.copyWith(color: AppColors.dark600)),
        ),
        BoxyArtButton(
          title: 'SELECT',
          onTap: () => Navigator.of(context).pop(pickedColor),
        ),
      ],
    );
  }
}

class StatusColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const StatusColorRow({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppColors.textSecondary;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.03),
          borderRadius: AppShapes.md,
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacitySubtle),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      fontSize: 12,
                      fontWeight: AppTypography.weightStrong,
                      letterSpacing: 0.8,
                      color: AppColors.dark600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
                        style: AppTypography.micro.copyWith(
                          color: textSecondary,
                          fontWeight: AppTypography.weightBold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: textSecondary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const CompactColorPicker({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.03),
          borderRadius: AppShapes.md,
          border: Border.all(
            color: Theme.of(
              context,
            ).dividerColor.withValues(alpha: AppColors.opacitySubtle),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontSize: 12,
                fontWeight: AppTypography.weightStrong,
                letterSpacing: 0.8,
                color: AppColors.dark600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
                  style: AppTypography.micro.copyWith(
                    fontWeight: AppTypography.weightBold,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DarkSwatch extends StatelessWidget {
  final String label;
  final Color color;

  const DarkSwatch({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppShapes.md,
            border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            fontSize: 8,
            color: AppColors.dark600,
          ),
        ),
      ],
    );
  }
}

class ScoreColorGridItem extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ScoreColorGridItem({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.pureWhite 
                    : AppColors.dark800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveColorRow extends StatelessWidget {
  final List<Widget> children;
  const ResponsiveColorRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a safe width if constraints are infinite (e.g. inside a horizontal scroll or unconstrained column)
        final width = constraints.maxWidth.isFinite 
            ? constraints.maxWidth 
            : MediaQuery.of(context).size.width - (AppSpacing.x2l * 2);

        int itemsPerRow = children.length;
        if (width < 440 && itemsPerRow > 2) itemsPerRow = 2;
        if (width < 280) itemsPerRow = 1;
        
        final spacing = AppSpacing.sm;
        final itemWidth = (width - (spacing * (itemsPerRow - 1))) / itemsPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((c) => SizedBox(
            width: itemWidth.isFinite ? itemWidth : 160, 
            child: c
          )).toList(),
        );
      },
    );
  }
}

class ColorPalette extends StatefulWidget {
  final Color selectedColor;
  final List<int> customColors;
  final Function(Color) onColorSelected;
  final Function(Color) onAddCustomColor;
  final Function(int, Color) onUpdateCustomColor;

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.customColors,
    required this.onColorSelected,
    required this.onAddCustomColor,
    required this.onUpdateCustomColor,
  });

  static const List<Color> systemColors = [
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
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  @override
  Widget build(BuildContext context) {
    final customColorsList = widget.customColors
        .map((hex) => Color(hex))
        .toList();

    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: ColorPalette.systemColors
              .map((c) => _buildColorCircle(c, isSystemColor: true))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ...List.generate(customColorsList.length, (index) {
              return _buildColorCircle(
                customColorsList[index],
                isSystemColor: false,
                customIndex: index,
              );
            }),
            ...List.generate(5 - customColorsList.length, (index) {
              return _buildEmptySlot();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildColorCircle(
    Color color, {
    required bool isSystemColor,
    int? customIndex,
  }) {
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
          border: isSelected
              ? Border.all(color: Colors.black, width: 3)
              : Border.all(color: AppColors.dark300),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Center(
                child: Icon(
                  Icons.check,
                  color: ContrastHelper.getContrastingText(color),
                  size: AppShapes.iconLg,
                ),
              ),
            if (!isSystemColor && customIndex != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditCustomColorDialog(customIndex, color),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.87),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.pureWhite,
                      size: AppShapes.iconXs,
                    ),
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
          color: AppColors.dark100,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.dark400,
            width: AppShapes.borderMedium,
          ),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.dark400,
          size: AppShapes.iconLg,
        ),
      ),
    );
  }

  Future<void> _showAddCustomColorDialog() async {
    await BrandingHelper.pickColor(
      context,
      'Add Color',
      widget.selectedColor,
      (result) => widget.onAddCustomColor(result),
    );
  }

  Future<void> _showEditCustomColorDialog(int index, Color currentColor) async {
    await BrandingHelper.pickColor(
      context,
      'Edit Color',
      currentColor,
      (result) => widget.onUpdateCustomColor(index, result),
    );
  }
}
