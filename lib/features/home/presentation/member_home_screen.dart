import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/golf_event.dart';
import '../../../models/notification.dart';
import 'home_providers.dart';

class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(homeNotificationsProvider);
    final nextMatch = ref.watch(homeNextMatchProvider);
    final topPlayers = ref.watch(homeLeaderboardProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: const Text('Golf Society'),
            actions: [
              IconButton(
                icon: Badge(
                  label: Text('${notifications.where((n) => !n.isRead).length}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  // Navigate to Locker/Notifications or show modal
                  // For now, we'll just show a snackbar or navigate to members as placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Notifications Section
                if (notifications.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Notifications'),
                  const SizedBox(height: 8),
                  ...notifications.take(3).map((notification) => 
                    _NotificationCard(notification: notification)
                  ),
                  const SizedBox(height: 24),
                ],

                // Next Match Hero Card
                _buildSectionHeader(context, 'Next Match'),
                const SizedBox(height: 8),
                _NextMatchCard(event: nextMatch),
                const SizedBox(height: 24),

                // Leaderboard Snippet
                _buildSectionHeader(context, 'Order of Merit - Top 3'),
                const SizedBox(height: 8),
                _LeaderboardSnippet(topPlayers: topPlayers),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead 
              ? Colors.grey.shade300 
              : Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.info_outline,
            color: notification.isRead ? Colors.grey : Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // Navigate to details if actionUrl exists, or just mark read
          // Placeholder action
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

class _NextMatchCard extends StatelessWidget {
  final GolfEvent event;

  const _NextMatchCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/events');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.golf_course, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.location_on, event.location),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today, 
                DateFormat('EEEE, MMMM d, y').format(event.date),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time, 
                'Tee-off: ${DateFormat('h:mm a').format(event.teeOffTime ?? event.date)}',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.go('/events');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...topPlayers.map((player) => _buildPlayerRow(context, player)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to full stats/standings
                // Assuming this might be under Archive or a sub-tab
                context.go('/archive'); 
              },
              child: const Text('View Full Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(BuildContext context, Map<String, dynamic> player) {
    final position = player['position'] as int;
    final isFirst = position == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFirst ? Colors.amber : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isFirst
                  ? const Icon(Icons.emoji_events, color: Colors.white)
                  : Text(
                      '$position',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              player['name'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${player['points']} pts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
