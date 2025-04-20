import 'package:flutter/material.dart';

class PopularProductsWidget extends StatelessWidget {
  final List<dynamic> categories;
  final Map<String, List<dynamic>> categoryProducts;
  final void Function(dynamic product) onTap;

  const PopularProductsWidget({super.key, required this.categories, required this.categoryProducts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final products = categoryProducts[categories[0]['ID']?.toString()] ?? [];
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          final name = p['name'] ?? 'No name';
          final price = p['price']?.toString() ?? '0';
          return GestureDetector(
            onTap: () => onTap(p),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: Icon(Icons.image, size: 60)),
                  const SizedBox(height: 8),
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Ksh $price", style: const TextStyle(color: Colors.green)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
