import 'package:calendar/screens/event_view_on_map.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class EventCard extends StatelessWidget {
  final calendar.Event event;
  final bool showLocation;
  static const List<Color> colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
  ];

  const EventCard({
    Key? key,
    required this.event,
    this.showLocation = false,
  }) : super(key: key);

  void _onLocationTap(BuildContext context) {
    if (showLocation) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => EventView(
            events: [event],
            showBackArrow: true,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    }
  }

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
              onTap: () => _onLocationTap(context),
              child: Text(
                'Location: ${event.location ?? "No Location"}',
                style: TextStyle(
                  fontSize: 16,
                  color: showLocation ? Colors.blue : Colors.grey,
                  decoration: showLocation
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
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
