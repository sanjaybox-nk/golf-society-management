
import 'package:flutter/material.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xFF1E1E1E),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        items: items,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        elevation: 0,
      ),
    );
  }
}
