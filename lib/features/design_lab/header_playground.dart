import 'package:flutter/material.dart';
import 'package:golf_society/core/shared_ui/modern_cards.dart';


// Color scheme definitions
class AppColorScheme {
  final String name;
  final Color background;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const AppColorScheme({
    required this.name,
    required this.background,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    this.isDark = false,
  });
}

const _schemes = {
  'Analytics Gray': AppColorScheme(
    name: 'Analytics Gray',
    background: Color(0xFFECECEC),
    cardBg: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2A2A2A),
    textSecondary: Color(0xFF888888),
  ),
  'Soft Lilac': AppColorScheme(
    name: 'Soft Lilac',
    background: Color(0xFFF3F0F8),
    cardBg: Color(0xFFFFFBFF),
    textPrimary: Color(0xFF2E2833),
    textSecondary: Color(0xFF8B7E9A),
  ),
  'Warm Beige': AppColorScheme(
    name: 'Warm Beige',
    background: Color(0xFFF5F1EA),
    cardBg: Color(0xFFFFFBF5),
    textPrimary: Color(0xFF2A2A2A),
    textSecondary: Color(0xFF8A8A8A),
  ),
  'Cool Gray': AppColorScheme(
    name: 'Cool Gray',
    background: Color(0xFFF0F4F8),
    cardBg: Color(0xFFFAFCFF),
    textPrimary: Color(0xFF1A202C),
    textSecondary: Color(0xFF7A8195),
  ),
  'Soft Mint': AppColorScheme(
    name: 'Soft Mint',
    background: Color(0xFFF0F8F5),
    cardBg: Color(0xFFFAFFFD),
    textPrimary: Color(0xFF1A2E25),
    textSecondary: Color(0xFF7A9189),
  ),
  'Light Rose': AppColorScheme(
    name: 'Light Rose',
    background: Color(0xFFFFF5F7),
    cardBg: Color(0xFFFFFBFC),
    textPrimary: Color(0xFF2A1A1D),
    textSecondary: Color(0xFF9A7A81),
  ),
  'Dark Mode': AppColorScheme(
    name: 'Dark Mode',
    background: Color(0xFF1A1A1A),
    cardBg: Color(0xFF242424),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFF9A9A9A),
    isDark: true,
  ),
};

/// Refined Design Lab - Modern Card-Based Layouts
class HeaderPlayground extends StatefulWidget {
  const HeaderPlayground({super.key});

  @override
  State<HeaderPlayground> createState() => _HeaderPlaygroundState();
}

class _HeaderPlaygroundState extends State<HeaderPlayground> {
  String _selectedScheme = 'Analytics Gray';

  @override
  Widget build(BuildContext context) {
    final scheme = _schemes[_selectedScheme]!;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scheme.background,
        appBar: AppBar(
          title: const Text('Modern Card Design Lab'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Column(
              children: [
                // Color scheme selector
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _schemes.keys.map((name) {
                      final isSelected = name == _selectedScheme;
                      final schemeColor = _schemes[name]!;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedScheme = name);
                            }
                          },
                          backgroundColor: schemeColor.background,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : schemeColor.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : schemeColor.textSecondary.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Event Details'),
                    Tab(text: 'Registration'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _ModernEventDetails(scheme: scheme),
            _ModernRegistration(scheme: scheme),
          ],
        ),
      ),
    );
  }
}

/// Modern Card-Based Event Details Screen
class _ModernEventDetails extends StatelessWidget {
  final AppColorScheme scheme;
  
  const _ModernEventDetails({required this.scheme});
  
