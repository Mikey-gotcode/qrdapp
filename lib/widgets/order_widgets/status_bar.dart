import 'package:flutter/material.dart';

class StatusTab extends StatelessWidget {
  final String title;
  final int count;

  const StatusTab({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }
}