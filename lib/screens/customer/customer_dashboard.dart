import 'package:flutter/material.dart';
import 'package:qrdapp/widgets/search_bar_widget.dart';
import 'package:qrdapp/widgets/cart_button_widget.dart';
import 'package:qrdapp/widgets/category_list_widget.dart';
import 'package:qrdapp/widgets/special_section_widget.dart';
import 'package:qrdapp/widgets/popular_products_widget.dart';
import 'package:qrdapp/screens/products/product_list_screen.dart';
import 'package:qrdapp/screens/products/products_detail_screen.dart';
import 'package:qrdapp/services/categories/categories_service.dart';
import 'package:qrdapp/services/auth/auth_service.dart';

/// Main customer dashboard screen
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;
  List<dynamic> categories = [];
  Map<String, List<dynamic>> categoryProducts = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndProducts();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Fetch all categories and their associated products
  Future<void> fetchCategoriesAndProducts() async {
    setState(() => isLoading = true);
    try {
      final fetched = await CategoryService.fetchCategories();
      setState(() => categories = fetched);
      for (var cat in fetched) {
        final id = cat['ID']?.toString();
        if (id != null) {
          final products = await CategoryService.fetchProductsByCategory(id);
          setState(() => categoryProducts[id] = products);
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories/products: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Handles user logout logic and navigation
  Future<void> _logoutUser() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
        context, '/login'); // ⬅️ Ensure this route exists in your app
  }

  /// Pages displayed in the dashboard, depending on selected tab
  List<Widget> get pages => [
        // 🏠 Featured/Home Page
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: SearchBarWidget()),
                const SizedBox(width: 8),
                CartButtonWidget(itemCount: 3),
              ],
            ),
            const SizedBox(height: 16),
            CategoryListWidget(
              categories: categories,
              onTap: (cat) {
                final id = cat['ID']?.toString();
                final merchant = cat['merchant_id']?.toString();
                if (id != null && merchant != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(merchantId: merchant),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Special for you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SpecialSectionWidget(
              categories: categories,
              categoryProducts: categoryProducts,
              onTap: (cat) {
                final id = cat['ID']?.toString();
                final merchant = cat['merchant_id']?.toString();
                if (id != null && merchant != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(merchantId: merchant),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Popular Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            PopularProductsWidget(
              categories: categories,
              categoryProducts: categoryProducts,
              onTap: (product) {
                final id = product['ID']?.toString();
                if (id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: id),
                    ),
                  );
                }
              },
            ),
          ],
        ),

        // 🔍 Search Placeholder
        const Center(child: Text('Search')),

        // ➕ Add Item Placeholder
        const Center(child: Text('Add Item')),

        // 🔔 Notifications Placeholder
        const Center(child: Text('Notifications')),

        // 👤 Profile Page with Logout Button
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to your profile!',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _logoutUser,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.star_border), label: 'Featured'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
