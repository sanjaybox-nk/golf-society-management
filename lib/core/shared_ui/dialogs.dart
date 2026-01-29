import 'package:flutter/material.dart';
import './buttons.dart';

/// A standardized BoxyArt themed dialog.
class BoxyArtDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final String? message; // Keep message for simple cases
  final List<Widget>? actions;
  final VoidCallback? onConfirm;
  final String confirmText;
  final VoidCallback? onCancel;
  final String cancelText;

  const BoxyArtDialog({
    super.key,
    required this.title,
    this.content,
    this.message,
    this.actions,
    this.onConfirm,
    this.confirmText = 'Confirm',
    this.onCancel,
    this.cancelText = 'Cancel',
  }) : assert(content != null || message != null, 'Either content or message must be provided');

  @override
  Widget build(BuildContext context) {
    // Determine Actions
    List<Widget> dialogActions = actions ?? [];
    
    // If no custom actions provided, check for standard buttons
    if (dialogActions.isEmpty) {
      if (onConfirm != null || onCancel != null) {
        // Standard Confirm/Cancel Layout
        dialogActions = [
          if (onCancel != null)
            BoxyArtButton(
              title: cancelText,
              onTap: onCancel,
              isGhost: true,
            ),
          if (onConfirm != null)
            BoxyArtButton(
              title: confirmText,
              onTap: onConfirm,
              isPrimary: true,
            ),
        ];
      } else {
        // Default Close Button
        dialogActions = [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ];
      }
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Adjusted padding for buttons
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: content ?? (message != null ? Text(
        message!,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ) : null),
      actions: dialogActions,
    );
  }
}

/// Helper function to show a standardized BoxyArt dialog.
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
    builder: (context) => BoxyArtDialog(
      title: title,
      message: message,
      content: content,
      actions: actions,
      onConfirm: onConfirm,
      confirmText: confirmText,
      onCancel: onCancel,
      cancelText: cancelText,
    ),
  );
}
