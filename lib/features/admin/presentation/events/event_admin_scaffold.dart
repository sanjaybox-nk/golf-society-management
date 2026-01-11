import 'package:flutter/material.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import 'tabs/event_dashboard_tab.dart';

class EventAdminScaffold extends StatefulWidget {
  const EventAdminScaffold({super.key});

  @override
  State<EventAdminScaffold> createState() => _EventAdminScaffoldState();
}

class _EventAdminScaffoldState extends State<EventAdminScaffold> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const EventDashboardTab(),
    const Center(child: Text('Event List (Coming Soon)')),
    const Center(child: Text('Results Entry (Coming Soon)')),
    const Center(child: Text('Event Settings (Coming Soon)')),
  ];

  final List<String> _titles = [
    'Event Analytics',
    'Manage Events',
    'Enter Results',
    'Event Templates',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BoxyArtAppBar(
        title: _titles[_currentIndex],
        showBack: true,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
