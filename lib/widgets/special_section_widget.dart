import 'package:flutter/material.dart';

class SpecialSectionWidget extends StatelessWidget {
  final List<dynamic> categories;
  final Map<String, List<dynamic>> categoryProducts;
  final void Function(dynamic cat) onTap;

  const SpecialSectionWidget(
      {super.key, required this.categories,
      required this.categoryProducts,
      required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (_, i) {
            final cat = categories[i];
            final products = categoryProducts[cat['ID']?.toString()] ?? [];
            return GestureDetector(
              onTap: () => onTap(cat),
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat['name'] ?? 'No name',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${products.length} products',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
