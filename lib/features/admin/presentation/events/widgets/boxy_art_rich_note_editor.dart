import 'package:golf_society/design_system/design_system.dart';

class RichNoteController {
  final TextEditingController titleController;
  final TextEditingController contentController;
  String? imageUrl;

  RichNoteController({
    String? title,
    String? content,
    this.imageUrl,
  })  : titleController = TextEditingController(text: title),
        contentController = TextEditingController(text: content ?? '');

  void dispose() {
    titleController.dispose();
    contentController.dispose();
  }
}

class BoxyArtRichNoteEditor extends StatelessWidget {
  final RichNoteController controller;
  final VoidCallback onRemove;

  const BoxyArtRichNoteEditor({
    super.key,
    required this.controller,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BoxyArtFormField(
                  label: 'Note Title',
                  controller: controller.titleController,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 16),
          BoxyArtFormField(
            label: 'Note Content',
            controller: controller.contentController,
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}
