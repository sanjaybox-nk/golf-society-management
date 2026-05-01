import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../tabs/event_tabs_state.dart';

class LiveHubToggle extends ConsumerWidget {
  final GolfEvent event;
  
  const LiveHubToggle({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(eventMyCardTabProvider);
    final isLocker = activeIndex == 0;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppShapes.pill,
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              label: 'SCORECARD',
              isActive: isLocker,
              onTap: () => ref.read(eventMyCardTabProvider.notifier).set(0),
            ),
          ),
          Expanded(
            child: _ToggleItem(
              label: 'MATCH PLAY',
              isActive: !isLocker,
              onTap: () => ref.read(eventMyCardTabProvider.notifier).set(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.lime500 : Colors.transparent,
          borderRadius: AppShapes.pill,
        ),
        child: Text(
          label,
          style: AppTypography.micro.copyWith(
            fontWeight: AppTypography.weightBold,
            color: isActive ? AppColors.dark600 : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
