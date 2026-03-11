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
          const SizedBox(height: AppTheme.sectionSpacing),
          BoxyArtCard(
            child: Column(
              children: [
                ...state.facilities.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
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
                TextButton.icon(
                  onPressed: () {
                    final list = List<String>.from(state.facilities)..add('');
                    ref.read(eventFormNotifierProvider.notifier).updateFacilities(list);
                  },
                  icon: const Icon(Icons.add, color: AppColors.textSecondary, size: AppShapes.iconSm),
                  label: const Text('Add Facility', style: TextStyle(color: AppColors.textSecondary, fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLabelStrong)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),
          const BoxyArtSectionTitle(title: 'Notes & Content'),
          const SizedBox(height: AppTheme.sectionSpacing),
          ...state.notes.asMap().entries.map((entry) {
             final index = entry.key;
             final note = entry.value;
             return Padding(
               padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
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
          const SizedBox(height: AppSpacing.x2l),
          BoxyArtButton(
            title: 'ADD NOTE',
            onTap: () {
              final list = List<EventNote>.from(state.notes)..add(const EventNote(content: ''));
              ref.read(eventFormNotifierProvider.notifier).updateNotes(list);
            },
            isGhost: true,
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
