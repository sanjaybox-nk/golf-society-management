import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/competition.dart';

class CompetitionTypeSelectionScreen extends StatelessWidget {
  final bool isTemplate;
  final bool isPicker;
  final String? formatFilter;

  const CompetitionTypeSelectionScreen({
    super.key, 
    this.isTemplate = false,
    this.isPicker = false,
    this.formatFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BoxyArtAppBar(
        title: (isTemplate || isPicker) ? 'SELECT GAME TYPE' : 'NEW TEMPLATE TYPE',
        centerTitle: true,
        showBack: true,
        isLarge: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (formatFilter == null || formatFilter == 'stableford')
              _TypeTile(
                title: 'Stableford',
                subtitle: 'Points based on handicap. Best for mixed ability.',
                icon: Icons.format_list_numbered,
                color: Colors.orange,
                onTap: () => _navigateToBuilder(context, CompetitionFormat.stableford),
              ),
            if (formatFilter == null || formatFilter == 'stableford')
              const SizedBox(height: 16),
            
            if (formatFilter == null || formatFilter == 'stroke')
              _TypeTile(
                title: 'Stroke Play (Medal)',
                subtitle: 'Count every shot. The pure test of golf.',
                icon: Icons.golf_course,
                color: Colors.blue,
                onTap: () => _navigateToBuilder(context, CompetitionFormat.stroke),
              ),
            if (formatFilter == null || formatFilter == 'stroke')
              const SizedBox(height: 16),
            
            if (formatFilter == null || formatFilter == 'maxScore')
              _TypeTile(
                title: 'Max Score',
                subtitle: 'Stroke play with a cap per hole (e.g. Par + 3).',
                icon: Icons.vertical_align_top,
                color: Colors.teal,
                onTap: () => _navigateToBuilder(context, CompetitionFormat.maxScore),
              ),
            if (formatFilter == null || formatFilter == 'maxScore')
              const SizedBox(height: 16),

            if (formatFilter == null)
              const BoxyArtSectionTitle(
                title: 'HEAD-TO-HEAD',
                padding: EdgeInsets.only(top: 16, bottom: 16),
              ),
            
            if (formatFilter == null || formatFilter == 'matchPlay')
              _TypeTile(
                title: 'Match Play',
                subtitle: 'Hole-by-hole knockout battles.',
                icon: Icons.compare_arrows,
                color: Colors.redAccent,
                onTap: () => _navigateToBuilder(context, CompetitionFormat.matchPlay),
              ),
            if (formatFilter == null || formatFilter == 'matchPlay')
              const SizedBox(height: 16),

            if (formatFilter == null)
              const BoxyArtSectionTitle(
                title: 'PAIRS FORMATS',
                padding: EdgeInsets.only(top: 16, bottom: 16),
              ),
            
            if (formatFilter == null)
              _TypeTile(
                title: 'Fourball (Better Ball)',
                subtitle: 'Pairs play own ball. Best score counts.',
                icon: Icons.people_outline,
                color: Colors.indigo,
                onTap: () => _navigateToBuilder(context, CompetitionSubtype.fourball),
              ),
            if (formatFilter == null)
              const SizedBox(height: 16),
            
            if (formatFilter == null)
              _TypeTile(
                title: 'Foursomes (Alternate Shot)',
                subtitle: 'Partners alternate hitting one ball.',
                icon: Icons.sync_alt,
                color: Colors.indigoAccent,
                onTap: () => _navigateToBuilder(context, CompetitionSubtype.foursomes),
              ),
            if (formatFilter == null)
              const SizedBox(height: 16),

            if (formatFilter == null)
              const BoxyArtSectionTitle(
                title: 'TEAM FORMATS',
                padding: EdgeInsets.only(top: 16, bottom: 16),
              ),
            
            if (formatFilter == null || formatFilter == 'scramble')
              _TypeTile(
                title: 'Scramble',
                subtitle: 'Texas/Florida Scramble. Team aggregate play.',
                icon: Icons.group_work,
                color: Colors.purple,
                onTap: () => _navigateToBuilder(context, CompetitionFormat.scramble),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _navigateToBuilder(BuildContext context, dynamic type) async {
    // type can be CompetitionFormat or CompetitionSubtype
    final typeName = type is CompetitionFormat ? type.name : (type as CompetitionSubtype).name;
    
    final base = isPicker ? '/admin/events/competitions/new/gallery' : '/admin/settings/templates/gallery';
    final result = await context.push<String>('$base/$typeName');
    
    if (isPicker && result != null && context.mounted) {
      context.pop(result);
    }
  }
}

class _TypeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // White Card Layout matching MemberTile
    const backgroundColor = Colors.white;
    const textColor = Colors.black87;
    const subTextColor = Colors.black54;

    final parts = title.split(' (');
    final mainTitle = parts[0];
    final bracketText = parts.length > 1 ? '(${parts[1]}' : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]),
        child: Row(
          children: [
            // Icon Avatar matching MemberTile size
            CircleAvatar(
              radius: 28, // Matches MemberTile radius
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (bracketText != null) ...[
                    Text(
                      bracketText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: subTextColor),
          ],
        ),
      ),
    );
  }
}
