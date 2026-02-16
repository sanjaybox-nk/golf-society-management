import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/season.dart';

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
import '../features/admin/presentation/settings/admin_settings_screen.dart';
import '../features/admin/presentation/roles/roles_settings_screen.dart';
import '../features/admin/presentation/settings/branding_settings_screen.dart';
import '../features/admin/presentation/settings/general_settings_screen.dart';
import '../features/admin/presentation/settings/currency_selection_screen.dart';
import '../features/admin/presentation/settings/grouping_strategy_selection_screen.dart';
import '../features/admin/presentation/settings/handicap_system_selection_screen.dart';
import '../features/admin/presentation/roles/role_members_screen.dart';
import '../features/admin/presentation/roles/committee_roles_screen.dart';
import '../features/admin/presentation/roles/committee_role_members_screen.dart';
import '../features/admin/presentation/notifications/notification_admin_scaffold.dart';
import '../features/home/presentation/notification_inbox_screen.dart';
import '../features/design_lab/header_playground.dart';
import '../features/admin/presentation/seasons/admin_seasons_screen.dart';
import '../features/events/presentation/event_registration_screen.dart';
import '../features/admin/presentation/events/event_registrations_admin_screen.dart';
import '../features/admin/presentation/events/event_admin_shell.dart';
import '../features/admin/presentation/events/event_admin_grouping_screen.dart';
import '../features/admin/presentation/events/event_admin_scores_screen.dart';
import '../features/admin/presentation/events/event_admin_scorecard_editor_screen.dart';
import '../features/admin/presentation/events/event_admin_reports_screen.dart';
import '../features/admin/presentation/admin_shell.dart';
import '../features/admin/presentation/competitions/admin_competitions_screen.dart';
import '../features/admin/presentation/competitions/competition_builder_screen.dart';
// import '../features/admin/presentation/competitions/scoring_review_queue_screen.dart'; // Removed
import '../features/admin/presentation/competitions/competition_type_selection_screen.dart'; // Added
import '../features/admin/presentation/competitions/competition_template_gallery_screen.dart'; // Added
import '../models/competition.dart'; // Added for enum
import '../features/admin/presentation/seasons/season_form_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_type_selection_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_builder_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_template_gallery_screen.dart'; // Added
import '../models/leaderboard_config.dart'; // Ensure this is imported

// Private navigators
import '../features/events/presentation/event_user_shell.dart';
import '../features/events/presentation/tabs/event_user_details_tab.dart';
import '../features/events/presentation/tabs/event_user_registration_tab.dart';
import '../features/events/presentation/tabs/event_user_placeholders.dart';
import '../features/events/presentation/tabs/event_gallery_user_tab.dart';
import '../features/competitions/presentation/season_standings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _eventsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'events');
final _membersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'members');
final _lockerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'locker');
final _archiveNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'archive');

