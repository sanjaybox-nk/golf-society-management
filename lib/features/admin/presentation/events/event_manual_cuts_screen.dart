import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';

class EventManualCutsScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventManualCutsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventManualCutsScreen> createState() => _EventManualCutsScreenState();
}

class _EventManualCutsScreenState extends ConsumerState<EventManualCutsScreen> {
  final Map<String, double> _localCuts = {};
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _save(GolfEvent event) async {
    setState(() => _isSaving = true);
    try {
      var updatedEvent = event.copyWith(manualCuts: _localCuts);
      
      // If grouping exists, we should recalculate the snapshotted PHCs
      final groupingData = updatedEvent.grouping['groups'] as List?;
      if (groupingData != null && groupingData.isNotEmpty) {
        final members = await ref.read(allMembersProvider.future);
        final config = ref.read(themeControllerProvider);
        
        final updatedGrouping = GroupingService.recalculateGroupHandicaps(
          event: updatedEvent,
          members: members,
          useWhs: config.useWhsHandicaps,
        );
        
        updatedEvent = updatedEvent.copyWith(grouping: updatedGrouping);
      }

      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manual cuts updated and PHCs recalculated')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final membersAsync = ref.watch(allMembersProvider);

    return eventAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (event) {

        // Initialize local state once
        if (_localCuts.isEmpty && event.manualCuts.isNotEmpty) {
          _localCuts.addAll(event.manualCuts);
        }

        // Filter participants who are actually golfing
        final participants = event.registrations.where((r) => r.attendingGolf).toList();

        return HeadlessScaffold(
          title: 'Manual Cuts',
          subtitle: event.title,
          showBack: true,
          onBack: () => context.pop(),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              IconButton(
                icon: const Icon(Icons.check_rounded),
                onPressed: () => _save(event),
              ),
          ],
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Search Bar
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                    child: BoxyArtInputField(
                      label: 'FIND PARTICIPANT',
                      hint: 'Search by name...',
                      controller: _searchController,
                      prefixIcon: const Icon(Icons.search_rounded),
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    ),
                  ),

                  // 2. Info Text
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                    child: Text(
                      'Assign individual shot adjustments for this specific event. Negative values act as a handicap cut.',
                      style: AppTypography.caption.copyWith(color: AppColors.dark300, fontStyle: FontStyle.italic),
                    ),
                  ),

                  // 3. Participant List
                  ...participants.where((p) => p.memberName.toLowerCase().contains(_searchQuery)).map((reg) {
                    final member = membersAsync.whenOrNull(data: (list) => list.where((m) => m.id == reg.memberId).firstOrNull);
                    final controller = _controllers.putIfAbsent(
                      reg.memberId,
                      () => TextEditingController(text: _localCuts[reg.memberId]?.toString() ?? '0.0'),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: BoxyArtCard(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            BoxyArtAvatar(
                              initials: reg.memberName.isNotEmpty ? reg.memberName.substring(0, 1).toUpperCase() : '?',
                              url: member?.avatarUrl,
                              radius: 22,
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reg.memberName.toUpperCase(),
                                    style: AppTypography.label.copyWith(fontSize: AppTypography.sizeButton),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'INDEX: ${member?.handicap ?? "N/A"}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.dark300,
                                      fontWeight: AppTypography.weightSemibold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            // Refined numeric input container
                            Container(
                              width: 90,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacitySubtle),
                                borderRadius: AppShapes.sm,
                              ),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: controller,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody),
                                decoration: InputDecoration(
                                  isDense: true,
                                  suffixText: 'pt',
                                  suffixStyle: AppTypography.caption.copyWith(fontWeight: AppTypography.weightBlack, color: AppColors.dark300),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                  border: InputBorder.none,
                                ),
                                onChanged: (val) {
                                  final d = double.tryParse(val);
                                  if (d != null) {
                                    _localCuts[reg.memberId] = d;
                                  } else if (val.isEmpty) {
                                    _localCuts.remove(reg.memberId);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.x4l),
                  BoxyArtButton(
                    title: 'SAVE ADJUSTMENTS',
                    isLoading: _isSaving,
                    onTap: () => _save(event),
                    fullWidth: true,
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}
