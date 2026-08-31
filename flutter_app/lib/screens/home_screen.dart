import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import '../services/api_service.dart';
import '../state/cart_provider.dart';
import '../theme.dart';
import '../widgets/page_container.dart';
import '../widgets/responsive_nav.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_card.dart';
import '../widgets/vendor_card.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'vendors_screen.dart';

const kCategories = [
  'All', 'Vegetables', 'Fruits', 'Meat', 'Fish and Seafood', 'Poultry', 'Eggs',
  'Rice and Grains', 'Spices and Seasonings', 'Dry Goods', 'Beverages', 'Other Market Products',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();
  String _category = 'All';
  late Future<List<Product>> _productsFuture;
  late Future<List<Vendor>> _vendorsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _api.fetchProducts();
    _vendorsFuture = _api.fetchVendors();
  }

  void _reload() {
    setState(() {
      _productsFuture = _api.fetchProducts(category: _category, search: _searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveNav(
        currentRoute: 'home',
        homeBuilder: () => const HomeScreen(),
        categoriesBuilder: () => const CategoriesScreen(),
        vendorsBuilder: () => const VendorsScreen(),
        cartBuilder: () => const CartScreen(),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width >= 768
          ? null
          : AppBottomNav(
              currentRoute: 'home',
              homeBuilder: () => const HomeScreen(),
              browseBuilder: () => const CategoriesScreen(),
              vendorsBuilder: () => const VendorsScreen(),
              basketBuilder: () => const CartScreen(),
            ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Hero(controller: _searchController, onSearch: _reload),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
                  return Transform.translate(
                    offset: Offset(0, isDesktop ? -48 : -32),
                    child: PageContainer(
                      maxWidth: 1000,
                      child: LayoutBuilder(
                        builder: (context, inner) {
                          final wide = inner.maxWidth >= 640;
                          final cards = const [
                            _FeatureCard(icon: Icons.shopping_basket_outlined, title: 'Madaling mamili', copy: 'Lahat ng suki sa isang app'),
                            _FeatureCard(icon: Icons.pedal_bike_outlined, title: 'Pickup o delivery', copy: 'Ikaw ang pumili'),
                            _FeatureCard(icon: Icons.verified_user_outlined, title: 'Trusted vendors', copy: 'Verified market stalls'),
                          ];
                          if (wide) {
                            return Row(
                              children: [
                                for (final c in cards) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c)),
                              ],
                            );
                          }
                          return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 8), child: c)]);
                        },
                      ),
                    ),
                  );
                },
              ),
              PageContainer(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = gridColumnsForWidth(constraints.maxWidth);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          kicker: 'FRESH TODAY',
                          title: 'Shop by Category',
                          onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: kCategories.take(8).length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final item = kCategories[i];
                              final selected = item == _category;
                              return ElevatedButton(
                                onPressed: () {
                                  setState(() => _category = item);
                                  _reload();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selected ? AppColors.primary : AppColors.card,
                                  foregroundColor: selected ? AppColors.primaryForeground : AppColors.foreground,
                                  side: selected ? null : const BorderSide(color: AppColors.border),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                ),
                                child: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          kicker: 'FROM LOCAL STALLS',
                          title: _searchController.text.isEmpty ? 'Popular Products' : 'Results for "${_searchController.text}"',
                        ),
                        const SizedBox(height: 14),
                        FutureBuilder<List<Product>>(
                          future: _productsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: Text('Could not load products.\n${snapshot.error}', textAlign: TextAlign.center)),
                              );
                            }
                            final products = snapshot.data ?? [];
                            if (products.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: Text('No products found. Try another search.')),
                              );
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: products.take(10).length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.68,
                              ),
                              itemBuilder: (context, i) => ProductCard(product: products[i]),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
              Container(
                color: AppColors.marketCream,
                child: PageContainer(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            kicker: 'MEET YOUR SUKI',
                            title: 'Shop by Vendor',
                            onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorsScreen())),
                          ),
                          const SizedBox(height: 14),
                          FutureBuilder<List<Vendor>>(
                            future: _vendorsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (snapshot.hasError) {
                                return const SizedBox.shrink();
                              }
                              final vendors = (snapshot.data ?? []).take(3).toList();
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: vendors.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.3,
                                ),
                                itemBuilder: (context, i) => VendorCard(vendor: vendors[i]),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  const _Hero({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 460),
      decoration: const BoxDecoration(color: AppColors.foreground),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1400',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.foreground.withOpacity(0.92),
                  AppColors.foreground.withOpacity(0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: const [
                  Icon(Icons.place_outlined, size: 14, color: AppColors.marketCream),
                  SizedBox(width: 6),
                  Text('BAGONG PALENGKE NG SAN JOSE', style: TextStyle(
                      color: AppColors.marketCream, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ]),
                const SizedBox(height: 12),
                const Text('Sariwang pagkain,', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32, height: 1.1)),
                const Text('diretso sa palengke.', style: TextStyle(
                    color: AppColors.marketGold, fontWeight: FontWeight.bold, fontSize: 32, height: 1.1)),
                const SizedBox(height: 12),
                Text(
                  'Mamili mula sa mga suki mong tindero. Fresh, affordable, and ready for pickup or delivery.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onSubmitted: (_) => onSearch(),
                          decoration: const InputDecoration(
                            hintText: 'Hanapin ang kamatis, bangus, bigas...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onSearch,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String copy;
  const _FeatureCard({required this.icon, required this.title, required this.copy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(copy, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.kicker, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kicker, style: const TextStyle(
            color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ],
    );

    if (onViewAll == null) return header;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        header,
        TextButton.icon(
          onPressed: onViewAll,
          icon: const Text('View all', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          label: const Icon(Icons.arrow_forward, size: 16),
          style: TextButton.styleFrom(foregroundColor: AppColors.foreground),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.foreground,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final children = [
              _FooterColumn(
                title: 'Palengke.ph',
                titleColor: Colors.white,
                lines: const ['Ang bagong paraan ng pamamalengke.'],
              ),
              _FooterColumn(
                title: 'Bagong Palengke ng San Jose',
                titleColor: Colors.white,
                lines: const ['Open daily · 5:00 AM–7:00 PM', 'San Jose City, Nueva Ecija'],
              ),
              _FooterColumn(
                title: 'For vendors',
                titleColor: Colors.white,
                lines: const ['Grow your stall online and reach more suki.'],
              ),
            ];
            if (wide) {
              return Row(children: [for (final c in children) Expanded(child: c)]);
            }
            return Column(children: [for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 20), child: c)]);
          },
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<String> lines;
  const _FooterColumn({required this.title, required this.titleColor, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 6),
        for (final line in lines)
          Text(line, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11, height: 1.5)),
      ],
    );
  }
}
