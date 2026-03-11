import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/competitions/presentation/widgets/competition_shared_widgets.dart';
import 'events_provider.dart';

import 'package:go_router/go_router.dart';


class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider); // Or a specific provider for one event
    
    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        return _EventDetailsContent(
          event: event, 
          currencySymbol: ref.watch(themeControllerProvider).currencySymbol,
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _EventDetailsContent extends StatelessWidget {
  final GolfEvent event;
  final String currencySymbol;

  const _EventDetailsContent({required this.event, required this.currencySymbol});
  
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return HeadlessScaffold(
      title: event.title,
      showBack: true,
      onBack: () => context.go('/events'),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (event.status == EventStatus.cancelled)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.x2l),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.coral500.withValues(alpha: AppColors.opacityLow),
                    borderRadius: AppShapes.lg,
                    border: Border.all(color: AppColors.coral500.withValues(alpha: AppColors.opacityMedium)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: AppColors.coral500),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EVENT CANCELLED',
                              style: TextStyle(color: AppColors.coral500, fontWeight: AppTypography.weightBlack, letterSpacing: 1.2),
                            ),
                            Text(
                              'This event has been cancelled by the administrative team.',
                              style: TextStyle(color: AppColors.coral500.withValues(alpha: AppColors.opacityHigh), fontSize: AppTypography.sizeLabelStrong),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              _buildStatusBadge(context),
              const SizedBox(height: AppSpacing.x2l),
              
              // Event Hero Image
              if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                BoxyArtCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: AppShapes.xl,
                    child: Image.network(
                      event.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                BoxyArtCard(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Icon(Icons.golf_course, size: AppShapes.iconMassive, color: primary.withValues(alpha: AppColors.opacityMedium)),
                  ),
                ),
              SizedBox(height: AppTheme.cardSpacing),

              // Registration Card
              _buildRegistrationCard(context),
              SizedBox(height: AppTheme.cardSpacing),

              // When & Where Card
              _buildWhenWhereCard(context),
              SizedBox(height: AppTheme.cardSpacing),

              // Course Details Card
              _buildCourseDetailsCard(context),
              SizedBox(height: AppTheme.cardSpacing),

              // Competition Rules Card
              _buildCompetitionCard(context),
              SizedBox(height: AppTheme.cardSpacing),

              // Costs Card
              _buildCostsCard(context),
              
              // Dinner Location Card
              if (event.dinnerLocation != null && event.dinnerLocation!.isNotEmpty) ...[
                SizedBox(height: AppTheme.cardSpacing),
                _buildDinnerLocationCard(context),
              ],

              // Notes Section
              if (event.notes.isNotEmpty) ...[
                SizedBox(height: AppTheme.cardSpacing),
                const BoxyArtSectionTitle(title: 'Notes & Content'),
                ...event.notes.map((note) => _buildNoteCard(context, note)),
              ],

              // Updates Section
              if (event.flashUpdates.isNotEmpty) ...[
                SizedBox(height: AppTheme.cardSpacing),
                const BoxyArtSectionTitle(title: 'Updates'),
                ...event.flashUpdates.map((update) => _buildUpdateCard(context, update)),
              ],

              // Gallery Section
              if (event.galleryUrls.isNotEmpty) ...[
                SizedBox(height: AppTheme.cardSpacing),
                const BoxyArtSectionTitle(title: 'Gallery'),
                _buildGalleryCard(context),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final displayStatus = event.displayStatus;
    
    String statusText;
    Color statusColor;
    
    switch (displayStatus) {
      case EventStatus.draft:
        statusText = 'Draft';
        statusColor = AppColors.amber500;
        break;
      case EventStatus.published:
        statusText = 'Published';
        statusColor = Theme.of(context).colorScheme.secondary;
        break;
      case EventStatus.inPlay:
        statusText = 'Live';
        statusColor = AppColors.teamA;
        break;
      case EventStatus.suspended:
        statusText = 'Suspended';
        statusColor = Colors.deepOrange;
        break;
      case EventStatus.completed:
        statusText = 'Completed';
        statusColor = AppColors.textSecondary;
        break;
      case EventStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = AppColors.coral500;
        break;
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        BoxyArtPill.status(
          label: statusText,
          color: statusColor,
        ),
        if (event.isInvitational)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 12, color: AppColors.amber500),
              const SizedBox(width: 4),
              Text(
                'Invitational event',
                style: AppTypography.caption.copyWith(
                  color: AppColors.amber500,
                  fontWeight: AppTypography.weightBlack,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        if (event.eventType == EventType.social)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_rounded, size: 12, color: AppColors.coral500),
              const SizedBox(width: 4),
              Text(
                'Social event',
                style: AppTypography.caption.copyWith(
                  color: AppColors.coral500,
                  fontWeight: AppTypography.weightBlack,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildRegistrationCard(BuildContext context) {
    const currentMemberId = 'current-user-id';
    final myRegistration = event.registrations.where((r) => r.memberId == currentMemberId).firstOrNull;
    final isRegistered = myRegistration != null;
    final primary = Theme.of(context).primaryColor;
    
    final isPastDeadline = event.registrationDeadline != null && 
                          DateTime.now().isAfter(event.registrationDeadline!);
    final isRegistrationDisabled = isPastDeadline || !event.showRegistrationButton;

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.x4l,
                height: AppSpacing.x4l,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.md,
                ),
                child: Icon(Icons.groups_rounded, color: primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Registration',
                style: TextStyle(fontSize: AppTypography.sizeLargeBody, fontWeight: AppTypography.weightBold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: ModernMetricStat(
                  value: '${event.playingCount}/${event.capacity ?? 32}',
                  label: 'Playing',
                  color: Theme.of(context).colorScheme.secondary,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ModernMetricStat(
                  value: '${event.guestCount}',
                  label: 'Guests',
                  color: AppColors.teamB,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ModernMetricStat(
                  value: '${event.waitlistCount}',
                  label: 'Reserve',
                  color: const Color(0xFFF39C12),
                  isCompact: true,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.x3l),
          if (isRegistered) ...[
            const BoxyArtSectionTitle(title: 'Your Status'),
            Row(
              children: [
                Expanded(child: _buildSummaryIcon(Icons.golf_course, 'Golf', myRegistration.attendingGolf)),
                Expanded(child: _buildSummaryIcon(Icons.electric_rickshaw, 'Buggy', myRegistration.needsBuggy)),
                Expanded(child: _buildSummaryIcon(Icons.free_breakfast_rounded, 'Breakfast', myRegistration.attendingBreakfast)),
                Expanded(child: _buildSummaryIcon(Icons.restaurant, 'Dinner', myRegistration.attendingDinner)),
              ],
            ),
            const SizedBox(height: AppSpacing.x2l),
          ] else if (event.registrationDeadline != null) ...[
            ModernRuleItem(
              label: 'Deadline',
              value: '${DateFormat.yMMMd().format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          BoxyArtButton(
            title: isPastDeadline 
                ? 'Registration closed' 
                : (isRegistered ? 'Update Registration' : 'Register Now'),
            onTap: isRegistrationDisabled 
                ? null 
                : () => context.push('/events/${Uri.encodeComponent(event.id)}/register'),
          ),
        ],
      ),
    );
  }

  Widget _buildWhenWhereCard(BuildContext context) {
    return BoxyArtCard(
      child: Column(
        children: [
          ModernInfoRow(
            label: 'When',
            value: DateFormat('EEEE, d MMM y').format(event.date),
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          ModernInfoRow(
            label: 'Tee Times',
            value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
            icon: Icons.schedule_rounded,
          ),
          const Divider(height: AppSpacing.x3l),
          ModernInfoRow(
            label: 'Course',
            value: event.courseName ?? 'TBA',
            icon: Icons.location_on_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDetailsCard(BuildContext context) {
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Course Info'),
          ModernRuleItem(label: 'Dress Code', value: event.dressCode ?? 'Standard Golf Attire'),
          if (event.availableBuggies != null)
            ModernRuleItem(label: 'Buggies', value: '${event.availableBuggies} available'),
          if (event.facilities.isNotEmpty)
            ModernRuleItem(label: 'Facilities', value: event.facilities.join(', ')),
        ],
      ),
    );
  }

  Widget _buildCompetitionCard(BuildContext context) {
    return CompetitionRulesCard(
      eventId: event.id,
      title: 'Competition',
    );
  }

  Widget _buildCostsCard(BuildContext context) {
    final bool hasBreakfast = event.hasBreakfast && event.breakfastCost != null;
    final bool hasLunch = event.hasLunch && event.lunchCost != null;
    final bool hasDinner = event.hasDinner && event.dinnerCost != null;

    final double memberSubtotal = (event.memberCost ?? 0) +
        (hasBreakfast ? (event.breakfastCost ?? 0) : 0) +
        (hasLunch ? (event.lunchCost ?? 0) : 0) +
        (hasDinner ? (event.dinnerCost ?? 0) : 0);

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Costs'),
          ModernCostRow(label: 'Member Golf', amount: _formatCost(event.memberCost)),
          if (hasBreakfast) ModernCostRow(label: 'Breakfast', amount: _formatCost(event.breakfastCost)),
          if (hasLunch) ModernCostRow(label: 'Lunch', amount: _formatCost(event.lunchCost)),
          if (hasDinner) ModernCostRow(label: 'Dinner', amount: _formatCost(event.dinnerCost)),
          const Divider(height: AppSpacing.x2l),
          ModernCostRow(label: 'Member Total', amount: _formatCost(memberSubtotal), isTotal: true),

          const SizedBox(height: AppSpacing.md),
          ModernCostRow(label: 'Guest Golf', amount: _formatCost(event.guestCost), color: AppColors.teamB),
          
          if (event.buggyCost != null) ...[
            const SizedBox(height: AppSpacing.md),
            ModernRuleItem(label: 'Buggy (Optional)', value: _formatCost(event.buggyCost)),
            const Text(
              'Shared cost per buggy',
              style: TextStyle(fontSize: AppTypography.sizeCaption, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCost(double? cost) {
    if (cost == null) return 'TBA';
    if (cost == 0) return 'Free';
    return '$currencySymbol${cost.toStringAsFixed(2)}';
  }

  Widget _buildDinnerLocationCard(BuildContext context) {
    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernInfoRow(
            label: 'Dinner Venue',
            value: event.dinnerLocation!,
            icon: Icons.restaurant_rounded,
          ),
          if (event.dinnerAddress != null && event.dinnerAddress!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 52), // Match offset of ModernInfoRow
                Expanded(
                  child: Text(
                    event.dinnerAddress!,
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
    );
  }

  Widget _buildUpdateCard(BuildContext context, String update) {
    return BoxyArtCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: AppColors.amber500, size: AppShapes.iconLg),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              update,
              style: const TextStyle(fontWeight: AppTypography.weightMedium, fontSize: AppTypography.sizeLabelStrong),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: event.galleryUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ClipRRect(
              borderRadius: AppShapes.lg,
              child: Image.network(
                event.galleryUrls[index],
                width: AppShapes.borderThin,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, EventNote note) {
    return ModernNoteCard(
      title: note.title,
      content: note.content,
      imageUrl: note.imageUrl,
    );
  }

  Widget _buildSummaryIcon(IconData icon, String label, bool active) {
    return ModernSummaryIcon(
      icon: icon,
      label: label,
      active: active,
    );
  }
}
