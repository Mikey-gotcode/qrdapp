import 'package:flutter/material.dart';

class CategoryListWidget extends StatelessWidget {
  final List<dynamic> categories;
  final void Function(dynamic cat) onTap;

  const CategoryListWidget({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (_, i) {
            final cat = categories[i];
            return GestureDetector(
              onTap: () => onTap(cat),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.orange[100],
                      child: const Icon(Icons.category),
                    ),
                    const SizedBox(height: 4),
                    Text(cat['name'] ?? 'No name',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
