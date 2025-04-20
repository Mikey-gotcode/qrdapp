import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search product',
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
      );
}
