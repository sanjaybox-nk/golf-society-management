import 'package:golf_society/domain/models/golf_event.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';

class EventBasicInfoSection extends ConsumerWidget {
  

  const EventBasicInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    
    return stateAsync.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Event Type'),
          const SizedBox(height: AppSpacing.sm),
          ModernUnderlinedFilterBar<EventType>(
            selectedValue: state.eventType,
            onTabSelected: (type) => ref.read(eventFormNotifierProvider.notifier).updateEventType(type),
            isExpanded: true,
            tabs: const [
              ModernFilterTab(label: 'GOLF', value: EventType.golf, icon: Icons.sports_golf_rounded),
              ModernFilterTab(label: 'SOCIAL', value: EventType.social, icon: Icons.celebration_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.x2l),
          const BoxyArtSectionTitle(title: 'Basic Info'),
          BoxyArtCard(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => ref.read(eventFormNotifierProvider.notifier).pickImage(),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle) 
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: AppShapes.lg,
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
                      ),
                    ),
                    child: state.imageUrl != null 
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: AppShapes.lg,
                                child: state.imageUrl!.startsWith('http') 
                                    ? Image.network(state.imageUrl!, width: double.infinity, height: 160, fit: BoxFit.cover)
                                    : Image.file(File(state.imageUrl!), width: double.infinity, height: 160, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: AppSpacing.sm,
                                right: AppSpacing.sm,
                                child: Row(
                                  children: [
                                    BoxyArtGlassIconButton(
                                      icon: Icons.edit_rounded,
                                      iconSize: 18,
                                      onPressed: () => ref.read(eventFormNotifierProvider.notifier).pickImage(),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    BoxyArtGlassIconButton(
                                      icon: Icons.delete_outline_rounded,
                                      iconSize: 18,
                                      onPressed: () => ref.read(eventFormNotifierProvider.notifier).updateImageUrl(null),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: AppShapes.iconXl, color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityHalf)),
                              const SizedBox(height: AppSpacing.sm),
                              const Text('Add Event Photo', style: TextStyle(fontSize: AppTypography.sizeLabelStrong, fontWeight: AppTypography.weightBold)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x2l),
                BoxyArtFormField(
                  label: 'Event Title',
                  initialValue: state.title,
                  onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateTitle(v),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.x2l),
                BoxyArtFormField(
                  label: 'Description',
                  initialValue: state.description,
                  onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateDescription(v),
                  maxLines: null,
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
