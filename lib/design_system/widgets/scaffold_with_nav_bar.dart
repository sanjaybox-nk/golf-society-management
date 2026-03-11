import "package:golf_society/design_system/design_system.dart";



import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/design_system/constants/navigation_constants.dart';

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
    final statusBarIconBrightness = ContrastHelper.getContrastingText(currentThemeColor) == AppColors.pureWhite
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
          items: NavigationConstants.userNavItems,
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
