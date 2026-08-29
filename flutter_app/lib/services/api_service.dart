import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/vendor.dart';

class ApiService {
  // Points at backend/. Use 10.0.2.2 for the Android emulator (localhost of
  // the host machine), your machine's LAN IP for a physical device, or the
  // deployed Render URL in production.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  Future<List<Product>> fetchProducts({String? category, String? search}) async {
    final params = <String, String>{};
    if (category != null && category != 'All') params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/api/products').replace(queryParameters: params);
    final response = await http.get(uri);
    _checkOk(response);
    final list = jsonDecode(response.body) as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Vendor>> fetchVendors() async {
    final response = await http.get(Uri.parse('$baseUrl/api/vendors'));
    _checkOk(response);
    final list = jsonDecode(response.body) as List;
    return list.map((e) => Vendor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> placeOrder({
    required String customerName,
    required String customerPhone,
    required String fulfillment,
    String? deliveryAddress,
    required String paymentMethod,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerName': customerName,
        'customerPhone': customerPhone,
        'fulfillment': fulfillment,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'notes': notes,
        'items': items,
      }),
    );
    _checkOk(response, allowed: {200, 201});
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _checkOk(http.Response response, {Set<int> allowed = const {200}}) {
    if (!allowed.contains(response.statusCode)) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Request failed (${response.statusCode})');
    }
  }
}
