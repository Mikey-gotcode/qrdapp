// lib/screens/products/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:qrdapp/services/products/products_service.dart';
import 'package:qrdapp/services/cart/cart_service.dart'; // Add this at the top
import 'package:qrdapp/models/cart_item.dart';

/// Product detail screen with custom UI, quantity selector, and Add to Cart
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>?> _productFuture;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    debugPrint('Fetching product details for id: ${widget.productId}');
    _productFuture = ProductService.getProductById(widget.productId);
  }

  void _increment() {
    setState(() {
      _quantity += 1;
    });
    debugPrint('Quantity increased to $_quantity');
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity -= 1;
      });
      debugPrint('Quantity decreased to $_quantity');
    }
  }

  void _addToCart() async {
    try {
      final product = await _productFuture;

      if (product == null) return;

      final cartItem = CartItem(
        productId: int.parse(widget.productId),
        name: product['name'],
        price: product['price'].toDouble(),
        quantity: _quantity,
      );

      const userId = 1; // TODO: Replace with actual logged-in user ID

      await CartService.addToCart(userId, cartItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $_quantity item(s) to cart')),
        );
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add item to cart')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error loading product'));
          }

          final product = snapshot.data!;
          final name = product['name'] ?? '';
          final description = product['description'] ?? '';
          final price = product['price']?.toStringAsFixed(2) ?? '0.00';

          return SafeArea(
            child: Column(
              children: [
                // Top bar with back and rating
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 28),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            product['rating']?.toString() ?? '0',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Product image
                Expanded(
                  child: Center(
                    child: product['imageUrl'] != null
                        ? Image.network(product['imageUrl'],
                            fit: BoxFit.contain)
                        : const Icon(Icons.image,
                            size: 150, color: Colors.grey),
                  ),
                ),

                // Name, description & quantity/add to cart
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and favorite
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border,
                                color: Colors.red),
                            onPressed: () => debugPrint('Favorite tapped'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => debugPrint('See more pressed'),
                          child: const Text('See More Detail >'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price and quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ksh $price',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _decrement,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                onPressed: _increment,
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Add to Cart button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
