import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Replace with your actual API base URL
final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.100.42:8080';

class OrderService {
  Future<List<Order>> fetchOrdersByStatus(int userId, String status) async {
    final Uri uri = Uri.parse('$baseUrl/orders/status');

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('orders')) {
          final List<dynamic> orderData = responseData['orders'];
          return orderData.map((json) => Order.fromJson(json)).toList();
        } else {
          print('Error: "orders" key not found in response body: ${response.body}');
          return [];
        }
      } else {
        print(
            'Failed to fetch orders (status: $status). Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch orders (status: $status)');
      }
    } catch (error) {
      print('Error fetching orders (status: $status): $error');
      throw Exception('Error fetching orders (status: $status): $error');
    }
  }

   Future<List<Order>> fetchOrdersByCustomerIDandStatus(int userId, String status) async {
    final Uri uri = Uri.parse('$baseUrl/users/$userId/orders?status=$status');

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('orderHistory')) {
          final List<dynamic> orderData = responseData['orderHistory'];
          return orderData.map((json) => Order.fromJson(json)).toList();
        } else {
          print('Error: "orderHistory" key not found in response body: ${response.body}');
          return [];
        }
      } else {
        print(
            'Failed to fetch orders for user (ID: $userId) with status: $status. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch orders for user (ID: $userId) with status: $status');
      }
    } catch (error) {
      print('Error fetching orders for user (ID: $userId) with status: $status: $error');
      throw Exception('Error fetching orders for user (ID: $userId) with status: $status: $error');
    }
  }

  Future<Order> fetchOrderById(int orderId) async {
    final Uri uri = Uri.parse('$baseUrl/orders/$orderId');

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Order.fromJson(responseData);
      } else {
        print('Failed to fetch order (ID: $orderId). Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch order (ID: $orderId)');
      }
    } catch (error) {
      print('Error fetching order (ID: $orderId): $error');
      throw Exception('Error fetching order (ID: $orderId): $error');
    }
  }



  

  Future<Order> acceptOrder(int orderId) async {
    final Uri uri = Uri.parse('$baseUrl/orders/$orderId/accept');

    try {
      final response = await http.patch(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Order(
          id: responseData['orderId'], // Use 'orderId' from response
          userId: 0, // These values might not be in the accept/cancel response
          total: 0.0,
          createdAt: 0,
          status: responseData['status'],
          location: '',
          items: [],
        );
      } else {
        print('Failed to accept order (ID: $orderId). Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to accept order (ID: $orderId)');
      }
    } catch (error) {
      print('Error accepting order (ID: $orderId): $error');
      throw Exception('Error accepting order (ID: $orderId): $error');
    }
  }

  Future<Order> cancelOrder(int orderId) async {
    final Uri uri = Uri.parse('$baseUrl/orders/$orderId/cancel');

    try {
      final response = await http.patch(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Order(
          id: responseData['orderId'], // Use 'orderId' from response
          userId: 0, // These values might not be in the accept/cancel response
          total: 0.0,
          createdAt: 0,
          status: responseData['status'],
          location: '',
          items: [],
        );
      } else {
        print('Failed to cancel order (ID: $orderId). Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to cancel order (ID: $orderId)');
      }
    } catch (error) {
      print('Error cancelling order (ID: $orderId): $error');
      throw Exception('Error cancelling order (ID: $orderId): $error');
    }
  }

  Future<Order> completeOrder(int orderId) async {
    final Uri uri = Uri.parse('$baseUrl/orders/$orderId/complete');

    try {
      final response = await http.patch(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Order(
          id: responseData['orderId'], // Use 'orderId' from response
          userId: 0, // These values might not be in the complete response
          total: 0.0,
          createdAt: 0,
          status: responseData['status'],
          location: '',
          items: [],
        );
      } else {
        print('Failed to complete order (ID: $orderId). Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to complete order (ID: $orderId)');
      }
    } catch (error) {
      print('Error completing order (ID: $orderId): $error');
      throw Exception('Error completing order (ID: $orderId): $error');
    }
  }

  Future<List<Order>> viewOrderHistory(int userId) async {
    final Uri uri = Uri.parse('$baseUrl/users/$userId/orders');

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('orderHistory')) {
          final List<dynamic> orderData = responseData['orderHistory'];
          return orderData.map((json) => Order.fromJson(json)).toList();
        } else {
          print('Error: "orderHistory" key not found in response body: ${response.body}');
          return [];
        }
      } else {
        print('Failed to fetch order history for user (ID: $userId). Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch order history for user (ID: $userId)');
      }
    } catch (error) {
      print('Error fetching order history for user (ID: $userId): $error');
      throw Exception('Error fetching order history for user (ID: $userId): $error');
    }
  }
}

class Order {
  final int id;
  final int userId;
  final double total;
  final int createdAt;
  final String status;
  final String location;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.total,
    required this.createdAt,
    required this.status,
    required this.location,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['ID'] ?? json['orderId'], // Check for both 'ID' and 'orderId'
      userId: json['userId'],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? 0,
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((itemJson) => OrderItem.fromJson(itemJson))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['ID'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}