import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:golf_society/services/storage_service.dart';

class BrandingSettingsScreen extends ConsumerWidget {
  const BrandingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final controller = ref.read(themeControllerProvider.notifier);

    return HeadlessScaffold(
      title: 'Branding',
      subtitle: 'Customize colors and identity',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: spacing?.labelToCard ?? AppSpacing.labelToCard,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'Live Preview'),
              _buildPreviewCard(
                config.primaryColor,
                config.secondaryColor,
                config.themeMode,
                config.useShadows,
                config.shadowIntensity,
                config.useBorders,
                config.borderWidth,
                config.buttonRadius,
                config.cardRadius,
                config.inputRadius,
                config.heroRadius,
                config.accentRadius,
                config.accentOpacity,
                config.shadowSpread,
                config.shadowOpacity,
                config.labelToCardSpacing,
                config.cardToLabelSpacing,
                config.statusConfirmedColor,
                config.statusReservedColor,
                config.statusWaitlistColor,
                config.cardVerticalPadding,
                config.cardHorizontalPadding,
              ),

              const BoxyArtSectionTitle(title: 'App Appearance'),
              BoxyArtCard(
                child: Column(
                  children: [
                    _ThemeModeTile(
                      title: 'System Default',
                      value: 'system',
                      groupValue: config.themeMode,
                      icon: Icons.brightness_auto_rounded,
                      onChanged: (v) => controller.setThemeMode(v!),
                    ),
                    const Divider(height: 1),
                    _ThemeModeTile(
                      title: 'Always Light',
                      value: 'light',
                      groupValue: config.themeMode,
                      icon: Icons.light_mode_rounded,
                      onChanged: (v) => controller.setThemeMode(v!),
                    ),
                    const Divider(height: 1),
                    _ThemeModeTile(
                      title: 'Always Dark',
                      value: 'dark',
                      groupValue: config.themeMode,
                      icon: Icons.dark_mode_rounded,
                      onChanged: (v) => controller.setThemeMode(v!),
                    ),
                  ],
                ),
              ),

              const BoxyArtSectionTitle(title: 'Society Identity'),
              BoxyArtCard(
                child: Column(
                  children: [
                    ModernTextField(
                      label: 'Society Name',
                      initialValue: config.societyName,
                      onChanged: (v) => controller.setSocietyName(v),
                      icon: Icons.business_rounded,
                    ),
                    _LogoPicker(
                      currentUrl: config.logoUrl,
                      onUrlChanged: (v) => controller.setLogoUrl(v),
                    ),
                  ],
                ),
              ),

