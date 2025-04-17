// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../customer/customer_dashboard.dart';
import '../merchant/merchant_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    print(_passwordController.text);

    try {
      final result = await AuthService.login(
        _emailController.text,
        _passwordController.text,
      );
      print('Login successful: $result'); // Logs the whole result

      

      if (result['message'] == 'Login successful') {
        final role = result['role'];
        if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomerDashboard()),
          );
        } else if (role == 'merchant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MerchantDashboard()),
          );
        } else {
          setState(() => _errorMessage = 'Unknown user role');
        }
      } else {
        setState(() => _errorMessage = 'Invalid credentials');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Login failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
