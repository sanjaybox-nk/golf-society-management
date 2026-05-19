import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
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
import '../features/admin/presentation/admin_operations_screen.dart';
import '../features/admin/presentation/events/event_admin_controls_screen.dart';
import '../features/admin/presentation/events/event_form_screen.dart';
import '../features/admin/presentation/members/admin_member_renewal_screen.dart';
import '../features/admin/presentation/settings/design_lab_screen.dart';
import '../features/admin/presentation/settings/platform_content_editor_screen.dart';
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
import '../features/admin/presentation/treasury/admin_season_financials_screen.dart';
import '../features/admin/presentation/seasons/admin_seasons_screen.dart';
import '../features/admin/presentation/seasons/season_form_screen.dart';
import '../features/admin/presentation/settings/admin_settings_hub_screen.dart';
import '../features/admin/presentation/settings/system_role_members_screen.dart';
import '../features/admin/presentation/settings/design_preview_screen.dart';
import '../features/admin/presentation/roles/committee_roles_screen.dart';
import '../features/admin/presentation/roles/committee_role_members_screen.dart';
import '../features/admin/presentation/surveys/admin_surveys_screen.dart';
import '../features/admin/presentation/surveys/survey_editor_screen.dart';
import '../features/admin/presentation/surveys/survey_results_screen.dart';
import '../features/admin/presentation/matchplay/match_play_draw_manager_screen.dart';
import '../features/admin/presentation/notifications/compose_notification_screen.dart';
import '../features/events/presentation/event_registration_screen.dart';
import 'global_app_shell.dart';
import '../features/admin/presentation/reports/admin_reports_screen.dart';
import '../features/events/presentation/tabs/event_user_details_tab.dart';
import '../features/events/presentation/event_feed_detail_screen.dart';
import '../features/events/presentation/tabs/event_field_hub_tab.dart';
import '../features/events/presentation/tabs/event_scores_hub_tab.dart';
import '../features/events/presentation/tabs/event_results_hub_tab.dart';

import '../features/competitions/presentation/season_standings_screen.dart';
import '../features/competitions/presentation/season_leaderboard_detail_screen.dart';
import '../features/admin/presentation/events/event_admin_financials_screen.dart';
import '../features/admin/presentation/events/event_admin_scores_screen.dart';
import '../features/admin/presentation/events/event_admin_verify_screen.dart';
import '../features/admin/presentation/events/event_admin_manage_screen.dart';
import '../features/admin/presentation/events/event_admin_grouping_screen.dart';
import '../features/admin/presentation/events/event_admin_scorecard_editor_screen.dart';
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

part 'routes/member_routes.dart';
part 'routes/admin_routes.dart';
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
final _branchAdminOperationsKey = GlobalKey<NavigatorState>(debugLabel: 'branchAdminOperations');

CustomTransitionPage boxyPage({
  required GoRouterState state,
  required Widget child,
  LocalKey? key,
  String? hubId, // Optional: if provided, wraps in appropriate Event Shell
}) {
  // Deterministic Admin Context detection for Hub shells
  final bool isAdmin = state.matchedLocation.contains('/admin');

  // [Hardened Deterministic Key Strategy] 
  // We anchor every screen to its strictly resolved location path. 
  // For Hub-based pages, we anchor to the HUB root to keep the shell persistent.
  final stableKey = key ?? ValueKey(hubId != null 
      ? 'hub:$hubId:${isAdmin ? 'admin' : 'user'}' 
      : 'page:${state.matchedLocation}');
  
  if (kDebugMode) debugPrint('DEBUG_ROUTER [HARDENED]: Identity anchored -> $stableKey');

  return CustomTransitionPage(
    key: stableKey,
    child: hubId != null 
      ? (isAdmin 
          ? EventAdminShell(id: hubId, child: child) 
          : EventAdminShell(id: hubId, child: child))
      : child,
    transitionDuration: AppAnimations.medium,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (hubId != null) {
        // Hubs use standard fade for smooth tab-like transitions
        return FadeTransition(opacity: CurvedAnimation(parent: animation, curve: AppAnimations.entranceCurve), child: child);
      }

      // Standard pages use the signature Design 4.x slide-fade entrance
      final fade = CurvedAnimation(parent: animation, curve: AppAnimations.entranceCurve);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: AppAnimations.entranceCurve));

      return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
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
          ..._buildMemberBranches(),
          ..._buildAdminBranches(ref),
        ],
      ),
    ],
  );
});
