import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/api_service.dart';
import '../widgets/vendor_card.dart';

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
      appBar: AppBar(title: const Text('Our Market Vendors')),
      body: FutureBuilder<List<Vendor>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load vendors.\n${snapshot.error}'));
          }
          final vendors = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vendors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, i) => VendorCard(vendor: vendors[i]),
          );
        },
      ),
    );
  }
}
