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
import '../features/admin/presentation/settings/admin_settings_screen.dart';
import '../features/admin/presentation/roles/roles_settings_screen.dart';
import '../features/admin/presentation/settings/branding_settings_screen.dart';
import '../features/admin/presentation/settings/general_settings_screen.dart';
import '../features/admin/presentation/settings/currency_selection_screen.dart';
import '../features/admin/presentation/roles/role_members_screen.dart';
import '../features/admin/presentation/roles/committee_roles_screen.dart';
import '../features/admin/presentation/roles/committee_role_members_screen.dart';
import '../features/admin/presentation/notifications/notification_admin_scaffold.dart';
import '../features/home/presentation/notification_inbox_screen.dart';
import '../features/admin/presentation/seasons/admin_seasons_screen.dart';
import '../features/events/presentation/event_registration_screen.dart';
import '../features/admin/presentation/events/event_registrations_admin_screen.dart';
import '../features/admin/presentation/events/event_admin_shell.dart';
import '../features/admin/presentation/events/event_admin_grouping_screen.dart';
import '../features/admin/presentation/events/event_admin_scores_screen.dart';

// Private navigators
import '../features/events/presentation/event_user_shell.dart';
import '../features/events/presentation/tabs/event_user_details_tab.dart';
import '../features/events/presentation/tabs/event_user_registration_tab.dart';
import '../features/events/presentation/tabs/event_user_placeholders.dart';
import '../features/events/presentation/tabs/event_gallery_user_tab.dart';

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
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationInboxScreen(),
                  ),
                ],
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
                  ShellRoute(
                    builder: (context, state, child) {
                      return EventAdminShell(child: child);
                    },
                    routes: [
                      GoRoute(
                        path: 'manage/:id/event',
                        builder: (context, state) {
                          final event = state.extra as GolfEvent?;
                          return EventFormScreen(event: event);
                        },
                      ),
                      GoRoute(
                        path: 'manage/:id/registrations',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return EventRegistrationsAdminScreen(eventId: id);
                        },
                      ),
                      GoRoute(
                        path: 'manage/:id/grouping',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return EventAdminGroupingScreen(eventId: id);
                        },
                      ),
                      GoRoute(
                        path: 'manage/:id/scores',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return EventAdminScoresScreen(eventId: id);
                        },
                      ),
                    ],
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
          GoRoute(
            path: 'settings',
            builder: (context, state) => const AdminSettingsScreen(),
            routes: [
              GoRoute(
                path: 'branding',
                builder: (context, state) => const BrandingSettingsScreen(),
              ),
              GoRoute(
                path: 'general',
                builder: (context, state) => const GeneralSettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'currency',
                    builder: (context, state) => const CurrencySelectionScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'roles',
                builder: (context, state) => const RolesSettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'members/:roleIndex',
                    builder: (context, state) {
                      final roleIndex = int.parse(state.pathParameters['roleIndex']!);
                      final role = MemberRole.values[roleIndex];
                      return RoleMembersScreen(role: role);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'committee-roles',
                builder: (context, state) => const CommitteeRolesScreen(),
                routes: [
                  GoRoute(
                    path: 'members/:roleName',
                    builder: (context, state) {
                      final roleName = Uri.decodeComponent(state.pathParameters['roleName']!);
                      return CommitteeRoleMembersScreen(role: roleName);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'communications',
            builder: (context, state) => const NotificationAdminScaffold(),
          ),
          GoRoute(
            path: 'seasons',
            builder: (context, state) => const AdminSeasonsScreen(),
          ),
        ],
      ),
    GoRoute(
      path: '/events/:id',
    redirect: (context, state) {
      final id = state.pathParameters['id'];
      if (state.uri.pathSegments.length == 2) {
        return '/events/$id/details';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: 'register-form', 
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventRegistrationScreen(eventId: id);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return EventUserShell(child: child);
        },
        routes: [
          GoRoute(
            path: 'details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EventUserDetailsTab(eventId: id);
            },
          ),
          GoRoute(
            path: 'register',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EventRegistrationUserTab(eventId: id);
            },
          ),
          GoRoute(
            path: 'grouping',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EventGroupingUserTab(eventId: id);
            },
          ),
          GoRoute(
            path: 'scores',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EventScoresUserTab(eventId: id);
            },
          ),
          GoRoute(
            path: 'gallery',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EventGalleryUserTab(eventId: id);
            },
          ),
        ],
      ),
    ],
  ),
    ],
  );
});
