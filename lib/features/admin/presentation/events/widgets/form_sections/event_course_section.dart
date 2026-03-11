import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';

class EventCourseSection extends ConsumerWidget {
  

  const EventCourseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    final societyConfig = ref.watch(themeControllerProvider);
    final currency = societyConfig.currencySymbol;

    return stateAsync.when(
      data: (state) {
        if (state.eventType != EventType.golf) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'Course Selection'),
            const SizedBox(height: AppTheme.sectionSpacing),
            BoxyArtCard(
              child: Column(
                children: [
                  // Course Lookup
                  Consumer(
                    builder: (context, ref, child) {
                      final coursesAsync = ref.watch(coursesProvider);
                      return coursesAsync.when(
                        data: (allCourses) => Autocomplete<Course>(
                          initialValue: TextEditingValue(text: state.courseName),
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) return const Iterable<Course>.empty();
                            final query = textEditingValue.text.toLowerCase();
                            return allCourses.where((c) => 
                              c.name.toLowerCase().contains(query) || 
                              c.address.toLowerCase().contains(query)
                            );
                          },
                          displayStringForOption: (c) => c.name,
                          onSelected: (c) => ref.read(eventFormNotifierProvider.notifier).updateCourse(c),
                          fieldViewBuilder: (context, controller, focus, onSubmitted) {
                            return BoxyArtFormField(
                              label: 'Course Name (Search)',
                              controller: controller,
                              focusNode: focus,
                              hintText: 'Type to search courses...',
                              prefixIcon: Icons.search,
                              onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateCourseNameManual(v),
                            );
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error loading courses: $e'),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  BoxyArtFormField(
                    label: 'Course Location (Auto-filled)',
                    initialValue: state.courseDetails,
                    readOnly: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  // Tee Selection (Simplified for now - can be expanded)
                  BoxyArtFormField(
                    label: 'Starting Tee (Manual)',
                    initialValue: state.selectedTeeName,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateSelectedTeeName(v),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  BoxyArtFormField(
                    label: 'Dress Code',
                    initialValue: state.dressCode,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateDressCode(v),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  Row(
                    children: [
                      Expanded(
                        child: BoxyArtFormField(
                          label: 'Available Buggies',
                          initialValue: state.availableBuggies?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateAvailableBuggies(int.tryParse(v)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: BoxyArtFormField(
                          label: 'Buggy Cost ($currency)',
                          initialValue: state.buggyCost?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateBuggyCost(double.tryParse(v)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  BoxyArtFormField(
                    label: 'Available Spaces',
                    initialValue: state.maxParticipants?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    hintText: 'Max players (multiples of 4)',
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateMaxParticipants(int.tryParse(v)),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final val = int.tryParse(v);
                      if (val == null) return 'Invalid number';
                      if (val % 4 != 0) return 'Must be a multiple of 4';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
