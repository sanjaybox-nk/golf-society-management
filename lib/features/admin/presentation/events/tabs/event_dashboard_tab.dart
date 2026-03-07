import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

class EventDashboardTab extends ConsumerWidget {
  const EventDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societyConfig = ref.watch(themeControllerProvider);
    final currency = societyConfig.currencySymbol;

    return Container(
      color: const Color(0xFFF5F5F7), // Main page background
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header Section (White background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.x3l, AppSpacing.xl, AppSpacing.x3l),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppShapes.rPill),
                  bottomRight: Radius.circular(AppShapes.rPill),
                ),
                boxShadow: AppShadows.softScale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Welcome Back, Admin',
                    style: TextStyle(
                      fontSize: AppTypography.sizeDisplaySmall,
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: -0.5,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  // Next Upcoming Event Wide Card
                  _buildUpcomingEventCard(context),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.x2l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Vital Signs Section
                  const Text(
                    'Vital Signs',
                    style: TextStyle(
                      fontSize: AppTypography.sizeLargeBody,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Vital Signs Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      const _VitalSignCard(
                        label: 'Slots Filled',
                        value: '24/32',
                        icon: Icons.how_to_reg,
                        iconColor: AppColors.teamA,
                      ),
                      _VitalSignCard(
                        label: 'Fees Collected',
                        value: '${currency}480',
                        icon: Icons.payments,
                        iconColor: AppColors.lime500,
                        subtitle: '${currency}120 Outstanding',
                        subtitleColor: AppColors.coral500,
                      ),
                      const _VitalSignCard(
                        label: 'Draw Not Published',
                        value: 'Pending',
                        icon: Icons.sports_score,
                        iconColor: AppColors.amber500,
                      ),
                      const _VitalSignCard(
                        label: 'New Guests',
                        value: '+3',
                        icon: Icons.group_add,
                        iconColor: AppColors.teamB,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.x3l),

                  // 3. Quick Actions Section (RESTORED)
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: AppTypography.sizeLargeBody,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        BoxyArtButton(
                          title: 'Create New Event',
                          isSecondary: true,
                          icon: Icons.add,
                          onTap: () {},
                        ),
                        const SizedBox(width: AppSpacing.md),
                        BoxyArtButton(
                          title: 'Publish Draw',
                          isSecondary: true,
                          icon: Icons.assignment_outlined,
                          onTap: () {},
                        ),
                        const SizedBox(width: AppSpacing.md),
                        BoxyArtButton(
                          title: 'Close Event',
                          isSecondary: true,
                          icon: Icons.lock_outline,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.x3l),

                  // 4. Action Required Section
                  const Text(
                    'Action Required',
                    style: TextStyle(
                      fontSize: AppTypography.sizeLargeBody,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  _buildActionItem(
                    title: 'Approve 2 Guest Requests',
                    subtitle: 'From Monthly Medal registration',
                    icon: Icons.person_add_sharp,
                    color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
                    iconColor: AppColors.amber500,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildActionItem(
                    title: 'Publish Draw for Saturday',
                    subtitle: 'Deadline approaching (6h remaining)',
                    icon: Icons.notification_important_outlined,
                    color: Theme.of(context).colorScheme.error.withValues(alpha: AppColors.opacityLow),
                    iconColor: Theme.of(context).colorScheme.error,
                  ),
                  
                  const SizedBox(height: AppSpacing.x4l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context) {
    return BoxyArtCard(
      child: Row(
        children: [
          // Date Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityLow),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'OCT',
                  style: TextStyle(
                    fontSize: AppTypography.sizeLabel,
                    fontWeight: AppTypography.weightBold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  '24',
                  style: TextStyle(
                    fontSize: AppTypography.sizeDisplaySubPage,
                    fontWeight: AppTypography.weightBold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          
          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Medal',
                  style: TextStyle(
                    fontSize: AppTypography.sizeLargeBody,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
                Text(
                  'Augusta National',
                  style: TextStyle(
                    fontSize: AppTypography.sizeBodySmall,
                    color: AppColors.dark600,
                  ),
                ),
              ],
            ),
          ),
          
          // Manage Button
          Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.26)),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppShapes.lg,
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBodySmall),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.dark700),
        ),
        trailing: const Icon(Icons.chevron_right, size: AppShapes.iconMd),
      ),
    );
  }
}

class _VitalSignCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final Color? subtitleColor;

  const _VitalSignCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppShapes.sheet, // Boxy Art style
        boxShadow: AppShadows.inputSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: AppColors.opacityLow),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTypography.sizeDisplaySubPage,
              fontWeight: AppTypography.weightBold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.dark600,
              fontWeight: AppTypography.weightMedium,
              fontSize: AppTypography.sizeLabelStrong,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: TextStyle(
                color: subtitleColor ?? AppColors.dark600,
                fontSize: AppTypography.sizeCaptionStrong,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
