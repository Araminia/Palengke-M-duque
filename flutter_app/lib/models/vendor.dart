class Vendor {
  final String id;
  final String name;
  final String stall;
  final String section;
  final List<String> categories;
  final double rating;
  final int products;
  final String image;
  final String description;

  Vendor({
    required this.id,
    required this.name,
    required this.stall,
    required this.section,
    required this.categories,
    required this.rating,
    required this.products,
    required this.image,
    required this.description,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      name: json['name'] as String,
      stall: json['stall'] as String,
      section: json['section'] as String,
      categories: (json['categories'] as List).map((e) => e as String).toList(),
      rating: (json['rating'] as num).toDouble(),
      products: json['products'] as int,
      image: json['image'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}