  @override
  Widget build(BuildContext context) {
    final beigeBackground = scheme.background;
    final cardWhite = scheme.cardBg;
    final orangePrimary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          // Main scrollable content
          ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40,
              left: 20,
              right: 20,
              bottom: 100,
            ),
            children: [
              const SizedBox(height: 16),
              
              // Event title
              Text(
                'The Lab Open',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              
              // Status badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF27AE60),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'OPEN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Event image card
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFF2C3E50),
                        child: const Icon(
                          Icons.golf_course,
                          size: 64,
                          color: Colors.white24,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Date/Time Card
              _InfoCard(
                backgroundColor: cardWhite,
                scheme: scheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: orangePrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: orangePrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'When',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Saturday, 10 Jan 2026',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: scheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: orangePrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.schedule_rounded,
                            color: orangePrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tee Times',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '08:00 - 10:30',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: scheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Course Card
              _InfoCard(
                backgroundColor: cardWhite,
                scheme: scheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: orangePrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: orangePrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'St Andrews (Old Course)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_rounded,
                            size: 18,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CourseDetail('Par', '72', Icons.flag_rounded, scheme),
                        _CourseDetail('Slope', '145', Icons.trending_up_rounded, scheme),
                        _CourseDetail('Rating', '73.5', Icons.star_rounded, scheme),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Registration Summary Card  
              _InfoCard(
                backgroundColor: cardWhite,
                scheme: scheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: orangePrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.groups_rounded,
                            color: orangePrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: scheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Competition Rules Card
              _InfoCard(
                backgroundColor: cardWhite,
                scheme: scheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: orangePrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: orangePrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Competition',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _RuleItem('Format', 'Stableford', orangePrimary, scheme),
                    _RuleItem('Handicap', '85% Allowance', orangePrimary, scheme),
                    _RuleItem('Grouping', 'Random 4-balls', orangePrimary, scheme),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Costs Card
              _InfoCard(
                backgroundColor: cardWhite,
                scheme: scheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: orangePrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.payments_rounded,
                            color: orangePrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Costs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _CostRow('Green Fee', '£85.00', scheme),
                    _CostRow('Breakfast', '£12.00', scheme),
                    _CostRow('Lunch', '£18.00', scheme),
                    _CostRow('Dinner', '£35.00', scheme),
                    const Divider(height: 20),
                    _CostRow('Total (All)', '£150.00', scheme, isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          
          // Minimal top bar
          _MinimalTopBar(beigeBackground: beigeBackground, orangePrimary: orangePrimary),
          
          // Bottom navigation
          _ModernBottomNav(cardWhite: cardWhite, orangePrimary: orangePrimary),
        ],
      ),
    );
  }
}

/// Modern Card-Based Registration Screen
class _ModernRegistration extends StatelessWidget {
  final AppColorScheme scheme;
  
  const _ModernRegistration({required this.scheme});
  
  @override
  Widget build(BuildContext context) {
    final beigeBackground = scheme.background;
    final cardWhite = scheme.cardBg;
    final orangePrimary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          // Main scrollable content
          ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40,
              left: 20,
              right: 20,
              bottom: 100,
            ),
            children: [
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Registration',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'The Lab Open',
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              
              // Metrics Card
              _InfoCard(
                backgroundColor: cardWhite,
                scheme: scheme,
                child: Column(
                  children: [
                    // Metrics Grid (Uniform 4 columns)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: ModernMetricStat(value: '24', label: 'Total', icon: Icons.groups_rounded, color: const Color(0xFF2C3E50), isCompact: true)),
                          const SizedBox(width: 12),
                          Expanded(child: ModernMetricStat(value: '20', label: 'Playing', icon: Icons.check_circle_rounded, color: const Color(0xFF27AE60), isCompact: true)),
                          const SizedBox(width: 12),
                          Expanded(child: ModernMetricStat(value: '3', label: 'Reserve', icon: Icons.hourglass_top_rounded, color: const Color(0xFFF39C12), isCompact: true)),
                          const SizedBox(width: 12),
                          Expanded(child: ModernMetricStat(value: '4', label: 'Guests', icon: Icons.person_add_rounded, color: Colors.purple, isCompact: true)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: ModernMetricStat(value: '6/12', label: 'Buggies', icon: Icons.electric_rickshaw_rounded, color: const Color(0xFF455A64), isCompact: true)),
                          const SizedBox(width: 12),
                          Expanded(child: ModernMetricStat(value: '18', label: 'Dinner', icon: Icons.restaurant_rounded, color: Colors.deepPurple, isCompact: true)),
                          const SizedBox(width: 12),
                          Expanded(child: ModernMetricStat(value: '0', label: 'Waitlist', icon: Icons.priority_high_rounded, color: const Color(0xFFC0392B), isCompact: true)),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    // STATUS BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '24/32 spaces',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: scheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(width: 1, height: 16, color: scheme.textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(width: 16),
                          Icon(Icons.lock_outline_rounded, size: 18, color: const Color(0xFFC0392B)),
                          const SizedBox(width: 8),
                          const Text(
                            'Registration Closed',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC0392B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Section Header
              Text(
                'Playing Members (20)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Member Cards
              _MemberCard(
                name: 'Joseph Martin',
                position: 1,
                status: 'Confirmed',
                statusColor: const Color(0xFF27AE60),
                hasBuggy: true,
                hasDinner: true,
                hasBreakfast: false,
                hasLunch: true,
                hasPaid: true,
                backgroundColor: cardWhite,
                scheme: scheme,
              ),
              const SizedBox(height: 8),
              _MemberCard(
                name: 'David Garcia',
                position: 2,
                status: 'Confirmed',
                statusColor: const Color(0xFF27AE60),
                hasBuggy: false,
                hasDinner: true,
                hasBreakfast: true,
                hasLunch: true,
                hasPaid: false,
                backgroundColor: cardWhite,
                scheme: scheme,
              ),
              const SizedBox(height: 8),
              _MemberCard(
                name: 'Mary Moore',
                position: 3,
                status: 'Confirmed',
                statusColor: const Color(0xFF27AE60),
                hasBuggy: true,
                hasDinner: false,
                hasBreakfast: false,
                hasLunch: true,
                hasPaid: true,
                backgroundColor: cardWhite,
                scheme: scheme,
              ),
              const SizedBox(height: 24),
              
              // Reserve Section
              Text(
                'Reserve (3)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _MemberCard(
                name: 'James Wilson',
                position: 21,
                status: 'Reserve',
                statusColor: const Color(0xFFF39C12),
                hasBuggy: false,
                hasDinner: true,
                hasBreakfast: false,
                hasLunch: false,
                hasPaid: false,
                backgroundColor: cardWhite,
                scheme: scheme,
              ),
              const SizedBox(height: 20),
            ],
          ),
          
          // Minimal top bar
          _MinimalTopBar(beigeBackground: beigeBackground, orangePrimary: orangePrimary),
          
          // Bottom navigation
          _ModernBottomNav(cardWhite: cardWhite, orangePrimary: orangePrimary, selectedIndex: 1),
        ],
      ),
    );
  }
}

// Reusable Components
class _InfoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final AppColorScheme scheme;

  const _InfoCard({required this.child, required this.backgroundColor, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CourseDetail extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final AppColorScheme scheme;

  const _CourseDetail(this.label, this.value, this.icon, this.scheme);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: scheme.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: scheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: scheme.textSecondary,
          ),
        ),
      ],
    );
  }
}


