import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
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

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Marker & Tee Selection'.toUpperCase(),
      initialChildSize: 0.55,
      minChildSize: 0.45,
      addNavBarPadding: false,
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
    
    final isGroupScorer = markerSelection.isGroupScorer;
    final markerAssignments = markerSelection.markerAssignments;
    final tees = widget.event.courseConfig.tees;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group Scorer Toggle
          BoxyArtCard(
            backgroundColor: AppColors.lime500.withValues(alpha: 0.05),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark Entire Group'.toUpperCase(),
                        style: AppTypography.label.copyWith(
                          color: AppColors.dark950,
                          fontWeight: AppTypography.weightHeavy,
                        ),
                      ),
                      Text(
                        'Allow entry for everyone in your group',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.dark400,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isGroupScorer,
                  onChanged: (val) => ref.read(markerSelectionProvider.notifier).toggleGroupScorer(val),
                  activeColor: AppColors.lime500,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.cardToLabel),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
            child: Text(
              'Select Player To Mark'.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.labelToCard),

          BoxyArtCard(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, 
              horizontal: AppSpacing.standard,
            ),
            child: Column(
              children: (() {
                final otherPlayers = widget.groupPlayers.where((p) {
                  final pid = p['id'] ?? p['registrationMemberId'];
                  final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                  return id != currentUser.id;
                }).toList();

                final String currentUserDefaultTee = ScoringCalculator.resolvePlayerTee(
                  memberId: currentUser.id, 
                  event: widget.event, 
                  membersList: [...members, currentUser],
                  gender: currentUser.gender,
                ).name;

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
                      if (!isSelfMarking) {
                        ref.read(markerSelectionProvider.notifier).setSelfMarking(true);
                      }
                    },
                    defaultTeeName: currentUserDefaultTee,
                    canBeMyMarker: false,
                    showDivider: otherPlayers.isNotEmpty,
                  ),
                  
                  ...otherPlayers.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final p = entry.value;
                    final pid = p['id'] ?? p['registrationMemberId'];
                    final id = (p['isGuest'] == true || pid.toString().contains('_guest')) ? (pid.toString().contains('_guest') ? pid : '${pid}_guest') : pid;
                    final name = p['name'] ?? 'Unknown';
                    final isSelected = markerSelection.targetEntryIds.contains(id);

                    final memberProfile = members.firstWhereOrNull((m) => m.id == pid);
                    final String playerDefaultTee = ScoringCalculator.resolvePlayerTee(
                      memberId: id ?? '', 
                      event: widget.event, 
                      membersList: members,
                      gender: memberProfile?.gender,
                    ).name;
                     
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
                          ref.read(markerSelectionProvider.notifier).toggleTarget(id);
                        }
                      },
                      defaultTeeName: playerDefaultTee,
                      isMyMarker: markerSelection.myMarkerId == id,
                      canBeMyMarker: true,
                      isTaken: markerAssignments.entries.any((e) => e.key != currentUser.id && e.value == id),
                      showDivider: idx < otherPlayers.length - 1,
                    );
                  }),
                ];
              })(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BoxyArtButton(
              title: 'Confirm assignments'.toUpperCase(),
              onTap: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
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
    bool isMyMarker = false,
    bool canBeMyMarker = true,
    bool isTaken = false,
    bool showDivider = true,
  }) {
    final opacity = isTaken ? 0.4 : 1.0;
    
    return Column(
      children: [
        Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: isTaken ? null : onSelect,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: AppSpacing.xl,
                            height: AppSpacing.xl,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppShapes.rXs),
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : AppColors.dark400,
                                width: isSelected ? 2 : 1.5,
                              ),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
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
                SizedBox(
                  width: 28,
                  child: canBeMyMarker ? GestureDetector(
                    onTap: isTaken ? null : () => ref.read(markerSelectionProvider.notifier).setMyMarker(isMyMarker ? null : entryId),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isMyMarker ? AppColors.lime500 : AppColors.dark100.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppShapes.rXs),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_circle_outline_rounded : Icons.edit_note_rounded,
                        size: 18,
                        color: isMyMarker ? Colors.white : AppColors.dark400,
                      ),
                    ),
                  ) : const SizedBox.shrink(),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 1,
                  child: _buildTeeDropdown(context, ref, entryId, tees, overrides, defaultTeeName),
                ),
              ],
            ),
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
           isDense: true,
           menuMaxHeight: 200,
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
