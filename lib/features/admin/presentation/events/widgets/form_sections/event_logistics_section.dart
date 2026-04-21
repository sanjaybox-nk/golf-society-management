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
    final theme = Theme.of(context);
    
    return stateAsync.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'DateTime & Registration', followsCard: true),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                // Date Selection
                BoxyArtDatePickerField(
                  label: state.isMultiDay ? 'Start date' : 'Date',
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
                
                // Multi-Day Settings
                if (state.eventType == EventType.golf) ...[
                  BoxyArtSwitchField(
                    label: 'Multi-Day Event', 
                    value: state.isMultiDay, 
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateMultiDay(v),
                  ),
                  if (state.isMultiDay) ...[
                    BoxyArtDatePickerField(
                      label: 'End date',
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
                ],

                // Registration Settings
                BoxyArtDatePickerField(
                  label: state.eventType == EventType.social ? 'Event time' : 'Registration time',
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
                BoxyArtDatePickerField(
                  label: 'Registration deadline',
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

                // Golf-specific Logistics (Standardized Fields)
                if (state.eventType == EventType.golf) ...[
                  // Standard Field: First Tee Off
                  BoxyArtDatePickerField(
                    label: 'First Tee Off',
                    value: state.selectedTime.format(context),
                    icon: Icons.access_time_rounded,
                    iconColor: theme.primaryColor,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: state.selectedTime,
                      );
                      if (picked != null) {
                        ref.read(eventFormNotifierProvider.notifier).updateTime(picked, isTeeOff: true);
                      }
                    },
                  ),
                  
                  // Standard Field: Tee Interval
                  BoxyArtFormField(
                    label: 'Tee Interval',
                    initialValue: state.teeOffInterval.toString(),
                    keyboardType: TextInputType.number,
                    suffixText: 'mins',
                    onChanged: (v) {
                      final val = int.tryParse(v);
                      if (val != null) {
                        ref.read(eventFormNotifierProvider.notifier).updateTeeOffInterval(val.clamp(5, 20));
                      }
                    },
                  ),

                  BoxyArtSwitchField(
                    label: 'Invitational / Non-Scoring',
                    subtitle: "Exclude this event's scores from leaderboards.",
                    value: state.isInvitational,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateIsInvitational(v),
                  ),
                  BoxyArtSwitchField(
                    label: 'Enable Guest Entry',
                    subtitle: "Allow members to register guests.",
                    value: state.allowGuests,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateAllowGuests(v),
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
