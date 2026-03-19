import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';

class EventLogisticsSection extends ConsumerWidget {
  

  const EventLogisticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    
    return stateAsync.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'DateTime & Registration'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: Column(
              children: [
                BoxyArtDatePickerField(
                  label: state.isMultiDay ? 'START DATE' : 'DATE',
                  value: DateFormat.yMMMd().format(state.selectedDate),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      ref.read(eventFormNotifierProvider.notifier).updateDate(picked);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.cardToLabel),
                if (state.eventType == EventType.golf) ...[
                  BoxyArtSwitchField(
                    label: 'Multi-Day Event', 
                    value: state.isMultiDay, 
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateMultiDay(v),
                  ),
                ],
                if (state.isMultiDay) ...[
                  const SizedBox(height: AppSpacing.cardToLabel),
                   BoxyArtDatePickerField(
                    label: 'END DATE',
                    value: state.endDate != null ? DateFormat.yMMMd().format(state.endDate!) : 'Select End Date',
                    onTap: () async {
                        final picked = await showDatePicker(
                          context: context, 
                          initialDate: state.endDate ?? state.selectedDate, 
                          firstDate: state.selectedDate, 
                          lastDate: DateTime(2030)
                        );
                        if (picked != null) {
                          ref.read(eventFormNotifierProvider.notifier).updateEndDate(picked);
                        }
                    },
                  ),
                ],
                BoxyArtDatePickerField(
                  label: 'REGISTRATION',
                  value: state.registrationTime.format(context),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: state.registrationTime,
                    );
                    if (picked != null) {
                      ref.read(eventFormNotifierProvider.notifier).updateTime(picked, isTeeOff: false);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.cardToLabel),
                BoxyArtDatePickerField(
                  label: 'REGISTRATION DEADLINE',
                  value: (state.deadlineDate == null || state.deadlineTime == null) 
                      ? 'No deadline set' 
                      : '${DateFormat.yMMMd().format(state.deadlineDate!)} @ ${state.deadlineTime!.format(context)}',
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: state.deadlineDate ?? state.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      if (!context.mounted) return;
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: state.deadlineTime ?? const TimeOfDay(hour: 17, minute: 0),
                      );
                      if (pickedTime != null) {
                        ref.read(eventFormNotifierProvider.notifier).updateDeadline(pickedDate, pickedTime);
                      }
                    }
                  },
                ),
                if (state.eventType == EventType.golf) ...[
                  const SizedBox(height: AppSpacing.x2l),
                  BoxyArtSwitchField(
                    label: 'Invitational / Non-Scoring',
                    subtitle: "Exclude this event's scores from all season leaderboards.",
                    value: state.isInvitational,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateIsInvitational(v),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
