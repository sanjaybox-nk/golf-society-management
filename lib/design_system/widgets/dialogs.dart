import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Standard branded dialog for Fairway v3.1.
class BoxyArtDialog extends ConsumerWidget {
  final String title;
  final Widget? content;
  final String? message;
  final List<Widget>? actions;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;
  final bool isDangerous;

  const BoxyArtDialog({
    super.key,
    required this.title,
    this.content,
    this.message,
    this.actions,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.isDangerous = false,
  }) : assert(content != null || message != null, 'Either content or message must be provided');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    
    // Design 4.x Rhythm & Tokens
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.standard),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        backgroundColor: isDark ? AppColors.dark700 : Color(config.cardColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - Display Subpage 4.x
            Text(
              title, 
              style: AppTypography.displaySubPage.copyWith(
                color: isDark ? AppColors.dark60 : AppColors.dark900,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md), // 8pt Gap to message
            
            // Message - Body 4.x
            if (message != null || content != null)
              content ?? Text(
                message!,
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.dark150 : AppColors.dark300,
                  height: 1.5, // Improved readability for 4.x
                ),
              ),
              
            const SizedBox(height: AppSpacing.xl), // 16pt Gap to actions
            
            // Actions - Right Aligned or Stacked if overflowing
            OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: AppSpacing.md,
              overflowSpacing: AppSpacing.sm,
              children: [
                if (onCancel != null)
                  BoxyArtButton(
                    title: cancelText ?? 'CANCEL',
                    isGhost: true,
                    onTap: onCancel,
                  ),
                if (onConfirm != null)
                  BoxyArtButton(
                    title: confirmText ?? 'CONFIRM',
                    isPrimary: !isDangerous,
                    isDangerous: isDangerous,
                    onTap: onConfirm,
                  )
                else if (onCancel == null && actions == null)
                  BoxyArtButton(
                    title: 'CLOSE',
                    isGhost: true,
                    onTap: () => Navigator.pop(context),
                  ),
                if (actions != null) ...actions!,
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? content,
    String? message,
    List<Widget>? actions,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => BoxyArtDialog(
        title: title,
        content: content,
        message: message,
        actions: actions,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
      ),
    );
  }
}

/// Helper function to show a standardized BoxyArt dialog (Legacy support).
Future<T?> showBoxyArtDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  List<Widget>? actions,
  VoidCallback? onConfirm,
  String confirmText = 'CONFIRM',
  VoidCallback? onCancel,
  String cancelText = 'CANCEL',
  bool isDangerous = false,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) {
      return BoxyArtDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
      );
    },
  );
}

/// Generic confirmation dialog helper.
class BoxyArtConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const BoxyArtConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtDialog(
      title: title,
      message: message,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
      confirmText: confirmLabel,
      cancelText: cancelLabel,
    );
  }
}

/// A high-security confirmation dialog that requires typing a specific string to confirm.
class BoxyArtDeleteConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String requiredText;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const BoxyArtDeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.requiredText = 'DELETE',
    this.confirmLabel = 'CONFIRM DELETE',
    this.cancelLabel = 'Cancel',
    this.isDestructive = true,
  });

  @override
  State<BoxyArtDeleteConfirmationDialog> createState() => _BoxyArtDeleteConfirmationDialogState();
}

class _BoxyArtDeleteConfirmationDialogState extends State<BoxyArtDeleteConfirmationDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isMatch = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BoxyArtDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: AppTypography.body.copyWith(
              color: theme.brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark300,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Type "${widget.requiredText}" to confirm:',
            style: AppTypography.caption.copyWith(
              fontWeight: AppTypography.weightBold,
              color: widget.isDestructive ? theme.colorScheme.error : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (val) {
              setState(() {
                _isMatch = val.trim().toUpperCase() == widget.requiredText.toUpperCase();
              });
            },
            decoration: InputDecoration(
              hintText: widget.requiredText,
              errorText: (_controller.text.isNotEmpty && !_isMatch) ? 'Text must match exactly' : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          onPressed: _isMatch ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isDestructive ? theme.colorScheme.error : null,
            foregroundColor: AppColors.pureWhite,
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
