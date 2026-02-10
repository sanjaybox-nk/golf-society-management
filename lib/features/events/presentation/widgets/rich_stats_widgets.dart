import 'package:flutter/material.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/scorecard.dart';

class ScoringTypeDistributionChart extends StatelessWidget {
  final Map<String, int> counts;

  const ScoringTypeDistributionChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final types = ['EAGLE', 'BIRDIE', 'PAR', 'BOGEY', 'BLOB'];
    final colors = {
      'EAGLE': Colors.purple,
      'BIRDIE': Colors.blue,
      'PAR': Colors.green,
      'BOGEY': Colors.orange,
      'BLOB': Colors.red,
    };
    
    final maxCount = counts.values.fold(0, (max, v) => v > max ? v : max).clamp(1, 999);

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SCORING BREAKDOWN',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: types.map((t) {
                final count = counts[t] ?? 0;
                final barHeight = (count / maxCount) * 100;
                final color = colors[t] ?? Colors.grey;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: barHeight.toDouble().clamp(4, 100),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [color, color.withValues(alpha: 0.3)],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t,
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'A breakdown of every score recorded across the entire field.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class StablefordDistributionChart extends StatelessWidget {
  final Map<String, int> bucketCounts;

  const StablefordDistributionChart({super.key, required this.bucketCounts});

