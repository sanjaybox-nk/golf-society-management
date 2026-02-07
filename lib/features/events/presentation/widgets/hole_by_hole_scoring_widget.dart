import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_shadows.dart'; // [NEW] Added import
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/scorecard.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/profile_provider.dart';
// events_provider.dart removed as it was unused
enum MarkerTab { player, verifier }

class HoleByHoleScoringWidget extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Scorecard? targetScorecard;
  final Scorecard? verifierScorecard;
  final String? targetEntryId; // [NEW] Required for card creation
  final bool isSelfMarking;
  final MarkerTab selectedTab;
  final ValueChanged<MarkerTab>? onTabChanged;

  const HoleByHoleScoringWidget({
    super.key,
    required this.event,
    this.targetScorecard,
    this.verifierScorecard,
    this.targetEntryId,
    this.isSelfMarking = true,
    this.selectedTab = MarkerTab.player,
    this.onTabChanged,
  });

  @override
  ConsumerState<HoleByHoleScoringWidget> createState() => _HoleByHoleScoringWidgetState();
}

class _HoleByHoleScoringWidgetState extends ConsumerState<HoleByHoleScoringWidget> {
  late PageController _pageController;
  final Map<int, int> _localScores = {}; // Official (Target)
  final Map<int, int> _verifierScores = {}; // Verifier (My Record)
  int _currentPage = 0;
  // Internal state removed in favor of widget.selectedTab

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Initialize local scores (Official)
    if (widget.targetScorecard != null) {
      for (int i = 0; i < widget.targetScorecard!.holeScores.length; i++) {
        final score = widget.targetScorecard!.holeScores[i];
        if (score != null) {
          _localScores[i + 1] = score;
        }
      }
    }

