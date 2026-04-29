
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:golf_society/design_system/design_system.dart';

class BrandingHelper {
  static Future<void> pickColor(
    BuildContext context,
    String title,
    Color current,
    Function(Color) onPicked,
  ) async {
    final result = await showColorPickerDialog(
      context,
      current,
      title: Text(
        '$title Color',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      width: AppSpacing.x4l,
      height: AppSpacing.x4l,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 12,
      wheelDiameter: 180,
      enableOpacity: false,
      showColorCode: true,
      colorCodeReadOnly: false,
      colorCodeHasColor: true,
      colorCodeTextStyle: AppTypography.cardTitle.copyWith(
        color: AppColors.pureWhite,
      ),
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
    );
    onPicked(result);
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.03),
          borderRadius: AppShapes.md,
          border: Border.all(
            color: Theme.of(
              context,
            ).dividerColor.withValues(alpha: AppColors.opacitySubtle),
          ),
        ),
        child: Row(
          children: [
            BoxyArtPill.status(label: label, color: color),
            const Spacer(),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
              style: AppTypography.micro.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppTypography.weightBold,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
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
        padding: const EdgeInsets.all(AppSpacing.md),
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
              label,
              style: const TextStyle(
                fontSize: AppTypography.sizeLabel,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: AppSpacing.x3l,
                  height: AppSpacing.x3l,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
                  style: const TextStyle(
                    fontSize: AppTypography.sizeLabelStrong,
                    fontWeight: AppTypography.weightSemibold,
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
            color: AppColors.textSecondary,
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
        final width = constraints.maxWidth;
        int itemsPerRow = children.length;
        if (width < 440 && itemsPerRow > 2) itemsPerRow = 2;
        if (width < 280) itemsPerRow = 1;
        
        final spacing = AppSpacing.sm;
        final itemWidth = (width - (spacing * (itemsPerRow - 1))) / itemsPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((c) => SizedBox(
            width: itemWidth, 
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
    final result = await showColorPickerDialog(
      context,
      widget.selectedColor,
      title: Text('Add Color', style: Theme.of(context).textTheme.titleLarge),
      width: AppSpacing.x4l,
      height: AppSpacing.x4l,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 8,
      elevation: 4,
      showColorCode: true,
      colorCodeReadOnly: false,
      colorCodeHasColor: true,
      colorCodeTextStyle: AppTypography.cardTitle.copyWith(
        color: AppColors.pureWhite,
      ),
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
      constraints: const BoxConstraints(
        minHeight: 520,
        minWidth: 340,
        maxWidth: 340,
      ),
    );

    widget.onAddCustomColor(result);
  }

  Future<void> _showEditCustomColorDialog(int index, Color currentColor) async {
    final result = await showColorPickerDialog(
      context,
      currentColor,
      title: Text('Edit Color', style: Theme.of(context).textTheme.titleLarge),
      width: AppSpacing.x4l,
      height: AppSpacing.x4l,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 8,
      elevation: 4,
      showColorCode: true,
      colorCodeReadOnly: false,
      colorCodeHasColor: true,
      colorCodeTextStyle: AppTypography.cardTitle.copyWith(
        color: AppColors.pureWhite,
      ),
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
      constraints: const BoxConstraints(
        minHeight: 520,
        minWidth: 340,
        maxWidth: 340,
      ),
    );

    widget.onUpdateCustomColor(index, result);
  }
}