  @override
  Widget build(BuildContext context) {
    final buckets = ['<20', '20-25', '26-30', '31-35', '36+'];
    final maxCount = bucketCounts.values.fold(0, (max, v) => v > max ? v : max).clamp(1, 999);

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STABLEFORD DISTRIBUTION',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.map((b) {
                final count = bucketCounts[b] ?? 0;
                final barHeight = (count / maxCount) * 100;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        count.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: barHeight.toDouble().clamp(4, 100),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Counts how many players finished within each point range.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SplitPerformanceCard extends StatelessWidget {
  final double front9Avg;
  final double back9Avg;
  final bool isStableford;

  const SplitPerformanceCard({
    super.key,
    required this.front9Avg,
    required this.back9Avg,
    required this.isStableford,
  });

  @override
  Widget build(BuildContext context) {
    final diff = back9Avg - front9Avg;
    final isColapse = isStableford ? diff < 0 : diff > 0;
    final label = isStableford ? 'pts' : 'strokes';

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FRONT vs BACK PERFORMANCE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildHalfCard('FRONT 9', front9Avg, Colors.green, label),
                const SizedBox(width: 16),
                _buildHalfCard('BACK 9', back9Avg, Colors.orange, label),
              ],
            ),
            const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isColapse ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.primaryContainer).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                       Icon(
                         isColapse ? Icons.trending_down : Icons.trending_up, 
                         color: isColapse ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary, 
                         size: 20,
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Text(
                           isColapse 
                            ? 'The field faded on the Back 9 today.' 
                            : 'Strong finish! The field improved on the Back 9.',
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 13,
                             color: isColapse ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onPrimaryContainer,
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Compares total points or strokes between the first and last 9 holes.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildHalfCard(String title, double val, Color color, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                val.toStringAsFixed(1),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
              ),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class ParTypeBreakdown extends StatelessWidget {
  final Map<int, double> parTypeAverages;

  const ParTypeBreakdown({super.key, required this.parTypeAverages});

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PERFORMANCE BY HOLE TYPE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildParTypeStat(context, 'PAR 3', parTypeAverages[3] ?? 0),
                _buildParTypeStat(context, 'PAR 4', parTypeAverages[4] ?? 0),
                _buildParTypeStat(context, 'PAR 5', parTypeAverages[5] ?? 0),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Breaks down performance averages against par for different hole lengths.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParTypeStat(BuildContext context, String label, double avg) {
    final vsPar = avg > 0;
    final color = vsPar ? Theme.of(context).colorScheme.error : Colors.green; // Using themed error for bad scores
    
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '${vsPar ? "+" : ""}${avg.toStringAsFixed(1)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: color,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('AVG VS PAR', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}

class DifficultyHeatmap extends StatelessWidget {
  final Map<int, double> holeAverages;
  final List<dynamic> holes;

  const DifficultyHeatmap({super.key, required this.holeAverages, required this.holes});

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HOLE-BY-HOLE HEATMAP',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(9, (i) => Expanded(child: _buildHoleBubble(i))),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(9, (i) => Expanded(child: _buildHoleBubble(i + 9))),
            ),
            const SizedBox(height: 16),
            const Text(
              'A visual guide to course difficulty: Red shades indicate harder (over-par) holes, while green indicates easier ones.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoleBubble(int i) {
    final avg = holeAverages[i] ?? 4.0;
    final par = holes.length > i ? (holes[i]['par'] as int? ?? 4).toDouble() : 4.0;
    final diff = avg - par;
    
    Color color;
    if (diff > 1.0) {
      color = Colors.red[900]!;
    } else if (diff > 0.5) {
      color = Colors.red;
    } else if (diff > 0.2) {
      color = Colors.orange;
    } else if (diff > -0.2) {
      color = Colors.yellow[700]!;
    } else {
      color = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${i + 1}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
          ),
          Text(
            '${diff > 0 ? "+" : ""}${diff.toStringAsFixed(1)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HoleDifficultyChart extends StatelessWidget {
  final Map<int, double> holeAverages;
  final List<dynamic> holes;

  const HoleDifficultyChart({
    super.key,
    required this.holeAverages,
    required this.holes,
  });

  @override
  Widget build(BuildContext context) {
    // Sort holes by difficulty (average relative to par)
    final sortedHoleIndices = holeAverages.keys.toList()
      ..sort((a, b) {
        final parA = (holes[a]['par'] as int? ?? 4).toDouble();
        final diffA = holeAverages[a]! - parA;
        final parB = (holes[b]['par'] as int? ?? 4).toDouble();
        final diffB = holeAverages[b]! - parB;
        return diffB.compareTo(diffA); // Toughest first
      });

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOUGHEST TEST (AVG VS PAR)',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedHoleIndices.take(5).map((idx) {
              final avg = holeAverages[idx]!;
              final par = (holes[idx]['par'] as int? ?? 4).toDouble();
              final diff = avg - par;
              final isOverPar = diff > 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'HOLE ${idx + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${isOverPar ? "+" : ""}${diff.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: isOverPar ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (diff.abs() / 2).clamp(0.1, 1.0),
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOverPar ? Colors.red.withValues(alpha: 0.7) : Colors.green.withValues(alpha: 0.7),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text(
              'Identifies the most challenging holes based on average relative to par.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementTile extends StatelessWidget {
  final String title;
  final String playerName;
  final String value;
  final IconData icon;
  final Color color;

  const AchievementTile({
    super.key,
    required this.title,
    required this.playerName,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    playerName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldEclecticCard extends StatelessWidget {
  final List<int?> eclecticScores;
  final List<dynamic> holes;

  const FieldEclecticCard({
    super.key,
    required this.eclecticScores,
    required this.holes,
  });

  @override
  Widget build(BuildContext context) {
    final totalStrokes = eclecticScores.whereType<int>().fold(0, (sum, s) => sum + s);
    final parTotal = holes.fold(0, (sum, h) => sum + (h['par'] as int? ?? 4));
    final vsPar = totalStrokes - parTotal;

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOCIETY\'S BEST ROUND',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'FIELD ECLECTIC',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        totalStrokes.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        vsPar == 0 ? 'PAR' : (vsPar > 0 ? '+$vsPar' : '$vsPar'),
                        style: TextStyle(
                          color: vsPar <= 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'A "perfect round" constructed from the best score made on each hole by any player today.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SocietyRecapSummaryCard extends StatelessWidget {
  final int totalPlayers;
  final int totalHolesPlayed;
  final String topHoleName;
  final double topHoleDiff;

  const SocietyRecapSummaryCard({
    super.key,
    required this.totalPlayers,
    required this.totalHolesPlayed,
    required this.topHoleName,
    required this.topHoleDiff,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.flag_circle, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'SOCIETY RECAP COMPLETE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$totalPlayers PLAYERS · $totalHolesPlayed HOLES',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Toughest Test: $topHoleName (+${topHoleDiff.toStringAsFixed(1)})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What a day for the society! See you at the 19th hole. 🍻',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalBenchmarkingCard extends StatelessWidget {
  final Map<int, double> myAverages;
  final Map<int, double> fieldAverages;

  const PersonalBenchmarkingCard({
    super.key,
    required this.myAverages,
    required this.fieldAverages,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YOU VS THE FIELD',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildBenchStat(context, 'PAR 3', myAverages[3] ?? 0, fieldAverages[3] ?? 0),
                _buildBenchStat(context, 'PAR 4', myAverages[4] ?? 0, fieldAverages[4] ?? 0),
                _buildBenchStat(context, 'PAR 5', myAverages[5] ?? 0, fieldAverages[5] ?? 0),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Compares your average performance relative to par against the rest of the field.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchStat(BuildContext context, String label, double myAvg, double fieldAvg) {
    final diff = myAvg - fieldAvg;
    final betterThanField = diff < 0; // Scoring lower vs par is better
    final color = myAvg > 0 ? Theme.of(context).colorScheme.error : Colors.green;
    
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '${myAvg > 0 ? "+" : ""}${myAvg.toStringAsFixed(1)}',
              style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 18),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                betterThanField ? Icons.trending_up : Icons.trending_down,
                size: 10,
                color: betterThanField ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                '${betterThanField ? "-" : "+"}${diff.abs().toStringAsFixed(1)} FIELD',
                style: TextStyle(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  color: betterThanField ? Colors.green : Colors.red
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HoleComparisonHeatmap extends StatelessWidget {
  final Scorecard myScorecard;
  final Map<int, double> fieldAverages;
  final List<dynamic> holes;

  const HoleComparisonHeatmap({
    super.key,
    required this.myScorecard,
    required this.fieldAverages,
    required this.holes,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WHERE YOU BEAT THE FIELD',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(9, (i) => Expanded(child: _buildComparisonBubble(i))),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(9, (i) => Expanded(child: _buildComparisonBubble(i + 9))),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gold holes are where you personally beat the field average. Grey holes are where the field got the better of you.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonBubble(int i) {
    final myScore = (myScorecard.holeScores.length > i ? myScorecard.holeScores[i] : null)?.toDouble();
    if (myScore == null) return Container();

    final fieldAvg = fieldAverages[i] ?? 4.0;
    final diff = myScore - fieldAvg;
    final beatField = diff < 0;
    
    final color = beatField ? Colors.amber[700]! : Colors.grey[400]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${i + 1}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
          ),
          Icon(
            beatField ? Icons.star : Icons.remove,
            color: Colors.white.withValues(alpha: 0.8),
            size: 10,
          ),
        ],
      ),
    );
  }
}

class ConsistencyStatCard extends StatelessWidget {
  final double myVariance;
  final double fieldAvgVariance;

  const ConsistencyStatCard({
    super.key,
    required this.myVariance,
    required this.fieldAvgVariance,
  });

  @override
  Widget build(BuildContext context) {
    final diff = ((fieldAvgVariance - myVariance) / (fieldAvgVariance > 0 ? fieldAvgVariance : 1)) * 100;
    final moreConsistent = myVariance < fieldAvgVariance;
    final color = moreConsistent ? Colors.green : Colors.orange;

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONSISTENCY (ROUND VARIANCE)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moreConsistent ? 'STEADY HAND' : 'ROLLERCOASTER',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color),
                      ),
                      Text(
                        'You were ${diff.abs().toStringAsFixed(0)}% ${moreConsistent ? "more" : "less"} consistent than the field.',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(moreConsistent ? Icons.balance : Icons.auto_graph, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NetComparisonCard extends StatelessWidget {
  final int myNet;
  final double fieldAvgNet;

  const NetComparisonCard({
    super.key,
    required this.myNet,
    required this.fieldAvgNet,
  });

  @override
  Widget build(BuildContext context) {
    final diff = myNet - fieldAvgNet;
    final better = diff < 0;

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NET VS FIELD AVG',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$myNet',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'vs ${fieldAvgNet.toStringAsFixed(1)} AVG',
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (better ? Colors.green : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${better ? "-" : "+"}${diff.abs().toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: better ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HoleNemesisComparison extends StatelessWidget {
  final int myHardestHoleIdx;
  final double myHardestHoleDiff;
  final int fieldHardestHoleIdx;
  final double fieldHardestHoleDiff;

  const HoleNemesisComparison({
    super.key,
    required this.myHardestHoleIdx,
    required this.myHardestHoleDiff,
    required this.fieldHardestHoleIdx,
    required this.fieldHardestHoleDiff,
  });

  @override
  Widget build(BuildContext context) {
    final isSame = myHardestHoleIdx == fieldHardestHoleIdx;

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOUGHEST TEST (NEMESIS)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildNemesis(context, 'YOURS', myHardestHoleIdx, myHardestHoleDiff, Colors.blue)),
                Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
                Expanded(child: _buildNemesis(context, 'FIELD', fieldHardestHoleIdx, fieldHardestHoleDiff, Colors.red)),
              ],
            ),
            if (isSame) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🤝 You struggled where everyone else did!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNemesis(BuildContext context, String label, int idx, double diff, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          'HOLE ${idx + 1}',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color),
        ),
        Text(
          '+${diff.toStringAsFixed(1)} VS PAR',
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class BounceBackStatCard extends StatelessWidget {
  final double myRate;
  final double fieldRate;

  const BounceBackStatCard({
    super.key,
    required this.myRate,
    required this.fieldRate,
  });

  @override
  Widget build(BuildContext context) {
    final better = myRate >= fieldRate;
    final color = better ? Colors.blue : Colors.grey;

    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.replay_circle_filled, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOUNCE BACK RATE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(myRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'FIELD AVG',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey),
                ),
                Text(
                  '${(fieldRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
