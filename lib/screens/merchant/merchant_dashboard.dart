import 'package:flutter/material.dart';
import 'package:qrdapp/screens/merchant/orders/order_screen.dart';
import 'package:qrdapp/screens/merchant/addresses/map_screen.dart';
import 'package:qrdapp/services/auth/auth_storage.dart';

// Import the new tabbed dashboard
import 'package:qrdapp/screens/merchant/management_dashboard.dart'; // Import the new file

class MerchantDashboard extends StatelessWidget {
  const MerchantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shoplon"),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 10),
          Icon(Icons.notifications_none),
          SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text("Hi, Merchant", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("merchant@example.com", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFB36FE0), Color(0xFF5F5EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Starter Plan", style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text("All features unlocked!", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                  ),
                  child: const Text("Upgrade"),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildMenuItem(context, Icons.shopping_bag, "Orders", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen()));
          }),
          _buildMenuItem(context, Icons.assignment_return, "Returns", () {}),
          _buildMenuItem(context, Icons.favorite_border, "Wishlist", () {}),
          _buildMenuItem(context, Icons.location_on_outlined, "Addresses", () async {
            final merchantId = await SecureStorageService.getUserId();
            if (merchantId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MapScreen(merchantId: merchantId)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User ID not found. Please log in again.")),
              );
            }
          }),
          _buildMenuItem(context, Icons.payment, "Payment", () {}),
          _buildMenuItem(context, Icons.account_balance_wallet, "Wallet", () {}),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Changed to 1 to select the GridView icon
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) { // Index 1 is now the GridView
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManagementDashboard()), // Navigate
            );
          } else if (index == 4) {
             // Handle "Profile"navigation
             Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantDashboard()));
          }
          else if (index == 0){
             Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantDashboard()));
          }
           else if (index == 2){
             Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""), // GridView
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

