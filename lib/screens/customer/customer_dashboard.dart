import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  List<dynamic> categories = [];
  Map<String, List<dynamic>> categoryProducts = {};
  final int merchantID = 1; // Replace this
  final String backendURL = "http:/192.168.100.42:8080"; // Replace this

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

  Future<void> fetchCategoriesAndProducts() async {
    final res = await http.get(Uri.parse("$backendURL/categories/merchant/$merchantID"));
    if (res.statusCode == 200) {
      final categoryData = jsonDecode(res.body);
      setState(() {
        categories = categoryData;
      });

      for (var category in categoryData) {
        final id = category['_id'];
        final productRes = await http.get(Uri.parse("$backendURL/categories/$id/products"));
        if (productRes.statusCode == 200) {
          setState(() {
            categoryProducts[id] = jsonDecode(productRes.body);
          });
        }
      }
    }
  }

  Widget _buildFeaturedTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search product",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange[100],
                        child: const Icon(Icons.category),
                      ),
                      const SizedBox(height: 4),
                      Text(cat['name'], style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
          const Text("Special for you", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((cat) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text("${categoryProducts[cat['_id']]?.length ?? 0} products", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
          const Text("Popular Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (categories.isNotEmpty && categoryProducts[categories[0]['_id']] != null)
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categoryProducts[categories[0]['_id']]!
                    .map((product) => Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(child: Icon(Icons.image, size: 60)),
                              const SizedBox(height: 8),
                              Text(product['name'] ?? 'No name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Ksh ${product['price']}", style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    _pages.clear(); // rebuild list with current featured content
    _pages.add(_buildFeaturedTab());
    _pages.addAll([
      const Center(child: Text("Search")),
      const Center(child: Text("Add Item")),
      const Center(child: Text("Notifications")),
      const Center(child: Text("Profile")),
    ]);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Featured'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
