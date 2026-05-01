import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import '../state/marker_selection_provider.dart';

class MarkerSelectionSheet extends ConsumerStatefulWidget {
  final GolfEvent event;
  final List<Map<String, dynamic>> groupPlayers;

  const MarkerSelectionSheet({
    super.key,
    required this.event,
    required this.groupPlayers,
  });

  static void show({
    required BuildContext context,
    required GolfEvent event,
  }) {
    final groupData = event.grouping['groups'] as List?;
    if (groupData == null) return;

    // Logic to find current user's group
    final currentUser = ProviderScope.containerOf(context).read(effectiveUserProvider);
    List<Map<String, dynamic>> groupPlayersRaw = [];
    for (var g in groupData) {
      final players = (g['players'] as List?) ?? [];
      final hasMe = players.any((p) {
        final pid = p['id'] ?? p['registrationMemberId'];
        return pid == currentUser.id;
      });
      
      if (hasMe) {
        groupPlayersRaw = List<Map<String, dynamic>>.from(players);
        break;
      }
    }

    BoxyArtBottomSheet.showPersistent(
      context: context,
      title: 'Marker & Tee Selection'.toUpperCase(),
      child: MarkerSelectionSheet(event: event, groupPlayers: groupPlayersRaw),
    );
  }

  @override
  ConsumerState<MarkerSelectionSheet> createState() => _MarkerSelectionSheetState();
}

class _MarkerSelectionSheetState extends ConsumerState<MarkerSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(effectiveUserProvider);
    final members = ref.watch(allMembersProvider).value ?? [];
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final String? targetEntryId = markerSelection.targetEntryId;
    final tees = widget.event.courseConfig.tees;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Text(
                'Select Player To Mark'.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                  fontWeight: AppTypography.weightHeavy,
                  letterSpacing: AppTypography.lsLabel,
                ),
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: BoxyArtCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: (() {
                final otherPlayers = widget.groupPlayers.where((p) {
                  final pid = p['id'] ?? p['registrationMemberId'];
                  final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                  return id != currentUser.id;
                }).toList();

                final String currentUserDefaultTee = (currentUser.gender?.toLowerCase() == 'female')
                    ? (widget.event.selectedFemaleTeeName ?? 'Red')
                    : (widget.event.selectedTeeName ?? 'Yellow');

                return [
                  _buildSelectionRow(
                    context, 
                    ref,
                    isSelected: isSelfMarking,
                    name: 'Myself (Me)',
                    entryId: currentUser.id,
                    tees: tees,
                    overrides: markerSelection.teeOverrides,
                    onSelect: () {
                      ref.read(markerSelectionProvider.notifier).selectSelf();
                    },
                    defaultTeeName: currentUserDefaultTee,
                    showDivider: otherPlayers.isNotEmpty,
                  ),
                  
                  ...otherPlayers.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final p = entry.value;
                    final pid = p['id'] ?? p['registrationMemberId'];
                    final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                    final name = p['name'] ?? 'Unknown';
                    final isSelected = !isSelfMarking && targetEntryId == id;

                    // Resolve player-specific default tee based on gender
                    final memberProfile = members.firstWhereOrNull((m) => m.id == pid);
                    final String playerDefaultTee = (memberProfile?.gender?.toLowerCase() == 'female')
                        ? (widget.event.selectedFemaleTeeName ?? 'Red')
                        : (widget.event.selectedTeeName ?? 'Yellow');
                     
                    return _buildSelectionRow(
                      context,
                      ref,
                      isSelected: isSelected,
                      name: name,
                      entryId: id ?? '',
                      tees: tees,
                      overrides: markerSelection.teeOverrides,
                      onSelect: () {
                        if (id != null) {
                          ref.read(markerSelectionProvider.notifier).selectTarget(id);
                        }
                      },
                      defaultTeeName: playerDefaultTee,
                      showDivider: idx < otherPlayers.length - 1,
                    );
                  }),
                ];
              })(),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSelectionRow(
    BuildContext context, 
    WidgetRef ref, {
    required bool isSelected,
    required String name,
    required String entryId,
    required List<dynamic> tees,
    required Map<String, String> overrides,
    required VoidCallback onSelect,
    required String defaultTeeName,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: onSelect,
                  borderRadius: AppShapes.md,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppSpacing.xl,
                          height: AppSpacing.xl,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onSurface 
                                  : AppColors.dark400,
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: isSelected 
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              fontSize: AppTypography.sizeBodySmall,
                              fontWeight: isSelected ? AppTypography.weightHeavy : AppTypography.weightSemibold,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onSurface 
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 1,
                child: _buildTeeDropdown(context, ref, entryId, tees, overrides, defaultTeeName),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1, 
            color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
      ],
    );
  }

  Widget _buildTeeDropdown(BuildContext context, WidgetRef ref, String entryId, List<dynamic> tees, Map<String, String> overrides, String defaultTeeName) {
     final String? persistedTee = overrides[entryId];
     String? currentTeeValue = persistedTee;
     if (currentTeeValue != null && currentTeeValue.toLowerCase().trim() == defaultTeeName.toLowerCase().trim()) {
       currentTeeValue = null;
     }
     
     return Container(
       height: 36,
       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
       decoration: BoxDecoration(
         color: Colors.transparent,
         borderRadius: AppShapes.sm,
         border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
       ),
       child: DropdownButtonHideUnderline(
         child: DropdownButton<String?>(
           value: currentTeeValue,
           isExpanded: true,
           icon: const Icon(Icons.arrow_drop_down, size: AppShapes.iconMd),
           onChanged: (String? newValue) {
             if (newValue == null) {
               ref.read(markerSelectionProvider.notifier).clearManualTee(entryId);
             } else {
               ref.read(markerSelectionProvider.notifier).setManualTee(entryId, newValue);
             }
           },
           items: [
             DropdownMenuItem<String?>(
               value: null,
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                     Container(
                       width: 12, 
                       height: 12, 
                       decoration: BoxDecoration(
                         color: AppColors.getTeeColor(defaultTeeName, widget.event.courseConfig.tees), 
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.black12, width: 1.0),
                       ),
                     ),
                     const SizedBox(width: AppSpacing.sm),
                     Text('Auto ($defaultTeeName)', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              ...tees.map((tee) => DropdownMenuItem<String?>(
                value: tee.name,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12, 
                      height: 12, 
                      decoration: BoxDecoration(
                        color: AppColors.getTeeColor(tee.name, widget.event.courseConfig.tees), 
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1.0),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(tee.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
   }
}
