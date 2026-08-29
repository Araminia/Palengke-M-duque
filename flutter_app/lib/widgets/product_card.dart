import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../state/cart_provider.dart';
import '../theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final money = '₱${product.price.toStringAsFixed(2)}';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: Image.network(product.image, fit: BoxFit.cover),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: _Tag(text: product.category),
              ),
              if (product.soldOut)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.75),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Text(
                      'Sold Out',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: money, style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    TextSpan(text: ' per ${product.unit}', style: const TextStyle(
                        color: AppColors.mutedForeground, fontSize: 11)),
                  ]),
                ),
                const SizedBox(height: 2),
                Text('${product.vendor} · Stall ${product.stall}', maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.soldOut
                        ? null
                        : () {
                            context.read<CartProvider>().add(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} added to basket'), duration: const Duration(seconds: 1)),
                            );
                          },
                    child: Text(product.soldOut ? 'Sold Out' : 'Add to Basket'),
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

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
    );
  }
}
