
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'controllers/reports_controller.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HeadlessScaffold(
      title: 'Society Reports',
      subtitle: 'Analytics and Data Export',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(
                title: 'Available Reports',
                isPeeking: true,
              ),
              _ReportCard(
                title: 'Financial Ledger',
                description: 'Full history of society transactions and balances.',
                icon: Icons.account_balance_wallet_rounded,
                onExport: (format) => _handleExport(context, ref, 'Financial Ledger', format),
              ),
              const SizedBox(height: AppSpacing.md),
              _ReportCard(
                title: 'Membership Roster',
                description: 'Complete list of members with contact details.',
                icon: Icons.people_rounded,
                onExport: (format) => _handleExport(context, ref, 'Membership Roster', format),
              ),
              const SizedBox(height: AppSpacing.md),
              _ReportCard(
                title: 'Event Attendance',
                description: 'Attendance statistics across all events.',
                icon: Icons.event_note_rounded,
                onExport: (format) => _handleExport(context, ref, 'Event Attendance', format),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref, String type, String format) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preparing $format Export for $type...')),
    );

    await ref.read(reportsControllerProvider.notifier).exportReport(
      type: type,
      format: format,
      onSuccess: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$type exported successfully as $format!')),
          );
        }
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Function(String) onExport;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BoxyArtSquareBadge(
                size: 40,
                isTinted: true,
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.cardTitle),
                    Text(description, style: AppTypography.subtext),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BoxyArtButton(
                title: 'PDF',
                isSmall: true,
                isGhost: true,
                onTap: () => onExport('PDF'),
              ),
              const SizedBox(width: AppSpacing.md),
              BoxyArtButton(
                title: 'CSV',
                isSmall: true,
                onTap: () => onExport('CSV'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
