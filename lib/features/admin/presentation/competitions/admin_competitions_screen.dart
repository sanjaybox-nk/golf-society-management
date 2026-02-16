import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/shared_ui/headless_scaffold.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/models/competition.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';

class AdminLeaderboardsScreen extends ConsumerStatefulWidget {
  const AdminLeaderboardsScreen({super.key});

  @override
  ConsumerState<AdminLeaderboardsScreen> createState() => _AdminLeaderboardsScreenState();
}

class _AdminLeaderboardsScreenState extends ConsumerState<AdminLeaderboardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    
    return DefaultTabController(
      length: 3,
      child: HeadlessScaffold(
        title: 'Leaderboards',
        subtitle: 'Society Competitions',
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(49),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: TabBar(
                  indicatorColor: primary,
                  indicatorWeight: 3,
                  labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                  unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'LIVE'),
                    Tab(text: 'UPCOMING'),
                    Tab(text: 'HISTORY'),
                  ],
                ),
              ),
            ),
          ),
          const _AdminLeaderboardsTabContent(),
        ],
      ),
    );
  }
}

class _AdminLeaderboardsTabContent extends ConsumerWidget {
  const _AdminLeaderboardsTabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = DefaultTabController.of(context);
    
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final status = _getStatusForIndex(tabController.index);
        return _CompetitionsSliverList(status: status);
      },
    );
  }

  CompetitionStatus _getStatusForIndex(int index) {
    switch (index) {
      case 0: return CompetitionStatus.open;
      case 1: return CompetitionStatus.draft;
      case 2: return CompetitionStatus.published;
      default: return CompetitionStatus.open;
    }
  }
}

class _CompetitionsSliverList extends ConsumerWidget {
  final CompetitionStatus status;
  const _CompetitionsSliverList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compsAsync = ref.watch(competitionsListProvider(status));

    return compsAsync.when(
      data: (comps) {
        if (comps.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No ${status.name} competitions', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final comp = comps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ModernCard(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () => context.push('/admin/competitions/manage/${comp.id}'),
                      borderRadius: BorderRadius.circular(24),
                      child: Row(
                        children: [
                          _buildFormatBadge(context, comp.rules.format),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${comp.startDate.year} • ${comp.rules.mode.name.toUpperCase()}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comp.name ?? comp.rules.format.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded, color: Theme.of(context).dividerColor),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: comps.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => SliverFillRemaining(
        child: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildFormatBadge(BuildContext context, CompetitionFormat format) {
    final primary = Theme.of(context).primaryColor;
    IconData icon;
    switch (format) {
      case CompetitionFormat.stroke: icon = Icons.golf_course_rounded; break;
      case CompetitionFormat.stableford: icon = Icons.format_list_numbered_rounded; break;
      case CompetitionFormat.maxScore: icon = Icons.vertical_align_top_rounded; break;
      case CompetitionFormat.matchPlay: icon = Icons.compare_arrows_rounded; break;
      case CompetitionFormat.scramble: icon = Icons.group_work_rounded; break;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: primary, size: 24),
    );
  }
}
