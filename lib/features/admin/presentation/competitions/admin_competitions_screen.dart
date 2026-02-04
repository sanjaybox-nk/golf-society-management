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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CompetitionsList(status: CompetitionStatus.open), // LIVE
                  _CompetitionsList(status: CompetitionStatus.draft), // UPCOMING
                  _CompetitionsList(status: CompetitionStatus.published), // HISTORY (Closed)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BoxyArtFloatingCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEADERBOARDS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Live scoring and results',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => context.push('/admin/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).primaryColor,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'LIVE'),
        Tab(text: 'UPCOMING'),
        Tab(text: 'HISTORY'),
      ],
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
          padding: const EdgeInsets.all(24),
          itemCount: comps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final comp = comps[index];
            return BoxyArtFloatingCard(
              onTap: () => context.push('/admin/competitions/manage/${comp.id}'),
              border: Border.all(color: Colors.white10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildFormatBadge(comp.rules.format),
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
                          Text(
                            comp.rules.format.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 18, 
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white24),
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

  Widget _buildFormatBadge(CompetitionFormat format) {
    IconData icon;
    switch (format) {
      case CompetitionFormat.stroke: icon = Icons.golf_course; break;
      case CompetitionFormat.stableford: icon = Icons.format_list_numbered; break;
      case CompetitionFormat.maxScore: icon = Icons.vertical_align_top; break;
      case CompetitionFormat.matchPlay: icon = Icons.compare_arrows; break;
      case CompetitionFormat.scramble: icon = Icons.group_work; break;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
