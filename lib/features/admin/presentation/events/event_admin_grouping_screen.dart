import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class EventAdminGroupingScreen extends StatelessWidget {
  final String eventId;

  const EventAdminGroupingScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Event Grouping',
        showBack: true,
        onBack: () => context.go('/admin/events'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tee Sheet Grouping',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon: Manage groups and tee times.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
