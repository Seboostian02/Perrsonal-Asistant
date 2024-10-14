import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final int number;

  const EventCard({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Event $number',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
