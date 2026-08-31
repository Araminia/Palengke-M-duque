import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/api_service.dart';
import '../widgets/page_container.dart';
import '../widgets/responsive_nav.dart';
import '../widgets/vendor_card.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart' show HomeScreen;

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final _api = ApiService();
  late Future<List<Vendor>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveNav(
        title: 'Our Market Vendors',
        currentRoute: 'vendors',
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
              return FutureBuilder<List<Vendor>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: Text('Could not load vendors.\n${snapshot.error}', textAlign: TextAlign.center)),
                    );
                  }
                  final vendors = snapshot.data ?? [];
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vendors.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, i) => VendorCard(vendor: vendors[i]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
