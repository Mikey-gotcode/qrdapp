import 'package:flutter/material.dart';
import 'package:qrdapp/widgets/messaging/message_view.dart';
import 'package:qrdapp/widgets/messaging/message_input.dart';
import 'package:qrdapp/services/messages/message_services.dart';

class MessageScreen extends StatefulWidget {
  final int orderId;
  final int customerId;

  const MessageScreen({super.key, required this.orderId, required this.customerId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late MessageService _messageService;
  final String _merchantName = 'Merchant'; // Define merchant name here

  @override
  void initState() {
    super.initState();
    _messageService = MessageService(onReceiveMessage: _handleReceiveMessage, merchantName: _merchantName);
    _messageService.connect(widget.orderId ,'customer_${widget.customerId}');
  }

  @override
  void dispose() {
    _messageService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _handleReceiveMessage(Map<String, dynamic> data) {
    final message = ChatMessage.fromJson(data);
    setState(() {
      _messages.add(message);
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageService.sendMessage(widget.orderId, text, 'customer_${widget.customerId}');
      final message = ChatMessage(
        sender: _merchantName,
        text: text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      setState(() {
        _messages.add(message);
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const BackButton(),
            const SizedBox(width: 8.0),
            Text('Customer ${widget.customerId}'), // Replace with actual customer name
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageView(messages: _messages, merchantName: _merchantName),
          ),
          MessageInput( // Use the imported widget
            messageController: _messageController,
            onSend: _sendMessage,
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
      sender: json['sender'],
      text: json['text'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
    };
  }
}