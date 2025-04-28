import 'package:flutter/material.dart';
import 'package:qrdapp/services/products/products_service.dart';
import 'package:qrdapp/screens/products/products_detail_screen.dart';

/// Screen displaying products for a given merchant, optionally filtered by category.
class ProductListScreen extends StatefulWidget {
  final String merchantId;
  final String? categoryId;
  final String? selectedLocation; // Add selectedLocation
  final String? currentLocation;  // Add currentLocation

  const ProductListScreen({
    super.key,
    required this.merchantId,
    this.categoryId,
    this.selectedLocation, // Initialize selectedLocation
    this.currentLocation,  // Initialize currentLocation
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('Loading products for merchantId: ${widget.merchantId}, categoryId: ${widget.categoryId}, selectedLocation: ${widget.selectedLocation}');
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (widget.selectedLocation != null) {
      String locationName = widget.selectedLocation!;
      if (locationName.startsWith("Current Location") && widget.currentLocation != null) {
        locationName = widget.currentLocation!;
      }
      if (widget.categoryId != null) {
        // Fetch products by location AND category
        _productsFuture = ProductService.fetchProductsByLocationAndCategory(locationName, widget.categoryId!);
      } else {
        // Fetch all products for the location
        _productsFuture = ProductService.fetchProductsByLocation(locationName);
      }
    } else {
      // Fallback if location is not available (shouldn't happen in normal flow)
      _productsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId != null ? 'Category Products' : 'All Products'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          debugPrint('ProductList snapshot: state=${snapshot.connectionState}, hasData=${snapshot.hasData}, error=${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found in this category at the selected location.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final String? id = product['ID']?.toString();
              final name = product['name'] ?? 'Unnamed';
              final price = product['price']?.toString() ?? '0';

              return ListTile(
                title: Text(name),
                subtitle: Text('Ksh $price'),
                onTap: () {
                  debugPrint('Tapped product: \$name (ID: \$id)');
                  if (id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: id),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}