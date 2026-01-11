import 'package:flutter/material.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/theme/app_theme.dart';
import 'compose_notification_screen.dart';
import 'audience_manager_screen.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.send_rounded),
              label: 'Compose',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Audience',
            ),
          ],
        ),
      ),
    );
  }
}
