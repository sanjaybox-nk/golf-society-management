import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/theme_controller.dart';

import '../../../../core/theme/contrast_helper.dart';

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
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = ContrastHelper.getContrastingText(primaryColor);

    // Popular currencies for quick access
    final popularCodes = ['GBP', 'USD', 'EUR', 'JPY', 'AUD', 'CAD'];
    final popularCurrencies = _allCurrencies.where((c) => popularCodes.contains(c.code)).toList();

    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Select Currency',
        subtitle: 'App-wide display currency',
        isLarge: true,
        leadingWidth: 70,
        leading: Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text('Back', style: TextStyle(color: onPrimary, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: BoxyArtSearchBar(
              hintText: 'Search by name, code or symbol...',
              controller: _searchController,
              onChanged: _filterCurrencies,
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (_searchController.text.isEmpty) ...[
                  const BoxyArtSectionTitle(title: 'Popular Currencies'),
                  const SizedBox(height: 12),
                  _buildPopularGrid(popularCurrencies, societyConfig.currencyCode, (c) {
                    controller.setCurrency(c.symbol, c.code);
                    context.pop();
                  }),
                  const SizedBox(height: 32),
                  const BoxyArtSectionTitle(title: 'All Currencies'),
                  const SizedBox(height: 12),
                ],
                
                ..._filteredCurrencies.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BoxyArtFloatingCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      controller.setCurrency(c.symbol, c.code);
                      context.pop();
                    },
                    child: Row(
                      children: [
                        // FLAG / ICON
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getEmoji(c),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                c.code,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SYMBOL
                        Text(
                          c.symbol,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.code == societyConfig.currencyCode 
                                ? Theme.of(context).primaryColor 
                                : Colors.black,
                          ),
                        ),
                        if (c.code == societyConfig.currencyCode)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
                
                if (_filteredCurrencies.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No currencies found for "${_searchController.text}"',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
        
        return BoxyArtFloatingCard(
          padding: EdgeInsets.zero,
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
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black,
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
