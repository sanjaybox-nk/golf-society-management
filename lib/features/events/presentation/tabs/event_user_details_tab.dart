import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../events_provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'dart:io';
import '../../domain/registration_logic.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../competitions/presentation/widgets/competition_shared_widgets.dart';
import '../widgets/event_structural_cards.dart';


enum EventInfoSubTab {
  info,
  notifications,
}

class EventUserDetailsTab extends ConsumerWidget {
  final String eventId;
  final bool useScaffold;
  final bool isAdminMode;

  const EventUserDetailsTab({super.key, required this.eventId, this.useScaffold = true, this.isAdminMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    
    return eventAsync.when(
      data: (event) {
        final config = ref.watch(themeControllerProvider);
        final user = ref.watch(effectiveUserProvider);

        // Check for preview mode
        bool isPreview = false;
        try {
          isPreview = GoRouterState.of(context).uri.queryParameters['preview'] == 'true';
        } catch (_) {
          isPreview = false;
        }

        return EventDetailsContent(
          event: event, 
          currencySymbol: config.currencySymbol,
          isPreview: isPreview,

          isAdminMode: isAdminMode,
          onStatusChanged: (user.role != MemberRole.member) ? (newStatus) {
            ref.read(eventsRepositoryProvider).updateEvent(
              event.copyWith(status: newStatus),
            );
          } : null,
        );
      },
      loading: () => useScaffold 
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const Center(child: CircularProgressIndicator()),
      error: (err, stack) => useScaffold
          ? Scaffold(body: Center(child: Text('Error: $err')))
          : Center(child: Text('Error: $err')),
    );
  }
}

class EventDetailsContent extends ConsumerStatefulWidget {
  final GolfEvent event;
  final String currencySymbol;
  final bool isPreview;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final ValueChanged<EventStatus>? onStatusChanged;
  final Widget? bottomNavigationBar;
  final bool useScaffold;
  final bool isAdminMode;
  final Competition? competition; // Optional direct competition object for previewing

  const EventDetailsContent({
    super.key,
    required this.event, 
    required this.currencySymbol,
    this.isPreview = false,
    this.onCancel,
    this.onEdit,
    this.onStatusChanged,
    this.bottomNavigationBar,
    this.useScaffold = true,
    this.isAdminMode = false,
    this.competition,
  });

  @override
  ConsumerState<EventDetailsContent> createState() => _EventDetailsContentState();
}

class _EventDetailsContentState extends ConsumerState<EventDetailsContent> {
  EventInfoSubTab _selectedTab = EventInfoSubTab.notifications;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(effectiveUserProvider);
    final isStaff = user.role != MemberRole.member;
    
