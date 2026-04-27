import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../design_system/design_system.dart';
import '../../../../../services/storage_service.dart';

class BoxyArtLogoPicker extends ConsumerStatefulWidget {
  final String? currentUrl;
  final ValueChanged<String?> onUrlChanged;

  const BoxyArtLogoPicker({
    super.key,
    required this.currentUrl,
    required this.onUrlChanged,
  });

  @override
  ConsumerState<BoxyArtLogoPicker> createState() => _BoxyArtLogoPickerState();
}

class _BoxyArtLogoPickerState extends ConsumerState<BoxyArtLogoPicker> {
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

      final url = await storage.uploadImage(path: 'branding', file: file);

      widget.onUrlChanged(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
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
          'SOCIETY LOGO',
          style: TextStyle(
            fontSize: AppTypography.sizeMicro,
            fontWeight: AppTypography.weightHeavy,
            letterSpacing: AppTypography.lsLabel,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        Row(
          children: [
            // Left Column: Logo Preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.xl,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
                  width: 1.5,
                ),
                image: widget.currentUrl != null
                    ? DecorationImage(
                        image: boxyArtNetworkImage(widget.currentUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.currentUrl == null
                  ? Icon(
                      Icons.golf_course_rounded,
                      size: 40,
                      color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityMedium),
                    )
                  : null,
            ),
            
            const SizedBox(width: AppSpacing.xl),
            
            // Right Column: Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pickAndUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: ContrastHelper.getContrastingText(
                          Theme.of(context).primaryColor,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppShapes.md,
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: AppSpacing.xl,
                              height: AppSpacing.xl,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.pureWhite,
                              ),
                            )
                          : const Text(
                              'Update Logo',
                              style: TextStyle(
                                fontWeight: AppTypography.weightBold,
                              ),
                            ),
                    ),
                  ),
                  if (widget.currentUrl != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () => widget.onUrlChanged(null),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: AppShapes.iconSm,
                      ),
                      label: const Text('Remove Logo'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.coral500,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
