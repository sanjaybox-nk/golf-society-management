import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../domain/registration_logic.dart';

class RegistrationStatsCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isCompact;

  const RegistrationStatsCard({
    super.key,
    required this.event,
    this.isCompact = false,
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
      return _buildCompactVersion(context, stats, isDark, playingValue, reserveValue);
    }

    return _buildFullVersion(context, stats, isDark, playingValue, reserveValue, currency);
  }

  Widget _buildCompactVersion(
    BuildContext context, 
    RegistrationStats stats, 
    bool isDark,
    String playingValue,
    String reserveValue,
  ) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
                    color: isDark ? AppColors.dark150 : AppColors.dark500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: playingValue,
                    label: 'Playing',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.lime500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: reserveValue,
                    label: 'Reserve',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.amber500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}',
                    label: 'Guests',
                    icon: Icons.person_add_rounded,
                    color: const Color(0xFF8E44AD),
                    isCompact: true,
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
                    value: '${stats.buggyCount}',
                    label: 'Buggies',
                    icon: Icons.electric_rickshaw_rounded,
                    color: isDark ? AppColors.dark300 : AppColors.dark600,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.waitlistGolfers}',
                    label: 'Waitlist',
                    icon: Icons.priority_high_rounded,
                    color: AppColors.coral500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.withdrawnCount}',
                    label: 'Withdraw',
                    icon: Icons.person_remove_rounded,
                    color: AppColors.dark400,
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
  ) {
    // Financials calculation (Move logic inside widget or helper)
    final double totalPaidFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) {
          double golfCost = 0.0;
          if (r.isConfirmed && r.attendingGolf) golfCost += event.memberCost ?? 0.0;
          if (r.guestIsConfirmed && r.guestName != null && r.guestName!.isNotEmpty) golfCost += event.guestCost ?? 0.0;
          return sum + golfCost;
        });

    final double totalDinnerFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) => sum +
            (r.attendingDinner && r.isConfirmed ? (event.dinnerCost ?? 0.0) : 0.0) +
            (r.guestAttendingDinner && r.guestIsConfirmed ? (event.dinnerCost ?? 0.0) : 0.0));

    final double totalBreakfastFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) => sum +
            (r.attendingBreakfast && r.isConfirmed ? (event.breakfastCost ?? 0.0) : 0.0) +
            (r.guestAttendingBreakfast && r.guestIsConfirmed ? (event.breakfastCost ?? 0.0) : 0.0));

    final double totalLunchFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) => sum +
            (r.attendingLunch && r.isConfirmed ? (event.lunchCost ?? 0.0) : 0.0) +
            (r.guestAttendingLunch && r.guestIsConfirmed ? (event.lunchCost ?? 0.0) : 0.0));

    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;
    final capacity = event.maxParticipants ?? 0;
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
                    color: isDark ? AppColors.dark150 : AppColors.dark500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: playingValue,
                    label: 'Playing',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.lime500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: reserveValue,
                    label: 'Reserve',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.amber500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}',
                    label: 'Guests',
                    icon: Icons.person_add_rounded,
                    color: const Color(0xFF8E44AD),
                    isCompact: true,
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
                    value: '${stats.buggyCount}/$buggyCapacity',
                    label: 'Buggies',
                    icon: Icons.electric_rickshaw_rounded,
                    color: isDark ? AppColors.dark300 : AppColors.dark600,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.breakfastCount}',
                    label: 'Breakfast',
                    icon: Icons.breakfast_dining_rounded,
                    color: const Color(0xFF8D6E63),
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.lunchCount}',
                    label: 'Lunch',
                    icon: Icons.lunch_dining_rounded,
                    color: AppColors.amber500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.dinnerCount}',
                    label: 'Dinner',
                    icon: Icons.restaurant_rounded,
                    color: const Color(0xFF673AB7),
                    isCompact: true,
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
                    color: AppColors.coral500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '${stats.withdrawnCount}',
                    label: 'Withdrawn',
                    icon: Icons.person_remove_rounded,
                    color: AppColors.dark400,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: SizedBox.shrink()),
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ModernMetricStat(
                    value: '$currency${totalPaidFees.toStringAsFixed(0)}',
                    label: 'Paid',
                    icon: Icons.payments_rounded,
                    color: AppColors.lime500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '$currency${totalBreakfastFees.toStringAsFixed(0)}',
                    label: 'Breakfast',
                    icon: Icons.breakfast_dining_rounded,
                    color: const Color(0xFF8D6E63),
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '$currency${totalLunchFees.toStringAsFixed(0)}',
                    label: 'Lunch',
                    icon: Icons.lunch_dining_rounded,
                    color: AppColors.amber500,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ModernMetricStat(
                    value: '$currency${totalDinnerFees.toStringAsFixed(0)}',
                    label: 'Dinner',
                    icon: Icons.restaurant_menu_rounded,
                    color: isDark ? AppColors.dark200 : AppColors.dark600,
                    isCompact: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    '${stats.confirmedGolfers}/$capacity spaces',
                    style: TextStyle(
                      fontSize: AppTypography.sizeBody,
                      fontWeight: AppTypography.weightSemibold,
                      color: isDark ? AppColors.dark150 : const Color(0xFF2C3E50),
                    ),
                  ),
                  BoxyArtPill.status(
                    label: isClosed ? 'Registration Closed' : 'Registration Open',
                    color: isClosed 
                        ? (isDark ? AppColors.dark150 : AppColors.dark400)
                        : AppColors.lime500,
                    icon: isClosed ? Icons.lock_outline_rounded : Icons.timer_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
