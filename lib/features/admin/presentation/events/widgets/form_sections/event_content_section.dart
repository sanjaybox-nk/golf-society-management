import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';
import 'package:golf_society/design_system/widgets/boxy_art_rich_note_editor.dart';

class EventContentSection extends ConsumerWidget {
  

  const EventContentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    
    return stateAsync.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Facilities'),
          BoxyArtCard(
            child: Column(
              children: [
                ...state.facilities.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.cardToLabel),
                    child: BoxyArtFormField(
                      label: 'Facility ${entry.key + 1}',
                      initialValue: entry.value,
                      onChanged: (v) {
                        final list = List<String>.from(state.facilities);
                        list[entry.key] = v;
                        ref.read(eventFormNotifierProvider.notifier).updateFacilities(list);
                      },
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
                BoxyArtButton(
                  title: 'Add facility',
                  onTap: () => ref.read(eventFormNotifierProvider.notifier).addFacility(),
                  isGhost: true,
                  icon: Icons.add_circle_outline_rounded,
                ),
              ],
            ),
          ),
          const BoxyArtSectionTitle(title: 'Notes & Content', followsCard: true),
          ...state.notes.asMap().entries.map((entry) {
             final index = entry.key;
             final note = entry.value;
             return Padding(
               padding: const EdgeInsets.only(bottom: AppSpacing.cardToLabel),
               child: BoxyArtRichNoteEditor(
                 key: ValueKey('note_$index'),
                 initialTitle: note.title,
                 initialContent: note.content,
                 initialImageUrl: note.imageUrl,
                 onChanged: (title, content, imageUrl) {
                   final list = List<EventNote>.from(state.notes);
                   list[index] = note.copyWith(title: title, content: content, imageUrl: imageUrl);
                   ref.read(eventFormNotifierProvider.notifier).updateNotes(list);
                 },
                 onRemove: () {
                   final list = List<EventNote>.from(state.notes)..removeAt(index);
                   ref.read(eventFormNotifierProvider.notifier).updateNotes(list);
                 },
               ),
             );
          }),
          const SizedBox(height: AppSpacing.cardToLabel),
          BoxyArtButton(
            title: 'Add note',
            onTap: () => ref.read(eventFormNotifierProvider.notifier).addNote(),
            isGhost: true,
            icon: Icons.add_circle_outline_rounded,
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
