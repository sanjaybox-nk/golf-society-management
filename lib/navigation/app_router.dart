import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/season.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import '../features/archive/presentation/archive_screen.dart';
import '../features/events/presentation/events_screen.dart';
import '../features/home/presentation/member_home_screen.dart';
import '../features/members/presentation/locker_screen.dart';
import '../features/members/presentation/members_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/events/presentation/event_feed_detail_screen.dart';
import '../features/admin/presentation/events/admin_events_screen.dart';
import '../features/admin/presentation/events/event_form_screen.dart';
import 'package:golf_society/features/admin/presentation/events/event_broadcast_screen.dart';
import 'package:golf_society/features/admin/presentation/events/feed_item_editor_screen.dart';
import '../features/admin/presentation/members/admin_members_screen.dart';
import '../features/admin/presentation/settings/admin_settings_screen.dart';
import '../features/admin/presentation/roles/roles_settings_screen.dart';
import '../features/admin/presentation/settings/branding_settings_screen.dart';
import '../features/admin/presentation/settings/currency_selection_screen.dart';
import '../features/admin/presentation/settings/grouping_strategy_selection_screen.dart';
import '../features/admin/presentation/settings/handicap_system_selection_screen.dart';
import '../features/admin/presentation/settings/society_cuts_settings_screen.dart';
import '../features/admin/presentation/events/event_manual_cuts_screen.dart';
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
import '../features/admin/presentation/events/event_admin_scorecard_editor_screen.dart';
import '../features/admin/presentation/events/event_admin_reports_screen.dart';
import '../features/admin/presentation/admin_shell.dart';
import '../features/admin/presentation/reports/admin_reports_screen.dart';
import '../features/admin/presentation/surveys/admin_surveys_screen.dart';
import '../features/admin/presentation/surveys/survey_editor_screen.dart';
import '../features/admin/presentation/surveys/survey_results_screen.dart';
import '../features/admin/presentation/competitions/competition_builder_screen.dart';
import '../features/admin/presentation/competitions/competition_type_selection_screen.dart'; 
import '../features/admin/presentation/competitions/competition_template_gallery_screen.dart'; 
import 'package:golf_society/domain/models/competition.dart'; 
import '../features/admin/presentation/seasons/season_form_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_type_selection_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_builder_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_template_gallery_screen.dart'; 
import 'package:golf_society/domain/models/leaderboard_config.dart'; 

// Private navigators
import '../features/events/presentation/event_user_shell.dart';
import '../features/events/presentation/tabs/event_user_details_tab.dart';
import '../features/events/presentation/tabs/event_user_home_tab.dart';
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
final _adminSurveysKey = GlobalKey<NavigatorState>(debugLabel: 'adminSurveys');

