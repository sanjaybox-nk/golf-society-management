import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
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
import '../features/admin/presentation/members/admin_member_renewal_screen.dart';
import '../features/admin/presentation/settings/admin_settings_screen.dart';
import '../features/admin/presentation/settings/branding_settings_screen.dart';
import '../features/admin/presentation/settings/currency_selection_screen.dart';
import '../features/admin/presentation/settings/grouping_strategy_selection_screen.dart';
import '../features/admin/presentation/settings/handicap_system_selection_screen.dart';
import '../features/admin/presentation/settings/society_cuts_settings_screen.dart';
import '../features/admin/presentation/settings/roles_screen.dart';
import '../features/admin/presentation/settings/system_role_members_screen.dart';
import '../features/admin/presentation/roles/committee_roles_screen.dart';
import '../features/admin/presentation/roles/committee_role_members_screen.dart';
import '../features/events/presentation/event_registration_screen.dart';
import 'package:golf_society/domain/models/member.dart';
import 'global_app_shell.dart';

import '../features/admin/presentation/surveys/admin_surveys_screen.dart';
import '../features/admin/presentation/surveys/survey_editor_screen.dart';
import '../features/admin/presentation/surveys/survey_results_screen.dart';
import '../features/admin/presentation/events/event_admin_reports_screen.dart';
import '../features/admin/presentation/reports/admin_reports_screen.dart';
import '../features/events/presentation/event_user_shell.dart';
import '../features/events/presentation/tabs/event_user_details_tab.dart';
import '../features/events/presentation/tabs/event_user_placeholders.dart';
import '../features/competitions/presentation/season_standings_screen.dart';
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
import '../features/admin/presentation/competitions/competition_type_selection_screen.dart';
import '../features/admin/presentation/competitions/competition_template_gallery_screen.dart';
import '../features/admin/presentation/competitions/competition_builder_screen.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/members/presentation/member_details_screen.dart';
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

// Hub Shell Navigator Keys
final _userHubNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'userHubNavigator');
final _adminHubNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'adminHubNavigator');

CustomTransitionPage boxyPage({
  required GoRouterState state,
  required Widget child,
  LocalKey? key,
}) {
  // We use the matchedLocation as the primary key source to ensure that the same logical route
  // always maintains its State and RenderObject during branch switching and non-destructive transitions.
  final pageKey = key ?? ValueKey('boxyPage-${state.matchedLocation}');
  debugPrint('DEBUG_ROUTER: Building page for ${state.matchedLocation} with key: $pageKey');

  return CustomTransitionPage(
    key: pageKey,
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

CustomTransitionPage hubPage({
  required GoRouterState state,
  required Widget child,
  required String id,
  bool isAdmin = false,
}) {
  // Stable Hub Key: Forces the shell to stay alive across tab switches.
  final hubKey = ValueKey('hub-${isAdmin ? 'admin' : 'user'}-$id');
  
  return CustomTransitionPage(
    key: hubKey,
    child: isAdmin 
      ? EventAdminShell(id: id, child: child) 
      : EventUserShell(id: id, child: child),
    transitionDuration: AppAnimations.medium,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppAnimations.entranceCurve),
        child: child,
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
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
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
                    redirect: (context, state) => '/events/${state.pathParameters['id']}/details',
                  ),
                  GoRoute(
                    path: ':id/details',
                    name: 'user-event-details',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      child: EventUserDetailsTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/field',
                    name: 'user-event-field',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      child: EventGroupingUserTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/live',
                    name: 'user-event-live',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      child: EventScoresUserTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/scores',
                    name: 'user-event-scores',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      child: TournamentScoresUserTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/stats',
                    name: 'user-event-stats',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      child: EventStatsUserTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/register-form',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventRegistrationScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/photos',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const Center(child: Text('Event Photos Placeholder')),
                    ),
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
              GoRoute(
                name: 'member-detail',
                path: '/members/:id',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: MemberDetailsScreen(id: state.pathParameters['id']!),
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
                name: 'admin-dashboard',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: const AdminDashboardScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'system-roles/:role',
                    name: 'admin-system-role-members',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: SystemRoleMembersScreen(
                        role: MemberRole.values.byName(state.pathParameters['role']!),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'committee-roles/:role',
                    name: 'admin-committee-role-members',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: CommitteeRoleMembersScreen(
                        role: state.pathParameters['role']!,
                      ),
                    ),
                  ),
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
                    name: 'admin-settings',
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
                      GoRoute(
                        path: 'committee-roles',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const CommitteeRolesScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'roles',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const RolesScreen(),
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
                name: 'admin-events',
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
                  GoRoute(
                    path: 'manage/:id',
                    redirect: (context, state) => '/admin/events/manage/${state.pathParameters['id']}/details',
                  ),
                  GoRoute(
                    path: 'manage/:id/details',
                    name: 'admin-event-details',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      isAdmin: true,
                      child: EventUserDetailsTab(
                        eventId: state.pathParameters['id']!,
                        isAdminMode: true,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/event/edit',
                    name: 'admin-event-edit',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventFormScreen(
                        eventId: state.pathParameters['id'],
                        event: state.extra as GolfEvent?,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/gallery',
                    name: 'admin-event-gallery',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      isAdmin: true,
                      child: EventFieldAdminScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/scores',
                    name: 'admin-event-scores',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      isAdmin: true,
                      child: EventAdminScoresScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/stats',
                    name: 'admin-event-reporting',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      isAdmin: true,
                      child: EventAdminReportsScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/controls',
                    name: 'admin-event-manage-tower',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      isAdmin: true,
                      child: EventAdminControlsScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  // Legacy/Sub-routes
                  GoRoute(
                    path: 'manage/:id/registrations',
                    name: 'admin-event-registrations',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventRegistrationsAdminScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/costs',
                    name: 'admin-event-costs',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventCostControlScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/broadcast',
                    name: 'admin-event-broadcast',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventBroadcastScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/financials',
                    name: 'admin-event-financials',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventAdminFinancialsScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/manual-cuts',
                    name: 'admin-event-manual-cuts',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventManualCutsScreen(eventId: state.pathParameters['id']!),
                    ),
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
                name: 'admin-members',
                pageBuilder: (context, state) => boxyPage(state: state,
                  child: const AdminMembersScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'renewal',
                    name: 'admin-member-renewal',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const AdminMemberRenewalScreen(),
                    ),
                  ),
                ],
              ),
              GoRoute(
                name: 'admin-member-detail',
                path: '/admin/members/:id',
                pageBuilder: (context, state) => boxyPage(
                  state: state,
                  child: MemberDetailsScreen(id: state.pathParameters['id']!, isAdminContext: true),
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
                name: 'admin-comms',
                pageBuilder: (context, state) => boxyPage(state: state,
                  child: const NotificationAdminScaffold(),
                ),
              ),
            ],
          ),

          // 10. Admin Reports
          StatefulShellBranch(
            navigatorKey: _branchAdminReportsKey,
            routes: [
              GoRoute(
                path: '/admin/reports',
                name: 'admin-reports',
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