    final event = widget.event;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      primary: false,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: HeadlessScaffold(
        title: event.title,
        subtitle: 'Event Info Hub',
        showAdminShortcut: false, // Explicitly removed as requested
  
        leading: widget.isPreview ? Center(
          child: BoxyArtGlassIconButton(
            icon: Icons.close_rounded,
            iconSize: 24,
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ) : null,
        showBack: true,
        onBack: () {
          if (widget.isPreview && widget.onCancel != null) {
            widget.onCancel!();
            return;
          }
          
          if (widget.isAdminMode) {
            context.go('/admin/events');
          } else {
            context.go('/events');
          }
        },
        actions: [
          if (!widget.isPreview && widget.isAdminMode && isStaff && _selectedTab == EventInfoSubTab.info) ...[
            if (widget.onEdit != null)
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                iconSize: 24,
                onPressed: widget.onEdit,
                tooltip: 'Edit Event Settings',
              )
            else ...[
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                iconSize: 24,
                onPressed: () => context.pushNamed(
                  'admin-event-edit',
                  pathParameters: {'id': event.id},
                  extra: event,
                ),
                tooltip: 'Edit Event Settings',
              ),
            ],
          ],
        ],
        slivers: [
          // Baseline Nudge for Tab Bar
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16.0),
              child: ModernUnderlinedFilterBar<EventInfoSubTab>(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                isExpanded: true,
                tabs: const [
                  ModernFilterTab(label: 'News updates', value: EventInfoSubTab.notifications),
                  ModernFilterTab(label: 'Event Info', value: EventInfoSubTab.info),
                ],
                selectedValue: _selectedTab,
                onTabSelected: (tab) => setState(() => _selectedTab = tab),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Content Spacing (Standardized 24px overall visual: 16px container space + 8px spacer)
              const SizedBox(height: AppSpacing.xs),
              
              if (_selectedTab == EventInfoSubTab.info) ...[
                _buildDateTimeSection(context),
                const SizedBox(height: AppSpacing.sectionTitleTop), // Manual gap for first two cards (no titles)
                _buildHeroSection(context),
                
                if (event.eventType == EventType.golf) ...[
                  _buildCourseSelectionSection(context),
                  _buildCourseDataHardeningSection(context),
                ],
                if (event.status == EventStatus.published && event.eventType == EventType.golf) ...[
                   CompetitionRulesCard(
                    eventId: event.id,
                    title: 'Competition Rules',
                    competition: widget.competition,
                  ),
                ],

                _buildPlayingCostsSection(context),
                _buildMealCostsSection(context),
                _buildDinnerLocationSection(context),
                _buildFacilitiesSection(context),
                _buildAwardsSection(context, ref),
                _buildNotesSection(context),
              ]
 else ...[
                _buildNotificationsSection(context, ref),
              ],
            ]),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref) {
    final event = widget.event;
    final user = ref.watch(effectiveUserProvider);
    final isStaff = user.role != MemberRole.member;


    final publishedItems = event.effectiveFeedItems.where((i) => i.isPublished).toList();
    
    // Sort logic same as EventUserHomeTab
    publishedItems.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });

    // Headline is handled by the scaffold header; others should be allowed to render or self-shrink
    final displayItems = publishedItems.where((item) => 
      item.type != FeedItemType.headline 
    ).toList();

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    bool userIsInGroup = false;
    final groupsData = event.grouping['groups'] as List?;
    if (groupsData != null) {
      for (var gd in groupsData) {
        final players = (gd as Map<String, dynamic>)['players'] as List?;
        if (players != null && players.any((p) => (p as Map<String, dynamic>)['registrationMemberId'] == user.id)) {
          userIsInGroup = true;
          break;
        }
      }
    }

    final bool showYourGroup = event.isGroupingPublished && userIsInGroup;
    
    int firstSectionedIndex = -1;
    if (!showYourGroup) {
      firstSectionedIndex = displayItems.indexWhere((item) => 
        item.type == FeedItemType.registration || 
        item.type == FeedItemType.gallerySnippet || 
        item.type == FeedItemType.podium
      );
    }

    return Column(
      children: [
        if (showYourGroup) YourGroupCard(event: event, isPeeking: true),

        if (displayItems.isEmpty && !showYourGroup) ...[
          SizedBox(height: spacing?.cardToLabel ?? AppSpacing.x4l),
          const BoxyArtEmptyState(
            icon: Icons.notifications_off_rounded,
            title: 'No Notifications',
            message: 'Check back later for event updates and newsletters.',
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayItems.length,
            separatorBuilder: (context, index) {
              final nextItem = displayItems[index + 1];
              // Items with internal section titles handle their own top padding via cardToLabel
              if (nextItem.type == FeedItemType.gallerySnippet || 
                  nextItem.type == FeedItemType.podium || 
                  nextItem.type == FeedItemType.registration) {
                return const SizedBox.shrink();
              }
              // Standard items use cardToCard gap
              return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
            },
            itemBuilder: (context, index) {
              final item = displayItems[index];
              final bool shouldPeek = (!showYourGroup && index == firstSectionedIndex);

              switch (item.type) {
                case FeedItemType.headline:
                  return const SizedBox.shrink();
                case FeedItemType.podium:
                  return EventPodiumCard(event: event, isManagement: isStaff, isPeeking: shouldPeek);
                case FeedItemType.registration:
                  return EventRegistrationCard(event: event, isManagement: isStaff, isPeeking: shouldPeek);
                case FeedItemType.gallerySnippet:
                  return EventGalleryCard(event: event, isManagement: isStaff, isPeeking: shouldPeek);
                case FeedItemType.flash:
                  return _buildFlashItem(context, item);
                case FeedItemType.newsletter:
                  return _buildNewsletterItem(context, item);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFlashItem(BuildContext context, EventFeedItem item) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
        borderRadius: AppShapes.lg,
        border: Border.all(color: AppColors.amber500.withValues(alpha: AppColors.opacityMuted)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign_rounded, color: AppColors.amber500),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.content,
              style: const TextStyle(
                fontSize: AppTypography.sizeButton,
                fontWeight: AppTypography.weightExtraBold,
                color: AppColors.amber500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterItem(BuildContext context, EventFeedItem item) {
    final event = widget.event;
    String snippet = '';
    try {
      final decoded = jsonDecode(item.content);
      if (decoded is List && decoded.isNotEmpty) {
        final firstNote = EventNote.fromJson(decoded.first as Map<String, dynamic>);
        snippet = _getPlainTextSnippet(firstNote.content);
      } else {
        snippet = _getPlainTextSnippet(item.content);
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        final isAdmin = GoRouterState.of(context).uri.path.startsWith('/admin');
        final prefix = isAdmin ? '/admin/events/manage/${event.id}' : '/events/${event.id}';
        context.push('$prefix/feed/${item.id}', extra: item);
      },
      child: BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
                  child: Image.network(
                    item.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.title != null && item.title!.isNotEmpty) ...[
                      Text(
                        item.title!,
                        style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeLargeBody),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (snippet.isNotEmpty)
                      Text(
                        snippet,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sizeBodySmall,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: AppColors.opacityHigh),
                          height: 1.5,
                        ),
                      ),
                    SizedBox(height: Theme.of(context).extension<AppSpacingTokens>()?.labelToCard ?? AppSpacing.lg),
                    Row(
                      children: [
                        Text(
                          'READ FULL STORY',
                          style: TextStyle(
                            fontSize: AppTypography.sizeCaptionStrong,
                            fontWeight: AppTypography.weightBlack,
                            letterSpacing: 1.2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(Icons.arrow_forward_rounded, size: AppShapes.iconXs, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }

  String _getPlainTextSnippet(String quillJson) {
    try {
      final delta = jsonDecode(quillJson);
      if (delta is List) {
        final buffer = StringBuffer();
        for (var op in delta) {
          if (op is Map && op.containsKey('insert') && op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }
        return buffer.toString().trim();
      }
    } catch (_) {}
    return quillJson.length > 150 ? '${quillJson.substring(0, 147)}...' : quillJson;
  }



  Widget _buildHeroSection(BuildContext context) {
    if (widget.event.imageUrl != null && widget.event.imageUrl!.isNotEmpty) {
      return BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppShapes.xl,
              child: Image.network(
                widget.event.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            if (widget.event.description != null && widget.event.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: _buildRichDescription(context, widget.event.description!),
              ),
          ],
        ),
      );
    } else if (widget.event.description != null && widget.event.description!.isNotEmpty) {
      return BoxyArtCard(
        child: _buildRichDescription(context, widget.event.description!),
      );
    }
    return const SizedBox.shrink();
  }


  Widget _buildRichDescription(BuildContext context, String content) {
    // Handle both JSON Delta and Plain Text
    late quill.QuillController controller;
    
    if (content.startsWith('[{"insert"')) {
      try {
        controller = quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(content)),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } catch (_) {
        controller = quill.QuillController.basic();
        controller.readOnly = true;
      }
    } else {
      controller = quill.QuillController.basic();
      controller.readOnly = true;
      controller.document.insert(0, content);
    }

    return BoxyArtRichEditor(
      controller: controller,
      readOnly: true,
      showToolbar: false,
      scrollable: false,
      minHeight: 0,
    );
  }


  Widget _buildDateTimeSection(BuildContext context) {
    final event = widget.event;
    final gradient = AppGradients.brandPrimary(context);
    
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      gradient: gradient,
      isHero: true,
      customShadows: Theme.of(context).extension<AppShadows>()?.softScale,
      child: Column(
        children: [
          if (event.courseName != null) ...[
            ModernInfoRow(
              label: 'LOCATION',
              value: event.courseName!,
              icon: Icons.location_on_outlined,
              labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
              valueColor: AppColors.pureWhite,
              iconColor: AppColors.pureWhite,
              trailing: BoxyArtGlassIconButton(
                icon: Icons.map_outlined,
                iconSize: 20,
                onPressed: () => _launchMap(event.courseName!, event.courseDetails),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          ModernInfoRow(
            label: event.isMultiDay ? 'START DATE' : 'EVENT DATE',
            value: DateFormat('EEEE, d MMM yyyy').format(event.date),
            icon: Icons.calendar_today_rounded,
            labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
            valueColor: AppColors.pureWhite,
            iconColor: AppColors.pureWhite,
          ),
          if (event.isMultiDay && event.endDate != null) ...[
            const SizedBox(height: AppSpacing.xl),
            ModernInfoRow(
              label: 'END DATE',
              value: DateFormat('EEEE, d MMM yyyy').format(event.endDate!),
              icon: Icons.calendar_today_rounded,
              labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
              valueColor: AppColors.pureWhite,
              iconColor: AppColors.pureWhite,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          ModernInfoRow(
            label: 'REGISTRATION',
            value: event.regTime != null 
                ? DateFormat('h:mm a').format(event.regTime!)
                : 'TBA',
            icon: Icons.app_registration_rounded,
            labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
            valueColor: AppColors.pureWhite,
            iconColor: AppColors.pureWhite,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (event.eventType == EventType.golf) ...[
            ModernInfoRow(
              label: 'TEE-OFF',
              value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
              icon: Icons.schedule_rounded,
              labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
              valueColor: AppColors.pureWhite,
              iconColor: AppColors.pureWhite,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          if (event.registrationDeadline != null) ...[
            ModernInfoRow(
              label: 'REGISTRATION CLOSES',
              value: '${DateFormat('d MMM').format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
              icon: Icons.timer_outlined,
              iconColor: AppColors.pureWhite,
              labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
              valueColor: AppColors.pureWhite,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseSelectionSection(BuildContext context) {
    final event = widget.event;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Course'),
        BoxyArtCard(
          child: Column(
            children: [
              if (event.courseDetails != null && event.courseDetails!.isNotEmpty) ...[
                ModernInfoRow(
                  label: 'Course Details',
                  value: event.courseDetails!,
                  icon: Icons.info_outline_rounded,
                ),
              ],
              if (event.eventType == EventType.golf && (event.selectedTeeName != null || event.selectedFemaleTeeName != null)) ...[
                const SizedBox(height: AppSpacing.standard),
                Builder(
                  builder: (context) {
                    final maleTee = event.selectedTeeName;
                    final femaleTee = event.selectedFemaleTeeName;
                    String value;
                    if (maleTee != null && femaleTee != null) {
                      if (maleTee == femaleTee) {
                        value = maleTee;
                      } else {
                        value = '$maleTee / $femaleTee';
                      }
                    } else {
                      value = maleTee ?? femaleTee ?? 'TBA';
                    }
                    return ModernInfoRow(
                      label: 'Tee Position',
                      value: value,
                      icon: Icons.flag_rounded,
                    );
                  }
                ),
              ],
              if (event.maxParticipants != null) ...[
                const SizedBox(height: AppSpacing.standard),
                Builder(
                  builder: (context) {
                    final stats = RegistrationLogic.getRegistrationStats(event);
                    final available = (event.maxParticipants! - stats.confirmedGolfers).clamp(0, event.maxParticipants!);
                    return ModernInfoRow(
                      label: 'Field Capacity',
                      value: '$available / ${event.maxParticipants} slots available',
                      icon: Icons.groups_rounded,
                    );
                  }
                ),
              ],
              const SizedBox(height: AppSpacing.standard),
              ModernInfoRow(
                label: 'Dress Code',
                value: event.dressCode ?? 'Standard Golf Attire',
                icon: Icons.checkroom_rounded,
              ),
              if (event.eventType == EventType.golf && event.availableBuggies != null) ...[
                const SizedBox(height: AppSpacing.standard),
                ModernInfoRow(
                  label: 'Buggies',
                  value: '${event.availableBuggies} available',
                  icon: Icons.electric_rickshaw_rounded,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchMap(String courseName, String? details) async {
    final query = details != null && details.isNotEmpty 
        ? '$courseName, $details' 
        : courseName;
    final encodedQuery = Uri.encodeComponent(query);
    
    // Use platform specific URL schemes if possible, fallback to universal
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$encodedQuery';

    final Uri url = Uri.parse(Platform.isIOS ? appleMapsUrl : googleMapsUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to generic browser search if map apps can't be launched
        final searchUrl = Uri.parse('https://www.google.com/search?q=$encodedQuery');
        await launchUrl(searchUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Silently fail or show error
    }
  }

  Widget _buildCourseDataHardeningSection(BuildContext context) {
    final event = widget.event;
    // Only show for Admins (based on presence of onStatusChanged callback)
    if (widget.onStatusChanged == null || event.eventType == EventType.social) return const SizedBox.shrink();

    final config = event.courseConfig;
    final slope = config.slope;
    final rating = config.rating;
    final par = config.par;

    final bool isMissing = (slope ?? 0) <= 0 || (rating ?? 0) <= 0 || (par ?? 0) <= 0;
    if (!isMissing) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, _) {
        final spacing = Theme.of(context).extension<AppSpacingTokens>();
        return Padding(
          padding: EdgeInsets.only(top: spacing?.cardToCard ?? AppSpacing.standard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.coral500.withValues(alpha: AppColors.opacitySubtle),
                  borderRadius: AppShapes.xl,
                  border: Border.all(color: AppColors.coral500.withValues(alpha: AppColors.opacityMedium)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       children: [
                         const Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: AppShapes.iconLg),
                         const SizedBox(width: AppSpacing.md),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text(
                                 'Missing Course Data',
                                 style: TextStyle(fontWeight: AppTypography.weightExtraBold, fontSize: AppTypography.sizeBody, color: AppColors.coral500),
                               ),
                               Text(
                                 'Handicaps cannot be accurately calculated.',
                                 style: TextStyle(fontSize: AppTypography.sizeLabelStrong, color: AppColors.coral500.withValues(alpha: AppColors.opacityHigh)),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: AppSpacing.xl),
                     _buildManualDataFixer(context, ref),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildManualDataFixer(BuildContext context, WidgetRef ref) {
    final event = widget.event;
    final config = event.courseConfig;
    final slopeController = TextEditingController(text: config.slope?.toString() ?? '');
    final ratingController = TextEditingController(text: config.rating?.toString() ?? '');
    final parController = TextEditingController(text: config.par?.toString() ?? '');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniInput(context, 'Slope', slopeController),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMiniInput(context, 'Rating', ratingController),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMiniInput(context, 'Par', parController),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.standard),
        BoxyArtButton(
          title: 'Apply Course Updates',
          isPrimary: true,
          onTap: () async {
             final updatedConfig = event.courseConfig.copyWith(
               slope: (double.tryParse(slopeController.text) ?? 113).toInt(),
               rating: double.tryParse(ratingController.text) ?? 72.0,
               par: (double.tryParse(parController.text) ?? 72).toInt(),
             );

             final updatedEvent = event.copyWith(courseConfig: updatedConfig);
             await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
             
             if (context.mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Course data updated! Scroll to Grouping to Recalculate HCPs.'))
               );
             }
          },
        ),
      ],
    );
  }

  Widget _buildMiniInput(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, letterSpacing: 1.0),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: AppShapes.md,
            border: Border.all(color: AppColors.dark300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBody),
            decoration: const InputDecoration(
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildPlayingCostsSection(BuildContext context) {
    final event = widget.event;
    if (event.memberCost == null && event.guestCost == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Playing Costs'),
        BoxyArtCard(
          child: Column(
            children: [
              if (event.memberCost != null)
                ModernInfoRow(
                  label: 'Member Green Fee',
                  value: '${widget.currencySymbol}${event.memberCost!.toStringAsFixed(2)}',
                  icon: Icons.person_rounded,
                ),
              if (event.memberCost != null && event.guestCost != null)
                const SizedBox(height: AppTheme.cardSpacing),
              if (event.guestCost != null)
                ModernInfoRow(
                  label: 'Guest Green Fee',
                  value: '${widget.currencySymbol}${event.guestCost!.toStringAsFixed(2)}',
                  icon: Icons.person_outline_rounded,
                ),
               if (event.buggyCost != null) ...[
                const SizedBox(height: AppTheme.cardSpacing),
                ModernInfoRow(
                  label: 'Buggy Cost (Indicative)',
                  value: '${widget.currencySymbol}${event.buggyCost!.toStringAsFixed(2)}',
                  icon: Icons.electric_rickshaw_rounded,
                  trailing: const Tooltip(
                    message: 'Paid directly to pro shop',
                    child: Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
               ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealCostsSection(BuildContext context) {
    final config = widget.event;
    final List<Widget> children = [];

    if (config.hasBreakfast && config.breakfastCost != null) {
      children.add(ModernInfoRow(
        label: 'Breakfast',
        value: '${widget.currencySymbol}${config.breakfastCost!.toStringAsFixed(2)}',
        icon: Icons.breakfast_dining_rounded,
      ));
    }
    if (config.hasLunch && config.lunchCost != null) {
      if (children.isNotEmpty) children.add(const SizedBox(height: AppTheme.cardSpacing));
      children.add(ModernInfoRow(
        label: 'Lunch',
        value: '${widget.currencySymbol}${config.lunchCost!.toStringAsFixed(2)}',
        icon: Icons.lunch_dining_rounded,
      ));
    }
    if (config.hasDinner && config.dinnerCost != null) {
      if (children.isNotEmpty) children.add(const SizedBox(height: AppTheme.cardSpacing));
      children.add(ModernInfoRow(
        label: 'Dinner',
        value: '${widget.currencySymbol}${config.dinnerCost!.toStringAsFixed(2)}',
        icon: Icons.dinner_dining_rounded,
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Meal Costs'),
        BoxyArtCard(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection(BuildContext context) {
    if (widget.event.facilities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Facilities'),
        BoxyArtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.event.facilities.asMap().entries.map((entry) {
              final index = entry.key;
              final f = entry.value;
              final isLast = index == widget.event.facilities.length - 1;
              
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.standard),
                child: ModernInfoRow(
                  label: 'Feature',
                  value: f,
                  icon: Icons.check_rounded,
                  showFill: true,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final event = widget.event;
    if (event.notes.isEmpty) return const SizedBox.shrink();
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Additional Notes'),
        ...event.notes.map((note) => BoxyArtCard(
          margin: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title != null) ...[
                Text(note.title!, style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeLargeBody)),
                const SizedBox(height: AppSpacing.md),
              ],
              _buildRichDescription(context, note.content),
            ],
          ),
        )),
      ],
    );
  }



  Widget _buildDinnerLocationSection(BuildContext context) {
    if (widget.event.dinnerLocation == null || widget.event.dinnerLocation!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Dinner Info'),
        BoxyArtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ModernInfoRow(
                      label: 'Location',
                      value: widget.event.dinnerLocation!,
                      icon: Icons.restaurant_rounded,
                    ),
                  ),
                  if (widget.isPreview == false)
                    IconButton(
                      icon: Icon(
                        Icons.map_outlined,
                        color: Theme.of(context).primaryColor,
                        size: AppShapes.iconMd,
                      ),
                      onPressed: () => _launchMap(widget.event.dinnerLocation!, widget.event.dinnerAddress),
                    ),
                ],
              ),
              if (widget.event.dinnerAddress != null && widget.event.dinnerAddress!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 52), // Exact offset of ModernInfoRow text (38 icon + 14 spacing)
                    Expanded(
                      child: Text(
                        widget.event.dinnerAddress!,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: AppTypography.sizeLabelStrong,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAwardsSection(BuildContext context, WidgetRef ref) {
    if (widget.event.eventType == EventType.social || !widget.event.showAwards || widget.event.awards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Event Prizes'),
        BoxyArtCard(
          child: Column(
            children: widget.event.awards.map((award) {
              final isLast = award == widget.event.awards.last;
              IconData icon;
              
              switch (award.type.toLowerCase()) {
                case 'cup':
                  icon = Icons.emoji_events_rounded;
                  break;
                case 'voucher':
                  icon = Icons.confirmation_number_rounded;
                  break;
                default:
                  icon = Icons.payments_rounded;
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        BoxyArtIconBadge(
                          icon: icon,
                          color: Color(ref.watch(themeControllerProvider).iconBadgeFillColor),
                          iconColor: Color(ref.watch(themeControllerProvider).iconBadgeIconColor),
                          fillOpacity: ref.watch(themeControllerProvider).iconBadgeOpacity,
                          size: 38,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                award.label,
                                style: const TextStyle(
                                  fontSize: AppTypography.sizeBody,
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                              if (award.type.toLowerCase() != 'cup' && award.value > 0)
                                Text(
                                  'Value: ${ref.watch(themeControllerProvider).currencySymbol}${award.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: AppTypography.sizeLabel,
                                    fontWeight: AppTypography.weightBold,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                                    letterSpacing: 0.5,
                                  ),
                                )
                              else
                                Text(
                                  toTitleCase(award.type),
                                  style: TextStyle(
                                    fontSize: AppTypography.sizeLabel,
                                    fontWeight: AppTypography.weightBold,
                                    letterSpacing: 0.5,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

}


String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
