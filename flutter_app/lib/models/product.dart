class Product {
  final String id;
  final String vendorId;
  final String name;
  final double price;
  final String unit;
  final int stock;
  final String category;
  final String image;
  final String description;
  final String vendor;
  final String stall;

  Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.unit,
    required this.stock,
    required this.category,
    required this.image,
    required this.description,
    required this.vendor,
    required this.stall,
  });

  bool get soldOut => stock <= 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      vendorId: json['vendorId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      stock: json['stock'] as int,
      category: json['category'] as String,
      image: json['image'] as String,
      description: json['description'] as String? ?? '',
      vendor: json['vendor'] as String,
      stall: json['stall'] as String,
    );
  }
}
