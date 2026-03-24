import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/season.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import '../features/archive/presentation/archive_screen.dart';
import '../features/events/presentation/events_screen.dart';
import '../features/home/presentation/member_home_screen.dart';
import '../features/members/presentation/locker_screen.dart';
import '../features/members/presentation/members_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/events/admin_events_screen.dart';
import '../features/admin/presentation/events/event_admin_controls_screen.dart';
import '../features/admin/presentation/events/event_form_screen.dart';
import '../features/admin/presentation/members/admin_members_screen.dart';
import '../features/admin/presentation/settings/admin_settings_screen.dart';
import '../features/admin/presentation/settings/branding_settings_screen.dart';
import '../features/admin/presentation/settings/currency_selection_screen.dart';
import '../features/admin/presentation/settings/grouping_strategy_selection_screen.dart';
import '../features/admin/presentation/settings/handicap_system_selection_screen.dart';
import '../features/admin/presentation/settings/society_cuts_settings_screen.dart';
import '../features/competitions/presentation/season_standings_screen.dart';
import '../features/events/presentation/event_details_screen.dart';
import '../features/events/presentation/event_registration_screen.dart';
import 'global_app_shell.dart';

import '../features/admin/presentation/surveys/admin_surveys_screen.dart';
import '../features/admin/presentation/surveys/survey_editor_screen.dart';
import '../features/admin/presentation/surveys/survey_results_screen.dart';
import '../features/admin/presentation/events/event_admin_reports_screen.dart';
import '../features/admin/presentation/reports/admin_reports_screen.dart';
import '../features/events/presentation/event_user_shell.dart';
import '../features/events/presentation/tabs/event_user_details_tab.dart';
import '../features/events/presentation/tabs/event_user_registration_tab.dart';
import '../features/events/presentation/tabs/event_user_placeholders.dart';
import '../features/events/presentation/tabs/event_stats_tab.dart';
import '../features/admin/presentation/events/event_admin_financials_screen.dart';
import '../features/admin/presentation/events/event_admin_grouping_screen.dart';
import '../features/admin/presentation/events/event_admin_scorecards_screen.dart';
import '../features/admin/presentation/events/event_admin_scores_screen.dart';
import '../features/admin/presentation/events/event_airdrop_control_screen.dart';
import '../features/admin/presentation/events/event_broadcast_screen.dart';
import '../features/admin/presentation/events/event_cost_control_screen.dart';
import '../features/admin/presentation/events/event_field_admin_screen.dart';
import '../features/admin/presentation/events/event_manual_cuts_screen.dart';
import '../features/admin/presentation/events/event_registrations_admin_screen.dart';
import '../features/admin/presentation/events/feed_item_editor_screen.dart';
import '../features/admin/presentation/events/event_admin_shell.dart';
import '../features/admin/presentation/notifications/notification_admin_scaffold.dart';
import '../features/home/presentation/notification_inbox_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_type_selection_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_builder_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_template_gallery_screen.dart';
import '../features/admin/presentation/competitions/competition_type_selection_screen.dart';
import '../features/admin/presentation/competitions/competition_template_gallery_screen.dart';
import '../features/admin/presentation/competitions/competition_builder_screen.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/events/presentation/event_feed_detail_screen.dart';
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Shell Branch Keys
final _branchHomeKey = GlobalKey<NavigatorState>(debugLabel: 'branchHome');
final _branchEventsKey = GlobalKey<NavigatorState>(debugLabel: 'branchEvents');
final _branchMembersKey = GlobalKey<NavigatorState>(debugLabel: 'branchMembers');
final _branchLockerKey = GlobalKey<NavigatorState>(debugLabel: 'branchLocker');
final _branchArchiveKey = GlobalKey<NavigatorState>(debugLabel: 'branchArchive');
final _branchAdminKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdmin');
final _branchAdminEventsKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdminEvents');
final _branchAdminMembersKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdminMembers');
final _branchAdminCommsKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdminComms');
final _branchAdminSurveysKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdminSurveys');
final _branchAdminReportsKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdminReports');

