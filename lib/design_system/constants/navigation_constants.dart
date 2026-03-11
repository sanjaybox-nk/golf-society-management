import 'package:flutter/material.dart';
import 'package:golf_society/design_system/widgets/boxy_art_nav_bar.dart';

class NavigationConstants {
  static const List<BoxyArtBottomNavItem> adminNavItems = [
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
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Members',
    ),
    BoxyArtBottomNavItem(
      icon: Icons.notification_add_outlined,
      activeIcon: Icons.notification_add,
      label: 'Comms',
    ),
    BoxyArtBottomNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Reporting',
    ),
  ];

  static const List<BoxyArtBottomNavItem> userNavItems = [
    BoxyArtBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    BoxyArtBottomNavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Events',
    ),
    BoxyArtBottomNavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Members',
    ),
    BoxyArtBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Locker',
    ),
    BoxyArtBottomNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'Archive',
    ),
  ];
}
