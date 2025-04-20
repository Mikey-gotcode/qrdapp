// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class AuthService {
  static const baseUrl =
      'http://192.168.100.42:8080'; // Replace with your actual endpoint

static Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    body: jsonEncode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final userId = data['user']['id'];
    final token = data['token'];

    await SecureStorageService.saveToken(token);
    await SecureStorageService.saveUserId(userId);

    return {
      'message': data['message'],
      'role': data['role'],
      'token': token,
      'userId': userId,
    };
  } else {
    final data = jsonDecode(response.body);
    return {
      'message': 'error',
      'error': data['error'] ?? 'Invalid credentials',
    };
  }
}





  static Future<bool> isLoggedIn() async {
    final token = await SecureStorageService.getToken();
    return token != null;
  }

  static Future<void> logout() async {
    await SecureStorageService.clearToken();
  }
}
