
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';

class BrandingTypographySettings extends StatelessWidget {
  final SocietyConfig config;
  final ThemeController controller;

  const BrandingTypographySettings({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final fonts = [
      'Plus Jakarta Sans',
      'Inter',
      'Roboto',
      'Outfit',
      'Montserrat',
      'Sora',
      'Lexend',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Typography & Typeface', followsCard: true),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              Text(
                'Choose the primary font family for your society. This affects all headers, body text, and metrics.',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: AppTypography.weightMedium,
                  color: AppColors.dark600,
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: fonts.map((font) {
                  final isSelected = config.fontFamily == font;
                  return InkWell(
                    onTap: () => controller.setFontFamily(font),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Color(config.secondaryColor) 
                            : Color(config.surfaceElevatedColor),
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        border: isSelected 
                            ? null 
                            : Border.all(color: Color(config.borderColor).withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        font,
                        style: AppTypography.label.copyWith(
                          color: isSelected ? Colors.white : Color(config.textPrimaryColor),
                          fontFamily: font,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
