import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../../models/golf_event.dart';

class EventAdminScoresScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminScoresScreen> createState() => _EventAdminScoresScreenState();
}

class _EventAdminScoresScreenState extends ConsumerState<EventAdminScoresScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));

    return eventAsync.when(
      data: (event) => Scaffold(
        appBar: BoxyArtAppBar(
          title: 'Event Scores',
          subtitle: event.title,
          centerTitle: true,
          isLarge: true,
          leadingWidth: 70,
          leading: Center(
            child: TextButton(
              onPressed: () => context.canPop() ? context.pop() : context.go('/admin/events'),
              child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  _buildTabButton('Controls', 0, Icons.settings_outlined),
                  _buildTabButton('Leaderboard', 1, Icons.emoji_events_outlined),
                  _buildTabButton('Scorecards', 2, Icons.people_outline),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildTabContent(event),
        ),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(GolfEvent event) {
    switch (_selectedTab) {
      case 0: // Controls
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(event),
            const SizedBox(height: 24),
            const BoxyArtSectionTitle(title: 'SCORING CONTROLS'),
            const SizedBox(height: 12),
            BoxyArtFloatingCard(
              child: Column(
                children: [
                  _buildControlRow(
                    context,
                    icon: Icons.rocket_launch,
                    title: 'Force Scoring Active',
                    subtitle: 'Allow players to enter scores before the scheduled date.',
                    value: event.scoringForceActive == true,
                    onChanged: (val) {
                      ref.read(eventsRepositoryProvider).updateEvent(
                        event.copyWith(scoringForceActive: val),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildControlRow(
                    context,
                    icon: Icons.lock_person,
                    title: 'Lock Final Scores',
                    subtitle: 'Prevent all players from making further edits to their scorecards.',
                    value: event.isScoringLocked == true,
                    onChanged: (val) {
                       ref.read(eventsRepositoryProvider).updateEvent(
                        event.copyWith(isScoringLocked: val),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      case 1: // Leaderboard
        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'LIVE STANDINGS'),
            const SizedBox(height: 16),
            const BoxyArtFloatingCard(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('Admin Leaderboard View Coming Soon'),
                ),
              ),
            ),
          ],
        );
      case 2: // Scorecards
        return Column(
          children: [
            const BoxyArtSectionTitle(title: 'PLAYER SCORECARDS'),
            const SizedBox(height: 12),
            BoxyArtFloatingCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'Scorecard Management',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Soon you will be able to override and review individual player scorecards here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusHeader(GolfEvent event) {
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            'STATUS', 
            (event.isScoringLocked == true) ? 'LOCKED' : ((event.scoringForceActive == true) ? 'LIVE (MANUAL)' : 'PENDING'),
            (event.isScoringLocked == true) ? Colors.red : ((event.scoringForceActive == true) ? Colors.green : Colors.orange),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBadgeCard(
            'SUBMITTED', 
            '12 / 24', // Mocking for now
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String label, String value, Color color) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value, 
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
