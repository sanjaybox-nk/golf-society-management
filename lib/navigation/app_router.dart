import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/scaffold_with_nav_bar.dart';
import '../models/golf_event.dart';
import '../models/member.dart';
import '../features/archive/presentation/archive_screen.dart';
import '../features/events/presentation/events_screen.dart';
import '../features/home/presentation/member_home_screen.dart';
import '../features/members/presentation/locker_screen.dart';
import '../features/members/presentation/members_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/events/admin_events_screen.dart';
import '../features/admin/presentation/events/event_form_screen.dart';
import '../features/admin/presentation/members/admin_members_screen.dart';
import '../features/admin/presentation/members/member_form_screen.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _eventsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'events');
final _membersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'members');
final _lockerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'locker');
final _archiveNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'archive');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MemberHomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _eventsNavigatorKey,
            routes: [
              GoRoute(
                path: '/events',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: EventsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _membersNavigatorKey,
            routes: [
              GoRoute(
                path: '/members',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MembersScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _lockerNavigatorKey,
            routes: [
              GoRoute(
                path: '/locker',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LockerScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _archiveNavigatorKey,
            routes: [
              GoRoute(
                path: '/archive',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ArchiveScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashboardScreen(),
        ),
        routes: [
          GoRoute(
            path: 'events',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminEventsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const EventFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final event = state.extra as GolfEvent;
                  return EventFormScreen(event: event);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'members',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminMembersScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const MemberFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                   final member = state.extra as Member;
                   return MemberFormScreen(member: member);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
