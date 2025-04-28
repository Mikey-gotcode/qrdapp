import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_dashboard.dart';
import 'screens/cart/cart_screen.dart';
import 'services/auth/auth_service.dart';
import 'services/auth/auth_storage.dart'; // Import SecureStorageService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == '/cart') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CartScreen(userId: args['userId']),
          );
        } else if (settings.name == '/dashboard') {
          return MaterialPageRoute(
            builder: (context) => const DashboardDecider(),
          );
        } else if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        }
        return null;
      },
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool isLoggedIn = await AuthService.isLoggedIn();

    // Delay to simulate splash time (optional)
    await Future.delayed(const Duration(seconds: 1));

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardDecider()), // Use MaterialPageRoute
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Splash or loading indicator
      ),
    );
  }
}

class DashboardDecider extends StatefulWidget {
  const DashboardDecider({super.key});

  @override
  State<DashboardDecider> createState() => _DashboardDeciderState();
}

class _DashboardDeciderState extends State<DashboardDecider> {
  int? _customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final userId = await SecureStorageService.getUserId();
    setState(() {
      _customerId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_customerId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return CustomerDashboardScreen(customerId: _customerId!);
    }
  }
}