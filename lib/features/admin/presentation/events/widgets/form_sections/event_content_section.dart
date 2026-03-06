import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';
import 'package:golf_society/features/admin/presentation/events/widgets/boxy_art_rich_note_editor.dart';

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
          const SizedBox(height: AppTheme.sectionSpacing),
          BoxyArtCard(
            child: Column(
              children: [
                ...state.facilities.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    final list = List<String>.from(state.facilities)..add('');
                    ref.read(eventFormNotifierProvider.notifier).updateFacilities(list);
                  },
                  icon: const Icon(Icons.add, color: Colors.grey, size: 18),
                  label: const Text('Add Facility', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'Notes & Content'),
          const SizedBox(height: AppTheme.sectionSpacing),
          ...state.notes.asMap().entries.map((entry) {
             return BoxyArtRichNoteEditor(
               controller: RichNoteController(
                 title: entry.value.title,
                 content: entry.value.content,
                 imageUrl: entry.value.imageUrl,
               ),
               onRemove: () {
                 final list = List<EventNote>.from(state.notes)..removeAt(entry.key);
                 ref.read(eventFormNotifierProvider.notifier).updateNotes(list);
               },
             );
          }),
          const SizedBox(height: 16),
          BoxyArtButton(
            title: 'ADD NOTE',
            onTap: () {
              final list = List<EventNote>.from(state.notes)..add(const EventNote(content: ''));
              ref.read(eventFormNotifierProvider.notifier).updateNotes(list);
            },
            isGhost: true,
          ),
          const SizedBox(height: 48),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
