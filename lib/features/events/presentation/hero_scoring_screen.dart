import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'events_provider.dart';
import '../../matchplay/presentation/state/match_play_providers.dart';
import 'widgets/modern_scoring_view.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../../competitions/presentation/competitions_provider.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../members/presentation/members_provider.dart';
import '../../members/presentation/profile_provider.dart';
import 'widgets/hole_by_hole_scoring_widget.dart'; // For MarkerTab
import 'state/marker_selection_provider.dart';

class HeroScoringScreen extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Map<int, int> initialPlayerScores;
  final Map<int, int> initialVerifierScores;
  final int initialHole;
  final List<dynamic> holes;
  final Map<String, dynamic> effectivePtc;
  final MarkerTab initialTab;
  final String? activeEntryId;
  final Function(int hole, int score, bool isVerifier) onSetScore;
  final bool isSelfMarking;

  const HeroScoringScreen({
    super.key,
    required this.event,
    required this.initialPlayerScores,
    required this.initialVerifierScores,
    required this.initialHole,
    required this.holes,
    required this.effectivePtc,
    required this.initialTab,
    this.activeEntryId,
    required this.onSetScore,
    this.isSelfMarking = true,
  });

  @override
  ConsumerState<HeroScoringScreen> createState() => _HeroScoringScreenState();
}

class _HeroScoringScreenState extends ConsumerState<HeroScoringScreen> {
  late int _currentHole;
  late Map<int, int> _playerScores;
  late Map<int, int> _verifierScores;
  late MarkerTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _currentHole = widget.initialHole;
    _playerScores = Map.from(widget.initialPlayerScores);
    _verifierScores = Map.from(widget.initialVerifierScores);
    _selectedTab = widget.isSelfMarking ? MarkerTab.verifier : widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final matchResultAsync = ref.watch(currentMatchControllerProvider(widget.event.id));
    final compAsync = ref.watch(competitionDetailProvider(widget.event.id));
    final markerSelection = ref.watch(markerSelectionProvider);
    final matchResult = matchResultAsync.asData?.value;
    final isVerifier = _selectedTab == MarkerTab.verifier;
    final currentScores = isVerifier ? _verifierScores : _playerScores;

    // Resolve Marking Name
    final effectiveUser = ref.watch(effectiveUserProvider);
    final memberId = isVerifier ? effectiveUser.id : widget.activeEntryId;
    final members = ref.watch(allMembersProvider).value ?? [];
    final member = members.firstWhereOrNull(
      (m) => m.id == memberId?.replaceFirst('_guest', '')
    );
    final markingName = member?.displayName ?? (isVerifier ? 'Me' : 'Player');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drawer handle indicator
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'HOLE $_currentHole',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Dismiss',
        ),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Swipe down to dismiss
          if (details.primaryDelta! > 12) {
            Navigator.of(context).pop();
          }
        },
        onHorizontalDragEnd: (details) {
          // Detect horizontal swipes for hole navigation
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -300) {
            // Swipe Left -> Next Hole
            if (_currentHole < 18) {
              setState(() => _currentHole++);
            }
          } else if (velocity > 300) {
            // Swipe Right -> Previous Hole
            if (_currentHole > 1) {
              setState(() => _currentHole--);
            }
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            bottom: false,
            child: compAsync.when(
              data: (comp) => ModernScoringView(
                event: widget.event,
                scores: currentScores,
                currentHole: _currentHole,
                holes: widget.holes,
                playerPhc: _calculatePhc(isVerifier),
                markingName: markingName,
                matchResult: matchResult?.result,
                isTeam1: matchResult?.match.team1Ids.contains(memberId) ?? true,
                format: comp?.rules.format ?? CompetitionFormat.stableford,
                maxScoreConfig: comp?.rules.maxScoreConfig,
                rules: comp?.rules,
                selectedTab: _selectedTab == MarkerTab.verifier ? 1 : 0,
                isSelfMarking: widget.isSelfMarking,
                selectedTeeName: markerSelection.teeOverrides[memberId],
                onTabChanged: (tab) => setState(() {
                  _selectedTab = tab == 0 ? MarkerTab.player : MarkerTab.verifier;
                }),
                onHoleChanged: (h) => setState(() => _currentHole = h),
                onSetScore: (h, score) {
                  setState(() {
                    if (isVerifier) {
                      _verifierScores[h] = score;
                    } else {
                      _playerScores[h] = score;
                    }
                  });
                  widget.onSetScore(h, score, isVerifier);
                },
                onShowFullCard: () => Navigator.of(context).pop(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ),
      ),
    );
  }



  int _calculatePhc(bool isVerifier) {
    final memberId = isVerifier ? ref.read(effectiveUserProvider).id : widget.activeEntryId;
    if (memberId == null) return 0;
    
    final comp = ref.watch(competitionDetailProvider(widget.event.id)).asData?.value;
    
    // 1. Check for explicit Match Play strokes
    if (comp?.rules.format == CompetitionFormat.matchPlay) {
       final matchData = ref.watch(currentMatchControllerProvider(widget.event.id)).asData?.value;
       if (matchData != null) {
          return matchData.match.strokesReceived[memberId] ?? 0;
       }
    }

    // 2. Single Source of Truth: Read PHC from Event Grouping data.
    //    Watch the LIVE event from Firestore so PHC updates immediately
    //    when the admin recalculates and saves in the Grouping screen.
    final liveEvent = ref.watch(eventProvider(widget.event.id)).asData?.value;
    final grouping = liveEvent?.grouping ?? widget.event.grouping;
    return HandicapCalculator.getStoredPhc(grouping, memberId);
  }
}
