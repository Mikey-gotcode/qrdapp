import 'package:flutter/material.dart';
import 'package:qrdapp/screens/products/product_management_screen.dart'; // Import your product management screen
import 'package:qrdapp/screens/categories/category_management_screen.dart'; // Import your category management screen
//import 'package:qrdapp/screens/merchant/events/event_management_screen.dart'; // Import your event management screen

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  _ManagementDashboardState createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Listings'), // Changed title
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProductManagementScreen(), // Use your Product Management Screen
          CategoryManagementScreen(), // Use your Category Management Screen
         // EventManagementScreen(),     // Use your Event Management Screen
        ],
      ),
    );
  }
}
