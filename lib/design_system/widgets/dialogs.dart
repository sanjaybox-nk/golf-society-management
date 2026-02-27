import 'package:flutter/material.dart';
import 'package:golf_society/theme/app_colors.dart';
import 'package:golf_society/theme/app_typography.dart';
import 'package:golf_society/theme/app_spacing.dart';

/// Standard branded dialog for Fairway v3.1.
class BoxyArtDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final String? message;
  final List<Widget>? actions;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;

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
  }) : assert(content != null || message != null, 'Either content or message must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final List<Widget> dialogActions = actions ?? [
      if (onCancel != null)
        TextButton(
          onPressed: onCancel,
          child: Text(cancelText ?? 'Cancel'),
        ),
      if (onConfirm != null)
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(confirmText ?? 'Confirm'),
        )
      else if (onCancel == null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
    ];

    return AlertDialog(
      title: Text(title, style: theme.dialogTheme.titleTextStyle),
      content: SingleChildScrollView(
        child: content ?? Text(
          message!,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.dark150 : AppColors.dark300,
          ),
        ),
      ),
      actions: dialogActions,
      backgroundColor: theme.dialogTheme.backgroundColor,
      shape: theme.dialogTheme.shape,
      actionsPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
  String confirmText = 'Confirm',
  VoidCallback? onCancel,
  String cancelText = 'Cancel',
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
