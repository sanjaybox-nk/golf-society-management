import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/shared_ui/headless_scaffold.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/theme_controller.dart';



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
    final controller = ref.read(themeControllerProvider.notifier);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    // Popular currencies for quick access
    final popularCodes = ['GBP', 'USD', 'EUR', 'JPY', 'AUD', 'CAD'];
    final popularCurrencies = _allCurrencies.where((c) => popularCodes.contains(c.code)).toList();

    return HeadlessScaffold(
      title: 'Currency',
      subtitle: 'App-wide display currency',
      showBack: true,
      backgroundColor: beigeBackground,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Search Bar
              ModernCard(
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterCurrencies,
                  decoration: InputDecoration(
                    hintText: 'Search by name, code or symbol...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (_searchController.text.isEmpty) ...[
                const BoxyArtSectionTitle(title: 'Popular Currencies', padding: EdgeInsets.zero),
                const SizedBox(height: 12),
                _buildPopularGrid(popularCurrencies, societyConfig.currencyCode, (c) {
                  controller.setCurrency(c.symbol, c.code);
                  context.pop();
                }),
                const SizedBox(height: 32),
                const BoxyArtSectionTitle(title: 'All Currencies', padding: EdgeInsets.zero),
                const SizedBox(height: 12),
              ],
              
              ..._filteredCurrencies.map((c) {
                final isSelected = c.code == societyConfig.currencyCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ModernCard(
                    onTap: () {
                      controller.setCurrency(c.symbol, c.code);
                      context.pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getEmoji(c),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  c.code,
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            c.symbol,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Theme.of(context).primaryColor : null,
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              if (_filteredCurrencies.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No currencies found',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
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
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        final c = currencies[index];
        final isSelected = c.code == currentCode;
        
        return ModernCard(
          onTap: () => onSelect(c),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getEmoji(c),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                c.code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Theme.of(context).primaryColor : null,
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
