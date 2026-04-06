import 'package:golf_society/design_system/design_system.dart';

/// A robust image widget for the Boxy Art design system.
/// Automatically migrates stale image provider URLs (e.g. Clearbit) 
/// and provides a standardized error fallback.
class BoxyArtImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const BoxyArtImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  String _sanitizeUrl(String originalUrl) {
    if (originalUrl.contains('logo.clearbit.com')) {
      return originalUrl.replaceAll('logo.clearbit.com', 'unavatar.io');
    }
    return originalUrl;
  }

  @override
  Widget build(BuildContext context) {
    final isAsset = url.startsWith('assets/');

    Widget image = isAsset 
      ? Image.asset(
          url,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => errorWidget ?? _buildPlaceholder(),
        )
      : Image.network(
          _sanitizeUrl(url),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => errorWidget ?? _buildPlaceholder(),
        );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.dark300.withOpacity(0.1),
      child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
    );
  }
}

/// Helper for DecorationImage.
NetworkImage boxyArtNetworkImage(String url, {double scale = 1.0, Map<String, String>? headers}) {
  String sanitizedUrl = url;
  if (url.contains('logo.clearbit.com')) {
    sanitizedUrl = url.replaceAll('logo.clearbit.com', 'unavatar.io');
  }
  return NetworkImage(sanitizedUrl, scale: scale, headers: headers);
}
