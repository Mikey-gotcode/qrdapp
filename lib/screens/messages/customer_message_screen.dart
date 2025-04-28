import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class CustomerMessageScreen extends StatefulWidget {
  final int orderId;
  final int merchantId; // Or however you identify the merchant

  const CustomerMessageScreen({super.key, required this.orderId, required this.merchantId});

  @override
  State<CustomerMessageScreen> createState() => _CustomerMessageScreenState();
}

class _CustomerMessageScreenState extends State<CustomerMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  WebSocketChannel? _channel;
  final int _customerId = 123; // Replace with the actual customer ID

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void _connectWebSocket() {
    final Uri uri = Uri.parse('ws://YOUR_GO_BACKEND_IP:8080/ws');
    try {
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen((message) {
        print('Customer received: $message');
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          setState(() {
            _messages.add(ChatMessage.fromJson(data));
          });
        } catch (e) {
          print('Customer error decoding: $e');
        }
      }, onDone: () => print('Customer WS closed'), onError: (error) => print('Customer WS error: $error'));

      _send({'type': 'joinOrderRoom', 'orderId': widget.orderId, 'sender': 'customer_$_customerId'});
    } catch (e) {
      print('Customer connect error: $e');
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _channel != null) {
      final message = {
        'orderId': widget.orderId,
        'sender': 'customer_$_customerId',
        'text': text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _send({'type': 'sendMessage', 'payload': message});
      setState(() {
        _messages.add(ChatMessage(sender: 'customer_$_customerId', text: text, timestamp: DateTime.now().millisecondsSinceEpoch));
        _messageController.clear();
      });
    }
  }

  void _send(dynamic message) {
    _channel?.sink.add(jsonEncode(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${widget.orderId} Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message.sender == 'customer_$_customerId';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF800080) : const Color(0xFF808080),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final int timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] as int,
    );
  }
}