    // Initialize verifier scores (Secondary)
    if (widget.verifierScorecard != null) {
      for (int i = 0; i < widget.verifierScorecard!.playerVerifierScores.length; i++) {
        final score = widget.verifierScorecard!.playerVerifierScores[i];
        if (score != null) {
          _verifierScores[i + 1] = score;
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateScore(int holeNum, int delta, int par, {bool isVerifier = false}) {
    setState(() {
      final map = isVerifier ? _verifierScores : _localScores;
      final currentScore = map[holeNum] ?? par;
      final newScore = (currentScore + delta).clamp(1, 15);
      map[holeNum] = newScore;
    });
    
    // Auto-save logic (debounced or immediate for now)
    _persistScores(isVerifier: isVerifier);
  }

  Future<void> _persistScores({bool isVerifier = false}) async {
    final repo = ref.read(scorecardRepositoryProvider);
    final userId = ref.read(effectiveUserProvider).id;
    
    // Determine which card we are updating
    final cardToUpdate = isVerifier ? widget.verifierScorecard : widget.targetScorecard;
    final map = isVerifier ? _verifierScores : _localScores;
    
    // If no card exists yet, we need to handle creation.
    // For Verifier (My Card), it should ideally exist.
    // For Target (Their Card), it should ideally exist.
    // If not, we create one.
    
    final scoresList = List<int?>.generate(18, (i) => map[i + 1]);
    
    // Calculate totals only for Main/Hole scores (not strictly needed for verifier logic but good to have)
    final grossTotal = scoresList.whereType<int>().fold<int>(0, (a, b) => a + b);

    if (cardToUpdate == null) {
        // This case handles brand new scorecard creation
        // If Self-Marking, cardToUpdate is null initially if not passed.
        // We need to create a new scorecard.
        // If Verifier Mode, verifierCard should exist if the event is set up correctly.
        // Allowing creation for now.
        
        final newCard = Scorecard(
          id: '', // Repo generates ID
          competitionId: widget.event.id,
          roundId: 'round_1',
          // Explicitly use targetEntryId if available, otherwise fallback to user
          entryId: isVerifier ? userId : (widget.targetEntryId ?? widget.targetScorecard?.entryId ?? userId),
          submittedByUserId: userId,
          holeScores: isVerifier ? [] : scoresList,
          playerVerifierScores: isVerifier ? scoresList : [],
          grossTotal: isVerifier ? null : grossTotal,
          status: ScorecardStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.addScorecard(newCard);
    } else {
        // Update existing card
        final updatedCard = isVerifier 
            ? cardToUpdate.copyWith(
                playerVerifierScores: scoresList, 
                updatedAt: DateTime.now()
              )
            : cardToUpdate.copyWith(
                holeScores: scoresList,
                grossTotal: grossTotal,
                updatedAt: DateTime.now()
              );
              
        await repo.updateScorecard(updatedCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final holes = widget.event.courseConfig['holes'] as List? ?? [];
    // Fixed height for tabbed view
    const double cardHeight = 240; // Slightly taller for tabs
    
    return BoxyArtFloatingCard(
      height: cardHeight,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 18,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              // Swiping automatically saves the current hole's score
              _persistScores();
            },
            itemBuilder: (context, index) {
              final holeNum = index + 1;
              int par = 4;
              int? si;

              if (holes.length >= holeNum) {
                final holeData = holes[index];
                par = (holeData['par'] as num?)?.toInt() ?? 4;
                si = (holeData['si'] as num?)?.toInt();
              }

              final score = _localScores[holeNum] ?? par;

              return _buildHoleView(holeNum, par, si, score);
            },
          ),
          
          // Left Chevron
          if (_currentPage > 0)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),

          // Right Chevron
          if (_currentPage < 17)
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 28),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHoleView(int holeNum, int par, int? si, int score) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    // Determine current mode and values
    // If Self Marking, always Player Tab implicitly
    // If Marker Mode, check _currentTab
    
    // Check Conflict for Alert
    bool hasConflict = false;
    final markersEntryForMe = widget.verifierScorecard?.holeScores.elementAtOrNull(holeNum - 1);
    final myEntry = _verifierScores[holeNum];
    
    if (markersEntryForMe != null && markersEntryForMe > 0) {
      if (myEntry != null && myEntry != markersEntryForMe) {
        hasConflict = true;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Row 1: Hole Info (MOVED TO BOTTOM)
          
          const SizedBox(height: 12),

    // Row 2: Tabs (Only if NOT self-marking)
          if (!widget.isSelfMarking)
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  // Player Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTabChanged?.call(MarkerTab.player),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.selectedTab == MarkerTab.player ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: widget.selectedTab == MarkerTab.player ? AppShadows.softScale : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'PLAYER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: widget.selectedTab == MarkerTab.player ? primaryColor : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Verifier Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTabChanged?.call(MarkerTab.verifier),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.selectedTab == MarkerTab.verifier ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: widget.selectedTab == MarkerTab.verifier ? AppShadows.softScale : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'MY SCORE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: hasConflict 
                                    ? Colors.red 
                                    : (widget.selectedTab == MarkerTab.verifier ? primaryColor : Colors.grey),
                              ),
                            ),
                            if (hasConflict) ...[
                               const SizedBox(width: 4),
                               const Icon(Icons.error, size: 14, color: Colors.red),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Center Row: Singular Input
          // Logic:
          // If Self Marking -> Always Player Score
          // If Marker Mode -> Depends on Tab
          
          Builder(
            builder: (context) {
                final isVerifierTab = !widget.isSelfMarking && widget.selectedTab == MarkerTab.verifier;
                final displayScore = isVerifierTab ? (_verifierScores[holeNum] ?? par) : score;
                
                return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildThemedControl(Icons.remove, () => _updateScore(holeNum, -1, par, isVerifier: isVerifierTab)),
                  const SizedBox(width: 24),
                  // Inline Score Input
                  _ScoreInput(
                    key: ValueKey('input_${isVerifierTab ? 'verifier' : 'player'}_$holeNum'),
                    score: displayScore,
                    hasConflict: isVerifierTab && hasConflict,
                    borderColor: (isVerifierTab && hasConflict) ? Colors.red : null,
                    onChanged: (newScore) => _setScore(holeNum, newScore, isVerifier: isVerifierTab),
                  ),
                  const SizedBox(width: 24),
                  _buildThemedControl(Icons.add, () => _updateScore(holeNum, 1, par, isVerifier: isVerifierTab)),
                ],
              );
            }
          ),
          
          const Spacer(),
          const SizedBox(height: 12),
          
          // Row 3: Hole Info (Moved to Bottom)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HOLE $holeNum',
                style: textTheme.labelSmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                  BoxyArtStatusPill(
                    text: 'PAR $par',
                    baseColor: Colors.grey,
                    backgroundColorOverride: onSurface.withValues(alpha: 0.05),
                  ),
                  if (si != null) ...[
                    const SizedBox(width: 6),
                    BoxyArtStatusPill(
                      text: 'SI $si',
                      baseColor: primaryColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemedControl(IconData icon, VoidCallback onTap) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return BoxyArtCircularIconBtn(
      icon: icon,
      onTap: onTap,
      backgroundColor: onSurface.withValues(alpha: 0.05),
      iconColor: Theme.of(context).primaryColor,
      iconSize: 24,
      padding: 12,
      shadowOverride: AppShadows.inputSoft, 
    );
  }

  void _setScore(int holeNum, int score, {bool isVerifier = false}) {
    setState(() {
      final map = isVerifier ? _verifierScores : _localScores;
      map[holeNum] = score.clamp(1, 15);
    });
    _persistScores(isVerifier: isVerifier);
  }
}

// Helper extension
extension ElementAtOrNull<E> on Iterable<E> {
  E? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}

class _ScoreInput extends StatefulWidget {
  final int score;
  final ValueChanged<int> onChanged;
  final Color? borderColor;
  final bool hasConflict;

  const _ScoreInput({
    super.key,
    required this.score,
    required this.onChanged,
    this.borderColor,
    this.hasConflict = false,
  });

  @override
  State<_ScoreInput> createState() => _ScoreInputState();
}

class _ScoreInputState extends State<_ScoreInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.score.toString());
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      } else {
        // On Blur: Commit the current value to ensure it saves
        _handleCommit();
      }
    });
  }

  void _handleCommit() {
    final text = _controller.text;
    if (text.isEmpty) return;
    
    final value = int.tryParse(text);
    if (value != null) {
      widget.onChanged(value);
    }
  }

  @override
  void didUpdateWidget(_ScoreInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      final parsed = int.tryParse(_controller.text);
      if (parsed != widget.score) {
        _controller.text = widget.score.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 90, // roughly 80 * 1.125
      height: 80,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        border: Border.all(
          color: widget.hasConflict 
              ? Colors.red 
              : (widget.borderColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          width: widget.hasConflict ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: 0.05),
             blurRadius: 4,
             offset: const Offset(0, 2),
          )
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: theme.textTheme.displayLarge?.copyWith(
          color: widget.hasConflict ? Colors.red : theme.colorScheme.onSurface,
          fontSize: 64, 
          fontWeight: FontWeight.w900,
          height: 1,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          counterText: '', 
          filled: false, 
        ),
        onSubmitted: (_) => _handleCommit(),
        onChanged: (val) {
          if (val.isEmpty) return; // Don't update for empty string
          final newValue = int.tryParse(val);
          if (newValue != null) {
            widget.onChanged(newValue);
          }
        },
        onTapOutside: (_) => _focusNode.unfocus(),
      ),
    );
  }
}
