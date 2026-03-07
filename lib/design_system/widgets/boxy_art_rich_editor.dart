import 'package:flutter_quill/flutter_quill.dart';
import 'package:golf_society/design_system/design_system.dart';

class BoxyArtRichEditor extends StatelessWidget {
  final QuillController controller;
  final String placeholder;
  final double minHeight;
  final bool scrollable;

  const BoxyArtRichEditor({
    super.key,
    required this.controller,
    this.placeholder = 'Message content...',
    this.minHeight = 200,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Compact Toolbar
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.dark400.withValues(alpha: AppColors.opacityMuted) 
                : AppColors.textSecondary.withValues(alpha: AppColors.opacitySubtle),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rMd)),
          ),
          child: SizedBox(
            height: 48,
            child: QuillSimpleToolbar(
              controller: controller,
              config: QuillSimpleToolbarConfig(
                showDividers: true,
                showFontFamily: false,
                showFontSize: false,
                showBoldButton: true,
                showUnderLineButton: true,
                showStrikeThrough: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showAlignmentButtons: false,
                showLeftAlignment: false,
                showCenterAlignment: false,
                showRightAlignment: false,
                showJustifyAlignment: false,
                showDirection: false,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: true,
                showCodeBlock: false,
                showQuote: false,
                showIndent: false,
                showLink: false,
                buttonOptions: const QuillSimpleToolbarButtonOptions(
                  base: QuillToolbarBaseButtonOptions(
                    iconSize: 15,
                  ),
                  linkStyle: QuillToolbarLinkStyleButtonOptions(),
                ),
                showUndo: true,
                showRedo: true,
                showSubscript: false,
                showSuperscript: false,
                showSearchButton: false,
                multiRowsDisplay: false,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.link, size: 15),
                    tooltip: 'Insert Link',
                    onPressed: () => _showLinkDialog(context, controller),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: 1, color: AppColors.pureWhite.withValues(alpha: 0.10)),
        
        // Editor
        Container(
          constraints: BoxConstraints(minHeight: minHeight),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.dark300.withValues(alpha: AppColors.opacityMedium) 
                : AppColors.pureWhite.withValues(alpha: AppColors.opacityHalf),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppShapes.rMd)),
            border: Border.all(
              color: isDark ? AppColors.dark400 : AppColors.lightBorder,
              width: AppShapes.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              placeholder: placeholder,
              customStyles: DefaultStyles(
                placeHolder: DefaultTextBlockStyle(
                  AppTypography.body.copyWith(
                    color: isDark ? AppColors.dark400 : AppColors.dark300,
                  ),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  null,
                ),
              ),
              scrollable: scrollable,
              autoFocus: false,
              expands: false,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLinkDialog(BuildContext context, QuillController controller) async {
    final textController = TextEditingController();
    final linkController = TextEditingController();
    
    // Get current selection
    final selection = controller.selection;
    if (!selection.isCollapsed) {
      textController.text = controller.document.getPlainText(selection.start, selection.end - selection.start);
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => BoxyArtDialog(
        title: 'Insert Link',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BoxyArtTextField(
              controller: textController,
              label: 'Text',
              hintText: 'Display text',
            ),
            const SizedBox(height: AppSpacing.lg),
            BoxyArtTextField(
              controller: linkController,
              label: 'Link (URL)',
              hintText: 'e.g. google.com',
              autofocus: true,
            ),
          ],
        ),
        onConfirm: () {
          var link = linkController.text.trim();
          if (link.isNotEmpty) {
            // Forgiving URL validation
            if (!link.startsWith('http://') && !link.startsWith('https://') && !link.startsWith('mailto:')) {
              link = 'https://$link';
            }
            Navigator.pop(context, {
              'text': textController.text.trim().isEmpty ? link : textController.text.trim(),
              'link': link,
            });
          }
        },
        onCancel: () => Navigator.pop(context),
        confirmText: 'Ok',
      ),
    );

    if (result != null) {
      final text = result['text']!;
      final link = result['link']!;
      final index = selection.start;
      final length = selection.end - selection.start;
      
      // Replace existing selection or insert new text
      controller.replaceText(index, length, text, null);
      
      // Apply link attribute to the newly inserted/replaced text
      controller.formatText(index, text.length, LinkAttribute(link));
      
      // Move cursor after the inserted link
      controller.updateSelection(
        TextSelection.collapsed(offset: index + text.length),
        ChangeSource.local,
      );
    }
  }
}
