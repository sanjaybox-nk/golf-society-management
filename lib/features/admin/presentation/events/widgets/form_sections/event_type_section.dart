import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';

class EventTypeSection extends ConsumerWidget {
  final bool isPeeking;

  const EventTypeSection({super.key, this.isPeeking = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    
    return stateAsync.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernUnderlinedFilterBar<EventType>(
            selectedValue: state.eventType,
            onTabSelected: (type) => ref.read(eventFormNotifierProvider.notifier).updateEventType(type),
            isExpanded: true,
            tabs: const [
              ModernFilterTab(label: 'Golf', value: EventType.golf),
              ModernFilterTab(label: 'Social', value: EventType.social),
            ],
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
