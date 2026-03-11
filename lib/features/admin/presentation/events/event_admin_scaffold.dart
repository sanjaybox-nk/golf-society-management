import 'package:golf_society/design_system/design_system.dart';
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
    'Events',
    'Enter Results',
    'Event Templates',
  ];

  @override
  Widget build(BuildContext context) {
    return HeadlessScaffold(
      title: _titles[_currentIndex],
      showBack: true,
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: const [
          BoxyArtBottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Events',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            label: 'Results',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
      slivers: [
        SliverFillRemaining(
          child: _tabs[_currentIndex],
        ),
      ],
    );
  }
}
