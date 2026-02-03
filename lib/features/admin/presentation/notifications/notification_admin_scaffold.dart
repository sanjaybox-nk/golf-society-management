import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import 'compose_notification_screen.dart';
import 'audience_manager_screen.dart';
import 'notification_history_screen.dart';

class NotificationAdminScaffold extends StatefulWidget {
  const NotificationAdminScaffold({super.key});

  @override
  State<NotificationAdminScaffold> createState() => _NotificationAdminScaffoldState();
}

class _NotificationAdminScaffoldState extends State<NotificationAdminScaffold> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const ComposeNotificationScreen(isTabbed: true),
    const AudienceManagerScreen(),
    const NotificationHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Communications',
        isLarge: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white, size: 28),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/admin/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            activeIcon: Icon(Icons.send_rounded),
            label: 'Compose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Audience',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history_toggle_off_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
