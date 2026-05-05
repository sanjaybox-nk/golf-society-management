import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';

/// Renders a JSON-Delta or plain-text string as a read-only Quill editor.
Widget buildRichDescription(BuildContext context, String content) {
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

// ── Hero ─────────────────────────────────────────────────────────────────────

class EventHeroSection extends StatelessWidget {
  const EventHeroSection({super.key, required this.event});
  final GolfEvent event;

  @override
  Widget build(BuildContext context) {
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppShapes.xl,
              child: Image.network(
                event.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            if (event.description != null && event.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: buildRichDescription(context, event.description!),
              ),
          ],
        ),
      );
    } else if (event.description != null && event.description!.isNotEmpty) {
      return BoxyArtCard(child: buildRichDescription(context, event.description!));
    }
    return const SizedBox.shrink();
  }
}

// ── Date & Time ───────────────────────────────────────────────────────────────

class EventDateTimeSection extends StatelessWidget {
  const EventDateTimeSection({super.key, required this.event});
  final GolfEvent event;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final gap = SizedBox(height: spacing?.cardToCard ?? AppSpacing.atomic);

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      gradient: AppGradients.brandPrimary(context),
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
            gap,
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
            gap,
            ModernInfoRow(
              label: 'END DATE',
              value: DateFormat('EEEE, d MMM yyyy').format(event.endDate!),
              icon: Icons.calendar_today_rounded,
              labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
              valueColor: AppColors.pureWhite,
              iconColor: AppColors.pureWhite,
            ),
          ],
          gap,
          ModernInfoRow(
            label: event.eventType == EventType.social ? 'EVENT TIME' : 'REGISTRATION',
            value: event.regTime != null ? DateFormat.Hm().format(event.regTime!) : 'TBA',
            icon: Icons.app_registration_rounded,
            labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
            valueColor: AppColors.pureWhite,
            iconColor: AppColors.pureWhite,
          ),
          gap,
          if (event.eventType == EventType.golf) ...[
            ModernInfoRow(
              label: 'TEE-OFF',
              value: DateFormat.Hm().format(event.teeOffTime ?? event.date),
              icon: Icons.schedule_rounded,
              labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
              valueColor: AppColors.pureWhite,
              iconColor: AppColors.pureWhite,
            ),
            gap,
          ],
          if (event.registrationDeadline != null)
            ModernInfoRow(
              label: 'REGISTRATION CLOSES',
              value: '${DateFormat('d MMM').format(event.registrationDeadline!)} @ ${DateFormat.Hm().format(event.registrationDeadline!)}',
              icon: Icons.timer_outlined,
              iconColor: AppColors.pureWhite,
              labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
              valueColor: AppColors.pureWhite,
            ),
        ],
      ),
    );
  }

  Future<void> _launchMap(String courseName, String? details) async {
    final query = details != null && details.isNotEmpty ? '$courseName, $details' : courseName;
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(Platform.isIOS
        ? 'https://maps.apple.com/?q=$encodedQuery'
        : 'https://www.google.com/maps/search/?api=1&query=$encodedQuery');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(
          Uri.parse('https://www.google.com/search?q=$encodedQuery'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {}
  }
}

// ── Meal Details ──────────────────────────────────────────────────────────────

class EventMealDetailsSection extends StatelessWidget {
  const EventMealDetailsSection({super.key, required this.event, required this.currencySymbol});
  final GolfEvent event;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final hasMealInfo = event.hasBreakfast || event.hasLunch || event.hasDinner || event.dinnerLocation != null;
    if (!hasMealInfo && event.eventType != EventType.social) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtSectionTitle(title: event.eventType == EventType.social ? 'Event Details' : 'Meal Details'),
        BoxyArtCard(
          child: Column(
            children: [
              if (event.eventType == EventType.golf) ...[
                if (event.hasBreakfast) _mealRow('Breakfast', event.breakfastCost, Icons.flatware_rounded),
                if (event.hasLunch) ...[
                  if (event.hasBreakfast) SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                  _mealRow('Lunch', event.lunchCost, Icons.restaurant_rounded),
                ],
                if (event.hasDinner) ...[
                  if (event.hasBreakfast || event.hasLunch) SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                  _mealRow('Dinner', event.dinnerCost, Icons.dinner_dining_rounded),
                ],
              ],
              if (event.dinnerLocation != null || event.eventType == EventType.social) ...[
                if (event.eventType == EventType.golf && (event.hasBreakfast || event.hasLunch || event.hasDinner))
                  SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                ModernInfoRow(
                  label: event.eventType == EventType.social ? 'Event Location' : 'Dinner Location',
                  value: event.dinnerLocation ?? 'TBC',
                  icon: Icons.location_on_rounded,
                ),
                if (event.dinnerAddress != null) ...[
                  const SizedBox(height: AppTheme.cardSpacing),
                  ModernInfoRow(
                    label: event.eventType == EventType.social ? 'Event Address' : 'Dinner Address',
                    value: event.dinnerAddress!,
                    icon: Icons.map_rounded,
                    maxLines: 10,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _mealRow(String label, double? cost, IconData icon) => ModernInfoRow(
        label: label,
        value: cost != null ? '$currencySymbol${cost.toStringAsFixed(2)}' : 'TBC',
        icon: icon,
      );
}

// ── Course Selection ──────────────────────────────────────────────────────────

class EventCourseSelectionSection extends StatelessWidget {
  const EventCourseSelectionSection({super.key, required this.event});
  final GolfEvent event;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Course'),
        BoxyArtCard(
          child: Column(
            children: [
              if (event.courseDetails != null && event.courseDetails!.isNotEmpty)
                ModernInfoRow(
                  label: 'Course Details',
                  value: event.courseDetails!,
                  icon: Icons.info_outline_rounded,
                ),
              if (event.eventType == EventType.golf &&
                  (event.selectedTeeName != null || event.selectedFemaleTeeName != null)) ...[
                SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                Builder(builder: (context) {
                  final male = event.selectedTeeName;
                  final female = event.selectedFemaleTeeName;
                  final value = (male != null && female != null)
                      ? (male == female ? male : '$male / $female')
                      : male ?? female ?? 'TBA';
                  return ModernInfoRow(label: 'Tee Position', value: value, icon: Icons.flag_rounded);
                }),
              ],
              if (event.maxParticipants != null) ...[
                const SizedBox(height: AppSpacing.standard),
                Builder(builder: (context) {
                  final stats = RegistrationLogic.getRegistrationStats(event);
                  final available = (event.maxParticipants! - stats.confirmedGolfers).clamp(0, event.maxParticipants!);
                  return ModernInfoRow(
                    label: 'Field Capacity',
                    value: '$available / ${event.maxParticipants} slots available',
                    icon: Icons.groups_rounded,
                  );
                }),
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
}

// ── Playing Costs ─────────────────────────────────────────────────────────────

class EventPlayingCostsSection extends StatelessWidget {
  const EventPlayingCostsSection({super.key, required this.event, required this.currencySymbol});
  final GolfEvent event;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final hasCosts = event.memberCost != null || event.guestCost != null || event.extraCosts.isNotEmpty;
    if (!hasCosts) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtSectionTitle(title: event.eventType == EventType.social ? 'Event Costs' : 'Playing Costs'),
        BoxyArtCard(
          child: Column(
            children: [
              if (event.memberCost != null)
                ModernInfoRow(
                  label: event.eventType == EventType.social ? 'Member Event Cost' : 'Member Green Fee',
                  value: '$currencySymbol${event.memberCost!.toStringAsFixed(2)}',
                  icon: Icons.person_rounded,
                ),
              if (event.memberCost != null && event.guestCost != null)
                const SizedBox(height: AppTheme.cardSpacing),
              if (event.guestCost != null)
                ModernInfoRow(
                  label: event.eventType == EventType.social ? 'Guest Event Cost' : 'Guest Green Fee',
                  value: '$currencySymbol${event.guestCost!.toStringAsFixed(2)}',
                  icon: Icons.person_outline_rounded,
                ),
              if (event.buggyCost != null && event.eventType == EventType.golf) ...[
                const SizedBox(height: AppTheme.cardSpacing),
                ModernInfoRow(
                  label: 'Buggy Cost (Indicative)',
                  value: '$currencySymbol${event.buggyCost!.toStringAsFixed(2)}',
                  icon: Icons.electric_rickshaw_rounded,
                  trailing: const Tooltip(
                    message: 'Paid directly to pro shop',
                    child: Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
              ...event.extraCosts.map((extra) => Column(
                    children: [
                      const SizedBox(height: AppTheme.cardSpacing),
                      ModernInfoRow(
                        label: extra.label,
                        value: '$currencySymbol${extra.amount.toStringAsFixed(2)}',
                        icon: Icons.add_circle_outline_rounded,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Facilities ────────────────────────────────────────────────────────────────

class EventFacilitiesSection extends StatelessWidget {
  const EventFacilitiesSection({super.key, required this.event});
  final GolfEvent event;

  @override
  Widget build(BuildContext context) {
    if (event.facilities.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Facilities'),
        BoxyArtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: event.facilities.asMap().entries.map((entry) {
              final isLast = entry.key == event.facilities.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.standard),
                child: ModernInfoRow(
                  label: 'Feature',
                  value: entry.value,
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
}

// ── Notes ─────────────────────────────────────────────────────────────────────

class EventNotesSection extends StatelessWidget {
  const EventNotesSection({super.key, required this.event});
  final GolfEvent event;

  @override
  Widget build(BuildContext context) {
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
                    Text(note.title!, style: AppTypography.label),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  buildRichDescription(context, note.content),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Awards ────────────────────────────────────────────────────────────────────

class EventAwardsSection extends StatelessWidget {
  const EventAwardsSection({super.key, required this.event, required this.currencySymbol});
  final GolfEvent event;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (event.eventType == EventType.social || !event.showAwards || event.awards.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Event Prizes'),
        BoxyArtCard(
          child: Column(
            children: event.awards.map((award) {
              final icon = switch (award.type.toLowerCase()) {
                'cup'     => Icons.emoji_events_rounded,
                'voucher' => Icons.confirmation_number_rounded,
                _         => Icons.payments_rounded,
              };
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: ModernInfoRow(
                  label: award.label,
                  value: (award.type.toLowerCase() != 'cup' && award.value > 0)
                      ? '$currencySymbol${award.value.toStringAsFixed(2)}'
                      : award.type,
                  icon: icon,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
