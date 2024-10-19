import 'package:flutter/material.dart';
import 'dart:math';

class EventCard extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String startTime;
  final String endTime;

  static const List<Color> colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
  ];

  const EventCard({
    super.key,
    required this.title,
    required this.location,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final randomIndex = Random().nextInt(colors.length);
    final backgroundColor = colors[randomIndex];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Location: $location',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Starts at: $startTime',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Ends at: $endTime',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
