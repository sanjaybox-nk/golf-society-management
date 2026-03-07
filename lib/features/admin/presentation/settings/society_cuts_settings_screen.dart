import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';

class SocietyCutsSettingsScreen extends ConsumerStatefulWidget {
  const SocietyCutsSettingsScreen({super.key});

  @override
  ConsumerState<SocietyCutsSettingsScreen> createState() => _SocietyCutsSettingsScreenState();
}

class _SocietyCutsSettingsScreenState extends ConsumerState<SocietyCutsSettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final config = ref.read(themeControllerProvider);
    _controllers.addAll(config.societyCutRules.map((key, value) => MapEntry(
          key,
          TextEditingController(text: value.toString()),
        )));
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateRule(String key, String value) {
    final double? val = double.tryParse(value);
    if (val != null) {
      final currentRules = Map<String, double>.from(ref.read(themeControllerProvider).societyCutRules);
      currentRules[key] = val;
      ref.read(themeControllerProvider.notifier).setSocietyCutRules(currentRules);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(themeControllerProvider);
    final currentMode = config.societyCutMode;
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
    final theme = Theme.of(context);

    return HeadlessScaffold(
      title: 'Society Cuts',
      subtitle: (config.societyCutMode != SocietyCutMode.off) ? 'Active' : 'Disabled',
      showBack: true,
      autoPrefix: false,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Mode Selector
              const BoxyArtSectionTitle(title: 'Selection Mode'),
              const SizedBox(height: AppSpacing.md),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    _buildModeOption(context, SocietyCutMode.off, 'OFF', Icons.power_settings_new_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    _buildModeOption(context, SocietyCutMode.global, 'GLOBAL', Icons.auto_graph_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    _buildModeOption(context, SocietyCutMode.manual, 'MANUAL', Icons.touch_app_rounded),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),

              if (currentMode == SocietyCutMode.off)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: AppColors.opacitySubtle),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.shield_outlined, size: AppShapes.iconXl, color: theme.dividerColor.withValues(alpha: AppColors.opacityMuted)),
                        ),
                        const SizedBox(height: AppSpacing.x2l),
                        Text(
                          'SOCIETY CUTS DISABLED',
                          style: AppTypography.label.copyWith(
                            color: theme.dividerColor.withValues(alpha: AppColors.opacityHalf),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Select a mode above to begin',
                          style: AppTypography.caption.copyWith(color: theme.dividerColor.withValues(alpha: AppColors.opacityMuted)),
                        ),
                      ],
                    ),
                  ),
                ),

              if (currentMode == SocietyCutMode.global) ...[
                const BoxyArtSectionTitle(title: 'Cut Rules (Shots)'),
                const SizedBox(height: AppSpacing.md),
                BoxyArtCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: config.societyCutRules.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Row(
                          children: [
                            Expanded(child: Text(entry.key, style: AppTypography.label)),
                            const SizedBox(width: AppSpacing.lg),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: AppTypography.weightBlack),
                                decoration: const InputDecoration(
                                  suffixText: 'pt',
                                  isDense: true,
                                ),
                                controller: _controllers.putIfAbsent(
                                  entry.key,
                                  () => TextEditingController(text: entry.value.toString()),
                                ),
                                onChanged: (v) => _updateRule(entry.key, v),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    'In Global mode, cuts are applied automatically based on 1st/2nd/3rd finishers of previous season events.',
                    style: AppTypography.caption.copyWith(color: AppColors.dark300, fontStyle: FontStyle.italic),
                  ),
                ),
              ],

              if (currentMode == SocietyCutMode.manual) ...[
                const BoxyArtSectionTitle(title: 'Manual Overrides'),
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    'Select an upcoming event to apply specific shot adjustments for individual players.',
                    style: AppTypography.caption.copyWith(color: AppColors.dark300),
                  ),
                ),
                upcomingEventsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (events) {
                    if (events.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4l),
                        child: Center(
                          child: Text('No upcoming events found', style: AppTypography.label.copyWith(color: theme.dividerColor)),
                        ),
                      );
                    }
                    return Column(
                      children: events.map((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: BoxyArtNavTile(
                            title: event.title.toUpperCase(),
                            subtitle: 'TAP TO APPLY INDIVIDUAL CUTS',
                            icon: Icons.tune_rounded,
                            iconColor: AppColors.lime500,
                            onTap: () => context.push('/admin/events/manage/${event.id}/manual-cuts'),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildModeOption(BuildContext context, SocietyCutMode mode, String label, IconData icon) {
    final config = ref.watch(themeControllerProvider);
    final isSelected = config.societyCutMode == mode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeControllerProvider.notifier).setSocietyCutMode(mode),
        child: AnimatedContainer(
          duration: AppAnimations.medium,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary.withValues(alpha: AppColors.opacitySubtle) 
                : Colors.transparent,
            borderRadius: AppShapes.lg,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary.withValues(alpha: AppColors.opacityMedium) : Colors.transparent,
              width: AppShapes.borderThin,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary.withValues(alpha: AppColors.opacityLow)
                      : (isDark ? AppColors.dark800 : AppColors.dark50),
                  borderRadius: AppShapes.md,
                ),
                child: Icon(
                  icon, 
                  size: AppShapes.iconMd,
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : (isDark ? AppColors.dark400 : AppColors.dark300),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  fontSize: AppTypography.sizeCaptionStrong,
                  letterSpacing: 1,
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : (isDark ? AppColors.dark400 : AppColors.dark300),
                  fontWeight: isSelected ? AppTypography.weightBlack : AppTypography.weightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
