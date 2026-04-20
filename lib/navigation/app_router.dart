import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
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
import '../features/admin/presentation/settings/branding_settings_screen.dart';
import '../features/admin/presentation/settings/society_identity_screen.dart';
import '../features/admin/presentation/settings/app_appearance_screen.dart';
import '../features/admin/presentation/settings/currency_selection_screen.dart';
import '../features/admin/presentation/settings/grouping_strategy_selection_screen.dart';
import '../features/admin/presentation/settings/handicap_system_selection_screen.dart';
import '../features/admin/presentation/settings/society_cuts_settings_screen.dart';
import '../features/admin/presentation/settings/treasury_settings_screen.dart';
import '../features/admin/presentation/settings/admin_sponsorship_hub_screen.dart';
import '../features/admin/presentation/settings/roles_screen.dart';
import '../features/admin/presentation/treasury/admin_debt_ledger_screen.dart';
import '../features/admin/presentation/seasons/admin_seasons_screen.dart';
import '../features/admin/presentation/seasons/season_form_screen.dart';
import '../features/admin/presentation/settings/admin_settings_hub_screen.dart';
import '../features/admin/presentation/settings/system_role_members_screen.dart';
import '../features/admin/presentation/roles/committee_roles_screen.dart';
import '../features/admin/presentation/roles/committee_role_members_screen.dart';
import '../features/admin/presentation/surveys/admin_surveys_screen.dart';
import '../features/admin/presentation/surveys/survey_editor_screen.dart';
import '../features/admin/presentation/surveys/survey_results_screen.dart';
import '../features/admin/presentation/matchplay/match_play_draw_manager_screen.dart';
import '../features/admin/presentation/notifications/compose_notification_screen.dart';
import '../features/events/presentation/event_registration_screen.dart';
import 'global_app_shell.dart';
import '../features/admin/presentation/events/event_admin_reports_screen.dart';
import '../features/admin/presentation/reports/admin_reports_screen.dart';
import '../features/events/presentation/event_user_shell.dart';
import '../features/events/presentation/tabs/event_user_details_tab.dart';
import '../features/events/presentation/event_feed_detail_screen.dart';
import '../features/events/presentation/tabs/event_user_placeholders.dart';
import '../features/competitions/presentation/season_standings_screen.dart';
import '../features/competitions/presentation/season_leaderboard_detail_screen.dart';
import '../features/admin/presentation/events/event_admin_financials_screen.dart';
import '../features/admin/presentation/events/event_admin_scores_screen.dart';
import 'package:golf_society/features/admin/presentation/events/event_broadcast_screen.dart';
import 'package:golf_society/features/admin/presentation/events/feed_item_editor_screen.dart';
import 'package:golf_society/features/admin/presentation/events/event_cost_control_screen.dart';
import '../features/admin/presentation/events/event_field_admin_screen.dart';
import '../features/admin/presentation/events/event_manual_cuts_screen.dart';
import '../features/admin/presentation/events/event_registrations_admin_screen.dart';
import '../features/admin/presentation/events/event_fines_workbench_screen.dart';
import '../features/admin/presentation/events/event_admin_shell.dart';
import '../features/admin/presentation/notifications/notification_admin_scaffold.dart';
import '../features/admin/presentation/notifications/admin_audience_hub_screen.dart';
import '../features/home/presentation/notification_inbox_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_type_selection_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_builder_screen.dart';
import '../features/admin/presentation/competitions/competition_type_selection_screen.dart';
import '../features/admin/presentation/competitions/competition_template_gallery_screen.dart';
import '../features/admin/presentation/competitions/competition_builder_screen.dart';
import '../features/surveys/presentation/survey_detail_screen.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/members/presentation/member_details_screen.dart';
import '../features/admin/presentation/leaderboards/leaderboard_template_gallery_screen.dart';
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
final _branchAdminReportsKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdminReports');

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
        redirect: (context, state) {
          final user = ref.read(effectiveUserProvider);
          final bool isDeparted = user.status == MemberStatus.left || user.status == MemberStatus.archived;
          
          if (isDeparted) {
             final location = state.matchedLocation;
             if (location == '/' || location == '/home' || location == '/events' || location == '/members') {
               return '/locker';
             }
          }
          return '/home';
        },
      ),
      // --- GLOBAL SURVEYS (Redirect to Shell) ---
      GoRoute(
        path: '/surveys/:id',
        redirect: (context, state) => '/home/surveys/${state.pathParameters['id']}',
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
                  GoRoute(
                    path: 'surveys/:id',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: SurveyDetailScreen(surveyId: state.pathParameters['id']!),
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
                    path: ':id/register-form',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventRegistrationScreen(eventId: state.pathParameters['id']!),
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
                    path: ':id/photos',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const Center(child: Text('Event Photos Placeholder')),
                    ),
                  ),
                  GoRoute(
                    path: ':id/feed/:itemId',
                    name: 'user-event-feed-item',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventFeedDetailScreen(
                        eventId: state.pathParameters['id']!,
                        itemId: state.pathParameters['itemId']!,
                        item: state.extra as EventFeedItem?,
                      ),
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
                    routes: [
                      GoRoute(
                        path: ':leaderboardId',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: SeasonLeaderboardDetailScreen(
                            leaderboardId: state.pathParameters['leaderboardId']!,
                            seasonId: state.uri.queryParameters['seasonId'],
                          ),
                        ),
                      ),
                    ],
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
                  child: AdminDashboardScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'admin-settings-hub',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const AdminSettingsHubScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'identity',
                        name: 'admin-settings-identity',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: const SocietyIdentityScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'appearance',
                        name: 'admin-settings-appearance',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: const AppAppearanceScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'branding',
                        name: 'admin-settings-branding',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const BrandingSettingsScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'sponsors',
                        name: 'admin-sponsorship-hub',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const AdminSponsorshipHubScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'currency',
                        name: 'admin-settings-currency',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const CurrencySelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'grouping-strategy',
                        name: 'admin-settings-grouping',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const GroupingStrategySelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'handicap-system',
                        name: 'admin-settings-handicap',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const HandicapSystemSelectionScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'society-cuts', 
                        name: 'admin-settings-cuts',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const SocietyCutsSettingsScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'committee-roles',
                        name: 'admin-settings-committee-roles',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const CommitteeRolesScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'treasury',
                        name: 'admin-settings-treasury',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const TreasurySettingsScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'seasons',
                        name: 'admin-settings-seasons',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const AdminSeasonsScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: 'new',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: const SeasonFormScreen(),
                            ),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: SeasonFormScreen(
                                seasonId: state.pathParameters['id'],
                                season: state.extra as Season?,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'templates',
                        name: 'admin-settings-templates',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const CompetitionTypeSelectionScreen(isPicker: false),
                        ),
                        routes: [
                          GoRoute(
                            path: 'gallery/:type',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: CompetitionTemplateGalleryScreen(
                                typeStr: state.pathParameters['type']!,
                                isPicker: false,
                              ),
                            ),
                          ),
                          GoRoute(
                            path: 'create/:type',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: CompetitionBuilderScreen(
                                format: CompetitionFormat.values.firstWhereOrNull(
                                  (f) => f.name == state.pathParameters['type'],
                                ),
                              ),
                            ),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: CompetitionBuilderScreen(
                                competitionId: state.pathParameters['id'],
                                isTemplate: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'leaderboards',
                        name: 'admin-settings-leaderboards',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const LeaderboardTypeSelectionScreen(isPicker: false),
                        ),
                        routes: [
                          GoRoute(
                            path: 'select-type',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: const LeaderboardTypeSelectionScreen(isPicker: false),
                            ),
                          ),
                          GoRoute(
                            path: 'gallery/:type',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: LeaderboardTemplateGalleryScreen(
                                type: LeaderboardType.values.byName(state.pathParameters['type']!),
                                isTemplate: true,
                              ),
                            ),
                          ),
                          GoRoute(
                            path: 'create/:type',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: LeaderboardBuilderScreen(
                                type: LeaderboardType.values.byName(state.pathParameters['type']!),
                                isTemplate: true,
                              ),
                            ),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            pageBuilder: (context, state) => boxyPage(state: state,
                              child: LeaderboardBuilderScreen(
                                configId: state.pathParameters['id'],
                                existingConfig: state.extra as LeaderboardConfig?,
                                isTemplate: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'roles',
                        name: 'admin-settings-roles',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const RolesScreen(),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'debt-ledger',
                    name: 'admin-debt-ledger',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const AdminDebtLedgerScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'member-renewal',
                    name: 'admin-member-renewal',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const AdminMemberRenewalScreen(),
                    ),
                  ),
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
                    routes: [
                      GoRoute(
                        path: 'gallery/:type',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: LeaderboardTemplateGalleryScreen(
                            type: LeaderboardType.values.byName(state.pathParameters['type']!),
                            isPicker: true,
                          ),
                        ),
                      ),
                    ],
                   ),
                  GoRoute(
                    path: 'leaderboards/create/:type',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: Consumer(builder: (context, ref, _) {
                        final typeStr = state.pathParameters['type']!;
                        final type = LeaderboardType.values.firstWhere((e) => e.name == typeStr);
                        return LeaderboardBuilderScreen(type: type, isTemplate: false);
                      }),
                    ),
                  ),
                  GoRoute(
                    path: 'surveys',
                    name: 'admin-surveys',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const AdminSurveysScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: const SurveyEditorScreen(),
                        ),
                      ),
                      GoRoute(
                        path: 'edit/:id',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: SurveyEditorScreen(surveyId: state.pathParameters['id']),
                        ),
                      ),
                      GoRoute(
                        path: 'results/:id',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: SurveyResultsScreen(surveyId: state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'compose',
                    name: 'admin-notifications-compose',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: ComposeNotificationScreen(
                        isTabbed: false,
                        eventId: state.uri.queryParameters['eventId'],
                        type: state.uri.queryParameters['type'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'audience',
                    name: 'admin-audience',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const AdminAudienceHubScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'matchplay/draw',
                    name: 'admin-matchplay-draw',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const MatchPlayDrawManagerScreen(),
                    ),
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
                    path: 'manage/:id/matchplay/draw',
                    name: 'admin-event-matchplay-draw',
                    pageBuilder: (context, state) => hubPage(
                      state: state,
                      id: state.pathParameters['id']!,
                      isAdmin: true,
                      child: MatchPlayDrawManagerScreen(
                        eventId: state.pathParameters['id'],
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
                    routes: [
                      GoRoute(
                        path: 'edit/:itemId',
                        name: 'admin-event-broadcast-edit',
                        pageBuilder: (context, state) {
                          final eventId = state.pathParameters['id']!;
                          final existingItem = state.extra as EventFeedItem?;
                          
                          if (existingItem?.type == FeedItemType.newsletter) {
                            return boxyPage(
                              state: state,
                              child: ComposeNotificationScreen(
                                eventId: eventId,
                                feedItemId: existingItem?.id,
                              ),
                            );
                          }
                          
                          return boxyPage(
                            state: state,
                            child: FeedItemEditorScreen(
                              eventId: eventId,
                              existingItem: existingItem,
                            ),
                          );
                        },
                      ),
                    ],
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
                    path: 'manage/:id/feed/:itemId',
                    name: 'admin-event-feed-item',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventFeedDetailScreen(
                        eventId: state.pathParameters['id']!,
                        itemId: state.pathParameters['itemId']!,
                        item: state.extra as EventFeedItem?,
                      ),
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
                  GoRoute(
                    path: 'manage/:id/fines',
                    name: 'admin-event-fines',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: EventFinesWorkbenchScreen(eventId: state.pathParameters['id']!),
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
                  // Renewal Hub moved to Branch 5 for shell persistence
                  GoRoute(
                    path: 'new',
                    name: 'admin-member-new',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: const MemberDetailsScreen(id: 'new', isAdminContext: true),
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