/// Standardized Fade Transition for Shells
CustomTransitionPage fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: AppAnimations.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Standardized Boxy Art Transition (Fade + Subtle Slide Up) for Leaf Routes
CustomTransitionPage boxyPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: AppAnimations.medium,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: AppAnimations.entranceCurve,
      );
      final slide = Tween<Offset>(
        begin: AppAnimations.slideUp,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.entranceCurve,
      ));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}

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
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const MemberHomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: const NotificationInboxScreen(),
                    ),
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
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const EventsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _membersNavigatorKey,
            routes: [
              GoRoute(
                path: '/members',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const MembersScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _lockerNavigatorKey,
            routes: [
              GoRoute(
                path: '/locker',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const LockerScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'standings',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: const SeasonStandingsScreen(),
                    ),
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
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const ArchiveScreen(),
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
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const AdminDashboardScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'leaderboards/create/picker',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: const LeaderboardTypeSelectionScreen(isPicker: true),
                    ),
                    routes: [
                      GoRoute(
                        path: 'gallery/:type',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: Builder(builder: (context) {
                            final typeStr = state.pathParameters['type']!;
                            final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                            return LeaderboardTemplateGalleryScreen(type: type, isPicker: true);
                          }),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'leaderboards/create/:type',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: Builder(builder: (context) {
                        final typeStr = state.pathParameters['type']!;
                        final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                        return LeaderboardBuilderScreen(type: type, isTemplate: false);
                      }),
                    ),
                  ),
                  GoRoute(
                    path: 'settings',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: const AdminSettingsScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'branding',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const BrandingSettingsScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'currency',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const CurrencySelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'grouping-strategy',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const GroupingStrategySelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'handicap-system',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const HandicapSystemSelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'society-cuts', 
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const SocietyCutsSettingsScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'roles',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const RolesSettingsScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: 'members/:roleIndex',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final roleIndex = int.parse(state.pathParameters['roleIndex']!);
                                final role = MemberRole.values[roleIndex];
                                return RoleMembersScreen(role: role);
                              }),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'committee-roles',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const CommitteeRolesScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: 'members/:roleName',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final roleName = Uri.decodeComponent(state.pathParameters['roleName']!);
                                return CommitteeRoleMembersScreen(role: roleName);
                              }),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'seasons',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const AdminSeasonsScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: 'new',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: const SeasonFormScreen(),
                            ),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final season = state.extra as Season?;
                                final id = state.pathParameters['id']!;
                                return SeasonFormScreen(season: season, seasonId: id);
                              }),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'templates',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const CompetitionTypeSelectionScreen(isTemplate: true),
                        ),
                        routes: [
                          GoRoute(
                            path: 'gallery/:type',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final typeStr = state.pathParameters['type']!;
                                return CompetitionTemplateGalleryScreen(typeStr: typeStr, isTemplate: true);
                              }),
                            ),
                          ),
                          GoRoute(
                            path: 'create/:type',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
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
                              }),
                            ),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final id = state.pathParameters['id']!;
                                return CompetitionBuilderScreen(competitionId: id, isTemplate: true);
                              }),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'leaderboards',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: const LeaderboardTypeSelectionScreen(isTemplate: true),
                        ),
                        routes: [
                          GoRoute(
                            path: 'gallery/:type',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final typeStr = state.pathParameters['type']!;
                                final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                                return LeaderboardTemplateGalleryScreen(type: type, isTemplate: true);
                              }),
                            ),
                          ),
                          GoRoute(
                            path: 'create/picker',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: const LeaderboardTypeSelectionScreen(isPicker: true),
                            ),
                            routes: [
                              GoRoute(
                                path: 'gallery/:type',
                                pageBuilder: (context, state) => boxyPage(
                                  key: state.pageKey,
                                  child: Builder(builder: (context) {
                                    final typeStr = state.pathParameters['type']!;
                                    final type = LeaderboardType.values.firstWhere(
                                      (e) => e.name == typeStr,
                                      orElse: () => LeaderboardType.orderOfMerit,
                                    );
                                    return LeaderboardTemplateGalleryScreen(type: type, isPicker: true);
                                  }),
                                ),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: 'create/:type',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final typeStr = state.pathParameters['type']!;
                                final type = LeaderboardType.values.firstWhere(
                                  (e) => e.name == typeStr,
                                  orElse: () => LeaderboardType.orderOfMerit,
                                );
                                return LeaderboardBuilderScreen(
                                  type: type, 
                                  isTemplate: true,
                                );
                              }),
                            ),
                          ),
                          GoRoute(
                            path: 'create/:type/builder',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final typeStr = state.pathParameters['type']!;
                                final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                                final config = state.extra as LeaderboardConfig?;
                                return LeaderboardBuilderScreen(
                                  type: type, 
                                  isTemplate: true,
                                  existingConfig: config,
                                );
                              }),
                            ),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final config = state.extra as LeaderboardConfig;
                                return LeaderboardBuilderScreen(
                                  type: _getTypeFromConfig(config),
                                  existingConfig: config,
                                  isTemplate: true
                                );
                              }),
                            ),
                          ),
                        ],
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
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const AdminEventsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: const EventFormScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'competitions/new',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: Builder(builder: (context) {
                        final format = state.uri.queryParameters['format'];
                        return CompetitionTypeSelectionScreen(isPicker: true, formatFilter: format);
                      }),
                    ),
                    routes: [
                      GoRoute(
                        path: 'gallery/:type',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: Builder(builder: (context) {
                            final typeStr = state.pathParameters['type']!;
                            return CompetitionTemplateGalleryScreen(typeStr: typeStr, isPicker: true);
                          }),
                        ),
                      ),
                      GoRoute(
                        path: 'create/:type',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: Builder(builder: (context) {
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
                          }),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'competitions/edit/:id',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: Builder(builder: (context) {
                        final id = state.pathParameters['id']!;
                        return CompetitionBuilderScreen(competitionId: id, isTemplate: false);
                      }),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id',
                    redirect: (context, state) {
                      final id = state.pathParameters['id']!;
                      final path = state.uri.path;
                      if (path.endsWith('manage/$id') || path.endsWith('manage/$id/')) {
                        return '/admin/events/manage/$id/home';
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(
                        path: 'broadcast',
                        pageBuilder: (context, state) => boxyPage(
                          key: state.pageKey,
                          child: Builder(builder: (context) {
                            final id = state.pathParameters['id']!;
                            return EventBroadcastScreen(eventId: id);
                          }),
                        ),
                        routes: [
                          GoRoute(
                            path: 'new',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final eventId = state.pathParameters['id']!;
                                return FeedItemEditorScreen(eventId: eventId);
                              }),
                            ),
                          ),
                          GoRoute(
                            path: 'edit/:itemId',
                            pageBuilder: (context, state) => boxyPage(
                              key: state.pageKey,
                              child: Builder(builder: (context) {
                                final eventId = state.pathParameters['id']!;
                                final item = state.extra as EventFeedItem?;
                                return FeedItemEditorScreen(eventId: eventId, existingItem: item);
                              }),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'feed/:itemId',
                        pageBuilder: (context, state) {
                          final item = state.extra as EventFeedItem;
                          return boxyPage(
                            key: state.pageKey,
                            child: EventFeedDetailScreen(item: item),
                          );
                        },
                      ),
                      ShellRoute(
                        pageBuilder: (context, state, child) {
                          return fadePage(
                            key: state.pageKey,
                            child: EventAdminShell(child: child),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'home',
                            pageBuilder: (context, state) {
                              final eventId = state.pathParameters['id']!;
                              return fadePage(
                                key: state.pageKey,
                                child: EventUserHomeTab(eventId: eventId),
                              );
                            },
                          ),
                          GoRoute(
                            path: 'event',
                            pageBuilder: (context, state) {
                              final eventId = state.pathParameters['id']!;
                              return fadePage(
                                key: state.pageKey,
                                child: EventUserDetailsTab(eventId: eventId, useScaffold: false),
                              );
                            },
                            routes: [
                              GoRoute(
                                path: 'edit',
                                pageBuilder: (context, state) {
                                  final event = state.extra as GolfEvent?;
                                  final eventId = state.pathParameters['id'];
                                  return boxyPage(
                                    key: state.pageKey,
                                    child: EventFormScreen(event: event, eventId: eventId),
                                  );
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                            path: 'registrations',
                            pageBuilder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return fadePage(
                                key: state.pageKey,
                                child: EventRegistrationsAdminScreen(eventId: id),
                              );
                            },
                          ),
                          GoRoute(
                            path: 'grouping',
                            pageBuilder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return fadePage(
                                key: state.pageKey,
                                child: EventAdminGroupingScreen(eventId: id),
                              );
                            },
                          ),
                          GoRoute(
                            path: 'scores',
                            pageBuilder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return fadePage(
                                key: state.pageKey,
                                child: EventAdminScoresScreen(eventId: id),
                              );
                            },
                            routes: [
                              GoRoute(
                                path: ':playerId',
                                pageBuilder: (context, state) {
                                  final id = state.pathParameters['id']!;
                                  final playerId = state.pathParameters['playerId']!;
                                  return boxyPage(
                                    key: state.pageKey,
                                    child: EventAdminScorecardEditorScreen(eventId: id, playerId: playerId),
                                  );
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                            path: 'reporting',
                            pageBuilder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return fadePage(
                                key: state.pageKey,
                                child: EventAdminReportsScreen(eventId: id),
                              );
                            },
                          ),
                          GoRoute(
                            path: 'manual-cuts',
                            pageBuilder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return fadePage(
                                key: state.pageKey,
                                child: EventManualCutsScreen(eventId: id),
                              );
                            },
                          ),
                        ],
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
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const AdminMembersScreen(),
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
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const NotificationAdminScaffold(),
                ),
              ),
            ],
          ),
          // 3.5 Surveys
          StatefulShellBranch(
            navigatorKey: _adminSurveysKey,
            routes: [
              GoRoute(
                path: '/admin/surveys',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const AdminSurveysScreen(),
                ),
              ),
              GoRoute(
                path: '/admin/surveys/new',
                pageBuilder: (context, state) => boxyPage(
                  key: state.pageKey,
                  child: const SurveyEditorScreen(),
                ),
              ),
              GoRoute(
                path: '/admin/surveys/edit/:surveyId',
                pageBuilder: (context, state) => boxyPage(
                  key: state.pageKey,
                  child: SurveyEditorScreen(
                    surveyId: state.pathParameters['surveyId'],
                  ),
                ),
              ),
              GoRoute(
                path: '/admin/surveys/results/:surveyId',
                pageBuilder: (context, state) => boxyPage(
                  key: state.pageKey,
                  child: SurveyResultsScreen(
                    surveyId: state.pathParameters['surveyId']!,
                  ),
                ),
              ),
            ],
          ),
          // 4. Reporting
          StatefulShellBranch(
            navigatorKey: _adminLeaderboardsKey,
            routes: [
              GoRoute(
                path: '/admin/reports',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: const AdminReportsScreen(), 
                ),
                routes: [
                  GoRoute(
                    path: 'manage/:id',
                    pageBuilder: (context, state) => boxyPage(
                      key: state.pageKey,
                      child: Builder(builder: (context) {
                        final id = state.pathParameters['id']!;
                        final config = state.extra as LeaderboardConfig?;
                        
                        if (config != null) {
                          return LeaderboardBuilderScreen(
                            type: _getTypeFromConfig(config),
                            existingConfig: config,
                            isTemplate: false,
                          );
                        }
                        
                        return Scaffold(
                          appBar: AppBar(title: const Text('Admin Debug')),
                          body: Center(
                            child: Text('Leaderboard ID: $id\nNo Config Passed!'),
                          ),
                        );
                      }),
                    ),
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
            return '/events/$id/home${query.isNotEmpty ? '?$query' : ''}';
          }
          return null;
        },
        builder: (context, state) => const SizedBox.shrink(),
        routes: [
          GoRoute(
            path: 'register-form', 
            pageBuilder: (context, state) => boxyPage(
              key: state.pageKey,
              child: Builder(builder: (context) {
                final id = state.pathParameters['id']!;
                return EventRegistrationScreen(eventId: id);
              }),
            ),
          ),
          GoRoute(
            path: 'feed/:itemId',
            pageBuilder: (context, state) {
              final item = state.extra as EventFeedItem;
              return boxyPage(
                key: state.pageKey,
                child: EventFeedDetailScreen(item: item),
              );
            },
          ),
          ShellRoute(
            pageBuilder: (context, state, child) => fadePage(
              key: state.pageKey,
              child: EventUserShell(child: child),
            ),
            routes: [
              GoRoute(
                path: 'home',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: EventUserHomeTab(eventId: state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'details',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: EventUserDetailsTab(eventId: state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'field',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: EventGroupingUserTab(eventId: state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'live',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: EventScoresUserTab(eventId: state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'stats',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: EventStatsUserTab(eventId: state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'photos',
                pageBuilder: (context, state) => fadePage(
                  key: state.pageKey,
                  child: EventGalleryUserTab(eventId: state.pathParameters['id']!),
                ),
              ),
              // Old path redirects for backward compatibility
              GoRoute(
                path: 'register',
                redirect: (context, state) => '/events/${Uri.encodeComponent(state.pathParameters['id']!)}/field',
              ),
              GoRoute(
                path: 'grouping',
                redirect: (context, state) => '/events/${Uri.encodeComponent(state.pathParameters['id']!)}/field',
              ),
              GoRoute(
                path: 'scores',
                redirect: (context, state) => '/events/${Uri.encodeComponent(state.pathParameters['id']!)}/live',
              ),
              GoRoute(
                path: 'gallery',
                redirect: (context, state) => '/events/${Uri.encodeComponent(state.pathParameters['id']!)}/photos',
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
