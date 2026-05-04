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
import '../widgets/vertical_hole_scoring_list.dart';

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
            final bool isCardFull = userScorecard?.holeScores.length == 18 && userScorecard!.holeScores.every((s) => s != null && s > 0);

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

            return HeadlessScaffold(
              title: event.title,
              subtitle: effectiveRules.isUnifiedTeamFormat ? 'Team Scorecard' : 'My Event Card',
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
              // [NEW] Pin keypad ONLY on the SCORECARD tab (Index 1)
              pinnedBottom: selectedScoringTab == 1 
                  ? _buildPinnedScoring(event, comp, scoringData, effectiveRules)
                  : null,
              pinnedBottomPadding: AppSpacing.lg,
              slivers: [
                // 1. Sticky Tab Switcher (Design 4.x Tokened Style)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabDelegate(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: ModernUnderlinedFilterBar<int>(
                        tabs: const [
                          ModernFilterTab(label: 'Scoring', value: 0, icon: Icons.edit_note_rounded),
                          ModernFilterTab(label: 'Scorecard', value: 1, icon: Icons.grid_on_rounded),
                        ],
                        selectedValue: selectedScoringTab,
                        onTabSelected: (val) => ref.read(eventScoringTabProvider.notifier).set(val),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),

                // 2. Main Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                     child: selectedScoringTab == 0
                        ? VerticalHoleScoringList(
                            key: ValueKey('scoring_${event.id}_${currentUser.id}'),
                            event: event, 
                            scoringData: scoringData,
                            onMarkerSelectionTap: () => MarkerSelectionSheet.show(context: context, event: event),
                          )
                        : _buildScoringContent(event, comp, effectiveRules, scoringData),
                  ),
                ),
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
                child: BoxyArtEmptyState(
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
            child: BoxyArtEmptyState(
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

  Widget _buildScoringContent(GolfEvent event, Competition? comp, CompetitionRules effectiveRules, ProcessedEventData? scoringData) {
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
    );
  }

  void _showVerificationSheet(GolfEvent event, Scorecard userScorecard) {
    final currentUser = ref.read(effectiveUserProvider);
    final allScorecards = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];
    final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Verify Scorecard',
      child: ScoringVerificationView(
        event: event,
        targetEntryId: userScorecard.entryId,
        activeScorecard: userScorecard,
        verifierScorecard: myCard,
        isAdmin: widget.isAdminMode,
        onSignOff: (isPlayer) async {
          // Handled via state update in HoleByHoleScoringWidget or here
          // For now, we reuse the verification logic from the view itself
          // which updates the scorecard in the repository.
          // After sign-off, we check if we should close the sheet.
          final updatedAllCards = ref.read(scorecardsListProvider(event.id)).asData?.value ?? [];
          final freshUserCard = updatedAllCards.firstWhereOrNull((s) => s.id == userScorecard.id);
          
          if (freshUserCard?.status == ScorecardStatus.submitted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
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
class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabDelegate({required this.child});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabDelegate oldDelegate) => true;
}
