import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qrdapp/models/cart_item.dart';

class CartService {
  static const String _baseUrl = 'http://192.168.100.42:8080';

  /// Add an item to the user's cart
  /// Expects JSON body: { userId, productId, quantity }
  static Future<void> addToCart(int userId, CartItem item) async {
    final url = Uri.parse('$_baseUrl/cart/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'productId': item.productId,
        'quantity': item.quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add item to cart');
    }
  }

  /// Get the user's current cart items
  /// Expects query param: ?userId=...
  static Future<List<CartItem>> getCartItems(int userId) async {
    final url = Uri.parse('$_baseUrl/cart?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch cart');
    }

    final data = jsonDecode(response.body);
    // Assuming the Go controller returns JSON with `Items` field
    final items = data['Items'] ?? data['items'] ?? [];

    return List<CartItem>.from(
      items.map((item) => CartItem.fromJson(item)),
    );
  }

  /// Delete a specific item from the user's cart
  /// Expects JSON body: { productId }
  static Future<void> deleteCartItem(int productId) async {
    final url = Uri.parse('$_baseUrl/cart/delete');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item from cart');
    }
  }

  /// Update the quantity of a specific item in the cart
  /// Expects JSON body: { productId, quantity }
  static Future<void> updateQuantity(int productId, int quantity) async {
    final url = Uri.parse('$_baseUrl/cart/update-quantity');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item quantity');
    }
  }

  /// Checkout and clear the cart, return the total amount
  /// Expects query param: ?userId=...
  static Future<double> checkoutCart(int userId) async {
    final url = Uri.parse('$_baseUrl/cart/checkout?userId=$userId');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Checkout failed');
    }

    final data = jsonDecode(response.body);
    return (data['total'] as num).toDouble();
  }
}
