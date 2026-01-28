import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/golf_event.dart';
import 'home_providers.dart';
import 'widgets/home_notification_card.dart';

class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Top 2 unread notifications
    final notificationsAsync = ref.watch(homeNotificationsProvider);
    
    final nextMatch = ref.watch(homeNextMatchProvider);
    final topPlayers = ref.watch(homeLeaderboardProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match provided aesthetic
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allNotifications) {
          final unreadNotifications = allNotifications
              .where((n) => !n.isRead)
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          final homeNotifications = unreadNotifications.take(2).toList();
          
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                title: Text(
                  'Golf Society',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.admin_panel_settings_outlined, color: Theme.of(context).iconTheme.color),
                    tooltip: 'Admin Console',
                    onPressed: () => context.push('/admin'),
                  ),
                  IconButton(
                    icon: Badge(
                      label: Text('${unreadNotifications.length}'),
                      isLabelVisible: unreadNotifications.isNotEmpty,
                      child: Icon(Icons.notifications_outlined, color: Theme.of(context).iconTheme.color),
                    ),
                    onPressed: () => context.push('/home/notifications'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
    
              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Notifications Section (Dynamic)
                    if (homeNotifications.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(context, 'Notifications'),
                          TextButton(
                            onPressed: () => context.push('/home/notifications'),
                            child: const Text('View All', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...homeNotifications.map((n) => HomeNotificationCard(notification: n)),
                      const SizedBox(height: 24),
                    ],
    
                    // Next Match Hero Card
                    _buildSectionHeader(context, 'Next Match'),
                    const SizedBox(height: 12),
                    nextMatch.when(
                      data: (event) {
                        if (event == null) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No upcoming matches scheduled.'),
                            ),
                          );
                        }
                        return _NextMatchCard(event: event);
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                const SizedBox(height: 24),

                // Leaderboard Snippet
                _buildSectionHeader(context, 'Order of Merit - Top 3'),
                const SizedBox(height: 12),
                _LeaderboardSnippet(topPlayers: topPlayers),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _NextMatchCard extends StatelessWidget {
  final GolfEvent event;

  const _NextMatchCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Sleek black as seen in premium golf apps
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.golf_course, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPCOMING MATCH',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(context, Icons.location_on_outlined, event.courseName ?? 'TBA'),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined, 
            DateFormat('EEEE, MMMM d, y').format(event.date),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.go('/events');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardSnippet extends StatelessWidget {
  final List<Map<String, dynamic>> topPlayers;

  const _LeaderboardSnippet({required this.topPlayers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...topPlayers.map((player) => _buildPlayerRow(context, player)),
          const SizedBox(height: 12),
          const Divider(),
          TextButton(
            onPressed: () {
              context.go('/archive'); 
            },
            child: const Text('Full Standings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(BuildContext context, Map<String, dynamic> player) {
    final position = player['position'] as int;
    final isFirst = position == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isFirst ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: isFirst ? Colors.black : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              player['name'] as String,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Text(
            '${player['points']}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
