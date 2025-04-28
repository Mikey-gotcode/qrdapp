import 'package:flutter/material.dart';
import 'package:qrdapp/screens/messages/customer_message_screen.dart';
import 'package:qrdapp/services/messages/message_services.dart';
import 'package:qrdapp/services/orders/order_service.dart';

class NotificationManagementScreen extends StatefulWidget {
  final int customerId;

  const NotificationManagementScreen({super.key, required this.customerId});

  @override
  State<NotificationManagementScreen> createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MessageService _messageService;
  final OrderService _orderService = OrderService();

  List<Order> _pendingOrders = [];
  List<Order> _activeOrders = [];
  List<Map<String, dynamic>> _chatRooms = [];

  bool _isLoadingOrders = false;
  bool _isLoadingChatRooms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize MessageService before usage
    _messageService = MessageService(onReceiveMessage: (data) {
      print('Received message in notification screen: \$data');
    });

    _loadPendingAndActiveOrders();
    _loadChatRooms();
  }

  Future<void> _loadPendingAndActiveOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });
    try {
      final pending = await _orderService.fetchOrdersByCustomerIDandStatus(
          widget.customerId, 'pending');
      final active = await _orderService.fetchOrdersByCustomerIDandStatus(
          widget.customerId, 'active');

      setState(() {
        _pendingOrders = pending;
        _activeOrders = active;
      });
    } catch (e) {
      debugPrint('Error fetching orders: \$e');
    } finally {
      setState(() {
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoadingChatRooms = true;
    });
    try {
      final rooms = await _messageService.fetchChatrooms(widget.customerId);
      setState(() {
        // Assuming fetchChatrooms returns List<Map<String, dynamic>>
        _chatRooms = List<Map<String, dynamic>>.from(rooms);
      });
    } catch (e) {
      debugPrint('Error fetching chat rooms: \$e');
    } finally {
      setState(() {
        _isLoadingChatRooms = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Transactions Tab
          _isLoadingOrders
              ? const Center(child: CircularProgressIndicator())
              : (_pendingOrders.isEmpty && _activeOrders.isEmpty)
                  ? const Center(child: Text('No pending or active transactions.'))
                  : ListView(
                      children: [
                        if (_pendingOrders.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Pending Orders',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ..._pendingOrders.map((order) => _buildOrderCard(order)),

                        if (_activeOrders.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Active Orders',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ..._activeOrders.map((order) => _buildOrderCard(order)),
                      ],
                    ),

          // Messages Tab
          _isLoadingChatRooms
              ? const Center(child: CircularProgressIndicator())
              : _chatRooms.isEmpty
                  ? const Center(child: Text('No active chats.'))
                  : ListView.builder(
                      itemCount: _chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = _chatRooms[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              "Chat with \${chatRoom['merchantName'] ?? 'Merchant'}"
                            ),
                            subtitle: Text(
                              "Order ID: \${chatRoom['orderId'] ?? 'N/A'}"
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerMessageScreen(
                                    orderId: chatRoom['orderId'],
                                    merchantId: chatRoom['merchantId'] ?? -1,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final date = DateTime.fromMillisecondsSinceEpoch(order.createdAt).toLocal();
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: \${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text('Status: \${order.status}'),
            Text('Total Amount: \$\${order.total.toStringAsFixed(2)}'),
            Text('Order Date: \$date'),
          ],
        ),
      ),
    );
  }
}
