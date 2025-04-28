import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageService {
  WebSocketChannel? _channel;
  final String? merchantName; // Make merchantName nullable for customer service
  final Function(Map<String, dynamic>) onReceiveMessage;
  final String _baseUrl = 'http://192.168.100.24:8080'; // Your Go backend URL

  MessageService({required this.onReceiveMessage, this.merchantName});

  void connect(int orderId, String sender) {
    // Replace with your WebSocket server URL for the /ws endpoint
    final Uri uri = Uri.parse('ws://192.168.100.24:8080/ws');
    try {
      _channel = IOWebSocketChannel.connect(uri);
      _channel!.stream.listen((message) {
        print('Received raw WebSocket message: $message');
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          onReceiveMessage(data);
        } catch (e) {
          print('Error decoding WebSocket message: $e');
        }
      }, onDone: () {
        print('WebSocket connection closed');
        _channel = null;
      }, onError: (error) {
        print('WebSocket error: $error');
        _channel = null;
      });

      // Send join order room message after connection
      _send({'type': 'joinOrderRoom', 'orderId': orderId, 'sender': sender});

    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _channel = null;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void sendMessage(int orderId, String text, String sender) {
    if (_channel != null) {
      final message = {
        'orderId': orderId,
        'sender': sender,
        'text': text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _send({'type': 'sendMessage', 'payload': message});
    } else {
      print('WebSocket not connected, cannot send message.');
    }
  }

  void _send(dynamic message) {
    if (_channel != null) {
      final String encodedMessage = jsonEncode(message);
      print('Sending raw WebSocket message: $encodedMessage');
      _channel!.sink.add(encodedMessage);
    } else {
      print('WebSocket not connected, cannot send data.');
    }
  }

  Future<List<dynamic>> fetchChatrooms(int customerId) async {
    final Uri uri = Uri.parse('$_baseUrl/users/$customerId/chatrooms'); // Adjust your backend API endpoint
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to fetch chatrooms: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching chatrooms: $e');
      return [];
    }
  }
}