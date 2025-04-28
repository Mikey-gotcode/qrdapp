import 'package:flutter/material.dart';
import 'package:qrdapp/services/orders/order_service.dart'; // Import the OrderService
import 'package:qrdapp/screens/messages/message_screen.dart'; // Import MessageScreen

class OrderCard extends StatefulWidget {
  final Order order;
  final Function()? onOrderUpdated; // Optional callback for when order status changes

  const OrderCard({super.key, required this.order, this.onOrderUpdated});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late String _orderStatus;
  bool _isLoading = false;
  final OrderService _orderService = OrderService();
  DateTime? _acceptTime;
  bool _canCancel = true;

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.order.status;
    if (_orderStatus == 'accepted') {
      _acceptTime = DateTime.now();
      _startCancelTimer();
    }
  }

  void _startCancelTimer() {
    Future.delayed(const Duration(minutes: 10), () {
      if (mounted && _orderStatus == 'new') {
        setState(() {
          _canCancel = true;
        });
      }
    });
    setState(() {
      _canCancel = false;
    });
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Order? updatedOrder;
      if (newStatus == 'accepted') {
        updatedOrder = await _orderService.acceptOrder(orderId);
        _acceptTime = DateTime.now();
        _startCancelTimer();
            } else if (newStatus == 'cancelled') {
        updatedOrder = await _orderService.cancelOrder(orderId);
      } else if (newStatus == 'completed') {
        updatedOrder = await _orderService.completeOrder(orderId);
      }

      if (updatedOrder != null) {
        setState(() {
          _orderStatus = updatedOrder?.status ?? _orderStatus;
        });
        if (widget.onOrderUpdated != null) {
          widget.onOrderUpdated!(); // Call the callback if provided
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${updatedOrder.id} $_orderStatus successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update order status.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ID: ${widget.order.userId}', // Replace with actual customer name if available
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      'Order ID: ${widget.order.id}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Text('\$${widget.order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8.0),
            ...widget.order.items.map((item) =>
                Text('${item.quantity} x Product ID ${item.productId} (\$${item.price.toStringAsFixed(2)})')),
            const SizedBox(height: 16.0),
            Text(
              'Created At: ${DateTime.fromMillisecondsSinceEpoch(widget.order.createdAt * 1000)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Status: $_orderStatus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _orderStatus == 'new'
                    ? Colors.orange
                    : _orderStatus == 'accepted'
                        ? Colors.green
                        : _orderStatus == 'completed'
                            ? Colors.blue
                            : _orderStatus == 'cancelled'
                                ? Colors.red
                                : Colors.grey,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading || _orderStatus != 'new' || !_canCancel
                      ? null
                      : () {
                          _updateOrderStatus(widget.order.id, 'cancelled');
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading && _orderStatus == 'cancelled'
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                      : Text(_canCancel ? 'CANCEL' : 'CANCEL (Disabled)'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _isLoading || _orderStatus != 'new'
                      ? null
                      : () {
                          _updateOrderStatus(widget.order.id, 'accepted');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading && _orderStatus == 'accepted'
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('ACCEPT'),
                ),
                const SizedBox(width: 8.0),
                if (_orderStatus == 'accepted')
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _updateOrderStatus(widget.order.id, 'completed');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading && _orderStatus == 'completed'
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('COMPLETE'),
                  ),
                const SizedBox(width: 8.0),
                if (_orderStatus == 'accepted' || _orderStatus == 'active')
                  IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageScreen(orderId: widget.order.id, customerId: widget.order.userId),
                        ),
                      );
                    },
                  ),
                if (_orderStatus != 'accepted' && _orderStatus != 'active')
                  IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () {
                      // Handle call action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Call functionality not implemented')),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}