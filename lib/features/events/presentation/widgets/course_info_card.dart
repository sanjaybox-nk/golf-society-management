import 'package:flutter/material.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class CourseInfoCard extends StatelessWidget {
  final Map<String, dynamic> courseConfig;
  final String? selectedTeeName;
  final String distanceUnit;
  final bool isStableford;
  final int? playerHandicap; // For calculating shot allowances
  final List<int?>? scores; // Actual scores entered by user

  const CourseInfoCard({
    super.key,
    required this.courseConfig,
    this.selectedTeeName,
    this.distanceUnit = 'yards',
    this.isStableford = false,
    this.playerHandicap,
    this.scores,
  });

  @override
  Widget build(BuildContext context) {
    // Extract course data - handle both formats
    List<dynamic> holePars;
    List<dynamic> holeSIs;
    List<dynamic> holeYardages;
    
    // Check if using new format (holes array)
    if (courseConfig['holes'] != null) {
      final holes = courseConfig['holes'] as List<dynamic>;
      holePars = holes.map((h) => h['par'] ?? 4).toList();
      holeSIs = holes.map((h) => h['si'] ?? 0).toList();
      holeYardages = holes.map((h) => h['yardage'] ?? 0).toList();
    } else {
      // Legacy format
      holePars = courseConfig['holePars'] as List<dynamic>? ?? List.filled(18, 4);
      holeSIs = courseConfig['holeSIs'] as List<dynamic>? ?? List.generate(18, (i) => i + 1);
      
      // Get yardage for selected tee (default to first tee if not specified)
      final tees = courseConfig['tees'] as Map<String, dynamic>? ?? {};
      final selectedTee = selectedTeeName != null && tees.containsKey(selectedTeeName)
          ? tees[selectedTeeName] as Map<String, dynamic>?
          : tees.values.isNotEmpty
              ? tees.values.first as Map<String, dynamic>?
              : null;
      
      holeYardages = selectedTee?['yardages'] as List<dynamic>? ?? List.filled(18, 0);
    }
    
    // Calculate totals
    final front9Pars = holePars.take(9).fold<int>(0, (sum, par) => sum + (par as int));
    final back9Pars = holePars.skip(9).take(9).fold<int>(0, (sum, par) => sum + (par as int));
    final totalPar = front9Pars + back9Pars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtFloatingCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Front 9
              _buildNineHoles(
                context,
                'OUT',
                holePars.take(9).toList(),
                holeSIs.take(9).toList(),
                front9Pars,
                1,
              ),
              const SizedBox(height: 6),
              
              // Back 9
              _buildNineHoles(
                context,
                'IN',
                holePars.skip(9).take(9).toList(),
                holeSIs.skip(9).take(9).toList(),
                back9Pars,
                10,
              ),
              const SizedBox(height: 6),
              
              // Totals
              _buildTotalsRow(context, totalPar),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNineHoles(
    BuildContext context,
    String label,
    List<dynamic> pars,
    List<dynamic> sis,
    int totalPar,
    int startHole,
  ) {
    // Get actual scores from user input and pad with nulls to ensure length 9
    final rawScores = scores?.skip(startHole - 1).take(9).toList() ?? [];
    final nineScores = List<int?>.generate(9, (i) => i < rawScores.length ? rawScores[i] : null);
    
    final totalScore = nineScores.where((s) => s != null).fold<int>(0, (sum, s) => sum + (s as int));
    
    // Calculate Stableford points if applicable
    List<int?> stablefordPoints = [];
    int totalPoints = 0;
    
    if (isStableford && playerHandicap != null) {
      for (int i = 0; i < 9; i++) {
        if (nineScores[i] != null && i < pars.length && i < sis.length) {
          final par = pars[i] as int;
          final si = sis[i] as int;
          final score = nineScores[i]!;
          
          // Calculate shots received on this hole
          final shotsReceived = playerHandicap! >= si ? 1 : 0;
          final netScore = score - shotsReceived;
          
          // Calculate Stableford points (2 points for par)
          final points = par - netScore + 2;
          stablefordPoints.add(points.clamp(0, 5)); // Max 5 points (eagle or better)
          totalPoints += stablefordPoints[i]!;
        } else {
          stablefordPoints.add(null);
        }
      }
    } else {
      stablefordPoints = List<int?>.filled(9, null);
    }
    
    return Column(
      children: [
          // Header row (Hole numbers) with themed background
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                SizedBox(width: 50, child: _buildCellHeader('', width: 50)),
                for (int i = 0; i < 9; i++)
                  Expanded(child: _buildCellHeader('${startHole + i}', width: double.infinity)),
                SizedBox(width: 40, child: _buildCellHeader(label, width: 40, isBold: true)),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Par row with tee color background
          Container(
            decoration: BoxDecoration(
              color: selectedTeeName != null 
                  ? _getTeeColor(selectedTeeName!)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                SizedBox(width: 50, child: _buildCellLabel('Par', width: 50, isOnTeeColor: selectedTeeName != null)),
                for (int i = 0; i < 9; i++)
                  Expanded(child: _buildCell(context, i < pars.length ? '${pars[i]}' : '-', width: double.infinity, isPar: true, isOnTeeColor: selectedTeeName != null)),
                SizedBox(width: 40, child: _buildCell(context, '$totalPar', width: 40, isBold: true, isOnTeeColor: selectedTeeName != null)),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // SI row
          Row(
            children: [
              SizedBox(width: 50, child: _buildCellLabel('SI', width: 50)),
              for (int i = 0; i < 9; i++)
                Expanded(child: _buildCell(context, i < sis.length ? '${sis[i]}' : '-', width: double.infinity)),
              SizedBox(width: 40, child: _buildCell(context, '', width: 40)),
            ],
          ),
          const Divider(height: 1),
          
          // Score row (user input - placeholder for now)
          Row(
            children: [
              SizedBox(width: 50, child: _buildCellLabel('Score', width: 50)),
              for (int i = 0; i < 9; i++)
                Expanded(child: _buildCell(context, nineScores[i]?.toString() ?? '-', width: double.infinity, isScore: true)),
              SizedBox(width: 40, child: _buildCell(context, totalScore > 0 ? '$totalScore' : '-', width: 40, isBold: true, isScore: true)),
            ],
          ),
          
          // Stableford Points row (only if Stableford competition)
          if (isStableford)
            const Divider(height: 1),
          if (isStableford)
            Row(
              children: [
                SizedBox(width: 50, child: _buildCellLabel('Points', width: 50)),
                for (int i = 0; i < 9; i++)
                  Expanded(child: _buildCell(context, (i < stablefordPoints.length) ? (stablefordPoints[i]?.toString() ?? '-') : '-', width: double.infinity, isPoints: true)),
                SizedBox(width: 40, child: _buildCell(context, totalPoints > 0 ? '$totalPoints' : '-', width: 40, isBold: true, isPoints: true)),
              ],
            ),
        ],
      );
  }

  Widget _buildTotalsRow(BuildContext context, int totalPar) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'Par $totalPar',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCellHeader(String text, {double width = 30, bool isBold = false}) {
    return SizedBox(
      width: width,
      height: 24,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildCellLabel(String text, {double width = 50, bool isOnTeeColor = false}) {
    return SizedBox(
      width: width,
      height: 28,
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isOnTeeColor ? FontWeight.w900 : FontWeight.w800,
              color: isOnTeeColor ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, String text, {double width = 30, bool isBold = false, bool isPar = false, bool isSmall = false, bool isScore = false, bool isPoints = false, bool isOnTeeColor = false}) {
    return SizedBox(
      width: width,
      height: 28,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 8 : 10,
            fontWeight: isBold ? FontWeight.w900 : (isPar ? FontWeight.w800 : FontWeight.normal),
            color: isOnTeeColor
                ? Colors.white
                : (isPoints
                    ? Colors.green[700]
                    : (isScore 
                        ? Theme.of(context).primaryColor 
                        : (isPar ? Colors.black87 : Colors.grey[700]))),
          ),
        ),
      ),
    );
  }

  Color _getTeeColor(String teeName) {
    final name = teeName.toLowerCase();
    if (name.contains('black')) return Colors.black;
    if (name.contains('blue')) return Colors.blue;
    if (name.contains('white')) return Colors.grey[600]!;
    if (name.contains('yellow')) return Colors.amber;
    if (name.contains('red')) return Colors.red;
    if (name.contains('green')) return Colors.green;
    return Colors.grey;
  }
}
