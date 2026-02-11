import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/competition.dart';
import '../../../competitions/presentation/competitions_provider.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'Leaderboards',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              leading: IconButton(
                icon: const Icon(Icons.home_rounded, size: 24),
                onPressed: () => context.go('/home'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_rounded, size: 22),
                  onPressed: () => context.push('/admin/settings'),
                ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
                indicatorColor: Theme.of(context).primaryColor,
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
          ],
          body: const TabBarView(
            children: [
              _CompetitionsList(status: CompetitionStatus.open),
              _CompetitionsList(status: CompetitionStatus.draft),
              _CompetitionsList(status: CompetitionStatus.published),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetitionsList extends ConsumerWidget {
  final CompetitionStatus status;

  const _CompetitionsList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compsAsync = ref.watch(competitionsListProvider(status));

    return compsAsync.when(
      data: (comps) {
        if (comps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No ${status.name} competitions', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: comps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final comp = comps[index];
            return ModernCard(
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
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
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
