import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/competition.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/competitions/utils/competition_rule_translator.dart';
import '../../../competitions/presentation/competitions_provider.dart';

class CompetitionTemplateGalleryScreen extends ConsumerWidget {
  final String typeStr;
  final bool isTemplate;
  final bool isPicker;

  const CompetitionTemplateGalleryScreen({
    super.key,
    required this.typeStr,
    this.isTemplate = false,
    this.isPicker = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtype = CompetitionSubtype.values.where((e) => e.name == typeStr).firstOrNull;
    final format = CompetitionFormat.values.where((e) => e.name == typeStr).firstOrNull ?? CompetitionFormat.stableford;
    
    final gameName = (subtype != null && subtype != CompetitionSubtype.none)
        ? subtype.name.toUpperCase()
        : format.name.toUpperCase();

    final templatesAsync = ref.watch(templatesListProvider);

    return HeadlessScaffold(
      title: gameName,
      subtitle: 'Choose a template or start blank',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Start Blank Card
              _buildGalleryCard(
                context,
                title: 'Start Blank',
                subtitle: 'Create a new $gameName from scratch',
                icon: Icons.add_circle_outline_rounded,
                isPrimary: true,
                onTap: () async {
                  if (isPicker) {
                      final result = await context.push<String>('/admin/events/competitions/new/create/$typeStr');
                      if (result != null && context.mounted) {
                        context.pop(result);
                      }
                  } else {
                    context.push('/admin/settings/templates/create/$typeStr');
                  }
                },
              ),

              templatesAsync.when(
                data: (templates) {
                  final filtered = templates.where((t) {
                      final rules = t.rules;
                      if (subtype != null && subtype != CompetitionSubtype.none) {
                        return rules.subtype == subtype;
                      }
                      // Scramble always has a non-none subtype (texas/florida),
                      // so match on format alone for formats that use subtypes internally.
                      if (format == CompetitionFormat.scramble) {
                        return rules.format == format;
                      }
                      return rules.format == format && rules.subtype == CompetitionSubtype.none;
                  }).toList();

                  if (filtered.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const BoxyArtSectionTitle(title: 'Saved Templates', padding: EdgeInsets.zero),
                      const SizedBox(height: 12),
                      ...filtered.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTemplateCard(context, t, ref),
                      )),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => Text('Error loading templates: $e'),
              ),

              const SizedBox(height: 32),
              const BoxyArtSectionTitle(title: 'System Presets', padding: EdgeInsets.zero),
              const SizedBox(height: 12),
              _buildGalleryCard(
                context,
                title: 'Standard $gameName',
                subtitle: 'The traditional configuration used by most societies',
                icon: Icons.auto_awesome_rounded,
                onTap: () async {
                  if (isPicker) {
                      final result = await context.push<String>('/admin/events/competitions/new/create/$typeStr');
                      if (result != null && context.mounted) {
                        context.pop(result);
                      }
                  } else {
                    context.push('/admin/settings/templates/create/$typeStr');
                  }
                },
                badges: [
                  _RuleBadge(label: CompetitionRules(
                    format: format, 
                    subtype: subtype ?? CompetitionSubtype.none,
                  ).defaultAllowanceLabel),
                  const _RuleBadge(label: '1 ROUND'),
                ],
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }


  Widget _buildTemplateCard(BuildContext context, Competition template, WidgetRef ref) {
    return Dismissible(
      key: Key(template.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Template?"),
            content: const Text("Are you sure you want to delete this template?"),
            actions: [
              TextButton(onPressed: () => context.pop(false), child: const Text("Cancel")),
              TextButton(
                onPressed: () => context.pop(true), 
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        ref.read(competitionsRepositoryProvider).deleteTemplate(template.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Template deleted"), duration: Duration(seconds: 2)),
        );
      },
      child: _buildGalleryCard(
        context,
        title: (template.name != null && template.name!.isNotEmpty) 
            ? template.name!.toUpperCase() 
            : template.rules.gameName,
        subtitle: '${template.rules.modeLabel} • ${template.rules.roundsCount} ROUND',
        description: CompetitionRuleTranslator.translate(template.rules),
        icon: _getFormatIcon(template.rules.format),
        onTap: () {
          if (isPicker) {
             // RETURN TO EVENT FORM WITH TEMPLATE ID
             context.pop(template.id);
          } else {
            context.push('/admin/settings/templates/edit/${template.id}');
          }
        },
        onChevronTap: () {
          context.push('/admin/settings/templates/edit/${template.id}');
        },
        badges: [
          // MODE BADGE (SINGLES/PAIRS/TEAMS)
          _RuleBadge(label: template.rules.modeLabel),
          
          // GROSS/NET
          if (template.rules.handicapAllowance == 0 || template.rules.subtype == CompetitionSubtype.grossStableford)
            const _RuleBadge(label: 'GROSS')
          else
            const _RuleBadge(label: 'NET'),

          // ALLOWANCE
          if (template.rules.format == CompetitionFormat.scramble && template.rules.useWHSScrambleAllowance)
            const _RuleBadge(label: 'WHS ALLOWANCE')
          else if (template.rules.handicapAllowance > 0)
            _RuleBadge(label: '${(template.rules.handicapAllowance * 100).toInt()}% HCP'),

          // HCP MODE
          if (template.rules.handicapMode != HandicapMode.whs)
            _RuleBadge(label: '${template.rules.handicapMode.name.toUpperCase()} HCP'),

          // CAP
          if (template.rules.handicapCap != 28)
            _RuleBadge(label: 'CAP: ${template.rules.handicapCap}'),

          // MAX SCORE
          if (template.rules.format == CompetitionFormat.maxScore && template.rules.maxScoreConfig != null)
             _RuleBadge(
               label: template.rules.maxScoreConfig!.type == MaxScoreType.fixed 
                 ? 'MAX ${template.rules.maxScoreConfig!.value}' 
                 : 'MAX PAR+${template.rules.maxScoreConfig!.value}'
             ),

          // SERIES/MULTI-ROUND
          if (template.rules.roundsCount > 1) ...[
            _RuleBadge(label: '${template.rules.roundsCount} ROUNDS'),
            _RuleBadge(
              label: template.rules.aggregation == AggregationMethod.singleBest 
                ? 'BEST ROUND' 
                : 'CUMULATIVE'
            ),
          ],

          // SCRAMBLE DRIVES
          if (template.rules.format == CompetitionFormat.scramble && template.rules.minDrivesPerPlayer > 0)
            _RuleBadge(label: 'MIN ${template.rules.minDrivesPerPlayer} DRIVES'),

          // TIE-BREAK
          _RuleBadge(label: template.rules.tieBreak.name.toUpperCase()),
        ],
      ),
    );
  }

  IconData _getFormatIcon(CompetitionFormat format) {
    switch (format) {
      case CompetitionFormat.stableford: return Icons.format_list_numbered;
      case CompetitionFormat.stroke: return Icons.golf_course;
      case CompetitionFormat.maxScore: return Icons.vertical_align_top;
      case CompetitionFormat.matchPlay: return Icons.compare_arrows;
      case CompetitionFormat.scramble: return Icons.group_work;
    }
  }

  Widget _buildGalleryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? description,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onChevronTap,
    bool isPrimary = false,
    List<Widget>? badges,
  }) {
    final theme = Theme.of(context);
    
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.dividerColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isPrimary ? theme.colorScheme.primary : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onChevronTap != null)
                IconButton(
                  onPressed: onChevronTap,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
            ],
          ),

          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],

          if (badges != null && badges.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 0, runSpacing: 8, children: badges),
          ],
        ],
      ),
    );
  }
}

class _RuleBadge extends StatelessWidget {
  final String label;
  const _RuleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
