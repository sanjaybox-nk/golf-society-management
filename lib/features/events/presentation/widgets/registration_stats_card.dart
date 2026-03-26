import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';
import '../../domain/registration_logic.dart';

class RegistrationStatsCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isCompact;
  final bool showAdminMetrics;

  const RegistrationStatsCard({
    super.key,
    required this.event,
    this.isCompact = false,
    this.showAdminMetrics = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = RegistrationLogic.getRegistrationStats(event);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    final currency = config.currencySymbol;

    final playingValue = stats.confirmedGuests > 0 
        ? '${stats.confirmedGolfers} (${stats.confirmedGuests})' 
        : '${stats.confirmedGolfers}';
    final reserveValue = stats.reserveGuests > 0 
        ? '${stats.reserveGolfers} (${stats.reserveGuests})' 
        : '${stats.reserveGolfers}';

    if (isCompact) {
      return _buildCompactVersion(context, stats, isDark, playingValue, reserveValue, config);
    }

    return _buildFullVersion(context, stats, isDark, playingValue, reserveValue, currency, config);
  }

  Widget _buildCompactVersion(
    BuildContext context, 
    RegistrationStats stats, 
    bool isDark,
    String playingValue,
    String reserveValue,
    SocietyConfig config,
  ) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

    return BoxyArtCard(
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ModernMetricStat(
                    value: '${event.maxParticipants ?? 0}',
                    label: 'Capacity',
                    icon: Icons.groups_rounded,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: playingValue,
                    label: 'Playing',
                    icon: Icons.check_circle_rounded,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: reserveValue,
                    label: 'Reserve',
                    icon: Icons.hourglass_top_rounded,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}',
                    label: 'Guests',
                    icon: Icons.person_add_rounded,
                    isCompact: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.buggyCount}',
                    label: 'Buggies',
                    icon: Icons.electric_rickshaw_rounded,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.waitlistGolfers}',
                    label: 'Waitlist',
                    icon: Icons.priority_high_rounded,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.withdrawnCount}',
                    label: 'Withdraw',
                    icon: Icons.person_remove_rounded,
                    isCompact: true,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullVersion(
    BuildContext context, 
    RegistrationStats stats, 
    bool isDark,
    String playingValue,
    String reserveValue,
    String currency,
    SocietyConfig config,
  ) {
    // Financials calculation (Move logic inside widget or helper)
    final double totalPaidFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) {
          double golfCost = 0.0;
          if (r.isConfirmed && r.attendingGolf) golfCost += event.memberCost ?? 0.0;
          if (r.guestIsConfirmed && r.guestName != null && r.guestName!.isNotEmpty) golfCost += event.guestCost ?? 0.0;
          return sum + golfCost;
        });

    final double totalDinnerFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) => sum +
            (r.attendingDinner == true && r.isConfirmed == true ? (event.dinnerCost ?? 0.0) : 0.0) +
            (r.guestAttendingDinner == true && r.guestIsConfirmed == true ? (event.dinnerCost ?? 0.0) : 0.0));

    final double totalBreakfastFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) => sum +
            (r.attendingBreakfast == true && r.isConfirmed == true ? (event.breakfastCost ?? 0.0) : 0.0) +
            (r.guestAttendingBreakfast == true && r.guestIsConfirmed == true ? (event.breakfastCost ?? 0.0) : 0.0));

    final double totalLunchFees = event.registrations
        .where((r) => r.hasPaid == true)
        .fold(0.0, (sum, r) => sum +
            (r.attendingLunch == true && r.isConfirmed == true ? (event.lunchCost ?? 0.0) : 0.0) +
            (r.guestAttendingLunch == true && r.guestIsConfirmed == true ? (event.lunchCost ?? 0.0) : 0.0));

    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final double vPadding = spacing?.cardVerticalPadding ?? AppSpacing.lg;
    final double hPadding = spacing?.cardHorizontalPadding ?? AppSpacing.xl;

    return BoxyArtCard(
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ModernMetricStat(
                    value: '${event.maxParticipants ?? 0}',
                    label: 'Capacity',
                    icon: Icons.groups_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: playingValue,
                    label: 'Playing',
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: reserveValue,
                    label: 'Reserve',
                    icon: Icons.hourglass_top_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}',
                    label: 'Guests',
                    icon: Icons.person_add_rounded,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.buggyCount}/$buggyCapacity',
                    label: 'Buggies',
                    icon: Icons.electric_rickshaw_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.breakfastCount}',
                    label: 'Breakfast',
                    icon: Icons.breakfast_dining_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.lunchCount}',
                    label: 'Lunch',
                    icon: Icons.lunch_dining_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.dinnerCount}',
                    label: 'Dinner',
                    icon: Icons.restaurant_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.waitlistGolfers}',
                    label: 'Waitlist',
                    icon: Icons.priority_high_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.withdrawnCount}',
                    label: 'Withdrawn',
                    icon: Icons.person_remove_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: SizedBox.shrink()),
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          if (showAdminMetrics) ...[
            SizedBox(height: (spacing?.cardToCard ?? AppSpacing.xl) * 1.5),
            const Divider(),
            SizedBox(height: (spacing?.cardToCard ?? AppSpacing.xl) * 1.5),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ModernMetricStat(
                      value: '$currency${totalPaidFees.toStringAsFixed(0)}',
                      label: 'Paid',
                      icon: Icons.payments_rounded,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: '$currency${totalBreakfastFees.toStringAsFixed(0)}',
                      label: 'Breakfast',
                      icon: Icons.breakfast_dining_rounded,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: '$currency${totalLunchFees.toStringAsFixed(0)}',
                      label: 'Lunch',
                      icon: Icons.lunch_dining_rounded,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: '$currency${totalDinnerFees.toStringAsFixed(0)}',
                      label: 'Dinner',
                      icon: Icons.restaurant_menu_rounded,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            const Divider(),
          ],
        ],
      ),
    );
  }
}
