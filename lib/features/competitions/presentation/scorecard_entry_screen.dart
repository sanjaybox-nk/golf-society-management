import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import '../../competitions/presentation/competitions_provider.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/competition.dart';
import '../../../../models/golf_event.dart';
import '../../events/presentation/events_provider.dart';

class ScorecardEntryScreen extends ConsumerStatefulWidget {
  final String competitionId;
  final String? scorecardId; // If editing

  const ScorecardEntryScreen({super.key, required this.competitionId, this.scorecardId});

  @override
  ConsumerState<ScorecardEntryScreen> createState() => _ScorecardEntryScreenState();
}

class _ScorecardEntryScreenState extends ConsumerState<ScorecardEntryScreen> {
  final Map<int, int> _holeScores = {};
  int? _totalGross;
  bool _isSaving = false;
  int _currentHole = 1;

  @override
  Widget build(BuildContext context) {
    final compAsync = ref.watch(competitionDetailProvider(widget.competitionId));
    final eventAsync = ref.watch(eventProvider(widget.competitionId)); // Assuming compId == eventId for now

    return compAsync.when(
      data: (comp) {
        if (comp == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        return eventAsync.when(
          data: (event) {
            // Let's use a simpler approach: get course from courseConfig (migration phase)
            final rules = comp.rules;
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: BoxyArtAppBar(
                title: 'SCORECARD',
                subtitle: rules.format.name.toUpperCase(),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: _isSaving ? null : () => _submit(comp),
                    child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              body: rules.holeByHoleRequired
                  ? _buildHoleByHoleEntry(comp, event)
                  : _buildTotalOnlyEntry(comp),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) => Scaffold(body: Center(child: Text('Error loading event: $e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildHoleByHoleEntry(Competition comp, GolfEvent event) {
    return Column(
      children: [
        _buildHoleSelector(),
        _buildHoleInfo(event),
        Expanded(
          child: Center(
            child: _buildScoreInput(_currentHole),
          ),
        ),
        _buildStatsBar(comp, event),
      ],
    );
  }

  Widget _buildHoleInfo(GolfEvent event) {
    // Determine Par and SI for current hole
    int? par;
    int? si;

    if (event.courseConfig['holes'] is List) {
      final holes = event.courseConfig['holes'] as List;
      if (holes.length >= _currentHole) {
        final holeData = holes[_currentHole - 1];
        par = (holeData['par'] as num?)?.toInt();
        si = (holeData['si'] as num?)?.toInt();
      }
    } else if (event.courseConfig['holePars'] is List) {
      // Legacy format fallback
      final pars = event.courseConfig['holePars'] as List;
      final sis = event.courseConfig['holeSIs'] as List?;
      if (pars.length >= _currentHole) {
        par = (pars[_currentHole - 1] as num?)?.toInt();
        si = sis != null && sis.length >= _currentHole ? (sis[_currentHole - 1] as num?)?.toInt() : null;
      }
    }

    if (par == null) return const SizedBox.shrink();

    // Set default score to par if not touched
    if (!_holeScores.containsKey(_currentHole)) {
      _holeScores[_currentHole] = par;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInfoChip('PAR $par', Colors.white.withValues(alpha: 0.1)),
          if (si != null) ...[
            const SizedBox(width: 8),
            _buildInfoChip('SI $si', Colors.orange.withValues(alpha: 0.2), textColor: Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color bgColor, {Color textColor = Colors.white70}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHoleSelector() {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 18,
        itemBuilder: (context, index) {
          final holeNum = index + 1;
          final isSelected = _currentHole == holeNum;
          final hasScore = _holeScores.containsKey(holeNum);
          return GestureDetector(
            onTap: () => setState(() => _currentHole = holeNum),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 50 : 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : (hasScore ? Colors.white24 : Colors.white10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ] : [],
              ),
              child: Center(
                child: Text(
                  holeNum.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.w900,
                    fontSize: isSelected ? 18 : 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreInput(int holeNum) {
    final score = _holeScores[holeNum] ?? 4;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'HOLE $holeNum',
          style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRoundButton(Icons.remove, () {
              if (score > 1) setState(() => _holeScores[holeNum] = score - 1);
            }),
            const SizedBox(width: 40),
            Container(
              constraints: const BoxConstraints(minWidth: 100),
              alignment: Alignment.center,
              child: Text(
                score.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 40),
            _buildRoundButton(Icons.add, () {
              setState(() => _holeScores[holeNum] = score + 1);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildStatsBar(Competition comp, GolfEvent event) {
    final total = _holeScores.values.fold(0, (sum, score) => sum + score);
    
    // Calculate Par total for the holes score entered
    int parTotal = 0;
    final holes = event.courseConfig['holes'] as List? ?? [];
    final legacyPars = event.courseConfig['holePars'] as List?;
    
    for (var holeNum in _holeScores.keys) {
      if (holes.length >= holeNum) {
        parTotal += (holes[holeNum - 1]['par'] as num?)?.toInt() ?? 4;
      } else if (legacyPars != null && legacyPars.length >= holeNum) {
        parTotal += (legacyPars[holeNum - 1] as num?)?.toInt() ?? 4;
      }
    }
    
    final relativeToPar = total - parTotal;
    final relString = relativeToPar == 0 ? 'E' : (relativeToPar > 0 ? '+$relativeToPar' : '$relativeToPar');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: BoxyArtFloatingCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('TOTAL', total.toString(), Colors.white),
              _buildStat('VS PAR', relString, relativeToPar > 0 ? Colors.red : (relativeToPar < 0 ? Colors.green : Colors.white70)),
              _buildStat('HOLES', '${_holeScores.length}/18', Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label, 
          style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildTotalOnlyEntry(Competition comp) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'TOTAL GROSS SCORE',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          BoxyArtFormField(
            label: 'Enter Score',
            keyboardType: TextInputType.number,
            onChanged: (v) => _totalGross = int.tryParse(v),
          ),
          const Spacer(),
          const Text(
            'Admin verification will be required after submission.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(Competition comp) async {
    if (comp.rules.holeByHoleRequired && _holeScores.length < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter scores for all 18 holes.')),
      );
      return;
    }

    if (!comp.rules.holeByHoleRequired && _totalGross == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your total gross score.')),
      );
      return;
    }

    final confirmed = await showBoxyArtDialog(
      context: context,
      title: 'SUBMIT SCORECARD?',
      message: 'Once submitted, your scores will be sent for review and update the live leaderboard.',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      confirmText: 'YES, SUBMIT',
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    
    try {
      final repo = ref.read(scorecardRepositoryProvider);
      final member = ref.read(currentUserProvider);
      
      final scorecard = Scorecard(
        id: widget.scorecardId ?? '',
        competitionId: widget.competitionId,
        roundId: 'round_1', // Assuming 1 round for now
        entryId: member.id,
        submittedByUserId: member.id,
        holeScores: List.generate(18, (i) => _holeScores[i + 1]),
        grossTotal: _totalGross ?? _holeScores.values.whereType<int>().fold<int>(0, (a, b) => a + b),
        status: ScorecardStatus.submitted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.scorecardId == null) {
        await repo.addScorecard(scorecard);
      } else {
        await repo.updateScorecard(scorecard);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scorecard submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
