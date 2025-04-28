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
import 'package:qrdapp/services/addresses/addresses_services.dart'; // Import location service
import 'package:qrdapp/services/products/products_service.dart';
import 'package:qrdapp/models/location.dart';
import 'package:qrdapp/screens/notifications/notification_management_screen.dart'; // Import NotificationManagementScreen

/// Main customer dashboard screen
class CustomerDashboardScreen extends StatefulWidget {
  final int customerId; // Receive customerId
  const CustomerDashboardScreen({super.key, required this.customerId});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;
  List<dynamic> categories = [];
  Map<String, List<dynamic>> categoryProducts = {};
  bool isLoading = false;
  String? _currentLocation;
  List<LocationModel> _locations = []; // Use the Location model
  String? _selectedLocationName; // Store selected location name

  @override
  void initState() {
    super.initState();
    _loadLocations(); // Load locations from service
    _getCurrentLocation(); //get current location
  }

  Future<void> _loadLocations() async {
    setState(() => isLoading = true);
    try {
      _locations = await AddressService.getAllLocations();
      // Initialize selected location with a default value or user's current location if available.
      if (_locations.isNotEmpty) {
        setState(() {
          _selectedLocationName = _locations[0].name; // Default to first location
        });
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      // Handle error (e.g., show a message to the user)
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      // Simulate getting the user's current location.  Replace this with a real implementation.
      //  _currentLocation = await LocationService.getCurrentLocation();  //removed await
      _currentLocation = "Nairobi"; //Hardcoded
      if (_currentLocation != null) {
        setState(() {
          _selectedLocationName =
              "Current Location ($_currentLocation)"; //set the dropdown value
        });
      }
      fetchCategoriesAndProductsByLocation(_currentLocation!);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Handle error (e.g., show a message)
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Fetch categories and products based on the selected location
  Future<void> fetchCategoriesAndProductsByLocation(String locationName) async {
    setState(() => isLoading = true);
    try {
      final fetchedCategories =
          await CategoryService.fetchCategoriesByLocation(locationName); // Pass the name
      setState(() => categories = fetchedCategories);

      categoryProducts.clear(); // Clear previous products

      // Instead of fetching products by category, fetch all products for the location
      final allProductsInLocation =
          await ProductService.fetchProductsByLocation(locationName);

      // Now, organize these products by their category
      for (var product in allProductsInLocation) {
        final categoryId = product['category_id']?.toString();
        if (categoryId != null) {
          if (!categoryProducts.containsKey(categoryId)) {
            categoryProducts[categoryId] = [];
          }
          categoryProducts[categoryId]!.add(product);
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories/products by location: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Handles user logout logic and navigation
  Future<void> _logoutUser() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Pages displayed in the dashboard, depending on selected tab
  List<Widget> get pages => [
        // 🏠 Featured/Home Page with Pull-to-Refresh
        RefreshIndicator(
          onRefresh: () async {
            if (_selectedLocationName != null) {
              String locationName = _selectedLocationName!;
              if (locationName.startsWith("Current Location")) {
                locationName = _currentLocation!;
              }
              await fetchCategoriesAndProductsByLocation(locationName);
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: SearchBarWidget()),
                  const SizedBox(width: 8),
                  // Location Dropdown
                  DropdownButton<String>(
                    value: _selectedLocationName,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLocationName = newValue;
                        });
                        String locationName = newValue;
                        if (newValue.startsWith("Current Location")) {
                          locationName = _currentLocation!;
                        }
                        fetchCategoriesAndProductsByLocation(locationName);
                      }
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: "Current Location ($_currentLocation)",
                        child: const Text("Current Location"),
                      ),
                      ..._locations
                          .map<DropdownMenuItem<String>>((LocationModel location) {
                        return DropdownMenuItem<String>(
                          value: location.name,
                          child: Text(location.name ?? ''),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const CartButtonWidget(),
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
                        builder: (_) => ProductListScreen(
                          merchantId: merchant,
                          categoryId: id,
                          selectedLocation: _selectedLocationName,
                          currentLocation: _currentLocation,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
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
                        builder: (_) => ProductListScreen(
                          merchantId: merchant,
                          categoryId: id,
                          selectedLocation: _selectedLocationName,
                          currentLocation: _currentLocation,
                        ),
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
        ),

        // 🔍 Search Placeholder
        const Center(child: Text('Search')),

        // ➕ Add Item Placeholder
        const Center(child: Text('Add Item')),

        // 🔔 Notifications Screen
        NotificationManagementScreen(customerId: widget.customerId),

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