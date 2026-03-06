
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'compose_notification_screen.dart';
import 'audience_manager_screen.dart';
import 'notification_history_screen.dart';
import 'survey_manager_screen.dart';

class NotificationAdminScaffold extends StatefulWidget {
  const NotificationAdminScaffold({super.key});

  @override
  State<NotificationAdminScaffold> createState() => _NotificationAdminScaffoldState();
}

class _NotificationAdminScaffoldState extends State<NotificationAdminScaffold> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const NotificationHistoryScreen(),
    const ComposeNotificationScreen(isTabbed: true),
    const AudienceManagerScreen(),
    const SurveyManagerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return HeadlessScaffold(
      useScaffold: false,
      title: 'Communications',
      actions: [
        if (_currentIndex == 0)
          BoxyArtGlassIconButton(
            icon: Icons.add_rounded,
            onPressed: () => setState(() => _currentIndex = 1),
            tooltip: 'New Notification',
          ),
      ],
      leading: Center(
        child: BoxyArtGlassIconButton(
          icon: Icons.home_rounded,
          onPressed: () => context.go('/home'),
          tooltip: 'App Home',
        ),
      ),
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: const [
          BoxyArtBottomNavItem(
            icon: Icons.history_rounded,
            activeIcon: Icons.history_toggle_off_rounded,
            label: 'History',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.send_outlined,
            activeIcon: Icons.send_rounded,
            label: 'Compose',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: 'Audience',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: 'Surveys',
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
