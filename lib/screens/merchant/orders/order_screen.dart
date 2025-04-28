import 'package:flutter/material.dart';
import 'package:qrdapp/services/orders/order_service.dart';
import 'package:qrdapp/widgets/order_widgets/status_bar.dart';
import 'package:qrdapp/widgets/order_widgets/order_list.dart';
import 'package:qrdapp/services/auth/auth_storage.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _newOrdersFuture;
  late Future<List<Order>> _activeOrdersFuture;
  late Future<List<Order>> _completedOrdersFuture;
  int _newOrderCount = 0;
  int _activeOrderCount = 0;
  int _completedOrderCount = 0;
  bool _isLoading = true; // To show loading indicator initially

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeOrders();
  }

  Future<void> _initializeOrders() async {
    setState(() {
      _isLoading = true;
    });
    final int? userId = await SecureStorageService.getUserId();

    print("Retrieved userId from SecureStorage: $userId");

    if (userId == null) {
      print("User ID is null from secure storage. Cannot fetch orders.");
      setState(() {
        _newOrdersFuture = Future.error("User ID is null");
        _activeOrdersFuture = Future.error("User ID is null");
        _completedOrdersFuture = Future.error("User ID is null");
        _isLoading = false;
      });
      return;
    }

    print("Calling fetchOrdersByStatus with userId: $userId");

    try {
      final newOrders = await _orderService.fetchOrdersByStatus(userId, 'new');
      final activeOrders = await _orderService.fetchOrdersByStatus(userId, 'accepted');
      final completedOrders = await _orderService.fetchOrdersByStatus(userId, 'completed');

      setState(() {
        _newOrderCount = newOrders.length;
        _activeOrderCount = activeOrders.length;
        _completedOrderCount = completedOrders.length;
        _newOrdersFuture = Future.value(newOrders);
        _activeOrdersFuture = Future.value(activeOrders);
        _completedOrdersFuture = Future.value(completedOrders);
        _isLoading = false;
      });
    } catch (error) {
      print("Error fetching orders: $error");
      setState(() {
        _newOrdersFuture = Future.error(error);
        _activeOrdersFuture = Future.error(error);
        _completedOrdersFuture = Future.error(error);
        _isLoading = false;
      });
    }
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
        title: const Text('Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black87,
          tabs: [
            Tab(
              child: StatusTab(title: 'New', count: _newOrderCount),
            ),
            Tab(
              child: StatusTab(title: 'Active', count: _activeOrderCount),
            ),
            Tab(
              child: StatusTab(title: 'Completed', count: _completedOrderCount),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                OrderList(ordersFuture: _newOrdersFuture),
                OrderList(ordersFuture: _activeOrdersFuture),
                OrderList(ordersFuture: _completedOrdersFuture),
              ],
            ),
    );
  }
}