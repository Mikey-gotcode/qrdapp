import 'package:flutter/material.dart';
import 'package:qrdapp/services/auth/auth_storage.dart';

/// A cart icon button with badge showing item count
class CartButtonWidget extends StatelessWidget {
  final int itemCount;

  const CartButtonWidget({super.key, this.itemCount = 0});

  Future<void> _navigateToCart(BuildContext context) async {
    final userId = await SecureStorageService.getUserId();
     debugPrint('UserID in CartButton: $userId');


    if (userId != null) {
      Navigator.pushNamed(context, '/cart', arguments: {'userId': int.tryParse(userId)});
    } else {
      // Optional: Show a message or redirect to login
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
        if (itemCount > 0)
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
                '$itemCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