              const BoxyArtSectionTitle(title: 'Style Preference'),
              BoxyArtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a structural tone for your society. This adjusts corner rounding and depth.',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: AppTypography.weightMedium,
                      ),
                    ),
                    SizedBox(
                      height: spacing?.labelToCard ?? AppSpacing.labelToCard,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use Shadows',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                              Text(
                                'Adds depth to cards and buttons',
                                style: AppTypography.helper.copyWith(
                                  fontWeight: AppTypography.weightRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: config.useShadows,
                          onChanged: (v) => controller.setUseShadows(v),
                          activeThumbColor: Color(config.secondaryColor),
                          activeTrackColor: Color(
                            config.secondaryColor,
                          ).withValues(alpha: AppColors.opacityMedium),
                        ),
                      ],
                    ),
                    if (config.useShadows) ...[
                      Row(
                        children: [
                          Text(
                            'Intensity',
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBold,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: config.shadowIntensity,
                              min: 0.0,
                              max: 2.0,
                              divisions: 20,
                              label: config.shadowIntensity.toStringAsFixed(1),
                              activeColor: Color(config.secondaryColor),
                              onChanged: (v) =>
                                  controller.setShadowIntensity(v),
                            ),
                          ),
                          Text(
                            config.shadowIntensity.toStringAsFixed(1),
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBlack,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Spread',
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBold,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: config.shadowSpread,
                              min: 0.0,
                              max: 20.0,
                              divisions: 20,
                              label: config.shadowSpread.toStringAsFixed(0),
                              activeColor: Color(config.secondaryColor),
                              onChanged: (v) => controller.setShadowSpread(v),
                            ),
                          ),
                          Text(
                            config.shadowSpread.toStringAsFixed(0),
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBlack,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Opacity',
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBold,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: config.shadowOpacity,
                              min: 0.0,
                              max: 1.0,
                              divisions: 20,
                              label: config.shadowOpacity.toStringAsFixed(2),
                              activeColor: Color(config.secondaryColor),
                              onChanged: (v) => controller.setShadowOpacity(v),
                            ),
                          ),
                          Text(
                            config.shadowOpacity.toStringAsFixed(2),
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use Borders',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                              Text(
                                'Hardens card and field edges',
                                style: AppTypography.helper.copyWith(
                                  fontWeight: AppTypography.weightRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: config.useBorders,
                          onChanged: (v) => controller.setUseBorders(v),
                          activeThumbColor: Color(config.secondaryColor),
                          activeTrackColor: Color(
                            config.secondaryColor,
                          ).withValues(alpha: AppColors.opacityMedium),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: spacing?.cardToCard ?? AppSpacing.standard,
                    ),
                    const BoxyArtSectionTitle(
                      title: 'SHAPE & RADIUS',
                      isLevel2: true,
                    ),
                    if (config.useBorders) ...[
                      Row(
                        children: [
                          Text(
                            'Border',
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBold,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: config.borderWidth,
                              min: 0.5,
                              max: 4.0,
                              divisions: 7,
                              label: config.borderWidth.toStringAsFixed(1),
                              activeColor: Color(config.secondaryColor),
                              onChanged: (v) => controller.setBorderWidth(v),
                            ),
                          ),
                          Text(
                            config.borderWidth.toStringAsFixed(1),
                            style: AppTypography.helper.copyWith(
                              fontWeight: AppTypography.weightBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic),
                    Row(
                      children: [
                        Text(
                          'Pills',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.pillRadius,
                            min: 0.0,
                            max: 30.0,
                            divisions: 15,
                            label: config.pillRadius.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setPillRadius(v),
                          ),
                        ),
                        Text(
                          config.pillRadius.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Buttons',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.buttonRadius,
                            min: 0.0,
                            max: 30.0,
                            divisions: 15,
                            label: config.buttonRadius.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setButtonRadius(v),
                          ),
                        ),
                        Text(
                          config.buttonRadius.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Cards',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.cardRadius,
                            min: 0.0,
                            max: 40.0,
                            divisions: 20,
                            label: config.cardRadius.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setCardRadius(v),
                          ),
                        ),
                        Text(
                          config.cardRadius.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Inputs',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.inputRadius,
                            min: 0.0,
                            max: 30.0,
                            divisions: 15,
                            label: config.inputRadius.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setInputRadius(v),
                          ),
                        ),
                        Text(
                          config.inputRadius.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Hero Cards',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.heroRadius,
                            min: 0.0,
                            max: 60.0,
                            divisions: 30,
                            label: config.heroRadius.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setHeroRadius(v),
                          ),
                        ),
                        Text(
                          config.heroRadius.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    BoxyArtDivider(
                      verticalPadding:
                          spacing?.labelToCard ?? AppSpacing.labelToCard,
                    ),
                    const BoxyArtSectionTitle(
                      title: 'VERTICAL SPACING & RHYTHM',
                      isLevel2: true,
                    ),
                    Row(
                      children: [
                        Text(
                          'Card to Label',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.cardToLabelSpacing,
                            min: 0.0,
                            max: 64.0,
                            divisions: 16,
                            label: config.cardToLabelSpacing.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) =>
                                controller.setCardToLabelSpacing(v),
                          ),
                        ),
                        Text(
                          config.cardToLabelSpacing.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Label to Card',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.labelToCardSpacing,
                            min: 0.0,
                            max: 32.0,
                            divisions: 16,
                            label: config.labelToCardSpacing.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) =>
                                controller.setLabelToCardSpacing(v),
                          ),
                        ),
                        Text(
                          config.labelToCardSpacing.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Card to Card',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.cardToCardSpacing,
                            min: 0.0,
                            max: 32.0,
                            divisions: 16,
                            label: config.cardToCardSpacing.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) =>
                                controller.setCardToCardSpacing(v),
                          ),
                        ),
                        Text(
                          config.cardToCardSpacing.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Card Vertical Padding',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.cardVerticalPadding,
                            min: 0.0,
                            max: 48.0,
                            divisions: 24,
                            label: config.cardVerticalPadding.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) =>
                                controller.setCardVerticalPadding(v),
                          ),
                        ),
                        Text(
                          config.cardVerticalPadding.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Card Horizontal Padding',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.cardHorizontalPadding,
                            min: 0.0,
                            max: 48.0,
                            divisions: 24,
                            label: config.cardHorizontalPadding.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) =>
                                controller.setCardHorizontalPadding(v),
                          ),
                        ),
                        Text(
                          config.cardHorizontalPadding.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    BoxyArtDivider(
                      verticalPadding:
                          spacing?.labelToCard ?? AppSpacing.labelToCard,
                    ),
                    const BoxyArtSectionTitle(title: 'Metric & Icon Branding'),
                    Row(
                      children: [
                        Text(
                          'Accent Radius',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.accentRadius,
                            min: 0.0,
                            max: 30.0,
                            divisions: 15,
                            label: config.accentRadius.toStringAsFixed(0),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setAccentRadius(v),
                          ),
                        ),
                        Text(
                          config.accentRadius.toStringAsFixed(0),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Accent Opacity',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.accentOpacity,
                            min: 0.0,
                            max: 0.5,
                            divisions: 10,
                            label: config.accentOpacity.toStringAsFixed(2),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setAccentOpacity(v),
                          ),
                        ),
                        Text(
                          config.accentOpacity.toStringAsFixed(2),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Icon Badge Opacity',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.iconBadgeOpacity,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            label: config.iconBadgeOpacity.toStringAsFixed(2),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setIconBadgeOpacity(v),
                          ),
                        ),
                        Text(
                          config.iconBadgeOpacity.toStringAsFixed(2),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Icon Opacity',
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: config.iconOpacity,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            label: config.iconOpacity.toStringAsFixed(2),
                            activeColor: Color(config.secondaryColor),
                            onChanged: (v) => controller.setIconOpacity(v),
                          ),
                        ),
                        Text(
                          config.iconOpacity.toStringAsFixed(2),
                          style: AppTypography.helper.copyWith(
                            fontWeight: AppTypography.weightBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Style Selector Removed in v4.0
                  ],
                ),
              ),

              const BoxyArtSectionTitle(title: 'App Identity Colors'),
              BoxyArtCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Primary Accent',
                            color: Color(config.primaryColor),
                            onTap: () => _pickColor(
                              context,
                              'Primary',
                              Color(config.primaryColor),
                              (c) => controller.setPrimaryColor(c),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: spacing?.labelToCard ?? AppSpacing.labelToCard,
                        ),
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Action Color',
                            color: Color(config.secondaryColor),
                            onTap: () => _pickColor(
                              context,
                              'Action',
                              Color(config.secondaryColor),
                              (c) => controller.setSecondaryColor(c),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: spacing?.labelToCard ?? AppSpacing.labelToCard,
                    ),
                    _CompactColorPicker(
                      label: 'Page Background (Light Mode)',
                      color: Color(config.backgroundColor),
                      onTap: () => _pickColor(
                        context,
                        'Background',
                        Color(config.backgroundColor),
                        (c) => controller.setBackgroundColor(c),
                      ),
                    ),
                  ],
                ),
              ),

              const BoxyArtSectionTitle(title: 'Functional Status Colors'),
              BoxyArtCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Confirmed',
                            color: Color(config.statusConfirmedColor),
                            onTap: () => _pickColor(
                              context,
                              'Confirmed',
                              Color(config.statusConfirmedColor),
                              (c) => controller.setStatusConfirmedColor(c),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: spacing?.labelToCard ?? AppSpacing.labelToCard,
                        ),
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Reserved',
                            color: Color(config.statusReservedColor),
                            onTap: () => _pickColor(
                              context,
                              'Reserved',
                              Color(config.statusReservedColor),
                              (c) => controller.setStatusReservedColor(c),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: spacing?.labelToCard ?? AppSpacing.labelToCard,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Waitlist',
                            color: Color(config.statusWaitlistColor),
                            onTap: () => _pickColor(
                              context,
                              'Waitlist',
                              Color(config.statusWaitlistColor),
                              (c) => controller.setStatusWaitlistColor(c),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: spacing?.labelToCard ?? AppSpacing.labelToCard,
                        ),
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Withdrawn',
                            color: Color(config.statusWithdrawnColor),
                            onTap: () => _pickColor(
                              context,
                              'Withdrawn',
                              Color(config.statusWithdrawnColor),
                              (c) => controller.setStatusWithdrawnColor(c),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: spacing?.labelToCard ?? AppSpacing.labelToCard,
                    ),
                    _CompactColorPicker(
                      label: 'Dinner Only',
                      color: Color(config.statusDinnerColor),
                      onTap: () => _pickColor(
                        context,
                        'Dinner',
                        Color(config.statusDinnerColor),
                        (c) => controller.setStatusDinnerColor(c),
                      ),
                    ),
                  ],
                ),
              ),

              const BoxyArtSectionTitle(title: 'Icon Badge Styling'),
              BoxyArtCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Icon Fill',
                            color: Color(config.iconBadgeFillColor),
                            onTap: () => _pickColor(
                              context,
                              'Icon Fill',
                              Color(config.iconBadgeFillColor),
                              (c) => controller.setIconBadgeFillColor(c),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: spacing?.labelToCard ?? AppSpacing.labelToCard,
                        ),
                        Expanded(
                          child: _CompactColorPicker(
                            label: 'Icon Glyph',
                            color: Color(config.iconBadgeIconColor),
                            onTap: () => _pickColor(
                              context,
                              'Icon Glyph',
                              Color(config.iconBadgeIconColor),
                              (c) => controller.setIconBadgeIconColor(c),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const BoxyArtSectionTitle(title: 'Society Dark Scale'),
              BoxyArtCard(
                child: Column(
                  children: [
                    Text(
                      'Reference palette for UI elements and text contrasts.',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDarkScalesGrid(),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _pickColor(
    BuildContext context,
    String title,
    Color current,
    Function(Color) onPicked,
  ) async {
    final result = await showColorPickerDialog(
      context,
      current,
      title: Text(
        '$title Color',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      width: AppSpacing.x4l,
      height: AppSpacing.x4l,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 12,
      wheelDiameter: 180,
      enableOpacity: false,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
    );
    onPicked(result);
  }

  Widget _buildPreviewCard(
    int primaryInt,
    int secondaryInt,
    String themeMode,
    bool useShadows,
    double shadowIntensity,
    bool useBorders,
    double borderWidth,
    double buttonRadius,
    double cardRadius,
    double inputRadius,
    double heroRadius,
    double accentRadius,
    double accentOpacity,
    double shadowSpread,
    double shadowOpacity,
    double labelToCardSpacing,
    double cardToLabelSpacing,
    int confirmedInt,
    int reservedInt,
    int waitlistInt,
    double cardVerticalPadding,
    double cardHorizontalPadding,
  ) {
    final primary = Color(primaryInt);
    final secondary = Color(secondaryInt);
    final confirmed = Color(confirmedInt);
    final reserved = Color(reservedInt);
    final waitlist = Color(waitlistInt);
    final bool isDark =
        themeMode == 'dark' ||
        (themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final bgColor = isDark ? const Color(0xFF1E1E1E) : AppColors.pureWhite;
    final textColor = isDark ? AppColors.pureWhite : Colors.black;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      showShadow: useShadows,
      child: Column(
        children: [
          const BoxyArtSectionTitle(title: 'PREVIEW SECTION', isLevel2: true),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: cardVerticalPadding,
              horizontal: cardHorizontalPadding,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(cardRadius),
              border: useBorders
                  ? Border.all(
                      color: textColor.withValues(alpha: AppColors.opacityLow),
                      width: borderWidth,
                    )
                  : null,
              boxShadow: useShadows
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha:
                              shadowOpacity * shadowIntensity.clamp(0.0, 1.0),
                        ),
                        blurRadius: 20 * shadowIntensity,
                        offset: Offset(0, 4 * shadowIntensity),
                        spreadRadius: shadowSpread,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primary.withValues(
                        alpha: AppColors.opacityMedium,
                      ),
                      radius: 24,
                      child: Icon(Icons.person, color: primary),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontWeight: AppTypography.weightBlack,
                            fontSize: AppTypography.sizeBody,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Handicap: 14.2',
                          style: TextStyle(
                            color: textColor.withValues(
                              alpha: AppColors.opacityHalf,
                            ),
                            fontSize: AppTypography.sizeLabelStrong,
                            fontWeight: AppTypography.weightSemibold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: secondary.withValues(alpha: accentOpacity),
                        borderRadius: BorderRadius.circular(accentRadius),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: isDark ? textColor : Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: labelToCardSpacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                      foregroundColor: ContrastHelper.getContrastingText(
                        secondary,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Action Button',
                      style: TextStyle(
                        fontWeight: AppTypography.weightBlack,
                        fontSize: AppTypography.sizeButton,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BoxyArtPill(label: 'Confirmed', color: confirmed),
                    const SizedBox(width: AppSpacing.sm),
                    BoxyArtPill(label: 'Waitlist', color: waitlist),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [BoxyArtPill(label: 'Reserved', color: reserved)],
                ),
              ],
            ),
          ),
          const BoxyArtSectionTitle(title: 'NEXT SECTION', isLevel2: true),
        ],
      ),
    );
  }

  Widget _buildDarkScalesGrid() {
    final colors = [
      ('950', AppColors.dark950),
      ('900', AppColors.dark900),
      ('800', AppColors.dark800),
      ('700', AppColors.dark700),
      ('600', AppColors.dark600),
      ('500', AppColors.dark500),
      ('400', AppColors.dark400),
      ('300', AppColors.dark300),
      ('200', AppColors.dark200),
      ('150', AppColors.dark150),
      ('100', AppColors.dark100),
      ('60', AppColors.dark60),
      ('50', AppColors.dark50),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      alignment: WrapAlignment.center,
      children: colors
          .map((c) => _DarkSwatch(label: c.$1, color: c.$2))
          .toList(),
    );
  }
}

class _CompactColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CompactColorPicker({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.03),
          borderRadius: AppShapes.md,
          border: Border.all(
            color: Theme.of(
              context,
            ).dividerColor.withValues(alpha: AppColors.opacitySubtle),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTypography.sizeLabel,
                fontWeight: AppTypography.weightBlack,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: AppSpacing.x3l,
                  height: AppSpacing.x3l,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '#${color.toARGB32().toRadixString(16).toUpperCase().substring(2)}',
                  style: const TextStyle(
                    fontSize: AppTypography.sizeLabelStrong,
                    fontWeight: AppTypography.weightSemibold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Style Selector Removed in v4.0 in favor of granular controls

// _StyleItem removed

class _ThemeModeTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _ThemeModeTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: AppColors.opacityLow)
                    : Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.md,
              ),
              child: Icon(
                icon,
                size: AppShapes.iconMd,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppTypography.sizeBody,
                  fontWeight: isSelected
                      ? AppTypography.weightBlack
                      : AppTypography.weightMedium,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            // ignore: deprecated_member_use
            Radio<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPalette extends StatefulWidget {
  final Color selectedColor;
  final List<int> customColors;
  final Function(Color) onColorSelected;
  final Function(Color) onAddCustomColor;
  final Function(int, Color) onUpdateCustomColor;

  const _ColorPalette({
    required this.selectedColor,
    required this.customColors,
    required this.onColorSelected,
    required this.onAddCustomColor,
    required this.onUpdateCustomColor,
  });

  static const List<Color> _systemColors = [
    Color(0xFFF7D354), // BoxyArt Yellow
    Color(0xFF2962FF), // Royal Blue
    Color(0xFF00C853), // Emerald Green
    Color(0xFFD50000), // Cardinal Red
    Color(0xFF6200EA), // Deep Purple
    Color(0xFF455A64), // Slate Grey
    Color(0xFFC6FF00), // Neon Lime
    Color(0xFFFF6D00), // Orange
    Color(0xFF00BFA5), // Teal
    Color(0xFFFFD600), // Pure Gold
  ];

  @override
  State<_ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<_ColorPalette> {
  @override
  Widget build(BuildContext context) {
    // Convert custom color ints to Color objects
    final customColorsList = widget.customColors
        .map((hex) => Color(hex))
        .toList();

    return Column(
      children: [
        // System Colors Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _ColorPalette._systemColors
              .map((c) => _buildColorCircle(c, isSystemColor: true))
              .toList(),
        ),

        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),

        // Custom Colors Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            // Existing custom colors
            ...List.generate(customColorsList.length, (index) {
              return _buildColorCircle(
                customColorsList[index],
                isSystemColor: false,
                customIndex: index,
              );
            }),
            // Empty slots (up to 5 total)
            ...List.generate(5 - customColorsList.length, (index) {
              return _buildEmptySlot();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildColorCircle(
    Color color, {
    required bool isSystemColor,
    int? customIndex,
  }) {
    final isSelected = widget.selectedColor == color;

    return GestureDetector(
      onTap: () => widget.onColorSelected(color),
      onLongPress: !isSystemColor && customIndex != null
          ? () => _showEditCustomColorDialog(customIndex, color)
          : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.black, width: 3)
              : Border.all(color: AppColors.dark300),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Center(
                child: Icon(
                  Icons.check,
                  color: ContrastHelper.getContrastingText(color),
                  size: AppShapes.iconLg,
                ),
              ),
            if (!isSystemColor && customIndex != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditCustomColorDialog(customIndex, color),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.87),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.pureWhite,
                      size: AppShapes.iconXs,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return GestureDetector(
      onTap: () => _showAddCustomColorDialog(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.dark100,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.dark400,
            width: AppShapes.borderMedium,
          ),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.dark400,
          size: AppShapes.iconLg,
        ),
      ),
    );
  }

  Future<void> _showAddCustomColorDialog() async {
    final result = await showColorPickerDialog(
      context,
      widget.selectedColor,
      title: Text('Add Color', style: Theme.of(context).textTheme.titleLarge),
      width: AppSpacing.x4l,
      height: AppSpacing.x4l,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 8,
      elevation: 4,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: false,
      ),
      constraints: const BoxConstraints(
        minHeight: 480,
        minWidth: 320,
        maxWidth: 320,
      ),
    );

    widget.onAddCustomColor(result);
  }

  Future<void> _showEditCustomColorDialog(int index, Color currentColor) async {
    final result = await showColorPickerDialog(
      context,
      currentColor,
      title: Text('Edit Color', style: Theme.of(context).textTheme.titleLarge),
      width: AppSpacing.x4l,
      height: AppSpacing.x4l,
      spacing: 8,
      runSpacing: 8,
      borderRadius: 8,
      elevation: 4,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const {
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: false,
      ),
      constraints: const BoxConstraints(
        minHeight: 480,
        minWidth: 320,
        maxWidth: 320,
      ),
    );

    widget.onUpdateCustomColor(index, result);
  }
}

class _LogoPicker extends ConsumerStatefulWidget {
  final String? currentUrl;
  final ValueChanged<String?> onUrlChanged;

  const _LogoPicker({required this.currentUrl, required this.onUrlChanged});

  @override
  ConsumerState<_LogoPicker> createState() => _LogoPickerState();
}

class _LogoPickerState extends ConsumerState<_LogoPicker> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final storage = ref.read(storageServiceProvider);

    setState(() => _isUploading = true);

    try {
      final file = await storage.pickImage(source: ImageSource.gallery);
      if (file == null) {
        setState(() => _isUploading = false);
        return;
      }

      final url = await storage.uploadImage(path: 'branding', file: file);

      widget.onUrlChanged(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Society Logo',
          style: TextStyle(
            fontSize: AppTypography.sizeLabelStrong,
            fontWeight: AppTypography.weightBold,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).dividerColor.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.xl,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: AppColors.opacityLow),
                ),
                image: widget.currentUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.currentUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.currentUrl == null
                  ? Icon(
                      Icons.golf_course_rounded,
                      size: 36,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: AppColors.opacityMedium),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _pickAndUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: ContrastHelper.getContrastingText(
                          Theme.of(context).primaryColor,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppShapes.md,
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: AppSpacing.xl,
                              height: AppSpacing.xl,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.pureWhite,
                              ),
                            )
                          : const Text(
                              'Update Logo',
                              style: TextStyle(
                                fontWeight: AppTypography.weightBold,
                              ),
                            ),
                    ),
                  ),
                  if (widget.currentUrl != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () => widget.onUrlChanged(null),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: AppShapes.iconSm,
                      ),
                      label: const Text('Remove Logo'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.coral500,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DarkSwatch extends StatelessWidget {
  final String label;
  final Color color;

  const _DarkSwatch({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppShapes.md,
            border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            fontSize: 8,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
