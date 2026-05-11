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
import '../widgets/hole_by_hole_scoring_widget.dart';
import '../widgets/marker_selection_sheet.dart';
import '../widgets/scoring/scoring_verification_view.dart';
import '../../../matchplay/presentation/widgets/match_play_bracket_hub.dart';
import '../../../matchplay/domain/golf_event_match_extensions.dart';
import 'event_tabs_state.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/vertical_hole_scoring_list.dart';
import 'package:golf_society/utils/guest_id_helper.dart';
import 'package:golf_society/features/events/logic/scoring/scoring_utils.dart';
import 'package:golf_society/features/competitions/data/scorecard_repository.dart';
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
  const EventScoresUserTab({super.key, required this.eventId, this.isAdminMode = false});

  @override
  ConsumerState<EventScoresUserTab> createState() => _EventScoresUserTabState();
}

class _EventScoresUserTabState extends ConsumerState<EventScoresUserTab> {
  Map<int, int>? _optimisticScores;
  bool _optimisticIsVerifier = false;
  MarkerTab _selectedMarkerTab = MarkerTab.player;
  String? _switchedCardId;
  final PageController _holeController = PageController();
  int _currentHole = 0;

  @override
  void dispose() {
    _holeController.dispose();
    super.dispose();
  }

  String _resolvePlayerName(GolfEvent event, List<Member> members, String id) {
    final groups = event.grouping['groups'] as List? ?? [];
    for (final group in groups) {
      for (final p in (group['players'] as List? ?? [])) {
        final map = Map<String, dynamic>.from(p as Map);
        if (GuestIdHelper.resolveEffectiveId(map) == id) {
          final n = map['name'] as String?;
          if (n != null && n.isNotEmpty) return n;
        }
      }
    }
    final baseId = GuestIdHelper.stripGuestSuffix(id);
    return members.firstWhereOrNull((m) => m.id == baseId)?.displayName ?? id;
  }

