import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/models/golf_event.dart';
import 'package:golf_society/models/member.dart';
import 'package:collection/collection.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final primary = Theme.of(context).primaryColor;

    return HeadlessScaffold(
      title: 'Society Reports',
      subtitle: 'Performance & Participation Overview',
      showBack: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Core Society Stats
              const BoxyArtSectionTitle(title: 'SOCIETY OVERVIEW', padding: EdgeInsets.only(bottom: 16)),
              _buildSocietyStats(membersAsync, eventsAsync, primary),
              
              // 2. Season Standings Preview
              const BoxyArtSectionTitle(title: 'SEASON STANDINGS', padding: EdgeInsets.only(bottom: 16)),
              _buildSeasonStandingsPreview(context, ref, primary),

              const SizedBox(height: 32),

              // 3. Event Specific Reports (Quick Access)
              const BoxyArtSectionTitle(title: 'EVENT REPORTS', padding: EdgeInsets.only(bottom: 16)),
              eventsAsync.when(
                data: (List<GolfEvent> events) {
                  final sortedEvents = events.sortedBy((e) => e.date).reversed.toList();
                  return ModernCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: sortedEvents.take(5).mapIndexed((index, event) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.analytics_rounded, color: primary, size: 20),
                              ),
                              title: Text(
                                event.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                event.courseName ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.push('/admin/events/manage/${event.id}/reports'),
                            ),
                            if (index < 4 && index < sortedEvents.length - 1)
                              const Divider(height: 1, indent: 64),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading events: $err'),
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSocietyStats(AsyncValue<List<Member>> membersAsync, AsyncValue<List<GolfEvent>> eventsAsync, Color primary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ReportMetricCard(
                label: 'TOTAL MEMBERS',
                value: membersAsync.when(
                  data: (members) => members.length.toString(),
                  loading: () => '...',
                  error: (err, stack) => '!',
                ),
                icon: Icons.people_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ReportMetricCard(
                label: 'TOTAL EVENTS',
                value: eventsAsync.when(
                  data: (events) => events.length.toString(),
                  loading: () => '...',
                  error: (err, stack) => '!',
                ),
                icon: Icons.calendar_month_rounded,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: eventsAsync.when(
                data: (List<GolfEvent> events) {
                  final now = DateTime.now();
                  int confirmedCount = 0;
                  for (final e in events) {
                    if (e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)) {
                      confirmedCount += e.registrations.where((r) => r.attendingGolf && r.statusOverride != 'waitlist').length;
                    }
                  }
                  return _ReportMetricCard(
                    label: 'ACTIVE SIGN-UPS',
                    value: confirmedCount.toString(),
                    icon: Icons.assignment_turned_in_rounded,
                    color: Colors.teal,
                  );
                },
                loading: () => _ReportMetricCard(label: 'ACTIVE SIGN-UPS', value: '...', icon: Icons.assignment_turned_in_rounded, color: Colors.teal),
                error: (err, stack) => _ReportMetricCard(label: 'ACTIVE SIGN-UPS', value: '!', icon: Icons.assignment_turned_in_rounded, color: Colors.teal),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: eventsAsync.when(
                data: (List<GolfEvent> events) {
                  final now = DateTime.now();
                  int waitlistCount = 0;
                  for (final e in events) {
                    if (e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)) {
                      waitlistCount += e.registrations.where((r) => r.statusOverride == 'waitlist').length;
                    }
                  }
                  return _ReportMetricCard(
                    label: 'WAITLIST TOTAL',
                    value: waitlistCount.toString(),
                    icon: Icons.hourglass_empty_rounded,
                    color: Colors.amber,
                  );
                },
                loading: () => _ReportMetricCard(label: 'WAITLIST TOTAL', value: '...', icon: Icons.hourglass_empty_rounded, color: Colors.amber),
                error: (err, stack) => _ReportMetricCard(label: 'WAITLIST TOTAL', value: '!', icon: Icons.hourglass_empty_rounded, color: Colors.amber),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        membersAsync.when(
          data: (List<Member> members) {
            if (members.isEmpty) return _ReportMetricCard(label: 'AVG SOCIETY HCP', value: '0.0', icon: Icons.analytics_rounded, color: Colors.indigo);
            final totalHcp = members.fold<double>(0.0, (sum, m) => sum + m.handicap);
            final avg = totalHcp / members.length;
            return _ReportMetricCard(
              label: 'AVERAGE SOCIETY HANDICAP',
              value: avg.toStringAsFixed(1),
              icon: Icons.analytics_rounded,
              color: Colors.indigo,
              fullWidth: true,
            );
          },
          loading: () => _ReportMetricCard(label: 'AVG SOCIETY HCP', value: '...', icon: Icons.analytics_rounded, color: Colors.indigo, fullWidth: true),
          error: (err, stack) => _ReportMetricCard(label: 'AVG SOCIETY HCP', value: '!', icon: Icons.analytics_rounded, color: Colors.indigo, fullWidth: true),
        ),
      ],
    );
  }

  Widget _buildSeasonStandingsPreview(BuildContext context, WidgetRef ref, Color primary) {
    final activeSeasonAsync = ref.watch(activeSeasonProvider);

    return activeSeasonAsync.when(
      data: (season) {
        if (season == null || season.leaderboards.isEmpty) {
          return const ModernCard(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No active season leaderboards')),
          );
        }

        final primaryConfig = season.leaderboards.first;

        return ModernCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.emoji_events_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          primaryConfig.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5),
                        ),
                        Text(
                          'Primary Society Standings',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/admin/competitions'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Manage All Season Standings',
                      style: TextStyle(fontWeight: FontWeight.bold, color: primary),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: primary),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _ReportMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      padding: const EdgeInsets.all(20),
      border: BorderSide(color: color.withValues(alpha: 0.1)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodySmall?.color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
