import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'branding/branding_color_settings.dart';
import 'branding/branding_icon_settings.dart';
import 'branding/branding_palette_manager.dart';
import 'branding/branding_helper_widgets.dart';

class DesignLabScreen extends ConsumerWidget {
  const DesignLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return HeadlessScaffold(
      title: 'Design Lab',
      subtitle: 'Operator Configuration',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.standard),

              // ── 1. BRAND COLORS ──────────────────────────────────────────
              _LabSection(
                icon: Icons.palette_rounded,
                title: 'Brand Colors',
                description: 'Primary action color, card surfaces, and page background. '
                    'These flow into buttons, indicators, and all interactive elements.',
                preview: _ColorPreview(config: config),
                controls: Column(
                  children: [
                    BrandingColorSettings(config: config, controller: controller),
                    const SizedBox(height: AppSpacing.section),
                    BrandingPaletteManager(config: config, controller: controller),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 2. SCORE PALETTE ─────────────────────────────────────────
              _LabSection(
                icon: Icons.sports_golf_rounded,
                title: 'Score Palette',
                description: 'Colors applied to each score outcome badge — '
                    'Eagle through Triple Bogey+. Changes appear immediately on all scorecards.',
                preview: _ScorePreview(config: config),
                controls: _ScorePaletteControls(config: config, controller: controller),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 3. SHAPE & RADIUS ────────────────────────────────────────
              _LabSection(
                icon: Icons.rounded_corner_rounded,
                title: 'Shape & Radius',
                description: 'Corner rounding for each component class. '
                    'Sharp (0) gives a structured look; larger values feel softer and modern.',
                preview: _ShapePreview(config: config),
                controls: _RadiusControls(config: config, controller: controller),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 4. NAVIGATION ────────────────────────────────────────────
              _LabSection(
                icon: Icons.navigation_rounded,
                title: 'Navigation',
                description: 'Bottom nav bar top corner rounding. '
                    'Higher values give a "shelf" quality — elevated but grounded. '
                    'Zero is a flat panel.',
                preview: _NavPreview(config: config),
                controls: _NavControls(config: config, controller: controller),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 5. SHADOWS & BORDERS ─────────────────────────────────────
              _LabSection(
                icon: Icons.layers_rounded,
                title: 'Shadows & Borders',
                description: 'Depth and edge definition. Shadows add lift to cards; '
                    'borders harden surfaces. Use one or both — rarely both at full intensity.',
                preview: _ShadowPreview(config: config),
                controls: _ShadowBorderControls(config: config, controller: controller),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 6. SPACING & DENSITY ─────────────────────────────────────
              _LabSection(
                icon: Icons.space_bar_rounded,
                title: 'Spacing & Density',
                description: 'Vertical rhythm between labels, cards, and fields. '
                    'Tighter spacing works well for admin-dense layouts; '
                    'looser spacing suits member-facing screens.',
                preview: _SpacingPreview(config: config),
                controls: _SpacingControls(config: config, controller: controller),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 7. TYPOGRAPHY ────────────────────────────────────────────
              _LabSection(
                icon: Icons.text_fields_rounded,
                title: 'Typography',
                description: 'The primary font family applied across all text. '
                    'The size scale and weight tokens remain constant — '
                    'only the typeface changes.',
                preview: _TypographyPreview(config: config),
                controls: _FontControls(config: config, controller: controller),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 8. ICONS & BADGES ────────────────────────────────────────
              _LabSection(
                icon: Icons.shield_rounded,
                title: 'Icons & Badges',
                description: 'Icon badge size, fill color, icon tint, and opacity. '
                    'Used by stat cards, member rows, and action indicators throughout the app.',
                preview: const SizedBox.shrink(),
                controls: BrandingIconSettings(config: config, controller: controller),
              ),

              const SizedBox(height: AppSpacing.section),

              // ── 9. SYSTEM REFERENCES ─────────────────────────────────────
              const BoxyArtSectionTitle(title: 'System References'),
              BoxyArtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fixed primitive scales — these are not configurable. '
                      'They are the foundation the token system is built on.',
                      style: AppTypography.micro.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.atomic),
                    const BoxyArtSectionTitle(title: 'DARK SCALE', isLevel2: true),
                    const ResponsiveColorRow(
                      children: [
                        DarkSwatch(label: '950', color: AppColors.dark950),
                        DarkSwatch(label: '900', color: AppColors.dark900),
                        DarkSwatch(label: '800', color: AppColors.dark800),
                        DarkSwatch(label: '700', color: AppColors.dark700),
                        DarkSwatch(label: '600', color: AppColors.dark600),
                        DarkSwatch(label: '500', color: AppColors.dark500),
                        DarkSwatch(label: '400', color: AppColors.dark400),
                        DarkSwatch(label: '300', color: AppColors.dark300),
                        DarkSwatch(label: '200', color: AppColors.dark200),
                        DarkSwatch(label: '100', color: AppColors.dark100),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    const BoxyArtSectionTitle(title: 'BRAND PRIMITIVES', isLevel2: true),
                    Wrap(
                      spacing: AppSpacing.atomic,
                      runSpacing: AppSpacing.atomic,
                      children: [
                        ScoreColorGridItem(label: 'AMBER', color: AppColors.amber500, onTap: () {}),
                        ScoreColorGridItem(label: 'LIME', color: AppColors.lime500, onTap: () {}),
                        ScoreColorGridItem(label: 'CORAL', color: AppColors.coral500, onTap: () {}),
                        ScoreColorGridItem(label: 'SLATE', color: AppColors.dark300, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.hero),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── SHARED SECTION WRAPPER ───────────────────────────────────────────────────

class _LabSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget preview;
  final Widget controls;

  const _LabSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.preview,
    required this.controls,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = theme.extension<AppShapeTokens>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: AppSpacing.section,
              height: AppSpacing.section,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityLow),
                borderRadius: shapes?.button ?? BorderRadius.circular(8),
              ),
              child: Icon(icon, size: AppShapes.iconSm, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.atomic),
            Text(
              title.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: AppTypography.lsLabel,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTypography.micro.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
          ),
        ),
        // Preview (skip if SizedBox.shrink)
        if (preview is! SizedBox || (preview as SizedBox).height != 0) ...[
          const SizedBox(height: AppSpacing.standard),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.standard),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: shapes?.card ?? BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: AppColors.opacityLow),
              ),
            ),
            child: preview,
          ),
        ],
        const SizedBox(height: AppSpacing.standard),
        controls,
      ],
    );
  }
}

// ── SHARED CONTROL WIDGETS ───────────────────────────────────────────────────

class _SliderControl extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderControl({
    required this.label,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold)),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.micro.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.atomic),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                style: AppTypography.label.copyWith(fontWeight: AppTypography.weightHeavy),
              ),
            ),
          ],
        ),
        BoxyArtSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            isNeutral: true,
            onChanged: onChanged,
          ),
        Divider(height: AppSpacing.standard, color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
      ],
    );
  }
}

