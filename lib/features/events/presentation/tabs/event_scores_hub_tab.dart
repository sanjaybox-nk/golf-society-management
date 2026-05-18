import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/utils/date_utils.dart' as utils;
import '../events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../logic/event_scoring_controller.dart';
import '../state/marker_selection_provider.dart';
import '../widgets/event_scorecard_view.dart';
import '../widgets/marker_selection_sheet.dart';
import '../../../matchplay/presentation/widgets/match_play_bracket_hub.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import 'event_tabs_state.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/vertical_hole_scoring_list.dart';
import 'package:golf_society/utils/guest_id_helper.dart';
import 'package:golf_society/features/events/logic/scoring/scoring_utils.dart';
import 'package:golf_society/features/home/presentation/home_providers.dart';
import 'package:golf_society/domain/models/notification.dart';

/// Resolved state needed to decide whether to show the pinned scoring keypad,
/// and which scorecard to target. Extracted from _buildPinnedScoring to keep
/// the build method free of provider fan-out and status resolution logic.
class PinnedScoringState {
  const PinnedScoringState({
    required this.effectiveEntryId,
    required this.userScorecard,
    required this.myCard,
    required this.shouldShow,
  });
  final String effectiveEntryId;
  final Scorecard? userScorecard;
  final Scorecard? myCard;
  final bool shouldShow;
}

final pinnedScoringStateProvider = Provider.autoDispose.family<PinnedScoringState, ({String eventId, GolfEvent event})>((ref, args) {
  final currentUser = ref.watch(effectiveUserProvider);
  final markerSelection = ref.watch(markerSelectionProvider);
  final isSelfMarking = markerSelection.isSelfMarking;
  final targetEntryId = markerSelection.targetEntryIds.firstOrNull;
  final effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);

  final allScorecards = ref.watch(scorecardsListProvider(args.eventId)).asData?.value ?? [];
  final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
  final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);

  final isSameDayOrPast = utils.DateUtils.isSameDayOrPastEvent(args.event);
  final isLocked = args.event.isScoringLocked == true;
  final isCompleted = args.event.status == EventStatus.completed;
  final shouldShow = isSameDayOrPast || isCompleted || isLocked;

  return PinnedScoringState(
    effectiveEntryId: effectiveEntryId,
    userScorecard: userScorecard,
    myCard: myCard,
    shouldShow: shouldShow,
  );
});

class EventScoresUserTab extends ConsumerStatefulWidget {
  final String eventId;
  final bool isAdminMode;
  final int initialTab;
  const EventScoresUserTab({super.key, required this.eventId, this.isAdminMode = false, this.initialTab = 0});

  @override
  ConsumerState<EventScoresUserTab> createState() => _EventScoresUserTabState();
}

