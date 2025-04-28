import 'package:flutter/material.dart';
import 'package:qrdapp/services/orders/order_service.dart';
import 'order_card.dart';

class OrderList extends StatelessWidget {
  final Future<List<Order>> ordersFuture;

  const OrderList({super.key, required this.ordersFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No orders found.'));
        } else {
          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        }
      },
    );
  }
}