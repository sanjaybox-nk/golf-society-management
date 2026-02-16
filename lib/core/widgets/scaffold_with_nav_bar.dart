import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/contrast_helper.dart';
import './boxy_art_nav_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // Get current theme color for status bar contrast
    final currentThemeColor = Theme.of(context).primaryColor;
    final statusBarIconBrightness = ContrastHelper.getContrastingText(currentThemeColor) == Colors.white
        ? Brightness.light  // White icons for dark backgrounds
        : Brightness.dark;  // Black icons for light backgrounds
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Let the background shine through
        statusBarIconBrightness: statusBarIconBrightness,
      ),
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: BoxyArtBottomNavBar(
          selectedIndex: navigationShell.currentIndex,
          onItemSelected: (index) => _onTap(context, index),
          items: const [
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
          ],
        ),
      ),
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, the initial location of that branch
    // is used.
    // If the user taps the item that is already selected, the app navigates
    // to the initial location of the branch (e.g. pop to root).
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