class _EventScoresUserTabState extends ConsumerState<EventScoresUserTab> {
  Map<int, int>? _optimisticScores;
  final bool _optimisticIsVerifier = false;
  MarkerTab _selectedMarkerTab = MarkerTab.player;
  String? _switchedCardId;
  final PageController _holeController = PageController();
  int _currentHole = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(eventScoringTabProvider.notifier).set(widget.initialTab);
      });
    }
  }

  @override
  void dispose() {
    _holeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final compAsync = ref.watch(competitionDetailProvider(widget.eventId));
    final scoringData = ref.watch(eventScoringControllerProvider(widget.eventId));

    return eventAsync.when(
      data: (event) {
        return compAsync.when(
          data: (comp) {
            final effectiveRules = comp?.rules ?? const CompetitionRules();

            final currentUser = ref.watch(effectiveUserProvider);
            final markerSelection = ref.watch(markerSelectionProvider);
            final bool isSelfMarking = markerSelection.isSelfMarking;
            final String? targetEntryId = markerSelection.targetEntryIds.firstOrNull;

            // [NEW] Default to SCORE (verifier) tab when self-marking
            if (isSelfMarking && _selectedMarkerTab == MarkerTab.player) {
              _selectedMarkerTab = MarkerTab.verifier;
            }
            String effectiveEntryId = isSelfMarking ? currentUser.id : (targetEntryId ?? currentUser.id);

            if (effectiveRules.isUnifiedTeamFormat) {
               final groupData = event.grouping['groups'] as List?;
               final myGroup = groupData?.firstWhereOrNull((g) => (g['players'] as List).any((p) => p['registrationMemberId'] == currentUser.id));
               if (myGroup != null) {
                  final players = myGroup['players'] as List;
                  final teamSize = effectiveRules.teamSize;
                  int playerIdx = players.indexWhere((p) => p['registrationMemberId'] == currentUser.id);
                  int teamIdx = playerIdx ~/ teamSize;
                  
                  final teamPlayers = players.skip(teamIdx * teamSize).take(teamSize).toList();
                  effectiveEntryId = teamPlayers.first['registrationMemberId'];
               }
            }

            // Check if the current user is an active participant in this event's grouping
            final groupData = event.grouping['groups'] as List? ?? [];
            final bool isParticipant = groupData.any((g) =>
              (g['players'] as List? ?? []).any((p) {
                final map = Map<String, dynamic>.from(p as Map);
                return GuestIdHelper.resolveEffectiveId(map) == currentUser.id ||
                    map['registrationMemberId'] == currentUser.id;
              }),
            );

            final allScorecards = ref.watch(scorecardsListProvider(widget.eventId)).asData?.value ?? [];
            final userScorecard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId);
            
            String? headerBadgeText;
            Color? headerBadgeColor;

            final effectiveStatus = event.status;
            final bool isLocked = event.isScoringLocked == true ||
                userScorecard?.status == ScorecardStatus.approved;
            final bool isCompleted = effectiveStatus == EventStatus.completed;

            final isSameDayOrPast = utils.DateUtils.isSameDayOrPastEvent(event);

            final bool isScoringActive = !isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));
            // Card is "full" if the player entered all holes OR the marker has — either is enough to trigger verification
            final bool isCardFull = userScorecard != null && (
              (userScorecard.holeScores.length == 18 && userScorecard.holeScores.every((s) => s != null && s > 0)) ||
              (userScorecard.playerVerifierScores.length == 18 && userScorecard.playerVerifierScores.every((s) => s != null && s > 0))
            );

            if (userScorecard?.status == ScorecardStatus.approved) {
              // ── Stage 5: Admin verified ───────────────────────────────────
              headerBadgeText = "Verified";
              headerBadgeColor = AppColors.lime500;
            } else if (userScorecard?.status == ScorecardStatus.finalScore ||
                userScorecard?.status == ScorecardStatus.reviewed) {
              // ── Stage 4: Both signed, in admin queue ──────────────────────
              headerBadgeText = "Submitted";
              headerBadgeColor = AppColors.amber500;
            } else if (userScorecard != null) {
              // ── Sign-off states — checked before global lock so sign-off
              // remains available even after admin locks score entry ──────────
              if (userScorecard.conflictedHoles.isNotEmpty) {
                headerBadgeText = "Conflict";
                headerBadgeColor = AppColors.coral500;
              } else if (userScorecard.verifiedByMarker && !userScorecard.verifiedByPlayer) {
                // ── Stage 3a: Marker confirmed — player needs to submit ────
                headerBadgeText = "Marker Verified";
                headerBadgeColor = AppColors.amber500;
              } else if (userScorecard.verifiedByPlayer && !userScorecard.verifiedByMarker) {
                // ── Stage 3b: Player signed — waiting for marker ──────────
                headerBadgeText = "Awaiting Marker";
                headerBadgeColor = AppColors.dark300;
              } else if (isCardFull) {
                // ── Stage 2: All 18 done — waiting for marker to confirm ──
                headerBadgeText = "Verify Score";
                headerBadgeColor = AppColors.dark300;
              } else if (event.isScoringLocked == true || isCompleted) {
                // Global lock — score entry closed, nothing to sign yet
                headerBadgeText = "Locked";
                headerBadgeColor = AppColors.dark300;
              } else if (!isScoringActive) {
                headerBadgeText = "Not Active";
                headerBadgeColor = AppColors.dark300;
              } else {
                // ── Stage 1: Round in progress ───────────────────────────
                headerBadgeText = "In Play";
                headerBadgeColor = AppColors.dark300;
              }
            } else {
              headerBadgeText = "In Play";
              headerBadgeColor = AppColors.dark300;
            }

            final isStaff = currentUser.role != MemberRole.member;
            final selectedScoringTab = ref.watch(eventScoringTabProvider);

            // Pinned bottom — hole nav arrows on Scoring tab only (participants only)
            Widget? pinnedBottom;
            if (selectedScoringTab == 0 && isParticipant) {
              Widget arrowBtn(IconData icon, bool enabled, VoidCallback action) {
                return GestureDetector(
                  onTap: enabled ? () {
                    if (_holeController.hasClients) action();
                  } : null,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44, height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: enabled ? AppColors.dark50 : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: enabled ? AppColors.dark100 : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: enabled ? [BoxShadow(
                        color: AppColors.dark950.withValues(alpha: 0.03),
                        blurRadius: 4, offset: const Offset(0, 2),
                      )] : null,
                    ),
                    child: Icon(icon, size: 16,
                      color: enabled ? AppColors.dark950 : AppColors.dark200),
                  ),
                );
              }
              pinnedBottom = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  arrowBtn(Icons.arrow_back_ios_new_rounded, _currentHole > 0,
                    () => _holeController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
                  arrowBtn(Icons.arrow_forward_ios_rounded, _currentHole < 17,
                    () => _holeController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
                ],
              );
            }

            // Scorecard tab picker — lets the marker flip to the card they are marking.
            // MKR comparison row only renders on the current user's own card (enforced
            // in EventScorecardView), so Ashley's view remains a clean read-only grid.
            Widget? personPicker;
            if (selectedScoringTab == 1 && isParticipant) {
              final officialTargetScorecard = allScorecards.firstWhereOrNull(
                (s) => s.markerId == currentUser.id,
              );
              final officialTargetEntryId = officialTargetScorecard?.entryId;
              // Guest proxy cards — this member is the assigned score entrant
              final guestProxyCards = allScorecards.where((s) =>
                  s.guestInputAssigneeId == currentUser.id &&
                  s.entryId.endsWith('_guest') &&
                  s.status != ScorecardStatus.finalScore &&
                  s.status != ScorecardStatus.approved).toList();

              final hasTabs = (officialTargetEntryId != null && officialTargetEntryId != currentUser.id) ||
                  guestProxyCards.isNotEmpty;

              if (hasTabs) {
                final selectedId = _switchedCardId ?? currentUser.id;
                final tabs = <ModernFilterTab<String>>[
                  const ModernFilterTab<String>(label: 'Me', value: ''),
                  if (officialTargetEntryId != null && officialTargetEntryId != currentUser.id)
                    ModernFilterTab<String>(
                      label: _resolveFirstName(officialTargetEntryId, event, full: false),
                      value: officialTargetEntryId,
                    ),
                  for (final g in guestProxyCards)
                    if (g.entryId != officialTargetEntryId)
                      ModernFilterTab<String>(
                        label: _resolveFirstName(g.entryId, event, full: false),
                        value: g.entryId,
                      ),
                ];
                personPicker = BoxyArtTabBar<String>(
                  tabs: tabs,
                  selectedValue: selectedId == currentUser.id ? '' : selectedId,
                  onTabSelected: (val) => setState(() =>
                      _switchedCardId = val.isEmpty ? null : val),
                );
                pinnedBottom = BoxyArtCard(
                  padding: const EdgeInsets.all(AppSpacing.atomic),
                  child: personPicker,
                );
              }
            }

            return HeadlessScaffold(
              title: effectiveRules.isUnifiedTeamFormat ? 'Team Scorecard' : 'My Card',
              subtitle: event.title,
              showAdminShortcut: false,
              showBack: true,
              onBack: () => context.go('/events'),
              actions: [
                if (event.matches.isNotEmpty)
                  BoxyArtGlassIconButton(
                    icon: Icons.account_tree_rounded,
                    tooltip: 'Match Bracket',
                    onPressed: () => _showMatchBracket(event),
                  ),
                if (widget.isAdminMode && isStaff)
                  BoxyArtGlassIconButton(
                    icon: Icons.edit_rounded,
                    tooltip: 'Manage Scores',
                    onPressed: () => context.push('/admin/events/manage/${event.id}/event/scores'),
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: BoxyArtPill.status(
                      label: headerBadgeText,
                      color: headerBadgeColor,
                      hasHorizontalMargin: false,
                      isLegend: true,
                      isAction: false,
                    ),
                  ),
                ),
              ],
              pinnedBottom: pinnedBottom,
              pinnedBottomPadding: AppSpacing.standard,
              slivers: [
                if (!isParticipant) ...[
                  // Non-participant observer — scoring not available
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.section, AppSpacing.xl, 0),
                    sliver: SliverToBoxAdapter(
                      child: BoxyArtEmptyCard(
                        icon: Icons.golf_course_rounded,
                        title: 'Not registered',
                        message: 'You are not entered in this event. You can follow live scores in the Scores and Stats tabs.',
                      ),
                    ),
                  ),
                ] else ...[
                  // Tab bar pinned below the header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.atomic, AppSpacing.xl, AppSpacing.standard,
                      ),
                      child: BoxyArtTabBar<int>(
                        tabs: const [
                          ModernFilterTab(label: 'Scorecard', value: 1),
                          ModernFilterTab(label: 'Scoring', value: 0),
                        ],
                        selectedValue: selectedScoringTab,
                        onTabSelected: (val) => ref.read(eventScoringTabProvider.notifier).set(val),
                      ),
                    ),
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    sliver: SliverToBoxAdapter(
                      child: selectedScoringTab == 0
                          ? VerticalHoleScoringList(
                              key: ValueKey('scoring_${event.id}_${currentUser.id}'),
                              event: event,
                              scoringData: scoringData,
                              pageController: _holeController,
                              onHoleChanged: (page) => setState(() => _currentHole = page),
                              onMarkerSelectionTap: () => MarkerSelectionSheet.show(context: context, event: event),
                              onProxyRecordComplete: () {
                                ref.read(eventScoringTabProvider.notifier).set(1);
                              },
                            )
                          : _buildScoringContent(event, comp, effectiveRules, scoringData, _switchedCardId),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.pageBottom)),
              ],
            );
          },
          loading: () => HeadlessScaffold(
            title: event.title,
            subtitle: 'Loading Scores...',
            showBack: true,
            onBack: () => context.go('/events'),
            slivers: const [
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (err, stack) => HeadlessScaffold(
            title: event.title,
            subtitle: 'Scores Error',
            showBack: true,
            onBack: () => context.go('/events'),
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyCard(
                  title: 'Could not load scoring data',
                  message: err.toString(),
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Loading Event...',
        slivers: [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (err, stack) => HeadlessScaffold(
        title: 'Event Error',
        showBack: true,
        onBack: () => context.go('/events'),
        slivers: [
          SliverFillRemaining(
            child: BoxyArtEmptyCard(
              title: 'Could not load event',
              message: err.toString(),
              icon: Icons.error_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildScoringContent(GolfEvent event, Competition? comp, CompetitionRules effectiveRules, ProcessedEventData? scoringData, String? switchedCardId) {
    final currentUser = ref.read(effectiveUserProvider);
    final allScorecards = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];
    final isOwnCard = switchedCardId == null || switchedCardId == currentUser.id;

    Widget? actionButton;

    if (isOwnCard) {
      // Own card: show verify button (disabled until marker confirms)
      final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);
      final isCardFull = myCard != null &&
          myCard.holeScores.length == 18 &&
          myCard.holeScores.every((s) => s != null && s > 0);


      if (isCardFull && !myCard.verifiedByPlayer) {
        final markerIsGuest = myCard.markerId?.endsWith('_guest') == true;
        final markerConfirmed = myCard.verifiedByMarker;
        final hasConflicts = myCard.conflictedHoles.isNotEmpty;

        Widget child;
        if (hasConflicts) {
          child = BoxyArtCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: AppShapes.iconSmall),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score conflict — cannot submit',
                        style: AppTypography.label.copyWith(
                          fontWeight: AppTypography.weightBold,
                          color: AppColors.coral500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Speak to your marker to resolve the discrepancy on hole${myCard.conflictedHoles.length > 1 ? 's' : ''} ${myCard.conflictedHoles.join(', ')} before submitting.',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (markerConfirmed) {
          child = BoxyArtButton(
            title: 'Verify Score',
            isPrimary: true,
            fullWidth: true,
            icon: Icons.task_alt_rounded,
            onTap: () => _showPlayerVerifySheet(event, myCard),
          );
        } else {
          String awaitingTitle;
          String awaitingBody;
          if (markerIsGuest) {
            final guestCard = allScorecards.firstWhereOrNull((s) => s.entryId == myCard.markerId);
            final assigneeId = guestCard?.guestInputAssigneeId;
            final assigneeName = assigneeId != null
                ? _resolveFirstName(assigneeId, event, full: false)
                : 'The captain';
            final guestName = _resolveFirstName(myCard.markerId!, event, full: true);
            awaitingTitle = 'Awaiting $assigneeName\'s verification';
            awaitingBody = '$assigneeName needs to verify your marked scores from $guestName\'s paper card before you can submit.';
          } else {
            awaitingTitle = 'Awaiting marker confirmation';
            awaitingBody = 'Your marker needs to confirm your scores before you can submit.';
          }
          child = BoxyArtCard(
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: AppColors.dark300, size: AppShapes.iconSmall),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(awaitingTitle,
                          style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold)),
                      const SizedBox(height: 2),
                      Text(awaitingBody, style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        actionButton = Padding(
          padding: const EdgeInsets.only(top: AppSpacing.cardToCard),
          child: child,
        );
      }
    } else {
      final targetCard = allScorecards.firstWhereOrNull((s) => s.entryId == switchedCardId);
      final isGuestCard = switchedCardId.endsWith('_guest');
      final playerName = _resolveFirstName(switchedCardId, event, full: false);

      if (isGuestCard && targetCard != null) {
        final markerScoresFull = targetCard.playerVerifierScores.length == 18 &&
            targetCard.playerVerifierScores.every((s) => s != null && s > 0);
        final confirmed = targetCard.holeScores.length == 18 &&
            targetCard.holeScores.every((s) => s != null && s > 0);
        final isAssignee = targetCard.guestInputAssigneeId == currentUser.id;
        final markedCard = allScorecards.firstWhereOrNull((s) => s.markerId == targetCard.entryId);
        final markerRecordFull = markedCard != null &&
            markedCard.playerVerifierScores.length == 18 &&
            markedCard.playerVerifierScores.every((s) => s != null && s > 0);
        final markedName = markedCard != null
            ? _resolveFirstName(markedCard.entryId, event, full: false)
            : null;
        final recordConflicts = markedCard?.conflictedHoles.isNotEmpty == true;

        Widget? stepCard;
        String? stepLabel;

        if (targetCard.status == ScorecardStatus.finalScore ||
            targetCard.status == ScorecardStatus.approved) {
          // Done — no action needed
        } else if (!markerScoresFull) {
          final markerName = targetCard.markerId != null
              ? _resolveFirstName(targetCard.markerId!.replaceAll('_guest', ''), event, full: false)
              : 'the marker';
          stepCard = BoxyArtCard(
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: AppColors.dark300, size: AppShapes.iconSmall),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Waiting for $markerName to complete scoring',
                          style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold)),
                      const SizedBox(height: 2),
                      Text('$markerName must enter all 18 scores before you can verify.',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (!confirmed && isAssignee) {
          stepLabel = markedCard != null ? 'STEP 1 OF 3' : 'STEP 1 OF 2';
          stepCard = BoxyArtButton(
            title: 'Verify $playerName\'s Scores',
            isPrimary: true,
            fullWidth: true,
            icon: Icons.fact_check_rounded,
            onTap: () => _showGuestVerifyFlow(event, targetCard),
          );
        } else if (confirmed && markedCard != null && !markerRecordFull && isAssignee) {
          stepLabel = 'STEP 2 OF 3';
          stepCard = BoxyArtButton(
            title: 'Enter $playerName\'s Record for $markedName',
            isPrimary: true,
            fullWidth: true,
            icon: Icons.edit_note_rounded,
            onTap: () => _openGuestMarkingEntry(event, markedCard),
          );
        } else if (recordConflicts) {
          stepCard = BoxyArtCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: AppShapes.iconSmall),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Score conflict on $markedName\'s card',
                          style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold, color: AppColors.coral500)),
                      const SizedBox(height: 2),
                      Text(
                        'Hole${markedCard!.conflictedHoles.length > 1 ? 's' : ''} ${markedCard.conflictedHoles.join(', ')} — speak to $playerName to agree the correct score.',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (confirmed && (markedCard == null || markerRecordFull) && isAssignee) {
          stepLabel = markedCard != null ? 'STEP 3 OF 3' : 'STEP 2 OF 2';
          stepCard = BoxyArtButton(
            title: 'Submit $playerName\'s Card',
            isPrimary: true,
            fullWidth: true,
            icon: Icons.how_to_reg_rounded,
            onTap: () => _submitGuestCard(event, switchedCardId, targetCard),
          );
        }

        if (stepCard != null) {
          final spacingTokens = Theme.of(context).extension<AppSpacingTokens>();
          actionButton = Padding(
            padding: EdgeInsets.only(
              top: stepLabel != null
                  ? (spacingTokens?.cardToLabel ?? AppSpacing.atomic)
                  : AppSpacing.cardToCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stepLabel != null) ...[
                  Text(
                    stepLabel,
                    style: AppTypography.micro.copyWith(
                      fontWeight: AppTypography.weightHeavy,
                      letterSpacing: AppTypography.lsLabel,
                      color: AppColors.dark400,
                    ),
                  ),
                  SizedBox(height: spacingTokens?.labelToCard ?? AppSpacing.atomic),
                ],
                stepCard,
              ],
            ),
          );
        }
      } else {
        // Member card
        final isCardFull = targetCard != null &&
            targetCard.holeScores.length == 18 &&
            targetCard.holeScores.every((s) => s != null && s > 0);
        if (isCardFull && !targetCard.verifiedByMarker) {
          if (targetCard.conflictedHoles.isNotEmpty) {
            actionButton = Padding(
              padding: const EdgeInsets.only(top: AppSpacing.cardToCard),
              child: BoxyArtCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: AppShapes.iconSmall),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Score conflict — cannot confirm',
                              style: AppTypography.label.copyWith(
                                  fontWeight: AppTypography.weightBold, color: AppColors.coral500)),
                          const SizedBox(height: 2),
                          Text(
                            'You and $playerName disagree on hole${targetCard.conflictedHoles.length > 1 ? 's' : ''} ${targetCard.conflictedHoles.join(', ')}. Agree on the correct score before confirming.',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            actionButton = Padding(
              padding: const EdgeInsets.only(top: AppSpacing.cardToCard),
              child: BoxyArtButton(
                title: 'Confirm $playerName\'s Scores',
                isPrimary: true,
                fullWidth: true,
                icon: Icons.how_to_reg_rounded,
                onTap: () => _showMarkerConfirmSheet(event, switchedCardId),
              ),
            );
          }
        }
      }
    }

    return Column(
      children: [
        EventScorecardView(
          event: event,
          comp: comp,
          scoringData: scoringData,
          effectiveRules: effectiveRules,
          optimisticScores: _optimisticScores,
          optimisticIsVerifier: _optimisticIsVerifier,
          selectedMarkerTab: _selectedMarkerTab,
          onMarkerSelectionTap: () => MarkerSelectionSheet.show(context: context, event: event),
          onSyncFromPartner: (card) => _copyScoresFromPartner(card),
          switchedCardId: switchedCardId,
        ),
        ?actionButton,
      ],
    );
  }

  void _openGuestMarkingEntry(GolfEvent event, Scorecard markedCard) {
    ref.read(markerSelectionProvider.notifier).ensureTarget(markedCard.entryId);
    ref.read(eventScoringTabProvider.notifier).set(0);
  }

  // Player confirms their own card (after marker has confirmed first)
  void _showPlayerVerifySheet(GolfEvent event, Scorecard card) {
    final currentUser = ref.read(effectiveUserProvider);
    final markerIsGuest = card.markerId?.endsWith('_guest') == true;
    final markerName = card.markerId != null ? _resolveFirstName(card.markerId!, event, full: true) : 'my marker';
    final declaration = markerIsGuest
        ? 'I confirm that the scores on my card are correct to the best of my knowledge. '
          'Note: my scores were recorded by $markerName, a guest, on a paper card.'
        : 'I confirm that the scores on my card are correct to the best of my knowledge.';
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Submit Your Card',
      child: _SignOffSheet(
        declaration: declaration,
        buttonLabel: 'Submit Card',
        onConfirm: () async {
          Navigator.of(context).pop();
          await _performSignOff(event: event, entryId: currentUser.id, isPlayerRole: true);
        },
      ),
    );
  }

  // Marker confirms scores they recorded for a player
  void _showMarkerConfirmSheet(GolfEvent event, String targetEntryId) {
    final playerName = _resolveFirstName(targetEntryId, event, full: true);
    final targetIsGuest = targetEntryId.endsWith('_guest');
    final declaration = targetIsGuest
        ? 'I confirm that the scores I recorded for $playerName (guest) are correct to the best of my knowledge. '
          'The player\'s card was completed on a paper card.'
        : 'I confirm that the scores I recorded for $playerName are correct to the best of my knowledge.';
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Confirm Scores',
      child: _SignOffSheet(
        declaration: declaration,
        buttonLabel: 'Confirm Scores',
        onConfirm: () async {
          Navigator.of(context).pop();
          await _performSignOff(event: event, entryId: targetEntryId, isPlayerRole: false);
        },
      ),
    );
  }

  // Shared sign-off logic — handles notifications, conflict detection, finalScore advance
  Future<void> _performSignOff({
    required GolfEvent event,
    required String entryId,
    required bool isPlayerRole,
  }) async {
    try {
      final repo = ref.read(scorecardRepositoryProvider);
      final allCards = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];
      final targetCard = allCards.firstWhereOrNull((s) => s.entryId == entryId);
      if (targetCard == null) return;

      final currentUser = ref.read(effectiveUserProvider);
      final now = DateTime.now();
      final flagged = isPlayerRole
          ? targetCard.copyWith(verifiedByPlayer: true, playerVerifiedAt: now, updatedAt: now)
          : targetCard.copyWith(verifiedByMarker: true, markerVerifiedAt: now, updatedAt: now);
      await repo.updateScorecard(flagged);

      // Marker confirmed → notify player it's their turn
      if (!isPlayerRole) {
        await _sendVerificationNotification(
          recipientId: entryId.replaceAll('_guest', ''),
          title: 'Marker Verified',
          message: '${_resolveFirstName(currentUser.id, event, full: true)} has confirmed your scores — please review and submit your card.',
          eventId: event.id,
          actionUrl: '/events/${event.id}/live',
        );
      }

      // Check for both signed → advance status
      final finalCard = ScoringUtils.validateAndFinalizeHandshake(
        targetScorecard: flagged,
        verifierScorecard: flagged,
      );
      if (finalCard.status != flagged.status) {
        await repo.updateScorecard(finalCard);
      } else if (flagged.verifiedByPlayer && flagged.verifiedByMarker) {
        // Both signed but conflict exists
        final conflictHoles = flagged.conflictedHoles;
        if (conflictHoles.isNotEmpty) {
          final holeList = conflictHoles.map((h) => 'hole $h').join(', ');
          final playerName = _resolveFirstName(entryId, event, full: true);
          await _sendVerificationNotification(
            recipientId: entryId.replaceAll('_guest', ''),
            title: 'Score Conflict — Action Required',
            message: 'Conflict on $holeList — speak to your marker before leaving the course.',
            eventId: event.id,
          );
          final markerId = targetCard.markerId?.replaceAll('_guest', '');
          if (markerId != null && markerId.isNotEmpty) {
            await _sendVerificationNotification(
              recipientId: markerId,
              title: 'Score Conflict — Action Required',
              message: 'Conflict on $holeList for $playerName — speak to the player.',
              eventId: event.id,
            );
          }
          final adminIds = ref.read(allMembersProvider).value
              ?.where((m) => m.role == MemberRole.admin || m.role == MemberRole.superAdmin)
              .map((m) => m.id) ?? [];
          for (final adminId in adminIds) {
            await _sendVerificationNotification(
              recipientId: adminId,
              title: 'Score Conflict Needs Resolution',
              message: '$playerName has conflicts on $holeList',
              eventId: event.id,
            );
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Score conflict on $holeList — both parties notified'),
              backgroundColor: AppColors.coral500,
            ));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-off failed: $e'), backgroundColor: AppColors.coral500),
        );
      }
    }
  }

  Future<void> _sendVerificationNotification({
    required String recipientId,
    required String title,
    required String message,
    required String eventId,
    String? actionUrl,
  }) async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      await repo.sendNotification(AppNotification(
        id: '',
        recipientId: recipientId,
        title: title,
        message: message,
        timestamp: DateTime.now(),
        category: 'Scoring',
        eventId: eventId,
        actionUrl: actionUrl,
      ));
    } catch (_) {
      // Notifications are best-effort — don't block the sign-off flow
    }
  }

  String _resolveFirstName(String entryId, GolfEvent event, {bool full = false}) {
    final groups = event.grouping['groups'] as List? ?? [];
    for (final group in groups) {
      for (final p in (group['players'] as List? ?? [])) {
        final map = Map<String, dynamic>.from(p as Map);
        if (GuestIdHelper.resolveEffectiveId(map) == entryId) {
          final name = (map['name'] as String?) ?? entryId;
          return full ? name : name.split(' ').first;
        }
      }
    }
    return entryId;
  }

  void _showGuestVerifyFlow(GolfEvent event, Scorecard guestCard) async {
    try {
      // Silently confirm — copy marker's entered scores to the guest's STR row
      final repo = ref.read(scorecardRepositoryProvider);
      await repo.updateScorecard(guestCard.copyWith(
        holeScores: guestCard.playerVerifierScores,
        conflictedHoles: [],
        verifiedByMarker: true,
        updatedAt: DateTime.now(),
      ));
      if (!mounted) return;
      // Add Carol (the person Isla marked) to scoring targets so her card
      // appears below Isla's locked card in the Scoring tab
      final allCards = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];
      final markedCard = allCards.firstWhereOrNull((s) => s.markerId == guestCard.entryId);
      if (markedCard != null) {
        ref.read(markerSelectionProvider.notifier).ensureTarget(markedCard.entryId);
      }
      ref.read(eventScoringTabProvider.notifier).set(0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm scores — check your connection.')),
        );
      }
    }
  }


  Future<void> _submitGuestCard(GolfEvent event, String guestEntryId, Scorecard card) async {
    final playerName = _resolveFirstName(guestEntryId, event, full: false);
    try {
      final repo = ref.read(scorecardRepositoryProvider);
      await repo.updateScorecard(card.copyWith(
        status: ScorecardStatus.finalScore,
        verifiedByPlayer: true,
        verifiedByMarker: true,
        playerVerifiedAt: DateTime.now(),
        markerVerifiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$playerName\'s card submitted'),
          backgroundColor: AppColors.lime500,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: AppColors.coral500),
        );
      }
    }
  }

  void _showMatchBracket(GolfEvent event) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Match Bracket',
      child: MatchPlayBracketHub(eventId: event.id),
    );
  }


  Future<void> _copyScoresFromPartner(Scorecard partnerCard) async {
    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Sync Scores?',
      message: 'This will copy all scores from your partner to your scorecard. Any existing scores on your card will be overwritten.',
      confirmText: 'Sync',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirmed == true && mounted) {
      try {
        final repo = ref.read(scorecardRepositoryProvider);
        final currentUser = ref.read(effectiveUserProvider);
        
        final myCard = ref.read(scorecardsListProvider(widget.eventId)).asData?.value
            .firstWhereOrNull((s) => s.entryId == currentUser.id);

        if (myCard == null) {
           final newCard = Scorecard(
              id: '', 
              competitionId: widget.eventId,
              roundId: 'round_1',
              entryId: currentUser.id,
              submittedByUserId: currentUser.id,
              holeScores: List.from(partnerCard.holeScores),
              status: ScorecardStatus.draft,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
           );
           await repo.addScorecard(newCard);
        } else {
           final updated = myCard.copyWith(
              holeScores: List.from(partnerCard.holeScores),
              updatedAt: DateTime.now(),
           );
           await repo.updateScorecard(updated);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scores synced successfully!'), backgroundColor: AppColors.lime500),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error syncing scores: $e')),
          );
        }
      }
    }
  }

}

// ---------------------------------------------------------------------------
// Simple sign-off declaration sheet
// ---------------------------------------------------------------------------

class _SignOffSheet extends StatefulWidget {
  final String declaration;
  final String buttonLabel;
  final Future<void> Function() onConfirm;

  const _SignOffSheet({
    required this.declaration,
    required this.buttonLabel,
    required this.onConfirm,
  });

  @override
  State<_SignOffSheet> createState() => _SignOffSheetState();
}

class _SignOffSheetState extends State<_SignOffSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BoxyArtCard(
          child: Text(
            widget.declaration,
            style: AppTypography.body.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.standard),
        BoxyArtButton(
          title: _loading ? 'Submitting…' : widget.buttonLabel,
          isPrimary: true,
          fullWidth: true,
          onTap: _loading ? null : () async {
            setState(() => _loading = true);
            await widget.onConfirm();
          },
        ),
        const SizedBox(height: AppSpacing.section),
      ],
    );
  }
}
