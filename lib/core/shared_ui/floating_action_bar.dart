import 'package:flutter/material.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/contrast_helper.dart';

/// A premium floating action bar for Save/Cancel actions in edit modes.
/// 
/// Features:
/// - "True Floating" pill design (detached from edges)
/// - 50/50 width split between Cancel and Save buttons
/// - Brand yellow "Save" button
/// - Dark grey "Cancel" button
class BoxyArtFloatingActionBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String? cancelLabel;
  final String? saveLabel;
  final bool isLoading;
  final bool isVisible;

  const BoxyArtFloatingActionBar({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.cancelLabel,
    this.saveLabel,
    this.isLoading = false,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppShadows.floatingAlt,
      ),
      child: Row(
        children: [
          // Cancel Button (50%)
          Expanded(
            child: TextButton(
              onPressed: isLoading ? null : onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const StadiumBorder(),
              ),
              child: Text(
                cancelLabel ?? 'Cancel',
                style: TextStyle(
                  color: isLoading ? Colors.grey[400] : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Save Button (50%)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppShadows.primaryButtonGlow,
              ),
              child: Builder(
                builder: (context) {
                  final backgroundColor = Theme.of(context).primaryColor;
                  final textColor = ContrastHelper.getContrastingText(backgroundColor);
                  
                  return ElevatedButton(
                    onPressed: isLoading ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: textColor,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size(double.infinity, 56),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.2,
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(textColor),
                            ),
                          )
                        : Text(saveLabel ?? 'Save'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
