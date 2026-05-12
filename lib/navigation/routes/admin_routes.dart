part of '../app_router.dart';

List<StatefulShellBranch> _buildAdminBranches(Ref ref) => [
          StatefulShellBranch(
            navigatorKey: _branchAdminKey,
            routes: [
              GoRoute(
                path: '/admin',
                name: 'admin-dashboard',
                redirect: (context, state) {
                  final user = ref.read(effectiveUserProvider);
                  if (user.role.isScorer) return '/admin/events';
                  return null;
                },
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
                          child: const DesignLabScreen(),
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
                                isTemplate: true,
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
                      GoRoute(
                        path: 'design-preview',
                        name: 'admin-settings-design-preview',
                        pageBuilder: (context, state) => boxyPage(state: state,
                          child: const DesignPreviewScreen(),
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
                    path: 'leaderboards/edit/local',
                    pageBuilder: (context, state) => boxyPage(state: state,
                      child: LeaderboardBuilderScreen(
                        existingConfig: state.extra as LeaderboardConfig?,
                        isTemplate: false,
                      ),
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
                  child: const EventsScreen(isAdminContext: true),
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
                    path: 'manage/:id',
                    redirect: (context, state) => '/admin/events/manage/${state.pathParameters['id']}/details',
                  ),
                  GoRoute(
                    path: 'manage/:id/details',
                    name: 'admin-event-details',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
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
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
                      child: MatchPlayDrawManagerScreen(
                        eventId: state.pathParameters['id'],
                        checkRoundProgression: state.uri.queryParameters['progress'] == 'true',
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/gallery',
                    name: 'admin-event-gallery',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
                      child: EventFieldAdminScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/scores',
                    name: 'admin-event-scores',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
                      child: EventAdminScoresScreen(eventId: state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: ':playerId',
                        name: 'admin-event-scorecard-edit',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: EventAdminScorecardEditorScreen(
                            eventId: state.pathParameters['id']!,
                            playerId: state.pathParameters['playerId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'manage/:id/stats',
                    name: 'admin-event-reporting',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
                      child: EventAdminReportsScreen(eventId: state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'manage/:id/controls',
                    name: 'admin-event-manage-tower',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      hubId: state.pathParameters['id']!,
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
                  // --- NESTED COMPETITION ROUTES ---
                  GoRoute(
                    path: 'manage/:id/game-setup',
                    name: 'admin-event-game-setup',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: CompetitionTypeSelectionScreen(
                        isPicker: true, 
                        eventId: state.pathParameters['id'],
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'gallery/:type',
                        name: 'admin-event-game-gallery',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: CompetitionTemplateGalleryScreen(
                            typeStr: state.pathParameters['type']!,
                            isPicker: true,
                            eventId: state.pathParameters['id']!,
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'create/:type',
                        name: 'admin-event-game-create',
                        pageBuilder: (context, state) => boxyPage(
                          state: state,
                          child: CompetitionBuilderScreen(
                            competitionId: state.pathParameters['id'],
                            competition: state.extra as Competition?,
                            format: CompetitionFormat.values.firstWhereOrNull(
                              (f) => f.name == state.pathParameters['type'],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'manage/:id/game-builder',
                    name: 'admin-event-game-builder',
                    pageBuilder: (context, state) => boxyPage(
                      state: state,
                      child: CompetitionBuilderScreen(
                        competitionId: state.pathParameters['id'],
                        competition: state.extra as Competition?,
                      ),
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
                  child: const MembersScreen(isAdminContext: true),
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
];
