// lib/services/products/products_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qrdapp/services/auth/auth_storage.dart'; // For getting the merchant ID

class ProductService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.100.42:8080'; // e.g. http://192.168.1.100:8080

  // Add a new product
  static Future<void> addProduct(
      {required String name,
      required String description,
      required double price,
      required int categoryId,
      required String location}) async {
    final int? merchantId = await SecureStorageService.getUserId();
    if (merchantId == null) {
      throw Exception('Merchant ID not found. Please log in.');
    }

    final Uri url = Uri.parse('$baseUrl/products');
    final Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'price': price,
      'merchant_id': merchantId,
      'category_id': categoryId,
      'location': location, // No change here, the encoding happens in the screen
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  // Get all products by merchant ID
  static Future<List<dynamic>> getProductsByMerchant(String merchantId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/products/merchant/$merchantId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    return [];
  }

  // Get all products for a merchant
  static Future<List<Map<String, dynamic>>> getProductsByMerchantId() async {
    final int? merchantId = await SecureStorageService.getUserId();
    if (merchantId == null) {
      throw Exception('Merchant ID not found. Please log in.');
    }
    final Uri url = Uri.parse('$baseUrl/products/merchant/$merchantId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products for merchant: ${response.body}');
    }
    final List<dynamic> productList = json.decode(response.body);
    return List<Map<String, dynamic>>.from(productList);
  }

  // Get product by ID
  static Future<Map<String, dynamic>?> getProductById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/products/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

// Update an existing product
  static Future<void> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required String location,
  }) async {
    final Uri url = Uri.parse('$baseUrl/product/$productId');
    final Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'location': location, // No change here, the encoding happens in the screen
    };
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  // Delete a product
  static Future<void> deleteProduct({required int productId}) async {
    final Uri url = Uri.parse('$baseUrl/product/$productId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  // New method to fetch products by location and category
  static Future<List<dynamic>> fetchProductsByLocationAndCategory(
      String location, String categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/$location/categories/$categoryId/products'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
          'Failed to fetch products for location: $location and category: $categoryId');
    }
  }

   // New method to fetch products by location
  static Future<List<dynamic>> fetchProductsByLocation(String location) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/$location/products'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch products for location: $location');
    }
  }
}