  void _onScoresChanged(Map<int, int> scores, bool isVerifier) {
    setState(() {
      _optimisticScores = scores;
      _optimisticIsVerifier = isVerifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
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
            VoidCallback? headerOnBadgeTap;
            
            final effectiveStatus = event.status;
            final bool isLocked = event.isScoringLocked == true;
            final bool isCompleted = effectiveStatus == EventStatus.completed;
            
            final isSameDayOrPast = utils.DateUtils.isSameDayOrPastEvent(event);

            final bool isScoringActive = !isCompleted && ((effectiveStatus == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));
            // Card is "full" if the player entered all holes OR the marker has — either is enough to trigger verification
            final bool isCardFull = userScorecard != null && (
              (userScorecard.holeScores.length == 18 && userScorecard.holeScores.every((s) => s != null && s > 0)) ||
              (userScorecard.playerVerifierScores.length == 18 && userScorecard.playerVerifierScores.every((s) => s != null && s > 0))
            );

            if (isLocked || (userScorecard?.status == ScorecardStatus.finalScore)) {
              headerBadgeText = "Final Score";
              headerBadgeColor = AppColors.lime600;
            } else if (isCompleted) {
              headerBadgeText = null;
              headerBadgeColor = Colors.transparent;
            } else if (!isScoringActive) {
              headerBadgeText = "Not Active";
              headerBadgeColor = AppColors.dark300;
            } else if (userScorecard != null) {
              // Check for conflicts
              final officialMarkerCard = allScorecards.firstWhereOrNull((s) => s.entryId == effectiveEntryId && s.markerId != effectiveEntryId);
              bool hasConflict = false;
              if (officialMarkerCard != null) {
                for (int i = 0; i < 18; i++) {
                  final pS = userScorecard.holeScores.elementAtOrNull(i);
                  final mS = officialMarkerCard.holeScores.elementAtOrNull(i);
                  if (pS != null && mS != null && pS != mS) {
                    hasConflict = true;
                    break;
                  }
                }
              }

              if (hasConflict) {
                headerBadgeText = "Conflict";
                headerBadgeColor = AppColors.coral500;
              } else if (userScorecard.status == ScorecardStatus.draft && isCardFull) {
                headerBadgeText = "Verify Score";
                headerBadgeColor = AppColors.amber500;
                headerOnBadgeTap = () => _showVerificationSheet(event, userScorecard);
              } else {
                if (userScorecard.status == ScorecardStatus.submitted) {
                  headerBadgeText = "Submitted";
                  headerOnBadgeTap = () => _confirmUnsubmit(userScorecard.id);
                } else if (userScorecard.status == ScorecardStatus.reviewed) {
                  headerBadgeText = "Confirmed";
                } else {
                  headerBadgeText = "Scoring";
                }
                headerBadgeColor = _getStatusColor(userScorecard.status);
              }
            } else {
              headerBadgeText = "Active";
              headerBadgeColor = AppColors.lime400;
            }

            final isStaff = currentUser.role != MemberRole.member;
            final selectedScoringTab = ref.watch(eventScoringTabProvider);
            final allTargetIds = markerSelection.targetEntryIds.toList();
            final members = ref.watch(allMembersProvider).value ?? [];

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

            // Card switcher — pinned above nav bar on Scorecard tab
            Widget? personPicker;
            if (selectedScoringTab == 1 && allTargetIds.isNotEmpty) {
              final selectedId = _switchedCardId ?? currentUser.id;
              final pickerEntries = [
                ModernFilterTab<String>(label: 'Me', value: currentUser.id),
                ...allTargetIds.map((id) {
                  final label = _resolvePlayerName(event, members, id).split(' ').first;
                  return ModernFilterTab<String>(label: label, value: id);
                }),
              ];
              personPicker = BoxyArtTabBar<String>(
                tabs: pickerEntries,
                selectedValue: selectedId,
                onTabSelected: (id) => setState(() => _switchedCardId = id),
              );
              pinnedBottom = BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.atomic),
                child: personPicker,
              );
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
                    child: GestureDetector(
                      onTap: headerOnBadgeTap,
                      child: headerBadgeText == null
                        ? const SizedBox.shrink()
                        : BoxyArtPill.status(
                            label: headerBadgeText,
                            color: headerBadgeColor,
                            hasHorizontalMargin: false,
                            isLegend: headerOnBadgeTap == null,
                            isAction: headerOnBadgeTap != null,
                          ),
                    ),
                  ),
                ),
              ],
              pinnedBottom: pinnedBottom,
              pinnedBottomPadding: AppSpacing.section,
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
                          ModernFilterTab(label: 'Scoring', value: 0),
                          ModernFilterTab(label: 'Scorecard', value: 1),
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
                              onVerifyTap: (userScorecard != null && userScorecard.status == ScorecardStatus.draft && isCardFull)
                                  ? () => _showVerificationSheet(event, userScorecard)
                                  : null,
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
  
  Widget? _buildPinnedScoring(GolfEvent event, Competition? comp, ProcessedEventData? scoringData, CompetitionRules effectiveRules) {
    final pinState = ref.watch(pinnedScoringStateProvider((eventId: event.id, event: event)));
    if (!pinState.shouldShow) return null;

    return HoleByHoleScoringWidget(
      event: event,
      targetScorecard: pinState.userScorecard,
      verifierScorecard: pinState.myCard,
      targetEntryId: pinState.effectiveEntryId,
      isSelfMarking: ref.watch(markerSelectionProvider).isSelfMarking,
      selectedTab: _selectedMarkerTab,
      onTabChanged: (tab) {
        setState(() {
          _selectedMarkerTab = tab;
          _optimisticScores = null;
        });
      },
      onScoresChanged: _onScoresChanged,
    );
  }

  Widget _buildScoringContent(GolfEvent event, Competition? comp, CompetitionRules effectiveRules, ProcessedEventData? scoringData, String? switchedCardId) {
    return EventScorecardView(
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
    );
  }

  void _showVerificationSheet(GolfEvent event, Scorecard userScorecard) {
    final currentUser = ref.read(effectiveUserProvider);
    final allScorecards = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];

    // Build sign-off tasks for all cards the current user is responsible for

    // 1. My own card — sign as PLAYER
    final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);
    final tasks = <SignOffTask>[];

    if (myCard != null) {
      // Resolve marker's name for the player confirmation context
      String? markerName;
      if (myCard.markerId != null && myCard.markerId != currentUser.id) {
        markerName = _resolveFirstName(myCard.markerId!, event, full: true);
      }
      tasks.add(SignOffTask(
        entryId: currentUser.id,
        playerName: currentUser.displayName,
        isPlayerRole: true,
        markerName: markerName,
      ));
    }

    // 2. Cards where I am the marker — sign as MARKER for each
    final myMarkeeCards = allScorecards
        .where((s) => s.markerId == currentUser.id && s.entryId != currentUser.id)
        .toList();

    for (final card in myMarkeeCards) {
      final name = _resolveFirstName(card.entryId, event, full: true);
      tasks.add(SignOffTask(
        entryId: card.entryId,
        playerName: name,
        isPlayerRole: false,
      ));
    }

    if (tasks.isEmpty) return;

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Verify Scorecard',
      initialChildSize: tasks.length > 2 ? 0.75 : 0.55,
      child: ScoringVerificationView(
        event: event,
        tasks: tasks,
        onSignOff: (entryId, isPlayerRole) async {
          try {
            final repo = ref.read(scorecardRepositoryProvider);
            final allCards = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];
            final targetCard = allCards.firstWhereOrNull((s) => s.entryId == entryId);
            if (targetCard == null) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scorecard not found — try again')),
              );
              return;
            }

            final now = DateTime.now();
            final flagged = isPlayerRole
                ? targetCard.copyWith(verifiedByPlayer: true, playerVerifiedAt: now, updatedAt: now)
                : targetCard.copyWith(verifiedByMarker: true, markerVerifiedAt: now, updatedAt: now);
            await repo.updateScorecard(flagged);

            // Notify the counterpart that it's their turn
            final currentUser = ref.read(effectiveUserProvider);
            final counterpartId = isPlayerRole
                ? targetCard.markerId  // player signed → notify their marker
                : entryId;             // marker signed → notify the player
            if (counterpartId != null && counterpartId != currentUser.id) {
              final counterpartName = isPlayerRole
                  ? currentUser.displayName
                  : _resolveFirstName(currentUser.id, event, full: true);
              await _sendVerificationNotification(
                recipientId: counterpartId,
                title: 'Scorecard Verification',
                message: isPlayerRole
                    ? '$counterpartName has confirmed your scores — please sign off'
                    : '$counterpartName has confirmed the scores you recorded',
                eventId: event.id,
              );
            }

            // Auto-advance to finalScore when both parties have signed off
            final finalCard = ScoringUtils.validateAndFinalizeHandshake(
              targetScorecard: flagged,
              verifierScorecard: flagged,
            );
            if (finalCard.status != flagged.status) {
              await repo.updateScorecard(finalCard);

              // Notify admin that the card is ready for final approval
              final playerName = _resolveFirstName(entryId, event, full: true);
              final adminIds = ref.read(allMembersProvider).value
                  ?.where((m) => m.role == MemberRole.admin || m.role == MemberRole.superAdmin)
                  .map((m) => m.id) ?? [];
              for (final adminId in adminIds) {
                await _sendVerificationNotification(
                  recipientId: adminId,
                  title: 'Score Ready for Approval',
                  message: '$playerName\'s scorecard has been verified by both parties',
                  eventId: event.id,
                );
              }

              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isPlayerRole ? 'Your scorecard submitted' : '${_resolveFirstName(entryId, event)}\'s scorecard submitted'),
                  backgroundColor: AppColors.lime500,
                ),
              );
            }

            // Close sheet only when all tasks are signed
            final refreshed = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];
            final allDone = tasks.every((t) {
              final c = refreshed.firstWhereOrNull((s) => s.entryId == t.entryId);
              return t.isPlayerRole ? (c?.verifiedByPlayer ?? false) : (c?.verifiedByMarker ?? false);
            });
            if (allDone && mounted) Navigator.of(context).pop();
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign-off failed: $e'), backgroundColor: AppColors.coral500),
            );
          }
        },
      ),
    );
  }

  Future<void> _sendVerificationNotification({
    required String recipientId,
    required String title,
    required String message,
    required String eventId,
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
      ));
    } catch (_) {
      // Notifications are best-effort — don't block the sign-off flow
    }
  }

  bool _cardHasConflict(Scorecard card) {
    for (int i = 0; i < 18; i++) {
      final p = card.holeScores.elementAtOrNull(i);
      final m = card.playerVerifierScores.elementAtOrNull(i);
      if (p != null && m != null && p != m) return true;
    }
    return false;
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

  void _showMatchBracket(GolfEvent event) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Match Bracket',
      child: MatchPlayBracketHub(eventId: event.id),
    );
  }

  // --- Core Persistence Logic ---
  
  Future<void> _submitScorecard(String scorecardId) async {
    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Submit Scorecard?',
      message: 'Are you sure you want to submit your scorecard? You will not be able to edit it afterwards.',
      confirmText: 'Submit',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(scorecardRepositoryProvider).updateScorecardStatus(
          scorecardId, 
          ScorecardStatus.submitted
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Scorecard Submitted Successfully!'), backgroundColor: AppColors.lime500),
           );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _confirmUnsubmit(String scorecardId) async {
    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Unsubmit Scorecard?',
      message: 'This will reopen your scorecard for editing. You will need to submit it again when finished.',
      confirmText: 'Unsubmit',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(scorecardRepositoryProvider).updateScorecardStatus(scorecardId, ScorecardStatus.draft);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scorecard reopened for editing.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reopening scorecard: $e')),
          );
        }
      }
    }
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

  Color _getStatusColor(ScorecardStatus status) {
    switch (status) {
      case ScorecardStatus.submitted: return AppColors.teamA;
      case ScorecardStatus.reviewed: return AppColors.lime600;
      case ScorecardStatus.finalScore: return AppColors.lime500;
      default: return AppColors.amber500;
    }
  }
}
