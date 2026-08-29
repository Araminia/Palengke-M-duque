import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);

  int get count => _lines.fold(0, (sum, line) => sum + line.quantity);

  double get total => _lines.fold(0, (sum, line) => sum + line.lineTotal);

  void add(Product product, [int quantity = 1]) {
    final existing = _lines.where((l) => l.product.id == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _lines.add(CartLine(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _lines.removeWhere((l) => l.product.id == productId);
    } else {
      final line = _lines.where((l) => l.product.id == productId).firstOrNull;
      if (line != null) line.quantity = quantity;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _lines.removeWhere((l) => l.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
