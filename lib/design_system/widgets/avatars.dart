import '../design_system.dart';

/// A standardized avatar for the Boxy Art design system.
class BoxyArtAvatar extends StatelessWidget {
  final String? url;
  final String initials;
  final double radius;
  final Color? color;
  final bool isCircle; // Allow override if specifically needed
  final Color? borderColor;
  final double? borderWidth;

  const BoxyArtAvatar({
    super.key,
    this.url,
    required this.initials,
    this.radius = 20,
    this.color,
    this.isCircle = true,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = color ?? theme.primaryColor;
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: AppColors.opacityLow),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(AppShapes.rMd),
        border: (borderColor != null || (borderWidth != null && borderWidth! > 0))
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? AppShapes.borderLight,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: isCircle ? BorderRadius.circular(radius) : BorderRadius.circular(AppShapes.rMd),
        child: url != null && url!.isNotEmpty
            ? BoxyArtImage(
                url: url!,
                fit: BoxFit.cover,
                errorWidget: _buildInitials(primary),
              )
            : _buildInitials(primary),
      ),
    );
  }

  Widget _buildInitials(Color color) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: AppTypography.weightBlack,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