CustomTransitionPage boxyPage({
  required GoRouterState state,
  required Widget child,
}) {
  // Use state.pageKey directly. Now that we have explicit navigatorKeys for all shells,
  // collisions between identically-pathed pages in different navigators are prevented.
  // Salting with matchedLocation was causing ShellRoutes to recreate on every sub-route change.
  final key = state.pageKey;
  debugPrint('DEBUG_ROUTER: Building page for ${state.matchedLocation} with key: $key');

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
        begin: const Offset(0, 0.05),
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
      // --- GLOBAL SURVEYS (Root level) ---
      GoRoute(
        path: '/surveys/:id',
        pageBuilder: (context, state) => boxyPage(
          state: state,
          child: const Center(child: Text('Survey Detail Placeholder')),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return GlobalAppShell(navigationShell: navigationShell);
        },
        branches: [
          // 0. Home
          StatefulShellBranch(
            navigatorKey: _branchHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const MemberHomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const NotificationInboxScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 1. Events
          StatefulShellBranch(
            navigatorKey: _branchEventsKey,
            routes: [
              GoRoute(
                path: '/events',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const EventsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    redirect: (context, state) {
                      final id = state.pathParameters['id'];
                      if (state.uri.pathSegments.length == 2) {
                        return '/events/$id/details';
                      }
                      return null;
                    },
                    routes: [
                      ShellRoute(
                        pageBuilder: (context, state, child) => boxyPage(
                          state: state,
                          child: EventUserShell(child: child),
                        ),
                        routes: [
                          GoRoute(
                            path: 'details',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventUserDetailsTab(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'field',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventGroupingUserTab(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'live',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventScoresUserTab(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'scores',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: TournamentScoresUserTab(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'stats',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventStatsTab(eventId: state.pathParameters['id']!),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'register-form',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: EventRegistrationScreen(eventId: state.pathParameters['id']!),
                        ),
                      ),
                      GoRoute(
                        path: 'photos',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: const Center(child: Text('Event Photos Placeholder')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 2. Members
          StatefulShellBranch(
            navigatorKey: _branchMembersKey,
            routes: [
              GoRoute(
                path: '/members',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const MembersScreen(),
                ),
              ),
            ],
          ),
          // 3. Locker
          StatefulShellBranch(
            navigatorKey: _branchLockerKey,
            routes: [
              GoRoute(
                path: '/locker',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const LockerScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'standings',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const SeasonStandingsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 4. Archive
          StatefulShellBranch(
            navigatorKey: _branchArchiveKey,
            routes: [
              GoRoute(
                path: '/archive',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const ArchiveScreen(),
                ),
              ),
            ],
          ),
          // --- ADMIN ---
          // 5. Admin Dashboard
          StatefulShellBranch(
            navigatorKey: _branchAdminKey,
            routes: [
              GoRoute(
                path: '/admin',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const AdminDashboardScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'leaderboards/create/picker',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: const LeaderboardTypeSelectionScreen(isPicker: true),
                    ),
                   ),
                  GoRoute(
                    path: 'leaderboards/create/:type',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: Builder(builder: (context) {
                        final typeStr = state.pathParameters['type']!;
                        final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                        return LeaderboardBuilderScreen(type: type, isTemplate: false);
                      }),
                    ),
                  ),
                  GoRoute(
                    path: 'settings',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: const AdminSettingsScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'branding',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const BrandingSettingsScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'currency',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const CurrencySelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'grouping-strategy',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const GroupingStrategySelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'handicap-system',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const HandicapSystemSelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'society-cuts', 
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const SocietyCutsSettingsScreen(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 6. Admin Events
          StatefulShellBranch(
            navigatorKey: _branchAdminEventsKey,
            routes: [
              GoRoute(
                path: '/admin/events',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const AdminEventsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'admin-event-new',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const EventFormScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'competitions',
                    redirect: (context, state) => '/admin/events',
                    routes: [
                      GoRoute(
                        path: 'new',
                        pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const CompetitionTypeSelectionScreen(isPicker: true),
                    ),
                    routes: [
                      GoRoute(
                        path: 'gallery/:type',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: CompetitionTemplateGalleryScreen(
                            typeStr: state.pathParameters['type']!,
                            isPicker: true,
                          ),
                        ),
                      ),
                          GoRoute(
                            path: 'create/:type',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: CompetitionBuilderScreen(
                                format: CompetitionFormat.values.firstWhereOrNull(
                                  (f) => f.name == state.pathParameters['type'],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'edit/:id',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: CompetitionBuilderScreen(
                            competitionId: state.pathParameters['id'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ShellRoute(
                    pageBuilder: (context, state, child) => boxyPage(
                      state: state,
                      child: EventAdminShell(child: child),
                    ),
                    routes: [
                      GoRoute(
                        path: 'manage/:id',
                        builder: (context, state) => const SizedBox.shrink(),
                        routes: [
                          GoRoute(
                            path: 'event',
                            name: 'admin-event-manage-tower',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventAdminControlsScreen(eventId: state.pathParameters['id']!),
                            ),
                            routes: [
                              GoRoute(
                                path: 'edit',
                                name: 'admin-event-edit-form',
                                pageBuilder: (context, state) => boxyPage(
                                  state: state,
                                  child: EventFormScreen(
                                    eventId: state.pathParameters['id'],
                                    event: state.extra as GolfEvent?,
                                  ),
                                ),
                              ),
                              GoRoute(
                                path: 'grouping',
                                name: 'admin-event-grouping',
                                pageBuilder: (context, state) => boxyPage(
                                  state: state,
                                  child: EventAdminGroupingScreen(eventId: state.pathParameters['id']!),
                                ),
                              ),
                              GoRoute(
                                path: 'scorecards',
                                name: 'admin-event-scorecards',
                                pageBuilder: (context, state) => boxyPage(
                                  state: state,
                                  child: EventAdminScorecardsScreen(eventId: state.pathParameters['id']!),
                                ),
                              ),
                              GoRoute(
                                path: 'gallery',
                                name: 'admin-event-gallery',
                                pageBuilder: (context, state) => boxyPage(
                                  state: state,
                                  child: EventFieldAdminScreen(eventId: state.pathParameters['id']!),
                                ),
                              ),
                              GoRoute(
                                path: 'scores',
                                pageBuilder: (context, state) => boxyPage(
                                  state: state,
                                  child: EventAdminScoresScreen(eventId: state.pathParameters['id']!),
                                ),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: 'field-hub',
                            name: 'admin-event-field-hub',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventRegistrationsAdminScreen(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'registrations',
                            name: 'admin-event-registrations',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventRegistrationsAdminScreen(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'costs',
                            name: 'admin-event-costs',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventCostControlScreen(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'broadcast',
                            name: 'admin-event-broadcast',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventBroadcastScreen(eventId: state.pathParameters['id']!),
                            ),
                            routes: [
                              GoRoute(
                                path: 'edit/:itemId',
                                name: 'admin-event-broadcast-edit',
                                pageBuilder: (context, state) => boxyPage(
                                  state: state,
                                  child: FeedItemEditorScreen(
                                    eventId: state.pathParameters['id']!,
                                    existingItem: state.extra as EventFeedItem?,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: 'financials',
                            name: 'admin-event-financials',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventAdminFinancialsScreen(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'reporting',
                            name: 'admin-event-reporting',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventAdminReportsScreen(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'scores',
                            name: 'admin-event-scores',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventAdminScoresScreen(eventId: state.pathParameters['id']!),
                            ),
                            routes: [
                              GoRoute(
                                path: ':scorecardId',
                                name: 'admin-event-scorecard-detail',
                                pageBuilder: (context, state) => boxyPage(
                                  state: state,
                                  child: EventAdminScorecardsScreen(
                                    eventId: state.pathParameters['id']!,
                                    // scorecardId: state.pathParameters['scorecardId'], // If the screen supports it
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: 'manual-cuts',
                            name: 'admin-event-manual-cuts',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventManualCutsScreen(eventId: state.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'airdrops',
                            name: 'admin-event-airdrops',
                            pageBuilder: (context, state) => boxyPage(
                              state: state,
                              child: EventAirdropControlScreen(eventId: state.pathParameters['id']!),
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
          // 7. Admin Members
          StatefulShellBranch(
            navigatorKey: _branchAdminMembersKey,
            routes: [
              GoRoute(
                path: '/admin/members',
                pageBuilder: (context, state) => boxyPage(state: state,
                  child: const AdminMembersScreen(),
                ),
              ),
            ],
          ),
          // 8. Admin Communications
          StatefulShellBranch(
            navigatorKey: _branchAdminCommsKey,
            routes: [
              GoRoute(
                path: '/admin/communications',
                pageBuilder: (context, state) => boxyPage(state: state,
                  child: const NotificationAdminScaffold(),
                ),
              ),
            ],
          ),
          // 9. Admin Surveys
          StatefulShellBranch(
            navigatorKey: _branchAdminSurveysKey,
            routes: [
              GoRoute(
                path: '/admin/surveys',
                pageBuilder: (context, state) => boxyPage(state: state,
                  child: const AdminSurveysScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: const SurveyEditorScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'edit/:surveyId',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: SurveyEditorScreen(
                        surveyId: state.pathParameters['surveyId'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'results/:surveyId',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: SurveyResultsScreen(
                        surveyId: state.pathParameters['surveyId']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 10. Admin Reports
          StatefulShellBranch(
            navigatorKey: _branchAdminReportsKey,
            routes: [
              GoRoute(
                path: '/admin/reports',
                pageBuilder: (context, state) => boxyPage(state: state,
                  child: const AdminReportsScreen(), 
                ),
                routes: [
                  GoRoute(
                    path: 'leaderboard/:id',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: const Center(child: Text('Leaderboard Detail Placeholder')),
                    ),
                  ),
                ],
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
