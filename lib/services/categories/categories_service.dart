// lib/services/category_service.dart

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qrdapp/services/auth/auth_storage.dart';
import 'dart:convert';

class CategoryService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.100.42:8080';
  static const int _merchantID = 1;

  static Future<List<dynamic>> fetchCategories() async {
    final response =
        await http.get(Uri.parse("$_baseUrl/categories/merchant/$_merchantID"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch categories");
    }
  }

  static Future<List<dynamic>> fetchProductsByCategory(
      String categoryId) async {
    final response =
        await http.get(Uri.parse("$_baseUrl/categories/$categoryId/products"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch products");
    }
  }

  // New method to fetch categories by location
  static Future<List<dynamic>> fetchCategoriesByLocation(
      String location) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/categories/location/$location'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch categories for location: $location');
    }
  }

  /// Add Category
  static Future<void> addCategory({
    required String name,
    required String description,
    required List<String?> location, // Changed to List<String?>
  }) async {
    final uri = Uri.parse('$_baseUrl/categories');
    final body = {
      'name': name,
      'description': description,
      'merchant_id': _merchantID,
      'location': jsonEncode(location), // Encode the list to JSON string
    };
    final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
    if (resp.statusCode != 200) {
      throw Exception('Failed to add category: ${resp.body}');
    }
  }

  /// Update Category
  static Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    required List<String?> location, // Changed to List<String?>
  }) async {
    final uri = Uri.parse('$_baseUrl/categories/$categoryId');
    final body = {
      'name': name,
      'description': description,
      'location': jsonEncode(location), // Encode the list to JSON string
    };
    final resp = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
    if (resp.statusCode != 200) {
      throw Exception('Failed to update category: ${resp.body}');
    }
  }
  // Delete Category
  static Future<void> deleteCategory({
    required int categoryId,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/categories/$categoryId');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }
   //// Fetches categories by merchant ID.
  static Future<List<Map<String, dynamic>>> fetchCategoriesByMerchantId() async {
    final int? merchantId =
        await SecureStorageService.getUserId(); // Get merchant ID dynamically
    if (merchantId == null) {
      throw Exception("Merchant ID is null");
    }
    final response =
        await http.get(Uri.parse("$_baseUrl/categories/merchant/$merchantId"));
    if (response.statusCode == 200) {
      final dynamic decodedBody = jsonDecode(response.body);
      if (decodedBody is List) {
        // Convert each item in the list to a Map<String, dynamic>
        List<Map<String, dynamic>> result = [];
        for (var item in decodedBody) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          } else {
            print("Error: Item is not a Map<String,dynamic>: $item");
            throw Exception(
                'Unexpected data type from server. Expected a List<Map<String,dynamic>>');
          }
        }
        return result;
      } else {
        print("Error: Expected a List, but got: $decodedBody");
        throw Exception('Unexpected data type from server. Expected a List.');
      }
    } else {
      throw Exception(
          "Failed to fetch categories by merchant: ${response.statusCode}");
    }
  }
}