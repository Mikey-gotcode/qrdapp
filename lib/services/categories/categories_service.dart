// lib/services/category_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryService {
  static const String _baseUrl = "http://192.168.100.42:8080";
  static const int _merchantID = 1;

  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse("$_baseUrl/categories/merchant/$_merchantID"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch categories");
    }
  }

  static Future<List<dynamic>> fetchProductsByCategory(String categoryId) async {
    final response = await http.get(Uri.parse("$_baseUrl/categories/$categoryId/products"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch products");
    }
  }
}
