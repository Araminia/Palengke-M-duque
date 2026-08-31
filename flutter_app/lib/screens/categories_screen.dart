import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/page_container.dart';
import '../widgets/product_card.dart';
import '../widgets/responsive_nav.dart';
import 'cart_screen.dart';
import 'home_screen.dart' show kCategories, HomeScreen;
import 'vendors_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _api = ApiService();
  String _category = 'All';
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchProducts();
  }

  void _select(String category) {
    setState(() {
      _category = category;
      _future = _api.fetchProducts(category: category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveNav(
        title: 'All Categories',
        currentRoute: 'categories',
        homeBuilder: () => const HomeScreen(),
        categoriesBuilder: () => const CategoriesScreen(),
        vendorsBuilder: () => const VendorsScreen(),
        cartBuilder: () => const CartScreen(),
      ),
      body: SingleChildScrollView(
        child: PageContainer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = gridColumnsForWidth(constraints.maxWidth);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final item = kCategories[i];
                        return ChoiceChip(
                          label: Text(item),
                          selected: item == _category,
                          onSelected: (_) => _select(item),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<Product>>(
                    future: _future,
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
                          child: Center(child: Text('No products found.')),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
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
      ),
    );
  }
}
