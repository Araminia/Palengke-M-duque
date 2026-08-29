import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../theme.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback? onTap;
  const VendorCard({super.key, required this.vendor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(aspectRatio: 1.6, child: Image.network(vendor.image, fit: BoxFit.cover)),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.marketGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Open', style: TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text('Stall ${vendor.stall} · ${vendor.section}',
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: AppColors.marketGold),
                    const SizedBox(width: 4),
                    Text('${vendor.rating} · ${vendor.products} products',
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
