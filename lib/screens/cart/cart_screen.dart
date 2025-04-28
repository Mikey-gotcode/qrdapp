import 'package:flutter/material.dart';
import 'package:qrdapp/models/cart_item.dart';
import 'package:qrdapp/services/cart/cart_service.dart';
import 'package:qrdapp/services/products/products_service.dart';

/// Combines a cart entry with its product details for display
class CartDisplayItem {
  final int productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  CartDisplayItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartDisplayItem>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<List<CartDisplayItem>> _loadCart() async {
    final cartItems = await CartService.getCartItems(widget.userId);

    final List<CartDisplayItem> displayItems = [];
    for (final ci in cartItems) {
      final productMap =
          await ProductService.getProductById(ci.productId.toString()) ?? {};
      final name = productMap['name'] as String? ?? 'Unnamed Product';
      final price = (productMap['price'] as num?)?.toDouble() ?? 0.0;
      final imageUrl = productMap['imageUrl'] as String? ?? '';

      displayItems.add(CartDisplayItem(
        productId: ci.productId!,
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: ci.quantity,
      ));
    }
    return displayItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<CartDisplayItem>>(
        future: _cartFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final total = items.fold<double>(
              0, (sum, item) => sum + item.price * item.quantity);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (ctx, index) {
                    final it = items[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                it.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ksh ${it.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: it.quantity > 1
                                            ? () => _updateQuantity(
                                                  it.productId,
                                                  it.quantity - 1,
                                                )
                                            : null,
                                      ),
                                      Text(
                                        '${it.quantity}',
                                        style:
                                            const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        onPressed: () => _updateQuantity(
                                          it.productId,
                                          it.quantity + 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _removeItem(it.productId),
                                    child: const Text(
                                      'Remove',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ksh ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _checkout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removeItem(int productId) {
    CartService.deleteCartItem(productId).then((_) => setState(() {
          _cartFuture = _loadCart();
        }));
  }

  void _updateQuantity(int productId, int newQty) {
    CartService.updateQuantity(productId, newQty).then((_) => setState(() {
          _cartFuture = _loadCart();
        }));
  }

  void _checkout() {
    CartService.checkoutCart(widget.userId).then((total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Checkout complete! Total: Ksh ${total.toStringAsFixed(2)}'),
        ),
      );
      setState(() {
        _cartFuture = _loadCart();
      });
    }).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed')),
      );
    });
  }
}
