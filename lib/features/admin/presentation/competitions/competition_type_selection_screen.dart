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
    final title = (isTemplate || isPicker) ? 'Select Game Type' : 'New Template Type';
    
    return HeadlessScaffold(
      title: title,
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (formatFilter == null || formatFilter == 'stableford') ...[
                _TypeTile(
                  title: 'Stableford',
                  subtitle: 'Points based on handicap. Best for mixed ability.',
                  icon: Icons.format_list_numbered,
                  color: Colors.orange,
                  onTap: () => _navigateToBuilder(context, CompetitionFormat.stableford),
                ),
                const SizedBox(height: 16),
              ],
              
              if (formatFilter == null || formatFilter == 'stroke') ...[
                _TypeTile(
                  title: 'Stroke Play (Medal)',
                  subtitle: 'Count every shot. The pure test of golf.',
                  icon: Icons.golf_course,
                  color: Colors.blue,
                  onTap: () => _navigateToBuilder(context, CompetitionFormat.stroke),
                ),
                const SizedBox(height: 16),
              ],
              
              if (formatFilter == null || formatFilter == 'maxScore') ...[
                _TypeTile(
                  title: 'Max Score',
                  subtitle: 'Stroke play with a cap per hole (e.g. Par + 3).',
                  icon: Icons.vertical_align_top,
                  color: Colors.teal,
                  onTap: () => _navigateToBuilder(context, CompetitionFormat.maxScore),
                ),
                const SizedBox(height: 16),
              ],

              if (formatFilter == null) ...[
                const SizedBox(height: 16),
                const BoxyArtSectionTitle(
                  title: 'HEAD-TO-HEAD',
                  padding: EdgeInsets.only(left: 4, bottom: 16),
                ),
                _TypeTile(
                  title: 'Match Play',
                  subtitle: 'Hole-by-hole knockout battles.',
                  icon: Icons.compare_arrows,
                  color: Colors.redAccent,
                  onTap: () => _navigateToBuilder(context, CompetitionFormat.matchPlay),
                ),
                const SizedBox(height: 16),
              ],

              if (formatFilter == null) ...[
                const SizedBox(height: 16),
                const BoxyArtSectionTitle(
                  title: 'PAIRS FORMATS',
                  padding: EdgeInsets.only(left: 4, bottom: 16),
                ),
                _TypeTile(
                  title: 'Fourball (Better Ball)',
                  subtitle: 'Pairs play own ball. Best score counts.',
                  icon: Icons.people_outline,
                  color: Colors.indigo,
                  onTap: () => _navigateToBuilder(context, CompetitionSubtype.fourball),
                ),
                const SizedBox(height: 16),
                _TypeTile(
                  title: 'Foursomes (Alternate Shot)',
                  subtitle: 'Partners alternate hitting one ball.',
                  icon: Icons.sync_alt,
                  color: Colors.indigoAccent,
                  onTap: () => _navigateToBuilder(context, CompetitionSubtype.foursomes),
                ),
                const SizedBox(height: 16),
              ],

              if (formatFilter == null) ...[
                const SizedBox(height: 16),
                const BoxyArtSectionTitle(
                  title: 'TEAM FORMATS',
                  padding: EdgeInsets.only(left: 4, bottom: 16),
                ),
                _TypeTile(
                  title: 'Scramble',
                  subtitle: 'Texas/Florida Scramble. Team aggregate play.',
                  icon: Icons.group_work,
                  color: Colors.purple,
                  onTap: () => _navigateToBuilder(context, CompetitionFormat.scramble),
                ),
                const SizedBox(height: 16),
              ],
              
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
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
    final parts = title.split(' (');
    final mainTitle = parts[0];
    final bracketText = parts.length > 1 ? '(${parts[1]}' : null;

    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Icon Avatar with soft background
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      mainTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (bracketText != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        bracketText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded, 
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
