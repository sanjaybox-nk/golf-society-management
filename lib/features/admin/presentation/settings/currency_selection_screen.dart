import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';



class CurrencySelectionScreen extends ConsumerStatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  ConsumerState<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends ConsumerState<CurrencySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _filteredCurrencies = [];
  final List<Currency> _allCurrencies = CurrencyService().getAll();

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = _allCurrencies;
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _allCurrencies;
      } else {
        _filteredCurrencies = _allCurrencies.where((c) {
          final q = query.toLowerCase();
          return c.name.toLowerCase().contains(q) ||
                 c.code.toLowerCase().contains(q) ||
                 c.symbol.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final societyConfig = ref.watch(themeControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final beigeBackground = theme.scaffoldBackgroundColor;

    // Popular currencies for quick access
    final popularCodes = ['GBP', 'USD', 'EUR', 'JPY', 'AUD', 'CAD'];
    final popularCurrencies = _allCurrencies.where((c) => popularCodes.contains(c.code)).toList();

    return HeadlessScaffold(
      title: 'Currency',
      subtitle: 'Select society default currency',
      showBack: true,
      onBack: () => context.pop(),
      backgroundColor: beigeBackground,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Search Bar standardized with BoxyArtInputField
              BoxyArtInputField(
                label: 'Search Currencies',
                hint: 'Name, code or symbol...',
                controller: _searchController,
                onChanged: _filterCurrencies,
                prefixIcon: const Icon(Icons.search_rounded, size: AppShapes.iconMd),
              ),
              const SizedBox(height: AppSpacing.x3l),

              if (_searchController.text.isEmpty) ...[
                const BoxyArtSectionTitle(title: 'Popular Currencies', ),
                _buildPopularGrid(popularCurrencies, societyConfig.currencyCode, (c) {
                  ref.read(themeControllerProvider.notifier).setCurrency(c.symbol, c.code);
                  context.pop();
                }),
                const SizedBox(height: AppSpacing.x3l),
                const BoxyArtSectionTitle(title: 'All Currencies', ),
              ],
              
              ..._filteredCurrencies.map((c) {
                final isSelected = c.code == societyConfig.currencyCode;
                const identityColor = AppColors.lime500;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    onTap: () {
                      ref.read(themeControllerProvider.notifier).setCurrency(c.symbol, c.code);
                      context.pop();
                    },
                    child: Row(
                      children: [
                        // Circular Icon Container (56x56)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              c.symbol,
                              style: const TextStyle(
                                color: AppColors.lime500,
                                fontSize: AppTypography.sizeDisplayLocker,
                                fontWeight: AppTypography.weightBold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: AppTypography.sizeButton,
                                  fontWeight: AppTypography.weightExtraBold,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.code,
                                style: TextStyle(
                                  fontSize: AppTypography.sizeLabelStrong,
                                  color: isDark ? AppColors.dark300 : AppColors.dark400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              c.symbol,
                              style: AppTypography.label.copyWith(
                                fontSize: AppTypography.sizeLargeBody,
                                fontWeight: AppTypography.weightBold,
                                color: isSelected ? identityColor : null,
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.md),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: identityColor,
                                  size: AppShapes.iconLg,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              if (_filteredCurrencies.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x5l),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: AppShapes.iconHero, color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityMedium)),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No currencies found',
                          style: AppTypography.body.copyWith(
                            color: isDark ? AppColors.dark300 : AppColors.dark400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularGrid(List<Currency> currencies, String currentCode, Function(Currency) onSelect) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        final c = currencies[index];
        final isSelected = c.code == currentCode;
        
        return BoxyArtCard(
          onTap: () => onSelect(c),
          padding: EdgeInsets.zero, // Use padding in column to prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isSelected ? AppColors.lime500 : AppColors.lime500).withValues(alpha: AppColors.opacityLow),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getEmoji(c),
                    style: const TextStyle(fontSize: AppTypography.sizeDisplaySection),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                c.code,
                style: AppTypography.label.copyWith(
                  fontSize: AppTypography.sizeLabelStrong,
                  fontWeight: AppTypography.weightExtraBold,
                  letterSpacing: 0.2,
                  color: isSelected ? AppColors.lime500 : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  String _getEmoji(Currency c) {
    try {
      return CurrencyUtils.currencyToEmoji(c);
    } catch (_) {
      return '💰';
    }
  }
}