class _RuleItem extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final AppColorScheme scheme;

  const _RuleItem(this.label, this.value, this.accentColor, this.scheme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: scheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String amount;
  final AppColorScheme scheme;
  final bool isTotal;

  const _CostRow(this.label, this.amount, this.scheme, {this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              color: isTotal ? scheme.textPrimary : scheme.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: scheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


class _MemberCard extends StatelessWidget {
  final String name;
  final int position;
  final String status;
  final Color statusColor;
  final bool hasBuggy;
  final bool hasDinner;
  final bool hasBreakfast;
  final bool hasLunch;
  final bool hasPaid;
  final Color backgroundColor;
  final AppColorScheme scheme;

  const _MemberCard({
    required this.name,
    required this.position,
    required this.status,
    required this.statusColor,
    required this.hasBuggy,
    required this.hasDinner,
    required this.hasBreakfast,
    required this.hasLunch,
    required this.hasPaid,
    required this.backgroundColor,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasBuggy)
                _IconBadge(Icons.electric_rickshaw_rounded, const Color(0xFF2C3E50)),
              if (hasBreakfast)
                _IconBadge(Icons.free_breakfast_rounded, const Color(0xFFF39C12)),
              if (hasLunch)
                _IconBadge(Icons.lunch_dining_rounded, const Color(0xFF27AE60)),
              if (hasDinner)
                _IconBadge(Icons.restaurant_rounded, Colors.purple),
              if (hasPaid)
                _IconBadge(Icons.check_circle_rounded, const Color(0xFF27AE60))
              else
                _IconBadge(Icons.pending_rounded, const Color(0xFFF39C12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _MinimalTopBar extends StatelessWidget {
  final Color beigeBackground;
  final Color orangePrimary;

  const _MinimalTopBar({
    required this.beigeBackground,
    required this.orangePrimary,
  });
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// _TopBarIcon removed as it is no longer used

class _ModernBottomNav extends StatelessWidget {
  final Color cardWhite;
  final Color orangePrimary;
  final int selectedIndex;

  const _ModernBottomNav({
    required this.cardWhite,
    required this.orangePrimary,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavIcon(Icons.info_outline_rounded, selectedIndex == 0, orangePrimary),
                _BottomNavIcon(Icons.groups_rounded, selectedIndex == 1, orangePrimary),
                _BottomNavIcon(Icons.emoji_events_rounded, selectedIndex == 2, orangePrimary),
                _BottomNavIcon(Icons.bar_chart_rounded, selectedIndex == 3, orangePrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color primaryColor;

  const _BottomNavIcon(this.icon, this.selected, this.primaryColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: selected ? primaryColor : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: selected ? Colors.white : const Color(0xFF8A8A8A),
        size: 24,
      ),
    );
  }
}
