import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class EventAdminScoresScreen extends StatelessWidget {
  final String eventId;

  const EventAdminScoresScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Event Scores',
        centerTitle: true,
        showBack: true,
        onBack: () => context.go('/admin/events'),
        isLarge: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Event Results & Scores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon: Enter scores and view leaderboards.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
