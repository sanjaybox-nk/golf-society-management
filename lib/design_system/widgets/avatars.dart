import 'package:flutter/material.dart';

/// A standardized avatar for the Boxy Art design system.
class BoxyArtAvatar extends StatelessWidget {
  final String? url;
  final String initials;
  final double radius;
  final Color? color;

  const BoxyArtAvatar({
    super.key,
    this.url,
    required this.initials,
    this.radius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = color ?? theme.primaryColor;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: url != null && url!.isNotEmpty
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitials(primary),
              )
            : _buildInitials(primary),
      ),
    );
  }

  Widget _buildInitials(Color color) {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
