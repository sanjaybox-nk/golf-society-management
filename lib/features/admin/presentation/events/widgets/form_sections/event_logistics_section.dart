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
                const SizedBox(height: AppSpacing.cardToLabel),
                if (state.eventType == EventType.golf) ...[
                  BoxyArtSwitchField(
                    label: 'Multi-Day Event', 
                    value: state.isMultiDay, 
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateMultiDay(v),
                  ),
                ],
                if (state.isMultiDay) ...[
                  const SizedBox(height: AppSpacing.lg),
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
                const SizedBox(height: AppSpacing.cardToLabel),
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
                if (state.eventType == EventType.golf) ...[
                  const BoxyArtDivider(),
                  // Tee Time Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tee time',
                                style: AppTypography.label.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'First group departure',
                                style: TextStyle(fontSize: AppTypography.sizeCaption, color: AppColors.dark500),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: state.selectedTime,
                            );
                            if (picked != null) {
                              ref.read(eventFormNotifierProvider.notifier).updateTime(picked, isTeeOff: true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.dark100,
                              borderRadius: AppShapes.pill,
                            ),
                            child: Text(
                              state.selectedTime.format(context),
                              style: AppTypography.displayMedium.copyWith(
                                fontSize: AppTypography.sizeBody,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: AppTypography.weightExtraBold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const BoxyArtDivider(),
                  // Tee Interval Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tee interval',
                                style: AppTypography.label.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Minutes between groups',
                                style: TextStyle(fontSize: AppTypography.sizeCaption, color: AppColors.dark500),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 24),
                              onPressed: () => ref.read(eventFormNotifierProvider.notifier).updateTeeOffInterval((state.teeOffInterval - 1).clamp(5, 20)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: AppColors.dark100,
                                borderRadius: AppShapes.pill,
                              ),
                              child: Text(
                                '${state.teeOffInterval}m',
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: AppTypography.sizeBody,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: AppTypography.weightExtraBold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
                              onPressed: () => ref.read(eventFormNotifierProvider.notifier).updateTeeOffInterval((state.teeOffInterval + 1).clamp(5, 20)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtSwitchField(
                    label: 'Invitational / Non-Scoring',
                    subtitle: "Exclude this event's scores from all season leaderboards.",
                    value: state.isInvitational,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateIsInvitational(v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtSwitchField(
                    label: 'Enable Guest Entry',
                    subtitle: "Allow members to register guests for this event.",
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
