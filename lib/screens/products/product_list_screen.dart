import 'package:flutter/material.dart';
import 'package:qrdapp/services/products/products_service.dart';
import 'package:qrdapp/screens/products/products_detail_screen.dart';

/// Screen displaying products for a given merchant.
class ProductListScreen extends StatefulWidget {
  final String merchantId;

  const ProductListScreen({super.key, required this.merchantId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('Loading products for merchantId: ${widget.merchantId}');
    _productsFuture = ProductService.getProductsByMerchant(widget.merchantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Products')),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          debugPrint('ProductList snapshot: state=${snapshot.connectionState}, hasData=${snapshot.hasData}, error=${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
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