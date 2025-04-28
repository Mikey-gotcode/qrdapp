import 'package:flutter/material.dart';
import 'package:qrdapp/screens/messages/message_screen.dart'; // Import ChatMessage

class MessageView extends StatelessWidget {
  final List<ChatMessage> messages;
  final String merchantName;

  const MessageView({super.key, required this.messages, required this.merchantName});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isMe = message.sender == merchantName;
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
    );
  }
}