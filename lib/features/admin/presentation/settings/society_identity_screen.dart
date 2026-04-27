import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import 'widgets/logo_picker.dart';

class SocietyIdentityScreen extends ConsumerWidget {
  const SocietyIdentityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Society Identity',
      subtitle: 'Manage branding and assets',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        // Identity Section
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(
              title: 'Identity & Assets',
              isPeeking: true,
            ),
          ),
        ),

        // Card 1: Branding Assets (Logo)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: BoxyArtLogoPicker(
                currentUrl: config.logoUrl,
                onUrlChanged: (v) => controller.setLogoUrl(v),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
        ),

        // Card 2: Society Naming
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ModernTextField(
                label: 'Society Name',
                initialValue: config.societyName,
                onChanged: (v) => controller.setSocietyName(v),
                icon: Icons.business_rounded,
                isSeamless: true,
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? 100),
        ),
      ],
    );
  }
}
