import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/domain/models/society_config.dart';

class EventManualCutsScreen extends ConsumerStatefulWidget {
  final String eventId;
  final bool useScaffold;
  const EventManualCutsScreen({
    super.key, 
    required this.eventId,
    this.useScaffold = true,
  });

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
        if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/admin/events');
        }
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
      loading: () => widget.useScaffold 
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const Center(child: CircularProgressIndicator()),
      error: (err, stack) => widget.useScaffold
          ? Scaffold(body: Center(child: Text('Error: $err')))
          : Center(child: Text('Error: $err')),
      data: (event) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Initialize local state once
        if (_localCuts.isEmpty && event.manualCuts.isNotEmpty) {
          _localCuts.addAll(event.manualCuts);
        }

        // Filter participants who are actually golfing
        final participants = event.registrations.where((r) => r.attendingGolf).toList();

        final config = ref.watch(themeControllerProvider);
        final isManualMode = config.societyCutMode == SocietyCutMode.manual;
        final spacing = Theme.of(context).extension<AppSpacingTokens>();

        return HeadlessScaffold(
          title: 'Manual Cuts',
          subtitle: event.title,
          topPill: BoxyArtPill.committee(label: 'ADMIN'),
          showBack: true,
          onBack: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/admin/events');
            }
          },

          actions: [
            const SizedBox(width: AppSpacing.md),
            if (isManualMode) ...[
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: BoxyArtGlassIconButton(
                    icon: Icons.check_rounded,
                    onPressed: () => _save(event),
                  ),
                ),
            ],
          ],
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.lg, 
                vertical: spacing?.cardVerticalPadding ?? AppSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!isManualMode) ...[
                    BoxyArtEmptyCard(
                      title: 'Manual Overrides Disabled',
                      message: 'This society is currently using ${config.societyCutMode.name.toUpperCase()} cuts. Individual event-level overrides are disabled.\n\nTo enable manual adjustments, change the cut mode to "Manual" in the Admin Console (Dashboard > Operations).',
                      icon: Icons.lock_person_outlined,
                    ),
                  ] else ...[
                    // 1. Search Bar (3.1 Style)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing?.cardToLabel ?? AppSpacing.x2l),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.dark600 : AppColors.lightHeader,
                          borderRadius: BorderRadius.circular(AppShapes.rLg),
                          border: Border.all(
                            color: isDark ? AppColors.dark500 : AppColors.lightBorder,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: AppTypography.body.copyWith(
                            color: isDark ? AppColors.dark60 : const Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by name...',
                            hintStyle: AppTypography.body.copyWith(
                              color: isDark ? AppColors.dark400 : AppColors.dark300,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: AppShapes.iconMd,
                              color: isDark ? AppColors.dark200 : AppColors.dark300,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                        ),
                      ),
                    ),

                    // 2. Info Text (3.1 subtext)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing?.cardToLabel ?? AppSpacing.x2l, left: AppSpacing.xs),
                      child: Text(
                        'Assign individual shot adjustments for this specific event. Negative values act as a handicap cut.',
                        style: AppTypography.subtext.copyWith(
                          color: isDark ? AppColors.dark300 : AppColors.dark400,
                          height: 1.4,
                        ),
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
                        child: BoxyArtMemberRow(
                          key: ValueKey('cut_${reg.memberId}'),
                          name: reg.memberName,
                          showChevron: false,
                          initials: reg.memberName.isNotEmpty ? reg.memberName.substring(0, 1).toUpperCase() : '?',
                          avatarUrl: member?.avatarUrl,
                          handicapIndex: member?.handicap,
                          isGuest: reg.isGuest,
                            trailing: SizedBox(
                            width: 110,
                            child: BoxyArtInputField(
                              label: '',
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              suffixText: 'pt',
                              textColor: isDark ? AppColors.pureWhite : AppColors.dark900,
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
                        ),
                      );
                  }),
                  const SizedBox(height: AppSpacing.x6l),
                ],
              ]),
              ),
            ),
          ],
        );
      },
    );
  }
}
