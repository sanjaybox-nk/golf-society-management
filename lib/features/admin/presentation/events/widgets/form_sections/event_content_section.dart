import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';

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
            child: BoxyArtFormColumn(
              children: [
                ...state.facilities.asMap().entries.map((entry) {
                  return BoxyArtFormField(
                    label: 'Facility ${entry.key + 1}',
                    initialValue: entry.value,
                    onChanged: (v) {
                      final list = List<String>.from(state.facilities);
                      list[entry.key] = v;
                      ref.read(eventFormNotifierProvider.notifier).updateFacilities(list);
                    },
                  );
                }),
              ],
            ),
          ),
          Builder(builder: (context) {
            final spacing = Theme.of(context).extension<AppSpacingTokens>();
            return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
          }),
          BoxyArtButton(
            title: 'Add facility',
            fullWidth: true,
            onTap: () => ref.read(eventFormNotifierProvider.notifier).addFacility(),
            isTinted: true,
            icon: Icons.add_circle_outline_rounded,
          ),
          const BoxyArtSectionTitle(title: 'Notes & Content', followsCard: true),
          ...state.notes.asMap().entries.map((entry) {
            final index = entry.key;
            final note = entry.value;
            return BoxyArtRichNoteEditor(
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
            );
          }),
          Builder(builder: (context) {
            final spacing = Theme.of(context).extension<AppSpacingTokens>();
            return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
          }),
          BoxyArtButton(
            title: 'Add note',
            fullWidth: true,
            onTap: () => ref.read(eventFormNotifierProvider.notifier).addNote(),
            isTinted: true,
            icon: Icons.add_circle_outline_rounded,
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
