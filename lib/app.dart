import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_dashboard.dart';
import 'screens/cart/cart_screen.dart';
import 'services/auth/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
            builder: (context) => const CustomerDashboardScreen(),
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
      Navigator.pushReplacementNamed(context, '/dashboard');
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
