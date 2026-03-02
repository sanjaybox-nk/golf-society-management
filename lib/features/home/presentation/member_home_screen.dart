import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';

import 'package:golf_society/domain/models/golf_event.dart';
import 'home_providers.dart';
import 'widgets/home_notification_card.dart';
import '../../members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';

class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveUser = ref.watch(effectiveUserProvider);
    final isPeeking = ref.watch(impersonationProvider) != null;
    
    // Top 2 unread notifications
    final notificationsAsync = ref.watch(homeNotificationsProvider);
    
    final nextMatch = ref.watch(homeNextMatchProvider);
    final topPlayers = ref.watch(homeSeasonLeaderboardProvider);
    final personalStanding = ref.watch(homeMemberStandingProvider);
    final societyConfig = ref.watch(themeControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match provided aesthetic
      body: Column(
        children: [
          if (isPeeking)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.amber.shade700,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Peeking as ${effectiveUser.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(impersonationProvider.notifier).clear(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'EXIT PEEK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: notificationsAsync.when(
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
                      pinned: true, // Keep it pinned for a premium feel
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: false,
                      toolbarHeight: 80, // Taller app bar
                      flexibleSpace: ClipRect(
                        child:  BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            if (societyConfig.logoUrl != null) ...[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    societyConfig.logoUrl!,
                                    height: 48,
                                    width: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.golf_course, size: 42),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    effectiveUser.firstName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: const [
                        AdminShortcutAction(),
                        SizedBox(width: 8),
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
                                BoxyArtSectionTitle(
                                  title: 'Notifications',
                                  isPeeking: isPeeking,
                                ),
                                TextButton(
                                  onPressed: () => context.push('/home/notifications'),
                                  child: const Text('View All', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...homeNotifications.asMap().entries.map((entry) => StaggeredEntrance(
                              index: entry.key,
                              child: HomeNotificationCard(notification: entry.value),
                            )),
                            const SizedBox(height: 24),
                          ],
          
                          // Next Match Hero Card
                          BoxyArtSectionTitle(
                            title: 'Next Match',
                            isPeeking: isPeeking,
                          ),
                          const SizedBox(height: 12),
                          StaggeredEntrance(
                            index: homeNotifications.length, // Stagger after notifications
                            child: nextMatch.when(
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
                          ),
                      const SizedBox(height: 24),

                      // Leaderboard Snippet
                      BoxyArtSectionTitle(
                        title: 'Order of Merit',
                        isPeeking: isPeeking,
                      ),
                      const SizedBox(height: 12),
                      StaggeredEntrance(
                        index: homeNotifications.length + 1, // Stagger after match card
                        child: topPlayers.when(
                          data: (players) => _LeaderboardSnippet(
                            topPlayers: players,
                            personalStanding: personalStanding.value,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error loading standings: $err'),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class _NextMatchCard extends StatelessWidget {
  final GolfEvent event;

  const _NextMatchCard({required this.event});

  @override
  Widget build(BuildContext context) {

    
    return BoxyArtCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/events/${event.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    event.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMM').format(event.date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (event.registrations.any((r) => r.memberId == 'current-user-id'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Playing',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ModernInfoRow(
                  label: 'Course',
                  value: event.courseName ?? 'TBA',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 12),
                ModernInfoRow(
                  label: 'Tee Off',
                  value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(height: 20),
                BoxyArtButton(
                  title: 'View Details',
                  isPrimary: true,
                  onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSnippet extends StatelessWidget {
  final List<Map<String, dynamic>> topPlayers;
  final LeaderboardStanding? personalStanding;

  const _LeaderboardSnippet({required this.topPlayers, this.personalStanding});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isPersonalInTop3 = topPlayers.any((p) => p['name'] == personalStanding?.memberName);

    return BoxyArtCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topPlayers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                   Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey.shade400),
                   const SizedBox(width: 8),
                   Text(
                     'No standings recorded yet.',
                     style: TextStyle(
                       fontSize: 13,
                       color: Colors.grey.shade500,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                ],
              ),
            ),

          ...topPlayers.map((player) {
            final position = player['position'] as int;
            final isFirst = position == 1;
            final isMe = player['name'] == personalStanding?.memberName;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isMe 
                        ? Colors.blue.withValues(alpha: 0.15)
                        : (isFirst ? primary.withValues(alpha: 0.15) : Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isFirst 
                        ? Icon(Icons.emoji_events_rounded, color: primary, size: 18)
                        : Text(
                            '$position',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isMe ? Colors.blue : (isFirst ? primary : Theme.of(context).textTheme.bodySmall?.color),
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
                        fontWeight: (isFirst || isMe) ? FontWeight.w900 : FontWeight.bold,
                        color: isMe ? Colors.blue : null,
                      ),
                    ),
                  ),
                  Text(
                    '${player['points']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isMe ? Colors.blue : (isFirst ? primary : null),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          if (!isPersonalInTop3 && personalStanding != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: const Icon(Icons.person_outline_rounded, size: 16, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Your Rank',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '#${personalStanding!.points.round()}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primary),
                ),
              ],
            ),
          ],

          if (topPlayers.isNotEmpty || personalStanding != null) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => context.push('/locker/standings'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Full Season Standings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: primary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Ready for the green,';
  if (hour < 17) return 'Perfect day for a round,';
  return 'Fore! Welcome back,';
}