// ── PREVIEW WIDGETS ──────────────────────────────────────────────────────────

class _ColorPreview extends StatelessWidget {
  final SocietyConfig config;
  const _ColorPreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final colors = [
      (Color(config.primaryColor), 'Primary'),
      (Color(config.secondaryColor), 'Secondary'),
      (Color(config.cardColor), 'Card'),
      (Color(config.backgroundColor), 'Background'),
      (Color(config.textPrimaryColor), 'Text'),
    ];
    return Row(
      children: colors.map((item) {
        final (color, label) = item;
        final isLight = color.computeLuminance() > 0.5;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Column(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    color.toARGB32().toRadixString(16).toUpperCase().substring(2),
                    style: AppTypography.nano.copyWith(
                      color: isLight ? Colors.black54 : Colors.white54,
                      fontSize: 8,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(label, style: AppTypography.nano.copyWith(fontSize: 9), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ScorePreview extends StatelessWidget {
  final SocietyConfig config;
  const _ScorePreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final scores = [
      (Color(config.scoreEagleColor), 'Eagle', '3'),
      (Color(config.scoreBirdieColor), 'Birdie', '4'),
      (Color(config.scoreParColor), 'Par', '5'),
      (Color(config.scoreBogeyColor), 'Bogey', '6'),
      (Color(config.scoreDoubleColor), 'Double', '7'),
      (Color(config.scoreTriplePlusColor), 'Triple+', '8'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: scores.map((item) {
        final (color, label, score) = item;
        final isLight = color.computeLuminance() > 0.5;
        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: label == 'Eagle' || label == 'Birdie'
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: label != 'Eagle' && label != 'Birdie'
                    ? BorderRadius.circular(6)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                score,
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightHeavy,
                  color: isLight ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.nano.copyWith(fontSize: 9)),
          ],
        );
      }).toList(),
    );
  }
}

class _ShapePreview extends StatelessWidget {
  final SocietyConfig config;
  const _ShapePreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (config.cardRadius, 'Card'),
      (config.buttonRadius, 'Button'),
      (config.inputRadius, 'Input'),
      (config.pillRadius, 'Pill'),
      (config.navBarRadius, 'Nav'),
    ];
    return Row(
      children: items.map((item) {
        final (radius, label) = item;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Column(
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityLow),
                    borderRadius: label == 'Nav'
                        ? BorderRadius.only(
                            topLeft: Radius.circular(radius),
                            topRight: Radius.circular(radius),
                          )
                        : BorderRadius.circular(radius),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityMuted),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${radius.toStringAsFixed(0)}pt',
                    style: AppTypography.nano.copyWith(
                      fontSize: 9,
                      color: theme.colorScheme.primary,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(label, style: AppTypography.nano.copyWith(fontSize: 9), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NavPreview extends StatelessWidget {
  final SocietyConfig config;
  const _NavPreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.dark800 : AppColors.pureWhite;
    final radius = config.navBarRadius;
    final items = ['Home', 'Events', 'Members', 'Locker'];
    final icons = [Icons.home_rounded, Icons.calendar_month_rounded, Icons.people_rounded, Icons.lock_rounded];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bottom Nav  ·  navBarRadius = ${radius.toStringAsFixed(0)}pt',
            style: AppTypography.nano.copyWith(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary))),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), offset: const Offset(0, -4), blurRadius: 12)],
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: List.generate(4, (i) {
              final isSelected = i == 0;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: isSelected ? BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityLow),
                        borderRadius: BorderRadius.circular(config.pillRadius),
                      ) : null,
                      child: Icon(icons[i], size: 18,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary)),
                    ),
                    const SizedBox(height: 2),
                    Text(items[i], style: AppTypography.nano.copyWith(
                      fontSize: 9,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                      fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                    )),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ShadowPreview extends StatelessWidget {
  final SocietyConfig config;
  const _ShadowPreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = theme.extension<AppShapeTokens>();
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: shapes?.card ?? BorderRadius.circular(12),
                  boxShadow: config.useShadows ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: config.shadowOpacity * config.shadowIntensity),
                      blurRadius: 12 * config.shadowIntensity,
                      spreadRadius: config.shadowSpread,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                  border: config.useBorders ? Border.all(
                    color: Color(config.borderColor).withValues(alpha: 0.4),
                    width: config.borderWidth,
                  ) : null,
                ),
                alignment: Alignment.center,
                child: Text('Card', style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                config.useShadows ? 'Shadow on' : 'Shadow off',
                style: AppTypography.nano.copyWith(fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.standard),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: shapes?.input ?? BorderRadius.circular(8),
                  border: Border.all(
                    color: config.useBorders
                        ? Color(config.borderColor).withValues(alpha: 0.6)
                        : theme.dividerColor.withValues(alpha: 0.3),
                    width: config.useBorders ? config.borderWidth : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text('Input', style: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                config.useBorders ? 'Border on' : 'Border off',
                style: AppTypography.nano.copyWith(fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpacingPreview extends StatelessWidget {
  final SocietyConfig config;
  const _SpacingPreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = theme.extension<AppShapeTokens>();
    return Column(
      children: [
        _miniLabel('SECTION LABEL', theme),
        SizedBox(height: config.labelToCardSpacing),
        _miniCard('Card content', theme, shapes),
        SizedBox(height: config.cardToLabelSpacing),
        _miniLabel('NEXT LABEL', theme),
        SizedBox(height: config.labelToCardSpacing),
        _miniCard('Another card', theme, shapes),
      ],
    );
  }

  Widget _miniLabel(String text, ThemeData theme) => Text(
    text,
    style: AppTypography.nano.copyWith(
      fontSize: 9,
      fontWeight: AppTypography.weightHeavy,
      letterSpacing: 1.0,
      color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
    ),
  );

  Widget _miniCard(String text, ThemeData theme, AppShapeTokens? shapes) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.atomic),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: shapes?.card ?? BorderRadius.circular(12),
      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
    ),
    child: Text(text, style: AppTypography.micro.copyWith(fontWeight: AppTypography.weightBold)),
  );
}

class _TypographyPreview extends StatelessWidget {
  final SocietyConfig config;
  const _TypographyPreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = [
      (AppTypography.sizeDisplay, AppTypography.weightHeavy, 'Display — Society Title'),
      (AppTypography.sizeHeadline, AppTypography.weightBold, 'Headline — Section Header'),
      (AppTypography.sizeBody, AppTypography.weightRegular, 'Body — Primary reading text'),
      (AppTypography.sizeLabel, AppTypography.weightRegular, 'Label — Metadata and buttons'),
      (AppTypography.sizeMicro, AppTypography.weightRegular, 'Micro — Captions and hints'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: styles.map((item) {
        final (size, weight, text) = item;
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: config.fontFamily,
              fontSize: size,
              fontWeight: weight,
              color: theme.colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── CONTROL SECTIONS ─────────────────────────────────────────────────────────

class _RadiusControls extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;
  const _RadiusControls({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: BoxyArtFormColumn(
        children: [
          _SliderControl(
            label: 'Cards',
            description: 'All content cards, list items, and information panels.',
            value: config.cardRadius, min: 0, max: 32, divisions: 16,
            onChanged: (v) => controller.setCardRadius(v),
          ),
          _SliderControl(
            label: 'Buttons',
            description: 'Primary and secondary action buttons throughout the app.',
            value: config.buttonRadius, min: 0, max: 30, divisions: 15,
            onChanged: (v) => controller.setButtonRadius(v),
          ),
          _SliderControl(
            label: 'Inputs',
            description: 'Text fields, dropdowns, and form input containers.',
            value: config.inputRadius, min: 0, max: 24, divisions: 12,
            onChanged: (v) => controller.setInputRadius(v),
          ),
          _SliderControl(
            label: 'Pills',
            description: 'Status badges, filter chips, and indicator pills.',
            value: config.pillRadius, min: 0, max: 30, divisions: 15,
            onChanged: (v) => controller.setPillRadius(v),
          ),
          _SliderControl(
            label: 'Hero',
            description: 'Large feature cards on the home screen and event hubs.',
            value: config.heroRadius, min: 0, max: 40, divisions: 20,
            onChanged: (v) => controller.setHeroRadius(v),
          ),
          _SliderControl(
            label: 'Metrics',
            description: 'Icon badges, stat indicators, and accent containers.',
            value: config.accentRadius, min: 0, max: 20, divisions: 10,
            onChanged: (v) => controller.setAccentRadius(v),
          ),
        ],
      ),
    );
  }
}

class _NavControls extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;
  const _NavControls({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: BoxyArtFormColumn(
        children: [
          _SliderControl(
            label: 'Nav Bar Corner Radius',
            description: 'Top-left and top-right corner rounding of the bottom navigation bar. '
                '0 = flat panel · 20 = shelf quality · 28+ = pill top.',
            value: config.navBarRadius, min: 0, max: 32, divisions: 16,
            onChanged: (v) => controller.setNavBarRadius(v),
          ),
          _SliderControl(
            label: 'Tab Indicator Radius',
            description: 'Corner rounding of the selected tab pill inside inner tab bars. '
                'Independent of the button radius — tabs are navigation, not actions.',
            value: config.tabIndicatorRadius, min: 0, max: 24, divisions: 12,
            onChanged: (v) => controller.setTabIndicatorRadius(v),
          ),
        ],
      ),
    );
  }
}

class _ShadowBorderControls extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;
  const _ShadowBorderControls({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: BoxyArtFormColumn(
        children: [
          BoxyArtSwitchField(
            label: 'Use Shadows',
            subtitle: 'Adds upward elevation to cards and floating elements.',
            value: config.useShadows,
            onChanged: (v) => controller.setUseShadows(v),
          ),
          if (config.useShadows) ...[
            _SliderControl(
              label: 'Intensity',
              description: 'Multiplier applied to all shadow blur and opacity values.',
              value: config.shadowIntensity, min: 0, max: 2, divisions: 20,
              onChanged: (v) => controller.setShadowIntensity(v),
            ),
            _SliderControl(
              label: 'Spread',
              description: 'How far the shadow extends beyond the element edge.',
              value: config.shadowSpread, min: 0, max: 20, divisions: 20,
              onChanged: (v) => controller.setShadowSpread(v),
            ),
            _SliderControl(
              label: 'Opacity',
              description: 'Global shadow transparency. Lower = more subtle.',
              value: config.shadowOpacity, min: 0, max: 1, divisions: 20,
              onChanged: (v) => controller.setShadowOpacity(v),
            ),
          ],
          const BoxyArtDivider(),
          BoxyArtSwitchField(
            label: 'Use Borders',
            subtitle: 'Draws a visible edge on cards and input fields.',
            value: config.useBorders,
            onChanged: (v) => controller.setUseBorders(v),
          ),
          if (config.useBorders) ...[
            _SliderControl(
              label: 'Border Width',
              description: 'Thickness in pixels of card and input borders.',
              value: config.borderWidth, min: 0.5, max: 4, divisions: 7,
              onChanged: (v) => controller.setBorderWidth(v),
            ),
            CompactColorPicker(
              label: 'Border Color',
              color: Color(config.borderColor),
              onTap: () => BrandingHelper.pickColor(context, 'Border Color', Color(config.borderColor),
                  (c) => controller.setBorderColor(c)),
            ),
          ],
          const BoxyArtDivider(),
          _SliderControl(
            label: 'Divider Thickness',
            description: 'Thickness of horizontal rules separating list items.',
            value: config.dividerThickness, min: 0.5, max: 3, divisions: 5,
            onChanged: (v) => controller.setDividerThickness(v),
          ),
          CompactColorPicker(
            label: 'Divider Color',
            color: Color(config.dividerColor),
            onTap: () => BrandingHelper.pickColor(context, 'Divider Color', Color(config.dividerColor),
                (c) => controller.setDividerColor(c)),
          ),
        ],
      ),
    );
  }
}

class _SpacingControls extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;
  const _SpacingControls({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      child: BoxyArtFormColumn(
        children: [
          _SliderControl(
            label: 'Label → Card',
            description: 'Gap between a section title and the card beneath it.',
            value: config.labelToCardSpacing, min: 0, max: 32, divisions: 16,
            onChanged: (v) => controller.setLabelToCardSpacing(v),
          ),
          _SliderControl(
            label: 'Card → Label',
            description: 'Gap between the bottom of a card and the next section title.',
            value: config.cardToLabelSpacing, min: 0, max: 48, divisions: 12,
            onChanged: (v) => controller.setCardToLabelSpacing(v),
          ),
          _SliderControl(
            label: 'Card → Card',
            description: 'Vertical gap between adjacent cards in a list.',
            value: config.cardToCardSpacing, min: 4, max: 32, divisions: 14,
            onChanged: (v) => controller.setCardToCardSpacing(v),
          ),
          _SliderControl(
            label: 'Field → Field',
            description: 'Gap between consecutive form fields inside a card.',
            value: config.fieldToFieldSpacing, min: 4, max: 32, divisions: 14,
            onChanged: (v) => controller.setFieldToFieldSpacing(v),
          ),
          _SliderControl(
            label: 'Card Vertical Padding',
            description: 'Top and bottom internal padding inside cards.',
            value: config.cardVerticalPadding, min: 4, max: 40, divisions: 18,
            onChanged: (v) => controller.setCardVerticalPadding(v),
          ),
          _SliderControl(
            label: 'Card Horizontal Padding',
            description: 'Left and right internal padding inside cards.',
            value: config.cardHorizontalPadding, min: 4, max: 40, divisions: 18,
            onChanged: (v) => controller.setCardHorizontalPadding(v),
          ),
          _SliderControl(
            label: 'Button Height',
            description: 'Height of primary and secondary action buttons.',
            value: config.buttonHeight, min: 32, max: 64, divisions: 16,
            onChanged: (v) => controller.setButtonHeight(v),
          ),
        ],
      ),
    );
  }
}

class _FontControls extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;
  const _FontControls({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = theme.extension<AppShapeTokens>();
    const fonts = [
      'Plus Jakarta Sans', 'Inter', 'Roboto',
      'Outfit', 'Montserrat', 'Sora', 'Lexend',
    ];

    return BoxyArtCard(
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: fonts.map((font) {
          final isSelected = config.fontFamily == font;
          return GestureDetector(
            onTap: () => controller.setFontFamily(font),
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.atomic),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: shapes?.pill ?? BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withValues(alpha: AppColors.opacityMuted),
                ),
              ),
              child: Text(
                font,
                style: TextStyle(
                  fontFamily: font,
                  fontSize: AppTypography.sizeLabel,
                  fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScorePaletteControls extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;
  const _ScorePaletteControls({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scores = [
      ('Eagle', Color(config.scoreEagleColor), (Color c) => controller.setScoreEagleColor(c)),
      ('Birdie', Color(config.scoreBirdieColor), (Color c) => controller.setScoreBirdieColor(c)),
      ('Par', Color(config.scoreParColor), (Color c) => controller.setScoreParColor(c)),
      ('Bogey', Color(config.scoreBogeyColor), (Color c) => controller.setScoreBogeyColor(c)),
      ('Double', Color(config.scoreDoubleColor), (Color c) => controller.setScoreDoubleColor(c)),
      ('Triple+', Color(config.scoreTriplePlusColor), (Color c) => controller.setScoreTriplePlusColor(c)),
    ];

    return BoxyArtCard(
      child: ResponsiveColorRow(
        children: scores.map((item) {
          final (label, color, setter) = item;
          return CompactColorPicker(
            label: label,
            color: color,
            onTap: () => BrandingHelper.pickColor(context, label, color, setter),
          );
        }).toList(),
      ),
    );
  }
}
