import 'package:calendar/screens/event_view_on_map.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class EventCard extends StatelessWidget {
  final calendar.Event event;

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
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final randomIndex = Random().nextInt(colors.length);
    final backgroundColor = colors[randomIndex];

    final startDateTime = DateTime.parse(event.start!.dateTime!.toString());
    final endDateTime = DateTime.parse(event.end!.dateTime!.toString());
    final String startHour =
        "${startDateTime.hour}:${startDateTime.minute.toString().padLeft(2, '0')}";
    final String endHour =
        "${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}";

    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(startDateTime);

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
              event.summary ?? "No Title",
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              event.description ?? "No Description",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventView(
                      events: [event], // Transmiterea evenimentului selectat
                    ),
                  ),
                );
              },
              child: Text(
                'Location: ${event.location ?? "No Location"}',
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: $formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Starts at: $startHour',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Ends at: $endHour',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
