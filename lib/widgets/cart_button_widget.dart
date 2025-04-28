import 'package:flutter/material.dart';
import 'package:qrdapp/services/auth/auth_storage.dart';
import 'package:qrdapp/services/cart/cart_service.dart';
//import 'package:qrdapp/models/cart_item.dart';

/// A cart icon button with badge showing item count
class CartButtonWidget extends StatefulWidget {
  const CartButtonWidget({super.key});

  @override
  State<CartButtonWidget> createState() => _CartButtonWidgetState();
}

class _CartButtonWidgetState extends State<CartButtonWidget> {
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();
  }

  Future<void> _loadCartItemCount() async {
    final userIdStr = await SecureStorageService.getUserId();
    if (userIdStr != null) {
      final userId = userIdStr;
      final cartItems = await CartService.getCartItems(userId);
      setState(() {
        _itemCount = cartItems.length;
      });
        }
  }

  Future<void> _navigateToCart(BuildContext context) async {
    final userId = await SecureStorageService.getUserId();
    debugPrint('UserID in CartButton: $userId');

    if (userId != null) {
      Navigator.pushNamed(context, '/cart', arguments: {'userId': userId});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => _navigateToCart(context),
        ),
        if (_itemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$_itemCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
