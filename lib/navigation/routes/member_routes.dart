part of '../app_router.dart';

List<StatefulShellBranch> _buildMemberBranches() => [
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
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
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
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
                      child: EventGroupingUserTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/live',
                    name: 'user-event-live',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
                      child: EventScoresUserTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/scores',
                    name: 'user-event-scores',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
                      child: TournamentScoresUserTab(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id/stats',
                    name: 'user-event-stats',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
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
];
