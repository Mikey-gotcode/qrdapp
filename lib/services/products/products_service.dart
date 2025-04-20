// lib/services/products/products_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String baseUrl = "http://192.168.100.42:8080"; // e.g. http://192.168.1.100:8080

  // Create a new product
  static Future<Map<String, dynamic>?> createProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/products"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Get all products by merchant ID
  static Future<List<dynamic>> getProductsByMerchant(String merchantId) async {
    final response = await http.get(Uri.parse("$baseUrl/products/merchant/$merchantId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    return [];
  }

  // Get product by ID
  static Future<Map<String, dynamic>?> getProductById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/products/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  // Update product
  static Future<Map<String, dynamic>?> updateProduct(String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/products/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Delete product
  static Future<bool> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/products/$id"));

    return response.statusCode == 200;
  }
}
