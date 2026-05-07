import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import '../state/marker_selection_provider.dart';
import 'package:golf_society/utils/guest_id_helper.dart';

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
      initialChildSize: 0.75,
      minChildSize: 0.55,
      maxChildSize: 0.92,
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
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final currentUser = ref.watch(effectiveUserProvider);
    final members = ref.watch(allMembersProvider).value ?? [];
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final isGroupScorer = markerSelection.isGroupScorer;
    final markerAssignments = markerSelection.markerAssignments;
    final tees = widget.event.courseConfig.tees;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          // Group Scorer Toggle
          BoxyArtCard(
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityLow),
            padding: EdgeInsets.zero,
            child: BoxyArtSwitchTile(
              icon: Icons.group_rounded,
              label: 'Mark Entire Group',
              subtitle: 'Allow score entry for everyone in your group',
              value: isGroupScorer,
              onChanged: (val) => ref.read(markerSelectionProvider.notifier).toggleGroupScorer(val),
            ),
          ),

          SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),

          Text(
            'SELECT PLAYER TO MARK',
            style: AppTypography.label.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
              fontWeight: AppTypography.weightHeavy,
              letterSpacing: AppTypography.lsLabel,
            ),
          ),

          SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),

          BoxyArtCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.atomic,
              horizontal: AppSpacing.standard,
            ),
            child: Column(
              children: (() {
                final otherPlayers = widget.groupPlayers.where((p) {
                  final id = GuestIdHelper.resolveEffectiveId(p);
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
                    context, ref,
                    shapes: shapes,
                    spacing: spacing,
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
                    final id = GuestIdHelper.resolveEffectiveId(p);
                    final name = p['name'] ?? 'Unknown';
                    final isSelected = markerSelection.targetEntryIds.contains(id);
                    final baseId = GuestIdHelper.stripGuestSuffix(id);
                    final memberProfile = members.firstWhereOrNull((m) => m.id == baseId);
                    final String playerDefaultTee = ScoringCalculator.resolvePlayerTee(
                      memberId: id,
                      event: widget.event,
                      membersList: members,
                      gender: memberProfile?.gender,
                    ).name;

                    return _buildSelectionRow(
                      context, ref,
                      shapes: shapes,
                      spacing: spacing,
                      isSelected: isSelected,
                      name: name,
                      entryId: id,
                      tees: tees,
                      overrides: markerSelection.teeOverrides,
                      onSelect: () {
                        if (id.isNotEmpty) {
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

          const SizedBox(height: AppSpacing.standard),
        ],
    );
  }

  Widget _buildSelectionRow(
    BuildContext context,
    WidgetRef ref, {
    required AppShapeTokens? shapes,
    required AppSpacingTokens? spacing,
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
    final theme = Theme.of(context);
    final opacity = isTaken ? AppColors.opacitySecondary : 1.0;

    return Column(
      children: [
        Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.atomic),
            child: Row(
              children: [
                // Checkbox
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: isTaken ? null : onSelect,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.atomic),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: AppSpacing.standard,
                            height: AppSpacing.standard,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: shapes?.input,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : AppColors.dark400,
                                width: isSelected
                                    ? AppShapes.borderMedium
                                    : AppShapes.borderThin,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check, size: AppShapes.iconXs, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.atomic),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body.copyWith(
                                fontWeight: isSelected
                                    ? AppTypography.weightHeavy
                                    : AppTypography.weightRegular,
                                color: isSelected
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacityHigh),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.atomic),

                // Marker assignment icon
                SizedBox(
                  width: AppSpacing.section,
                  child: canBeMyMarker
                      ? GestureDetector(
                          onTap: isTaken
                              ? null
                              : () => ref
                                  .read(markerSelectionProvider.notifier)
                                  .setMyMarker(isMyMarker ? null : entryId),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: isMyMarker
                                  ? theme.colorScheme.primary.withValues(alpha: AppColors.opacitySubtle)
                                  : AppColors.dark100.withValues(alpha: AppColors.opacityHalf),
                              borderRadius: shapes?.input,
                            ),
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: AppShapes.iconSm,
                              color: isMyMarker
                                  ? theme.colorScheme.primary
                                  : AppColors.dark400,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(width: AppSpacing.atomic),

                // Tee dropdown
                Expanded(
                  flex: 1,
                  child: _buildTeeDropdown(context, ref, entryId, tees, overrides, defaultTeeName, shapes),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.dividerColor.withValues(alpha: AppColors.opacityLow),
            indent: AppSpacing.standard,
            endIndent: AppSpacing.standard,
          ),
      ],
    );
  }

  Widget _buildTeeDropdown(
    BuildContext context,
    WidgetRef ref,
    String entryId,
    List<dynamic> tees,
    Map<String, String> overrides,
    String defaultTeeName,
    AppShapeTokens? shapes,
  ) {
    final theme = Theme.of(context);
    final String? persistedTee = overrides[entryId];
    String? currentTeeValue = persistedTee;
    if (currentTeeValue != null &&
        currentTeeValue.toLowerCase().trim() == defaultTeeName.toLowerCase().trim()) {
      currentTeeValue = null;
    }

    return Container(
      height: AppSpacing.section,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.atomic),
      decoration: BoxDecoration(
        borderRadius: shapes?.input,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: AppColors.opacityMuted),
        ),
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
                    width: AppSpacing.atomic,
                    height: AppSpacing.atomic,
                    decoration: BoxDecoration(
                      color: AppColors.getTeeColor(defaultTeeName, widget.event.courseConfig.tees),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: AppColors.opacityLow),
                        width: AppShapes.borderThin,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.atomic),
                  Text(
                    'Auto ($defaultTeeName)',
                    style: AppTypography.micro,
                  ),
                ],
              ),
            ),
            ...tees.map((tee) => DropdownMenuItem<String?>(
              value: tee.name,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSpacing.atomic,
                    height: AppSpacing.atomic,
                    decoration: BoxDecoration(
                      color: AppColors.getTeeColor(tee.name, widget.event.courseConfig.tees),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: AppColors.opacityLow),
                        width: AppShapes.borderThin,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.atomic),
                  Text(tee.name, style: AppTypography.micro),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