// Admin Navigators
final _adminDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'adminDashboard');
final _adminEventsKey = GlobalKey<NavigatorState>(debugLabel: 'adminEvents');
final _adminLeaderboardsKey = GlobalKey<NavigatorState>(debugLabel: 'adminLeaderboards');
final _adminMembersKey = GlobalKey<NavigatorState>(debugLabel: 'adminMembers');
final _adminCommsKey = GlobalKey<NavigatorState>(debugLabel: 'adminComms');

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
                  GoRoute(
                    path: 'design-lab',
                    builder: (context, state) => const HeaderPlayground(),
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
                routes: [
                  GoRoute(
                    path: 'standings',
                    builder: (context, state) => const SeasonStandingsScreen(),
                  ),
                ],
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShell(navigationShell: navigationShell);
        },
        branches: [
          // 0. Dashboard
          StatefulShellBranch(
            navigatorKey: _adminDashboardKey,
            routes: [
              GoRoute(
                path: '/admin',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AdminDashboardScreen(),
                ),
                routes: [
                  // Settings - Integrated into Dashboard branch for persistent menu
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
                          GoRoute(
                            path: 'grouping-strategy',
                            builder: (context, state) => const GroupingStrategySelectionScreen(),
                          ),
                          GoRoute(
                            path: 'handicap-system',
                            builder: (context, state) => const HandicapSystemSelectionScreen(),
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
                      GoRoute(
                        path: 'seasons',
                        builder: (context, state) => const AdminSeasonsScreen(),
                        routes: [
                          GoRoute(
                            path: 'new',
                            builder: (context, state) => const SeasonFormScreen(),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            builder: (context, state) {
                              final season = state.extra as Season?;
                              final id = state.pathParameters['id']!;
                              return SeasonFormScreen(season: season, seasonId: id);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'templates',
                        builder: (context, state) => const CompetitionTypeSelectionScreen(isTemplate: true),
                        routes: [
                          GoRoute(
                            path: 'gallery/:type',
                            builder: (context, state) {
                               final typeStr = state.pathParameters['type']!;
                               return CompetitionTemplateGalleryScreen(typeStr: typeStr, isTemplate: true);
                            },
                          ),
                          GoRoute(
                            path: 'create/:type',
                            builder: (context, state) {
                               final typeStr = state.pathParameters['type']!;
                               
                               // Try matching Subtype (for Pairs)
                               final subtype = CompetitionSubtype.values.where((e) => e.name == typeStr).firstOrNull;
                               if (subtype != null) {
                                 return CompetitionBuilderScreen(subtype: subtype, isTemplate: true);
                               }

                               // Match string to enum
                               final format = CompetitionFormat.values.firstWhere(
                                 (e) => e.name == typeStr,
                                 orElse: () => CompetitionFormat.stableford, // Fallback
                               );
                               return CompetitionBuilderScreen(format: format, isTemplate: true);
                            },
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            builder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return CompetitionBuilderScreen(competitionId: id, isTemplate: true);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'leaderboards/create/:type',
                        builder: (context, state) {
                           final typeStr = state.pathParameters['type']!;
                           final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                           return LeaderboardBuilderScreen(type: type, isTemplate: false); 
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 1. Events
          StatefulShellBranch(
            navigatorKey: _adminEventsKey,
            routes: [
              GoRoute(
                path: '/admin/events',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AdminEventsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const EventFormScreen(),
                  ),
                  // Competition Picker - Integrated into Events branch
                  GoRoute(
                    path: 'competitions/new',
                    builder: (context, state) {
                      final format = state.uri.queryParameters['format'];
                      return CompetitionTypeSelectionScreen(isPicker: true, formatFilter: format);
                    },
                    routes: [
                      GoRoute(
                        path: 'gallery/:type',
                        builder: (context, state) {
                           final typeStr = state.pathParameters['type']!;
                           return CompetitionTemplateGalleryScreen(typeStr: typeStr, isPicker: true);
                        },
                      ),
                      GoRoute(
                        path: 'create/:type',
                        builder: (context, state) {
                           final typeStr = state.pathParameters['type']!;
                           final subtype = CompetitionSubtype.values.where((e) => e.name == typeStr).firstOrNull;
                           if (subtype != null) {
                             return CompetitionBuilderScreen(subtype: subtype, isTemplate: true);
                           }
                           final format = CompetitionFormat.values.firstWhere(
                             (e) => e.name == typeStr,
                             orElse: () => CompetitionFormat.stableford,
                           );
                           return CompetitionBuilderScreen(format: format, isTemplate: true);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'competitions/edit/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CompetitionBuilderScreen(competitionId: id, isTemplate: false);
                    },
                  ),
                  ShellRoute(
                    pageBuilder: (context, state, child) {
                      return NoTransitionPage(
                        child: EventAdminShell(child: child),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'manage/:id/event',
                        pageBuilder: (context, state) {
                          final eventId = state.pathParameters['id']!;
                          return NoTransitionPage(
                            child: EventUserDetailsTab(eventId: eventId),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'edit',
                            pageBuilder: (context, state) {
                              final event = state.extra as GolfEvent?;
                              final eventId = state.pathParameters['id'];
                              return NoTransitionPage(
                                child: EventFormScreen(event: event, eventId: eventId),
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'manage/:id/registrations',
                        pageBuilder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return NoTransitionPage(
                            child: EventRegistrationsAdminScreen(eventId: id),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'manage/:id/grouping',
                        pageBuilder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return NoTransitionPage(
                            child: EventAdminGroupingScreen(eventId: id),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'manage/:id/scores',
                        pageBuilder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return NoTransitionPage(
                            child: EventAdminScoresScreen(eventId: id),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: ':playerId',
                            pageBuilder: (context, state) {
                              final id = state.pathParameters['id']!;
                              final playerId = state.pathParameters['playerId']!;
                              return NoTransitionPage(
                                child: EventAdminScorecardEditorScreen(eventId: id, playerId: playerId),
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'manage/:id/reports',
                        pageBuilder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return NoTransitionPage(
                            child: EventAdminReportsScreen(eventId: id),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 2. Members
          StatefulShellBranch(
            navigatorKey: _adminMembersKey,
            routes: [
              GoRoute(
                path: '/admin/members',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AdminMembersScreen(),
                ),
              ),
            ],
          ),
          // 3. Comms
          StatefulShellBranch(
            navigatorKey: _adminCommsKey,
            routes: [
              GoRoute(
                path: '/admin/communications',
                builder: (context, state) => const NotificationAdminScaffold(),
              ),
            ],
          ),
          // 4. Leaderboards (formerly index 5)
          StatefulShellBranch(
            navigatorKey: _adminLeaderboardsKey,
            routes: [
              GoRoute(
                path: '/admin/leaderboards',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AdminLeaderboardsScreen(), 
                ),
                routes: [
                  GoRoute(
                    path: 'manage/:id',
                    builder: (context, state) => const Scaffold(body: Center(child: Text('Management Screen'))),
                  ),
                ],
              ),
            ],
          ),
          // 5. Leaderboard Templates (New Settings Branch)
          StatefulShellBranch(
             navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'leaderboardTemplates'),
             routes: [
               GoRoute(
                 path: '/admin/settings/leaderboards', // Using dedicated path
                 builder: (context, state) => const LeaderboardTypeSelectionScreen(isTemplate: true),
                 routes: [
                   GoRoute(
                     path: 'gallery/:type',
                     builder: (context, state) {
                       final typeStr = state.pathParameters['type']!;
                       final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                       return LeaderboardTemplateGalleryScreen(type: type, isTemplate: true);
                     },
                   ),
                   GoRoute(
                     path: 'create/:type/builder',
                     builder: (context, state) {
                       final typeStr = state.pathParameters['type']!;
                       final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                       final config = state.extra as LeaderboardConfig?;
                       return LeaderboardBuilderScreen(
                         type: type, 
                         isTemplate: true,
                         existingConfig: config,
                       );
                     },
                   ),
                   GoRoute(
                     path: 'edit/:id',
                     builder: (context, state) {
                       final config = state.extra as LeaderboardConfig;
                       return LeaderboardBuilderScreen(
                         type: _getTypeFromConfig(config),
                         existingConfig: config,
                         isTemplate: true
                       );
                     },
                   ),
                 ],
               ),
             ],
          ),
        ],
      ),
      GoRoute(
        path: '/events/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          if (state.uri.pathSegments.length == 2) {
            final query = state.uri.query;
            return '/events/$id/details${query.isNotEmpty ? '?$query' : ''}';
          }
          return null;
        },
        builder: (context, state) => const SizedBox.shrink(),
        routes: [
      GoRoute(
        path: 'register-form', 
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventRegistrationScreen(eventId: id);
        },
      ),
      ShellRoute(
        pageBuilder: (context, state, child) => NoTransitionPage(
          child: EventUserShell(child: child),
        ),
        routes: [
          GoRoute(
            path: 'details',
            redirect: (context, state) => '/events/${state.pathParameters['id']}/info',
          ),
          GoRoute(
            path: 'info',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: EventUserDetailsTab(eventId: state.pathParameters['id']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: 'field',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: EventGroupingUserTab(eventId: state.pathParameters['id']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: 'live',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: EventScoresUserTab(eventId: state.pathParameters['id']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: 'stats',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: EventStatsUserTab(eventId: state.pathParameters['id']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: 'photos',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: EventGalleryUserTab(eventId: state.pathParameters['id']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          // Old path redirects for backward compatibility
          GoRoute(
            path: 'register',
            redirect: (context, state) => '/events/${state.pathParameters['id']}/field',
          ),
          GoRoute(
            path: 'grouping',
            redirect: (context, state) => '/events/${state.pathParameters['id']}/field',
          ),
          GoRoute(
            path: 'scores',
            redirect: (context, state) => '/events/${state.pathParameters['id']}/live',
          ),
          GoRoute(
            path: 'gallery',
            redirect: (context, state) => '/events/${state.pathParameters['id']}/photos',
          ),
        ],
      ),
    ],
  ),
],
  );
});

LeaderboardType _getTypeFromConfig(LeaderboardConfig config) {
  return config.map(
    orderOfMerit: (_) => LeaderboardType.orderOfMerit,
    bestOfSeries: (_) => LeaderboardType.bestOfSeries,
    eclectic: (_) => LeaderboardType.eclectic,
    markerCounter: (_) => LeaderboardType.markerCounter,
  );
}
